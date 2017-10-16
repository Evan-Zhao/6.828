
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
f0100015:	b8 00 60 11 00       	mov    $0x116000,%eax
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
f0100034:	bc 00 60 11 f0       	mov    $0xf0116000,%esp

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
f010004b:	68 60 3a 10 f0       	push   $0xf0103a60
f0100050:	e8 14 2a 00 00       	call   f0102a69 <cprintf>
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
f0100065:	e8 06 08 00 00       	call   f0100870 <mon_backtrace>
f010006a:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010006d:	83 ec 08             	sub    $0x8,%esp
f0100070:	53                   	push   %ebx
f0100071:	68 7c 3a 10 f0       	push   $0xf0103a7c
f0100076:	e8 ee 29 00 00       	call   f0102a69 <cprintf>
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
f010009a:	b8 70 89 11 f0       	mov    $0xf0118970,%eax
f010009f:	2d 00 83 11 f0       	sub    $0xf0118300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 83 11 f0       	push   $0xf0118300
f01000ac:	e8 e7 34 00 00       	call   f0103598 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 d8 04 00 00       	call   f010058e <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 97 3a 10 f0       	push   $0xf0103a97
f01000c3:	e8 a1 29 00 00       	call   f0102a69 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000c8:	e8 2a 11 00 00       	call   f01011f7 <mem_init>
	cprintf(ANSI_COLOR_RED     "This text is RED!"     ANSI_COLOR_RESET "\n");
f01000cd:	c7 04 24 b2 3a 10 f0 	movl   $0xf0103ab2,(%esp)
f01000d4:	e8 90 29 00 00       	call   f0102a69 <cprintf>
	cprintf(ANSI_COLOR_GREEN   "This text is GREEN!"   ANSI_COLOR_RESET "\n");
f01000d9:	c7 04 24 ce 3a 10 f0 	movl   $0xf0103ace,(%esp)
f01000e0:	e8 84 29 00 00       	call   f0102a69 <cprintf>
	cprintf(ANSI_COLOR_YELLOW  "This text is YELLOW!"  ANSI_COLOR_RESET "\n");
f01000e5:	c7 04 24 58 3b 10 f0 	movl   $0xf0103b58,(%esp)
f01000ec:	e8 78 29 00 00       	call   f0102a69 <cprintf>
	cprintf(ANSI_COLOR_BLUE    "This text is BLUE!"    ANSI_COLOR_RESET "\n");
f01000f1:	c7 04 24 ec 3a 10 f0 	movl   $0xf0103aec,(%esp)
f01000f8:	e8 6c 29 00 00       	call   f0102a69 <cprintf>
	cprintf(ANSI_COLOR_MAGENTA "This text is MAGENTA!" ANSI_COLOR_RESET "\n");
f01000fd:	c7 04 24 78 3b 10 f0 	movl   $0xf0103b78,(%esp)
f0100104:	e8 60 29 00 00       	call   f0102a69 <cprintf>
	cprintf(ANSI_COLOR_CYAN    "This text is CYAN!"    ANSI_COLOR_RESET "\n");
f0100109:	c7 04 24 09 3b 10 f0 	movl   $0xf0103b09,(%esp)
f0100110:	e8 54 29 00 00       	call   f0102a69 <cprintf>

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
f0100129:	e8 e6 07 00 00       	call   f0100914 <monitor>
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
f010013b:	83 3d 60 89 11 f0 00 	cmpl   $0x0,0xf0118960
f0100142:	74 0f                	je     f0100153 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100144:	83 ec 0c             	sub    $0xc,%esp
f0100147:	6a 00                	push   $0x0
f0100149:	e8 c6 07 00 00       	call   f0100914 <monitor>
f010014e:	83 c4 10             	add    $0x10,%esp
f0100151:	eb f1                	jmp    f0100144 <_panic+0x11>
	panicstr = fmt;
f0100153:	89 35 60 89 11 f0    	mov    %esi,0xf0118960
	asm volatile("cli; cld");
f0100159:	fa                   	cli    
f010015a:	fc                   	cld    
	va_start(ap, fmt);
f010015b:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f010015e:	83 ec 04             	sub    $0x4,%esp
f0100161:	ff 75 0c             	pushl  0xc(%ebp)
f0100164:	ff 75 08             	pushl  0x8(%ebp)
f0100167:	68 26 3b 10 f0       	push   $0xf0103b26
f010016c:	e8 f8 28 00 00       	call   f0102a69 <cprintf>
	vcprintf(fmt, ap);
f0100171:	83 c4 08             	add    $0x8,%esp
f0100174:	53                   	push   %ebx
f0100175:	56                   	push   %esi
f0100176:	e8 c8 28 00 00       	call   f0102a43 <vcprintf>
	cprintf("\n");
f010017b:	c7 04 24 98 4b 10 f0 	movl   $0xf0104b98,(%esp)
f0100182:	e8 e2 28 00 00       	call   f0102a69 <cprintf>
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
f010019c:	68 3e 3b 10 f0       	push   $0xf0103b3e
f01001a1:	e8 c3 28 00 00       	call   f0102a69 <cprintf>
	vcprintf(fmt, ap);
f01001a6:	83 c4 08             	add    $0x8,%esp
f01001a9:	53                   	push   %ebx
f01001aa:	ff 75 10             	pushl  0x10(%ebp)
f01001ad:	e8 91 28 00 00       	call   f0102a43 <vcprintf>
	cprintf("\n");
f01001b2:	c7 04 24 98 4b 10 f0 	movl   $0xf0104b98,(%esp)
f01001b9:	e8 ab 28 00 00       	call   f0102a69 <cprintf>
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
f01001f9:	8b 0d 24 85 11 f0    	mov    0xf0118524,%ecx
f01001ff:	8d 51 01             	lea    0x1(%ecx),%edx
f0100202:	89 15 24 85 11 f0    	mov    %edx,0xf0118524
f0100208:	88 81 20 83 11 f0    	mov    %al,-0xfee7ce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010020e:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100214:	75 d8                	jne    f01001ee <cons_intr+0x9>
			cons.wpos = 0;
f0100216:	c7 05 24 85 11 f0 00 	movl   $0x0,0xf0118524
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
f010025d:	8b 0d 00 83 11 f0    	mov    0xf0118300,%ecx
f0100263:	f6 c1 40             	test   $0x40,%cl
f0100266:	74 0e                	je     f0100276 <kbd_proc_data+0x4e>
		data |= 0x80;
f0100268:	83 c8 80             	or     $0xffffff80,%eax
f010026b:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f010026d:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100270:	89 0d 00 83 11 f0    	mov    %ecx,0xf0118300
	shift |= shiftcode[data];
f0100276:	0f b6 d2             	movzbl %dl,%edx
f0100279:	0f b6 82 00 3d 10 f0 	movzbl -0xfefc300(%edx),%eax
f0100280:	0b 05 00 83 11 f0    	or     0xf0118300,%eax
	shift ^= togglecode[data];
f0100286:	0f b6 8a 00 3c 10 f0 	movzbl -0xfefc400(%edx),%ecx
f010028d:	31 c8                	xor    %ecx,%eax
f010028f:	a3 00 83 11 f0       	mov    %eax,0xf0118300
	c = charcode[shift & (CTL | SHIFT)][data];
f0100294:	89 c1                	mov    %eax,%ecx
f0100296:	83 e1 03             	and    $0x3,%ecx
f0100299:	8b 0c 8d e0 3b 10 f0 	mov    -0xfefc420(,%ecx,4),%ecx
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
f01002c8:	68 98 3b 10 f0       	push   $0xf0103b98
f01002cd:	e8 97 27 00 00       	call   f0102a69 <cprintf>
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
f01002df:	83 0d 00 83 11 f0 40 	orl    $0x40,0xf0118300
		return 0;
f01002e6:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f01002eb:	89 d8                	mov    %ebx,%eax
f01002ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002f0:	c9                   	leave  
f01002f1:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002f2:	8b 0d 00 83 11 f0    	mov    0xf0118300,%ecx
f01002f8:	f6 c1 40             	test   $0x40,%cl
f01002fb:	75 05                	jne    f0100302 <kbd_proc_data+0xda>
f01002fd:	83 e0 7f             	and    $0x7f,%eax
f0100300:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f0100302:	0f b6 d2             	movzbl %dl,%edx
f0100305:	8a 82 00 3d 10 f0    	mov    -0xfefc300(%edx),%al
f010030b:	83 c8 40             	or     $0x40,%eax
f010030e:	0f b6 c0             	movzbl %al,%eax
f0100311:	f7 d0                	not    %eax
f0100313:	21 c8                	and    %ecx,%eax
f0100315:	a3 00 83 11 f0       	mov    %eax,0xf0118300
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
f01003db:	66 8b 0d 28 85 11 f0 	mov    0xf0118528,%cx
f01003e2:	bb 50 00 00 00       	mov    $0x50,%ebx
f01003e7:	89 c8                	mov    %ecx,%eax
f01003e9:	ba 00 00 00 00       	mov    $0x0,%edx
f01003ee:	66 f7 f3             	div    %bx
f01003f1:	29 d1                	sub    %edx,%ecx
f01003f3:	66 89 0d 28 85 11 f0 	mov    %cx,0xf0118528
	if (crt_pos >= CRT_SIZE) {
f01003fa:	66 81 3d 28 85 11 f0 	cmpw   $0x7cf,0xf0118528
f0100401:	cf 07 
f0100403:	0f 87 c5 00 00 00    	ja     f01004ce <cons_putc+0x192>
	outb(addr_6845, 14);
f0100409:	8b 0d 30 85 11 f0    	mov    0xf0118530,%ecx
f010040f:	b0 0e                	mov    $0xe,%al
f0100411:	89 ca                	mov    %ecx,%edx
f0100413:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100414:	8d 59 01             	lea    0x1(%ecx),%ebx
f0100417:	66 a1 28 85 11 f0    	mov    0xf0118528,%ax
f010041d:	66 c1 e8 08          	shr    $0x8,%ax
f0100421:	89 da                	mov    %ebx,%edx
f0100423:	ee                   	out    %al,(%dx)
f0100424:	b0 0f                	mov    $0xf,%al
f0100426:	89 ca                	mov    %ecx,%edx
f0100428:	ee                   	out    %al,(%dx)
f0100429:	a0 28 85 11 f0       	mov    0xf0118528,%al
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
f010043e:	66 a1 28 85 11 f0    	mov    0xf0118528,%ax
f0100444:	66 85 c0             	test   %ax,%ax
f0100447:	74 c0                	je     f0100409 <cons_putc+0xcd>
			crt_pos--;
f0100449:	48                   	dec    %eax
f010044a:	66 a3 28 85 11 f0    	mov    %ax,0xf0118528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100450:	0f b7 c0             	movzwl %ax,%eax
f0100453:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f0100459:	83 cf 20             	or     $0x20,%edi
f010045c:	8b 15 2c 85 11 f0    	mov    0xf011852c,%edx
f0100462:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100466:	eb 92                	jmp    f01003fa <cons_putc+0xbe>
		crt_pos += CRT_COLS;
f0100468:	66 83 05 28 85 11 f0 	addw   $0x50,0xf0118528
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
f01004ac:	66 a1 28 85 11 f0    	mov    0xf0118528,%ax
f01004b2:	8d 50 01             	lea    0x1(%eax),%edx
f01004b5:	66 89 15 28 85 11 f0 	mov    %dx,0xf0118528
f01004bc:	0f b7 c0             	movzwl %ax,%eax
f01004bf:	8b 15 2c 85 11 f0    	mov    0xf011852c,%edx
f01004c5:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004c9:	e9 2c ff ff ff       	jmp    f01003fa <cons_putc+0xbe>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004ce:	a1 2c 85 11 f0       	mov    0xf011852c,%eax
f01004d3:	83 ec 04             	sub    $0x4,%esp
f01004d6:	68 00 0f 00 00       	push   $0xf00
f01004db:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004e1:	52                   	push   %edx
f01004e2:	50                   	push   %eax
f01004e3:	e8 fd 30 00 00       	call   f01035e5 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01004e8:	8b 15 2c 85 11 f0    	mov    0xf011852c,%edx
f01004ee:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01004f4:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01004fa:	83 c4 10             	add    $0x10,%esp
f01004fd:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100502:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100505:	39 d0                	cmp    %edx,%eax
f0100507:	75 f4                	jne    f01004fd <cons_putc+0x1c1>
		crt_pos -= CRT_COLS;
f0100509:	66 83 2d 28 85 11 f0 	subw   $0x50,0xf0118528
f0100510:	50 
f0100511:	e9 f3 fe ff ff       	jmp    f0100409 <cons_putc+0xcd>

f0100516 <serial_intr>:
	if (serial_exists)
f0100516:	80 3d 34 85 11 f0 00 	cmpb   $0x0,0xf0118534
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
f0100554:	a1 20 85 11 f0       	mov    0xf0118520,%eax
f0100559:	3b 05 24 85 11 f0    	cmp    0xf0118524,%eax
f010055f:	74 26                	je     f0100587 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100561:	8d 50 01             	lea    0x1(%eax),%edx
f0100564:	89 15 20 85 11 f0    	mov    %edx,0xf0118520
f010056a:	0f b6 80 20 83 11 f0 	movzbl -0xfee7ce0(%eax),%eax
		if (cons.rpos == CONSBUFSIZE)
f0100571:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100577:	74 02                	je     f010057b <cons_getc+0x37>
}
f0100579:	c9                   	leave  
f010057a:	c3                   	ret    
			cons.rpos = 0;
f010057b:	c7 05 20 85 11 f0 00 	movl   $0x0,0xf0118520
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
f01005b7:	c7 05 30 85 11 f0 b4 	movl   $0x3b4,0xf0118530
f01005be:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005c1:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f01005c6:	8b 3d 30 85 11 f0    	mov    0xf0118530,%edi
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
f01005e7:	89 35 2c 85 11 f0    	mov    %esi,0xf011852c
	pos |= inb(addr_6845 + 1);
f01005ed:	0f b6 c0             	movzbl %al,%eax
f01005f0:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01005f2:	66 a3 28 85 11 f0    	mov    %ax,0xf0118528
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
f010063c:	0f 95 05 34 85 11 f0 	setne  0xf0118534
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
f0100660:	c7 05 30 85 11 f0 d4 	movl   $0x3d4,0xf0118530
f0100667:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010066a:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f010066f:	e9 52 ff ff ff       	jmp    f01005c6 <cons_init+0x38>
		cprintf("Serial port does not exist!\n");
f0100674:	83 ec 0c             	sub    $0xc,%esp
f0100677:	68 a4 3b 10 f0       	push   $0xf0103ba4
f010067c:	e8 e8 23 00 00       	call   f0102a69 <cprintf>
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
f01006b7:	68 00 3e 10 f0       	push   $0xf0103e00
f01006bc:	68 1e 3e 10 f0       	push   $0xf0103e1e
f01006c1:	68 23 3e 10 f0       	push   $0xf0103e23
f01006c6:	e8 9e 23 00 00       	call   f0102a69 <cprintf>
f01006cb:	83 c4 0c             	add    $0xc,%esp
f01006ce:	68 d8 3e 10 f0       	push   $0xf0103ed8
f01006d3:	68 2c 3e 10 f0       	push   $0xf0103e2c
f01006d8:	68 23 3e 10 f0       	push   $0xf0103e23
f01006dd:	e8 87 23 00 00       	call   f0102a69 <cprintf>
f01006e2:	83 c4 0c             	add    $0xc,%esp
f01006e5:	68 00 3f 10 f0       	push   $0xf0103f00
f01006ea:	68 35 3e 10 f0       	push   $0xf0103e35
f01006ef:	68 23 3e 10 f0       	push   $0xf0103e23
f01006f4:	e8 70 23 00 00       	call   f0102a69 <cprintf>
	return 0;
}
f01006f9:	b8 00 00 00 00       	mov    $0x0,%eax
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
f0100706:	68 3d 3e 10 f0       	push   $0xf0103e3d
f010070b:	e8 59 23 00 00       	call   f0102a69 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100710:	83 c4 08             	add    $0x8,%esp
f0100713:	68 0c 00 10 00       	push   $0x10000c
f0100718:	68 34 3f 10 f0       	push   $0xf0103f34
f010071d:	e8 47 23 00 00       	call   f0102a69 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100722:	83 c4 0c             	add    $0xc,%esp
f0100725:	68 0c 00 10 00       	push   $0x10000c
f010072a:	68 0c 00 10 f0       	push   $0xf010000c
f010072f:	68 5c 3f 10 f0       	push   $0xf0103f5c
f0100734:	e8 30 23 00 00       	call   f0102a69 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100739:	83 c4 0c             	add    $0xc,%esp
f010073c:	68 4c 3a 10 00       	push   $0x103a4c
f0100741:	68 4c 3a 10 f0       	push   $0xf0103a4c
f0100746:	68 80 3f 10 f0       	push   $0xf0103f80
f010074b:	e8 19 23 00 00       	call   f0102a69 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100750:	83 c4 0c             	add    $0xc,%esp
f0100753:	68 00 83 11 00       	push   $0x118300
f0100758:	68 00 83 11 f0       	push   $0xf0118300
f010075d:	68 a4 3f 10 f0       	push   $0xf0103fa4
f0100762:	e8 02 23 00 00       	call   f0102a69 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100767:	83 c4 0c             	add    $0xc,%esp
f010076a:	68 70 89 11 00       	push   $0x118970
f010076f:	68 70 89 11 f0       	push   $0xf0118970
f0100774:	68 c8 3f 10 f0       	push   $0xf0103fc8
f0100779:	e8 eb 22 00 00       	call   f0102a69 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010077e:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100781:	b8 6f 8d 11 f0       	mov    $0xf0118d6f,%eax
f0100786:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f010078b:	c1 f8 0a             	sar    $0xa,%eax
f010078e:	50                   	push   %eax
f010078f:	68 ec 3f 10 f0       	push   $0xf0103fec
f0100794:	e8 d0 22 00 00       	call   f0102a69 <cprintf>
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
		cprintf("Expecting a virtual addr range [l, r]\n");
		return 0;
	}
	uintptr_t l = strtoul(argv[1], NULL, 0), 
f01007ae:	83 ec 04             	sub    $0x4,%esp
f01007b1:	6a 00                	push   $0x0
f01007b3:	6a 00                	push   $0x0
f01007b5:	ff 76 04             	pushl  0x4(%esi)
f01007b8:	e8 bc 2f 00 00       	call   f0103779 <strtoul>
f01007bd:	89 c3                	mov    %eax,%ebx
		 	  r = strtoul(argv[2], NULL, 0); // In string.h
f01007bf:	83 c4 0c             	add    $0xc,%esp
f01007c2:	6a 00                	push   $0x0
f01007c4:	6a 00                	push   $0x0
f01007c6:	ff 76 08             	pushl  0x8(%esi)
f01007c9:	e8 ab 2f 00 00       	call   f0103779 <strtoul>
	if (l < 0 || r < 0 || l > r) {
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
		cprintf("Expecting a virtual addr range [l, r]\n");
f01007ea:	83 ec 0c             	sub    $0xc,%esp
f01007ed:	68 18 40 10 f0       	push   $0xf0104018
f01007f2:	e8 72 22 00 00       	call   f0102a69 <cprintf>
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
f0100809:	68 56 3e 10 f0       	push   $0xf0103e56
f010080e:	e8 56 22 00 00       	call   f0102a69 <cprintf>
		return 0;
f0100813:	83 c4 10             	add    $0x10,%esp
f0100816:	eb e2                	jmp    f01007fa <mon_showmap+0x5a>
			cprintf("0x%08x -> ----------; perm = ---\n", sz);
f0100818:	83 ec 08             	sub    $0x8,%esp
f010081b:	53                   	push   %ebx
f010081c:	68 40 40 10 f0       	push   $0xf0104040
f0100821:	e8 43 22 00 00       	call   f0102a69 <cprintf>
f0100826:	83 c4 10             	add    $0x10,%esp
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f0100829:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010082f:	39 f3                	cmp    %esi,%ebx
f0100831:	77 c7                	ja     f01007fa <mon_showmap+0x5a>
		pte_t* pte = pgdir_walk(kern_pgdir, (void*) sz, 0);
f0100833:	83 ec 04             	sub    $0x4,%esp
f0100836:	6a 00                	push   $0x0
f0100838:	53                   	push   %ebx
f0100839:	ff 35 68 89 11 f0    	pushl  0xf0118968
f010083f:	e8 38 07 00 00       	call   f0100f7c <pgdir_walk>
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
f0100861:	68 64 40 10 f0       	push   $0xf0104064
f0100866:	e8 fe 21 00 00       	call   f0102a69 <cprintf>
f010086b:	83 c4 10             	add    $0x10,%esp
f010086e:	eb b9                	jmp    f0100829 <mon_showmap+0x89>

f0100870 <mon_backtrace>:
{
f0100870:	55                   	push   %ebp
f0100871:	89 e5                	mov    %esp,%ebp
f0100873:	57                   	push   %edi
f0100874:	56                   	push   %esi
f0100875:	53                   	push   %ebx
f0100876:	83 ec 38             	sub    $0x38,%esp
	cprintf("Stack backtrace:\n");
f0100879:	68 70 3e 10 f0       	push   $0xf0103e70
f010087e:	e8 e6 21 00 00       	call   f0102a69 <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100883:	89 e8                	mov    %ebp,%eax
	while (ebp != 0) {
f0100885:	83 c4 10             	add    $0x10,%esp
f0100888:	eb 34                	jmp    f01008be <mon_backtrace+0x4e>
			cprintf("%c", info.eip_fn_name[i]);
f010088a:	83 ec 08             	sub    $0x8,%esp
f010088d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100890:	0f be 04 18          	movsbl (%eax,%ebx,1),%eax
f0100894:	50                   	push   %eax
f0100895:	68 93 3e 10 f0       	push   $0xf0103e93
f010089a:	e8 ca 21 00 00       	call   f0102a69 <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f010089f:	43                   	inc    %ebx
f01008a0:	83 c4 10             	add    $0x10,%esp
f01008a3:	39 5d dc             	cmp    %ebx,-0x24(%ebp)
f01008a6:	7f e2                	jg     f010088a <mon_backtrace+0x1a>
		cprintf("+%d\n", eip - info.eip_fn_addr);
f01008a8:	83 ec 08             	sub    $0x8,%esp
f01008ab:	2b 75 e0             	sub    -0x20(%ebp),%esi
f01008ae:	56                   	push   %esi
f01008af:	68 96 3e 10 f0       	push   $0xf0103e96
f01008b4:	e8 b0 21 00 00       	call   f0102a69 <cprintf>
		ebp = prev_ebp;
f01008b9:	83 c4 10             	add    $0x10,%esp
f01008bc:	89 f8                	mov    %edi,%eax
	while (ebp != 0) {
f01008be:	85 c0                	test   %eax,%eax
f01008c0:	74 4a                	je     f010090c <mon_backtrace+0x9c>
		prev_ebp = *(int*)ebp;
f01008c2:	8b 38                	mov    (%eax),%edi
		eip = *((int*)ebp + 1);
f01008c4:	8b 70 04             	mov    0x4(%eax),%esi
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, 
f01008c7:	ff 70 18             	pushl  0x18(%eax)
f01008ca:	ff 70 14             	pushl  0x14(%eax)
f01008cd:	ff 70 10             	pushl  0x10(%eax)
f01008d0:	ff 70 0c             	pushl  0xc(%eax)
f01008d3:	ff 70 08             	pushl  0x8(%eax)
f01008d6:	56                   	push   %esi
f01008d7:	50                   	push   %eax
f01008d8:	68 88 40 10 f0       	push   $0xf0104088
f01008dd:	e8 87 21 00 00       	call   f0102a69 <cprintf>
		int code = debuginfo_eip((uintptr_t)eip, &info);
f01008e2:	83 c4 18             	add    $0x18,%esp
f01008e5:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008e8:	50                   	push   %eax
f01008e9:	56                   	push   %esi
f01008ea:	e8 7b 22 00 00       	call   f0102b6a <debuginfo_eip>
		cprintf("         %s:%d: ", info.eip_file, info.eip_line);
f01008ef:	83 c4 0c             	add    $0xc,%esp
f01008f2:	ff 75 d4             	pushl  -0x2c(%ebp)
f01008f5:	ff 75 d0             	pushl  -0x30(%ebp)
f01008f8:	68 82 3e 10 f0       	push   $0xf0103e82
f01008fd:	e8 67 21 00 00       	call   f0102a69 <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f0100902:	83 c4 10             	add    $0x10,%esp
f0100905:	bb 00 00 00 00       	mov    $0x0,%ebx
f010090a:	eb 97                	jmp    f01008a3 <mon_backtrace+0x33>
}
f010090c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010090f:	5b                   	pop    %ebx
f0100910:	5e                   	pop    %esi
f0100911:	5f                   	pop    %edi
f0100912:	5d                   	pop    %ebp
f0100913:	c3                   	ret    

f0100914 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100914:	55                   	push   %ebp
f0100915:	89 e5                	mov    %esp,%ebp
f0100917:	57                   	push   %edi
f0100918:	56                   	push   %esi
f0100919:	53                   	push   %ebx
f010091a:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010091d:	68 c0 40 10 f0       	push   $0xf01040c0
f0100922:	e8 42 21 00 00       	call   f0102a69 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100927:	c7 04 24 e4 40 10 f0 	movl   $0xf01040e4,(%esp)
f010092e:	e8 36 21 00 00       	call   f0102a69 <cprintf>
f0100933:	83 c4 10             	add    $0x10,%esp
f0100936:	eb 47                	jmp    f010097f <monitor+0x6b>
		while (*buf && strchr(WHITESPACE, *buf))
f0100938:	83 ec 08             	sub    $0x8,%esp
f010093b:	0f be c0             	movsbl %al,%eax
f010093e:	50                   	push   %eax
f010093f:	68 9f 3e 10 f0       	push   $0xf0103e9f
f0100944:	e8 1a 2c 00 00       	call   f0103563 <strchr>
f0100949:	83 c4 10             	add    $0x10,%esp
f010094c:	85 c0                	test   %eax,%eax
f010094e:	74 0a                	je     f010095a <monitor+0x46>
			*buf++ = 0;
f0100950:	c6 03 00             	movb   $0x0,(%ebx)
f0100953:	89 fe                	mov    %edi,%esi
f0100955:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100958:	eb 68                	jmp    f01009c2 <monitor+0xae>
		if (*buf == 0)
f010095a:	80 3b 00             	cmpb   $0x0,(%ebx)
f010095d:	74 6f                	je     f01009ce <monitor+0xba>
		if (argc == MAXARGS-1) {
f010095f:	83 ff 0f             	cmp    $0xf,%edi
f0100962:	74 09                	je     f010096d <monitor+0x59>
		argv[argc++] = buf;
f0100964:	8d 77 01             	lea    0x1(%edi),%esi
f0100967:	89 5c bd a8          	mov    %ebx,-0x58(%ebp,%edi,4)
f010096b:	eb 37                	jmp    f01009a4 <monitor+0x90>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010096d:	83 ec 08             	sub    $0x8,%esp
f0100970:	6a 10                	push   $0x10
f0100972:	68 a4 3e 10 f0       	push   $0xf0103ea4
f0100977:	e8 ed 20 00 00       	call   f0102a69 <cprintf>
f010097c:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f010097f:	83 ec 0c             	sub    $0xc,%esp
f0100982:	68 9b 3e 10 f0       	push   $0xf0103e9b
f0100987:	e8 cc 29 00 00       	call   f0103358 <readline>
f010098c:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010098e:	83 c4 10             	add    $0x10,%esp
f0100991:	85 c0                	test   %eax,%eax
f0100993:	74 ea                	je     f010097f <monitor+0x6b>
	argv[argc] = 0;
f0100995:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f010099c:	bf 00 00 00 00       	mov    $0x0,%edi
f01009a1:	eb 21                	jmp    f01009c4 <monitor+0xb0>
			buf++;
f01009a3:	43                   	inc    %ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f01009a4:	8a 03                	mov    (%ebx),%al
f01009a6:	84 c0                	test   %al,%al
f01009a8:	74 18                	je     f01009c2 <monitor+0xae>
f01009aa:	83 ec 08             	sub    $0x8,%esp
f01009ad:	0f be c0             	movsbl %al,%eax
f01009b0:	50                   	push   %eax
f01009b1:	68 9f 3e 10 f0       	push   $0xf0103e9f
f01009b6:	e8 a8 2b 00 00       	call   f0103563 <strchr>
f01009bb:	83 c4 10             	add    $0x10,%esp
f01009be:	85 c0                	test   %eax,%eax
f01009c0:	74 e1                	je     f01009a3 <monitor+0x8f>
			*buf++ = 0;
f01009c2:	89 f7                	mov    %esi,%edi
		while (*buf && strchr(WHITESPACE, *buf))
f01009c4:	8a 03                	mov    (%ebx),%al
f01009c6:	84 c0                	test   %al,%al
f01009c8:	0f 85 6a ff ff ff    	jne    f0100938 <monitor+0x24>
	argv[argc] = 0;
f01009ce:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
f01009d5:	00 
	if (argc == 0)
f01009d6:	85 ff                	test   %edi,%edi
f01009d8:	74 a5                	je     f010097f <monitor+0x6b>
f01009da:	be 20 41 10 f0       	mov    $0xf0104120,%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009df:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f01009e4:	83 ec 08             	sub    $0x8,%esp
f01009e7:	ff 36                	pushl  (%esi)
f01009e9:	ff 75 a8             	pushl  -0x58(%ebp)
f01009ec:	e8 1e 2b 00 00       	call   f010350f <strcmp>
f01009f1:	83 c4 10             	add    $0x10,%esp
f01009f4:	85 c0                	test   %eax,%eax
f01009f6:	74 21                	je     f0100a19 <monitor+0x105>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009f8:	43                   	inc    %ebx
f01009f9:	83 c6 0c             	add    $0xc,%esi
f01009fc:	83 fb 03             	cmp    $0x3,%ebx
f01009ff:	75 e3                	jne    f01009e4 <monitor+0xd0>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a01:	83 ec 08             	sub    $0x8,%esp
f0100a04:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a07:	68 c1 3e 10 f0       	push   $0xf0103ec1
f0100a0c:	e8 58 20 00 00       	call   f0102a69 <cprintf>
f0100a11:	83 c4 10             	add    $0x10,%esp
f0100a14:	e9 66 ff ff ff       	jmp    f010097f <monitor+0x6b>
			return commands[i].func(argc, argv, tf);
f0100a19:	83 ec 04             	sub    $0x4,%esp
f0100a1c:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100a1f:	01 c3                	add    %eax,%ebx
f0100a21:	ff 75 08             	pushl  0x8(%ebp)
f0100a24:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100a27:	50                   	push   %eax
f0100a28:	57                   	push   %edi
f0100a29:	ff 14 9d 28 41 10 f0 	call   *-0xfefbed8(,%ebx,4)
			if (runcmd(buf, tf) < 0)
f0100a30:	83 c4 10             	add    $0x10,%esp
f0100a33:	85 c0                	test   %eax,%eax
f0100a35:	0f 89 44 ff ff ff    	jns    f010097f <monitor+0x6b>
				break;
	}
}
f0100a3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a3e:	5b                   	pop    %ebx
f0100a3f:	5e                   	pop    %esi
f0100a40:	5f                   	pop    %edi
f0100a41:	5d                   	pop    %ebp
f0100a42:	c3                   	ret    

f0100a43 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a43:	55                   	push   %ebp
f0100a44:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a46:	83 3d 38 85 11 f0 00 	cmpl   $0x0,0xf0118538
f0100a4d:	74 1f                	je     f0100a6e <boot_alloc+0x2b>
	}

	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	if (!n)
f0100a4f:	85 c0                	test   %eax,%eax
f0100a51:	74 2e                	je     f0100a81 <boot_alloc+0x3e>
		return (void*)nextfree;
	else {
		result = nextfree;
f0100a53:	8b 15 38 85 11 f0    	mov    0xf0118538,%edx
		nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100a59:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100a60:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a65:	a3 38 85 11 f0       	mov    %eax,0xf0118538
		return (void*)result;
	}
}
f0100a6a:	89 d0                	mov    %edx,%eax
f0100a6c:	5d                   	pop    %ebp
f0100a6d:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a6e:	ba 6f 99 11 f0       	mov    $0xf011996f,%edx
f0100a73:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a79:	89 15 38 85 11 f0    	mov    %edx,0xf0118538
f0100a7f:	eb ce                	jmp    f0100a4f <boot_alloc+0xc>
		return (void*)nextfree;
f0100a81:	8b 15 38 85 11 f0    	mov    0xf0118538,%edx
f0100a87:	eb e1                	jmp    f0100a6a <boot_alloc+0x27>

f0100a89 <nvram_read>:
{
f0100a89:	55                   	push   %ebp
f0100a8a:	89 e5                	mov    %esp,%ebp
f0100a8c:	56                   	push   %esi
f0100a8d:	53                   	push   %ebx
f0100a8e:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a90:	83 ec 0c             	sub    $0xc,%esp
f0100a93:	50                   	push   %eax
f0100a94:	e8 69 1f 00 00       	call   f0102a02 <mc146818_read>
f0100a99:	89 c3                	mov    %eax,%ebx
f0100a9b:	46                   	inc    %esi
f0100a9c:	89 34 24             	mov    %esi,(%esp)
f0100a9f:	e8 5e 1f 00 00       	call   f0102a02 <mc146818_read>
f0100aa4:	c1 e0 08             	shl    $0x8,%eax
f0100aa7:	09 d8                	or     %ebx,%eax
}
f0100aa9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100aac:	5b                   	pop    %ebx
f0100aad:	5e                   	pop    %esi
f0100aae:	5d                   	pop    %ebp
f0100aaf:	c3                   	ret    

f0100ab0 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100ab0:	89 d1                	mov    %edx,%ecx
f0100ab2:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100ab5:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ab8:	a8 01                	test   $0x1,%al
f0100aba:	74 47                	je     f0100b03 <check_va2pa+0x53>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100abc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ac1:	89 c1                	mov    %eax,%ecx
f0100ac3:	c1 e9 0c             	shr    $0xc,%ecx
f0100ac6:	3b 0d 64 89 11 f0    	cmp    0xf0118964,%ecx
f0100acc:	73 1a                	jae    f0100ae8 <check_va2pa+0x38>
	if (!(p[PTX(va)] & PTE_P))
f0100ace:	c1 ea 0c             	shr    $0xc,%edx
f0100ad1:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100ad7:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100ade:	a8 01                	test   $0x1,%al
f0100ae0:	74 27                	je     f0100b09 <check_va2pa+0x59>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100ae2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ae7:	c3                   	ret    
{
f0100ae8:	55                   	push   %ebp
f0100ae9:	89 e5                	mov    %esp,%ebp
f0100aeb:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100aee:	50                   	push   %eax
f0100aef:	68 44 41 10 f0       	push   $0xf0104144
f0100af4:	68 c2 02 00 00       	push   $0x2c2
f0100af9:	68 bc 48 10 f0       	push   $0xf01048bc
f0100afe:	e8 30 f6 ff ff       	call   f0100133 <_panic>
		return ~0;
f0100b03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100b08:	c3                   	ret    
		return ~0;
f0100b09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100b0e:	c3                   	ret    

f0100b0f <check_page_free_list>:
{
f0100b0f:	55                   	push   %ebp
f0100b10:	89 e5                	mov    %esp,%ebp
f0100b12:	57                   	push   %edi
f0100b13:	56                   	push   %esi
f0100b14:	53                   	push   %ebx
f0100b15:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b18:	84 c0                	test   %al,%al
f0100b1a:	0f 85 50 02 00 00    	jne    f0100d70 <check_page_free_list+0x261>
	if (!page_free_list)
f0100b20:	83 3d 3c 85 11 f0 00 	cmpl   $0x0,0xf011853c
f0100b27:	74 0a                	je     f0100b33 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b29:	be 00 04 00 00       	mov    $0x400,%esi
f0100b2e:	e9 98 02 00 00       	jmp    f0100dcb <check_page_free_list+0x2bc>
		panic("'page_free_list' is a null pointer!");
f0100b33:	83 ec 04             	sub    $0x4,%esp
f0100b36:	68 68 41 10 f0       	push   $0xf0104168
f0100b3b:	68 02 02 00 00       	push   $0x202
f0100b40:	68 bc 48 10 f0       	push   $0xf01048bc
f0100b45:	e8 e9 f5 ff ff       	call   f0100133 <_panic>
f0100b4a:	50                   	push   %eax
f0100b4b:	68 44 41 10 f0       	push   $0xf0104144
f0100b50:	6a 52                	push   $0x52
f0100b52:	68 c8 48 10 f0       	push   $0xf01048c8
f0100b57:	e8 d7 f5 ff ff       	call   f0100133 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b5c:	8b 1b                	mov    (%ebx),%ebx
f0100b5e:	85 db                	test   %ebx,%ebx
f0100b60:	74 41                	je     f0100ba3 <check_page_free_list+0x94>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b62:	89 d8                	mov    %ebx,%eax
f0100b64:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0100b6a:	c1 f8 03             	sar    $0x3,%eax
f0100b6d:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100b70:	89 c2                	mov    %eax,%edx
f0100b72:	c1 ea 16             	shr    $0x16,%edx
f0100b75:	39 f2                	cmp    %esi,%edx
f0100b77:	73 e3                	jae    f0100b5c <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100b79:	89 c2                	mov    %eax,%edx
f0100b7b:	c1 ea 0c             	shr    $0xc,%edx
f0100b7e:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f0100b84:	73 c4                	jae    f0100b4a <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100b86:	83 ec 04             	sub    $0x4,%esp
f0100b89:	68 80 00 00 00       	push   $0x80
f0100b8e:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100b93:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b98:	50                   	push   %eax
f0100b99:	e8 fa 29 00 00       	call   f0103598 <memset>
f0100b9e:	83 c4 10             	add    $0x10,%esp
f0100ba1:	eb b9                	jmp    f0100b5c <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100ba3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ba8:	e8 96 fe ff ff       	call   f0100a43 <boot_alloc>
f0100bad:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bb0:	8b 15 3c 85 11 f0    	mov    0xf011853c,%edx
		assert(pp >= pages);
f0100bb6:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
		assert(pp < pages + npages);
f0100bbc:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0100bc1:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100bc4:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bc7:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0100bca:	be 00 00 00 00       	mov    $0x0,%esi
f0100bcf:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bd2:	e9 c8 00 00 00       	jmp    f0100c9f <check_page_free_list+0x190>
		assert(pp >= pages);
f0100bd7:	68 d6 48 10 f0       	push   $0xf01048d6
f0100bdc:	68 e2 48 10 f0       	push   $0xf01048e2
f0100be1:	68 1c 02 00 00       	push   $0x21c
f0100be6:	68 bc 48 10 f0       	push   $0xf01048bc
f0100beb:	e8 43 f5 ff ff       	call   f0100133 <_panic>
		assert(pp < pages + npages);
f0100bf0:	68 f7 48 10 f0       	push   $0xf01048f7
f0100bf5:	68 e2 48 10 f0       	push   $0xf01048e2
f0100bfa:	68 1d 02 00 00       	push   $0x21d
f0100bff:	68 bc 48 10 f0       	push   $0xf01048bc
f0100c04:	e8 2a f5 ff ff       	call   f0100133 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c09:	68 8c 41 10 f0       	push   $0xf010418c
f0100c0e:	68 e2 48 10 f0       	push   $0xf01048e2
f0100c13:	68 1e 02 00 00       	push   $0x21e
f0100c18:	68 bc 48 10 f0       	push   $0xf01048bc
f0100c1d:	e8 11 f5 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) != 0);
f0100c22:	68 0b 49 10 f0       	push   $0xf010490b
f0100c27:	68 e2 48 10 f0       	push   $0xf01048e2
f0100c2c:	68 21 02 00 00       	push   $0x221
f0100c31:	68 bc 48 10 f0       	push   $0xf01048bc
f0100c36:	e8 f8 f4 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c3b:	68 1c 49 10 f0       	push   $0xf010491c
f0100c40:	68 e2 48 10 f0       	push   $0xf01048e2
f0100c45:	68 22 02 00 00       	push   $0x222
f0100c4a:	68 bc 48 10 f0       	push   $0xf01048bc
f0100c4f:	e8 df f4 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c54:	68 c0 41 10 f0       	push   $0xf01041c0
f0100c59:	68 e2 48 10 f0       	push   $0xf01048e2
f0100c5e:	68 23 02 00 00       	push   $0x223
f0100c63:	68 bc 48 10 f0       	push   $0xf01048bc
f0100c68:	e8 c6 f4 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c6d:	68 35 49 10 f0       	push   $0xf0104935
f0100c72:	68 e2 48 10 f0       	push   $0xf01048e2
f0100c77:	68 24 02 00 00       	push   $0x224
f0100c7c:	68 bc 48 10 f0       	push   $0xf01048bc
f0100c81:	e8 ad f4 ff ff       	call   f0100133 <_panic>
	if (PGNUM(pa) >= npages)
f0100c86:	89 c3                	mov    %eax,%ebx
f0100c88:	c1 eb 0c             	shr    $0xc,%ebx
f0100c8b:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f0100c8e:	76 63                	jbe    f0100cf3 <check_page_free_list+0x1e4>
	return (void *)(pa + KERNBASE);
f0100c90:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c95:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100c98:	77 6b                	ja     f0100d05 <check_page_free_list+0x1f6>
			++nfree_extmem;
f0100c9a:	ff 45 d0             	incl   -0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c9d:	8b 12                	mov    (%edx),%edx
f0100c9f:	85 d2                	test   %edx,%edx
f0100ca1:	74 7b                	je     f0100d1e <check_page_free_list+0x20f>
		assert(pp >= pages);
f0100ca3:	39 d1                	cmp    %edx,%ecx
f0100ca5:	0f 87 2c ff ff ff    	ja     f0100bd7 <check_page_free_list+0xc8>
		assert(pp < pages + npages);
f0100cab:	39 d7                	cmp    %edx,%edi
f0100cad:	0f 86 3d ff ff ff    	jbe    f0100bf0 <check_page_free_list+0xe1>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cb3:	89 d0                	mov    %edx,%eax
f0100cb5:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100cb8:	a8 07                	test   $0x7,%al
f0100cba:	0f 85 49 ff ff ff    	jne    f0100c09 <check_page_free_list+0xfa>
	return (pp - pages) << PGSHIFT;
f0100cc0:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100cc3:	c1 e0 0c             	shl    $0xc,%eax
f0100cc6:	0f 84 56 ff ff ff    	je     f0100c22 <check_page_free_list+0x113>
		assert(page2pa(pp) != IOPHYSMEM);
f0100ccc:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100cd1:	0f 84 64 ff ff ff    	je     f0100c3b <check_page_free_list+0x12c>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100cd7:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100cdc:	0f 84 72 ff ff ff    	je     f0100c54 <check_page_free_list+0x145>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100ce2:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100ce7:	74 84                	je     f0100c6d <check_page_free_list+0x15e>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100ce9:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100cee:	77 96                	ja     f0100c86 <check_page_free_list+0x177>
			++nfree_basemem;
f0100cf0:	46                   	inc    %esi
f0100cf1:	eb aa                	jmp    f0100c9d <check_page_free_list+0x18e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cf3:	50                   	push   %eax
f0100cf4:	68 44 41 10 f0       	push   $0xf0104144
f0100cf9:	6a 52                	push   $0x52
f0100cfb:	68 c8 48 10 f0       	push   $0xf01048c8
f0100d00:	e8 2e f4 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d05:	68 e4 41 10 f0       	push   $0xf01041e4
f0100d0a:	68 e2 48 10 f0       	push   $0xf01048e2
f0100d0f:	68 25 02 00 00       	push   $0x225
f0100d14:	68 bc 48 10 f0       	push   $0xf01048bc
f0100d19:	e8 15 f4 ff ff       	call   f0100133 <_panic>
f0100d1e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
	assert(nfree_basemem > 0);
f0100d21:	85 f6                	test   %esi,%esi
f0100d23:	7e 19                	jle    f0100d3e <check_page_free_list+0x22f>
	assert(nfree_extmem > 0);
f0100d25:	85 db                	test   %ebx,%ebx
f0100d27:	7e 2e                	jle    f0100d57 <check_page_free_list+0x248>
	cprintf("check_page_free_list() succeeded!\n");
f0100d29:	83 ec 0c             	sub    $0xc,%esp
f0100d2c:	68 2c 42 10 f0       	push   $0xf010422c
f0100d31:	e8 33 1d 00 00       	call   f0102a69 <cprintf>
}
f0100d36:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d39:	5b                   	pop    %ebx
f0100d3a:	5e                   	pop    %esi
f0100d3b:	5f                   	pop    %edi
f0100d3c:	5d                   	pop    %ebp
f0100d3d:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100d3e:	68 4f 49 10 f0       	push   $0xf010494f
f0100d43:	68 e2 48 10 f0       	push   $0xf01048e2
f0100d48:	68 2d 02 00 00       	push   $0x22d
f0100d4d:	68 bc 48 10 f0       	push   $0xf01048bc
f0100d52:	e8 dc f3 ff ff       	call   f0100133 <_panic>
	assert(nfree_extmem > 0);
f0100d57:	68 61 49 10 f0       	push   $0xf0104961
f0100d5c:	68 e2 48 10 f0       	push   $0xf01048e2
f0100d61:	68 2e 02 00 00       	push   $0x22e
f0100d66:	68 bc 48 10 f0       	push   $0xf01048bc
f0100d6b:	e8 c3 f3 ff ff       	call   f0100133 <_panic>
	if (!page_free_list)
f0100d70:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0100d75:	85 c0                	test   %eax,%eax
f0100d77:	0f 84 b6 fd ff ff    	je     f0100b33 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100d7d:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100d80:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100d83:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100d86:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100d89:	89 c2                	mov    %eax,%edx
f0100d8b:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit; 
f0100d91:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100d97:	0f 95 c2             	setne  %dl
f0100d9a:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100d9d:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100da1:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100da3:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100da7:	8b 00                	mov    (%eax),%eax
f0100da9:	85 c0                	test   %eax,%eax
f0100dab:	75 dc                	jne    f0100d89 <check_page_free_list+0x27a>
		*tp[1] = 0;
f0100dad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100db0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100db6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100db9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100dbc:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100dbe:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100dc1:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100dc6:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100dcb:	8b 1d 3c 85 11 f0    	mov    0xf011853c,%ebx
f0100dd1:	e9 88 fd ff ff       	jmp    f0100b5e <check_page_free_list+0x4f>

f0100dd6 <page_init>:
{
f0100dd6:	55                   	push   %ebp
f0100dd7:	89 e5                	mov    %esp,%ebp
f0100dd9:	57                   	push   %edi
f0100dda:	56                   	push   %esi
f0100ddb:	53                   	push   %ebx
	for (i = 1; i < npages_basemem; i++) {
f0100ddc:	8b 35 40 85 11 f0    	mov    0xf0118540,%esi
f0100de2:	8b 1d 3c 85 11 f0    	mov    0xf011853c,%ebx
f0100de8:	b2 00                	mov    $0x0,%dl
f0100dea:	b8 01 00 00 00       	mov    $0x1,%eax
f0100def:	bf 01 00 00 00       	mov    $0x1,%edi
f0100df4:	eb 22                	jmp    f0100e18 <page_init+0x42>
		pages[i].pp_ref = 0;
f0100df6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100dfd:	89 d1                	mov    %edx,%ecx
f0100dff:	03 0d 6c 89 11 f0    	add    0xf011896c,%ecx
f0100e05:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100e0b:	89 19                	mov    %ebx,(%ecx)
	for (i = 1; i < npages_basemem; i++) {
f0100e0d:	40                   	inc    %eax
		page_free_list = &pages[i];
f0100e0e:	89 d3                	mov    %edx,%ebx
f0100e10:	03 1d 6c 89 11 f0    	add    0xf011896c,%ebx
f0100e16:	89 fa                	mov    %edi,%edx
	for (i = 1; i < npages_basemem; i++) {
f0100e18:	39 c6                	cmp    %eax,%esi
f0100e1a:	77 da                	ja     f0100df6 <page_init+0x20>
f0100e1c:	84 d2                	test   %dl,%dl
f0100e1e:	75 33                	jne    f0100e53 <page_init+0x7d>
	size_t table_size = PTX(sizeof(struct PageInfo)*npages);
f0100e20:	8b 15 64 89 11 f0    	mov    0xf0118964,%edx
f0100e26:	c1 e2 0d             	shl    $0xd,%edx
f0100e29:	c1 ea 16             	shr    $0x16,%edx
	size_t end_idx = PTX(ROUNDUP((char *) end, PGSIZE));
f0100e2c:	b8 6f 99 11 f0       	mov    $0xf011996f,%eax
f0100e31:	c1 e8 0c             	shr    $0xc,%eax
f0100e34:	25 ff 03 00 00       	and    $0x3ff,%eax
	for (i = table_size + end_idx + 1; i < npages; i++) {
f0100e39:	8d 54 02 01          	lea    0x1(%edx,%eax,1),%edx
f0100e3d:	8b 1d 3c 85 11 f0    	mov    0xf011853c,%ebx
f0100e43:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0100e4a:	b1 00                	mov    $0x0,%cl
f0100e4c:	be 01 00 00 00       	mov    $0x1,%esi
f0100e51:	eb 26                	jmp    f0100e79 <page_init+0xa3>
f0100e53:	89 1d 3c 85 11 f0    	mov    %ebx,0xf011853c
f0100e59:	eb c5                	jmp    f0100e20 <page_init+0x4a>
		pages[i].pp_ref = 0;
f0100e5b:	89 c1                	mov    %eax,%ecx
f0100e5d:	03 0d 6c 89 11 f0    	add    0xf011896c,%ecx
f0100e63:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100e69:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0100e6b:	89 c3                	mov    %eax,%ebx
f0100e6d:	03 1d 6c 89 11 f0    	add    0xf011896c,%ebx
	for (i = table_size + end_idx + 1; i < npages; i++) {
f0100e73:	42                   	inc    %edx
f0100e74:	83 c0 08             	add    $0x8,%eax
f0100e77:	89 f1                	mov    %esi,%ecx
f0100e79:	39 15 64 89 11 f0    	cmp    %edx,0xf0118964
f0100e7f:	77 da                	ja     f0100e5b <page_init+0x85>
f0100e81:	84 c9                	test   %cl,%cl
f0100e83:	75 05                	jne    f0100e8a <page_init+0xb4>
}
f0100e85:	5b                   	pop    %ebx
f0100e86:	5e                   	pop    %esi
f0100e87:	5f                   	pop    %edi
f0100e88:	5d                   	pop    %ebp
f0100e89:	c3                   	ret    
f0100e8a:	89 1d 3c 85 11 f0    	mov    %ebx,0xf011853c
f0100e90:	eb f3                	jmp    f0100e85 <page_init+0xaf>

f0100e92 <page_alloc>:
{
f0100e92:	55                   	push   %ebp
f0100e93:	89 e5                	mov    %esp,%ebp
f0100e95:	53                   	push   %ebx
f0100e96:	83 ec 04             	sub    $0x4,%esp
	struct PageInfo* next = page_free_list;
f0100e99:	8b 1d 3c 85 11 f0    	mov    0xf011853c,%ebx
	if (!next)
f0100e9f:	85 db                	test   %ebx,%ebx
f0100ea1:	74 13                	je     f0100eb6 <page_alloc+0x24>
	page_free_list = page_free_list->pp_link;
f0100ea3:	8b 03                	mov    (%ebx),%eax
f0100ea5:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
	next->pp_link = NULL;
f0100eaa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f0100eb0:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100eb4:	75 07                	jne    f0100ebd <page_alloc+0x2b>
}
f0100eb6:	89 d8                	mov    %ebx,%eax
f0100eb8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ebb:	c9                   	leave  
f0100ebc:	c3                   	ret    
f0100ebd:	89 d8                	mov    %ebx,%eax
f0100ebf:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0100ec5:	c1 f8 03             	sar    $0x3,%eax
f0100ec8:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100ecb:	89 c2                	mov    %eax,%edx
f0100ecd:	c1 ea 0c             	shr    $0xc,%edx
f0100ed0:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f0100ed6:	73 1a                	jae    f0100ef2 <page_alloc+0x60>
		memset(content, 0, PGSIZE);
f0100ed8:	83 ec 04             	sub    $0x4,%esp
f0100edb:	68 00 10 00 00       	push   $0x1000
f0100ee0:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100ee2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ee7:	50                   	push   %eax
f0100ee8:	e8 ab 26 00 00       	call   f0103598 <memset>
f0100eed:	83 c4 10             	add    $0x10,%esp
f0100ef0:	eb c4                	jmp    f0100eb6 <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ef2:	50                   	push   %eax
f0100ef3:	68 44 41 10 f0       	push   $0xf0104144
f0100ef8:	6a 52                	push   $0x52
f0100efa:	68 c8 48 10 f0       	push   $0xf01048c8
f0100eff:	e8 2f f2 ff ff       	call   f0100133 <_panic>

f0100f04 <page_free>:
{
f0100f04:	55                   	push   %ebp
f0100f05:	89 e5                	mov    %esp,%ebp
f0100f07:	83 ec 08             	sub    $0x8,%esp
f0100f0a:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref)
f0100f0d:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f12:	75 14                	jne    f0100f28 <page_free+0x24>
	if (pp->pp_link)
f0100f14:	83 38 00             	cmpl   $0x0,(%eax)
f0100f17:	75 26                	jne    f0100f3f <page_free+0x3b>
	pp->pp_link = page_free_list;
f0100f19:	8b 15 3c 85 11 f0    	mov    0xf011853c,%edx
f0100f1f:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100f21:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
}
f0100f26:	c9                   	leave  
f0100f27:	c3                   	ret    
		panic("Ref count is non-zero");
f0100f28:	83 ec 04             	sub    $0x4,%esp
f0100f2b:	68 72 49 10 f0       	push   $0xf0104972
f0100f30:	68 3a 01 00 00       	push   $0x13a
f0100f35:	68 bc 48 10 f0       	push   $0xf01048bc
f0100f3a:	e8 f4 f1 ff ff       	call   f0100133 <_panic>
		panic("Page is double-freed");
f0100f3f:	83 ec 04             	sub    $0x4,%esp
f0100f42:	68 88 49 10 f0       	push   $0xf0104988
f0100f47:	68 3c 01 00 00       	push   $0x13c
f0100f4c:	68 bc 48 10 f0       	push   $0xf01048bc
f0100f51:	e8 dd f1 ff ff       	call   f0100133 <_panic>

f0100f56 <page_decref>:
{
f0100f56:	55                   	push   %ebp
f0100f57:	89 e5                	mov    %esp,%ebp
f0100f59:	83 ec 08             	sub    $0x8,%esp
f0100f5c:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100f5f:	8b 42 04             	mov    0x4(%edx),%eax
f0100f62:	48                   	dec    %eax
f0100f63:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100f67:	66 85 c0             	test   %ax,%ax
f0100f6a:	74 02                	je     f0100f6e <page_decref+0x18>
}
f0100f6c:	c9                   	leave  
f0100f6d:	c3                   	ret    
		page_free(pp);
f0100f6e:	83 ec 0c             	sub    $0xc,%esp
f0100f71:	52                   	push   %edx
f0100f72:	e8 8d ff ff ff       	call   f0100f04 <page_free>
f0100f77:	83 c4 10             	add    $0x10,%esp
}
f0100f7a:	eb f0                	jmp    f0100f6c <page_decref+0x16>

f0100f7c <pgdir_walk>:
{
f0100f7c:	55                   	push   %ebp
f0100f7d:	89 e5                	mov    %esp,%ebp
f0100f7f:	57                   	push   %edi
f0100f80:	56                   	push   %esi
f0100f81:	53                   	push   %ebx
f0100f82:	83 ec 1c             	sub    $0x1c,%esp
	pde_t pd_entry = (pde_t)pgdir[PDX(va)];
f0100f85:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100f88:	c1 eb 16             	shr    $0x16,%ebx
f0100f8b:	c1 e3 02             	shl    $0x2,%ebx
f0100f8e:	03 5d 08             	add    0x8(%ebp),%ebx
f0100f91:	8b 03                	mov    (%ebx),%eax
	if (pd_entry) {
f0100f93:	85 c0                	test   %eax,%eax
f0100f95:	74 42                	je     f0100fd9 <pgdir_walk+0x5d>
		pte_t* pt_base = KADDR(PTE_ADDR(pd_entry));
f0100f97:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100f9c:	89 c2                	mov    %eax,%edx
f0100f9e:	c1 ea 0c             	shr    $0xc,%edx
f0100fa1:	39 15 64 89 11 f0    	cmp    %edx,0xf0118964
f0100fa7:	76 1b                	jbe    f0100fc4 <pgdir_walk+0x48>
		return pt_base + PTX(va);
f0100fa9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100fac:	c1 ea 0a             	shr    $0xa,%edx
f0100faf:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f0100fb5:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
}
f0100fbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fbf:	5b                   	pop    %ebx
f0100fc0:	5e                   	pop    %esi
f0100fc1:	5f                   	pop    %edi
f0100fc2:	5d                   	pop    %ebp
f0100fc3:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fc4:	50                   	push   %eax
f0100fc5:	68 44 41 10 f0       	push   $0xf0104144
f0100fca:	68 67 01 00 00       	push   $0x167
f0100fcf:	68 bc 48 10 f0       	push   $0xf01048bc
f0100fd4:	e8 5a f1 ff ff       	call   f0100133 <_panic>
	else if (create) {
f0100fd9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100fdd:	0f 84 9c 00 00 00    	je     f010107f <pgdir_walk+0x103>
		struct PageInfo *new_pt = page_alloc(0);
f0100fe3:	83 ec 0c             	sub    $0xc,%esp
f0100fe6:	6a 00                	push   $0x0
f0100fe8:	e8 a5 fe ff ff       	call   f0100e92 <page_alloc>
f0100fed:	89 c7                	mov    %eax,%edi
		if (new_pt) {
f0100fef:	83 c4 10             	add    $0x10,%esp
f0100ff2:	85 c0                	test   %eax,%eax
f0100ff4:	0f 84 8f 00 00 00    	je     f0101089 <pgdir_walk+0x10d>
	return (pp - pages) << PGSHIFT;
f0100ffa:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0101000:	c1 f8 03             	sar    $0x3,%eax
f0101003:	c1 e0 0c             	shl    $0xc,%eax
f0101006:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (PGNUM(pa) >= npages)
f0101009:	c1 e8 0c             	shr    $0xc,%eax
f010100c:	3b 05 64 89 11 f0    	cmp    0xf0118964,%eax
f0101012:	73 42                	jae    f0101056 <pgdir_walk+0xda>
	return (void *)(pa + KERNBASE);
f0101014:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101017:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
			memset(content, 0, PGSIZE);
f010101d:	83 ec 04             	sub    $0x4,%esp
f0101020:	68 00 10 00 00       	push   $0x1000
f0101025:	6a 00                	push   $0x0
f0101027:	56                   	push   %esi
f0101028:	e8 6b 25 00 00       	call   f0103598 <memset>
			new_pt->pp_ref++;
f010102d:	66 ff 47 04          	incw   0x4(%edi)
	if ((uint32_t)kva < KERNBASE)
f0101031:	83 c4 10             	add    $0x10,%esp
f0101034:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f010103a:	76 2e                	jbe    f010106a <pgdir_walk+0xee>
			pgdir[PDX(va)] = PADDR(content) | 0xF; // Set all permissions.
f010103c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010103f:	83 c8 0f             	or     $0xf,%eax
f0101042:	89 03                	mov    %eax,(%ebx)
			return (pte_t*) content + PTX(va);
f0101044:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101047:	c1 e8 0a             	shr    $0xa,%eax
f010104a:	25 fc 0f 00 00       	and    $0xffc,%eax
f010104f:	01 f0                	add    %esi,%eax
f0101051:	e9 66 ff ff ff       	jmp    f0100fbc <pgdir_walk+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101056:	ff 75 e4             	pushl  -0x1c(%ebp)
f0101059:	68 44 41 10 f0       	push   $0xf0104144
f010105e:	6a 52                	push   $0x52
f0101060:	68 c8 48 10 f0       	push   $0xf01048c8
f0101065:	e8 c9 f0 ff ff       	call   f0100133 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010106a:	56                   	push   %esi
f010106b:	68 50 42 10 f0       	push   $0xf0104250
f0101070:	68 70 01 00 00       	push   $0x170
f0101075:	68 bc 48 10 f0       	push   $0xf01048bc
f010107a:	e8 b4 f0 ff ff       	call   f0100133 <_panic>
	return NULL;
f010107f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101084:	e9 33 ff ff ff       	jmp    f0100fbc <pgdir_walk+0x40>
f0101089:	b8 00 00 00 00       	mov    $0x0,%eax
f010108e:	e9 29 ff ff ff       	jmp    f0100fbc <pgdir_walk+0x40>

f0101093 <boot_map_region>:
{
f0101093:	55                   	push   %ebp
f0101094:	89 e5                	mov    %esp,%ebp
f0101096:	57                   	push   %edi
f0101097:	56                   	push   %esi
f0101098:	53                   	push   %ebx
f0101099:	83 ec 1c             	sub    $0x1c,%esp
f010109c:	89 c7                	mov    %eax,%edi
f010109e:	89 d6                	mov    %edx,%esi
f01010a0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f01010a3:	bb 00 00 00 00       	mov    $0x0,%ebx
		*page_entry = (pa + size0) | perm | PTE_P;
f01010a8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010ab:	83 c8 01             	or     $0x1,%eax
f01010ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f01010b1:	eb 22                	jmp    f01010d5 <boot_map_region+0x42>
		pte_t *page_entry = pgdir_walk(pgdir, (void*) va + size0, 1);
f01010b3:	83 ec 04             	sub    $0x4,%esp
f01010b6:	6a 01                	push   $0x1
f01010b8:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f01010bb:	50                   	push   %eax
f01010bc:	57                   	push   %edi
f01010bd:	e8 ba fe ff ff       	call   f0100f7c <pgdir_walk>
		*page_entry = (pa + size0) | perm | PTE_P;
f01010c2:	89 da                	mov    %ebx,%edx
f01010c4:	03 55 08             	add    0x8(%ebp),%edx
f01010c7:	0b 55 e0             	or     -0x20(%ebp),%edx
f01010ca:	89 10                	mov    %edx,(%eax)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f01010cc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01010d2:	83 c4 10             	add    $0x10,%esp
f01010d5:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01010d8:	72 d9                	jb     f01010b3 <boot_map_region+0x20>
}
f01010da:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010dd:	5b                   	pop    %ebx
f01010de:	5e                   	pop    %esi
f01010df:	5f                   	pop    %edi
f01010e0:	5d                   	pop    %ebp
f01010e1:	c3                   	ret    

f01010e2 <page_lookup>:
{
f01010e2:	55                   	push   %ebp
f01010e3:	89 e5                	mov    %esp,%ebp
f01010e5:	53                   	push   %ebx
f01010e6:	83 ec 08             	sub    $0x8,%esp
f01010e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *page_entry = pgdir_walk(pgdir, (void*) va, 0);
f01010ec:	6a 00                	push   $0x0
f01010ee:	ff 75 0c             	pushl  0xc(%ebp)
f01010f1:	ff 75 08             	pushl  0x8(%ebp)
f01010f4:	e8 83 fe ff ff       	call   f0100f7c <pgdir_walk>
	if (!page_entry || !*page_entry)
f01010f9:	83 c4 10             	add    $0x10,%esp
f01010fc:	85 c0                	test   %eax,%eax
f01010fe:	74 3a                	je     f010113a <page_lookup+0x58>
f0101100:	83 38 00             	cmpl   $0x0,(%eax)
f0101103:	74 3c                	je     f0101141 <page_lookup+0x5f>
	if (pte_store)
f0101105:	85 db                	test   %ebx,%ebx
f0101107:	74 02                	je     f010110b <page_lookup+0x29>
		*pte_store = page_entry;
f0101109:	89 03                	mov    %eax,(%ebx)
f010110b:	8b 00                	mov    (%eax),%eax
f010110d:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101110:	39 05 64 89 11 f0    	cmp    %eax,0xf0118964
f0101116:	76 0e                	jbe    f0101126 <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0101118:	8b 15 6c 89 11 f0    	mov    0xf011896c,%edx
f010111e:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0101121:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101124:	c9                   	leave  
f0101125:	c3                   	ret    
		panic("pa2page called with invalid pa");
f0101126:	83 ec 04             	sub    $0x4,%esp
f0101129:	68 74 42 10 f0       	push   $0xf0104274
f010112e:	6a 4b                	push   $0x4b
f0101130:	68 c8 48 10 f0       	push   $0xf01048c8
f0101135:	e8 f9 ef ff ff       	call   f0100133 <_panic>
		return NULL;
f010113a:	b8 00 00 00 00       	mov    $0x0,%eax
f010113f:	eb e0                	jmp    f0101121 <page_lookup+0x3f>
f0101141:	b8 00 00 00 00       	mov    $0x0,%eax
f0101146:	eb d9                	jmp    f0101121 <page_lookup+0x3f>

f0101148 <page_remove>:
{
f0101148:	55                   	push   %ebp
f0101149:	89 e5                	mov    %esp,%ebp
f010114b:	53                   	push   %ebx
f010114c:	83 ec 18             	sub    $0x18,%esp
f010114f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo *pp = page_lookup(pgdir, va, &pte_store);
f0101152:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101155:	50                   	push   %eax
f0101156:	53                   	push   %ebx
f0101157:	ff 75 08             	pushl  0x8(%ebp)
f010115a:	e8 83 ff ff ff       	call   f01010e2 <page_lookup>
	if (!pp)
f010115f:	83 c4 10             	add    $0x10,%esp
f0101162:	85 c0                	test   %eax,%eax
f0101164:	74 17                	je     f010117d <page_remove+0x35>
	pp->pp_ref--;
f0101166:	66 ff 48 04          	decw   0x4(%eax)
	*pte_store = 0;
f010116a:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010116d:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101173:	0f 01 3b             	invlpg (%ebx)
	if (!pp->pp_ref)
f0101176:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010117b:	74 05                	je     f0101182 <page_remove+0x3a>
}
f010117d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101180:	c9                   	leave  
f0101181:	c3                   	ret    
		page_free(pp);
f0101182:	83 ec 0c             	sub    $0xc,%esp
f0101185:	50                   	push   %eax
f0101186:	e8 79 fd ff ff       	call   f0100f04 <page_free>
f010118b:	83 c4 10             	add    $0x10,%esp
f010118e:	eb ed                	jmp    f010117d <page_remove+0x35>

f0101190 <page_insert>:
{
f0101190:	55                   	push   %ebp
f0101191:	89 e5                	mov    %esp,%ebp
f0101193:	57                   	push   %edi
f0101194:	56                   	push   %esi
f0101195:	53                   	push   %ebx
f0101196:	83 ec 10             	sub    $0x10,%esp
f0101199:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010119c:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *page_entry = pgdir_walk(pgdir, (void*) va, 1);
f010119f:	6a 01                	push   $0x1
f01011a1:	57                   	push   %edi
f01011a2:	ff 75 08             	pushl  0x8(%ebp)
f01011a5:	e8 d2 fd ff ff       	call   f0100f7c <pgdir_walk>
	if (!page_entry)
f01011aa:	83 c4 10             	add    $0x10,%esp
f01011ad:	85 c0                	test   %eax,%eax
f01011af:	74 3f                	je     f01011f0 <page_insert+0x60>
f01011b1:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f01011b3:	66 ff 43 04          	incw   0x4(%ebx)
	if (*page_entry) 
f01011b7:	83 38 00             	cmpl   $0x0,(%eax)
f01011ba:	75 23                	jne    f01011df <page_insert+0x4f>
	return (pp - pages) << PGSHIFT;
f01011bc:	2b 1d 6c 89 11 f0    	sub    0xf011896c,%ebx
f01011c2:	c1 fb 03             	sar    $0x3,%ebx
f01011c5:	c1 e3 0c             	shl    $0xc,%ebx
	*page_entry = page2pa(pp) | perm | PTE_P;
f01011c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01011cb:	83 c8 01             	or     $0x1,%eax
f01011ce:	09 c3                	or     %eax,%ebx
f01011d0:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01011d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01011d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011da:	5b                   	pop    %ebx
f01011db:	5e                   	pop    %esi
f01011dc:	5f                   	pop    %edi
f01011dd:	5d                   	pop    %ebp
f01011de:	c3                   	ret    
		page_remove(pgdir, va);
f01011df:	83 ec 08             	sub    $0x8,%esp
f01011e2:	57                   	push   %edi
f01011e3:	ff 75 08             	pushl  0x8(%ebp)
f01011e6:	e8 5d ff ff ff       	call   f0101148 <page_remove>
f01011eb:	83 c4 10             	add    $0x10,%esp
f01011ee:	eb cc                	jmp    f01011bc <page_insert+0x2c>
		return -E_NO_MEM;  // Has no page table AND cannot be allocated
f01011f0:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01011f5:	eb e0                	jmp    f01011d7 <page_insert+0x47>

f01011f7 <mem_init>:
{
f01011f7:	55                   	push   %ebp
f01011f8:	89 e5                	mov    %esp,%ebp
f01011fa:	57                   	push   %edi
f01011fb:	56                   	push   %esi
f01011fc:	53                   	push   %ebx
f01011fd:	83 ec 2c             	sub    $0x2c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0101200:	b8 15 00 00 00       	mov    $0x15,%eax
f0101205:	e8 7f f8 ff ff       	call   f0100a89 <nvram_read>
f010120a:	89 c6                	mov    %eax,%esi
	extmem = nvram_read(NVRAM_EXTLO);
f010120c:	b8 17 00 00 00       	mov    $0x17,%eax
f0101211:	e8 73 f8 ff ff       	call   f0100a89 <nvram_read>
f0101216:	89 c3                	mov    %eax,%ebx
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101218:	b8 34 00 00 00       	mov    $0x34,%eax
f010121d:	e8 67 f8 ff ff       	call   f0100a89 <nvram_read>
	if (ext16mem)
f0101222:	c1 e0 06             	shl    $0x6,%eax
f0101225:	75 10                	jne    f0101237 <mem_init+0x40>
	else if (extmem)
f0101227:	85 db                	test   %ebx,%ebx
f0101229:	0f 84 c3 00 00 00    	je     f01012f2 <mem_init+0xfb>
		totalmem = 1 * 1024 + extmem;
f010122f:	8d 83 00 04 00 00    	lea    0x400(%ebx),%eax
f0101235:	eb 05                	jmp    f010123c <mem_init+0x45>
		totalmem = 16 * 1024 + ext16mem;
f0101237:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f010123c:	89 c2                	mov    %eax,%edx
f010123e:	c1 ea 02             	shr    $0x2,%edx
f0101241:	89 15 64 89 11 f0    	mov    %edx,0xf0118964
	npages_basemem = basemem / (PGSIZE / 1024);
f0101247:	89 f2                	mov    %esi,%edx
f0101249:	c1 ea 02             	shr    $0x2,%edx
f010124c:	89 15 40 85 11 f0    	mov    %edx,0xf0118540
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101252:	89 c2                	mov    %eax,%edx
f0101254:	29 f2                	sub    %esi,%edx
f0101256:	52                   	push   %edx
f0101257:	56                   	push   %esi
f0101258:	50                   	push   %eax
f0101259:	68 94 42 10 f0       	push   $0xf0104294
f010125e:	e8 06 18 00 00       	call   f0102a69 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101263:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101268:	e8 d6 f7 ff ff       	call   f0100a43 <boot_alloc>
f010126d:	a3 68 89 11 f0       	mov    %eax,0xf0118968
	memset(kern_pgdir, 0, PGSIZE);
f0101272:	83 c4 0c             	add    $0xc,%esp
f0101275:	68 00 10 00 00       	push   $0x1000
f010127a:	6a 00                	push   $0x0
f010127c:	50                   	push   %eax
f010127d:	e8 16 23 00 00       	call   f0103598 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101282:	a1 68 89 11 f0       	mov    0xf0118968,%eax
	if ((uint32_t)kva < KERNBASE)
f0101287:	83 c4 10             	add    $0x10,%esp
f010128a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010128f:	76 68                	jbe    f01012f9 <mem_init+0x102>
	return (physaddr_t)kva - KERNBASE;
f0101291:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101297:	83 ca 05             	or     $0x5,%edx
f010129a:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo)*npages);
f01012a0:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f01012a5:	c1 e0 03             	shl    $0x3,%eax
f01012a8:	e8 96 f7 ff ff       	call   f0100a43 <boot_alloc>
f01012ad:	a3 6c 89 11 f0       	mov    %eax,0xf011896c
	memset(pages, 0, sizeof(struct PageInfo)*npages);
f01012b2:	83 ec 04             	sub    $0x4,%esp
f01012b5:	8b 0d 64 89 11 f0    	mov    0xf0118964,%ecx
f01012bb:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01012c2:	52                   	push   %edx
f01012c3:	6a 00                	push   $0x0
f01012c5:	50                   	push   %eax
f01012c6:	e8 cd 22 00 00       	call   f0103598 <memset>
	page_init();
f01012cb:	e8 06 fb ff ff       	call   f0100dd6 <page_init>
	check_page_free_list(1);
f01012d0:	b8 01 00 00 00       	mov    $0x1,%eax
f01012d5:	e8 35 f8 ff ff       	call   f0100b0f <check_page_free_list>
	if (!pages)
f01012da:	83 c4 10             	add    $0x10,%esp
f01012dd:	83 3d 6c 89 11 f0 00 	cmpl   $0x0,0xf011896c
f01012e4:	74 28                	je     f010130e <mem_init+0x117>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01012e6:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f01012eb:	bb 00 00 00 00       	mov    $0x0,%ebx
f01012f0:	eb 36                	jmp    f0101328 <mem_init+0x131>
		totalmem = basemem;
f01012f2:	89 f0                	mov    %esi,%eax
f01012f4:	e9 43 ff ff ff       	jmp    f010123c <mem_init+0x45>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01012f9:	50                   	push   %eax
f01012fa:	68 50 42 10 f0       	push   $0xf0104250
f01012ff:	68 91 00 00 00       	push   $0x91
f0101304:	68 bc 48 10 f0       	push   $0xf01048bc
f0101309:	e8 25 ee ff ff       	call   f0100133 <_panic>
		panic("'pages' is a null pointer!");
f010130e:	83 ec 04             	sub    $0x4,%esp
f0101311:	68 9d 49 10 f0       	push   $0xf010499d
f0101316:	68 41 02 00 00       	push   $0x241
f010131b:	68 bc 48 10 f0       	push   $0xf01048bc
f0101320:	e8 0e ee ff ff       	call   f0100133 <_panic>
		++nfree;
f0101325:	43                   	inc    %ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101326:	8b 00                	mov    (%eax),%eax
f0101328:	85 c0                	test   %eax,%eax
f010132a:	75 f9                	jne    f0101325 <mem_init+0x12e>
	assert((pp0 = page_alloc(0)));
f010132c:	83 ec 0c             	sub    $0xc,%esp
f010132f:	6a 00                	push   $0x0
f0101331:	e8 5c fb ff ff       	call   f0100e92 <page_alloc>
f0101336:	89 c7                	mov    %eax,%edi
f0101338:	83 c4 10             	add    $0x10,%esp
f010133b:	85 c0                	test   %eax,%eax
f010133d:	0f 84 10 02 00 00    	je     f0101553 <mem_init+0x35c>
	assert((pp1 = page_alloc(0)));
f0101343:	83 ec 0c             	sub    $0xc,%esp
f0101346:	6a 00                	push   $0x0
f0101348:	e8 45 fb ff ff       	call   f0100e92 <page_alloc>
f010134d:	89 c6                	mov    %eax,%esi
f010134f:	83 c4 10             	add    $0x10,%esp
f0101352:	85 c0                	test   %eax,%eax
f0101354:	0f 84 12 02 00 00    	je     f010156c <mem_init+0x375>
	assert((pp2 = page_alloc(0)));
f010135a:	83 ec 0c             	sub    $0xc,%esp
f010135d:	6a 00                	push   $0x0
f010135f:	e8 2e fb ff ff       	call   f0100e92 <page_alloc>
f0101364:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101367:	83 c4 10             	add    $0x10,%esp
f010136a:	85 c0                	test   %eax,%eax
f010136c:	0f 84 13 02 00 00    	je     f0101585 <mem_init+0x38e>
	assert(pp1 && pp1 != pp0);
f0101372:	39 f7                	cmp    %esi,%edi
f0101374:	0f 84 24 02 00 00    	je     f010159e <mem_init+0x3a7>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010137a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010137d:	39 c6                	cmp    %eax,%esi
f010137f:	0f 84 32 02 00 00    	je     f01015b7 <mem_init+0x3c0>
f0101385:	39 c7                	cmp    %eax,%edi
f0101387:	0f 84 2a 02 00 00    	je     f01015b7 <mem_init+0x3c0>
	return (pp - pages) << PGSHIFT;
f010138d:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101393:	8b 15 64 89 11 f0    	mov    0xf0118964,%edx
f0101399:	c1 e2 0c             	shl    $0xc,%edx
f010139c:	89 f8                	mov    %edi,%eax
f010139e:	29 c8                	sub    %ecx,%eax
f01013a0:	c1 f8 03             	sar    $0x3,%eax
f01013a3:	c1 e0 0c             	shl    $0xc,%eax
f01013a6:	39 d0                	cmp    %edx,%eax
f01013a8:	0f 83 22 02 00 00    	jae    f01015d0 <mem_init+0x3d9>
f01013ae:	89 f0                	mov    %esi,%eax
f01013b0:	29 c8                	sub    %ecx,%eax
f01013b2:	c1 f8 03             	sar    $0x3,%eax
f01013b5:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01013b8:	39 c2                	cmp    %eax,%edx
f01013ba:	0f 86 29 02 00 00    	jbe    f01015e9 <mem_init+0x3f2>
f01013c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01013c3:	29 c8                	sub    %ecx,%eax
f01013c5:	c1 f8 03             	sar    $0x3,%eax
f01013c8:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01013cb:	39 c2                	cmp    %eax,%edx
f01013cd:	0f 86 2f 02 00 00    	jbe    f0101602 <mem_init+0x40b>
	fl = page_free_list;
f01013d3:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f01013d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01013db:	c7 05 3c 85 11 f0 00 	movl   $0x0,0xf011853c
f01013e2:	00 00 00 
	assert(!page_alloc(0));
f01013e5:	83 ec 0c             	sub    $0xc,%esp
f01013e8:	6a 00                	push   $0x0
f01013ea:	e8 a3 fa ff ff       	call   f0100e92 <page_alloc>
f01013ef:	83 c4 10             	add    $0x10,%esp
f01013f2:	85 c0                	test   %eax,%eax
f01013f4:	0f 85 21 02 00 00    	jne    f010161b <mem_init+0x424>
	page_free(pp0);
f01013fa:	83 ec 0c             	sub    $0xc,%esp
f01013fd:	57                   	push   %edi
f01013fe:	e8 01 fb ff ff       	call   f0100f04 <page_free>
	page_free(pp1);
f0101403:	89 34 24             	mov    %esi,(%esp)
f0101406:	e8 f9 fa ff ff       	call   f0100f04 <page_free>
	page_free(pp2);
f010140b:	83 c4 04             	add    $0x4,%esp
f010140e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101411:	e8 ee fa ff ff       	call   f0100f04 <page_free>
	assert((pp0 = page_alloc(0)));
f0101416:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010141d:	e8 70 fa ff ff       	call   f0100e92 <page_alloc>
f0101422:	89 c6                	mov    %eax,%esi
f0101424:	83 c4 10             	add    $0x10,%esp
f0101427:	85 c0                	test   %eax,%eax
f0101429:	0f 84 05 02 00 00    	je     f0101634 <mem_init+0x43d>
	assert((pp1 = page_alloc(0)));
f010142f:	83 ec 0c             	sub    $0xc,%esp
f0101432:	6a 00                	push   $0x0
f0101434:	e8 59 fa ff ff       	call   f0100e92 <page_alloc>
f0101439:	89 c7                	mov    %eax,%edi
f010143b:	83 c4 10             	add    $0x10,%esp
f010143e:	85 c0                	test   %eax,%eax
f0101440:	0f 84 07 02 00 00    	je     f010164d <mem_init+0x456>
	assert((pp2 = page_alloc(0)));
f0101446:	83 ec 0c             	sub    $0xc,%esp
f0101449:	6a 00                	push   $0x0
f010144b:	e8 42 fa ff ff       	call   f0100e92 <page_alloc>
f0101450:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101453:	83 c4 10             	add    $0x10,%esp
f0101456:	85 c0                	test   %eax,%eax
f0101458:	0f 84 08 02 00 00    	je     f0101666 <mem_init+0x46f>
	assert(pp1 && pp1 != pp0);
f010145e:	39 fe                	cmp    %edi,%esi
f0101460:	0f 84 19 02 00 00    	je     f010167f <mem_init+0x488>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101466:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101469:	39 c7                	cmp    %eax,%edi
f010146b:	0f 84 27 02 00 00    	je     f0101698 <mem_init+0x4a1>
f0101471:	39 c6                	cmp    %eax,%esi
f0101473:	0f 84 1f 02 00 00    	je     f0101698 <mem_init+0x4a1>
	assert(!page_alloc(0));
f0101479:	83 ec 0c             	sub    $0xc,%esp
f010147c:	6a 00                	push   $0x0
f010147e:	e8 0f fa ff ff       	call   f0100e92 <page_alloc>
f0101483:	83 c4 10             	add    $0x10,%esp
f0101486:	85 c0                	test   %eax,%eax
f0101488:	0f 85 23 02 00 00    	jne    f01016b1 <mem_init+0x4ba>
f010148e:	89 f0                	mov    %esi,%eax
f0101490:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0101496:	c1 f8 03             	sar    $0x3,%eax
f0101499:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010149c:	89 c2                	mov    %eax,%edx
f010149e:	c1 ea 0c             	shr    $0xc,%edx
f01014a1:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f01014a7:	0f 83 1d 02 00 00    	jae    f01016ca <mem_init+0x4d3>
	memset(page2kva(pp0), 1, PGSIZE);
f01014ad:	83 ec 04             	sub    $0x4,%esp
f01014b0:	68 00 10 00 00       	push   $0x1000
f01014b5:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01014b7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01014bc:	50                   	push   %eax
f01014bd:	e8 d6 20 00 00       	call   f0103598 <memset>
	page_free(pp0);
f01014c2:	89 34 24             	mov    %esi,(%esp)
f01014c5:	e8 3a fa ff ff       	call   f0100f04 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01014ca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01014d1:	e8 bc f9 ff ff       	call   f0100e92 <page_alloc>
f01014d6:	83 c4 10             	add    $0x10,%esp
f01014d9:	85 c0                	test   %eax,%eax
f01014db:	0f 84 fb 01 00 00    	je     f01016dc <mem_init+0x4e5>
	assert(pp && pp0 == pp);
f01014e1:	39 c6                	cmp    %eax,%esi
f01014e3:	0f 85 0c 02 00 00    	jne    f01016f5 <mem_init+0x4fe>
	return (pp - pages) << PGSHIFT;
f01014e9:	89 f2                	mov    %esi,%edx
f01014eb:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f01014f1:	c1 fa 03             	sar    $0x3,%edx
f01014f4:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01014f7:	89 d0                	mov    %edx,%eax
f01014f9:	c1 e8 0c             	shr    $0xc,%eax
f01014fc:	3b 05 64 89 11 f0    	cmp    0xf0118964,%eax
f0101502:	0f 83 06 02 00 00    	jae    f010170e <mem_init+0x517>
	return (void *)(pa + KERNBASE);
f0101508:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f010150e:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101514:	80 38 00             	cmpb   $0x0,(%eax)
f0101517:	0f 85 03 02 00 00    	jne    f0101720 <mem_init+0x529>
f010151d:	40                   	inc    %eax
	for (i = 0; i < PGSIZE; i++)
f010151e:	39 d0                	cmp    %edx,%eax
f0101520:	75 f2                	jne    f0101514 <mem_init+0x31d>
	page_free_list = fl;
f0101522:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101525:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
	page_free(pp0);
f010152a:	83 ec 0c             	sub    $0xc,%esp
f010152d:	56                   	push   %esi
f010152e:	e8 d1 f9 ff ff       	call   f0100f04 <page_free>
	page_free(pp1);
f0101533:	89 3c 24             	mov    %edi,(%esp)
f0101536:	e8 c9 f9 ff ff       	call   f0100f04 <page_free>
	page_free(pp2);
f010153b:	83 c4 04             	add    $0x4,%esp
f010153e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101541:	e8 be f9 ff ff       	call   f0100f04 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101546:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f010154b:	83 c4 10             	add    $0x10,%esp
f010154e:	e9 e9 01 00 00       	jmp    f010173c <mem_init+0x545>
	assert((pp0 = page_alloc(0)));
f0101553:	68 b8 49 10 f0       	push   $0xf01049b8
f0101558:	68 e2 48 10 f0       	push   $0xf01048e2
f010155d:	68 49 02 00 00       	push   $0x249
f0101562:	68 bc 48 10 f0       	push   $0xf01048bc
f0101567:	e8 c7 eb ff ff       	call   f0100133 <_panic>
	assert((pp1 = page_alloc(0)));
f010156c:	68 ce 49 10 f0       	push   $0xf01049ce
f0101571:	68 e2 48 10 f0       	push   $0xf01048e2
f0101576:	68 4a 02 00 00       	push   $0x24a
f010157b:	68 bc 48 10 f0       	push   $0xf01048bc
f0101580:	e8 ae eb ff ff       	call   f0100133 <_panic>
	assert((pp2 = page_alloc(0)));
f0101585:	68 e4 49 10 f0       	push   $0xf01049e4
f010158a:	68 e2 48 10 f0       	push   $0xf01048e2
f010158f:	68 4b 02 00 00       	push   $0x24b
f0101594:	68 bc 48 10 f0       	push   $0xf01048bc
f0101599:	e8 95 eb ff ff       	call   f0100133 <_panic>
	assert(pp1 && pp1 != pp0);
f010159e:	68 fa 49 10 f0       	push   $0xf01049fa
f01015a3:	68 e2 48 10 f0       	push   $0xf01048e2
f01015a8:	68 4e 02 00 00       	push   $0x24e
f01015ad:	68 bc 48 10 f0       	push   $0xf01048bc
f01015b2:	e8 7c eb ff ff       	call   f0100133 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015b7:	68 d0 42 10 f0       	push   $0xf01042d0
f01015bc:	68 e2 48 10 f0       	push   $0xf01048e2
f01015c1:	68 4f 02 00 00       	push   $0x24f
f01015c6:	68 bc 48 10 f0       	push   $0xf01048bc
f01015cb:	e8 63 eb ff ff       	call   f0100133 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f01015d0:	68 0c 4a 10 f0       	push   $0xf0104a0c
f01015d5:	68 e2 48 10 f0       	push   $0xf01048e2
f01015da:	68 50 02 00 00       	push   $0x250
f01015df:	68 bc 48 10 f0       	push   $0xf01048bc
f01015e4:	e8 4a eb ff ff       	call   f0100133 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01015e9:	68 29 4a 10 f0       	push   $0xf0104a29
f01015ee:	68 e2 48 10 f0       	push   $0xf01048e2
f01015f3:	68 51 02 00 00       	push   $0x251
f01015f8:	68 bc 48 10 f0       	push   $0xf01048bc
f01015fd:	e8 31 eb ff ff       	call   f0100133 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101602:	68 46 4a 10 f0       	push   $0xf0104a46
f0101607:	68 e2 48 10 f0       	push   $0xf01048e2
f010160c:	68 52 02 00 00       	push   $0x252
f0101611:	68 bc 48 10 f0       	push   $0xf01048bc
f0101616:	e8 18 eb ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f010161b:	68 63 4a 10 f0       	push   $0xf0104a63
f0101620:	68 e2 48 10 f0       	push   $0xf01048e2
f0101625:	68 59 02 00 00       	push   $0x259
f010162a:	68 bc 48 10 f0       	push   $0xf01048bc
f010162f:	e8 ff ea ff ff       	call   f0100133 <_panic>
	assert((pp0 = page_alloc(0)));
f0101634:	68 b8 49 10 f0       	push   $0xf01049b8
f0101639:	68 e2 48 10 f0       	push   $0xf01048e2
f010163e:	68 60 02 00 00       	push   $0x260
f0101643:	68 bc 48 10 f0       	push   $0xf01048bc
f0101648:	e8 e6 ea ff ff       	call   f0100133 <_panic>
	assert((pp1 = page_alloc(0)));
f010164d:	68 ce 49 10 f0       	push   $0xf01049ce
f0101652:	68 e2 48 10 f0       	push   $0xf01048e2
f0101657:	68 61 02 00 00       	push   $0x261
f010165c:	68 bc 48 10 f0       	push   $0xf01048bc
f0101661:	e8 cd ea ff ff       	call   f0100133 <_panic>
	assert((pp2 = page_alloc(0)));
f0101666:	68 e4 49 10 f0       	push   $0xf01049e4
f010166b:	68 e2 48 10 f0       	push   $0xf01048e2
f0101670:	68 62 02 00 00       	push   $0x262
f0101675:	68 bc 48 10 f0       	push   $0xf01048bc
f010167a:	e8 b4 ea ff ff       	call   f0100133 <_panic>
	assert(pp1 && pp1 != pp0);
f010167f:	68 fa 49 10 f0       	push   $0xf01049fa
f0101684:	68 e2 48 10 f0       	push   $0xf01048e2
f0101689:	68 64 02 00 00       	push   $0x264
f010168e:	68 bc 48 10 f0       	push   $0xf01048bc
f0101693:	e8 9b ea ff ff       	call   f0100133 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101698:	68 d0 42 10 f0       	push   $0xf01042d0
f010169d:	68 e2 48 10 f0       	push   $0xf01048e2
f01016a2:	68 65 02 00 00       	push   $0x265
f01016a7:	68 bc 48 10 f0       	push   $0xf01048bc
f01016ac:	e8 82 ea ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f01016b1:	68 63 4a 10 f0       	push   $0xf0104a63
f01016b6:	68 e2 48 10 f0       	push   $0xf01048e2
f01016bb:	68 66 02 00 00       	push   $0x266
f01016c0:	68 bc 48 10 f0       	push   $0xf01048bc
f01016c5:	e8 69 ea ff ff       	call   f0100133 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016ca:	50                   	push   %eax
f01016cb:	68 44 41 10 f0       	push   $0xf0104144
f01016d0:	6a 52                	push   $0x52
f01016d2:	68 c8 48 10 f0       	push   $0xf01048c8
f01016d7:	e8 57 ea ff ff       	call   f0100133 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01016dc:	68 72 4a 10 f0       	push   $0xf0104a72
f01016e1:	68 e2 48 10 f0       	push   $0xf01048e2
f01016e6:	68 6b 02 00 00       	push   $0x26b
f01016eb:	68 bc 48 10 f0       	push   $0xf01048bc
f01016f0:	e8 3e ea ff ff       	call   f0100133 <_panic>
	assert(pp && pp0 == pp);
f01016f5:	68 90 4a 10 f0       	push   $0xf0104a90
f01016fa:	68 e2 48 10 f0       	push   $0xf01048e2
f01016ff:	68 6c 02 00 00       	push   $0x26c
f0101704:	68 bc 48 10 f0       	push   $0xf01048bc
f0101709:	e8 25 ea ff ff       	call   f0100133 <_panic>
f010170e:	52                   	push   %edx
f010170f:	68 44 41 10 f0       	push   $0xf0104144
f0101714:	6a 52                	push   $0x52
f0101716:	68 c8 48 10 f0       	push   $0xf01048c8
f010171b:	e8 13 ea ff ff       	call   f0100133 <_panic>
		assert(c[i] == 0);
f0101720:	68 a0 4a 10 f0       	push   $0xf0104aa0
f0101725:	68 e2 48 10 f0       	push   $0xf01048e2
f010172a:	68 6f 02 00 00       	push   $0x26f
f010172f:	68 bc 48 10 f0       	push   $0xf01048bc
f0101734:	e8 fa e9 ff ff       	call   f0100133 <_panic>
		--nfree;
f0101739:	4b                   	dec    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010173a:	8b 00                	mov    (%eax),%eax
f010173c:	85 c0                	test   %eax,%eax
f010173e:	75 f9                	jne    f0101739 <mem_init+0x542>
	assert(nfree == 0);
f0101740:	85 db                	test   %ebx,%ebx
f0101742:	0f 85 9c 07 00 00    	jne    f0101ee4 <mem_init+0xced>
	cprintf("check_page_alloc() succeeded!\n");
f0101748:	83 ec 0c             	sub    $0xc,%esp
f010174b:	68 f0 42 10 f0       	push   $0xf01042f0
f0101750:	e8 14 13 00 00       	call   f0102a69 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101755:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010175c:	e8 31 f7 ff ff       	call   f0100e92 <page_alloc>
f0101761:	89 c7                	mov    %eax,%edi
f0101763:	83 c4 10             	add    $0x10,%esp
f0101766:	85 c0                	test   %eax,%eax
f0101768:	0f 84 8f 07 00 00    	je     f0101efd <mem_init+0xd06>
	assert((pp1 = page_alloc(0)));
f010176e:	83 ec 0c             	sub    $0xc,%esp
f0101771:	6a 00                	push   $0x0
f0101773:	e8 1a f7 ff ff       	call   f0100e92 <page_alloc>
f0101778:	89 c3                	mov    %eax,%ebx
f010177a:	83 c4 10             	add    $0x10,%esp
f010177d:	85 c0                	test   %eax,%eax
f010177f:	0f 84 91 07 00 00    	je     f0101f16 <mem_init+0xd1f>
	assert((pp2 = page_alloc(0)));
f0101785:	83 ec 0c             	sub    $0xc,%esp
f0101788:	6a 00                	push   $0x0
f010178a:	e8 03 f7 ff ff       	call   f0100e92 <page_alloc>
f010178f:	89 c6                	mov    %eax,%esi
f0101791:	83 c4 10             	add    $0x10,%esp
f0101794:	85 c0                	test   %eax,%eax
f0101796:	0f 84 93 07 00 00    	je     f0101f2f <mem_init+0xd38>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010179c:	39 df                	cmp    %ebx,%edi
f010179e:	0f 84 a4 07 00 00    	je     f0101f48 <mem_init+0xd51>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017a4:	39 c3                	cmp    %eax,%ebx
f01017a6:	0f 84 b5 07 00 00    	je     f0101f61 <mem_init+0xd6a>
f01017ac:	39 c7                	cmp    %eax,%edi
f01017ae:	0f 84 ad 07 00 00    	je     f0101f61 <mem_init+0xd6a>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01017b4:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f01017b9:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f01017bc:	c7 05 3c 85 11 f0 00 	movl   $0x0,0xf011853c
f01017c3:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01017c6:	83 ec 0c             	sub    $0xc,%esp
f01017c9:	6a 00                	push   $0x0
f01017cb:	e8 c2 f6 ff ff       	call   f0100e92 <page_alloc>
f01017d0:	83 c4 10             	add    $0x10,%esp
f01017d3:	85 c0                	test   %eax,%eax
f01017d5:	0f 85 9f 07 00 00    	jne    f0101f7a <mem_init+0xd83>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01017db:	83 ec 04             	sub    $0x4,%esp
f01017de:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01017e1:	50                   	push   %eax
f01017e2:	6a 00                	push   $0x0
f01017e4:	ff 35 68 89 11 f0    	pushl  0xf0118968
f01017ea:	e8 f3 f8 ff ff       	call   f01010e2 <page_lookup>
f01017ef:	83 c4 10             	add    $0x10,%esp
f01017f2:	85 c0                	test   %eax,%eax
f01017f4:	0f 85 99 07 00 00    	jne    f0101f93 <mem_init+0xd9c>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01017fa:	6a 02                	push   $0x2
f01017fc:	6a 00                	push   $0x0
f01017fe:	53                   	push   %ebx
f01017ff:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101805:	e8 86 f9 ff ff       	call   f0101190 <page_insert>
f010180a:	83 c4 10             	add    $0x10,%esp
f010180d:	85 c0                	test   %eax,%eax
f010180f:	0f 89 97 07 00 00    	jns    f0101fac <mem_init+0xdb5>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101815:	83 ec 0c             	sub    $0xc,%esp
f0101818:	57                   	push   %edi
f0101819:	e8 e6 f6 ff ff       	call   f0100f04 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010181e:	6a 02                	push   $0x2
f0101820:	6a 00                	push   $0x0
f0101822:	53                   	push   %ebx
f0101823:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101829:	e8 62 f9 ff ff       	call   f0101190 <page_insert>
f010182e:	83 c4 20             	add    $0x20,%esp
f0101831:	85 c0                	test   %eax,%eax
f0101833:	0f 85 8c 07 00 00    	jne    f0101fc5 <mem_init+0xdce>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101839:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f010183e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	return (pp - pages) << PGSHIFT;
f0101841:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
f0101847:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010184a:	8b 00                	mov    (%eax),%eax
f010184c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010184f:	89 c2                	mov    %eax,%edx
f0101851:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101857:	89 f8                	mov    %edi,%eax
f0101859:	29 c8                	sub    %ecx,%eax
f010185b:	c1 f8 03             	sar    $0x3,%eax
f010185e:	c1 e0 0c             	shl    $0xc,%eax
f0101861:	39 c2                	cmp    %eax,%edx
f0101863:	0f 85 75 07 00 00    	jne    f0101fde <mem_init+0xde7>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101869:	ba 00 00 00 00       	mov    $0x0,%edx
f010186e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101871:	e8 3a f2 ff ff       	call   f0100ab0 <check_va2pa>
f0101876:	89 da                	mov    %ebx,%edx
f0101878:	2b 55 d0             	sub    -0x30(%ebp),%edx
f010187b:	c1 fa 03             	sar    $0x3,%edx
f010187e:	c1 e2 0c             	shl    $0xc,%edx
f0101881:	39 d0                	cmp    %edx,%eax
f0101883:	0f 85 6e 07 00 00    	jne    f0101ff7 <mem_init+0xe00>
	assert(pp1->pp_ref == 1);
f0101889:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010188e:	0f 85 7c 07 00 00    	jne    f0102010 <mem_init+0xe19>
	assert(pp0->pp_ref == 1);
f0101894:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101899:	0f 85 8a 07 00 00    	jne    f0102029 <mem_init+0xe32>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010189f:	6a 02                	push   $0x2
f01018a1:	68 00 10 00 00       	push   $0x1000
f01018a6:	56                   	push   %esi
f01018a7:	ff 75 d4             	pushl  -0x2c(%ebp)
f01018aa:	e8 e1 f8 ff ff       	call   f0101190 <page_insert>
f01018af:	83 c4 10             	add    $0x10,%esp
f01018b2:	85 c0                	test   %eax,%eax
f01018b4:	0f 85 88 07 00 00    	jne    f0102042 <mem_init+0xe4b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01018ba:	ba 00 10 00 00       	mov    $0x1000,%edx
f01018bf:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f01018c4:	e8 e7 f1 ff ff       	call   f0100ab0 <check_va2pa>
f01018c9:	89 f2                	mov    %esi,%edx
f01018cb:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f01018d1:	c1 fa 03             	sar    $0x3,%edx
f01018d4:	c1 e2 0c             	shl    $0xc,%edx
f01018d7:	39 d0                	cmp    %edx,%eax
f01018d9:	0f 85 7c 07 00 00    	jne    f010205b <mem_init+0xe64>
	assert(pp2->pp_ref == 1);
f01018df:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01018e4:	0f 85 8a 07 00 00    	jne    f0102074 <mem_init+0xe7d>

	// should be no free memory
	assert(!page_alloc(0));
f01018ea:	83 ec 0c             	sub    $0xc,%esp
f01018ed:	6a 00                	push   $0x0
f01018ef:	e8 9e f5 ff ff       	call   f0100e92 <page_alloc>
f01018f4:	83 c4 10             	add    $0x10,%esp
f01018f7:	85 c0                	test   %eax,%eax
f01018f9:	0f 85 8e 07 00 00    	jne    f010208d <mem_init+0xe96>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01018ff:	6a 02                	push   $0x2
f0101901:	68 00 10 00 00       	push   $0x1000
f0101906:	56                   	push   %esi
f0101907:	ff 35 68 89 11 f0    	pushl  0xf0118968
f010190d:	e8 7e f8 ff ff       	call   f0101190 <page_insert>
f0101912:	83 c4 10             	add    $0x10,%esp
f0101915:	85 c0                	test   %eax,%eax
f0101917:	0f 85 89 07 00 00    	jne    f01020a6 <mem_init+0xeaf>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010191d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101922:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101927:	e8 84 f1 ff ff       	call   f0100ab0 <check_va2pa>
f010192c:	89 f2                	mov    %esi,%edx
f010192e:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f0101934:	c1 fa 03             	sar    $0x3,%edx
f0101937:	c1 e2 0c             	shl    $0xc,%edx
f010193a:	39 d0                	cmp    %edx,%eax
f010193c:	0f 85 7d 07 00 00    	jne    f01020bf <mem_init+0xec8>
	assert(pp2->pp_ref == 1);
f0101942:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101947:	0f 85 8b 07 00 00    	jne    f01020d8 <mem_init+0xee1>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f010194d:	83 ec 0c             	sub    $0xc,%esp
f0101950:	6a 00                	push   $0x0
f0101952:	e8 3b f5 ff ff       	call   f0100e92 <page_alloc>
f0101957:	83 c4 10             	add    $0x10,%esp
f010195a:	85 c0                	test   %eax,%eax
f010195c:	0f 85 8f 07 00 00    	jne    f01020f1 <mem_init+0xefa>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101962:	8b 15 68 89 11 f0    	mov    0xf0118968,%edx
f0101968:	8b 02                	mov    (%edx),%eax
f010196a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f010196f:	89 c1                	mov    %eax,%ecx
f0101971:	c1 e9 0c             	shr    $0xc,%ecx
f0101974:	3b 0d 64 89 11 f0    	cmp    0xf0118964,%ecx
f010197a:	0f 83 8a 07 00 00    	jae    f010210a <mem_init+0xf13>
	return (void *)(pa + KERNBASE);
f0101980:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101985:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101988:	83 ec 04             	sub    $0x4,%esp
f010198b:	6a 00                	push   $0x0
f010198d:	68 00 10 00 00       	push   $0x1000
f0101992:	52                   	push   %edx
f0101993:	e8 e4 f5 ff ff       	call   f0100f7c <pgdir_walk>
f0101998:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010199b:	8d 51 04             	lea    0x4(%ecx),%edx
f010199e:	83 c4 10             	add    $0x10,%esp
f01019a1:	39 d0                	cmp    %edx,%eax
f01019a3:	0f 85 76 07 00 00    	jne    f010211f <mem_init+0xf28>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01019a9:	6a 06                	push   $0x6
f01019ab:	68 00 10 00 00       	push   $0x1000
f01019b0:	56                   	push   %esi
f01019b1:	ff 35 68 89 11 f0    	pushl  0xf0118968
f01019b7:	e8 d4 f7 ff ff       	call   f0101190 <page_insert>
f01019bc:	83 c4 10             	add    $0x10,%esp
f01019bf:	85 c0                	test   %eax,%eax
f01019c1:	0f 85 71 07 00 00    	jne    f0102138 <mem_init+0xf41>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019c7:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f01019cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019cf:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019d4:	e8 d7 f0 ff ff       	call   f0100ab0 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f01019d9:	89 f2                	mov    %esi,%edx
f01019db:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f01019e1:	c1 fa 03             	sar    $0x3,%edx
f01019e4:	c1 e2 0c             	shl    $0xc,%edx
f01019e7:	39 d0                	cmp    %edx,%eax
f01019e9:	0f 85 62 07 00 00    	jne    f0102151 <mem_init+0xf5a>
	assert(pp2->pp_ref == 1);
f01019ef:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01019f4:	0f 85 70 07 00 00    	jne    f010216a <mem_init+0xf73>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01019fa:	83 ec 04             	sub    $0x4,%esp
f01019fd:	6a 00                	push   $0x0
f01019ff:	68 00 10 00 00       	push   $0x1000
f0101a04:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a07:	e8 70 f5 ff ff       	call   f0100f7c <pgdir_walk>
f0101a0c:	83 c4 10             	add    $0x10,%esp
f0101a0f:	f6 00 04             	testb  $0x4,(%eax)
f0101a12:	0f 84 6b 07 00 00    	je     f0102183 <mem_init+0xf8c>
	assert(kern_pgdir[0] & PTE_U);
f0101a18:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101a1d:	f6 00 04             	testb  $0x4,(%eax)
f0101a20:	0f 84 76 07 00 00    	je     f010219c <mem_init+0xfa5>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a26:	6a 02                	push   $0x2
f0101a28:	68 00 10 00 00       	push   $0x1000
f0101a2d:	56                   	push   %esi
f0101a2e:	50                   	push   %eax
f0101a2f:	e8 5c f7 ff ff       	call   f0101190 <page_insert>
f0101a34:	83 c4 10             	add    $0x10,%esp
f0101a37:	85 c0                	test   %eax,%eax
f0101a39:	0f 85 76 07 00 00    	jne    f01021b5 <mem_init+0xfbe>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101a3f:	83 ec 04             	sub    $0x4,%esp
f0101a42:	6a 00                	push   $0x0
f0101a44:	68 00 10 00 00       	push   $0x1000
f0101a49:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101a4f:	e8 28 f5 ff ff       	call   f0100f7c <pgdir_walk>
f0101a54:	83 c4 10             	add    $0x10,%esp
f0101a57:	f6 00 02             	testb  $0x2,(%eax)
f0101a5a:	0f 84 6e 07 00 00    	je     f01021ce <mem_init+0xfd7>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101a60:	83 ec 04             	sub    $0x4,%esp
f0101a63:	6a 00                	push   $0x0
f0101a65:	68 00 10 00 00       	push   $0x1000
f0101a6a:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101a70:	e8 07 f5 ff ff       	call   f0100f7c <pgdir_walk>
f0101a75:	83 c4 10             	add    $0x10,%esp
f0101a78:	f6 00 04             	testb  $0x4,(%eax)
f0101a7b:	0f 85 66 07 00 00    	jne    f01021e7 <mem_init+0xff0>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101a81:	6a 02                	push   $0x2
f0101a83:	68 00 00 40 00       	push   $0x400000
f0101a88:	57                   	push   %edi
f0101a89:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101a8f:	e8 fc f6 ff ff       	call   f0101190 <page_insert>
f0101a94:	83 c4 10             	add    $0x10,%esp
f0101a97:	85 c0                	test   %eax,%eax
f0101a99:	0f 89 61 07 00 00    	jns    f0102200 <mem_init+0x1009>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101a9f:	6a 02                	push   $0x2
f0101aa1:	68 00 10 00 00       	push   $0x1000
f0101aa6:	53                   	push   %ebx
f0101aa7:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101aad:	e8 de f6 ff ff       	call   f0101190 <page_insert>
f0101ab2:	83 c4 10             	add    $0x10,%esp
f0101ab5:	85 c0                	test   %eax,%eax
f0101ab7:	0f 85 5c 07 00 00    	jne    f0102219 <mem_init+0x1022>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101abd:	83 ec 04             	sub    $0x4,%esp
f0101ac0:	6a 00                	push   $0x0
f0101ac2:	68 00 10 00 00       	push   $0x1000
f0101ac7:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101acd:	e8 aa f4 ff ff       	call   f0100f7c <pgdir_walk>
f0101ad2:	83 c4 10             	add    $0x10,%esp
f0101ad5:	f6 00 04             	testb  $0x4,(%eax)
f0101ad8:	0f 85 54 07 00 00    	jne    f0102232 <mem_init+0x103b>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101ade:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101ae3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101ae6:	ba 00 00 00 00       	mov    $0x0,%edx
f0101aeb:	e8 c0 ef ff ff       	call   f0100ab0 <check_va2pa>
f0101af0:	89 c1                	mov    %eax,%ecx
f0101af2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101af5:	89 d8                	mov    %ebx,%eax
f0101af7:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0101afd:	c1 f8 03             	sar    $0x3,%eax
f0101b00:	c1 e0 0c             	shl    $0xc,%eax
f0101b03:	39 c1                	cmp    %eax,%ecx
f0101b05:	0f 85 40 07 00 00    	jne    f010224b <mem_init+0x1054>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101b0b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b10:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b13:	e8 98 ef ff ff       	call   f0100ab0 <check_va2pa>
f0101b18:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101b1b:	0f 85 43 07 00 00    	jne    f0102264 <mem_init+0x106d>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101b21:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101b26:	0f 85 51 07 00 00    	jne    f010227d <mem_init+0x1086>
	assert(pp2->pp_ref == 0);
f0101b2c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101b31:	0f 85 5f 07 00 00    	jne    f0102296 <mem_init+0x109f>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101b37:	83 ec 0c             	sub    $0xc,%esp
f0101b3a:	6a 00                	push   $0x0
f0101b3c:	e8 51 f3 ff ff       	call   f0100e92 <page_alloc>
f0101b41:	83 c4 10             	add    $0x10,%esp
f0101b44:	85 c0                	test   %eax,%eax
f0101b46:	0f 84 63 07 00 00    	je     f01022af <mem_init+0x10b8>
f0101b4c:	39 c6                	cmp    %eax,%esi
f0101b4e:	0f 85 5b 07 00 00    	jne    f01022af <mem_init+0x10b8>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101b54:	83 ec 08             	sub    $0x8,%esp
f0101b57:	6a 00                	push   $0x0
f0101b59:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101b5f:	e8 e4 f5 ff ff       	call   f0101148 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101b64:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101b69:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101b6c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b71:	e8 3a ef ff ff       	call   f0100ab0 <check_va2pa>
f0101b76:	83 c4 10             	add    $0x10,%esp
f0101b79:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101b7c:	0f 85 46 07 00 00    	jne    f01022c8 <mem_init+0x10d1>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101b82:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b87:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b8a:	e8 21 ef ff ff       	call   f0100ab0 <check_va2pa>
f0101b8f:	89 da                	mov    %ebx,%edx
f0101b91:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f0101b97:	c1 fa 03             	sar    $0x3,%edx
f0101b9a:	c1 e2 0c             	shl    $0xc,%edx
f0101b9d:	39 d0                	cmp    %edx,%eax
f0101b9f:	0f 85 3c 07 00 00    	jne    f01022e1 <mem_init+0x10ea>
	assert(pp1->pp_ref == 1);
f0101ba5:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101baa:	0f 85 4a 07 00 00    	jne    f01022fa <mem_init+0x1103>
	assert(pp2->pp_ref == 0);
f0101bb0:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101bb5:	0f 85 58 07 00 00    	jne    f0102313 <mem_init+0x111c>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101bbb:	6a 00                	push   $0x0
f0101bbd:	68 00 10 00 00       	push   $0x1000
f0101bc2:	53                   	push   %ebx
f0101bc3:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101bc6:	e8 c5 f5 ff ff       	call   f0101190 <page_insert>
f0101bcb:	83 c4 10             	add    $0x10,%esp
f0101bce:	85 c0                	test   %eax,%eax
f0101bd0:	0f 85 56 07 00 00    	jne    f010232c <mem_init+0x1135>
	assert(pp1->pp_ref);
f0101bd6:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101bdb:	0f 84 64 07 00 00    	je     f0102345 <mem_init+0x114e>
	assert(pp1->pp_link == NULL);
f0101be1:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101be4:	0f 85 74 07 00 00    	jne    f010235e <mem_init+0x1167>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101bea:	83 ec 08             	sub    $0x8,%esp
f0101bed:	68 00 10 00 00       	push   $0x1000
f0101bf2:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101bf8:	e8 4b f5 ff ff       	call   f0101148 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101bfd:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101c02:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101c05:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c0a:	e8 a1 ee ff ff       	call   f0100ab0 <check_va2pa>
f0101c0f:	83 c4 10             	add    $0x10,%esp
f0101c12:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101c15:	0f 85 5c 07 00 00    	jne    f0102377 <mem_init+0x1180>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101c1b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c20:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c23:	e8 88 ee ff ff       	call   f0100ab0 <check_va2pa>
f0101c28:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101c2b:	0f 85 5f 07 00 00    	jne    f0102390 <mem_init+0x1199>
	assert(pp1->pp_ref == 0);
f0101c31:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101c36:	0f 85 6d 07 00 00    	jne    f01023a9 <mem_init+0x11b2>
	assert(pp2->pp_ref == 0);
f0101c3c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101c41:	0f 85 7b 07 00 00    	jne    f01023c2 <mem_init+0x11cb>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101c47:	83 ec 0c             	sub    $0xc,%esp
f0101c4a:	6a 00                	push   $0x0
f0101c4c:	e8 41 f2 ff ff       	call   f0100e92 <page_alloc>
f0101c51:	83 c4 10             	add    $0x10,%esp
f0101c54:	85 c0                	test   %eax,%eax
f0101c56:	0f 84 7f 07 00 00    	je     f01023db <mem_init+0x11e4>
f0101c5c:	39 c3                	cmp    %eax,%ebx
f0101c5e:	0f 85 77 07 00 00    	jne    f01023db <mem_init+0x11e4>

	// should be no free memory
	assert(!page_alloc(0));
f0101c64:	83 ec 0c             	sub    $0xc,%esp
f0101c67:	6a 00                	push   $0x0
f0101c69:	e8 24 f2 ff ff       	call   f0100e92 <page_alloc>
f0101c6e:	83 c4 10             	add    $0x10,%esp
f0101c71:	85 c0                	test   %eax,%eax
f0101c73:	0f 85 7b 07 00 00    	jne    f01023f4 <mem_init+0x11fd>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101c79:	8b 0d 68 89 11 f0    	mov    0xf0118968,%ecx
f0101c7f:	8b 11                	mov    (%ecx),%edx
f0101c81:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101c87:	89 f8                	mov    %edi,%eax
f0101c89:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0101c8f:	c1 f8 03             	sar    $0x3,%eax
f0101c92:	c1 e0 0c             	shl    $0xc,%eax
f0101c95:	39 c2                	cmp    %eax,%edx
f0101c97:	0f 85 70 07 00 00    	jne    f010240d <mem_init+0x1216>
	kern_pgdir[0] = 0;
f0101c9d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101ca3:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101ca8:	0f 85 78 07 00 00    	jne    f0102426 <mem_init+0x122f>
	pp0->pp_ref = 0;
f0101cae:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101cb4:	83 ec 0c             	sub    $0xc,%esp
f0101cb7:	57                   	push   %edi
f0101cb8:	e8 47 f2 ff ff       	call   f0100f04 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101cbd:	83 c4 0c             	add    $0xc,%esp
f0101cc0:	6a 01                	push   $0x1
f0101cc2:	68 00 10 40 00       	push   $0x401000
f0101cc7:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101ccd:	e8 aa f2 ff ff       	call   f0100f7c <pgdir_walk>
f0101cd2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101cd5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101cd8:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101cdd:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101ce0:	8b 50 04             	mov    0x4(%eax),%edx
f0101ce3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101ce9:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0101cee:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101cf1:	89 d1                	mov    %edx,%ecx
f0101cf3:	c1 e9 0c             	shr    $0xc,%ecx
f0101cf6:	83 c4 10             	add    $0x10,%esp
f0101cf9:	39 c1                	cmp    %eax,%ecx
f0101cfb:	0f 83 3e 07 00 00    	jae    f010243f <mem_init+0x1248>
	assert(ptep == ptep1 + PTX(va));
f0101d01:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0101d07:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0101d0a:	0f 85 44 07 00 00    	jne    f0102454 <mem_init+0x125d>
	kern_pgdir[PDX(va)] = 0;
f0101d10:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101d13:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101d1a:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
	return (pp - pages) << PGSHIFT;
f0101d20:	89 f8                	mov    %edi,%eax
f0101d22:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0101d28:	c1 f8 03             	sar    $0x3,%eax
f0101d2b:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101d2e:	89 c2                	mov    %eax,%edx
f0101d30:	c1 ea 0c             	shr    $0xc,%edx
f0101d33:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f0101d36:	0f 86 31 07 00 00    	jbe    f010246d <mem_init+0x1276>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101d3c:	83 ec 04             	sub    $0x4,%esp
f0101d3f:	68 00 10 00 00       	push   $0x1000
f0101d44:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101d49:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101d4e:	50                   	push   %eax
f0101d4f:	e8 44 18 00 00       	call   f0103598 <memset>
	page_free(pp0);
f0101d54:	89 3c 24             	mov    %edi,(%esp)
f0101d57:	e8 a8 f1 ff ff       	call   f0100f04 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101d5c:	83 c4 0c             	add    $0xc,%esp
f0101d5f:	6a 01                	push   $0x1
f0101d61:	6a 00                	push   $0x0
f0101d63:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101d69:	e8 0e f2 ff ff       	call   f0100f7c <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101d6e:	89 fa                	mov    %edi,%edx
f0101d70:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f0101d76:	c1 fa 03             	sar    $0x3,%edx
f0101d79:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101d7c:	89 d0                	mov    %edx,%eax
f0101d7e:	c1 e8 0c             	shr    $0xc,%eax
f0101d81:	83 c4 10             	add    $0x10,%esp
f0101d84:	3b 05 64 89 11 f0    	cmp    0xf0118964,%eax
f0101d8a:	0f 83 ef 06 00 00    	jae    f010247f <mem_init+0x1288>
	return (void *)(pa + KERNBASE);
f0101d90:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101d96:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101d99:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101d9f:	f6 00 01             	testb  $0x1,(%eax)
f0101da2:	0f 85 e9 06 00 00    	jne    f0102491 <mem_init+0x129a>
f0101da8:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0101dab:	39 c2                	cmp    %eax,%edx
f0101dad:	75 f0                	jne    f0101d9f <mem_init+0xba8>
	kern_pgdir[0] = 0;
f0101daf:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101db4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101dba:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0101dc0:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0101dc3:	a3 3c 85 11 f0       	mov    %eax,0xf011853c

	// free the pages we took
	page_free(pp0);
f0101dc8:	83 ec 0c             	sub    $0xc,%esp
f0101dcb:	57                   	push   %edi
f0101dcc:	e8 33 f1 ff ff       	call   f0100f04 <page_free>
	page_free(pp1);
f0101dd1:	89 1c 24             	mov    %ebx,(%esp)
f0101dd4:	e8 2b f1 ff ff       	call   f0100f04 <page_free>
	page_free(pp2);
f0101dd9:	89 34 24             	mov    %esi,(%esp)
f0101ddc:	e8 23 f1 ff ff       	call   f0100f04 <page_free>

	cprintf("check_page() succeeded!\n");
f0101de1:	c7 04 24 81 4b 10 f0 	movl   $0xf0104b81,(%esp)
f0101de8:	e8 7c 0c 00 00       	call   f0102a69 <cprintf>
	sz = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0101ded:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0101df2:	8d 0c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ecx
f0101df9:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_region(kern_pgdir, UPAGES, sz, PADDR(pages), PTE_U | PTE_P);
f0101dff:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
	if ((uint32_t)kva < KERNBASE)
f0101e04:	83 c4 10             	add    $0x10,%esp
f0101e07:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101e0c:	0f 86 98 06 00 00    	jbe    f01024aa <mem_init+0x12b3>
f0101e12:	83 ec 08             	sub    $0x8,%esp
f0101e15:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0101e17:	05 00 00 00 10       	add    $0x10000000,%eax
f0101e1c:	50                   	push   %eax
f0101e1d:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0101e22:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101e27:	e8 67 f2 ff ff       	call   f0101093 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0101e2c:	83 c4 10             	add    $0x10,%esp
f0101e2f:	b8 00 e0 10 f0       	mov    $0xf010e000,%eax
f0101e34:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101e39:	0f 86 80 06 00 00    	jbe    f01024bf <mem_init+0x12c8>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, 
f0101e3f:	83 ec 08             	sub    $0x8,%esp
f0101e42:	6a 03                	push   $0x3
f0101e44:	68 00 e0 10 00       	push   $0x10e000
f0101e49:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0101e4e:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0101e53:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101e58:	e8 36 f2 ff ff       	call   f0101093 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 1 << 28, // 2^32 - 0xf0000000
f0101e5d:	83 c4 08             	add    $0x8,%esp
f0101e60:	6a 03                	push   $0x3
f0101e62:	6a 00                	push   $0x0
f0101e64:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0101e69:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0101e6e:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101e73:	e8 1b f2 ff ff       	call   f0101093 <boot_map_region>
	pgdir = kern_pgdir;
f0101e78:	8b 1d 68 89 11 f0    	mov    0xf0118968,%ebx
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0101e7e:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0101e83:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101e86:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0101e8d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101e92:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101e95:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101e9a:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101e9d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0101ea0:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f0101ea6:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i += PGSIZE) 
f0101ea9:	be 00 00 00 00       	mov    $0x0,%esi
f0101eae:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0101eb1:	0f 86 4d 06 00 00    	jbe    f0102504 <mem_init+0x130d>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101eb7:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f0101ebd:	89 d8                	mov    %ebx,%eax
f0101ebf:	e8 ec eb ff ff       	call   f0100ab0 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0101ec4:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0101ecb:	0f 86 03 06 00 00    	jbe    f01024d4 <mem_init+0x12dd>
f0101ed1:	8d 14 3e             	lea    (%esi,%edi,1),%edx
f0101ed4:	39 d0                	cmp    %edx,%eax
f0101ed6:	0f 85 0f 06 00 00    	jne    f01024eb <mem_init+0x12f4>
	for (i = 0; i < n; i += PGSIZE) 
f0101edc:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101ee2:	eb ca                	jmp    f0101eae <mem_init+0xcb7>
	assert(nfree == 0);
f0101ee4:	68 aa 4a 10 f0       	push   $0xf0104aaa
f0101ee9:	68 e2 48 10 f0       	push   $0xf01048e2
f0101eee:	68 7c 02 00 00       	push   $0x27c
f0101ef3:	68 bc 48 10 f0       	push   $0xf01048bc
f0101ef8:	e8 36 e2 ff ff       	call   f0100133 <_panic>
	assert((pp0 = page_alloc(0)));
f0101efd:	68 b8 49 10 f0       	push   $0xf01049b8
f0101f02:	68 e2 48 10 f0       	push   $0xf01048e2
f0101f07:	68 d6 02 00 00       	push   $0x2d6
f0101f0c:	68 bc 48 10 f0       	push   $0xf01048bc
f0101f11:	e8 1d e2 ff ff       	call   f0100133 <_panic>
	assert((pp1 = page_alloc(0)));
f0101f16:	68 ce 49 10 f0       	push   $0xf01049ce
f0101f1b:	68 e2 48 10 f0       	push   $0xf01048e2
f0101f20:	68 d7 02 00 00       	push   $0x2d7
f0101f25:	68 bc 48 10 f0       	push   $0xf01048bc
f0101f2a:	e8 04 e2 ff ff       	call   f0100133 <_panic>
	assert((pp2 = page_alloc(0)));
f0101f2f:	68 e4 49 10 f0       	push   $0xf01049e4
f0101f34:	68 e2 48 10 f0       	push   $0xf01048e2
f0101f39:	68 d8 02 00 00       	push   $0x2d8
f0101f3e:	68 bc 48 10 f0       	push   $0xf01048bc
f0101f43:	e8 eb e1 ff ff       	call   f0100133 <_panic>
	assert(pp1 && pp1 != pp0);
f0101f48:	68 fa 49 10 f0       	push   $0xf01049fa
f0101f4d:	68 e2 48 10 f0       	push   $0xf01048e2
f0101f52:	68 db 02 00 00       	push   $0x2db
f0101f57:	68 bc 48 10 f0       	push   $0xf01048bc
f0101f5c:	e8 d2 e1 ff ff       	call   f0100133 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101f61:	68 d0 42 10 f0       	push   $0xf01042d0
f0101f66:	68 e2 48 10 f0       	push   $0xf01048e2
f0101f6b:	68 dc 02 00 00       	push   $0x2dc
f0101f70:	68 bc 48 10 f0       	push   $0xf01048bc
f0101f75:	e8 b9 e1 ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f0101f7a:	68 63 4a 10 f0       	push   $0xf0104a63
f0101f7f:	68 e2 48 10 f0       	push   $0xf01048e2
f0101f84:	68 e3 02 00 00       	push   $0x2e3
f0101f89:	68 bc 48 10 f0       	push   $0xf01048bc
f0101f8e:	e8 a0 e1 ff ff       	call   f0100133 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101f93:	68 10 43 10 f0       	push   $0xf0104310
f0101f98:	68 e2 48 10 f0       	push   $0xf01048e2
f0101f9d:	68 e6 02 00 00       	push   $0x2e6
f0101fa2:	68 bc 48 10 f0       	push   $0xf01048bc
f0101fa7:	e8 87 e1 ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101fac:	68 48 43 10 f0       	push   $0xf0104348
f0101fb1:	68 e2 48 10 f0       	push   $0xf01048e2
f0101fb6:	68 e9 02 00 00       	push   $0x2e9
f0101fbb:	68 bc 48 10 f0       	push   $0xf01048bc
f0101fc0:	e8 6e e1 ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101fc5:	68 78 43 10 f0       	push   $0xf0104378
f0101fca:	68 e2 48 10 f0       	push   $0xf01048e2
f0101fcf:	68 ed 02 00 00       	push   $0x2ed
f0101fd4:	68 bc 48 10 f0       	push   $0xf01048bc
f0101fd9:	e8 55 e1 ff ff       	call   f0100133 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101fde:	68 a8 43 10 f0       	push   $0xf01043a8
f0101fe3:	68 e2 48 10 f0       	push   $0xf01048e2
f0101fe8:	68 ee 02 00 00       	push   $0x2ee
f0101fed:	68 bc 48 10 f0       	push   $0xf01048bc
f0101ff2:	e8 3c e1 ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101ff7:	68 d0 43 10 f0       	push   $0xf01043d0
f0101ffc:	68 e2 48 10 f0       	push   $0xf01048e2
f0102001:	68 ef 02 00 00       	push   $0x2ef
f0102006:	68 bc 48 10 f0       	push   $0xf01048bc
f010200b:	e8 23 e1 ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 1);
f0102010:	68 b5 4a 10 f0       	push   $0xf0104ab5
f0102015:	68 e2 48 10 f0       	push   $0xf01048e2
f010201a:	68 f0 02 00 00       	push   $0x2f0
f010201f:	68 bc 48 10 f0       	push   $0xf01048bc
f0102024:	e8 0a e1 ff ff       	call   f0100133 <_panic>
	assert(pp0->pp_ref == 1);
f0102029:	68 c6 4a 10 f0       	push   $0xf0104ac6
f010202e:	68 e2 48 10 f0       	push   $0xf01048e2
f0102033:	68 f1 02 00 00       	push   $0x2f1
f0102038:	68 bc 48 10 f0       	push   $0xf01048bc
f010203d:	e8 f1 e0 ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102042:	68 00 44 10 f0       	push   $0xf0104400
f0102047:	68 e2 48 10 f0       	push   $0xf01048e2
f010204c:	68 f4 02 00 00       	push   $0x2f4
f0102051:	68 bc 48 10 f0       	push   $0xf01048bc
f0102056:	e8 d8 e0 ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010205b:	68 3c 44 10 f0       	push   $0xf010443c
f0102060:	68 e2 48 10 f0       	push   $0xf01048e2
f0102065:	68 f5 02 00 00       	push   $0x2f5
f010206a:	68 bc 48 10 f0       	push   $0xf01048bc
f010206f:	e8 bf e0 ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 1);
f0102074:	68 d7 4a 10 f0       	push   $0xf0104ad7
f0102079:	68 e2 48 10 f0       	push   $0xf01048e2
f010207e:	68 f6 02 00 00       	push   $0x2f6
f0102083:	68 bc 48 10 f0       	push   $0xf01048bc
f0102088:	e8 a6 e0 ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f010208d:	68 63 4a 10 f0       	push   $0xf0104a63
f0102092:	68 e2 48 10 f0       	push   $0xf01048e2
f0102097:	68 f9 02 00 00       	push   $0x2f9
f010209c:	68 bc 48 10 f0       	push   $0xf01048bc
f01020a1:	e8 8d e0 ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01020a6:	68 00 44 10 f0       	push   $0xf0104400
f01020ab:	68 e2 48 10 f0       	push   $0xf01048e2
f01020b0:	68 fc 02 00 00       	push   $0x2fc
f01020b5:	68 bc 48 10 f0       	push   $0xf01048bc
f01020ba:	e8 74 e0 ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01020bf:	68 3c 44 10 f0       	push   $0xf010443c
f01020c4:	68 e2 48 10 f0       	push   $0xf01048e2
f01020c9:	68 fd 02 00 00       	push   $0x2fd
f01020ce:	68 bc 48 10 f0       	push   $0xf01048bc
f01020d3:	e8 5b e0 ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 1);
f01020d8:	68 d7 4a 10 f0       	push   $0xf0104ad7
f01020dd:	68 e2 48 10 f0       	push   $0xf01048e2
f01020e2:	68 fe 02 00 00       	push   $0x2fe
f01020e7:	68 bc 48 10 f0       	push   $0xf01048bc
f01020ec:	e8 42 e0 ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f01020f1:	68 63 4a 10 f0       	push   $0xf0104a63
f01020f6:	68 e2 48 10 f0       	push   $0xf01048e2
f01020fb:	68 02 03 00 00       	push   $0x302
f0102100:	68 bc 48 10 f0       	push   $0xf01048bc
f0102105:	e8 29 e0 ff ff       	call   f0100133 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010210a:	50                   	push   %eax
f010210b:	68 44 41 10 f0       	push   $0xf0104144
f0102110:	68 05 03 00 00       	push   $0x305
f0102115:	68 bc 48 10 f0       	push   $0xf01048bc
f010211a:	e8 14 e0 ff ff       	call   f0100133 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010211f:	68 6c 44 10 f0       	push   $0xf010446c
f0102124:	68 e2 48 10 f0       	push   $0xf01048e2
f0102129:	68 06 03 00 00       	push   $0x306
f010212e:	68 bc 48 10 f0       	push   $0xf01048bc
f0102133:	e8 fb df ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102138:	68 ac 44 10 f0       	push   $0xf01044ac
f010213d:	68 e2 48 10 f0       	push   $0xf01048e2
f0102142:	68 09 03 00 00       	push   $0x309
f0102147:	68 bc 48 10 f0       	push   $0xf01048bc
f010214c:	e8 e2 df ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102151:	68 3c 44 10 f0       	push   $0xf010443c
f0102156:	68 e2 48 10 f0       	push   $0xf01048e2
f010215b:	68 0a 03 00 00       	push   $0x30a
f0102160:	68 bc 48 10 f0       	push   $0xf01048bc
f0102165:	e8 c9 df ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 1);
f010216a:	68 d7 4a 10 f0       	push   $0xf0104ad7
f010216f:	68 e2 48 10 f0       	push   $0xf01048e2
f0102174:	68 0b 03 00 00       	push   $0x30b
f0102179:	68 bc 48 10 f0       	push   $0xf01048bc
f010217e:	e8 b0 df ff ff       	call   f0100133 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102183:	68 ec 44 10 f0       	push   $0xf01044ec
f0102188:	68 e2 48 10 f0       	push   $0xf01048e2
f010218d:	68 0c 03 00 00       	push   $0x30c
f0102192:	68 bc 48 10 f0       	push   $0xf01048bc
f0102197:	e8 97 df ff ff       	call   f0100133 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010219c:	68 e8 4a 10 f0       	push   $0xf0104ae8
f01021a1:	68 e2 48 10 f0       	push   $0xf01048e2
f01021a6:	68 0d 03 00 00       	push   $0x30d
f01021ab:	68 bc 48 10 f0       	push   $0xf01048bc
f01021b0:	e8 7e df ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01021b5:	68 00 44 10 f0       	push   $0xf0104400
f01021ba:	68 e2 48 10 f0       	push   $0xf01048e2
f01021bf:	68 10 03 00 00       	push   $0x310
f01021c4:	68 bc 48 10 f0       	push   $0xf01048bc
f01021c9:	e8 65 df ff ff       	call   f0100133 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01021ce:	68 20 45 10 f0       	push   $0xf0104520
f01021d3:	68 e2 48 10 f0       	push   $0xf01048e2
f01021d8:	68 11 03 00 00       	push   $0x311
f01021dd:	68 bc 48 10 f0       	push   $0xf01048bc
f01021e2:	e8 4c df ff ff       	call   f0100133 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01021e7:	68 54 45 10 f0       	push   $0xf0104554
f01021ec:	68 e2 48 10 f0       	push   $0xf01048e2
f01021f1:	68 12 03 00 00       	push   $0x312
f01021f6:	68 bc 48 10 f0       	push   $0xf01048bc
f01021fb:	e8 33 df ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102200:	68 8c 45 10 f0       	push   $0xf010458c
f0102205:	68 e2 48 10 f0       	push   $0xf01048e2
f010220a:	68 15 03 00 00       	push   $0x315
f010220f:	68 bc 48 10 f0       	push   $0xf01048bc
f0102214:	e8 1a df ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102219:	68 c4 45 10 f0       	push   $0xf01045c4
f010221e:	68 e2 48 10 f0       	push   $0xf01048e2
f0102223:	68 18 03 00 00       	push   $0x318
f0102228:	68 bc 48 10 f0       	push   $0xf01048bc
f010222d:	e8 01 df ff ff       	call   f0100133 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102232:	68 54 45 10 f0       	push   $0xf0104554
f0102237:	68 e2 48 10 f0       	push   $0xf01048e2
f010223c:	68 19 03 00 00       	push   $0x319
f0102241:	68 bc 48 10 f0       	push   $0xf01048bc
f0102246:	e8 e8 de ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010224b:	68 00 46 10 f0       	push   $0xf0104600
f0102250:	68 e2 48 10 f0       	push   $0xf01048e2
f0102255:	68 1c 03 00 00       	push   $0x31c
f010225a:	68 bc 48 10 f0       	push   $0xf01048bc
f010225f:	e8 cf de ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102264:	68 2c 46 10 f0       	push   $0xf010462c
f0102269:	68 e2 48 10 f0       	push   $0xf01048e2
f010226e:	68 1d 03 00 00       	push   $0x31d
f0102273:	68 bc 48 10 f0       	push   $0xf01048bc
f0102278:	e8 b6 de ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 2);
f010227d:	68 fe 4a 10 f0       	push   $0xf0104afe
f0102282:	68 e2 48 10 f0       	push   $0xf01048e2
f0102287:	68 1f 03 00 00       	push   $0x31f
f010228c:	68 bc 48 10 f0       	push   $0xf01048bc
f0102291:	e8 9d de ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 0);
f0102296:	68 0f 4b 10 f0       	push   $0xf0104b0f
f010229b:	68 e2 48 10 f0       	push   $0xf01048e2
f01022a0:	68 20 03 00 00       	push   $0x320
f01022a5:	68 bc 48 10 f0       	push   $0xf01048bc
f01022aa:	e8 84 de ff ff       	call   f0100133 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01022af:	68 5c 46 10 f0       	push   $0xf010465c
f01022b4:	68 e2 48 10 f0       	push   $0xf01048e2
f01022b9:	68 23 03 00 00       	push   $0x323
f01022be:	68 bc 48 10 f0       	push   $0xf01048bc
f01022c3:	e8 6b de ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01022c8:	68 80 46 10 f0       	push   $0xf0104680
f01022cd:	68 e2 48 10 f0       	push   $0xf01048e2
f01022d2:	68 27 03 00 00       	push   $0x327
f01022d7:	68 bc 48 10 f0       	push   $0xf01048bc
f01022dc:	e8 52 de ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01022e1:	68 2c 46 10 f0       	push   $0xf010462c
f01022e6:	68 e2 48 10 f0       	push   $0xf01048e2
f01022eb:	68 28 03 00 00       	push   $0x328
f01022f0:	68 bc 48 10 f0       	push   $0xf01048bc
f01022f5:	e8 39 de ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 1);
f01022fa:	68 b5 4a 10 f0       	push   $0xf0104ab5
f01022ff:	68 e2 48 10 f0       	push   $0xf01048e2
f0102304:	68 29 03 00 00       	push   $0x329
f0102309:	68 bc 48 10 f0       	push   $0xf01048bc
f010230e:	e8 20 de ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 0);
f0102313:	68 0f 4b 10 f0       	push   $0xf0104b0f
f0102318:	68 e2 48 10 f0       	push   $0xf01048e2
f010231d:	68 2a 03 00 00       	push   $0x32a
f0102322:	68 bc 48 10 f0       	push   $0xf01048bc
f0102327:	e8 07 de ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010232c:	68 a4 46 10 f0       	push   $0xf01046a4
f0102331:	68 e2 48 10 f0       	push   $0xf01048e2
f0102336:	68 2d 03 00 00       	push   $0x32d
f010233b:	68 bc 48 10 f0       	push   $0xf01048bc
f0102340:	e8 ee dd ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref);
f0102345:	68 20 4b 10 f0       	push   $0xf0104b20
f010234a:	68 e2 48 10 f0       	push   $0xf01048e2
f010234f:	68 2e 03 00 00       	push   $0x32e
f0102354:	68 bc 48 10 f0       	push   $0xf01048bc
f0102359:	e8 d5 dd ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_link == NULL);
f010235e:	68 2c 4b 10 f0       	push   $0xf0104b2c
f0102363:	68 e2 48 10 f0       	push   $0xf01048e2
f0102368:	68 2f 03 00 00       	push   $0x32f
f010236d:	68 bc 48 10 f0       	push   $0xf01048bc
f0102372:	e8 bc dd ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102377:	68 80 46 10 f0       	push   $0xf0104680
f010237c:	68 e2 48 10 f0       	push   $0xf01048e2
f0102381:	68 33 03 00 00       	push   $0x333
f0102386:	68 bc 48 10 f0       	push   $0xf01048bc
f010238b:	e8 a3 dd ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102390:	68 dc 46 10 f0       	push   $0xf01046dc
f0102395:	68 e2 48 10 f0       	push   $0xf01048e2
f010239a:	68 34 03 00 00       	push   $0x334
f010239f:	68 bc 48 10 f0       	push   $0xf01048bc
f01023a4:	e8 8a dd ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 0);
f01023a9:	68 41 4b 10 f0       	push   $0xf0104b41
f01023ae:	68 e2 48 10 f0       	push   $0xf01048e2
f01023b3:	68 35 03 00 00       	push   $0x335
f01023b8:	68 bc 48 10 f0       	push   $0xf01048bc
f01023bd:	e8 71 dd ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 0);
f01023c2:	68 0f 4b 10 f0       	push   $0xf0104b0f
f01023c7:	68 e2 48 10 f0       	push   $0xf01048e2
f01023cc:	68 36 03 00 00       	push   $0x336
f01023d1:	68 bc 48 10 f0       	push   $0xf01048bc
f01023d6:	e8 58 dd ff ff       	call   f0100133 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f01023db:	68 04 47 10 f0       	push   $0xf0104704
f01023e0:	68 e2 48 10 f0       	push   $0xf01048e2
f01023e5:	68 39 03 00 00       	push   $0x339
f01023ea:	68 bc 48 10 f0       	push   $0xf01048bc
f01023ef:	e8 3f dd ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f01023f4:	68 63 4a 10 f0       	push   $0xf0104a63
f01023f9:	68 e2 48 10 f0       	push   $0xf01048e2
f01023fe:	68 3c 03 00 00       	push   $0x33c
f0102403:	68 bc 48 10 f0       	push   $0xf01048bc
f0102408:	e8 26 dd ff ff       	call   f0100133 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010240d:	68 a8 43 10 f0       	push   $0xf01043a8
f0102412:	68 e2 48 10 f0       	push   $0xf01048e2
f0102417:	68 3f 03 00 00       	push   $0x33f
f010241c:	68 bc 48 10 f0       	push   $0xf01048bc
f0102421:	e8 0d dd ff ff       	call   f0100133 <_panic>
	assert(pp0->pp_ref == 1);
f0102426:	68 c6 4a 10 f0       	push   $0xf0104ac6
f010242b:	68 e2 48 10 f0       	push   $0xf01048e2
f0102430:	68 41 03 00 00       	push   $0x341
f0102435:	68 bc 48 10 f0       	push   $0xf01048bc
f010243a:	e8 f4 dc ff ff       	call   f0100133 <_panic>
f010243f:	52                   	push   %edx
f0102440:	68 44 41 10 f0       	push   $0xf0104144
f0102445:	68 48 03 00 00       	push   $0x348
f010244a:	68 bc 48 10 f0       	push   $0xf01048bc
f010244f:	e8 df dc ff ff       	call   f0100133 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102454:	68 52 4b 10 f0       	push   $0xf0104b52
f0102459:	68 e2 48 10 f0       	push   $0xf01048e2
f010245e:	68 49 03 00 00       	push   $0x349
f0102463:	68 bc 48 10 f0       	push   $0xf01048bc
f0102468:	e8 c6 dc ff ff       	call   f0100133 <_panic>
f010246d:	50                   	push   %eax
f010246e:	68 44 41 10 f0       	push   $0xf0104144
f0102473:	6a 52                	push   $0x52
f0102475:	68 c8 48 10 f0       	push   $0xf01048c8
f010247a:	e8 b4 dc ff ff       	call   f0100133 <_panic>
f010247f:	52                   	push   %edx
f0102480:	68 44 41 10 f0       	push   $0xf0104144
f0102485:	6a 52                	push   $0x52
f0102487:	68 c8 48 10 f0       	push   $0xf01048c8
f010248c:	e8 a2 dc ff ff       	call   f0100133 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102491:	68 6a 4b 10 f0       	push   $0xf0104b6a
f0102496:	68 e2 48 10 f0       	push   $0xf01048e2
f010249b:	68 53 03 00 00       	push   $0x353
f01024a0:	68 bc 48 10 f0       	push   $0xf01048bc
f01024a5:	e8 89 dc ff ff       	call   f0100133 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01024aa:	50                   	push   %eax
f01024ab:	68 50 42 10 f0       	push   $0xf0104250
f01024b0:	68 b5 00 00 00       	push   $0xb5
f01024b5:	68 bc 48 10 f0       	push   $0xf01048bc
f01024ba:	e8 74 dc ff ff       	call   f0100133 <_panic>
f01024bf:	50                   	push   %eax
f01024c0:	68 50 42 10 f0       	push   $0xf0104250
f01024c5:	68 c2 00 00 00       	push   $0xc2
f01024ca:	68 bc 48 10 f0       	push   $0xf01048bc
f01024cf:	e8 5f dc ff ff       	call   f0100133 <_panic>
f01024d4:	ff 75 c8             	pushl  -0x38(%ebp)
f01024d7:	68 50 42 10 f0       	push   $0xf0104250
f01024dc:	68 94 02 00 00       	push   $0x294
f01024e1:	68 bc 48 10 f0       	push   $0xf01048bc
f01024e6:	e8 48 dc ff ff       	call   f0100133 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01024eb:	68 28 47 10 f0       	push   $0xf0104728
f01024f0:	68 e2 48 10 f0       	push   $0xf01048e2
f01024f5:	68 94 02 00 00       	push   $0x294
f01024fa:	68 bc 48 10 f0       	push   $0xf01048bc
f01024ff:	e8 2f dc ff ff       	call   f0100133 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102504:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102507:	c1 e7 0c             	shl    $0xc,%edi
f010250a:	be 00 00 00 00       	mov    $0x0,%esi
f010250f:	eb 17                	jmp    f0102528 <mem_init+0x1331>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102511:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102517:	89 d8                	mov    %ebx,%eax
f0102519:	e8 92 e5 ff ff       	call   f0100ab0 <check_va2pa>
f010251e:	39 c6                	cmp    %eax,%esi
f0102520:	75 50                	jne    f0102572 <mem_init+0x137b>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102522:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102528:	39 fe                	cmp    %edi,%esi
f010252a:	72 e5                	jb     f0102511 <mem_init+0x131a>
f010252c:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102531:	b8 00 e0 10 f0       	mov    $0xf010e000,%eax
f0102536:	8d b8 00 80 00 20    	lea    0x20008000(%eax),%edi
f010253c:	89 f2                	mov    %esi,%edx
f010253e:	89 d8                	mov    %ebx,%eax
f0102540:	e8 6b e5 ff ff       	call   f0100ab0 <check_va2pa>
f0102545:	8d 14 37             	lea    (%edi,%esi,1),%edx
f0102548:	39 d0                	cmp    %edx,%eax
f010254a:	75 3f                	jne    f010258b <mem_init+0x1394>
f010254c:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < KSTKSIZE; i += PGSIZE) {
f0102552:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0102558:	75 e2                	jne    f010253c <mem_init+0x1345>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010255a:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f010255f:	89 d8                	mov    %ebx,%eax
f0102561:	e8 4a e5 ff ff       	call   f0100ab0 <check_va2pa>
f0102566:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102569:	75 39                	jne    f01025a4 <mem_init+0x13ad>
	for (i = 0; i < NPDENTRIES; i++) {
f010256b:	b8 00 00 00 00       	mov    $0x0,%eax
f0102570:	eb 72                	jmp    f01025e4 <mem_init+0x13ed>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102572:	68 5c 47 10 f0       	push   $0xf010475c
f0102577:	68 e2 48 10 f0       	push   $0xf01048e2
f010257c:	68 99 02 00 00       	push   $0x299
f0102581:	68 bc 48 10 f0       	push   $0xf01048bc
f0102586:	e8 a8 db ff ff       	call   f0100133 <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010258b:	68 84 47 10 f0       	push   $0xf0104784
f0102590:	68 e2 48 10 f0       	push   $0xf01048e2
f0102595:	68 9d 02 00 00       	push   $0x29d
f010259a:	68 bc 48 10 f0       	push   $0xf01048bc
f010259f:	e8 8f db ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01025a4:	68 cc 47 10 f0       	push   $0xf01047cc
f01025a9:	68 e2 48 10 f0       	push   $0xf01048e2
f01025ae:	68 9f 02 00 00       	push   $0x29f
f01025b3:	68 bc 48 10 f0       	push   $0xf01048bc
f01025b8:	e8 76 db ff ff       	call   f0100133 <_panic>
			assert(pgdir[i] & PTE_P);
f01025bd:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f01025c1:	74 47                	je     f010260a <mem_init+0x1413>
	for (i = 0; i < NPDENTRIES; i++) {
f01025c3:	40                   	inc    %eax
f01025c4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f01025c9:	0f 87 93 00 00 00    	ja     f0102662 <mem_init+0x146b>
		switch (i) {
f01025cf:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f01025d4:	72 0e                	jb     f01025e4 <mem_init+0x13ed>
f01025d6:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01025db:	76 e0                	jbe    f01025bd <mem_init+0x13c6>
f01025dd:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01025e2:	74 d9                	je     f01025bd <mem_init+0x13c6>
			if (i >= PDX(KERNBASE)) {
f01025e4:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01025e9:	77 38                	ja     f0102623 <mem_init+0x142c>
				assert(pgdir[i] == 0);
f01025eb:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01025ef:	74 d2                	je     f01025c3 <mem_init+0x13cc>
f01025f1:	68 bc 4b 10 f0       	push   $0xf0104bbc
f01025f6:	68 e2 48 10 f0       	push   $0xf01048e2
f01025fb:	68 ae 02 00 00       	push   $0x2ae
f0102600:	68 bc 48 10 f0       	push   $0xf01048bc
f0102605:	e8 29 db ff ff       	call   f0100133 <_panic>
			assert(pgdir[i] & PTE_P);
f010260a:	68 9a 4b 10 f0       	push   $0xf0104b9a
f010260f:	68 e2 48 10 f0       	push   $0xf01048e2
f0102614:	68 a7 02 00 00       	push   $0x2a7
f0102619:	68 bc 48 10 f0       	push   $0xf01048bc
f010261e:	e8 10 db ff ff       	call   f0100133 <_panic>
				assert(pgdir[i] & PTE_P);
f0102623:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102626:	f6 c2 01             	test   $0x1,%dl
f0102629:	74 1e                	je     f0102649 <mem_init+0x1452>
				assert(pgdir[i] & PTE_W);
f010262b:	f6 c2 02             	test   $0x2,%dl
f010262e:	75 93                	jne    f01025c3 <mem_init+0x13cc>
f0102630:	68 ab 4b 10 f0       	push   $0xf0104bab
f0102635:	68 e2 48 10 f0       	push   $0xf01048e2
f010263a:	68 ac 02 00 00       	push   $0x2ac
f010263f:	68 bc 48 10 f0       	push   $0xf01048bc
f0102644:	e8 ea da ff ff       	call   f0100133 <_panic>
				assert(pgdir[i] & PTE_P);
f0102649:	68 9a 4b 10 f0       	push   $0xf0104b9a
f010264e:	68 e2 48 10 f0       	push   $0xf01048e2
f0102653:	68 ab 02 00 00       	push   $0x2ab
f0102658:	68 bc 48 10 f0       	push   $0xf01048bc
f010265d:	e8 d1 da ff ff       	call   f0100133 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102662:	83 ec 0c             	sub    $0xc,%esp
f0102665:	68 fc 47 10 f0       	push   $0xf01047fc
f010266a:	e8 fa 03 00 00       	call   f0102a69 <cprintf>
	lcr3(PADDR(kern_pgdir));
f010266f:	a1 68 89 11 f0       	mov    0xf0118968,%eax
	if ((uint32_t)kva < KERNBASE)
f0102674:	83 c4 10             	add    $0x10,%esp
f0102677:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010267c:	0f 86 fe 01 00 00    	jbe    f0102880 <mem_init+0x1689>
	return (physaddr_t)kva - KERNBASE;
f0102682:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102687:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f010268a:	b8 00 00 00 00       	mov    $0x0,%eax
f010268f:	e8 7b e4 ff ff       	call   f0100b0f <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102694:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102697:	83 e0 f3             	and    $0xfffffff3,%eax
f010269a:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f010269f:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01026a2:	83 ec 0c             	sub    $0xc,%esp
f01026a5:	6a 00                	push   $0x0
f01026a7:	e8 e6 e7 ff ff       	call   f0100e92 <page_alloc>
f01026ac:	89 c3                	mov    %eax,%ebx
f01026ae:	83 c4 10             	add    $0x10,%esp
f01026b1:	85 c0                	test   %eax,%eax
f01026b3:	0f 84 dc 01 00 00    	je     f0102895 <mem_init+0x169e>
	assert((pp1 = page_alloc(0)));
f01026b9:	83 ec 0c             	sub    $0xc,%esp
f01026bc:	6a 00                	push   $0x0
f01026be:	e8 cf e7 ff ff       	call   f0100e92 <page_alloc>
f01026c3:	89 c7                	mov    %eax,%edi
f01026c5:	83 c4 10             	add    $0x10,%esp
f01026c8:	85 c0                	test   %eax,%eax
f01026ca:	0f 84 de 01 00 00    	je     f01028ae <mem_init+0x16b7>
	assert((pp2 = page_alloc(0)));
f01026d0:	83 ec 0c             	sub    $0xc,%esp
f01026d3:	6a 00                	push   $0x0
f01026d5:	e8 b8 e7 ff ff       	call   f0100e92 <page_alloc>
f01026da:	89 c6                	mov    %eax,%esi
f01026dc:	83 c4 10             	add    $0x10,%esp
f01026df:	85 c0                	test   %eax,%eax
f01026e1:	0f 84 e0 01 00 00    	je     f01028c7 <mem_init+0x16d0>
	page_free(pp0);
f01026e7:	83 ec 0c             	sub    $0xc,%esp
f01026ea:	53                   	push   %ebx
f01026eb:	e8 14 e8 ff ff       	call   f0100f04 <page_free>
	return (pp - pages) << PGSHIFT;
f01026f0:	89 f8                	mov    %edi,%eax
f01026f2:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f01026f8:	c1 f8 03             	sar    $0x3,%eax
f01026fb:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01026fe:	89 c2                	mov    %eax,%edx
f0102700:	c1 ea 0c             	shr    $0xc,%edx
f0102703:	83 c4 10             	add    $0x10,%esp
f0102706:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f010270c:	0f 83 ce 01 00 00    	jae    f01028e0 <mem_init+0x16e9>
	memset(page2kva(pp1), 1, PGSIZE);
f0102712:	83 ec 04             	sub    $0x4,%esp
f0102715:	68 00 10 00 00       	push   $0x1000
f010271a:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f010271c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102721:	50                   	push   %eax
f0102722:	e8 71 0e 00 00       	call   f0103598 <memset>
	return (pp - pages) << PGSHIFT;
f0102727:	89 f0                	mov    %esi,%eax
f0102729:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f010272f:	c1 f8 03             	sar    $0x3,%eax
f0102732:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102735:	89 c2                	mov    %eax,%edx
f0102737:	c1 ea 0c             	shr    $0xc,%edx
f010273a:	83 c4 10             	add    $0x10,%esp
f010273d:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f0102743:	0f 83 a9 01 00 00    	jae    f01028f2 <mem_init+0x16fb>
	memset(page2kva(pp2), 2, PGSIZE);
f0102749:	83 ec 04             	sub    $0x4,%esp
f010274c:	68 00 10 00 00       	push   $0x1000
f0102751:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102753:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102758:	50                   	push   %eax
f0102759:	e8 3a 0e 00 00       	call   f0103598 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010275e:	6a 02                	push   $0x2
f0102760:	68 00 10 00 00       	push   $0x1000
f0102765:	57                   	push   %edi
f0102766:	ff 35 68 89 11 f0    	pushl  0xf0118968
f010276c:	e8 1f ea ff ff       	call   f0101190 <page_insert>
	assert(pp1->pp_ref == 1);
f0102771:	83 c4 20             	add    $0x20,%esp
f0102774:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102779:	0f 85 85 01 00 00    	jne    f0102904 <mem_init+0x170d>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010277f:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102786:	01 01 01 
f0102789:	0f 85 8e 01 00 00    	jne    f010291d <mem_init+0x1726>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010278f:	6a 02                	push   $0x2
f0102791:	68 00 10 00 00       	push   $0x1000
f0102796:	56                   	push   %esi
f0102797:	ff 35 68 89 11 f0    	pushl  0xf0118968
f010279d:	e8 ee e9 ff ff       	call   f0101190 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01027a2:	83 c4 10             	add    $0x10,%esp
f01027a5:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01027ac:	02 02 02 
f01027af:	0f 85 81 01 00 00    	jne    f0102936 <mem_init+0x173f>
	assert(pp2->pp_ref == 1);
f01027b5:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01027ba:	0f 85 8f 01 00 00    	jne    f010294f <mem_init+0x1758>
	assert(pp1->pp_ref == 0);
f01027c0:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01027c5:	0f 85 9d 01 00 00    	jne    f0102968 <mem_init+0x1771>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01027cb:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01027d2:	03 03 03 
	return (pp - pages) << PGSHIFT;
f01027d5:	89 f0                	mov    %esi,%eax
f01027d7:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f01027dd:	c1 f8 03             	sar    $0x3,%eax
f01027e0:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01027e3:	89 c2                	mov    %eax,%edx
f01027e5:	c1 ea 0c             	shr    $0xc,%edx
f01027e8:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f01027ee:	0f 83 8d 01 00 00    	jae    f0102981 <mem_init+0x178a>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01027f4:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01027fb:	03 03 03 
f01027fe:	0f 85 8f 01 00 00    	jne    f0102993 <mem_init+0x179c>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102804:	83 ec 08             	sub    $0x8,%esp
f0102807:	68 00 10 00 00       	push   $0x1000
f010280c:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0102812:	e8 31 e9 ff ff       	call   f0101148 <page_remove>
	assert(pp2->pp_ref == 0);
f0102817:	83 c4 10             	add    $0x10,%esp
f010281a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010281f:	0f 85 87 01 00 00    	jne    f01029ac <mem_init+0x17b5>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102825:	8b 0d 68 89 11 f0    	mov    0xf0118968,%ecx
f010282b:	8b 11                	mov    (%ecx),%edx
f010282d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102833:	89 d8                	mov    %ebx,%eax
f0102835:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f010283b:	c1 f8 03             	sar    $0x3,%eax
f010283e:	c1 e0 0c             	shl    $0xc,%eax
f0102841:	39 c2                	cmp    %eax,%edx
f0102843:	0f 85 7c 01 00 00    	jne    f01029c5 <mem_init+0x17ce>
	kern_pgdir[0] = 0;
f0102849:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010284f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102854:	0f 85 84 01 00 00    	jne    f01029de <mem_init+0x17e7>
	pp0->pp_ref = 0;
f010285a:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102860:	83 ec 0c             	sub    $0xc,%esp
f0102863:	53                   	push   %ebx
f0102864:	e8 9b e6 ff ff       	call   f0100f04 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102869:	c7 04 24 90 48 10 f0 	movl   $0xf0104890,(%esp)
f0102870:	e8 f4 01 00 00       	call   f0102a69 <cprintf>
}
f0102875:	83 c4 10             	add    $0x10,%esp
f0102878:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010287b:	5b                   	pop    %ebx
f010287c:	5e                   	pop    %esi
f010287d:	5f                   	pop    %edi
f010287e:	5d                   	pop    %ebp
f010287f:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102880:	50                   	push   %eax
f0102881:	68 50 42 10 f0       	push   $0xf0104250
f0102886:	68 d8 00 00 00       	push   $0xd8
f010288b:	68 bc 48 10 f0       	push   $0xf01048bc
f0102890:	e8 9e d8 ff ff       	call   f0100133 <_panic>
	assert((pp0 = page_alloc(0)));
f0102895:	68 b8 49 10 f0       	push   $0xf01049b8
f010289a:	68 e2 48 10 f0       	push   $0xf01048e2
f010289f:	68 6e 03 00 00       	push   $0x36e
f01028a4:	68 bc 48 10 f0       	push   $0xf01048bc
f01028a9:	e8 85 d8 ff ff       	call   f0100133 <_panic>
	assert((pp1 = page_alloc(0)));
f01028ae:	68 ce 49 10 f0       	push   $0xf01049ce
f01028b3:	68 e2 48 10 f0       	push   $0xf01048e2
f01028b8:	68 6f 03 00 00       	push   $0x36f
f01028bd:	68 bc 48 10 f0       	push   $0xf01048bc
f01028c2:	e8 6c d8 ff ff       	call   f0100133 <_panic>
	assert((pp2 = page_alloc(0)));
f01028c7:	68 e4 49 10 f0       	push   $0xf01049e4
f01028cc:	68 e2 48 10 f0       	push   $0xf01048e2
f01028d1:	68 70 03 00 00       	push   $0x370
f01028d6:	68 bc 48 10 f0       	push   $0xf01048bc
f01028db:	e8 53 d8 ff ff       	call   f0100133 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01028e0:	50                   	push   %eax
f01028e1:	68 44 41 10 f0       	push   $0xf0104144
f01028e6:	6a 52                	push   $0x52
f01028e8:	68 c8 48 10 f0       	push   $0xf01048c8
f01028ed:	e8 41 d8 ff ff       	call   f0100133 <_panic>
f01028f2:	50                   	push   %eax
f01028f3:	68 44 41 10 f0       	push   $0xf0104144
f01028f8:	6a 52                	push   $0x52
f01028fa:	68 c8 48 10 f0       	push   $0xf01048c8
f01028ff:	e8 2f d8 ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 1);
f0102904:	68 b5 4a 10 f0       	push   $0xf0104ab5
f0102909:	68 e2 48 10 f0       	push   $0xf01048e2
f010290e:	68 75 03 00 00       	push   $0x375
f0102913:	68 bc 48 10 f0       	push   $0xf01048bc
f0102918:	e8 16 d8 ff ff       	call   f0100133 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010291d:	68 1c 48 10 f0       	push   $0xf010481c
f0102922:	68 e2 48 10 f0       	push   $0xf01048e2
f0102927:	68 76 03 00 00       	push   $0x376
f010292c:	68 bc 48 10 f0       	push   $0xf01048bc
f0102931:	e8 fd d7 ff ff       	call   f0100133 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102936:	68 40 48 10 f0       	push   $0xf0104840
f010293b:	68 e2 48 10 f0       	push   $0xf01048e2
f0102940:	68 78 03 00 00       	push   $0x378
f0102945:	68 bc 48 10 f0       	push   $0xf01048bc
f010294a:	e8 e4 d7 ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 1);
f010294f:	68 d7 4a 10 f0       	push   $0xf0104ad7
f0102954:	68 e2 48 10 f0       	push   $0xf01048e2
f0102959:	68 79 03 00 00       	push   $0x379
f010295e:	68 bc 48 10 f0       	push   $0xf01048bc
f0102963:	e8 cb d7 ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 0);
f0102968:	68 41 4b 10 f0       	push   $0xf0104b41
f010296d:	68 e2 48 10 f0       	push   $0xf01048e2
f0102972:	68 7a 03 00 00       	push   $0x37a
f0102977:	68 bc 48 10 f0       	push   $0xf01048bc
f010297c:	e8 b2 d7 ff ff       	call   f0100133 <_panic>
f0102981:	50                   	push   %eax
f0102982:	68 44 41 10 f0       	push   $0xf0104144
f0102987:	6a 52                	push   $0x52
f0102989:	68 c8 48 10 f0       	push   $0xf01048c8
f010298e:	e8 a0 d7 ff ff       	call   f0100133 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102993:	68 64 48 10 f0       	push   $0xf0104864
f0102998:	68 e2 48 10 f0       	push   $0xf01048e2
f010299d:	68 7c 03 00 00       	push   $0x37c
f01029a2:	68 bc 48 10 f0       	push   $0xf01048bc
f01029a7:	e8 87 d7 ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 0);
f01029ac:	68 0f 4b 10 f0       	push   $0xf0104b0f
f01029b1:	68 e2 48 10 f0       	push   $0xf01048e2
f01029b6:	68 7e 03 00 00       	push   $0x37e
f01029bb:	68 bc 48 10 f0       	push   $0xf01048bc
f01029c0:	e8 6e d7 ff ff       	call   f0100133 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01029c5:	68 a8 43 10 f0       	push   $0xf01043a8
f01029ca:	68 e2 48 10 f0       	push   $0xf01048e2
f01029cf:	68 81 03 00 00       	push   $0x381
f01029d4:	68 bc 48 10 f0       	push   $0xf01048bc
f01029d9:	e8 55 d7 ff ff       	call   f0100133 <_panic>
	assert(pp0->pp_ref == 1);
f01029de:	68 c6 4a 10 f0       	push   $0xf0104ac6
f01029e3:	68 e2 48 10 f0       	push   $0xf01048e2
f01029e8:	68 83 03 00 00       	push   $0x383
f01029ed:	68 bc 48 10 f0       	push   $0xf01048bc
f01029f2:	e8 3c d7 ff ff       	call   f0100133 <_panic>

f01029f7 <tlb_invalidate>:
{
f01029f7:	55                   	push   %ebp
f01029f8:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01029fa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01029fd:	0f 01 38             	invlpg (%eax)
}
f0102a00:	5d                   	pop    %ebp
f0102a01:	c3                   	ret    

f0102a02 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102a02:	55                   	push   %ebp
f0102a03:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102a05:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a08:	ba 70 00 00 00       	mov    $0x70,%edx
f0102a0d:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102a0e:	ba 71 00 00 00       	mov    $0x71,%edx
f0102a13:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102a14:	0f b6 c0             	movzbl %al,%eax
}
f0102a17:	5d                   	pop    %ebp
f0102a18:	c3                   	ret    

f0102a19 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102a19:	55                   	push   %ebp
f0102a1a:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102a1c:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a1f:	ba 70 00 00 00       	mov    $0x70,%edx
f0102a24:	ee                   	out    %al,(%dx)
f0102a25:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102a28:	ba 71 00 00 00       	mov    $0x71,%edx
f0102a2d:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102a2e:	5d                   	pop    %ebp
f0102a2f:	c3                   	ret    

f0102a30 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102a30:	55                   	push   %ebp
f0102a31:	89 e5                	mov    %esp,%ebp
f0102a33:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102a36:	ff 75 08             	pushl  0x8(%ebp)
f0102a39:	e8 48 dc ff ff       	call   f0100686 <cputchar>
	*cnt++;
}
f0102a3e:	83 c4 10             	add    $0x10,%esp
f0102a41:	c9                   	leave  
f0102a42:	c3                   	ret    

f0102a43 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102a43:	55                   	push   %ebp
f0102a44:	89 e5                	mov    %esp,%ebp
f0102a46:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102a49:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102a50:	ff 75 0c             	pushl  0xc(%ebp)
f0102a53:	ff 75 08             	pushl  0x8(%ebp)
f0102a56:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102a59:	50                   	push   %eax
f0102a5a:	68 30 2a 10 f0       	push   $0xf0102a30
f0102a5f:	e8 1b 04 00 00       	call   f0102e7f <vprintfmt>
	return cnt;
}
f0102a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102a67:	c9                   	leave  
f0102a68:	c3                   	ret    

f0102a69 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102a69:	55                   	push   %ebp
f0102a6a:	89 e5                	mov    %esp,%ebp
f0102a6c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102a6f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102a72:	50                   	push   %eax
f0102a73:	ff 75 08             	pushl  0x8(%ebp)
f0102a76:	e8 c8 ff ff ff       	call   f0102a43 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102a7b:	c9                   	leave  
f0102a7c:	c3                   	ret    

f0102a7d <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102a7d:	55                   	push   %ebp
f0102a7e:	89 e5                	mov    %esp,%ebp
f0102a80:	57                   	push   %edi
f0102a81:	56                   	push   %esi
f0102a82:	53                   	push   %ebx
f0102a83:	83 ec 14             	sub    $0x14,%esp
f0102a86:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102a89:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0102a8c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102a8f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102a92:	8b 32                	mov    (%edx),%esi
f0102a94:	8b 01                	mov    (%ecx),%eax
f0102a96:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102a99:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0102aa0:	eb 2f                	jmp    f0102ad1 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0102aa2:	48                   	dec    %eax
		while (m >= l && stabs[m].n_type != type)
f0102aa3:	39 c6                	cmp    %eax,%esi
f0102aa5:	7f 4d                	jg     f0102af4 <stab_binsearch+0x77>
f0102aa7:	0f b6 0a             	movzbl (%edx),%ecx
f0102aaa:	83 ea 0c             	sub    $0xc,%edx
f0102aad:	39 f9                	cmp    %edi,%ecx
f0102aaf:	75 f1                	jne    f0102aa2 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102ab1:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0102ab4:	01 c2                	add    %eax,%edx
f0102ab6:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102ab9:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0102abd:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102ac0:	73 37                	jae    f0102af9 <stab_binsearch+0x7c>
			*region_left = m;
f0102ac2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102ac5:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0102ac7:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0102aca:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0102ad1:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0102ad4:	7f 4d                	jg     f0102b23 <stab_binsearch+0xa6>
		int true_m = (l + r) / 2, m = true_m;
f0102ad6:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102ad9:	01 f0                	add    %esi,%eax
f0102adb:	89 c3                	mov    %eax,%ebx
f0102add:	c1 eb 1f             	shr    $0x1f,%ebx
f0102ae0:	01 c3                	add    %eax,%ebx
f0102ae2:	d1 fb                	sar    %ebx
f0102ae4:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0102ae7:	01 d8                	add    %ebx,%eax
f0102ae9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102aec:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0102af0:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0102af2:	eb af                	jmp    f0102aa3 <stab_binsearch+0x26>
			l = true_m + 1;
f0102af4:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0102af7:	eb d8                	jmp    f0102ad1 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0102af9:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102afc:	76 12                	jbe    f0102b10 <stab_binsearch+0x93>
			*region_right = m - 1;
f0102afe:	48                   	dec    %eax
f0102aff:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102b02:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102b05:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0102b07:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102b0e:	eb c1                	jmp    f0102ad1 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102b10:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102b13:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0102b15:	ff 45 0c             	incl   0xc(%ebp)
f0102b18:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0102b1a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102b21:	eb ae                	jmp    f0102ad1 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0102b23:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102b27:	74 18                	je     f0102b41 <stab_binsearch+0xc4>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102b29:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102b2c:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102b2e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102b31:	8b 0e                	mov    (%esi),%ecx
f0102b33:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0102b36:	01 c2                	add    %eax,%edx
f0102b38:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0102b3b:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0102b3f:	eb 0e                	jmp    f0102b4f <stab_binsearch+0xd2>
		*region_right = *region_left - 1;
f0102b41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102b44:	8b 00                	mov    (%eax),%eax
f0102b46:	48                   	dec    %eax
f0102b47:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0102b4a:	89 07                	mov    %eax,(%edi)
f0102b4c:	eb 14                	jmp    f0102b62 <stab_binsearch+0xe5>
		     l--)
f0102b4e:	48                   	dec    %eax
		for (l = *region_right;
f0102b4f:	39 c1                	cmp    %eax,%ecx
f0102b51:	7d 0a                	jge    f0102b5d <stab_binsearch+0xe0>
		     l > *region_left && stabs[l].n_type != type;
f0102b53:	0f b6 1a             	movzbl (%edx),%ebx
f0102b56:	83 ea 0c             	sub    $0xc,%edx
f0102b59:	39 fb                	cmp    %edi,%ebx
f0102b5b:	75 f1                	jne    f0102b4e <stab_binsearch+0xd1>
			/* do nothing */;
		*region_left = l;
f0102b5d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102b60:	89 07                	mov    %eax,(%edi)
	}
}
f0102b62:	83 c4 14             	add    $0x14,%esp
f0102b65:	5b                   	pop    %ebx
f0102b66:	5e                   	pop    %esi
f0102b67:	5f                   	pop    %edi
f0102b68:	5d                   	pop    %ebp
f0102b69:	c3                   	ret    

f0102b6a <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102b6a:	55                   	push   %ebp
f0102b6b:	89 e5                	mov    %esp,%ebp
f0102b6d:	57                   	push   %edi
f0102b6e:	56                   	push   %esi
f0102b6f:	53                   	push   %ebx
f0102b70:	83 ec 3c             	sub    $0x3c,%esp
f0102b73:	8b 75 08             	mov    0x8(%ebp),%esi
f0102b76:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102b79:	c7 03 ca 4b 10 f0    	movl   $0xf0104bca,(%ebx)
	info->eip_line = 0;
f0102b7f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102b86:	c7 43 08 ca 4b 10 f0 	movl   $0xf0104bca,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102b8d:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102b94:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102b97:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102b9e:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102ba4:	0f 86 31 01 00 00    	jbe    f0102cdb <debuginfo_eip+0x171>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102baa:	b8 30 d9 10 f0       	mov    $0xf010d930,%eax
f0102baf:	3d 49 ba 10 f0       	cmp    $0xf010ba49,%eax
f0102bb4:	0f 86 b6 01 00 00    	jbe    f0102d70 <debuginfo_eip+0x206>
f0102bba:	80 3d 2f d9 10 f0 00 	cmpb   $0x0,0xf010d92f
f0102bc1:	0f 85 b0 01 00 00    	jne    f0102d77 <debuginfo_eip+0x20d>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102bc7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102bce:	ba 48 ba 10 f0       	mov    $0xf010ba48,%edx
f0102bd3:	81 ea 00 4e 10 f0    	sub    $0xf0104e00,%edx
f0102bd9:	c1 fa 02             	sar    $0x2,%edx
f0102bdc:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0102bdf:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0102be2:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0102be5:	89 c1                	mov    %eax,%ecx
f0102be7:	c1 e1 08             	shl    $0x8,%ecx
f0102bea:	01 c8                	add    %ecx,%eax
f0102bec:	89 c1                	mov    %eax,%ecx
f0102bee:	c1 e1 10             	shl    $0x10,%ecx
f0102bf1:	01 c8                	add    %ecx,%eax
f0102bf3:	01 c0                	add    %eax,%eax
f0102bf5:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
f0102bf9:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102bfc:	83 ec 08             	sub    $0x8,%esp
f0102bff:	56                   	push   %esi
f0102c00:	6a 64                	push   $0x64
f0102c02:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102c05:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102c08:	b8 00 4e 10 f0       	mov    $0xf0104e00,%eax
f0102c0d:	e8 6b fe ff ff       	call   f0102a7d <stab_binsearch>
	if (lfile == 0)
f0102c12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102c15:	83 c4 10             	add    $0x10,%esp
f0102c18:	85 c0                	test   %eax,%eax
f0102c1a:	0f 84 5e 01 00 00    	je     f0102d7e <debuginfo_eip+0x214>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102c20:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0102c23:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102c26:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102c29:	83 ec 08             	sub    $0x8,%esp
f0102c2c:	56                   	push   %esi
f0102c2d:	6a 24                	push   $0x24
f0102c2f:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102c32:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102c35:	b8 00 4e 10 f0       	mov    $0xf0104e00,%eax
f0102c3a:	e8 3e fe ff ff       	call   f0102a7d <stab_binsearch>

	if (lfun <= rfun) {
f0102c3f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102c42:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102c45:	83 c4 10             	add    $0x10,%esp
f0102c48:	39 d0                	cmp    %edx,%eax
f0102c4a:	0f 8f 9f 00 00 00    	jg     f0102cef <debuginfo_eip+0x185>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102c50:	8d 0c 00             	lea    (%eax,%eax,1),%ecx
f0102c53:	01 c1                	add    %eax,%ecx
f0102c55:	c1 e1 02             	shl    $0x2,%ecx
f0102c58:	8d b9 00 4e 10 f0    	lea    -0xfefb200(%ecx),%edi
f0102c5e:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0102c61:	8b 89 00 4e 10 f0    	mov    -0xfefb200(%ecx),%ecx
f0102c67:	bf 30 d9 10 f0       	mov    $0xf010d930,%edi
f0102c6c:	81 ef 49 ba 10 f0    	sub    $0xf010ba49,%edi
f0102c72:	39 f9                	cmp    %edi,%ecx
f0102c74:	73 09                	jae    f0102c7f <debuginfo_eip+0x115>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102c76:	81 c1 49 ba 10 f0    	add    $0xf010ba49,%ecx
f0102c7c:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102c7f:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0102c82:	8b 4f 08             	mov    0x8(%edi),%ecx
f0102c85:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102c88:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0102c8a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0102c8d:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102c90:	83 ec 08             	sub    $0x8,%esp
f0102c93:	6a 3a                	push   $0x3a
f0102c95:	ff 73 08             	pushl  0x8(%ebx)
f0102c98:	e8 e3 08 00 00       	call   f0103580 <strfind>
f0102c9d:	2b 43 08             	sub    0x8(%ebx),%eax
f0102ca0:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// N_SLINE represents text segment
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0102ca3:	83 c4 08             	add    $0x8,%esp
f0102ca6:	56                   	push   %esi
f0102ca7:	6a 44                	push   $0x44
f0102ca9:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0102cac:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0102caf:	b8 00 4e 10 f0       	mov    $0xf0104e00,%eax
f0102cb4:	e8 c4 fd ff ff       	call   f0102a7d <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0102cb9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102cbc:	8d 04 12             	lea    (%edx,%edx,1),%eax
f0102cbf:	01 d0                	add    %edx,%eax
f0102cc1:	c1 e0 02             	shl    $0x2,%eax
f0102cc4:	0f b7 88 06 4e 10 f0 	movzwl -0xfefb1fa(%eax),%ecx
f0102ccb:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102cce:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102cd1:	05 04 4e 10 f0       	add    $0xf0104e04,%eax
f0102cd6:	83 c4 10             	add    $0x10,%esp
f0102cd9:	eb 29                	jmp    f0102d04 <debuginfo_eip+0x19a>
  	        panic("User address");
f0102cdb:	83 ec 04             	sub    $0x4,%esp
f0102cde:	68 d4 4b 10 f0       	push   $0xf0104bd4
f0102ce3:	6a 7f                	push   $0x7f
f0102ce5:	68 e1 4b 10 f0       	push   $0xf0104be1
f0102cea:	e8 44 d4 ff ff       	call   f0100133 <_panic>
		info->eip_fn_addr = addr;
f0102cef:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102cf2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102cf5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0102cf8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102cfb:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102cfe:	eb 90                	jmp    f0102c90 <debuginfo_eip+0x126>
f0102d00:	4a                   	dec    %edx
f0102d01:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0102d04:	39 d6                	cmp    %edx,%esi
f0102d06:	7f 34                	jg     f0102d3c <debuginfo_eip+0x1d2>
	       && stabs[lline].n_type != N_SOL
f0102d08:	8a 08                	mov    (%eax),%cl
f0102d0a:	80 f9 84             	cmp    $0x84,%cl
f0102d0d:	74 0b                	je     f0102d1a <debuginfo_eip+0x1b0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102d0f:	80 f9 64             	cmp    $0x64,%cl
f0102d12:	75 ec                	jne    f0102d00 <debuginfo_eip+0x196>
f0102d14:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0102d18:	74 e6                	je     f0102d00 <debuginfo_eip+0x196>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102d1a:	8d 04 12             	lea    (%edx,%edx,1),%eax
f0102d1d:	01 c2                	add    %eax,%edx
f0102d1f:	8b 14 95 00 4e 10 f0 	mov    -0xfefb200(,%edx,4),%edx
f0102d26:	b8 30 d9 10 f0       	mov    $0xf010d930,%eax
f0102d2b:	2d 49 ba 10 f0       	sub    $0xf010ba49,%eax
f0102d30:	39 c2                	cmp    %eax,%edx
f0102d32:	73 08                	jae    f0102d3c <debuginfo_eip+0x1d2>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102d34:	81 c2 49 ba 10 f0    	add    $0xf010ba49,%edx
f0102d3a:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102d3c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102d3f:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0102d42:	39 f2                	cmp    %esi,%edx
f0102d44:	7d 3f                	jge    f0102d85 <debuginfo_eip+0x21b>
		for (lline = lfun + 1;
f0102d46:	42                   	inc    %edx
f0102d47:	89 d0                	mov    %edx,%eax
f0102d49:	8d 0c 12             	lea    (%edx,%edx,1),%ecx
f0102d4c:	01 ca                	add    %ecx,%edx
f0102d4e:	8d 14 95 04 4e 10 f0 	lea    -0xfefb1fc(,%edx,4),%edx
f0102d55:	eb 03                	jmp    f0102d5a <debuginfo_eip+0x1f0>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0102d57:	ff 43 14             	incl   0x14(%ebx)
		for (lline = lfun + 1;
f0102d5a:	39 c6                	cmp    %eax,%esi
f0102d5c:	7e 34                	jle    f0102d92 <debuginfo_eip+0x228>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102d5e:	8a 0a                	mov    (%edx),%cl
f0102d60:	40                   	inc    %eax
f0102d61:	83 c2 0c             	add    $0xc,%edx
f0102d64:	80 f9 a0             	cmp    $0xa0,%cl
f0102d67:	74 ee                	je     f0102d57 <debuginfo_eip+0x1ed>

	return 0;
f0102d69:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d6e:	eb 1a                	jmp    f0102d8a <debuginfo_eip+0x220>
		return -1;
f0102d70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102d75:	eb 13                	jmp    f0102d8a <debuginfo_eip+0x220>
f0102d77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102d7c:	eb 0c                	jmp    f0102d8a <debuginfo_eip+0x220>
		return -1;
f0102d7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102d83:	eb 05                	jmp    f0102d8a <debuginfo_eip+0x220>
	return 0;
f0102d85:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102d8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d8d:	5b                   	pop    %ebx
f0102d8e:	5e                   	pop    %esi
f0102d8f:	5f                   	pop    %edi
f0102d90:	5d                   	pop    %ebp
f0102d91:	c3                   	ret    
	return 0;
f0102d92:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d97:	eb f1                	jmp    f0102d8a <debuginfo_eip+0x220>

f0102d99 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102d99:	55                   	push   %ebp
f0102d9a:	89 e5                	mov    %esp,%ebp
f0102d9c:	57                   	push   %edi
f0102d9d:	56                   	push   %esi
f0102d9e:	53                   	push   %ebx
f0102d9f:	83 ec 1c             	sub    $0x1c,%esp
f0102da2:	89 c7                	mov    %eax,%edi
f0102da4:	89 d6                	mov    %edx,%esi
f0102da6:	8b 45 08             	mov    0x8(%ebp),%eax
f0102da9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102dac:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102daf:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102db2:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0102db5:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102dba:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102dbd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0102dc0:	39 d3                	cmp    %edx,%ebx
f0102dc2:	72 05                	jb     f0102dc9 <printnum+0x30>
f0102dc4:	39 45 10             	cmp    %eax,0x10(%ebp)
f0102dc7:	77 78                	ja     f0102e41 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102dc9:	83 ec 0c             	sub    $0xc,%esp
f0102dcc:	ff 75 18             	pushl  0x18(%ebp)
f0102dcf:	8b 45 14             	mov    0x14(%ebp),%eax
f0102dd2:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0102dd5:	53                   	push   %ebx
f0102dd6:	ff 75 10             	pushl  0x10(%ebp)
f0102dd9:	83 ec 08             	sub    $0x8,%esp
f0102ddc:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102ddf:	ff 75 e0             	pushl  -0x20(%ebp)
f0102de2:	ff 75 dc             	pushl  -0x24(%ebp)
f0102de5:	ff 75 d8             	pushl  -0x28(%ebp)
f0102de8:	e8 5b 0a 00 00       	call   f0103848 <__udivdi3>
f0102ded:	83 c4 18             	add    $0x18,%esp
f0102df0:	52                   	push   %edx
f0102df1:	50                   	push   %eax
f0102df2:	89 f2                	mov    %esi,%edx
f0102df4:	89 f8                	mov    %edi,%eax
f0102df6:	e8 9e ff ff ff       	call   f0102d99 <printnum>
f0102dfb:	83 c4 20             	add    $0x20,%esp
f0102dfe:	eb 11                	jmp    f0102e11 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102e00:	83 ec 08             	sub    $0x8,%esp
f0102e03:	56                   	push   %esi
f0102e04:	ff 75 18             	pushl  0x18(%ebp)
f0102e07:	ff d7                	call   *%edi
f0102e09:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0102e0c:	4b                   	dec    %ebx
f0102e0d:	85 db                	test   %ebx,%ebx
f0102e0f:	7f ef                	jg     f0102e00 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102e11:	83 ec 08             	sub    $0x8,%esp
f0102e14:	56                   	push   %esi
f0102e15:	83 ec 04             	sub    $0x4,%esp
f0102e18:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102e1b:	ff 75 e0             	pushl  -0x20(%ebp)
f0102e1e:	ff 75 dc             	pushl  -0x24(%ebp)
f0102e21:	ff 75 d8             	pushl  -0x28(%ebp)
f0102e24:	e8 1f 0b 00 00       	call   f0103948 <__umoddi3>
f0102e29:	83 c4 14             	add    $0x14,%esp
f0102e2c:	0f be 80 ef 4b 10 f0 	movsbl -0xfefb411(%eax),%eax
f0102e33:	50                   	push   %eax
f0102e34:	ff d7                	call   *%edi
}
f0102e36:	83 c4 10             	add    $0x10,%esp
f0102e39:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e3c:	5b                   	pop    %ebx
f0102e3d:	5e                   	pop    %esi
f0102e3e:	5f                   	pop    %edi
f0102e3f:	5d                   	pop    %ebp
f0102e40:	c3                   	ret    
f0102e41:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0102e44:	eb c6                	jmp    f0102e0c <printnum+0x73>

f0102e46 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102e46:	55                   	push   %ebp
f0102e47:	89 e5                	mov    %esp,%ebp
f0102e49:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102e4c:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0102e4f:	8b 10                	mov    (%eax),%edx
f0102e51:	3b 50 04             	cmp    0x4(%eax),%edx
f0102e54:	73 0a                	jae    f0102e60 <sprintputch+0x1a>
		*b->buf++ = ch;
f0102e56:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102e59:	89 08                	mov    %ecx,(%eax)
f0102e5b:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e5e:	88 02                	mov    %al,(%edx)
}
f0102e60:	5d                   	pop    %ebp
f0102e61:	c3                   	ret    

f0102e62 <printfmt>:
{
f0102e62:	55                   	push   %ebp
f0102e63:	89 e5                	mov    %esp,%ebp
f0102e65:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0102e68:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102e6b:	50                   	push   %eax
f0102e6c:	ff 75 10             	pushl  0x10(%ebp)
f0102e6f:	ff 75 0c             	pushl  0xc(%ebp)
f0102e72:	ff 75 08             	pushl  0x8(%ebp)
f0102e75:	e8 05 00 00 00       	call   f0102e7f <vprintfmt>
}
f0102e7a:	83 c4 10             	add    $0x10,%esp
f0102e7d:	c9                   	leave  
f0102e7e:	c3                   	ret    

f0102e7f <vprintfmt>:
{
f0102e7f:	55                   	push   %ebp
f0102e80:	89 e5                	mov    %esp,%ebp
f0102e82:	57                   	push   %edi
f0102e83:	56                   	push   %esi
f0102e84:	53                   	push   %ebx
f0102e85:	83 ec 2c             	sub    $0x2c,%esp
f0102e88:	8b 75 08             	mov    0x8(%ebp),%esi
f0102e8b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102e8e:	8b 7d 10             	mov    0x10(%ebp),%edi
f0102e91:	e9 ac 03 00 00       	jmp    f0103242 <vprintfmt+0x3c3>
		padc = ' ';
f0102e96:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0102e9a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0102ea1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f0102ea8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0102eaf:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0102eb4:	8d 47 01             	lea    0x1(%edi),%eax
f0102eb7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102eba:	8a 17                	mov    (%edi),%dl
f0102ebc:	8d 42 dd             	lea    -0x23(%edx),%eax
f0102ebf:	3c 55                	cmp    $0x55,%al
f0102ec1:	0f 87 fc 03 00 00    	ja     f01032c3 <vprintfmt+0x444>
f0102ec7:	0f b6 c0             	movzbl %al,%eax
f0102eca:	ff 24 85 7c 4c 10 f0 	jmp    *-0xfefb384(,%eax,4)
f0102ed1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0102ed4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0102ed8:	eb da                	jmp    f0102eb4 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0102eda:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0102edd:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0102ee1:	eb d1                	jmp    f0102eb4 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0102ee3:	0f b6 d2             	movzbl %dl,%edx
f0102ee6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0102ee9:	b8 00 00 00 00       	mov    $0x0,%eax
f0102eee:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0102ef1:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102ef4:	01 c0                	add    %eax,%eax
f0102ef6:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
f0102efa:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0102efd:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0102f00:	83 f9 09             	cmp    $0x9,%ecx
f0102f03:	77 52                	ja     f0102f57 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
f0102f05:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
f0102f06:	eb e9                	jmp    f0102ef1 <vprintfmt+0x72>
			precision = va_arg(ap, int);
f0102f08:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f0b:	8b 00                	mov    (%eax),%eax
f0102f0d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102f10:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f13:	8d 40 04             	lea    0x4(%eax),%eax
f0102f16:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0102f19:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0102f1c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102f20:	79 92                	jns    f0102eb4 <vprintfmt+0x35>
				width = precision, precision = -1;
f0102f22:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102f25:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102f28:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102f2f:	eb 83                	jmp    f0102eb4 <vprintfmt+0x35>
f0102f31:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102f35:	78 08                	js     f0102f3f <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
f0102f37:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102f3a:	e9 75 ff ff ff       	jmp    f0102eb4 <vprintfmt+0x35>
f0102f3f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102f46:	eb ef                	jmp    f0102f37 <vprintfmt+0xb8>
f0102f48:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0102f4b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0102f52:	e9 5d ff ff ff       	jmp    f0102eb4 <vprintfmt+0x35>
f0102f57:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102f5a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102f5d:	eb bd                	jmp    f0102f1c <vprintfmt+0x9d>
			lflag++;
f0102f5f:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
f0102f60:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0102f63:	e9 4c ff ff ff       	jmp    f0102eb4 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f0102f68:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f6b:	8d 78 04             	lea    0x4(%eax),%edi
f0102f6e:	83 ec 08             	sub    $0x8,%esp
f0102f71:	53                   	push   %ebx
f0102f72:	ff 30                	pushl  (%eax)
f0102f74:	ff d6                	call   *%esi
			break;
f0102f76:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0102f79:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0102f7c:	e9 be 02 00 00       	jmp    f010323f <vprintfmt+0x3c0>
			err = va_arg(ap, int);
f0102f81:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f84:	8d 78 04             	lea    0x4(%eax),%edi
f0102f87:	8b 00                	mov    (%eax),%eax
f0102f89:	85 c0                	test   %eax,%eax
f0102f8b:	78 2a                	js     f0102fb7 <vprintfmt+0x138>
f0102f8d:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102f8f:	83 f8 06             	cmp    $0x6,%eax
f0102f92:	7f 27                	jg     f0102fbb <vprintfmt+0x13c>
f0102f94:	8b 04 85 d4 4d 10 f0 	mov    -0xfefb22c(,%eax,4),%eax
f0102f9b:	85 c0                	test   %eax,%eax
f0102f9d:	74 1c                	je     f0102fbb <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
f0102f9f:	50                   	push   %eax
f0102fa0:	68 f4 48 10 f0       	push   $0xf01048f4
f0102fa5:	53                   	push   %ebx
f0102fa6:	56                   	push   %esi
f0102fa7:	e8 b6 fe ff ff       	call   f0102e62 <printfmt>
f0102fac:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0102faf:	89 7d 14             	mov    %edi,0x14(%ebp)
f0102fb2:	e9 88 02 00 00       	jmp    f010323f <vprintfmt+0x3c0>
f0102fb7:	f7 d8                	neg    %eax
f0102fb9:	eb d2                	jmp    f0102f8d <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
f0102fbb:	52                   	push   %edx
f0102fbc:	68 07 4c 10 f0       	push   $0xf0104c07
f0102fc1:	53                   	push   %ebx
f0102fc2:	56                   	push   %esi
f0102fc3:	e8 9a fe ff ff       	call   f0102e62 <printfmt>
f0102fc8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0102fcb:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0102fce:	e9 6c 02 00 00       	jmp    f010323f <vprintfmt+0x3c0>
			if ((p = va_arg(ap, char *)) == NULL)
f0102fd3:	8b 45 14             	mov    0x14(%ebp),%eax
f0102fd6:	83 c0 04             	add    $0x4,%eax
f0102fd9:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102fdc:	8b 45 14             	mov    0x14(%ebp),%eax
f0102fdf:	8b 38                	mov    (%eax),%edi
f0102fe1:	85 ff                	test   %edi,%edi
f0102fe3:	74 18                	je     f0102ffd <vprintfmt+0x17e>
			if (width > 0 && padc != '-')
f0102fe5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102fe9:	0f 8e b7 00 00 00    	jle    f01030a6 <vprintfmt+0x227>
f0102fef:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0102ff3:	75 0f                	jne    f0103004 <vprintfmt+0x185>
f0102ff5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102ff8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102ffb:	eb 6e                	jmp    f010306b <vprintfmt+0x1ec>
				p = "(null)";
f0102ffd:	bf 00 4c 10 f0       	mov    $0xf0104c00,%edi
f0103002:	eb e1                	jmp    f0102fe5 <vprintfmt+0x166>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103004:	83 ec 08             	sub    $0x8,%esp
f0103007:	ff 75 d0             	pushl  -0x30(%ebp)
f010300a:	57                   	push   %edi
f010300b:	e8 45 04 00 00       	call   f0103455 <strnlen>
f0103010:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103013:	29 c1                	sub    %eax,%ecx
f0103015:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0103018:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010301b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010301f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103022:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103025:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0103027:	eb 0d                	jmp    f0103036 <vprintfmt+0x1b7>
					putch(padc, putdat);
f0103029:	83 ec 08             	sub    $0x8,%esp
f010302c:	53                   	push   %ebx
f010302d:	ff 75 e0             	pushl  -0x20(%ebp)
f0103030:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0103032:	4f                   	dec    %edi
f0103033:	83 c4 10             	add    $0x10,%esp
f0103036:	85 ff                	test   %edi,%edi
f0103038:	7f ef                	jg     f0103029 <vprintfmt+0x1aa>
f010303a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010303d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103040:	89 c8                	mov    %ecx,%eax
f0103042:	85 c9                	test   %ecx,%ecx
f0103044:	78 59                	js     f010309f <vprintfmt+0x220>
f0103046:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103049:	29 c1                	sub    %eax,%ecx
f010304b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010304e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103051:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103054:	eb 15                	jmp    f010306b <vprintfmt+0x1ec>
				if (altflag && (ch < ' ' || ch > '~'))
f0103056:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010305a:	75 29                	jne    f0103085 <vprintfmt+0x206>
					putch(ch, putdat);
f010305c:	83 ec 08             	sub    $0x8,%esp
f010305f:	ff 75 0c             	pushl  0xc(%ebp)
f0103062:	50                   	push   %eax
f0103063:	ff d6                	call   *%esi
f0103065:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103068:	ff 4d e0             	decl   -0x20(%ebp)
f010306b:	47                   	inc    %edi
f010306c:	8a 57 ff             	mov    -0x1(%edi),%dl
f010306f:	0f be c2             	movsbl %dl,%eax
f0103072:	85 c0                	test   %eax,%eax
f0103074:	74 53                	je     f01030c9 <vprintfmt+0x24a>
f0103076:	85 db                	test   %ebx,%ebx
f0103078:	78 dc                	js     f0103056 <vprintfmt+0x1d7>
f010307a:	4b                   	dec    %ebx
f010307b:	79 d9                	jns    f0103056 <vprintfmt+0x1d7>
f010307d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103080:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103083:	eb 35                	jmp    f01030ba <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
f0103085:	0f be d2             	movsbl %dl,%edx
f0103088:	83 ea 20             	sub    $0x20,%edx
f010308b:	83 fa 5e             	cmp    $0x5e,%edx
f010308e:	76 cc                	jbe    f010305c <vprintfmt+0x1dd>
					putch('?', putdat);
f0103090:	83 ec 08             	sub    $0x8,%esp
f0103093:	ff 75 0c             	pushl  0xc(%ebp)
f0103096:	6a 3f                	push   $0x3f
f0103098:	ff d6                	call   *%esi
f010309a:	83 c4 10             	add    $0x10,%esp
f010309d:	eb c9                	jmp    f0103068 <vprintfmt+0x1e9>
f010309f:	b8 00 00 00 00       	mov    $0x0,%eax
f01030a4:	eb a0                	jmp    f0103046 <vprintfmt+0x1c7>
f01030a6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01030a9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01030ac:	eb bd                	jmp    f010306b <vprintfmt+0x1ec>
				putch(' ', putdat);
f01030ae:	83 ec 08             	sub    $0x8,%esp
f01030b1:	53                   	push   %ebx
f01030b2:	6a 20                	push   $0x20
f01030b4:	ff d6                	call   *%esi
			for (; width > 0; width--)
f01030b6:	4f                   	dec    %edi
f01030b7:	83 c4 10             	add    $0x10,%esp
f01030ba:	85 ff                	test   %edi,%edi
f01030bc:	7f f0                	jg     f01030ae <vprintfmt+0x22f>
			if ((p = va_arg(ap, char *)) == NULL)
f01030be:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01030c1:	89 45 14             	mov    %eax,0x14(%ebp)
f01030c4:	e9 76 01 00 00       	jmp    f010323f <vprintfmt+0x3c0>
f01030c9:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01030cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01030cf:	eb e9                	jmp    f01030ba <vprintfmt+0x23b>
	if (lflag >= 2)
f01030d1:	83 f9 01             	cmp    $0x1,%ecx
f01030d4:	7e 3f                	jle    f0103115 <vprintfmt+0x296>
		return va_arg(*ap, long long);
f01030d6:	8b 45 14             	mov    0x14(%ebp),%eax
f01030d9:	8b 50 04             	mov    0x4(%eax),%edx
f01030dc:	8b 00                	mov    (%eax),%eax
f01030de:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01030e1:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01030e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01030e7:	8d 40 08             	lea    0x8(%eax),%eax
f01030ea:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01030ed:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01030f1:	79 5c                	jns    f010314f <vprintfmt+0x2d0>
				putch('-', putdat);
f01030f3:	83 ec 08             	sub    $0x8,%esp
f01030f6:	53                   	push   %ebx
f01030f7:	6a 2d                	push   $0x2d
f01030f9:	ff d6                	call   *%esi
				num = -(long long) num;
f01030fb:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01030fe:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103101:	f7 da                	neg    %edx
f0103103:	83 d1 00             	adc    $0x0,%ecx
f0103106:	f7 d9                	neg    %ecx
f0103108:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010310b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103110:	e9 10 01 00 00       	jmp    f0103225 <vprintfmt+0x3a6>
	else if (lflag)
f0103115:	85 c9                	test   %ecx,%ecx
f0103117:	75 1b                	jne    f0103134 <vprintfmt+0x2b5>
		return va_arg(*ap, int);
f0103119:	8b 45 14             	mov    0x14(%ebp),%eax
f010311c:	8b 00                	mov    (%eax),%eax
f010311e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103121:	89 c1                	mov    %eax,%ecx
f0103123:	c1 f9 1f             	sar    $0x1f,%ecx
f0103126:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103129:	8b 45 14             	mov    0x14(%ebp),%eax
f010312c:	8d 40 04             	lea    0x4(%eax),%eax
f010312f:	89 45 14             	mov    %eax,0x14(%ebp)
f0103132:	eb b9                	jmp    f01030ed <vprintfmt+0x26e>
		return va_arg(*ap, long);
f0103134:	8b 45 14             	mov    0x14(%ebp),%eax
f0103137:	8b 00                	mov    (%eax),%eax
f0103139:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010313c:	89 c1                	mov    %eax,%ecx
f010313e:	c1 f9 1f             	sar    $0x1f,%ecx
f0103141:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103144:	8b 45 14             	mov    0x14(%ebp),%eax
f0103147:	8d 40 04             	lea    0x4(%eax),%eax
f010314a:	89 45 14             	mov    %eax,0x14(%ebp)
f010314d:	eb 9e                	jmp    f01030ed <vprintfmt+0x26e>
			num = getint(&ap, lflag);
f010314f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103152:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0103155:	b8 0a 00 00 00       	mov    $0xa,%eax
f010315a:	e9 c6 00 00 00       	jmp    f0103225 <vprintfmt+0x3a6>
	if (lflag >= 2)
f010315f:	83 f9 01             	cmp    $0x1,%ecx
f0103162:	7e 18                	jle    f010317c <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
f0103164:	8b 45 14             	mov    0x14(%ebp),%eax
f0103167:	8b 10                	mov    (%eax),%edx
f0103169:	8b 48 04             	mov    0x4(%eax),%ecx
f010316c:	8d 40 08             	lea    0x8(%eax),%eax
f010316f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103172:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103177:	e9 a9 00 00 00       	jmp    f0103225 <vprintfmt+0x3a6>
	else if (lflag)
f010317c:	85 c9                	test   %ecx,%ecx
f010317e:	75 1a                	jne    f010319a <vprintfmt+0x31b>
		return va_arg(*ap, unsigned int);
f0103180:	8b 45 14             	mov    0x14(%ebp),%eax
f0103183:	8b 10                	mov    (%eax),%edx
f0103185:	b9 00 00 00 00       	mov    $0x0,%ecx
f010318a:	8d 40 04             	lea    0x4(%eax),%eax
f010318d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103190:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103195:	e9 8b 00 00 00       	jmp    f0103225 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f010319a:	8b 45 14             	mov    0x14(%ebp),%eax
f010319d:	8b 10                	mov    (%eax),%edx
f010319f:	b9 00 00 00 00       	mov    $0x0,%ecx
f01031a4:	8d 40 04             	lea    0x4(%eax),%eax
f01031a7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01031aa:	b8 0a 00 00 00       	mov    $0xa,%eax
f01031af:	eb 74                	jmp    f0103225 <vprintfmt+0x3a6>
	if (lflag >= 2)
f01031b1:	83 f9 01             	cmp    $0x1,%ecx
f01031b4:	7e 15                	jle    f01031cb <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
f01031b6:	8b 45 14             	mov    0x14(%ebp),%eax
f01031b9:	8b 10                	mov    (%eax),%edx
f01031bb:	8b 48 04             	mov    0x4(%eax),%ecx
f01031be:	8d 40 08             	lea    0x8(%eax),%eax
f01031c1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01031c4:	b8 08 00 00 00       	mov    $0x8,%eax
f01031c9:	eb 5a                	jmp    f0103225 <vprintfmt+0x3a6>
	else if (lflag)
f01031cb:	85 c9                	test   %ecx,%ecx
f01031cd:	75 17                	jne    f01031e6 <vprintfmt+0x367>
		return va_arg(*ap, unsigned int);
f01031cf:	8b 45 14             	mov    0x14(%ebp),%eax
f01031d2:	8b 10                	mov    (%eax),%edx
f01031d4:	b9 00 00 00 00       	mov    $0x0,%ecx
f01031d9:	8d 40 04             	lea    0x4(%eax),%eax
f01031dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01031df:	b8 08 00 00 00       	mov    $0x8,%eax
f01031e4:	eb 3f                	jmp    f0103225 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f01031e6:	8b 45 14             	mov    0x14(%ebp),%eax
f01031e9:	8b 10                	mov    (%eax),%edx
f01031eb:	b9 00 00 00 00       	mov    $0x0,%ecx
f01031f0:	8d 40 04             	lea    0x4(%eax),%eax
f01031f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01031f6:	b8 08 00 00 00       	mov    $0x8,%eax
f01031fb:	eb 28                	jmp    f0103225 <vprintfmt+0x3a6>
			putch('0', putdat);
f01031fd:	83 ec 08             	sub    $0x8,%esp
f0103200:	53                   	push   %ebx
f0103201:	6a 30                	push   $0x30
f0103203:	ff d6                	call   *%esi
			putch('x', putdat);
f0103205:	83 c4 08             	add    $0x8,%esp
f0103208:	53                   	push   %ebx
f0103209:	6a 78                	push   $0x78
f010320b:	ff d6                	call   *%esi
			num = (unsigned long long)
f010320d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103210:	8b 10                	mov    (%eax),%edx
f0103212:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0103217:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010321a:	8d 40 04             	lea    0x4(%eax),%eax
f010321d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103220:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0103225:	83 ec 0c             	sub    $0xc,%esp
f0103228:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f010322c:	57                   	push   %edi
f010322d:	ff 75 e0             	pushl  -0x20(%ebp)
f0103230:	50                   	push   %eax
f0103231:	51                   	push   %ecx
f0103232:	52                   	push   %edx
f0103233:	89 da                	mov    %ebx,%edx
f0103235:	89 f0                	mov    %esi,%eax
f0103237:	e8 5d fb ff ff       	call   f0102d99 <printnum>
			break;
f010323c:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f010323f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103242:	47                   	inc    %edi
f0103243:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103247:	83 f8 25             	cmp    $0x25,%eax
f010324a:	0f 84 46 fc ff ff    	je     f0102e96 <vprintfmt+0x17>
			if (ch == '\0')
f0103250:	85 c0                	test   %eax,%eax
f0103252:	0f 84 89 00 00 00    	je     f01032e1 <vprintfmt+0x462>
			putch(ch, putdat);
f0103258:	83 ec 08             	sub    $0x8,%esp
f010325b:	53                   	push   %ebx
f010325c:	50                   	push   %eax
f010325d:	ff d6                	call   *%esi
f010325f:	83 c4 10             	add    $0x10,%esp
f0103262:	eb de                	jmp    f0103242 <vprintfmt+0x3c3>
	if (lflag >= 2)
f0103264:	83 f9 01             	cmp    $0x1,%ecx
f0103267:	7e 15                	jle    f010327e <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
f0103269:	8b 45 14             	mov    0x14(%ebp),%eax
f010326c:	8b 10                	mov    (%eax),%edx
f010326e:	8b 48 04             	mov    0x4(%eax),%ecx
f0103271:	8d 40 08             	lea    0x8(%eax),%eax
f0103274:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103277:	b8 10 00 00 00       	mov    $0x10,%eax
f010327c:	eb a7                	jmp    f0103225 <vprintfmt+0x3a6>
	else if (lflag)
f010327e:	85 c9                	test   %ecx,%ecx
f0103280:	75 17                	jne    f0103299 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned int);
f0103282:	8b 45 14             	mov    0x14(%ebp),%eax
f0103285:	8b 10                	mov    (%eax),%edx
f0103287:	b9 00 00 00 00       	mov    $0x0,%ecx
f010328c:	8d 40 04             	lea    0x4(%eax),%eax
f010328f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103292:	b8 10 00 00 00       	mov    $0x10,%eax
f0103297:	eb 8c                	jmp    f0103225 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0103299:	8b 45 14             	mov    0x14(%ebp),%eax
f010329c:	8b 10                	mov    (%eax),%edx
f010329e:	b9 00 00 00 00       	mov    $0x0,%ecx
f01032a3:	8d 40 04             	lea    0x4(%eax),%eax
f01032a6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01032a9:	b8 10 00 00 00       	mov    $0x10,%eax
f01032ae:	e9 72 ff ff ff       	jmp    f0103225 <vprintfmt+0x3a6>
			putch(ch, putdat);
f01032b3:	83 ec 08             	sub    $0x8,%esp
f01032b6:	53                   	push   %ebx
f01032b7:	6a 25                	push   $0x25
f01032b9:	ff d6                	call   *%esi
			break;
f01032bb:	83 c4 10             	add    $0x10,%esp
f01032be:	e9 7c ff ff ff       	jmp    f010323f <vprintfmt+0x3c0>
			putch('%', putdat);
f01032c3:	83 ec 08             	sub    $0x8,%esp
f01032c6:	53                   	push   %ebx
f01032c7:	6a 25                	push   $0x25
f01032c9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01032cb:	83 c4 10             	add    $0x10,%esp
f01032ce:	89 f8                	mov    %edi,%eax
f01032d0:	eb 01                	jmp    f01032d3 <vprintfmt+0x454>
f01032d2:	48                   	dec    %eax
f01032d3:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01032d7:	75 f9                	jne    f01032d2 <vprintfmt+0x453>
f01032d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01032dc:	e9 5e ff ff ff       	jmp    f010323f <vprintfmt+0x3c0>
}
f01032e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01032e4:	5b                   	pop    %ebx
f01032e5:	5e                   	pop    %esi
f01032e6:	5f                   	pop    %edi
f01032e7:	5d                   	pop    %ebp
f01032e8:	c3                   	ret    

f01032e9 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01032e9:	55                   	push   %ebp
f01032ea:	89 e5                	mov    %esp,%ebp
f01032ec:	83 ec 18             	sub    $0x18,%esp
f01032ef:	8b 45 08             	mov    0x8(%ebp),%eax
f01032f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01032f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01032f8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01032fc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01032ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103306:	85 c0                	test   %eax,%eax
f0103308:	74 26                	je     f0103330 <vsnprintf+0x47>
f010330a:	85 d2                	test   %edx,%edx
f010330c:	7e 29                	jle    f0103337 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010330e:	ff 75 14             	pushl  0x14(%ebp)
f0103311:	ff 75 10             	pushl  0x10(%ebp)
f0103314:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103317:	50                   	push   %eax
f0103318:	68 46 2e 10 f0       	push   $0xf0102e46
f010331d:	e8 5d fb ff ff       	call   f0102e7f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103322:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103325:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103328:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010332b:	83 c4 10             	add    $0x10,%esp
}
f010332e:	c9                   	leave  
f010332f:	c3                   	ret    
		return -E_INVAL;
f0103330:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103335:	eb f7                	jmp    f010332e <vsnprintf+0x45>
f0103337:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010333c:	eb f0                	jmp    f010332e <vsnprintf+0x45>

f010333e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010333e:	55                   	push   %ebp
f010333f:	89 e5                	mov    %esp,%ebp
f0103341:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103344:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103347:	50                   	push   %eax
f0103348:	ff 75 10             	pushl  0x10(%ebp)
f010334b:	ff 75 0c             	pushl  0xc(%ebp)
f010334e:	ff 75 08             	pushl  0x8(%ebp)
f0103351:	e8 93 ff ff ff       	call   f01032e9 <vsnprintf>
	va_end(ap);

	return rc;
}
f0103356:	c9                   	leave  
f0103357:	c3                   	ret    

f0103358 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103358:	55                   	push   %ebp
f0103359:	89 e5                	mov    %esp,%ebp
f010335b:	57                   	push   %edi
f010335c:	56                   	push   %esi
f010335d:	53                   	push   %ebx
f010335e:	83 ec 0c             	sub    $0xc,%esp
f0103361:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103364:	85 c0                	test   %eax,%eax
f0103366:	74 11                	je     f0103379 <readline+0x21>
		cprintf("%s", prompt);
f0103368:	83 ec 08             	sub    $0x8,%esp
f010336b:	50                   	push   %eax
f010336c:	68 f4 48 10 f0       	push   $0xf01048f4
f0103371:	e8 f3 f6 ff ff       	call   f0102a69 <cprintf>
f0103376:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103379:	83 ec 0c             	sub    $0xc,%esp
f010337c:	6a 00                	push   $0x0
f010337e:	e8 24 d3 ff ff       	call   f01006a7 <iscons>
f0103383:	89 c7                	mov    %eax,%edi
f0103385:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0103388:	be 00 00 00 00       	mov    $0x0,%esi
f010338d:	eb 6f                	jmp    f01033fe <readline+0xa6>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f010338f:	83 ec 08             	sub    $0x8,%esp
f0103392:	50                   	push   %eax
f0103393:	68 f0 4d 10 f0       	push   $0xf0104df0
f0103398:	e8 cc f6 ff ff       	call   f0102a69 <cprintf>
			return NULL;
f010339d:	83 c4 10             	add    $0x10,%esp
f01033a0:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01033a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033a8:	5b                   	pop    %ebx
f01033a9:	5e                   	pop    %esi
f01033aa:	5f                   	pop    %edi
f01033ab:	5d                   	pop    %ebp
f01033ac:	c3                   	ret    
				cputchar('\b');
f01033ad:	83 ec 0c             	sub    $0xc,%esp
f01033b0:	6a 08                	push   $0x8
f01033b2:	e8 cf d2 ff ff       	call   f0100686 <cputchar>
f01033b7:	83 c4 10             	add    $0x10,%esp
f01033ba:	eb 41                	jmp    f01033fd <readline+0xa5>
				cputchar(c);
f01033bc:	83 ec 0c             	sub    $0xc,%esp
f01033bf:	53                   	push   %ebx
f01033c0:	e8 c1 d2 ff ff       	call   f0100686 <cputchar>
f01033c5:	83 c4 10             	add    $0x10,%esp
f01033c8:	eb 5a                	jmp    f0103424 <readline+0xcc>
		} else if (c == '\n' || c == '\r') {
f01033ca:	83 fb 0a             	cmp    $0xa,%ebx
f01033cd:	74 05                	je     f01033d4 <readline+0x7c>
f01033cf:	83 fb 0d             	cmp    $0xd,%ebx
f01033d2:	75 2a                	jne    f01033fe <readline+0xa6>
			if (echoing)
f01033d4:	85 ff                	test   %edi,%edi
f01033d6:	75 0e                	jne    f01033e6 <readline+0x8e>
			buf[i] = 0;
f01033d8:	c6 86 60 85 11 f0 00 	movb   $0x0,-0xfee7aa0(%esi)
			return buf;
f01033df:	b8 60 85 11 f0       	mov    $0xf0118560,%eax
f01033e4:	eb bf                	jmp    f01033a5 <readline+0x4d>
				cputchar('\n');
f01033e6:	83 ec 0c             	sub    $0xc,%esp
f01033e9:	6a 0a                	push   $0xa
f01033eb:	e8 96 d2 ff ff       	call   f0100686 <cputchar>
f01033f0:	83 c4 10             	add    $0x10,%esp
f01033f3:	eb e3                	jmp    f01033d8 <readline+0x80>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01033f5:	85 f6                	test   %esi,%esi
f01033f7:	7e 3c                	jle    f0103435 <readline+0xdd>
			if (echoing)
f01033f9:	85 ff                	test   %edi,%edi
f01033fb:	75 b0                	jne    f01033ad <readline+0x55>
			i--;
f01033fd:	4e                   	dec    %esi
		c = getchar();
f01033fe:	e8 93 d2 ff ff       	call   f0100696 <getchar>
f0103403:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103405:	85 c0                	test   %eax,%eax
f0103407:	78 86                	js     f010338f <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103409:	83 f8 08             	cmp    $0x8,%eax
f010340c:	74 21                	je     f010342f <readline+0xd7>
f010340e:	83 f8 7f             	cmp    $0x7f,%eax
f0103411:	74 e2                	je     f01033f5 <readline+0x9d>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103413:	83 f8 1f             	cmp    $0x1f,%eax
f0103416:	7e b2                	jle    f01033ca <readline+0x72>
f0103418:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010341e:	7f aa                	jg     f01033ca <readline+0x72>
			if (echoing)
f0103420:	85 ff                	test   %edi,%edi
f0103422:	75 98                	jne    f01033bc <readline+0x64>
			buf[i++] = c;
f0103424:	88 9e 60 85 11 f0    	mov    %bl,-0xfee7aa0(%esi)
f010342a:	8d 76 01             	lea    0x1(%esi),%esi
f010342d:	eb cf                	jmp    f01033fe <readline+0xa6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010342f:	85 f6                	test   %esi,%esi
f0103431:	7e cb                	jle    f01033fe <readline+0xa6>
f0103433:	eb c4                	jmp    f01033f9 <readline+0xa1>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103435:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010343b:	7e e3                	jle    f0103420 <readline+0xc8>
f010343d:	eb bf                	jmp    f01033fe <readline+0xa6>

f010343f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010343f:	55                   	push   %ebp
f0103440:	89 e5                	mov    %esp,%ebp
f0103442:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103445:	b8 00 00 00 00       	mov    $0x0,%eax
f010344a:	eb 01                	jmp    f010344d <strlen+0xe>
		n++;
f010344c:	40                   	inc    %eax
	for (n = 0; *s != '\0'; s++)
f010344d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103451:	75 f9                	jne    f010344c <strlen+0xd>
	return n;
}
f0103453:	5d                   	pop    %ebp
f0103454:	c3                   	ret    

f0103455 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103455:	55                   	push   %ebp
f0103456:	89 e5                	mov    %esp,%ebp
f0103458:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010345b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010345e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103463:	eb 01                	jmp    f0103466 <strnlen+0x11>
		n++;
f0103465:	40                   	inc    %eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103466:	39 d0                	cmp    %edx,%eax
f0103468:	74 06                	je     f0103470 <strnlen+0x1b>
f010346a:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010346e:	75 f5                	jne    f0103465 <strnlen+0x10>
	return n;
}
f0103470:	5d                   	pop    %ebp
f0103471:	c3                   	ret    

f0103472 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103472:	55                   	push   %ebp
f0103473:	89 e5                	mov    %esp,%ebp
f0103475:	53                   	push   %ebx
f0103476:	8b 45 08             	mov    0x8(%ebp),%eax
f0103479:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010347c:	89 c2                	mov    %eax,%edx
f010347e:	41                   	inc    %ecx
f010347f:	42                   	inc    %edx
f0103480:	8a 59 ff             	mov    -0x1(%ecx),%bl
f0103483:	88 5a ff             	mov    %bl,-0x1(%edx)
f0103486:	84 db                	test   %bl,%bl
f0103488:	75 f4                	jne    f010347e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010348a:	5b                   	pop    %ebx
f010348b:	5d                   	pop    %ebp
f010348c:	c3                   	ret    

f010348d <strcat>:

char *
strcat(char *dst, const char *src)
{
f010348d:	55                   	push   %ebp
f010348e:	89 e5                	mov    %esp,%ebp
f0103490:	53                   	push   %ebx
f0103491:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103494:	53                   	push   %ebx
f0103495:	e8 a5 ff ff ff       	call   f010343f <strlen>
f010349a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010349d:	ff 75 0c             	pushl  0xc(%ebp)
f01034a0:	01 d8                	add    %ebx,%eax
f01034a2:	50                   	push   %eax
f01034a3:	e8 ca ff ff ff       	call   f0103472 <strcpy>
	return dst;
}
f01034a8:	89 d8                	mov    %ebx,%eax
f01034aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01034ad:	c9                   	leave  
f01034ae:	c3                   	ret    

f01034af <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01034af:	55                   	push   %ebp
f01034b0:	89 e5                	mov    %esp,%ebp
f01034b2:	56                   	push   %esi
f01034b3:	53                   	push   %ebx
f01034b4:	8b 75 08             	mov    0x8(%ebp),%esi
f01034b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01034ba:	89 f3                	mov    %esi,%ebx
f01034bc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01034bf:	89 f2                	mov    %esi,%edx
f01034c1:	39 da                	cmp    %ebx,%edx
f01034c3:	74 0e                	je     f01034d3 <strncpy+0x24>
		*dst++ = *src;
f01034c5:	42                   	inc    %edx
f01034c6:	8a 01                	mov    (%ecx),%al
f01034c8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f01034cb:	80 39 00             	cmpb   $0x0,(%ecx)
f01034ce:	74 f1                	je     f01034c1 <strncpy+0x12>
			src++;
f01034d0:	41                   	inc    %ecx
f01034d1:	eb ee                	jmp    f01034c1 <strncpy+0x12>
	}
	return ret;
}
f01034d3:	89 f0                	mov    %esi,%eax
f01034d5:	5b                   	pop    %ebx
f01034d6:	5e                   	pop    %esi
f01034d7:	5d                   	pop    %ebp
f01034d8:	c3                   	ret    

f01034d9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01034d9:	55                   	push   %ebp
f01034da:	89 e5                	mov    %esp,%ebp
f01034dc:	56                   	push   %esi
f01034dd:	53                   	push   %ebx
f01034de:	8b 75 08             	mov    0x8(%ebp),%esi
f01034e1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01034e4:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01034e7:	85 c0                	test   %eax,%eax
f01034e9:	74 20                	je     f010350b <strlcpy+0x32>
f01034eb:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
f01034ef:	89 f0                	mov    %esi,%eax
f01034f1:	eb 05                	jmp    f01034f8 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01034f3:	42                   	inc    %edx
f01034f4:	40                   	inc    %eax
f01034f5:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f01034f8:	39 d8                	cmp    %ebx,%eax
f01034fa:	74 06                	je     f0103502 <strlcpy+0x29>
f01034fc:	8a 0a                	mov    (%edx),%cl
f01034fe:	84 c9                	test   %cl,%cl
f0103500:	75 f1                	jne    f01034f3 <strlcpy+0x1a>
		*dst = '\0';
f0103502:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103505:	29 f0                	sub    %esi,%eax
}
f0103507:	5b                   	pop    %ebx
f0103508:	5e                   	pop    %esi
f0103509:	5d                   	pop    %ebp
f010350a:	c3                   	ret    
f010350b:	89 f0                	mov    %esi,%eax
f010350d:	eb f6                	jmp    f0103505 <strlcpy+0x2c>

f010350f <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010350f:	55                   	push   %ebp
f0103510:	89 e5                	mov    %esp,%ebp
f0103512:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103515:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103518:	eb 02                	jmp    f010351c <strcmp+0xd>
		p++, q++;
f010351a:	41                   	inc    %ecx
f010351b:	42                   	inc    %edx
	while (*p && *p == *q)
f010351c:	8a 01                	mov    (%ecx),%al
f010351e:	84 c0                	test   %al,%al
f0103520:	74 04                	je     f0103526 <strcmp+0x17>
f0103522:	3a 02                	cmp    (%edx),%al
f0103524:	74 f4                	je     f010351a <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103526:	0f b6 c0             	movzbl %al,%eax
f0103529:	0f b6 12             	movzbl (%edx),%edx
f010352c:	29 d0                	sub    %edx,%eax
}
f010352e:	5d                   	pop    %ebp
f010352f:	c3                   	ret    

f0103530 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103530:	55                   	push   %ebp
f0103531:	89 e5                	mov    %esp,%ebp
f0103533:	53                   	push   %ebx
f0103534:	8b 45 08             	mov    0x8(%ebp),%eax
f0103537:	8b 55 0c             	mov    0xc(%ebp),%edx
f010353a:	89 c3                	mov    %eax,%ebx
f010353c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010353f:	eb 02                	jmp    f0103543 <strncmp+0x13>
		n--, p++, q++;
f0103541:	40                   	inc    %eax
f0103542:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
f0103543:	39 d8                	cmp    %ebx,%eax
f0103545:	74 15                	je     f010355c <strncmp+0x2c>
f0103547:	8a 08                	mov    (%eax),%cl
f0103549:	84 c9                	test   %cl,%cl
f010354b:	74 04                	je     f0103551 <strncmp+0x21>
f010354d:	3a 0a                	cmp    (%edx),%cl
f010354f:	74 f0                	je     f0103541 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103551:	0f b6 00             	movzbl (%eax),%eax
f0103554:	0f b6 12             	movzbl (%edx),%edx
f0103557:	29 d0                	sub    %edx,%eax
}
f0103559:	5b                   	pop    %ebx
f010355a:	5d                   	pop    %ebp
f010355b:	c3                   	ret    
		return 0;
f010355c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103561:	eb f6                	jmp    f0103559 <strncmp+0x29>

f0103563 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103563:	55                   	push   %ebp
f0103564:	89 e5                	mov    %esp,%ebp
f0103566:	8b 45 08             	mov    0x8(%ebp),%eax
f0103569:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010356c:	8a 10                	mov    (%eax),%dl
f010356e:	84 d2                	test   %dl,%dl
f0103570:	74 07                	je     f0103579 <strchr+0x16>
		if (*s == c)
f0103572:	38 ca                	cmp    %cl,%dl
f0103574:	74 08                	je     f010357e <strchr+0x1b>
	for (; *s; s++)
f0103576:	40                   	inc    %eax
f0103577:	eb f3                	jmp    f010356c <strchr+0x9>
			return (char *) s;
	return 0;
f0103579:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010357e:	5d                   	pop    %ebp
f010357f:	c3                   	ret    

f0103580 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103580:	55                   	push   %ebp
f0103581:	89 e5                	mov    %esp,%ebp
f0103583:	8b 45 08             	mov    0x8(%ebp),%eax
f0103586:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0103589:	8a 10                	mov    (%eax),%dl
f010358b:	84 d2                	test   %dl,%dl
f010358d:	74 07                	je     f0103596 <strfind+0x16>
		if (*s == c)
f010358f:	38 ca                	cmp    %cl,%dl
f0103591:	74 03                	je     f0103596 <strfind+0x16>
	for (; *s; s++)
f0103593:	40                   	inc    %eax
f0103594:	eb f3                	jmp    f0103589 <strfind+0x9>
			break;
	return (char *) s;
}
f0103596:	5d                   	pop    %ebp
f0103597:	c3                   	ret    

f0103598 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103598:	55                   	push   %ebp
f0103599:	89 e5                	mov    %esp,%ebp
f010359b:	57                   	push   %edi
f010359c:	56                   	push   %esi
f010359d:	53                   	push   %ebx
f010359e:	8b 7d 08             	mov    0x8(%ebp),%edi
f01035a1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01035a4:	85 c9                	test   %ecx,%ecx
f01035a6:	74 13                	je     f01035bb <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01035a8:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01035ae:	75 05                	jne    f01035b5 <memset+0x1d>
f01035b0:	f6 c1 03             	test   $0x3,%cl
f01035b3:	74 0d                	je     f01035c2 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01035b5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035b8:	fc                   	cld    
f01035b9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01035bb:	89 f8                	mov    %edi,%eax
f01035bd:	5b                   	pop    %ebx
f01035be:	5e                   	pop    %esi
f01035bf:	5f                   	pop    %edi
f01035c0:	5d                   	pop    %ebp
f01035c1:	c3                   	ret    
		c &= 0xFF;
f01035c2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01035c6:	89 d3                	mov    %edx,%ebx
f01035c8:	c1 e3 08             	shl    $0x8,%ebx
f01035cb:	89 d0                	mov    %edx,%eax
f01035cd:	c1 e0 18             	shl    $0x18,%eax
f01035d0:	89 d6                	mov    %edx,%esi
f01035d2:	c1 e6 10             	shl    $0x10,%esi
f01035d5:	09 f0                	or     %esi,%eax
f01035d7:	09 c2                	or     %eax,%edx
f01035d9:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f01035db:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01035de:	89 d0                	mov    %edx,%eax
f01035e0:	fc                   	cld    
f01035e1:	f3 ab                	rep stos %eax,%es:(%edi)
f01035e3:	eb d6                	jmp    f01035bb <memset+0x23>

f01035e5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01035e5:	55                   	push   %ebp
f01035e6:	89 e5                	mov    %esp,%ebp
f01035e8:	57                   	push   %edi
f01035e9:	56                   	push   %esi
f01035ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01035ed:	8b 75 0c             	mov    0xc(%ebp),%esi
f01035f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01035f3:	39 c6                	cmp    %eax,%esi
f01035f5:	73 33                	jae    f010362a <memmove+0x45>
f01035f7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01035fa:	39 c2                	cmp    %eax,%edx
f01035fc:	76 2c                	jbe    f010362a <memmove+0x45>
		s += n;
		d += n;
f01035fe:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103601:	89 d6                	mov    %edx,%esi
f0103603:	09 fe                	or     %edi,%esi
f0103605:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010360b:	74 0a                	je     f0103617 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010360d:	4f                   	dec    %edi
f010360e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0103611:	fd                   	std    
f0103612:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103614:	fc                   	cld    
f0103615:	eb 21                	jmp    f0103638 <memmove+0x53>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103617:	f6 c1 03             	test   $0x3,%cl
f010361a:	75 f1                	jne    f010360d <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010361c:	83 ef 04             	sub    $0x4,%edi
f010361f:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103622:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0103625:	fd                   	std    
f0103626:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103628:	eb ea                	jmp    f0103614 <memmove+0x2f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010362a:	89 f2                	mov    %esi,%edx
f010362c:	09 c2                	or     %eax,%edx
f010362e:	f6 c2 03             	test   $0x3,%dl
f0103631:	74 09                	je     f010363c <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103633:	89 c7                	mov    %eax,%edi
f0103635:	fc                   	cld    
f0103636:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103638:	5e                   	pop    %esi
f0103639:	5f                   	pop    %edi
f010363a:	5d                   	pop    %ebp
f010363b:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010363c:	f6 c1 03             	test   $0x3,%cl
f010363f:	75 f2                	jne    f0103633 <memmove+0x4e>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103641:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0103644:	89 c7                	mov    %eax,%edi
f0103646:	fc                   	cld    
f0103647:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103649:	eb ed                	jmp    f0103638 <memmove+0x53>

f010364b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010364b:	55                   	push   %ebp
f010364c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010364e:	ff 75 10             	pushl  0x10(%ebp)
f0103651:	ff 75 0c             	pushl  0xc(%ebp)
f0103654:	ff 75 08             	pushl  0x8(%ebp)
f0103657:	e8 89 ff ff ff       	call   f01035e5 <memmove>
}
f010365c:	c9                   	leave  
f010365d:	c3                   	ret    

f010365e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010365e:	55                   	push   %ebp
f010365f:	89 e5                	mov    %esp,%ebp
f0103661:	56                   	push   %esi
f0103662:	53                   	push   %ebx
f0103663:	8b 45 08             	mov    0x8(%ebp),%eax
f0103666:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103669:	89 c6                	mov    %eax,%esi
f010366b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010366e:	39 f0                	cmp    %esi,%eax
f0103670:	74 16                	je     f0103688 <memcmp+0x2a>
		if (*s1 != *s2)
f0103672:	8a 08                	mov    (%eax),%cl
f0103674:	8a 1a                	mov    (%edx),%bl
f0103676:	38 d9                	cmp    %bl,%cl
f0103678:	75 04                	jne    f010367e <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010367a:	40                   	inc    %eax
f010367b:	42                   	inc    %edx
f010367c:	eb f0                	jmp    f010366e <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f010367e:	0f b6 c1             	movzbl %cl,%eax
f0103681:	0f b6 db             	movzbl %bl,%ebx
f0103684:	29 d8                	sub    %ebx,%eax
f0103686:	eb 05                	jmp    f010368d <memcmp+0x2f>
	}

	return 0;
f0103688:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010368d:	5b                   	pop    %ebx
f010368e:	5e                   	pop    %esi
f010368f:	5d                   	pop    %ebp
f0103690:	c3                   	ret    

f0103691 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103691:	55                   	push   %ebp
f0103692:	89 e5                	mov    %esp,%ebp
f0103694:	8b 45 08             	mov    0x8(%ebp),%eax
f0103697:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010369a:	89 c2                	mov    %eax,%edx
f010369c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010369f:	39 d0                	cmp    %edx,%eax
f01036a1:	73 07                	jae    f01036aa <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
f01036a3:	38 08                	cmp    %cl,(%eax)
f01036a5:	74 03                	je     f01036aa <memfind+0x19>
	for (; s < ends; s++)
f01036a7:	40                   	inc    %eax
f01036a8:	eb f5                	jmp    f010369f <memfind+0xe>
			break;
	return (void *) s;
}
f01036aa:	5d                   	pop    %ebp
f01036ab:	c3                   	ret    

f01036ac <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01036ac:	55                   	push   %ebp
f01036ad:	89 e5                	mov    %esp,%ebp
f01036af:	57                   	push   %edi
f01036b0:	56                   	push   %esi
f01036b1:	53                   	push   %ebx
f01036b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01036b5:	eb 01                	jmp    f01036b8 <strtol+0xc>
		s++;
f01036b7:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f01036b8:	8a 01                	mov    (%ecx),%al
f01036ba:	3c 20                	cmp    $0x20,%al
f01036bc:	74 f9                	je     f01036b7 <strtol+0xb>
f01036be:	3c 09                	cmp    $0x9,%al
f01036c0:	74 f5                	je     f01036b7 <strtol+0xb>

	// plus/minus sign
	if (*s == '+')
f01036c2:	3c 2b                	cmp    $0x2b,%al
f01036c4:	74 2b                	je     f01036f1 <strtol+0x45>
		s++;
	else if (*s == '-')
f01036c6:	3c 2d                	cmp    $0x2d,%al
f01036c8:	74 2f                	je     f01036f9 <strtol+0x4d>
	int neg = 0;
f01036ca:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01036cf:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f01036d6:	75 12                	jne    f01036ea <strtol+0x3e>
f01036d8:	80 39 30             	cmpb   $0x30,(%ecx)
f01036db:	74 24                	je     f0103701 <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01036dd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01036e1:	75 07                	jne    f01036ea <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01036e3:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f01036ea:	b8 00 00 00 00       	mov    $0x0,%eax
f01036ef:	eb 4e                	jmp    f010373f <strtol+0x93>
		s++;
f01036f1:	41                   	inc    %ecx
	int neg = 0;
f01036f2:	bf 00 00 00 00       	mov    $0x0,%edi
f01036f7:	eb d6                	jmp    f01036cf <strtol+0x23>
		s++, neg = 1;
f01036f9:	41                   	inc    %ecx
f01036fa:	bf 01 00 00 00       	mov    $0x1,%edi
f01036ff:	eb ce                	jmp    f01036cf <strtol+0x23>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103701:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0103705:	74 10                	je     f0103717 <strtol+0x6b>
	else if (base == 0 && s[0] == '0')
f0103707:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010370b:	75 dd                	jne    f01036ea <strtol+0x3e>
		s++, base = 8;
f010370d:	41                   	inc    %ecx
f010370e:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f0103715:	eb d3                	jmp    f01036ea <strtol+0x3e>
		s += 2, base = 16;
f0103717:	83 c1 02             	add    $0x2,%ecx
f010371a:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f0103721:	eb c7                	jmp    f01036ea <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0103723:	8d 72 9f             	lea    -0x61(%edx),%esi
f0103726:	89 f3                	mov    %esi,%ebx
f0103728:	80 fb 19             	cmp    $0x19,%bl
f010372b:	77 24                	ja     f0103751 <strtol+0xa5>
			dig = *s - 'a' + 10;
f010372d:	0f be d2             	movsbl %dl,%edx
f0103730:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0103733:	3b 55 10             	cmp    0x10(%ebp),%edx
f0103736:	7d 2b                	jge    f0103763 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
f0103738:	41                   	inc    %ecx
f0103739:	0f af 45 10          	imul   0x10(%ebp),%eax
f010373d:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f010373f:	8a 11                	mov    (%ecx),%dl
f0103741:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0103744:	80 fb 09             	cmp    $0x9,%bl
f0103747:	77 da                	ja     f0103723 <strtol+0x77>
			dig = *s - '0';
f0103749:	0f be d2             	movsbl %dl,%edx
f010374c:	83 ea 30             	sub    $0x30,%edx
f010374f:	eb e2                	jmp    f0103733 <strtol+0x87>
		else if (*s >= 'A' && *s <= 'Z')
f0103751:	8d 72 bf             	lea    -0x41(%edx),%esi
f0103754:	89 f3                	mov    %esi,%ebx
f0103756:	80 fb 19             	cmp    $0x19,%bl
f0103759:	77 08                	ja     f0103763 <strtol+0xb7>
			dig = *s - 'A' + 10;
f010375b:	0f be d2             	movsbl %dl,%edx
f010375e:	83 ea 37             	sub    $0x37,%edx
f0103761:	eb d0                	jmp    f0103733 <strtol+0x87>
		// we don't properly detect overflow!
	}

	if (endptr)
f0103763:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103767:	74 05                	je     f010376e <strtol+0xc2>
		*endptr = (char *) s;
f0103769:	8b 75 0c             	mov    0xc(%ebp),%esi
f010376c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f010376e:	85 ff                	test   %edi,%edi
f0103770:	74 02                	je     f0103774 <strtol+0xc8>
f0103772:	f7 d8                	neg    %eax
}
f0103774:	5b                   	pop    %ebx
f0103775:	5e                   	pop    %esi
f0103776:	5f                   	pop    %edi
f0103777:	5d                   	pop    %ebp
f0103778:	c3                   	ret    

f0103779 <strtoul>:

unsigned long
strtoul(const char *s, char **endptr, int base)
{
f0103779:	55                   	push   %ebp
f010377a:	89 e5                	mov    %esp,%ebp
f010377c:	57                   	push   %edi
f010377d:	56                   	push   %esi
f010377e:	53                   	push   %ebx
f010377f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	unsigned long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103782:	eb 01                	jmp    f0103785 <strtoul+0xc>
		s++;
f0103784:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f0103785:	8a 01                	mov    (%ecx),%al
f0103787:	3c 20                	cmp    $0x20,%al
f0103789:	74 f9                	je     f0103784 <strtoul+0xb>
f010378b:	3c 09                	cmp    $0x9,%al
f010378d:	74 f5                	je     f0103784 <strtoul+0xb>

	// plus/minus sign
	if (*s == '+')
f010378f:	3c 2b                	cmp    $0x2b,%al
f0103791:	74 2b                	je     f01037be <strtoul+0x45>
		s++;
	else if (*s == '-')
f0103793:	3c 2d                	cmp    $0x2d,%al
f0103795:	74 2f                	je     f01037c6 <strtoul+0x4d>
	int neg = 0;
f0103797:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010379c:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f01037a3:	75 12                	jne    f01037b7 <strtoul+0x3e>
f01037a5:	80 39 30             	cmpb   $0x30,(%ecx)
f01037a8:	74 24                	je     f01037ce <strtoul+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01037aa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01037ae:	75 07                	jne    f01037b7 <strtoul+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01037b0:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f01037b7:	b8 00 00 00 00       	mov    $0x0,%eax
f01037bc:	eb 4e                	jmp    f010380c <strtoul+0x93>
		s++;
f01037be:	41                   	inc    %ecx
	int neg = 0;
f01037bf:	bf 00 00 00 00       	mov    $0x0,%edi
f01037c4:	eb d6                	jmp    f010379c <strtoul+0x23>
		s++, neg = 1;
f01037c6:	41                   	inc    %ecx
f01037c7:	bf 01 00 00 00       	mov    $0x1,%edi
f01037cc:	eb ce                	jmp    f010379c <strtoul+0x23>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01037ce:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01037d2:	74 10                	je     f01037e4 <strtoul+0x6b>
	else if (base == 0 && s[0] == '0')
f01037d4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01037d8:	75 dd                	jne    f01037b7 <strtoul+0x3e>
		s++, base = 8;
f01037da:	41                   	inc    %ecx
f01037db:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f01037e2:	eb d3                	jmp    f01037b7 <strtoul+0x3e>
		s += 2, base = 16;
f01037e4:	83 c1 02             	add    $0x2,%ecx
f01037e7:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f01037ee:	eb c7                	jmp    f01037b7 <strtoul+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01037f0:	8d 72 9f             	lea    -0x61(%edx),%esi
f01037f3:	89 f3                	mov    %esi,%ebx
f01037f5:	80 fb 19             	cmp    $0x19,%bl
f01037f8:	77 24                	ja     f010381e <strtoul+0xa5>
			dig = *s - 'a' + 10;
f01037fa:	0f be d2             	movsbl %dl,%edx
f01037fd:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0103800:	3b 55 10             	cmp    0x10(%ebp),%edx
f0103803:	7d 2b                	jge    f0103830 <strtoul+0xb7>
			break;
		s++, val = (val * base) + dig;
f0103805:	41                   	inc    %ecx
f0103806:	0f af 45 10          	imul   0x10(%ebp),%eax
f010380a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f010380c:	8a 11                	mov    (%ecx),%dl
f010380e:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0103811:	80 fb 09             	cmp    $0x9,%bl
f0103814:	77 da                	ja     f01037f0 <strtoul+0x77>
			dig = *s - '0';
f0103816:	0f be d2             	movsbl %dl,%edx
f0103819:	83 ea 30             	sub    $0x30,%edx
f010381c:	eb e2                	jmp    f0103800 <strtoul+0x87>
		else if (*s >= 'A' && *s <= 'Z')
f010381e:	8d 72 bf             	lea    -0x41(%edx),%esi
f0103821:	89 f3                	mov    %esi,%ebx
f0103823:	80 fb 19             	cmp    $0x19,%bl
f0103826:	77 08                	ja     f0103830 <strtoul+0xb7>
			dig = *s - 'A' + 10;
f0103828:	0f be d2             	movsbl %dl,%edx
f010382b:	83 ea 37             	sub    $0x37,%edx
f010382e:	eb d0                	jmp    f0103800 <strtoul+0x87>
		// we don't properly detect overflow!
	}

	if (endptr)
f0103830:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103834:	74 05                	je     f010383b <strtoul+0xc2>
		*endptr = (char *) s;
f0103836:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103839:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f010383b:	85 ff                	test   %edi,%edi
f010383d:	74 02                	je     f0103841 <strtoul+0xc8>
f010383f:	f7 d8                	neg    %eax
}
f0103841:	5b                   	pop    %ebx
f0103842:	5e                   	pop    %esi
f0103843:	5f                   	pop    %edi
f0103844:	5d                   	pop    %ebp
f0103845:	c3                   	ret    
f0103846:	66 90                	xchg   %ax,%ax

f0103848 <__udivdi3>:
f0103848:	55                   	push   %ebp
f0103849:	57                   	push   %edi
f010384a:	56                   	push   %esi
f010384b:	53                   	push   %ebx
f010384c:	83 ec 1c             	sub    $0x1c,%esp
f010384f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0103853:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103857:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010385b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010385f:	85 d2                	test   %edx,%edx
f0103861:	75 2d                	jne    f0103890 <__udivdi3+0x48>
f0103863:	39 f7                	cmp    %esi,%edi
f0103865:	77 59                	ja     f01038c0 <__udivdi3+0x78>
f0103867:	89 f9                	mov    %edi,%ecx
f0103869:	85 ff                	test   %edi,%edi
f010386b:	75 0b                	jne    f0103878 <__udivdi3+0x30>
f010386d:	b8 01 00 00 00       	mov    $0x1,%eax
f0103872:	31 d2                	xor    %edx,%edx
f0103874:	f7 f7                	div    %edi
f0103876:	89 c1                	mov    %eax,%ecx
f0103878:	31 d2                	xor    %edx,%edx
f010387a:	89 f0                	mov    %esi,%eax
f010387c:	f7 f1                	div    %ecx
f010387e:	89 c3                	mov    %eax,%ebx
f0103880:	89 e8                	mov    %ebp,%eax
f0103882:	f7 f1                	div    %ecx
f0103884:	89 da                	mov    %ebx,%edx
f0103886:	83 c4 1c             	add    $0x1c,%esp
f0103889:	5b                   	pop    %ebx
f010388a:	5e                   	pop    %esi
f010388b:	5f                   	pop    %edi
f010388c:	5d                   	pop    %ebp
f010388d:	c3                   	ret    
f010388e:	66 90                	xchg   %ax,%ax
f0103890:	39 f2                	cmp    %esi,%edx
f0103892:	77 1c                	ja     f01038b0 <__udivdi3+0x68>
f0103894:	0f bd da             	bsr    %edx,%ebx
f0103897:	83 f3 1f             	xor    $0x1f,%ebx
f010389a:	75 38                	jne    f01038d4 <__udivdi3+0x8c>
f010389c:	39 f2                	cmp    %esi,%edx
f010389e:	72 08                	jb     f01038a8 <__udivdi3+0x60>
f01038a0:	39 ef                	cmp    %ebp,%edi
f01038a2:	0f 87 98 00 00 00    	ja     f0103940 <__udivdi3+0xf8>
f01038a8:	b8 01 00 00 00       	mov    $0x1,%eax
f01038ad:	eb 05                	jmp    f01038b4 <__udivdi3+0x6c>
f01038af:	90                   	nop
f01038b0:	31 db                	xor    %ebx,%ebx
f01038b2:	31 c0                	xor    %eax,%eax
f01038b4:	89 da                	mov    %ebx,%edx
f01038b6:	83 c4 1c             	add    $0x1c,%esp
f01038b9:	5b                   	pop    %ebx
f01038ba:	5e                   	pop    %esi
f01038bb:	5f                   	pop    %edi
f01038bc:	5d                   	pop    %ebp
f01038bd:	c3                   	ret    
f01038be:	66 90                	xchg   %ax,%ax
f01038c0:	89 e8                	mov    %ebp,%eax
f01038c2:	89 f2                	mov    %esi,%edx
f01038c4:	f7 f7                	div    %edi
f01038c6:	31 db                	xor    %ebx,%ebx
f01038c8:	89 da                	mov    %ebx,%edx
f01038ca:	83 c4 1c             	add    $0x1c,%esp
f01038cd:	5b                   	pop    %ebx
f01038ce:	5e                   	pop    %esi
f01038cf:	5f                   	pop    %edi
f01038d0:	5d                   	pop    %ebp
f01038d1:	c3                   	ret    
f01038d2:	66 90                	xchg   %ax,%ax
f01038d4:	b8 20 00 00 00       	mov    $0x20,%eax
f01038d9:	29 d8                	sub    %ebx,%eax
f01038db:	88 d9                	mov    %bl,%cl
f01038dd:	d3 e2                	shl    %cl,%edx
f01038df:	89 54 24 08          	mov    %edx,0x8(%esp)
f01038e3:	89 fa                	mov    %edi,%edx
f01038e5:	88 c1                	mov    %al,%cl
f01038e7:	d3 ea                	shr    %cl,%edx
f01038e9:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01038ed:	09 d1                	or     %edx,%ecx
f01038ef:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01038f3:	88 d9                	mov    %bl,%cl
f01038f5:	d3 e7                	shl    %cl,%edi
f01038f7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01038fb:	89 f7                	mov    %esi,%edi
f01038fd:	88 c1                	mov    %al,%cl
f01038ff:	d3 ef                	shr    %cl,%edi
f0103901:	88 d9                	mov    %bl,%cl
f0103903:	d3 e6                	shl    %cl,%esi
f0103905:	89 ea                	mov    %ebp,%edx
f0103907:	88 c1                	mov    %al,%cl
f0103909:	d3 ea                	shr    %cl,%edx
f010390b:	09 d6                	or     %edx,%esi
f010390d:	89 f0                	mov    %esi,%eax
f010390f:	89 fa                	mov    %edi,%edx
f0103911:	f7 74 24 08          	divl   0x8(%esp)
f0103915:	89 d7                	mov    %edx,%edi
f0103917:	89 c6                	mov    %eax,%esi
f0103919:	f7 64 24 0c          	mull   0xc(%esp)
f010391d:	39 d7                	cmp    %edx,%edi
f010391f:	72 13                	jb     f0103934 <__udivdi3+0xec>
f0103921:	74 09                	je     f010392c <__udivdi3+0xe4>
f0103923:	89 f0                	mov    %esi,%eax
f0103925:	31 db                	xor    %ebx,%ebx
f0103927:	eb 8b                	jmp    f01038b4 <__udivdi3+0x6c>
f0103929:	8d 76 00             	lea    0x0(%esi),%esi
f010392c:	88 d9                	mov    %bl,%cl
f010392e:	d3 e5                	shl    %cl,%ebp
f0103930:	39 c5                	cmp    %eax,%ebp
f0103932:	73 ef                	jae    f0103923 <__udivdi3+0xdb>
f0103934:	8d 46 ff             	lea    -0x1(%esi),%eax
f0103937:	31 db                	xor    %ebx,%ebx
f0103939:	e9 76 ff ff ff       	jmp    f01038b4 <__udivdi3+0x6c>
f010393e:	66 90                	xchg   %ax,%ax
f0103940:	31 c0                	xor    %eax,%eax
f0103942:	e9 6d ff ff ff       	jmp    f01038b4 <__udivdi3+0x6c>
f0103947:	90                   	nop

f0103948 <__umoddi3>:
f0103948:	55                   	push   %ebp
f0103949:	57                   	push   %edi
f010394a:	56                   	push   %esi
f010394b:	53                   	push   %ebx
f010394c:	83 ec 1c             	sub    $0x1c,%esp
f010394f:	8b 74 24 30          	mov    0x30(%esp),%esi
f0103953:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0103957:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010395b:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f010395f:	89 f0                	mov    %esi,%eax
f0103961:	89 da                	mov    %ebx,%edx
f0103963:	85 ed                	test   %ebp,%ebp
f0103965:	75 15                	jne    f010397c <__umoddi3+0x34>
f0103967:	39 df                	cmp    %ebx,%edi
f0103969:	76 39                	jbe    f01039a4 <__umoddi3+0x5c>
f010396b:	f7 f7                	div    %edi
f010396d:	89 d0                	mov    %edx,%eax
f010396f:	31 d2                	xor    %edx,%edx
f0103971:	83 c4 1c             	add    $0x1c,%esp
f0103974:	5b                   	pop    %ebx
f0103975:	5e                   	pop    %esi
f0103976:	5f                   	pop    %edi
f0103977:	5d                   	pop    %ebp
f0103978:	c3                   	ret    
f0103979:	8d 76 00             	lea    0x0(%esi),%esi
f010397c:	39 dd                	cmp    %ebx,%ebp
f010397e:	77 f1                	ja     f0103971 <__umoddi3+0x29>
f0103980:	0f bd cd             	bsr    %ebp,%ecx
f0103983:	83 f1 1f             	xor    $0x1f,%ecx
f0103986:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010398a:	75 38                	jne    f01039c4 <__umoddi3+0x7c>
f010398c:	39 dd                	cmp    %ebx,%ebp
f010398e:	72 04                	jb     f0103994 <__umoddi3+0x4c>
f0103990:	39 f7                	cmp    %esi,%edi
f0103992:	77 dd                	ja     f0103971 <__umoddi3+0x29>
f0103994:	89 da                	mov    %ebx,%edx
f0103996:	89 f0                	mov    %esi,%eax
f0103998:	29 f8                	sub    %edi,%eax
f010399a:	19 ea                	sbb    %ebp,%edx
f010399c:	83 c4 1c             	add    $0x1c,%esp
f010399f:	5b                   	pop    %ebx
f01039a0:	5e                   	pop    %esi
f01039a1:	5f                   	pop    %edi
f01039a2:	5d                   	pop    %ebp
f01039a3:	c3                   	ret    
f01039a4:	89 f9                	mov    %edi,%ecx
f01039a6:	85 ff                	test   %edi,%edi
f01039a8:	75 0b                	jne    f01039b5 <__umoddi3+0x6d>
f01039aa:	b8 01 00 00 00       	mov    $0x1,%eax
f01039af:	31 d2                	xor    %edx,%edx
f01039b1:	f7 f7                	div    %edi
f01039b3:	89 c1                	mov    %eax,%ecx
f01039b5:	89 d8                	mov    %ebx,%eax
f01039b7:	31 d2                	xor    %edx,%edx
f01039b9:	f7 f1                	div    %ecx
f01039bb:	89 f0                	mov    %esi,%eax
f01039bd:	f7 f1                	div    %ecx
f01039bf:	eb ac                	jmp    f010396d <__umoddi3+0x25>
f01039c1:	8d 76 00             	lea    0x0(%esi),%esi
f01039c4:	b8 20 00 00 00       	mov    $0x20,%eax
f01039c9:	89 c2                	mov    %eax,%edx
f01039cb:	8b 44 24 04          	mov    0x4(%esp),%eax
f01039cf:	29 c2                	sub    %eax,%edx
f01039d1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01039d5:	88 c1                	mov    %al,%cl
f01039d7:	d3 e5                	shl    %cl,%ebp
f01039d9:	89 f8                	mov    %edi,%eax
f01039db:	88 d1                	mov    %dl,%cl
f01039dd:	d3 e8                	shr    %cl,%eax
f01039df:	09 c5                	or     %eax,%ebp
f01039e1:	8b 44 24 04          	mov    0x4(%esp),%eax
f01039e5:	88 c1                	mov    %al,%cl
f01039e7:	d3 e7                	shl    %cl,%edi
f01039e9:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01039ed:	89 df                	mov    %ebx,%edi
f01039ef:	88 d1                	mov    %dl,%cl
f01039f1:	d3 ef                	shr    %cl,%edi
f01039f3:	88 c1                	mov    %al,%cl
f01039f5:	d3 e3                	shl    %cl,%ebx
f01039f7:	89 f0                	mov    %esi,%eax
f01039f9:	88 d1                	mov    %dl,%cl
f01039fb:	d3 e8                	shr    %cl,%eax
f01039fd:	09 d8                	or     %ebx,%eax
f01039ff:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0103a03:	d3 e6                	shl    %cl,%esi
f0103a05:	89 fa                	mov    %edi,%edx
f0103a07:	f7 f5                	div    %ebp
f0103a09:	89 d1                	mov    %edx,%ecx
f0103a0b:	f7 64 24 08          	mull   0x8(%esp)
f0103a0f:	89 c3                	mov    %eax,%ebx
f0103a11:	89 d7                	mov    %edx,%edi
f0103a13:	39 d1                	cmp    %edx,%ecx
f0103a15:	72 29                	jb     f0103a40 <__umoddi3+0xf8>
f0103a17:	74 23                	je     f0103a3c <__umoddi3+0xf4>
f0103a19:	89 ca                	mov    %ecx,%edx
f0103a1b:	29 de                	sub    %ebx,%esi
f0103a1d:	19 fa                	sbb    %edi,%edx
f0103a1f:	89 d0                	mov    %edx,%eax
f0103a21:	8a 4c 24 0c          	mov    0xc(%esp),%cl
f0103a25:	d3 e0                	shl    %cl,%eax
f0103a27:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0103a2b:	88 d9                	mov    %bl,%cl
f0103a2d:	d3 ee                	shr    %cl,%esi
f0103a2f:	09 f0                	or     %esi,%eax
f0103a31:	d3 ea                	shr    %cl,%edx
f0103a33:	83 c4 1c             	add    $0x1c,%esp
f0103a36:	5b                   	pop    %ebx
f0103a37:	5e                   	pop    %esi
f0103a38:	5f                   	pop    %edi
f0103a39:	5d                   	pop    %ebp
f0103a3a:	c3                   	ret    
f0103a3b:	90                   	nop
f0103a3c:	39 c6                	cmp    %eax,%esi
f0103a3e:	73 d9                	jae    f0103a19 <__umoddi3+0xd1>
f0103a40:	2b 44 24 08          	sub    0x8(%esp),%eax
f0103a44:	19 ea                	sbb    %ebp,%edx
f0103a46:	89 d7                	mov    %edx,%edi
f0103a48:	89 c3                	mov    %eax,%ebx
f0103a4a:	eb cd                	jmp    f0103a19 <__umoddi3+0xd1>
