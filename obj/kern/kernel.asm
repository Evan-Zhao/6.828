
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
f010004b:	68 c0 38 10 f0       	push   $0xf01038c0
f0100050:	e8 3b 29 00 00       	call   f0102990 <cprintf>
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
f0100071:	68 dc 38 10 f0       	push   $0xf01038dc
f0100076:	e8 15 29 00 00       	call   f0102990 <cprintf>
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
f01000ac:	e8 0e 34 00 00       	call   f01034bf <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 d8 04 00 00       	call   f010058e <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 f7 38 10 f0       	push   $0xf01038f7
f01000c3:	e8 c8 28 00 00       	call   f0102990 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000c8:	e8 51 10 00 00       	call   f010111e <mem_init>
	cprintf(ANSI_COLOR_RED     "This text is RED!"     ANSI_COLOR_RESET "\n");
f01000cd:	c7 04 24 12 39 10 f0 	movl   $0xf0103912,(%esp)
f01000d4:	e8 b7 28 00 00       	call   f0102990 <cprintf>
	cprintf(ANSI_COLOR_GREEN   "This text is GREEN!"   ANSI_COLOR_RESET "\n");
f01000d9:	c7 04 24 2e 39 10 f0 	movl   $0xf010392e,(%esp)
f01000e0:	e8 ab 28 00 00       	call   f0102990 <cprintf>
	cprintf(ANSI_COLOR_YELLOW  "This text is YELLOW!"  ANSI_COLOR_RESET "\n");
f01000e5:	c7 04 24 b8 39 10 f0 	movl   $0xf01039b8,(%esp)
f01000ec:	e8 9f 28 00 00       	call   f0102990 <cprintf>
	cprintf(ANSI_COLOR_BLUE    "This text is BLUE!"    ANSI_COLOR_RESET "\n");
f01000f1:	c7 04 24 4c 39 10 f0 	movl   $0xf010394c,(%esp)
f01000f8:	e8 93 28 00 00       	call   f0102990 <cprintf>
	cprintf(ANSI_COLOR_MAGENTA "This text is MAGENTA!" ANSI_COLOR_RESET "\n");
f01000fd:	c7 04 24 d8 39 10 f0 	movl   $0xf01039d8,(%esp)
f0100104:	e8 87 28 00 00       	call   f0102990 <cprintf>
	cprintf(ANSI_COLOR_CYAN    "This text is CYAN!"    ANSI_COLOR_RESET "\n");
f0100109:	c7 04 24 69 39 10 f0 	movl   $0xf0103969,(%esp)
f0100110:	e8 7b 28 00 00       	call   f0102990 <cprintf>

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
f010013b:	83 3d 60 89 11 f0 00 	cmpl   $0x0,0xf0118960
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
f0100167:	68 86 39 10 f0       	push   $0xf0103986
f010016c:	e8 1f 28 00 00       	call   f0102990 <cprintf>
	vcprintf(fmt, ap);
f0100171:	83 c4 08             	add    $0x8,%esp
f0100174:	53                   	push   %ebx
f0100175:	56                   	push   %esi
f0100176:	e8 ef 27 00 00       	call   f010296a <vcprintf>
	cprintf("\n");
f010017b:	c7 04 24 14 49 10 f0 	movl   $0xf0104914,(%esp)
f0100182:	e8 09 28 00 00       	call   f0102990 <cprintf>
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
f010019c:	68 9e 39 10 f0       	push   $0xf010399e
f01001a1:	e8 ea 27 00 00       	call   f0102990 <cprintf>
	vcprintf(fmt, ap);
f01001a6:	83 c4 08             	add    $0x8,%esp
f01001a9:	53                   	push   %ebx
f01001aa:	ff 75 10             	pushl  0x10(%ebp)
f01001ad:	e8 b8 27 00 00       	call   f010296a <vcprintf>
	cprintf("\n");
f01001b2:	c7 04 24 14 49 10 f0 	movl   $0xf0104914,(%esp)
f01001b9:	e8 d2 27 00 00       	call   f0102990 <cprintf>
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
f0100279:	0f b6 82 60 3b 10 f0 	movzbl -0xfefc4a0(%edx),%eax
f0100280:	0b 05 00 83 11 f0    	or     0xf0118300,%eax
	shift ^= togglecode[data];
f0100286:	0f b6 8a 60 3a 10 f0 	movzbl -0xfefc5a0(%edx),%ecx
f010028d:	31 c8                	xor    %ecx,%eax
f010028f:	a3 00 83 11 f0       	mov    %eax,0xf0118300
	c = charcode[shift & (CTL | SHIFT)][data];
f0100294:	89 c1                	mov    %eax,%ecx
f0100296:	83 e1 03             	and    $0x3,%ecx
f0100299:	8b 0c 8d 40 3a 10 f0 	mov    -0xfefc5c0(,%ecx,4),%ecx
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
f01002c8:	68 f8 39 10 f0       	push   $0xf01039f8
f01002cd:	e8 be 26 00 00       	call   f0102990 <cprintf>
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
f0100305:	8a 82 60 3b 10 f0    	mov    -0xfefc4a0(%edx),%al
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
f01004e3:	e8 24 30 00 00       	call   f010350c <memmove>
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
f0100677:	68 04 3a 10 f0       	push   $0xf0103a04
f010067c:	e8 0f 23 00 00       	call   f0102990 <cprintf>
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
f01006b7:	68 60 3c 10 f0       	push   $0xf0103c60
f01006bc:	68 7e 3c 10 f0       	push   $0xf0103c7e
f01006c1:	68 83 3c 10 f0       	push   $0xf0103c83
f01006c6:	e8 c5 22 00 00       	call   f0102990 <cprintf>
f01006cb:	83 c4 0c             	add    $0xc,%esp
f01006ce:	68 18 3d 10 f0       	push   $0xf0103d18
f01006d3:	68 8c 3c 10 f0       	push   $0xf0103c8c
f01006d8:	68 83 3c 10 f0       	push   $0xf0103c83
f01006dd:	e8 ae 22 00 00       	call   f0102990 <cprintf>
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
f01006ef:	68 95 3c 10 f0       	push   $0xf0103c95
f01006f4:	e8 97 22 00 00       	call   f0102990 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006f9:	83 c4 08             	add    $0x8,%esp
f01006fc:	68 0c 00 10 00       	push   $0x10000c
f0100701:	68 40 3d 10 f0       	push   $0xf0103d40
f0100706:	e8 85 22 00 00       	call   f0102990 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010070b:	83 c4 0c             	add    $0xc,%esp
f010070e:	68 0c 00 10 00       	push   $0x10000c
f0100713:	68 0c 00 10 f0       	push   $0xf010000c
f0100718:	68 68 3d 10 f0       	push   $0xf0103d68
f010071d:	e8 6e 22 00 00       	call   f0102990 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100722:	83 c4 0c             	add    $0xc,%esp
f0100725:	68 a4 38 10 00       	push   $0x1038a4
f010072a:	68 a4 38 10 f0       	push   $0xf01038a4
f010072f:	68 8c 3d 10 f0       	push   $0xf0103d8c
f0100734:	e8 57 22 00 00       	call   f0102990 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100739:	83 c4 0c             	add    $0xc,%esp
f010073c:	68 00 83 11 00       	push   $0x118300
f0100741:	68 00 83 11 f0       	push   $0xf0118300
f0100746:	68 b0 3d 10 f0       	push   $0xf0103db0
f010074b:	e8 40 22 00 00       	call   f0102990 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100750:	83 c4 0c             	add    $0xc,%esp
f0100753:	68 70 89 11 00       	push   $0x118970
f0100758:	68 70 89 11 f0       	push   $0xf0118970
f010075d:	68 d4 3d 10 f0       	push   $0xf0103dd4
f0100762:	e8 29 22 00 00       	call   f0102990 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100767:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010076a:	b8 6f 8d 11 f0       	mov    $0xf0118d6f,%eax
f010076f:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100774:	c1 f8 0a             	sar    $0xa,%eax
f0100777:	50                   	push   %eax
f0100778:	68 f8 3d 10 f0       	push   $0xf0103df8
f010077d:	e8 0e 22 00 00       	call   f0102990 <cprintf>
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
f0100792:	68 ae 3c 10 f0       	push   $0xf0103cae
f0100797:	e8 f4 21 00 00       	call   f0102990 <cprintf>

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
f01007ae:	68 d1 3c 10 f0       	push   $0xf0103cd1
f01007b3:	e8 d8 21 00 00       	call   f0102990 <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f01007b8:	43                   	inc    %ebx
f01007b9:	83 c4 10             	add    $0x10,%esp
f01007bc:	39 5d dc             	cmp    %ebx,-0x24(%ebp)
f01007bf:	7f e2                	jg     f01007a3 <mon_backtrace+0x1a>
		cprintf("+%d\n", eip - info.eip_fn_addr);
f01007c1:	83 ec 08             	sub    $0x8,%esp
f01007c4:	2b 75 e0             	sub    -0x20(%ebp),%esi
f01007c7:	56                   	push   %esi
f01007c8:	68 d4 3c 10 f0       	push   $0xf0103cd4
f01007cd:	e8 be 21 00 00       	call   f0102990 <cprintf>
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
f01007f1:	68 24 3e 10 f0       	push   $0xf0103e24
f01007f6:	e8 95 21 00 00       	call   f0102990 <cprintf>
		int code = debuginfo_eip((uintptr_t)eip, &info);
f01007fb:	83 c4 18             	add    $0x18,%esp
f01007fe:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100801:	50                   	push   %eax
f0100802:	56                   	push   %esi
f0100803:	e8 89 22 00 00       	call   f0102a91 <debuginfo_eip>
		cprintf("         %s:%d: ", info.eip_file, info.eip_line);
f0100808:	83 c4 0c             	add    $0xc,%esp
f010080b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010080e:	ff 75 d0             	pushl  -0x30(%ebp)
f0100811:	68 c0 3c 10 f0       	push   $0xf0103cc0
f0100816:	e8 75 21 00 00       	call   f0102990 <cprintf>
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
f0100836:	68 5c 3e 10 f0       	push   $0xf0103e5c
f010083b:	e8 50 21 00 00       	call   f0102990 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100840:	c7 04 24 80 3e 10 f0 	movl   $0xf0103e80,(%esp)
f0100847:	e8 44 21 00 00       	call   f0102990 <cprintf>
f010084c:	83 c4 10             	add    $0x10,%esp
f010084f:	eb 47                	jmp    f0100898 <monitor+0x6b>
		while (*buf && strchr(WHITESPACE, *buf))
f0100851:	83 ec 08             	sub    $0x8,%esp
f0100854:	0f be c0             	movsbl %al,%eax
f0100857:	50                   	push   %eax
f0100858:	68 dd 3c 10 f0       	push   $0xf0103cdd
f010085d:	e8 28 2c 00 00       	call   f010348a <strchr>
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
f010088b:	68 e2 3c 10 f0       	push   $0xf0103ce2
f0100890:	e8 fb 20 00 00       	call   f0102990 <cprintf>
f0100895:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100898:	83 ec 0c             	sub    $0xc,%esp
f010089b:	68 d9 3c 10 f0       	push   $0xf0103cd9
f01008a0:	e8 da 29 00 00       	call   f010327f <readline>
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
f01008ca:	68 dd 3c 10 f0       	push   $0xf0103cdd
f01008cf:	e8 b6 2b 00 00       	call   f010348a <strchr>
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
f01008f6:	68 7e 3c 10 f0       	push   $0xf0103c7e
f01008fb:	ff 75 a8             	pushl  -0x58(%ebp)
f01008fe:	e8 33 2b 00 00       	call   f0103436 <strcmp>
f0100903:	83 c4 10             	add    $0x10,%esp
f0100906:	85 c0                	test   %eax,%eax
f0100908:	74 34                	je     f010093e <monitor+0x111>
f010090a:	83 ec 08             	sub    $0x8,%esp
f010090d:	68 8c 3c 10 f0       	push   $0xf0103c8c
f0100912:	ff 75 a8             	pushl  -0x58(%ebp)
f0100915:	e8 1c 2b 00 00       	call   f0103436 <strcmp>
f010091a:	83 c4 10             	add    $0x10,%esp
f010091d:	85 c0                	test   %eax,%eax
f010091f:	74 18                	je     f0100939 <monitor+0x10c>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100921:	83 ec 08             	sub    $0x8,%esp
f0100924:	ff 75 a8             	pushl  -0x58(%ebp)
f0100927:	68 ff 3c 10 f0       	push   $0xf0103cff
f010092c:	e8 5f 20 00 00       	call   f0102990 <cprintf>
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
f010094e:	ff 14 85 b0 3e 10 f0 	call   *-0xfefc150(,%eax,4)
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
f010096b:	83 3d 38 85 11 f0 00 	cmpl   $0x0,0xf0118538
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
f0100978:	8b 15 38 85 11 f0    	mov    0xf0118538,%edx
		nextfree = ROUNDUP(nextfree + n, PGSIZE);
f010097e:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100985:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010098a:	a3 38 85 11 f0       	mov    %eax,0xf0118538
		return (void*)result;
	}
}
f010098f:	89 d0                	mov    %edx,%eax
f0100991:	5d                   	pop    %ebp
f0100992:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100993:	ba 6f 99 11 f0       	mov    $0xf011996f,%edx
f0100998:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010099e:	89 15 38 85 11 f0    	mov    %edx,0xf0118538
f01009a4:	eb ce                	jmp    f0100974 <boot_alloc+0xc>
		return (void*)nextfree;
f01009a6:	8b 15 38 85 11 f0    	mov    0xf0118538,%edx
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
f01009b9:	e8 6b 1f 00 00       	call   f0102929 <mc146818_read>
f01009be:	89 c3                	mov    %eax,%ebx
f01009c0:	46                   	inc    %esi
f01009c1:	89 34 24             	mov    %esi,(%esp)
f01009c4:	e8 60 1f 00 00       	call   f0102929 <mc146818_read>
f01009c9:	c1 e0 08             	shl    $0x8,%eax
f01009cc:	09 d8                	or     %ebx,%eax
}
f01009ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01009d1:	5b                   	pop    %ebx
f01009d2:	5e                   	pop    %esi
f01009d3:	5d                   	pop    %ebp
f01009d4:	c3                   	ret    

f01009d5 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f01009d5:	89 d1                	mov    %edx,%ecx
f01009d7:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P)) {
f01009da:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01009dd:	a8 01                	test   $0x1,%al
f01009df:	74 47                	je     f0100a28 <check_va2pa+0x53>
		//cprintf("Here at %d th\n", PDX(va));
		return ~0;
	}
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01009e1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01009e6:	89 c1                	mov    %eax,%ecx
f01009e8:	c1 e9 0c             	shr    $0xc,%ecx
f01009eb:	3b 0d 64 89 11 f0    	cmp    0xf0118964,%ecx
f01009f1:	73 1a                	jae    f0100a0d <check_va2pa+0x38>
	if (!(p[PTX(va)] & PTE_P))
f01009f3:	c1 ea 0c             	shr    $0xc,%edx
f01009f6:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01009fc:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100a03:	a8 01                	test   $0x1,%al
f0100a05:	74 27                	je     f0100a2e <check_va2pa+0x59>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a07:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a0c:	c3                   	ret    
{
f0100a0d:	55                   	push   %ebp
f0100a0e:	89 e5                	mov    %esp,%ebp
f0100a10:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a13:	50                   	push   %eax
f0100a14:	68 c0 3e 10 f0       	push   $0xf0103ec0
f0100a19:	68 c6 02 00 00       	push   $0x2c6
f0100a1e:	68 38 46 10 f0       	push   $0xf0104638
f0100a23:	e8 0b f7 ff ff       	call   f0100133 <_panic>
		return ~0;
f0100a28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100a2d:	c3                   	ret    
		return ~0;
f0100a2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100a33:	c3                   	ret    

f0100a34 <check_page_free_list>:
{
f0100a34:	55                   	push   %ebp
f0100a35:	89 e5                	mov    %esp,%ebp
f0100a37:	57                   	push   %edi
f0100a38:	56                   	push   %esi
f0100a39:	53                   	push   %ebx
f0100a3a:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a3d:	84 c0                	test   %al,%al
f0100a3f:	0f 85 50 02 00 00    	jne    f0100c95 <check_page_free_list+0x261>
	if (!page_free_list)
f0100a45:	83 3d 3c 85 11 f0 00 	cmpl   $0x0,0xf011853c
f0100a4c:	74 0a                	je     f0100a58 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a4e:	be 00 04 00 00       	mov    $0x400,%esi
f0100a53:	e9 98 02 00 00       	jmp    f0100cf0 <check_page_free_list+0x2bc>
		panic("'page_free_list' is a null pointer!");
f0100a58:	83 ec 04             	sub    $0x4,%esp
f0100a5b:	68 e4 3e 10 f0       	push   $0xf0103ee4
f0100a60:	68 04 02 00 00       	push   $0x204
f0100a65:	68 38 46 10 f0       	push   $0xf0104638
f0100a6a:	e8 c4 f6 ff ff       	call   f0100133 <_panic>
f0100a6f:	50                   	push   %eax
f0100a70:	68 c0 3e 10 f0       	push   $0xf0103ec0
f0100a75:	6a 52                	push   $0x52
f0100a77:	68 44 46 10 f0       	push   $0xf0104644
f0100a7c:	e8 b2 f6 ff ff       	call   f0100133 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a81:	8b 1b                	mov    (%ebx),%ebx
f0100a83:	85 db                	test   %ebx,%ebx
f0100a85:	74 41                	je     f0100ac8 <check_page_free_list+0x94>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a87:	89 d8                	mov    %ebx,%eax
f0100a89:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0100a8f:	c1 f8 03             	sar    $0x3,%eax
f0100a92:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100a95:	89 c2                	mov    %eax,%edx
f0100a97:	c1 ea 16             	shr    $0x16,%edx
f0100a9a:	39 f2                	cmp    %esi,%edx
f0100a9c:	73 e3                	jae    f0100a81 <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100a9e:	89 c2                	mov    %eax,%edx
f0100aa0:	c1 ea 0c             	shr    $0xc,%edx
f0100aa3:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f0100aa9:	73 c4                	jae    f0100a6f <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100aab:	83 ec 04             	sub    $0x4,%esp
f0100aae:	68 80 00 00 00       	push   $0x80
f0100ab3:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100ab8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100abd:	50                   	push   %eax
f0100abe:	e8 fc 29 00 00       	call   f01034bf <memset>
f0100ac3:	83 c4 10             	add    $0x10,%esp
f0100ac6:	eb b9                	jmp    f0100a81 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100ac8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100acd:	e8 96 fe ff ff       	call   f0100968 <boot_alloc>
f0100ad2:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ad5:	8b 15 3c 85 11 f0    	mov    0xf011853c,%edx
		assert(pp >= pages);
f0100adb:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
		assert(pp < pages + npages);
f0100ae1:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0100ae6:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100ae9:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100aec:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0100aef:	be 00 00 00 00       	mov    $0x0,%esi
f0100af4:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100af7:	e9 c8 00 00 00       	jmp    f0100bc4 <check_page_free_list+0x190>
		assert(pp >= pages);
f0100afc:	68 52 46 10 f0       	push   $0xf0104652
f0100b01:	68 5e 46 10 f0       	push   $0xf010465e
f0100b06:	68 1e 02 00 00       	push   $0x21e
f0100b0b:	68 38 46 10 f0       	push   $0xf0104638
f0100b10:	e8 1e f6 ff ff       	call   f0100133 <_panic>
		assert(pp < pages + npages);
f0100b15:	68 73 46 10 f0       	push   $0xf0104673
f0100b1a:	68 5e 46 10 f0       	push   $0xf010465e
f0100b1f:	68 1f 02 00 00       	push   $0x21f
f0100b24:	68 38 46 10 f0       	push   $0xf0104638
f0100b29:	e8 05 f6 ff ff       	call   f0100133 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b2e:	68 08 3f 10 f0       	push   $0xf0103f08
f0100b33:	68 5e 46 10 f0       	push   $0xf010465e
f0100b38:	68 20 02 00 00       	push   $0x220
f0100b3d:	68 38 46 10 f0       	push   $0xf0104638
f0100b42:	e8 ec f5 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) != 0);
f0100b47:	68 87 46 10 f0       	push   $0xf0104687
f0100b4c:	68 5e 46 10 f0       	push   $0xf010465e
f0100b51:	68 23 02 00 00       	push   $0x223
f0100b56:	68 38 46 10 f0       	push   $0xf0104638
f0100b5b:	e8 d3 f5 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100b60:	68 98 46 10 f0       	push   $0xf0104698
f0100b65:	68 5e 46 10 f0       	push   $0xf010465e
f0100b6a:	68 24 02 00 00       	push   $0x224
f0100b6f:	68 38 46 10 f0       	push   $0xf0104638
f0100b74:	e8 ba f5 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100b79:	68 3c 3f 10 f0       	push   $0xf0103f3c
f0100b7e:	68 5e 46 10 f0       	push   $0xf010465e
f0100b83:	68 25 02 00 00       	push   $0x225
f0100b88:	68 38 46 10 f0       	push   $0xf0104638
f0100b8d:	e8 a1 f5 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100b92:	68 b1 46 10 f0       	push   $0xf01046b1
f0100b97:	68 5e 46 10 f0       	push   $0xf010465e
f0100b9c:	68 26 02 00 00       	push   $0x226
f0100ba1:	68 38 46 10 f0       	push   $0xf0104638
f0100ba6:	e8 88 f5 ff ff       	call   f0100133 <_panic>
	if (PGNUM(pa) >= npages)
f0100bab:	89 c3                	mov    %eax,%ebx
f0100bad:	c1 eb 0c             	shr    $0xc,%ebx
f0100bb0:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f0100bb3:	76 63                	jbe    f0100c18 <check_page_free_list+0x1e4>
	return (void *)(pa + KERNBASE);
f0100bb5:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100bba:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100bbd:	77 6b                	ja     f0100c2a <check_page_free_list+0x1f6>
			++nfree_extmem;
f0100bbf:	ff 45 d0             	incl   -0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bc2:	8b 12                	mov    (%edx),%edx
f0100bc4:	85 d2                	test   %edx,%edx
f0100bc6:	74 7b                	je     f0100c43 <check_page_free_list+0x20f>
		assert(pp >= pages);
f0100bc8:	39 d1                	cmp    %edx,%ecx
f0100bca:	0f 87 2c ff ff ff    	ja     f0100afc <check_page_free_list+0xc8>
		assert(pp < pages + npages);
f0100bd0:	39 d7                	cmp    %edx,%edi
f0100bd2:	0f 86 3d ff ff ff    	jbe    f0100b15 <check_page_free_list+0xe1>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bd8:	89 d0                	mov    %edx,%eax
f0100bda:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100bdd:	a8 07                	test   $0x7,%al
f0100bdf:	0f 85 49 ff ff ff    	jne    f0100b2e <check_page_free_list+0xfa>
	return (pp - pages) << PGSHIFT;
f0100be5:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100be8:	c1 e0 0c             	shl    $0xc,%eax
f0100beb:	0f 84 56 ff ff ff    	je     f0100b47 <check_page_free_list+0x113>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bf1:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100bf6:	0f 84 64 ff ff ff    	je     f0100b60 <check_page_free_list+0x12c>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100bfc:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c01:	0f 84 72 ff ff ff    	je     f0100b79 <check_page_free_list+0x145>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c07:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c0c:	74 84                	je     f0100b92 <check_page_free_list+0x15e>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c0e:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c13:	77 96                	ja     f0100bab <check_page_free_list+0x177>
			++nfree_basemem;
f0100c15:	46                   	inc    %esi
f0100c16:	eb aa                	jmp    f0100bc2 <check_page_free_list+0x18e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c18:	50                   	push   %eax
f0100c19:	68 c0 3e 10 f0       	push   $0xf0103ec0
f0100c1e:	6a 52                	push   $0x52
f0100c20:	68 44 46 10 f0       	push   $0xf0104644
f0100c25:	e8 09 f5 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c2a:	68 60 3f 10 f0       	push   $0xf0103f60
f0100c2f:	68 5e 46 10 f0       	push   $0xf010465e
f0100c34:	68 27 02 00 00       	push   $0x227
f0100c39:	68 38 46 10 f0       	push   $0xf0104638
f0100c3e:	e8 f0 f4 ff ff       	call   f0100133 <_panic>
f0100c43:	8b 5d d0             	mov    -0x30(%ebp),%ebx
	assert(nfree_basemem > 0);
f0100c46:	85 f6                	test   %esi,%esi
f0100c48:	7e 19                	jle    f0100c63 <check_page_free_list+0x22f>
	assert(nfree_extmem > 0);
f0100c4a:	85 db                	test   %ebx,%ebx
f0100c4c:	7e 2e                	jle    f0100c7c <check_page_free_list+0x248>
	cprintf("check_page_free_list() succeeded!\n");
f0100c4e:	83 ec 0c             	sub    $0xc,%esp
f0100c51:	68 a8 3f 10 f0       	push   $0xf0103fa8
f0100c56:	e8 35 1d 00 00       	call   f0102990 <cprintf>
}
f0100c5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c5e:	5b                   	pop    %ebx
f0100c5f:	5e                   	pop    %esi
f0100c60:	5f                   	pop    %edi
f0100c61:	5d                   	pop    %ebp
f0100c62:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100c63:	68 cb 46 10 f0       	push   $0xf01046cb
f0100c68:	68 5e 46 10 f0       	push   $0xf010465e
f0100c6d:	68 2f 02 00 00       	push   $0x22f
f0100c72:	68 38 46 10 f0       	push   $0xf0104638
f0100c77:	e8 b7 f4 ff ff       	call   f0100133 <_panic>
	assert(nfree_extmem > 0);
f0100c7c:	68 dd 46 10 f0       	push   $0xf01046dd
f0100c81:	68 5e 46 10 f0       	push   $0xf010465e
f0100c86:	68 30 02 00 00       	push   $0x230
f0100c8b:	68 38 46 10 f0       	push   $0xf0104638
f0100c90:	e8 9e f4 ff ff       	call   f0100133 <_panic>
	if (!page_free_list)
f0100c95:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0100c9a:	85 c0                	test   %eax,%eax
f0100c9c:	0f 84 b6 fd ff ff    	je     f0100a58 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100ca2:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100ca5:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100ca8:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100cab:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100cae:	89 c2                	mov    %eax,%edx
f0100cb0:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit; 
f0100cb6:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100cbc:	0f 95 c2             	setne  %dl
f0100cbf:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100cc2:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100cc6:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100cc8:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ccc:	8b 00                	mov    (%eax),%eax
f0100cce:	85 c0                	test   %eax,%eax
f0100cd0:	75 dc                	jne    f0100cae <check_page_free_list+0x27a>
		*tp[1] = 0;
f0100cd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100cd5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100cdb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100cde:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ce1:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100ce3:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100ce6:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ceb:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100cf0:	8b 1d 3c 85 11 f0    	mov    0xf011853c,%ebx
f0100cf6:	e9 88 fd ff ff       	jmp    f0100a83 <check_page_free_list+0x4f>

f0100cfb <page_init>:
{
f0100cfb:	55                   	push   %ebp
f0100cfc:	89 e5                	mov    %esp,%ebp
f0100cfe:	57                   	push   %edi
f0100cff:	56                   	push   %esi
f0100d00:	53                   	push   %ebx
	for (i = 1; i < npages_basemem; i++) {
f0100d01:	8b 35 40 85 11 f0    	mov    0xf0118540,%esi
f0100d07:	8b 1d 3c 85 11 f0    	mov    0xf011853c,%ebx
f0100d0d:	b2 00                	mov    $0x0,%dl
f0100d0f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100d14:	bf 01 00 00 00       	mov    $0x1,%edi
f0100d19:	eb 22                	jmp    f0100d3d <page_init+0x42>
		pages[i].pp_ref = 0;
f0100d1b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100d22:	89 d1                	mov    %edx,%ecx
f0100d24:	03 0d 6c 89 11 f0    	add    0xf011896c,%ecx
f0100d2a:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100d30:	89 19                	mov    %ebx,(%ecx)
	for (i = 1; i < npages_basemem; i++) {
f0100d32:	40                   	inc    %eax
		page_free_list = &pages[i];
f0100d33:	89 d3                	mov    %edx,%ebx
f0100d35:	03 1d 6c 89 11 f0    	add    0xf011896c,%ebx
f0100d3b:	89 fa                	mov    %edi,%edx
	for (i = 1; i < npages_basemem; i++) {
f0100d3d:	39 c6                	cmp    %eax,%esi
f0100d3f:	77 da                	ja     f0100d1b <page_init+0x20>
f0100d41:	84 d2                	test   %dl,%dl
f0100d43:	75 33                	jne    f0100d78 <page_init+0x7d>
	size_t table_size = PTX(sizeof(struct PageInfo)*npages);
f0100d45:	8b 15 64 89 11 f0    	mov    0xf0118964,%edx
f0100d4b:	c1 e2 0d             	shl    $0xd,%edx
f0100d4e:	c1 ea 16             	shr    $0x16,%edx
	size_t end_idx = PTX(ROUNDUP((char *) end, PGSIZE));
f0100d51:	b8 6f 99 11 f0       	mov    $0xf011996f,%eax
f0100d56:	c1 e8 0c             	shr    $0xc,%eax
f0100d59:	25 ff 03 00 00       	and    $0x3ff,%eax
	for (i = table_size + end_idx + 1; i < npages; i++) {
f0100d5e:	8d 54 02 01          	lea    0x1(%edx,%eax,1),%edx
f0100d62:	8b 1d 3c 85 11 f0    	mov    0xf011853c,%ebx
f0100d68:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0100d6f:	b1 00                	mov    $0x0,%cl
f0100d71:	be 01 00 00 00       	mov    $0x1,%esi
f0100d76:	eb 26                	jmp    f0100d9e <page_init+0xa3>
f0100d78:	89 1d 3c 85 11 f0    	mov    %ebx,0xf011853c
f0100d7e:	eb c5                	jmp    f0100d45 <page_init+0x4a>
		pages[i].pp_ref = 0;
f0100d80:	89 c1                	mov    %eax,%ecx
f0100d82:	03 0d 6c 89 11 f0    	add    0xf011896c,%ecx
f0100d88:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100d8e:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0100d90:	89 c3                	mov    %eax,%ebx
f0100d92:	03 1d 6c 89 11 f0    	add    0xf011896c,%ebx
	for (i = table_size + end_idx + 1; i < npages; i++) {
f0100d98:	42                   	inc    %edx
f0100d99:	83 c0 08             	add    $0x8,%eax
f0100d9c:	89 f1                	mov    %esi,%ecx
f0100d9e:	39 15 64 89 11 f0    	cmp    %edx,0xf0118964
f0100da4:	77 da                	ja     f0100d80 <page_init+0x85>
f0100da6:	84 c9                	test   %cl,%cl
f0100da8:	75 05                	jne    f0100daf <page_init+0xb4>
}
f0100daa:	5b                   	pop    %ebx
f0100dab:	5e                   	pop    %esi
f0100dac:	5f                   	pop    %edi
f0100dad:	5d                   	pop    %ebp
f0100dae:	c3                   	ret    
f0100daf:	89 1d 3c 85 11 f0    	mov    %ebx,0xf011853c
f0100db5:	eb f3                	jmp    f0100daa <page_init+0xaf>

f0100db7 <page_alloc>:
{
f0100db7:	55                   	push   %ebp
f0100db8:	89 e5                	mov    %esp,%ebp
f0100dba:	53                   	push   %ebx
f0100dbb:	83 ec 04             	sub    $0x4,%esp
	struct PageInfo* next = page_free_list;
f0100dbe:	8b 1d 3c 85 11 f0    	mov    0xf011853c,%ebx
	if (!next)
f0100dc4:	85 db                	test   %ebx,%ebx
f0100dc6:	74 13                	je     f0100ddb <page_alloc+0x24>
	page_free_list = page_free_list->pp_link;
f0100dc8:	8b 03                	mov    (%ebx),%eax
f0100dca:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
	next->pp_link = NULL;
f0100dcf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f0100dd5:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100dd9:	75 07                	jne    f0100de2 <page_alloc+0x2b>
}
f0100ddb:	89 d8                	mov    %ebx,%eax
f0100ddd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100de0:	c9                   	leave  
f0100de1:	c3                   	ret    
f0100de2:	89 d8                	mov    %ebx,%eax
f0100de4:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0100dea:	c1 f8 03             	sar    $0x3,%eax
f0100ded:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100df0:	89 c2                	mov    %eax,%edx
f0100df2:	c1 ea 0c             	shr    $0xc,%edx
f0100df5:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f0100dfb:	73 1a                	jae    f0100e17 <page_alloc+0x60>
		memset(content, 0, PGSIZE);
f0100dfd:	83 ec 04             	sub    $0x4,%esp
f0100e00:	68 00 10 00 00       	push   $0x1000
f0100e05:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100e07:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e0c:	50                   	push   %eax
f0100e0d:	e8 ad 26 00 00       	call   f01034bf <memset>
f0100e12:	83 c4 10             	add    $0x10,%esp
f0100e15:	eb c4                	jmp    f0100ddb <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e17:	50                   	push   %eax
f0100e18:	68 c0 3e 10 f0       	push   $0xf0103ec0
f0100e1d:	6a 52                	push   $0x52
f0100e1f:	68 44 46 10 f0       	push   $0xf0104644
f0100e24:	e8 0a f3 ff ff       	call   f0100133 <_panic>

f0100e29 <page_free>:
{
f0100e29:	55                   	push   %ebp
f0100e2a:	89 e5                	mov    %esp,%ebp
f0100e2c:	83 ec 08             	sub    $0x8,%esp
f0100e2f:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref)
f0100e32:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100e37:	75 14                	jne    f0100e4d <page_free+0x24>
	if (pp->pp_link)
f0100e39:	83 38 00             	cmpl   $0x0,(%eax)
f0100e3c:	75 26                	jne    f0100e64 <page_free+0x3b>
	pp->pp_link = page_free_list;
f0100e3e:	8b 15 3c 85 11 f0    	mov    0xf011853c,%edx
f0100e44:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100e46:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
}
f0100e4b:	c9                   	leave  
f0100e4c:	c3                   	ret    
		panic("Ref count is non-zero");
f0100e4d:	83 ec 04             	sub    $0x4,%esp
f0100e50:	68 ee 46 10 f0       	push   $0xf01046ee
f0100e55:	68 3a 01 00 00       	push   $0x13a
f0100e5a:	68 38 46 10 f0       	push   $0xf0104638
f0100e5f:	e8 cf f2 ff ff       	call   f0100133 <_panic>
		panic("Page is double-freed");
f0100e64:	83 ec 04             	sub    $0x4,%esp
f0100e67:	68 04 47 10 f0       	push   $0xf0104704
f0100e6c:	68 3c 01 00 00       	push   $0x13c
f0100e71:	68 38 46 10 f0       	push   $0xf0104638
f0100e76:	e8 b8 f2 ff ff       	call   f0100133 <_panic>

f0100e7b <page_decref>:
{
f0100e7b:	55                   	push   %ebp
f0100e7c:	89 e5                	mov    %esp,%ebp
f0100e7e:	83 ec 08             	sub    $0x8,%esp
f0100e81:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100e84:	8b 42 04             	mov    0x4(%edx),%eax
f0100e87:	48                   	dec    %eax
f0100e88:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100e8c:	66 85 c0             	test   %ax,%ax
f0100e8f:	74 02                	je     f0100e93 <page_decref+0x18>
}
f0100e91:	c9                   	leave  
f0100e92:	c3                   	ret    
		page_free(pp);
f0100e93:	83 ec 0c             	sub    $0xc,%esp
f0100e96:	52                   	push   %edx
f0100e97:	e8 8d ff ff ff       	call   f0100e29 <page_free>
f0100e9c:	83 c4 10             	add    $0x10,%esp
}
f0100e9f:	eb f0                	jmp    f0100e91 <page_decref+0x16>

f0100ea1 <pgdir_walk>:
{
f0100ea1:	55                   	push   %ebp
f0100ea2:	89 e5                	mov    %esp,%ebp
f0100ea4:	57                   	push   %edi
f0100ea5:	56                   	push   %esi
f0100ea6:	53                   	push   %ebx
f0100ea7:	83 ec 1c             	sub    $0x1c,%esp
	pde_t pd_entry = (pde_t)pgdir[PDX(va)];
f0100eaa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100ead:	c1 eb 16             	shr    $0x16,%ebx
f0100eb0:	c1 e3 02             	shl    $0x2,%ebx
f0100eb3:	03 5d 08             	add    0x8(%ebp),%ebx
f0100eb6:	8b 03                	mov    (%ebx),%eax
	if (pd_entry) {
f0100eb8:	85 c0                	test   %eax,%eax
f0100eba:	74 42                	je     f0100efe <pgdir_walk+0x5d>
		pte_t* pt_base = KADDR(PTE_ADDR(pd_entry));
f0100ebc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100ec1:	89 c2                	mov    %eax,%edx
f0100ec3:	c1 ea 0c             	shr    $0xc,%edx
f0100ec6:	39 15 64 89 11 f0    	cmp    %edx,0xf0118964
f0100ecc:	76 1b                	jbe    f0100ee9 <pgdir_walk+0x48>
		return pt_base + PTX(va);
f0100ece:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100ed1:	c1 ea 0a             	shr    $0xa,%edx
f0100ed4:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f0100eda:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
}
f0100ee1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ee4:	5b                   	pop    %ebx
f0100ee5:	5e                   	pop    %esi
f0100ee6:	5f                   	pop    %edi
f0100ee7:	5d                   	pop    %ebp
f0100ee8:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ee9:	50                   	push   %eax
f0100eea:	68 c0 3e 10 f0       	push   $0xf0103ec0
f0100eef:	68 67 01 00 00       	push   $0x167
f0100ef4:	68 38 46 10 f0       	push   $0xf0104638
f0100ef9:	e8 35 f2 ff ff       	call   f0100133 <_panic>
	else if (create) {
f0100efe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100f02:	0f 84 9e 00 00 00    	je     f0100fa6 <pgdir_walk+0x105>
		struct PageInfo *new_pt = page_alloc(0);
f0100f08:	83 ec 0c             	sub    $0xc,%esp
f0100f0b:	6a 00                	push   $0x0
f0100f0d:	e8 a5 fe ff ff       	call   f0100db7 <page_alloc>
f0100f12:	89 c7                	mov    %eax,%edi
		if (new_pt) {
f0100f14:	83 c4 10             	add    $0x10,%esp
f0100f17:	85 c0                	test   %eax,%eax
f0100f19:	0f 84 91 00 00 00    	je     f0100fb0 <pgdir_walk+0x10f>
	return (pp - pages) << PGSHIFT;
f0100f1f:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0100f25:	c1 f8 03             	sar    $0x3,%eax
f0100f28:	c1 e0 0c             	shl    $0xc,%eax
f0100f2b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (PGNUM(pa) >= npages)
f0100f2e:	c1 e8 0c             	shr    $0xc,%eax
f0100f31:	3b 05 64 89 11 f0    	cmp    0xf0118964,%eax
f0100f37:	73 44                	jae    f0100f7d <pgdir_walk+0xdc>
	return (void *)(pa + KERNBASE);
f0100f39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f3c:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
			memset(content, 0, PGSIZE);
f0100f42:	83 ec 04             	sub    $0x4,%esp
f0100f45:	68 00 10 00 00       	push   $0x1000
f0100f4a:	6a 00                	push   $0x0
f0100f4c:	56                   	push   %esi
f0100f4d:	e8 6d 25 00 00       	call   f01034bf <memset>
			new_pt->pp_ref++;
f0100f52:	66 ff 47 04          	incw   0x4(%edi)
	if ((uint32_t)kva < KERNBASE)
f0100f56:	83 c4 10             	add    $0x10,%esp
f0100f59:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0100f5f:	76 30                	jbe    f0100f91 <pgdir_walk+0xf0>
			pgdir[PDX(va)] = PADDR(content) | 0x1FF; // Set all permissions.
f0100f61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f64:	0d ff 01 00 00       	or     $0x1ff,%eax
f0100f69:	89 03                	mov    %eax,(%ebx)
			return (pte_t*) content + PTX(va);
f0100f6b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f6e:	c1 e8 0a             	shr    $0xa,%eax
f0100f71:	25 fc 0f 00 00       	and    $0xffc,%eax
f0100f76:	01 f0                	add    %esi,%eax
f0100f78:	e9 64 ff ff ff       	jmp    f0100ee1 <pgdir_walk+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f7d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100f80:	68 c0 3e 10 f0       	push   $0xf0103ec0
f0100f85:	6a 52                	push   $0x52
f0100f87:	68 44 46 10 f0       	push   $0xf0104644
f0100f8c:	e8 a2 f1 ff ff       	call   f0100133 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f91:	56                   	push   %esi
f0100f92:	68 cc 3f 10 f0       	push   $0xf0103fcc
f0100f97:	68 71 01 00 00       	push   $0x171
f0100f9c:	68 38 46 10 f0       	push   $0xf0104638
f0100fa1:	e8 8d f1 ff ff       	call   f0100133 <_panic>
	return NULL;
f0100fa6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fab:	e9 31 ff ff ff       	jmp    f0100ee1 <pgdir_walk+0x40>
f0100fb0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fb5:	e9 27 ff ff ff       	jmp    f0100ee1 <pgdir_walk+0x40>

f0100fba <boot_map_region>:
{
f0100fba:	55                   	push   %ebp
f0100fbb:	89 e5                	mov    %esp,%ebp
f0100fbd:	57                   	push   %edi
f0100fbe:	56                   	push   %esi
f0100fbf:	53                   	push   %ebx
f0100fc0:	83 ec 1c             	sub    $0x1c,%esp
f0100fc3:	89 c7                	mov    %eax,%edi
f0100fc5:	89 d6                	mov    %edx,%esi
f0100fc7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f0100fca:	bb 00 00 00 00       	mov    $0x0,%ebx
		*page_entry = (pa + size0) | perm | PTE_P;
f0100fcf:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fd2:	83 c8 01             	or     $0x1,%eax
f0100fd5:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f0100fd8:	eb 22                	jmp    f0100ffc <boot_map_region+0x42>
		pte_t *page_entry = pgdir_walk(pgdir, (void*) va + size0, 1);
f0100fda:	83 ec 04             	sub    $0x4,%esp
f0100fdd:	6a 01                	push   $0x1
f0100fdf:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f0100fe2:	50                   	push   %eax
f0100fe3:	57                   	push   %edi
f0100fe4:	e8 b8 fe ff ff       	call   f0100ea1 <pgdir_walk>
		*page_entry = (pa + size0) | perm | PTE_P;
f0100fe9:	89 da                	mov    %ebx,%edx
f0100feb:	03 55 08             	add    0x8(%ebp),%edx
f0100fee:	0b 55 e0             	or     -0x20(%ebp),%edx
f0100ff1:	89 10                	mov    %edx,(%eax)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f0100ff3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100ff9:	83 c4 10             	add    $0x10,%esp
f0100ffc:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0100fff:	72 d9                	jb     f0100fda <boot_map_region+0x20>
}
f0101001:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101004:	5b                   	pop    %ebx
f0101005:	5e                   	pop    %esi
f0101006:	5f                   	pop    %edi
f0101007:	5d                   	pop    %ebp
f0101008:	c3                   	ret    

f0101009 <page_lookup>:
{
f0101009:	55                   	push   %ebp
f010100a:	89 e5                	mov    %esp,%ebp
f010100c:	53                   	push   %ebx
f010100d:	83 ec 08             	sub    $0x8,%esp
f0101010:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *page_entry = pgdir_walk(pgdir, (void*) va, 0);
f0101013:	6a 00                	push   $0x0
f0101015:	ff 75 0c             	pushl  0xc(%ebp)
f0101018:	ff 75 08             	pushl  0x8(%ebp)
f010101b:	e8 81 fe ff ff       	call   f0100ea1 <pgdir_walk>
	if (!page_entry || !*page_entry)
f0101020:	83 c4 10             	add    $0x10,%esp
f0101023:	85 c0                	test   %eax,%eax
f0101025:	74 3a                	je     f0101061 <page_lookup+0x58>
f0101027:	83 38 00             	cmpl   $0x0,(%eax)
f010102a:	74 3c                	je     f0101068 <page_lookup+0x5f>
	if (pte_store)
f010102c:	85 db                	test   %ebx,%ebx
f010102e:	74 02                	je     f0101032 <page_lookup+0x29>
		*pte_store = page_entry;
f0101030:	89 03                	mov    %eax,(%ebx)
f0101032:	8b 00                	mov    (%eax),%eax
f0101034:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101037:	39 05 64 89 11 f0    	cmp    %eax,0xf0118964
f010103d:	76 0e                	jbe    f010104d <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f010103f:	8b 15 6c 89 11 f0    	mov    0xf011896c,%edx
f0101045:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0101048:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010104b:	c9                   	leave  
f010104c:	c3                   	ret    
		panic("pa2page called with invalid pa");
f010104d:	83 ec 04             	sub    $0x4,%esp
f0101050:	68 f0 3f 10 f0       	push   $0xf0103ff0
f0101055:	6a 4b                	push   $0x4b
f0101057:	68 44 46 10 f0       	push   $0xf0104644
f010105c:	e8 d2 f0 ff ff       	call   f0100133 <_panic>
		return NULL;
f0101061:	b8 00 00 00 00       	mov    $0x0,%eax
f0101066:	eb e0                	jmp    f0101048 <page_lookup+0x3f>
f0101068:	b8 00 00 00 00       	mov    $0x0,%eax
f010106d:	eb d9                	jmp    f0101048 <page_lookup+0x3f>

f010106f <page_remove>:
{
f010106f:	55                   	push   %ebp
f0101070:	89 e5                	mov    %esp,%ebp
f0101072:	53                   	push   %ebx
f0101073:	83 ec 18             	sub    $0x18,%esp
f0101076:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo *pp = page_lookup(pgdir, va, &pte_store);
f0101079:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010107c:	50                   	push   %eax
f010107d:	53                   	push   %ebx
f010107e:	ff 75 08             	pushl  0x8(%ebp)
f0101081:	e8 83 ff ff ff       	call   f0101009 <page_lookup>
	if (!pp)
f0101086:	83 c4 10             	add    $0x10,%esp
f0101089:	85 c0                	test   %eax,%eax
f010108b:	74 17                	je     f01010a4 <page_remove+0x35>
	pp->pp_ref--;
f010108d:	66 ff 48 04          	decw   0x4(%eax)
	*pte_store = 0;
f0101091:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101094:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010109a:	0f 01 3b             	invlpg (%ebx)
	if (!pp->pp_ref)
f010109d:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01010a2:	74 05                	je     f01010a9 <page_remove+0x3a>
}
f01010a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010a7:	c9                   	leave  
f01010a8:	c3                   	ret    
		page_free(pp);
f01010a9:	83 ec 0c             	sub    $0xc,%esp
f01010ac:	50                   	push   %eax
f01010ad:	e8 77 fd ff ff       	call   f0100e29 <page_free>
f01010b2:	83 c4 10             	add    $0x10,%esp
f01010b5:	eb ed                	jmp    f01010a4 <page_remove+0x35>

f01010b7 <page_insert>:
{
f01010b7:	55                   	push   %ebp
f01010b8:	89 e5                	mov    %esp,%ebp
f01010ba:	57                   	push   %edi
f01010bb:	56                   	push   %esi
f01010bc:	53                   	push   %ebx
f01010bd:	83 ec 10             	sub    $0x10,%esp
f01010c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01010c3:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *page_entry = pgdir_walk(pgdir, (void*) va, 1);
f01010c6:	6a 01                	push   $0x1
f01010c8:	57                   	push   %edi
f01010c9:	ff 75 08             	pushl  0x8(%ebp)
f01010cc:	e8 d0 fd ff ff       	call   f0100ea1 <pgdir_walk>
	if (!page_entry)
f01010d1:	83 c4 10             	add    $0x10,%esp
f01010d4:	85 c0                	test   %eax,%eax
f01010d6:	74 3f                	je     f0101117 <page_insert+0x60>
f01010d8:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f01010da:	66 ff 43 04          	incw   0x4(%ebx)
	if (*page_entry) 
f01010de:	83 38 00             	cmpl   $0x0,(%eax)
f01010e1:	75 23                	jne    f0101106 <page_insert+0x4f>
	return (pp - pages) << PGSHIFT;
f01010e3:	2b 1d 6c 89 11 f0    	sub    0xf011896c,%ebx
f01010e9:	c1 fb 03             	sar    $0x3,%ebx
f01010ec:	c1 e3 0c             	shl    $0xc,%ebx
	*page_entry = page2pa(pp) | perm | PTE_P;
f01010ef:	8b 45 14             	mov    0x14(%ebp),%eax
f01010f2:	83 c8 01             	or     $0x1,%eax
f01010f5:	09 c3                	or     %eax,%ebx
f01010f7:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01010f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01010fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101101:	5b                   	pop    %ebx
f0101102:	5e                   	pop    %esi
f0101103:	5f                   	pop    %edi
f0101104:	5d                   	pop    %ebp
f0101105:	c3                   	ret    
		page_remove(pgdir, va);
f0101106:	83 ec 08             	sub    $0x8,%esp
f0101109:	57                   	push   %edi
f010110a:	ff 75 08             	pushl  0x8(%ebp)
f010110d:	e8 5d ff ff ff       	call   f010106f <page_remove>
f0101112:	83 c4 10             	add    $0x10,%esp
f0101115:	eb cc                	jmp    f01010e3 <page_insert+0x2c>
		return -E_NO_MEM;  // Has no page table AND cannot be allocated
f0101117:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010111c:	eb e0                	jmp    f01010fe <page_insert+0x47>

f010111e <mem_init>:
{
f010111e:	55                   	push   %ebp
f010111f:	89 e5                	mov    %esp,%ebp
f0101121:	57                   	push   %edi
f0101122:	56                   	push   %esi
f0101123:	53                   	push   %ebx
f0101124:	83 ec 2c             	sub    $0x2c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0101127:	b8 15 00 00 00       	mov    $0x15,%eax
f010112c:	e8 7d f8 ff ff       	call   f01009ae <nvram_read>
f0101131:	89 c6                	mov    %eax,%esi
	extmem = nvram_read(NVRAM_EXTLO);
f0101133:	b8 17 00 00 00       	mov    $0x17,%eax
f0101138:	e8 71 f8 ff ff       	call   f01009ae <nvram_read>
f010113d:	89 c3                	mov    %eax,%ebx
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010113f:	b8 34 00 00 00       	mov    $0x34,%eax
f0101144:	e8 65 f8 ff ff       	call   f01009ae <nvram_read>
	if (ext16mem)
f0101149:	c1 e0 06             	shl    $0x6,%eax
f010114c:	75 10                	jne    f010115e <mem_init+0x40>
	else if (extmem)
f010114e:	85 db                	test   %ebx,%ebx
f0101150:	0f 84 c3 00 00 00    	je     f0101219 <mem_init+0xfb>
		totalmem = 1 * 1024 + extmem;
f0101156:	8d 83 00 04 00 00    	lea    0x400(%ebx),%eax
f010115c:	eb 05                	jmp    f0101163 <mem_init+0x45>
		totalmem = 16 * 1024 + ext16mem;
f010115e:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101163:	89 c2                	mov    %eax,%edx
f0101165:	c1 ea 02             	shr    $0x2,%edx
f0101168:	89 15 64 89 11 f0    	mov    %edx,0xf0118964
	npages_basemem = basemem / (PGSIZE / 1024);
f010116e:	89 f2                	mov    %esi,%edx
f0101170:	c1 ea 02             	shr    $0x2,%edx
f0101173:	89 15 40 85 11 f0    	mov    %edx,0xf0118540
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101179:	89 c2                	mov    %eax,%edx
f010117b:	29 f2                	sub    %esi,%edx
f010117d:	52                   	push   %edx
f010117e:	56                   	push   %esi
f010117f:	50                   	push   %eax
f0101180:	68 10 40 10 f0       	push   $0xf0104010
f0101185:	e8 06 18 00 00       	call   f0102990 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010118a:	b8 00 10 00 00       	mov    $0x1000,%eax
f010118f:	e8 d4 f7 ff ff       	call   f0100968 <boot_alloc>
f0101194:	a3 68 89 11 f0       	mov    %eax,0xf0118968
	memset(kern_pgdir, 0, PGSIZE);
f0101199:	83 c4 0c             	add    $0xc,%esp
f010119c:	68 00 10 00 00       	push   $0x1000
f01011a1:	6a 00                	push   $0x0
f01011a3:	50                   	push   %eax
f01011a4:	e8 16 23 00 00       	call   f01034bf <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01011a9:	a1 68 89 11 f0       	mov    0xf0118968,%eax
	if ((uint32_t)kva < KERNBASE)
f01011ae:	83 c4 10             	add    $0x10,%esp
f01011b1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01011b6:	76 68                	jbe    f0101220 <mem_init+0x102>
	return (physaddr_t)kva - KERNBASE;
f01011b8:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01011be:	83 ca 05             	or     $0x5,%edx
f01011c1:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo)*npages);
f01011c7:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f01011cc:	c1 e0 03             	shl    $0x3,%eax
f01011cf:	e8 94 f7 ff ff       	call   f0100968 <boot_alloc>
f01011d4:	a3 6c 89 11 f0       	mov    %eax,0xf011896c
	memset(pages, 0, sizeof(struct PageInfo)*npages);
f01011d9:	83 ec 04             	sub    $0x4,%esp
f01011dc:	8b 0d 64 89 11 f0    	mov    0xf0118964,%ecx
f01011e2:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01011e9:	52                   	push   %edx
f01011ea:	6a 00                	push   $0x0
f01011ec:	50                   	push   %eax
f01011ed:	e8 cd 22 00 00       	call   f01034bf <memset>
	page_init();
f01011f2:	e8 04 fb ff ff       	call   f0100cfb <page_init>
	check_page_free_list(1);
f01011f7:	b8 01 00 00 00       	mov    $0x1,%eax
f01011fc:	e8 33 f8 ff ff       	call   f0100a34 <check_page_free_list>
	if (!pages)
f0101201:	83 c4 10             	add    $0x10,%esp
f0101204:	83 3d 6c 89 11 f0 00 	cmpl   $0x0,0xf011896c
f010120b:	74 28                	je     f0101235 <mem_init+0x117>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010120d:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0101212:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101217:	eb 36                	jmp    f010124f <mem_init+0x131>
		totalmem = basemem;
f0101219:	89 f0                	mov    %esi,%eax
f010121b:	e9 43 ff ff ff       	jmp    f0101163 <mem_init+0x45>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101220:	50                   	push   %eax
f0101221:	68 cc 3f 10 f0       	push   $0xf0103fcc
f0101226:	68 91 00 00 00       	push   $0x91
f010122b:	68 38 46 10 f0       	push   $0xf0104638
f0101230:	e8 fe ee ff ff       	call   f0100133 <_panic>
		panic("'pages' is a null pointer!");
f0101235:	83 ec 04             	sub    $0x4,%esp
f0101238:	68 19 47 10 f0       	push   $0xf0104719
f010123d:	68 43 02 00 00       	push   $0x243
f0101242:	68 38 46 10 f0       	push   $0xf0104638
f0101247:	e8 e7 ee ff ff       	call   f0100133 <_panic>
		++nfree;
f010124c:	43                   	inc    %ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010124d:	8b 00                	mov    (%eax),%eax
f010124f:	85 c0                	test   %eax,%eax
f0101251:	75 f9                	jne    f010124c <mem_init+0x12e>
	assert((pp0 = page_alloc(0)));
f0101253:	83 ec 0c             	sub    $0xc,%esp
f0101256:	6a 00                	push   $0x0
f0101258:	e8 5a fb ff ff       	call   f0100db7 <page_alloc>
f010125d:	89 c7                	mov    %eax,%edi
f010125f:	83 c4 10             	add    $0x10,%esp
f0101262:	85 c0                	test   %eax,%eax
f0101264:	0f 84 10 02 00 00    	je     f010147a <mem_init+0x35c>
	assert((pp1 = page_alloc(0)));
f010126a:	83 ec 0c             	sub    $0xc,%esp
f010126d:	6a 00                	push   $0x0
f010126f:	e8 43 fb ff ff       	call   f0100db7 <page_alloc>
f0101274:	89 c6                	mov    %eax,%esi
f0101276:	83 c4 10             	add    $0x10,%esp
f0101279:	85 c0                	test   %eax,%eax
f010127b:	0f 84 12 02 00 00    	je     f0101493 <mem_init+0x375>
	assert((pp2 = page_alloc(0)));
f0101281:	83 ec 0c             	sub    $0xc,%esp
f0101284:	6a 00                	push   $0x0
f0101286:	e8 2c fb ff ff       	call   f0100db7 <page_alloc>
f010128b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010128e:	83 c4 10             	add    $0x10,%esp
f0101291:	85 c0                	test   %eax,%eax
f0101293:	0f 84 13 02 00 00    	je     f01014ac <mem_init+0x38e>
	assert(pp1 && pp1 != pp0);
f0101299:	39 f7                	cmp    %esi,%edi
f010129b:	0f 84 24 02 00 00    	je     f01014c5 <mem_init+0x3a7>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01012a1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01012a4:	39 c6                	cmp    %eax,%esi
f01012a6:	0f 84 32 02 00 00    	je     f01014de <mem_init+0x3c0>
f01012ac:	39 c7                	cmp    %eax,%edi
f01012ae:	0f 84 2a 02 00 00    	je     f01014de <mem_init+0x3c0>
	return (pp - pages) << PGSHIFT;
f01012b4:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01012ba:	8b 15 64 89 11 f0    	mov    0xf0118964,%edx
f01012c0:	c1 e2 0c             	shl    $0xc,%edx
f01012c3:	89 f8                	mov    %edi,%eax
f01012c5:	29 c8                	sub    %ecx,%eax
f01012c7:	c1 f8 03             	sar    $0x3,%eax
f01012ca:	c1 e0 0c             	shl    $0xc,%eax
f01012cd:	39 d0                	cmp    %edx,%eax
f01012cf:	0f 83 22 02 00 00    	jae    f01014f7 <mem_init+0x3d9>
f01012d5:	89 f0                	mov    %esi,%eax
f01012d7:	29 c8                	sub    %ecx,%eax
f01012d9:	c1 f8 03             	sar    $0x3,%eax
f01012dc:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01012df:	39 c2                	cmp    %eax,%edx
f01012e1:	0f 86 29 02 00 00    	jbe    f0101510 <mem_init+0x3f2>
f01012e7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01012ea:	29 c8                	sub    %ecx,%eax
f01012ec:	c1 f8 03             	sar    $0x3,%eax
f01012ef:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01012f2:	39 c2                	cmp    %eax,%edx
f01012f4:	0f 86 2f 02 00 00    	jbe    f0101529 <mem_init+0x40b>
	fl = page_free_list;
f01012fa:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f01012ff:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101302:	c7 05 3c 85 11 f0 00 	movl   $0x0,0xf011853c
f0101309:	00 00 00 
	assert(!page_alloc(0));
f010130c:	83 ec 0c             	sub    $0xc,%esp
f010130f:	6a 00                	push   $0x0
f0101311:	e8 a1 fa ff ff       	call   f0100db7 <page_alloc>
f0101316:	83 c4 10             	add    $0x10,%esp
f0101319:	85 c0                	test   %eax,%eax
f010131b:	0f 85 21 02 00 00    	jne    f0101542 <mem_init+0x424>
	page_free(pp0);
f0101321:	83 ec 0c             	sub    $0xc,%esp
f0101324:	57                   	push   %edi
f0101325:	e8 ff fa ff ff       	call   f0100e29 <page_free>
	page_free(pp1);
f010132a:	89 34 24             	mov    %esi,(%esp)
f010132d:	e8 f7 fa ff ff       	call   f0100e29 <page_free>
	page_free(pp2);
f0101332:	83 c4 04             	add    $0x4,%esp
f0101335:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101338:	e8 ec fa ff ff       	call   f0100e29 <page_free>
	assert((pp0 = page_alloc(0)));
f010133d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101344:	e8 6e fa ff ff       	call   f0100db7 <page_alloc>
f0101349:	89 c6                	mov    %eax,%esi
f010134b:	83 c4 10             	add    $0x10,%esp
f010134e:	85 c0                	test   %eax,%eax
f0101350:	0f 84 05 02 00 00    	je     f010155b <mem_init+0x43d>
	assert((pp1 = page_alloc(0)));
f0101356:	83 ec 0c             	sub    $0xc,%esp
f0101359:	6a 00                	push   $0x0
f010135b:	e8 57 fa ff ff       	call   f0100db7 <page_alloc>
f0101360:	89 c7                	mov    %eax,%edi
f0101362:	83 c4 10             	add    $0x10,%esp
f0101365:	85 c0                	test   %eax,%eax
f0101367:	0f 84 07 02 00 00    	je     f0101574 <mem_init+0x456>
	assert((pp2 = page_alloc(0)));
f010136d:	83 ec 0c             	sub    $0xc,%esp
f0101370:	6a 00                	push   $0x0
f0101372:	e8 40 fa ff ff       	call   f0100db7 <page_alloc>
f0101377:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010137a:	83 c4 10             	add    $0x10,%esp
f010137d:	85 c0                	test   %eax,%eax
f010137f:	0f 84 08 02 00 00    	je     f010158d <mem_init+0x46f>
	assert(pp1 && pp1 != pp0);
f0101385:	39 fe                	cmp    %edi,%esi
f0101387:	0f 84 19 02 00 00    	je     f01015a6 <mem_init+0x488>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010138d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101390:	39 c7                	cmp    %eax,%edi
f0101392:	0f 84 27 02 00 00    	je     f01015bf <mem_init+0x4a1>
f0101398:	39 c6                	cmp    %eax,%esi
f010139a:	0f 84 1f 02 00 00    	je     f01015bf <mem_init+0x4a1>
	assert(!page_alloc(0));
f01013a0:	83 ec 0c             	sub    $0xc,%esp
f01013a3:	6a 00                	push   $0x0
f01013a5:	e8 0d fa ff ff       	call   f0100db7 <page_alloc>
f01013aa:	83 c4 10             	add    $0x10,%esp
f01013ad:	85 c0                	test   %eax,%eax
f01013af:	0f 85 23 02 00 00    	jne    f01015d8 <mem_init+0x4ba>
f01013b5:	89 f0                	mov    %esi,%eax
f01013b7:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f01013bd:	c1 f8 03             	sar    $0x3,%eax
f01013c0:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01013c3:	89 c2                	mov    %eax,%edx
f01013c5:	c1 ea 0c             	shr    $0xc,%edx
f01013c8:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f01013ce:	0f 83 1d 02 00 00    	jae    f01015f1 <mem_init+0x4d3>
	memset(page2kva(pp0), 1, PGSIZE);
f01013d4:	83 ec 04             	sub    $0x4,%esp
f01013d7:	68 00 10 00 00       	push   $0x1000
f01013dc:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01013de:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01013e3:	50                   	push   %eax
f01013e4:	e8 d6 20 00 00       	call   f01034bf <memset>
	page_free(pp0);
f01013e9:	89 34 24             	mov    %esi,(%esp)
f01013ec:	e8 38 fa ff ff       	call   f0100e29 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01013f1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01013f8:	e8 ba f9 ff ff       	call   f0100db7 <page_alloc>
f01013fd:	83 c4 10             	add    $0x10,%esp
f0101400:	85 c0                	test   %eax,%eax
f0101402:	0f 84 fb 01 00 00    	je     f0101603 <mem_init+0x4e5>
	assert(pp && pp0 == pp);
f0101408:	39 c6                	cmp    %eax,%esi
f010140a:	0f 85 0c 02 00 00    	jne    f010161c <mem_init+0x4fe>
	return (pp - pages) << PGSHIFT;
f0101410:	89 f2                	mov    %esi,%edx
f0101412:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f0101418:	c1 fa 03             	sar    $0x3,%edx
f010141b:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010141e:	89 d0                	mov    %edx,%eax
f0101420:	c1 e8 0c             	shr    $0xc,%eax
f0101423:	3b 05 64 89 11 f0    	cmp    0xf0118964,%eax
f0101429:	0f 83 06 02 00 00    	jae    f0101635 <mem_init+0x517>
	return (void *)(pa + KERNBASE);
f010142f:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101435:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f010143b:	80 38 00             	cmpb   $0x0,(%eax)
f010143e:	0f 85 03 02 00 00    	jne    f0101647 <mem_init+0x529>
f0101444:	40                   	inc    %eax
	for (i = 0; i < PGSIZE; i++)
f0101445:	39 d0                	cmp    %edx,%eax
f0101447:	75 f2                	jne    f010143b <mem_init+0x31d>
	page_free_list = fl;
f0101449:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010144c:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
	page_free(pp0);
f0101451:	83 ec 0c             	sub    $0xc,%esp
f0101454:	56                   	push   %esi
f0101455:	e8 cf f9 ff ff       	call   f0100e29 <page_free>
	page_free(pp1);
f010145a:	89 3c 24             	mov    %edi,(%esp)
f010145d:	e8 c7 f9 ff ff       	call   f0100e29 <page_free>
	page_free(pp2);
f0101462:	83 c4 04             	add    $0x4,%esp
f0101465:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101468:	e8 bc f9 ff ff       	call   f0100e29 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010146d:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0101472:	83 c4 10             	add    $0x10,%esp
f0101475:	e9 e9 01 00 00       	jmp    f0101663 <mem_init+0x545>
	assert((pp0 = page_alloc(0)));
f010147a:	68 34 47 10 f0       	push   $0xf0104734
f010147f:	68 5e 46 10 f0       	push   $0xf010465e
f0101484:	68 4b 02 00 00       	push   $0x24b
f0101489:	68 38 46 10 f0       	push   $0xf0104638
f010148e:	e8 a0 ec ff ff       	call   f0100133 <_panic>
	assert((pp1 = page_alloc(0)));
f0101493:	68 4a 47 10 f0       	push   $0xf010474a
f0101498:	68 5e 46 10 f0       	push   $0xf010465e
f010149d:	68 4c 02 00 00       	push   $0x24c
f01014a2:	68 38 46 10 f0       	push   $0xf0104638
f01014a7:	e8 87 ec ff ff       	call   f0100133 <_panic>
	assert((pp2 = page_alloc(0)));
f01014ac:	68 60 47 10 f0       	push   $0xf0104760
f01014b1:	68 5e 46 10 f0       	push   $0xf010465e
f01014b6:	68 4d 02 00 00       	push   $0x24d
f01014bb:	68 38 46 10 f0       	push   $0xf0104638
f01014c0:	e8 6e ec ff ff       	call   f0100133 <_panic>
	assert(pp1 && pp1 != pp0);
f01014c5:	68 76 47 10 f0       	push   $0xf0104776
f01014ca:	68 5e 46 10 f0       	push   $0xf010465e
f01014cf:	68 50 02 00 00       	push   $0x250
f01014d4:	68 38 46 10 f0       	push   $0xf0104638
f01014d9:	e8 55 ec ff ff       	call   f0100133 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014de:	68 4c 40 10 f0       	push   $0xf010404c
f01014e3:	68 5e 46 10 f0       	push   $0xf010465e
f01014e8:	68 51 02 00 00       	push   $0x251
f01014ed:	68 38 46 10 f0       	push   $0xf0104638
f01014f2:	e8 3c ec ff ff       	call   f0100133 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f01014f7:	68 88 47 10 f0       	push   $0xf0104788
f01014fc:	68 5e 46 10 f0       	push   $0xf010465e
f0101501:	68 52 02 00 00       	push   $0x252
f0101506:	68 38 46 10 f0       	push   $0xf0104638
f010150b:	e8 23 ec ff ff       	call   f0100133 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101510:	68 a5 47 10 f0       	push   $0xf01047a5
f0101515:	68 5e 46 10 f0       	push   $0xf010465e
f010151a:	68 53 02 00 00       	push   $0x253
f010151f:	68 38 46 10 f0       	push   $0xf0104638
f0101524:	e8 0a ec ff ff       	call   f0100133 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101529:	68 c2 47 10 f0       	push   $0xf01047c2
f010152e:	68 5e 46 10 f0       	push   $0xf010465e
f0101533:	68 54 02 00 00       	push   $0x254
f0101538:	68 38 46 10 f0       	push   $0xf0104638
f010153d:	e8 f1 eb ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f0101542:	68 df 47 10 f0       	push   $0xf01047df
f0101547:	68 5e 46 10 f0       	push   $0xf010465e
f010154c:	68 5b 02 00 00       	push   $0x25b
f0101551:	68 38 46 10 f0       	push   $0xf0104638
f0101556:	e8 d8 eb ff ff       	call   f0100133 <_panic>
	assert((pp0 = page_alloc(0)));
f010155b:	68 34 47 10 f0       	push   $0xf0104734
f0101560:	68 5e 46 10 f0       	push   $0xf010465e
f0101565:	68 62 02 00 00       	push   $0x262
f010156a:	68 38 46 10 f0       	push   $0xf0104638
f010156f:	e8 bf eb ff ff       	call   f0100133 <_panic>
	assert((pp1 = page_alloc(0)));
f0101574:	68 4a 47 10 f0       	push   $0xf010474a
f0101579:	68 5e 46 10 f0       	push   $0xf010465e
f010157e:	68 63 02 00 00       	push   $0x263
f0101583:	68 38 46 10 f0       	push   $0xf0104638
f0101588:	e8 a6 eb ff ff       	call   f0100133 <_panic>
	assert((pp2 = page_alloc(0)));
f010158d:	68 60 47 10 f0       	push   $0xf0104760
f0101592:	68 5e 46 10 f0       	push   $0xf010465e
f0101597:	68 64 02 00 00       	push   $0x264
f010159c:	68 38 46 10 f0       	push   $0xf0104638
f01015a1:	e8 8d eb ff ff       	call   f0100133 <_panic>
	assert(pp1 && pp1 != pp0);
f01015a6:	68 76 47 10 f0       	push   $0xf0104776
f01015ab:	68 5e 46 10 f0       	push   $0xf010465e
f01015b0:	68 66 02 00 00       	push   $0x266
f01015b5:	68 38 46 10 f0       	push   $0xf0104638
f01015ba:	e8 74 eb ff ff       	call   f0100133 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015bf:	68 4c 40 10 f0       	push   $0xf010404c
f01015c4:	68 5e 46 10 f0       	push   $0xf010465e
f01015c9:	68 67 02 00 00       	push   $0x267
f01015ce:	68 38 46 10 f0       	push   $0xf0104638
f01015d3:	e8 5b eb ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f01015d8:	68 df 47 10 f0       	push   $0xf01047df
f01015dd:	68 5e 46 10 f0       	push   $0xf010465e
f01015e2:	68 68 02 00 00       	push   $0x268
f01015e7:	68 38 46 10 f0       	push   $0xf0104638
f01015ec:	e8 42 eb ff ff       	call   f0100133 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015f1:	50                   	push   %eax
f01015f2:	68 c0 3e 10 f0       	push   $0xf0103ec0
f01015f7:	6a 52                	push   $0x52
f01015f9:	68 44 46 10 f0       	push   $0xf0104644
f01015fe:	e8 30 eb ff ff       	call   f0100133 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101603:	68 ee 47 10 f0       	push   $0xf01047ee
f0101608:	68 5e 46 10 f0       	push   $0xf010465e
f010160d:	68 6d 02 00 00       	push   $0x26d
f0101612:	68 38 46 10 f0       	push   $0xf0104638
f0101617:	e8 17 eb ff ff       	call   f0100133 <_panic>
	assert(pp && pp0 == pp);
f010161c:	68 0c 48 10 f0       	push   $0xf010480c
f0101621:	68 5e 46 10 f0       	push   $0xf010465e
f0101626:	68 6e 02 00 00       	push   $0x26e
f010162b:	68 38 46 10 f0       	push   $0xf0104638
f0101630:	e8 fe ea ff ff       	call   f0100133 <_panic>
f0101635:	52                   	push   %edx
f0101636:	68 c0 3e 10 f0       	push   $0xf0103ec0
f010163b:	6a 52                	push   $0x52
f010163d:	68 44 46 10 f0       	push   $0xf0104644
f0101642:	e8 ec ea ff ff       	call   f0100133 <_panic>
		assert(c[i] == 0);
f0101647:	68 1c 48 10 f0       	push   $0xf010481c
f010164c:	68 5e 46 10 f0       	push   $0xf010465e
f0101651:	68 71 02 00 00       	push   $0x271
f0101656:	68 38 46 10 f0       	push   $0xf0104638
f010165b:	e8 d3 ea ff ff       	call   f0100133 <_panic>
		--nfree;
f0101660:	4b                   	dec    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101661:	8b 00                	mov    (%eax),%eax
f0101663:	85 c0                	test   %eax,%eax
f0101665:	75 f9                	jne    f0101660 <mem_init+0x542>
	assert(nfree == 0);
f0101667:	85 db                	test   %ebx,%ebx
f0101669:	0f 85 9c 07 00 00    	jne    f0101e0b <mem_init+0xced>
	cprintf("check_page_alloc() succeeded!\n");
f010166f:	83 ec 0c             	sub    $0xc,%esp
f0101672:	68 6c 40 10 f0       	push   $0xf010406c
f0101677:	e8 14 13 00 00       	call   f0102990 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010167c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101683:	e8 2f f7 ff ff       	call   f0100db7 <page_alloc>
f0101688:	89 c7                	mov    %eax,%edi
f010168a:	83 c4 10             	add    $0x10,%esp
f010168d:	85 c0                	test   %eax,%eax
f010168f:	0f 84 8f 07 00 00    	je     f0101e24 <mem_init+0xd06>
	assert((pp1 = page_alloc(0)));
f0101695:	83 ec 0c             	sub    $0xc,%esp
f0101698:	6a 00                	push   $0x0
f010169a:	e8 18 f7 ff ff       	call   f0100db7 <page_alloc>
f010169f:	89 c3                	mov    %eax,%ebx
f01016a1:	83 c4 10             	add    $0x10,%esp
f01016a4:	85 c0                	test   %eax,%eax
f01016a6:	0f 84 91 07 00 00    	je     f0101e3d <mem_init+0xd1f>
	assert((pp2 = page_alloc(0)));
f01016ac:	83 ec 0c             	sub    $0xc,%esp
f01016af:	6a 00                	push   $0x0
f01016b1:	e8 01 f7 ff ff       	call   f0100db7 <page_alloc>
f01016b6:	89 c6                	mov    %eax,%esi
f01016b8:	83 c4 10             	add    $0x10,%esp
f01016bb:	85 c0                	test   %eax,%eax
f01016bd:	0f 84 93 07 00 00    	je     f0101e56 <mem_init+0xd38>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01016c3:	39 df                	cmp    %ebx,%edi
f01016c5:	0f 84 a4 07 00 00    	je     f0101e6f <mem_init+0xd51>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016cb:	39 c3                	cmp    %eax,%ebx
f01016cd:	0f 84 b5 07 00 00    	je     f0101e88 <mem_init+0xd6a>
f01016d3:	39 c7                	cmp    %eax,%edi
f01016d5:	0f 84 ad 07 00 00    	je     f0101e88 <mem_init+0xd6a>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01016db:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f01016e0:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f01016e3:	c7 05 3c 85 11 f0 00 	movl   $0x0,0xf011853c
f01016ea:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01016ed:	83 ec 0c             	sub    $0xc,%esp
f01016f0:	6a 00                	push   $0x0
f01016f2:	e8 c0 f6 ff ff       	call   f0100db7 <page_alloc>
f01016f7:	83 c4 10             	add    $0x10,%esp
f01016fa:	85 c0                	test   %eax,%eax
f01016fc:	0f 85 9f 07 00 00    	jne    f0101ea1 <mem_init+0xd83>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101702:	83 ec 04             	sub    $0x4,%esp
f0101705:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101708:	50                   	push   %eax
f0101709:	6a 00                	push   $0x0
f010170b:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101711:	e8 f3 f8 ff ff       	call   f0101009 <page_lookup>
f0101716:	83 c4 10             	add    $0x10,%esp
f0101719:	85 c0                	test   %eax,%eax
f010171b:	0f 85 99 07 00 00    	jne    f0101eba <mem_init+0xd9c>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101721:	6a 02                	push   $0x2
f0101723:	6a 00                	push   $0x0
f0101725:	53                   	push   %ebx
f0101726:	ff 35 68 89 11 f0    	pushl  0xf0118968
f010172c:	e8 86 f9 ff ff       	call   f01010b7 <page_insert>
f0101731:	83 c4 10             	add    $0x10,%esp
f0101734:	85 c0                	test   %eax,%eax
f0101736:	0f 89 97 07 00 00    	jns    f0101ed3 <mem_init+0xdb5>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010173c:	83 ec 0c             	sub    $0xc,%esp
f010173f:	57                   	push   %edi
f0101740:	e8 e4 f6 ff ff       	call   f0100e29 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101745:	6a 02                	push   $0x2
f0101747:	6a 00                	push   $0x0
f0101749:	53                   	push   %ebx
f010174a:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101750:	e8 62 f9 ff ff       	call   f01010b7 <page_insert>
f0101755:	83 c4 20             	add    $0x20,%esp
f0101758:	85 c0                	test   %eax,%eax
f010175a:	0f 85 8c 07 00 00    	jne    f0101eec <mem_init+0xdce>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101760:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101765:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	return (pp - pages) << PGSHIFT;
f0101768:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
f010176e:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101771:	8b 00                	mov    (%eax),%eax
f0101773:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101776:	89 c2                	mov    %eax,%edx
f0101778:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010177e:	89 f8                	mov    %edi,%eax
f0101780:	29 c8                	sub    %ecx,%eax
f0101782:	c1 f8 03             	sar    $0x3,%eax
f0101785:	c1 e0 0c             	shl    $0xc,%eax
f0101788:	39 c2                	cmp    %eax,%edx
f010178a:	0f 85 75 07 00 00    	jne    f0101f05 <mem_init+0xde7>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101790:	ba 00 00 00 00       	mov    $0x0,%edx
f0101795:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101798:	e8 38 f2 ff ff       	call   f01009d5 <check_va2pa>
f010179d:	89 da                	mov    %ebx,%edx
f010179f:	2b 55 d0             	sub    -0x30(%ebp),%edx
f01017a2:	c1 fa 03             	sar    $0x3,%edx
f01017a5:	c1 e2 0c             	shl    $0xc,%edx
f01017a8:	39 d0                	cmp    %edx,%eax
f01017aa:	0f 85 6e 07 00 00    	jne    f0101f1e <mem_init+0xe00>
	assert(pp1->pp_ref == 1);
f01017b0:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01017b5:	0f 85 7c 07 00 00    	jne    f0101f37 <mem_init+0xe19>
	assert(pp0->pp_ref == 1);
f01017bb:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01017c0:	0f 85 8a 07 00 00    	jne    f0101f50 <mem_init+0xe32>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01017c6:	6a 02                	push   $0x2
f01017c8:	68 00 10 00 00       	push   $0x1000
f01017cd:	56                   	push   %esi
f01017ce:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017d1:	e8 e1 f8 ff ff       	call   f01010b7 <page_insert>
f01017d6:	83 c4 10             	add    $0x10,%esp
f01017d9:	85 c0                	test   %eax,%eax
f01017db:	0f 85 88 07 00 00    	jne    f0101f69 <mem_init+0xe4b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01017e1:	ba 00 10 00 00       	mov    $0x1000,%edx
f01017e6:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f01017eb:	e8 e5 f1 ff ff       	call   f01009d5 <check_va2pa>
f01017f0:	89 f2                	mov    %esi,%edx
f01017f2:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f01017f8:	c1 fa 03             	sar    $0x3,%edx
f01017fb:	c1 e2 0c             	shl    $0xc,%edx
f01017fe:	39 d0                	cmp    %edx,%eax
f0101800:	0f 85 7c 07 00 00    	jne    f0101f82 <mem_init+0xe64>
	assert(pp2->pp_ref == 1);
f0101806:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010180b:	0f 85 8a 07 00 00    	jne    f0101f9b <mem_init+0xe7d>

	// should be no free memory
	assert(!page_alloc(0));
f0101811:	83 ec 0c             	sub    $0xc,%esp
f0101814:	6a 00                	push   $0x0
f0101816:	e8 9c f5 ff ff       	call   f0100db7 <page_alloc>
f010181b:	83 c4 10             	add    $0x10,%esp
f010181e:	85 c0                	test   %eax,%eax
f0101820:	0f 85 8e 07 00 00    	jne    f0101fb4 <mem_init+0xe96>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101826:	6a 02                	push   $0x2
f0101828:	68 00 10 00 00       	push   $0x1000
f010182d:	56                   	push   %esi
f010182e:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101834:	e8 7e f8 ff ff       	call   f01010b7 <page_insert>
f0101839:	83 c4 10             	add    $0x10,%esp
f010183c:	85 c0                	test   %eax,%eax
f010183e:	0f 85 89 07 00 00    	jne    f0101fcd <mem_init+0xeaf>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101844:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101849:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f010184e:	e8 82 f1 ff ff       	call   f01009d5 <check_va2pa>
f0101853:	89 f2                	mov    %esi,%edx
f0101855:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f010185b:	c1 fa 03             	sar    $0x3,%edx
f010185e:	c1 e2 0c             	shl    $0xc,%edx
f0101861:	39 d0                	cmp    %edx,%eax
f0101863:	0f 85 7d 07 00 00    	jne    f0101fe6 <mem_init+0xec8>
	assert(pp2->pp_ref == 1);
f0101869:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010186e:	0f 85 8b 07 00 00    	jne    f0101fff <mem_init+0xee1>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101874:	83 ec 0c             	sub    $0xc,%esp
f0101877:	6a 00                	push   $0x0
f0101879:	e8 39 f5 ff ff       	call   f0100db7 <page_alloc>
f010187e:	83 c4 10             	add    $0x10,%esp
f0101881:	85 c0                	test   %eax,%eax
f0101883:	0f 85 8f 07 00 00    	jne    f0102018 <mem_init+0xefa>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101889:	8b 15 68 89 11 f0    	mov    0xf0118968,%edx
f010188f:	8b 02                	mov    (%edx),%eax
f0101891:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101896:	89 c1                	mov    %eax,%ecx
f0101898:	c1 e9 0c             	shr    $0xc,%ecx
f010189b:	3b 0d 64 89 11 f0    	cmp    0xf0118964,%ecx
f01018a1:	0f 83 8a 07 00 00    	jae    f0102031 <mem_init+0xf13>
	return (void *)(pa + KERNBASE);
f01018a7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01018ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01018af:	83 ec 04             	sub    $0x4,%esp
f01018b2:	6a 00                	push   $0x0
f01018b4:	68 00 10 00 00       	push   $0x1000
f01018b9:	52                   	push   %edx
f01018ba:	e8 e2 f5 ff ff       	call   f0100ea1 <pgdir_walk>
f01018bf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01018c2:	8d 51 04             	lea    0x4(%ecx),%edx
f01018c5:	83 c4 10             	add    $0x10,%esp
f01018c8:	39 d0                	cmp    %edx,%eax
f01018ca:	0f 85 76 07 00 00    	jne    f0102046 <mem_init+0xf28>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01018d0:	6a 06                	push   $0x6
f01018d2:	68 00 10 00 00       	push   $0x1000
f01018d7:	56                   	push   %esi
f01018d8:	ff 35 68 89 11 f0    	pushl  0xf0118968
f01018de:	e8 d4 f7 ff ff       	call   f01010b7 <page_insert>
f01018e3:	83 c4 10             	add    $0x10,%esp
f01018e6:	85 c0                	test   %eax,%eax
f01018e8:	0f 85 71 07 00 00    	jne    f010205f <mem_init+0xf41>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01018ee:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f01018f3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018f6:	ba 00 10 00 00       	mov    $0x1000,%edx
f01018fb:	e8 d5 f0 ff ff       	call   f01009d5 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101900:	89 f2                	mov    %esi,%edx
f0101902:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f0101908:	c1 fa 03             	sar    $0x3,%edx
f010190b:	c1 e2 0c             	shl    $0xc,%edx
f010190e:	39 d0                	cmp    %edx,%eax
f0101910:	0f 85 62 07 00 00    	jne    f0102078 <mem_init+0xf5a>
	assert(pp2->pp_ref == 1);
f0101916:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010191b:	0f 85 70 07 00 00    	jne    f0102091 <mem_init+0xf73>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101921:	83 ec 04             	sub    $0x4,%esp
f0101924:	6a 00                	push   $0x0
f0101926:	68 00 10 00 00       	push   $0x1000
f010192b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010192e:	e8 6e f5 ff ff       	call   f0100ea1 <pgdir_walk>
f0101933:	83 c4 10             	add    $0x10,%esp
f0101936:	f6 00 04             	testb  $0x4,(%eax)
f0101939:	0f 84 6b 07 00 00    	je     f01020aa <mem_init+0xf8c>
	assert(kern_pgdir[0] & PTE_U);
f010193f:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101944:	f6 00 04             	testb  $0x4,(%eax)
f0101947:	0f 84 76 07 00 00    	je     f01020c3 <mem_init+0xfa5>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010194d:	6a 02                	push   $0x2
f010194f:	68 00 10 00 00       	push   $0x1000
f0101954:	56                   	push   %esi
f0101955:	50                   	push   %eax
f0101956:	e8 5c f7 ff ff       	call   f01010b7 <page_insert>
f010195b:	83 c4 10             	add    $0x10,%esp
f010195e:	85 c0                	test   %eax,%eax
f0101960:	0f 85 76 07 00 00    	jne    f01020dc <mem_init+0xfbe>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101966:	83 ec 04             	sub    $0x4,%esp
f0101969:	6a 00                	push   $0x0
f010196b:	68 00 10 00 00       	push   $0x1000
f0101970:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101976:	e8 26 f5 ff ff       	call   f0100ea1 <pgdir_walk>
f010197b:	83 c4 10             	add    $0x10,%esp
f010197e:	f6 00 02             	testb  $0x2,(%eax)
f0101981:	0f 84 6e 07 00 00    	je     f01020f5 <mem_init+0xfd7>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101987:	83 ec 04             	sub    $0x4,%esp
f010198a:	6a 00                	push   $0x0
f010198c:	68 00 10 00 00       	push   $0x1000
f0101991:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101997:	e8 05 f5 ff ff       	call   f0100ea1 <pgdir_walk>
f010199c:	83 c4 10             	add    $0x10,%esp
f010199f:	f6 00 04             	testb  $0x4,(%eax)
f01019a2:	0f 85 66 07 00 00    	jne    f010210e <mem_init+0xff0>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01019a8:	6a 02                	push   $0x2
f01019aa:	68 00 00 40 00       	push   $0x400000
f01019af:	57                   	push   %edi
f01019b0:	ff 35 68 89 11 f0    	pushl  0xf0118968
f01019b6:	e8 fc f6 ff ff       	call   f01010b7 <page_insert>
f01019bb:	83 c4 10             	add    $0x10,%esp
f01019be:	85 c0                	test   %eax,%eax
f01019c0:	0f 89 61 07 00 00    	jns    f0102127 <mem_init+0x1009>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01019c6:	6a 02                	push   $0x2
f01019c8:	68 00 10 00 00       	push   $0x1000
f01019cd:	53                   	push   %ebx
f01019ce:	ff 35 68 89 11 f0    	pushl  0xf0118968
f01019d4:	e8 de f6 ff ff       	call   f01010b7 <page_insert>
f01019d9:	83 c4 10             	add    $0x10,%esp
f01019dc:	85 c0                	test   %eax,%eax
f01019de:	0f 85 5c 07 00 00    	jne    f0102140 <mem_init+0x1022>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01019e4:	83 ec 04             	sub    $0x4,%esp
f01019e7:	6a 00                	push   $0x0
f01019e9:	68 00 10 00 00       	push   $0x1000
f01019ee:	ff 35 68 89 11 f0    	pushl  0xf0118968
f01019f4:	e8 a8 f4 ff ff       	call   f0100ea1 <pgdir_walk>
f01019f9:	83 c4 10             	add    $0x10,%esp
f01019fc:	f6 00 04             	testb  $0x4,(%eax)
f01019ff:	0f 85 54 07 00 00    	jne    f0102159 <mem_init+0x103b>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101a05:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101a0a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a0d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a12:	e8 be ef ff ff       	call   f01009d5 <check_va2pa>
f0101a17:	89 c1                	mov    %eax,%ecx
f0101a19:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101a1c:	89 d8                	mov    %ebx,%eax
f0101a1e:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0101a24:	c1 f8 03             	sar    $0x3,%eax
f0101a27:	c1 e0 0c             	shl    $0xc,%eax
f0101a2a:	39 c1                	cmp    %eax,%ecx
f0101a2c:	0f 85 40 07 00 00    	jne    f0102172 <mem_init+0x1054>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101a32:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a37:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a3a:	e8 96 ef ff ff       	call   f01009d5 <check_va2pa>
f0101a3f:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101a42:	0f 85 43 07 00 00    	jne    f010218b <mem_init+0x106d>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101a48:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101a4d:	0f 85 51 07 00 00    	jne    f01021a4 <mem_init+0x1086>
	assert(pp2->pp_ref == 0);
f0101a53:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101a58:	0f 85 5f 07 00 00    	jne    f01021bd <mem_init+0x109f>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101a5e:	83 ec 0c             	sub    $0xc,%esp
f0101a61:	6a 00                	push   $0x0
f0101a63:	e8 4f f3 ff ff       	call   f0100db7 <page_alloc>
f0101a68:	83 c4 10             	add    $0x10,%esp
f0101a6b:	85 c0                	test   %eax,%eax
f0101a6d:	0f 84 63 07 00 00    	je     f01021d6 <mem_init+0x10b8>
f0101a73:	39 c6                	cmp    %eax,%esi
f0101a75:	0f 85 5b 07 00 00    	jne    f01021d6 <mem_init+0x10b8>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101a7b:	83 ec 08             	sub    $0x8,%esp
f0101a7e:	6a 00                	push   $0x0
f0101a80:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101a86:	e8 e4 f5 ff ff       	call   f010106f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101a8b:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101a90:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a93:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a98:	e8 38 ef ff ff       	call   f01009d5 <check_va2pa>
f0101a9d:	83 c4 10             	add    $0x10,%esp
f0101aa0:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101aa3:	0f 85 46 07 00 00    	jne    f01021ef <mem_init+0x10d1>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101aa9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101aae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ab1:	e8 1f ef ff ff       	call   f01009d5 <check_va2pa>
f0101ab6:	89 da                	mov    %ebx,%edx
f0101ab8:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f0101abe:	c1 fa 03             	sar    $0x3,%edx
f0101ac1:	c1 e2 0c             	shl    $0xc,%edx
f0101ac4:	39 d0                	cmp    %edx,%eax
f0101ac6:	0f 85 3c 07 00 00    	jne    f0102208 <mem_init+0x10ea>
	assert(pp1->pp_ref == 1);
f0101acc:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ad1:	0f 85 4a 07 00 00    	jne    f0102221 <mem_init+0x1103>
	assert(pp2->pp_ref == 0);
f0101ad7:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101adc:	0f 85 58 07 00 00    	jne    f010223a <mem_init+0x111c>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101ae2:	6a 00                	push   $0x0
f0101ae4:	68 00 10 00 00       	push   $0x1000
f0101ae9:	53                   	push   %ebx
f0101aea:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101aed:	e8 c5 f5 ff ff       	call   f01010b7 <page_insert>
f0101af2:	83 c4 10             	add    $0x10,%esp
f0101af5:	85 c0                	test   %eax,%eax
f0101af7:	0f 85 56 07 00 00    	jne    f0102253 <mem_init+0x1135>
	assert(pp1->pp_ref);
f0101afd:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101b02:	0f 84 64 07 00 00    	je     f010226c <mem_init+0x114e>
	assert(pp1->pp_link == NULL);
f0101b08:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101b0b:	0f 85 74 07 00 00    	jne    f0102285 <mem_init+0x1167>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101b11:	83 ec 08             	sub    $0x8,%esp
f0101b14:	68 00 10 00 00       	push   $0x1000
f0101b19:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101b1f:	e8 4b f5 ff ff       	call   f010106f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101b24:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101b29:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101b2c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b31:	e8 9f ee ff ff       	call   f01009d5 <check_va2pa>
f0101b36:	83 c4 10             	add    $0x10,%esp
f0101b39:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101b3c:	0f 85 5c 07 00 00    	jne    f010229e <mem_init+0x1180>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101b42:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b47:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b4a:	e8 86 ee ff ff       	call   f01009d5 <check_va2pa>
f0101b4f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101b52:	0f 85 5f 07 00 00    	jne    f01022b7 <mem_init+0x1199>
	assert(pp1->pp_ref == 0);
f0101b58:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101b5d:	0f 85 6d 07 00 00    	jne    f01022d0 <mem_init+0x11b2>
	assert(pp2->pp_ref == 0);
f0101b63:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101b68:	0f 85 7b 07 00 00    	jne    f01022e9 <mem_init+0x11cb>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101b6e:	83 ec 0c             	sub    $0xc,%esp
f0101b71:	6a 00                	push   $0x0
f0101b73:	e8 3f f2 ff ff       	call   f0100db7 <page_alloc>
f0101b78:	83 c4 10             	add    $0x10,%esp
f0101b7b:	85 c0                	test   %eax,%eax
f0101b7d:	0f 84 7f 07 00 00    	je     f0102302 <mem_init+0x11e4>
f0101b83:	39 c3                	cmp    %eax,%ebx
f0101b85:	0f 85 77 07 00 00    	jne    f0102302 <mem_init+0x11e4>

	// should be no free memory
	assert(!page_alloc(0));
f0101b8b:	83 ec 0c             	sub    $0xc,%esp
f0101b8e:	6a 00                	push   $0x0
f0101b90:	e8 22 f2 ff ff       	call   f0100db7 <page_alloc>
f0101b95:	83 c4 10             	add    $0x10,%esp
f0101b98:	85 c0                	test   %eax,%eax
f0101b9a:	0f 85 7b 07 00 00    	jne    f010231b <mem_init+0x11fd>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101ba0:	8b 0d 68 89 11 f0    	mov    0xf0118968,%ecx
f0101ba6:	8b 11                	mov    (%ecx),%edx
f0101ba8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101bae:	89 f8                	mov    %edi,%eax
f0101bb0:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0101bb6:	c1 f8 03             	sar    $0x3,%eax
f0101bb9:	c1 e0 0c             	shl    $0xc,%eax
f0101bbc:	39 c2                	cmp    %eax,%edx
f0101bbe:	0f 85 70 07 00 00    	jne    f0102334 <mem_init+0x1216>
	kern_pgdir[0] = 0;
f0101bc4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101bca:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101bcf:	0f 85 78 07 00 00    	jne    f010234d <mem_init+0x122f>
	pp0->pp_ref = 0;
f0101bd5:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101bdb:	83 ec 0c             	sub    $0xc,%esp
f0101bde:	57                   	push   %edi
f0101bdf:	e8 45 f2 ff ff       	call   f0100e29 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101be4:	83 c4 0c             	add    $0xc,%esp
f0101be7:	6a 01                	push   $0x1
f0101be9:	68 00 10 40 00       	push   $0x401000
f0101bee:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101bf4:	e8 a8 f2 ff ff       	call   f0100ea1 <pgdir_walk>
f0101bf9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101bfc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101bff:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101c04:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101c07:	8b 50 04             	mov    0x4(%eax),%edx
f0101c0a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101c10:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0101c15:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101c18:	89 d1                	mov    %edx,%ecx
f0101c1a:	c1 e9 0c             	shr    $0xc,%ecx
f0101c1d:	83 c4 10             	add    $0x10,%esp
f0101c20:	39 c1                	cmp    %eax,%ecx
f0101c22:	0f 83 3e 07 00 00    	jae    f0102366 <mem_init+0x1248>
	assert(ptep == ptep1 + PTX(va));
f0101c28:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0101c2e:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0101c31:	0f 85 44 07 00 00    	jne    f010237b <mem_init+0x125d>
	kern_pgdir[PDX(va)] = 0;
f0101c37:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c3a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101c41:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
	return (pp - pages) << PGSHIFT;
f0101c47:	89 f8                	mov    %edi,%eax
f0101c49:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0101c4f:	c1 f8 03             	sar    $0x3,%eax
f0101c52:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101c55:	89 c2                	mov    %eax,%edx
f0101c57:	c1 ea 0c             	shr    $0xc,%edx
f0101c5a:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f0101c5d:	0f 86 31 07 00 00    	jbe    f0102394 <mem_init+0x1276>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101c63:	83 ec 04             	sub    $0x4,%esp
f0101c66:	68 00 10 00 00       	push   $0x1000
f0101c6b:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101c70:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c75:	50                   	push   %eax
f0101c76:	e8 44 18 00 00       	call   f01034bf <memset>
	page_free(pp0);
f0101c7b:	89 3c 24             	mov    %edi,(%esp)
f0101c7e:	e8 a6 f1 ff ff       	call   f0100e29 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101c83:	83 c4 0c             	add    $0xc,%esp
f0101c86:	6a 01                	push   $0x1
f0101c88:	6a 00                	push   $0x0
f0101c8a:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101c90:	e8 0c f2 ff ff       	call   f0100ea1 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101c95:	89 fa                	mov    %edi,%edx
f0101c97:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f0101c9d:	c1 fa 03             	sar    $0x3,%edx
f0101ca0:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101ca3:	89 d0                	mov    %edx,%eax
f0101ca5:	c1 e8 0c             	shr    $0xc,%eax
f0101ca8:	83 c4 10             	add    $0x10,%esp
f0101cab:	3b 05 64 89 11 f0    	cmp    0xf0118964,%eax
f0101cb1:	0f 83 ef 06 00 00    	jae    f01023a6 <mem_init+0x1288>
	return (void *)(pa + KERNBASE);
f0101cb7:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101cbd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101cc0:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101cc6:	f6 00 01             	testb  $0x1,(%eax)
f0101cc9:	0f 85 e9 06 00 00    	jne    f01023b8 <mem_init+0x129a>
f0101ccf:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0101cd2:	39 c2                	cmp    %eax,%edx
f0101cd4:	75 f0                	jne    f0101cc6 <mem_init+0xba8>
	kern_pgdir[0] = 0;
f0101cd6:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101cdb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101ce1:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0101ce7:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0101cea:	a3 3c 85 11 f0       	mov    %eax,0xf011853c

	// free the pages we took
	page_free(pp0);
f0101cef:	83 ec 0c             	sub    $0xc,%esp
f0101cf2:	57                   	push   %edi
f0101cf3:	e8 31 f1 ff ff       	call   f0100e29 <page_free>
	page_free(pp1);
f0101cf8:	89 1c 24             	mov    %ebx,(%esp)
f0101cfb:	e8 29 f1 ff ff       	call   f0100e29 <page_free>
	page_free(pp2);
f0101d00:	89 34 24             	mov    %esi,(%esp)
f0101d03:	e8 21 f1 ff ff       	call   f0100e29 <page_free>

	cprintf("check_page() succeeded!\n");
f0101d08:	c7 04 24 fd 48 10 f0 	movl   $0xf01048fd,(%esp)
f0101d0f:	e8 7c 0c 00 00       	call   f0102990 <cprintf>
	sz = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0101d14:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0101d19:	8d 0c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ecx
f0101d20:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_region(kern_pgdir, UPAGES, sz, PADDR(pages), PTE_U | PTE_P);
f0101d26:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
	if ((uint32_t)kva < KERNBASE)
f0101d2b:	83 c4 10             	add    $0x10,%esp
f0101d2e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101d33:	0f 86 98 06 00 00    	jbe    f01023d1 <mem_init+0x12b3>
f0101d39:	83 ec 08             	sub    $0x8,%esp
f0101d3c:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0101d3e:	05 00 00 00 10       	add    $0x10000000,%eax
f0101d43:	50                   	push   %eax
f0101d44:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0101d49:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101d4e:	e8 67 f2 ff ff       	call   f0100fba <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0101d53:	83 c4 10             	add    $0x10,%esp
f0101d56:	b8 00 e0 10 f0       	mov    $0xf010e000,%eax
f0101d5b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101d60:	0f 86 80 06 00 00    	jbe    f01023e6 <mem_init+0x12c8>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, 
f0101d66:	83 ec 08             	sub    $0x8,%esp
f0101d69:	6a 03                	push   $0x3
f0101d6b:	68 00 e0 10 00       	push   $0x10e000
f0101d70:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0101d75:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0101d7a:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101d7f:	e8 36 f2 ff ff       	call   f0100fba <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 1 << 28, // 2^32 - 0xf0000000
f0101d84:	83 c4 08             	add    $0x8,%esp
f0101d87:	6a 03                	push   $0x3
f0101d89:	6a 00                	push   $0x0
f0101d8b:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0101d90:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0101d95:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101d9a:	e8 1b f2 ff ff       	call   f0100fba <boot_map_region>
	pgdir = kern_pgdir;
f0101d9f:	8b 1d 68 89 11 f0    	mov    0xf0118968,%ebx
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0101da5:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0101daa:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101dad:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0101db4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101db9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101dbc:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0101dc1:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101dc4:	89 45 d0             	mov    %eax,-0x30(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0101dc7:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f0101dcd:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i += PGSIZE) 
f0101dd0:	be 00 00 00 00       	mov    $0x0,%esi
f0101dd5:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0101dd8:	0f 86 4d 06 00 00    	jbe    f010242b <mem_init+0x130d>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101dde:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f0101de4:	89 d8                	mov    %ebx,%eax
f0101de6:	e8 ea eb ff ff       	call   f01009d5 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0101deb:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0101df2:	0f 86 03 06 00 00    	jbe    f01023fb <mem_init+0x12dd>
f0101df8:	8d 14 3e             	lea    (%esi,%edi,1),%edx
f0101dfb:	39 d0                	cmp    %edx,%eax
f0101dfd:	0f 85 0f 06 00 00    	jne    f0102412 <mem_init+0x12f4>
	for (i = 0; i < n; i += PGSIZE) 
f0101e03:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101e09:	eb ca                	jmp    f0101dd5 <mem_init+0xcb7>
	assert(nfree == 0);
f0101e0b:	68 26 48 10 f0       	push   $0xf0104826
f0101e10:	68 5e 46 10 f0       	push   $0xf010465e
f0101e15:	68 7e 02 00 00       	push   $0x27e
f0101e1a:	68 38 46 10 f0       	push   $0xf0104638
f0101e1f:	e8 0f e3 ff ff       	call   f0100133 <_panic>
	assert((pp0 = page_alloc(0)));
f0101e24:	68 34 47 10 f0       	push   $0xf0104734
f0101e29:	68 5e 46 10 f0       	push   $0xf010465e
f0101e2e:	68 da 02 00 00       	push   $0x2da
f0101e33:	68 38 46 10 f0       	push   $0xf0104638
f0101e38:	e8 f6 e2 ff ff       	call   f0100133 <_panic>
	assert((pp1 = page_alloc(0)));
f0101e3d:	68 4a 47 10 f0       	push   $0xf010474a
f0101e42:	68 5e 46 10 f0       	push   $0xf010465e
f0101e47:	68 db 02 00 00       	push   $0x2db
f0101e4c:	68 38 46 10 f0       	push   $0xf0104638
f0101e51:	e8 dd e2 ff ff       	call   f0100133 <_panic>
	assert((pp2 = page_alloc(0)));
f0101e56:	68 60 47 10 f0       	push   $0xf0104760
f0101e5b:	68 5e 46 10 f0       	push   $0xf010465e
f0101e60:	68 dc 02 00 00       	push   $0x2dc
f0101e65:	68 38 46 10 f0       	push   $0xf0104638
f0101e6a:	e8 c4 e2 ff ff       	call   f0100133 <_panic>
	assert(pp1 && pp1 != pp0);
f0101e6f:	68 76 47 10 f0       	push   $0xf0104776
f0101e74:	68 5e 46 10 f0       	push   $0xf010465e
f0101e79:	68 df 02 00 00       	push   $0x2df
f0101e7e:	68 38 46 10 f0       	push   $0xf0104638
f0101e83:	e8 ab e2 ff ff       	call   f0100133 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101e88:	68 4c 40 10 f0       	push   $0xf010404c
f0101e8d:	68 5e 46 10 f0       	push   $0xf010465e
f0101e92:	68 e0 02 00 00       	push   $0x2e0
f0101e97:	68 38 46 10 f0       	push   $0xf0104638
f0101e9c:	e8 92 e2 ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f0101ea1:	68 df 47 10 f0       	push   $0xf01047df
f0101ea6:	68 5e 46 10 f0       	push   $0xf010465e
f0101eab:	68 e7 02 00 00       	push   $0x2e7
f0101eb0:	68 38 46 10 f0       	push   $0xf0104638
f0101eb5:	e8 79 e2 ff ff       	call   f0100133 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101eba:	68 8c 40 10 f0       	push   $0xf010408c
f0101ebf:	68 5e 46 10 f0       	push   $0xf010465e
f0101ec4:	68 ea 02 00 00       	push   $0x2ea
f0101ec9:	68 38 46 10 f0       	push   $0xf0104638
f0101ece:	e8 60 e2 ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101ed3:	68 c4 40 10 f0       	push   $0xf01040c4
f0101ed8:	68 5e 46 10 f0       	push   $0xf010465e
f0101edd:	68 ed 02 00 00       	push   $0x2ed
f0101ee2:	68 38 46 10 f0       	push   $0xf0104638
f0101ee7:	e8 47 e2 ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101eec:	68 f4 40 10 f0       	push   $0xf01040f4
f0101ef1:	68 5e 46 10 f0       	push   $0xf010465e
f0101ef6:	68 f1 02 00 00       	push   $0x2f1
f0101efb:	68 38 46 10 f0       	push   $0xf0104638
f0101f00:	e8 2e e2 ff ff       	call   f0100133 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101f05:	68 24 41 10 f0       	push   $0xf0104124
f0101f0a:	68 5e 46 10 f0       	push   $0xf010465e
f0101f0f:	68 f2 02 00 00       	push   $0x2f2
f0101f14:	68 38 46 10 f0       	push   $0xf0104638
f0101f19:	e8 15 e2 ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101f1e:	68 4c 41 10 f0       	push   $0xf010414c
f0101f23:	68 5e 46 10 f0       	push   $0xf010465e
f0101f28:	68 f3 02 00 00       	push   $0x2f3
f0101f2d:	68 38 46 10 f0       	push   $0xf0104638
f0101f32:	e8 fc e1 ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 1);
f0101f37:	68 31 48 10 f0       	push   $0xf0104831
f0101f3c:	68 5e 46 10 f0       	push   $0xf010465e
f0101f41:	68 f4 02 00 00       	push   $0x2f4
f0101f46:	68 38 46 10 f0       	push   $0xf0104638
f0101f4b:	e8 e3 e1 ff ff       	call   f0100133 <_panic>
	assert(pp0->pp_ref == 1);
f0101f50:	68 42 48 10 f0       	push   $0xf0104842
f0101f55:	68 5e 46 10 f0       	push   $0xf010465e
f0101f5a:	68 f5 02 00 00       	push   $0x2f5
f0101f5f:	68 38 46 10 f0       	push   $0xf0104638
f0101f64:	e8 ca e1 ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f69:	68 7c 41 10 f0       	push   $0xf010417c
f0101f6e:	68 5e 46 10 f0       	push   $0xf010465e
f0101f73:	68 f8 02 00 00       	push   $0x2f8
f0101f78:	68 38 46 10 f0       	push   $0xf0104638
f0101f7d:	e8 b1 e1 ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f82:	68 b8 41 10 f0       	push   $0xf01041b8
f0101f87:	68 5e 46 10 f0       	push   $0xf010465e
f0101f8c:	68 f9 02 00 00       	push   $0x2f9
f0101f91:	68 38 46 10 f0       	push   $0xf0104638
f0101f96:	e8 98 e1 ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 1);
f0101f9b:	68 53 48 10 f0       	push   $0xf0104853
f0101fa0:	68 5e 46 10 f0       	push   $0xf010465e
f0101fa5:	68 fa 02 00 00       	push   $0x2fa
f0101faa:	68 38 46 10 f0       	push   $0xf0104638
f0101faf:	e8 7f e1 ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f0101fb4:	68 df 47 10 f0       	push   $0xf01047df
f0101fb9:	68 5e 46 10 f0       	push   $0xf010465e
f0101fbe:	68 fd 02 00 00       	push   $0x2fd
f0101fc3:	68 38 46 10 f0       	push   $0xf0104638
f0101fc8:	e8 66 e1 ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101fcd:	68 7c 41 10 f0       	push   $0xf010417c
f0101fd2:	68 5e 46 10 f0       	push   $0xf010465e
f0101fd7:	68 00 03 00 00       	push   $0x300
f0101fdc:	68 38 46 10 f0       	push   $0xf0104638
f0101fe1:	e8 4d e1 ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101fe6:	68 b8 41 10 f0       	push   $0xf01041b8
f0101feb:	68 5e 46 10 f0       	push   $0xf010465e
f0101ff0:	68 01 03 00 00       	push   $0x301
f0101ff5:	68 38 46 10 f0       	push   $0xf0104638
f0101ffa:	e8 34 e1 ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 1);
f0101fff:	68 53 48 10 f0       	push   $0xf0104853
f0102004:	68 5e 46 10 f0       	push   $0xf010465e
f0102009:	68 02 03 00 00       	push   $0x302
f010200e:	68 38 46 10 f0       	push   $0xf0104638
f0102013:	e8 1b e1 ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f0102018:	68 df 47 10 f0       	push   $0xf01047df
f010201d:	68 5e 46 10 f0       	push   $0xf010465e
f0102022:	68 06 03 00 00       	push   $0x306
f0102027:	68 38 46 10 f0       	push   $0xf0104638
f010202c:	e8 02 e1 ff ff       	call   f0100133 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102031:	50                   	push   %eax
f0102032:	68 c0 3e 10 f0       	push   $0xf0103ec0
f0102037:	68 09 03 00 00       	push   $0x309
f010203c:	68 38 46 10 f0       	push   $0xf0104638
f0102041:	e8 ed e0 ff ff       	call   f0100133 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102046:	68 e8 41 10 f0       	push   $0xf01041e8
f010204b:	68 5e 46 10 f0       	push   $0xf010465e
f0102050:	68 0a 03 00 00       	push   $0x30a
f0102055:	68 38 46 10 f0       	push   $0xf0104638
f010205a:	e8 d4 e0 ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010205f:	68 28 42 10 f0       	push   $0xf0104228
f0102064:	68 5e 46 10 f0       	push   $0xf010465e
f0102069:	68 0d 03 00 00       	push   $0x30d
f010206e:	68 38 46 10 f0       	push   $0xf0104638
f0102073:	e8 bb e0 ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102078:	68 b8 41 10 f0       	push   $0xf01041b8
f010207d:	68 5e 46 10 f0       	push   $0xf010465e
f0102082:	68 0e 03 00 00       	push   $0x30e
f0102087:	68 38 46 10 f0       	push   $0xf0104638
f010208c:	e8 a2 e0 ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 1);
f0102091:	68 53 48 10 f0       	push   $0xf0104853
f0102096:	68 5e 46 10 f0       	push   $0xf010465e
f010209b:	68 0f 03 00 00       	push   $0x30f
f01020a0:	68 38 46 10 f0       	push   $0xf0104638
f01020a5:	e8 89 e0 ff ff       	call   f0100133 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01020aa:	68 68 42 10 f0       	push   $0xf0104268
f01020af:	68 5e 46 10 f0       	push   $0xf010465e
f01020b4:	68 10 03 00 00       	push   $0x310
f01020b9:	68 38 46 10 f0       	push   $0xf0104638
f01020be:	e8 70 e0 ff ff       	call   f0100133 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01020c3:	68 64 48 10 f0       	push   $0xf0104864
f01020c8:	68 5e 46 10 f0       	push   $0xf010465e
f01020cd:	68 11 03 00 00       	push   $0x311
f01020d2:	68 38 46 10 f0       	push   $0xf0104638
f01020d7:	e8 57 e0 ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01020dc:	68 7c 41 10 f0       	push   $0xf010417c
f01020e1:	68 5e 46 10 f0       	push   $0xf010465e
f01020e6:	68 14 03 00 00       	push   $0x314
f01020eb:	68 38 46 10 f0       	push   $0xf0104638
f01020f0:	e8 3e e0 ff ff       	call   f0100133 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f01020f5:	68 9c 42 10 f0       	push   $0xf010429c
f01020fa:	68 5e 46 10 f0       	push   $0xf010465e
f01020ff:	68 15 03 00 00       	push   $0x315
f0102104:	68 38 46 10 f0       	push   $0xf0104638
f0102109:	e8 25 e0 ff ff       	call   f0100133 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010210e:	68 d0 42 10 f0       	push   $0xf01042d0
f0102113:	68 5e 46 10 f0       	push   $0xf010465e
f0102118:	68 16 03 00 00       	push   $0x316
f010211d:	68 38 46 10 f0       	push   $0xf0104638
f0102122:	e8 0c e0 ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102127:	68 08 43 10 f0       	push   $0xf0104308
f010212c:	68 5e 46 10 f0       	push   $0xf010465e
f0102131:	68 19 03 00 00       	push   $0x319
f0102136:	68 38 46 10 f0       	push   $0xf0104638
f010213b:	e8 f3 df ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102140:	68 40 43 10 f0       	push   $0xf0104340
f0102145:	68 5e 46 10 f0       	push   $0xf010465e
f010214a:	68 1c 03 00 00       	push   $0x31c
f010214f:	68 38 46 10 f0       	push   $0xf0104638
f0102154:	e8 da df ff ff       	call   f0100133 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102159:	68 d0 42 10 f0       	push   $0xf01042d0
f010215e:	68 5e 46 10 f0       	push   $0xf010465e
f0102163:	68 1d 03 00 00       	push   $0x31d
f0102168:	68 38 46 10 f0       	push   $0xf0104638
f010216d:	e8 c1 df ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102172:	68 7c 43 10 f0       	push   $0xf010437c
f0102177:	68 5e 46 10 f0       	push   $0xf010465e
f010217c:	68 20 03 00 00       	push   $0x320
f0102181:	68 38 46 10 f0       	push   $0xf0104638
f0102186:	e8 a8 df ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010218b:	68 a8 43 10 f0       	push   $0xf01043a8
f0102190:	68 5e 46 10 f0       	push   $0xf010465e
f0102195:	68 21 03 00 00       	push   $0x321
f010219a:	68 38 46 10 f0       	push   $0xf0104638
f010219f:	e8 8f df ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 2);
f01021a4:	68 7a 48 10 f0       	push   $0xf010487a
f01021a9:	68 5e 46 10 f0       	push   $0xf010465e
f01021ae:	68 23 03 00 00       	push   $0x323
f01021b3:	68 38 46 10 f0       	push   $0xf0104638
f01021b8:	e8 76 df ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 0);
f01021bd:	68 8b 48 10 f0       	push   $0xf010488b
f01021c2:	68 5e 46 10 f0       	push   $0xf010465e
f01021c7:	68 24 03 00 00       	push   $0x324
f01021cc:	68 38 46 10 f0       	push   $0xf0104638
f01021d1:	e8 5d df ff ff       	call   f0100133 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01021d6:	68 d8 43 10 f0       	push   $0xf01043d8
f01021db:	68 5e 46 10 f0       	push   $0xf010465e
f01021e0:	68 27 03 00 00       	push   $0x327
f01021e5:	68 38 46 10 f0       	push   $0xf0104638
f01021ea:	e8 44 df ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01021ef:	68 fc 43 10 f0       	push   $0xf01043fc
f01021f4:	68 5e 46 10 f0       	push   $0xf010465e
f01021f9:	68 2b 03 00 00       	push   $0x32b
f01021fe:	68 38 46 10 f0       	push   $0xf0104638
f0102203:	e8 2b df ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102208:	68 a8 43 10 f0       	push   $0xf01043a8
f010220d:	68 5e 46 10 f0       	push   $0xf010465e
f0102212:	68 2c 03 00 00       	push   $0x32c
f0102217:	68 38 46 10 f0       	push   $0xf0104638
f010221c:	e8 12 df ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 1);
f0102221:	68 31 48 10 f0       	push   $0xf0104831
f0102226:	68 5e 46 10 f0       	push   $0xf010465e
f010222b:	68 2d 03 00 00       	push   $0x32d
f0102230:	68 38 46 10 f0       	push   $0xf0104638
f0102235:	e8 f9 de ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 0);
f010223a:	68 8b 48 10 f0       	push   $0xf010488b
f010223f:	68 5e 46 10 f0       	push   $0xf010465e
f0102244:	68 2e 03 00 00       	push   $0x32e
f0102249:	68 38 46 10 f0       	push   $0xf0104638
f010224e:	e8 e0 de ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102253:	68 20 44 10 f0       	push   $0xf0104420
f0102258:	68 5e 46 10 f0       	push   $0xf010465e
f010225d:	68 31 03 00 00       	push   $0x331
f0102262:	68 38 46 10 f0       	push   $0xf0104638
f0102267:	e8 c7 de ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref);
f010226c:	68 9c 48 10 f0       	push   $0xf010489c
f0102271:	68 5e 46 10 f0       	push   $0xf010465e
f0102276:	68 32 03 00 00       	push   $0x332
f010227b:	68 38 46 10 f0       	push   $0xf0104638
f0102280:	e8 ae de ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_link == NULL);
f0102285:	68 a8 48 10 f0       	push   $0xf01048a8
f010228a:	68 5e 46 10 f0       	push   $0xf010465e
f010228f:	68 33 03 00 00       	push   $0x333
f0102294:	68 38 46 10 f0       	push   $0xf0104638
f0102299:	e8 95 de ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010229e:	68 fc 43 10 f0       	push   $0xf01043fc
f01022a3:	68 5e 46 10 f0       	push   $0xf010465e
f01022a8:	68 37 03 00 00       	push   $0x337
f01022ad:	68 38 46 10 f0       	push   $0xf0104638
f01022b2:	e8 7c de ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01022b7:	68 58 44 10 f0       	push   $0xf0104458
f01022bc:	68 5e 46 10 f0       	push   $0xf010465e
f01022c1:	68 38 03 00 00       	push   $0x338
f01022c6:	68 38 46 10 f0       	push   $0xf0104638
f01022cb:	e8 63 de ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 0);
f01022d0:	68 bd 48 10 f0       	push   $0xf01048bd
f01022d5:	68 5e 46 10 f0       	push   $0xf010465e
f01022da:	68 39 03 00 00       	push   $0x339
f01022df:	68 38 46 10 f0       	push   $0xf0104638
f01022e4:	e8 4a de ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 0);
f01022e9:	68 8b 48 10 f0       	push   $0xf010488b
f01022ee:	68 5e 46 10 f0       	push   $0xf010465e
f01022f3:	68 3a 03 00 00       	push   $0x33a
f01022f8:	68 38 46 10 f0       	push   $0xf0104638
f01022fd:	e8 31 de ff ff       	call   f0100133 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102302:	68 80 44 10 f0       	push   $0xf0104480
f0102307:	68 5e 46 10 f0       	push   $0xf010465e
f010230c:	68 3d 03 00 00       	push   $0x33d
f0102311:	68 38 46 10 f0       	push   $0xf0104638
f0102316:	e8 18 de ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f010231b:	68 df 47 10 f0       	push   $0xf01047df
f0102320:	68 5e 46 10 f0       	push   $0xf010465e
f0102325:	68 40 03 00 00       	push   $0x340
f010232a:	68 38 46 10 f0       	push   $0xf0104638
f010232f:	e8 ff dd ff ff       	call   f0100133 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102334:	68 24 41 10 f0       	push   $0xf0104124
f0102339:	68 5e 46 10 f0       	push   $0xf010465e
f010233e:	68 43 03 00 00       	push   $0x343
f0102343:	68 38 46 10 f0       	push   $0xf0104638
f0102348:	e8 e6 dd ff ff       	call   f0100133 <_panic>
	assert(pp0->pp_ref == 1);
f010234d:	68 42 48 10 f0       	push   $0xf0104842
f0102352:	68 5e 46 10 f0       	push   $0xf010465e
f0102357:	68 45 03 00 00       	push   $0x345
f010235c:	68 38 46 10 f0       	push   $0xf0104638
f0102361:	e8 cd dd ff ff       	call   f0100133 <_panic>
f0102366:	52                   	push   %edx
f0102367:	68 c0 3e 10 f0       	push   $0xf0103ec0
f010236c:	68 4c 03 00 00       	push   $0x34c
f0102371:	68 38 46 10 f0       	push   $0xf0104638
f0102376:	e8 b8 dd ff ff       	call   f0100133 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010237b:	68 ce 48 10 f0       	push   $0xf01048ce
f0102380:	68 5e 46 10 f0       	push   $0xf010465e
f0102385:	68 4d 03 00 00       	push   $0x34d
f010238a:	68 38 46 10 f0       	push   $0xf0104638
f010238f:	e8 9f dd ff ff       	call   f0100133 <_panic>
f0102394:	50                   	push   %eax
f0102395:	68 c0 3e 10 f0       	push   $0xf0103ec0
f010239a:	6a 52                	push   $0x52
f010239c:	68 44 46 10 f0       	push   $0xf0104644
f01023a1:	e8 8d dd ff ff       	call   f0100133 <_panic>
f01023a6:	52                   	push   %edx
f01023a7:	68 c0 3e 10 f0       	push   $0xf0103ec0
f01023ac:	6a 52                	push   $0x52
f01023ae:	68 44 46 10 f0       	push   $0xf0104644
f01023b3:	e8 7b dd ff ff       	call   f0100133 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f01023b8:	68 e6 48 10 f0       	push   $0xf01048e6
f01023bd:	68 5e 46 10 f0       	push   $0xf010465e
f01023c2:	68 57 03 00 00       	push   $0x357
f01023c7:	68 38 46 10 f0       	push   $0xf0104638
f01023cc:	e8 62 dd ff ff       	call   f0100133 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01023d1:	50                   	push   %eax
f01023d2:	68 cc 3f 10 f0       	push   $0xf0103fcc
f01023d7:	68 b5 00 00 00       	push   $0xb5
f01023dc:	68 38 46 10 f0       	push   $0xf0104638
f01023e1:	e8 4d dd ff ff       	call   f0100133 <_panic>
f01023e6:	50                   	push   %eax
f01023e7:	68 cc 3f 10 f0       	push   $0xf0103fcc
f01023ec:	68 c2 00 00 00       	push   $0xc2
f01023f1:	68 38 46 10 f0       	push   $0xf0104638
f01023f6:	e8 38 dd ff ff       	call   f0100133 <_panic>
f01023fb:	ff 75 c8             	pushl  -0x38(%ebp)
f01023fe:	68 cc 3f 10 f0       	push   $0xf0103fcc
f0102403:	68 96 02 00 00       	push   $0x296
f0102408:	68 38 46 10 f0       	push   $0xf0104638
f010240d:	e8 21 dd ff ff       	call   f0100133 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102412:	68 a4 44 10 f0       	push   $0xf01044a4
f0102417:	68 5e 46 10 f0       	push   $0xf010465e
f010241c:	68 96 02 00 00       	push   $0x296
f0102421:	68 38 46 10 f0       	push   $0xf0104638
f0102426:	e8 08 dd ff ff       	call   f0100133 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010242b:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010242e:	c1 e7 0c             	shl    $0xc,%edi
f0102431:	be 00 00 00 00       	mov    $0x0,%esi
f0102436:	eb 17                	jmp    f010244f <mem_init+0x1331>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102438:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f010243e:	89 d8                	mov    %ebx,%eax
f0102440:	e8 90 e5 ff ff       	call   f01009d5 <check_va2pa>
f0102445:	39 c6                	cmp    %eax,%esi
f0102447:	75 50                	jne    f0102499 <mem_init+0x137b>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102449:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010244f:	39 fe                	cmp    %edi,%esi
f0102451:	72 e5                	jb     f0102438 <mem_init+0x131a>
f0102453:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102458:	b8 00 e0 10 f0       	mov    $0xf010e000,%eax
f010245d:	8d b8 00 80 00 20    	lea    0x20008000(%eax),%edi
f0102463:	89 f2                	mov    %esi,%edx
f0102465:	89 d8                	mov    %ebx,%eax
f0102467:	e8 69 e5 ff ff       	call   f01009d5 <check_va2pa>
f010246c:	8d 14 37             	lea    (%edi,%esi,1),%edx
f010246f:	39 d0                	cmp    %edx,%eax
f0102471:	75 3f                	jne    f01024b2 <mem_init+0x1394>
f0102473:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < KSTKSIZE; i += PGSIZE) {
f0102479:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f010247f:	75 e2                	jne    f0102463 <mem_init+0x1345>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102481:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102486:	89 d8                	mov    %ebx,%eax
f0102488:	e8 48 e5 ff ff       	call   f01009d5 <check_va2pa>
f010248d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102490:	75 39                	jne    f01024cb <mem_init+0x13ad>
	for (i = 0; i < NPDENTRIES; i++) {
f0102492:	b8 00 00 00 00       	mov    $0x0,%eax
f0102497:	eb 72                	jmp    f010250b <mem_init+0x13ed>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102499:	68 d8 44 10 f0       	push   $0xf01044d8
f010249e:	68 5e 46 10 f0       	push   $0xf010465e
f01024a3:	68 9b 02 00 00       	push   $0x29b
f01024a8:	68 38 46 10 f0       	push   $0xf0104638
f01024ad:	e8 81 dc ff ff       	call   f0100133 <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01024b2:	68 00 45 10 f0       	push   $0xf0104500
f01024b7:	68 5e 46 10 f0       	push   $0xf010465e
f01024bc:	68 9f 02 00 00       	push   $0x29f
f01024c1:	68 38 46 10 f0       	push   $0xf0104638
f01024c6:	e8 68 dc ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01024cb:	68 48 45 10 f0       	push   $0xf0104548
f01024d0:	68 5e 46 10 f0       	push   $0xf010465e
f01024d5:	68 a1 02 00 00       	push   $0x2a1
f01024da:	68 38 46 10 f0       	push   $0xf0104638
f01024df:	e8 4f dc ff ff       	call   f0100133 <_panic>
			assert(pgdir[i] & PTE_P);
f01024e4:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f01024e8:	74 47                	je     f0102531 <mem_init+0x1413>
	for (i = 0; i < NPDENTRIES; i++) {
f01024ea:	40                   	inc    %eax
f01024eb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f01024f0:	0f 87 93 00 00 00    	ja     f0102589 <mem_init+0x146b>
		switch (i) {
f01024f6:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f01024fb:	72 0e                	jb     f010250b <mem_init+0x13ed>
f01024fd:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102502:	76 e0                	jbe    f01024e4 <mem_init+0x13c6>
f0102504:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102509:	74 d9                	je     f01024e4 <mem_init+0x13c6>
			if (i >= PDX(KERNBASE)) {
f010250b:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102510:	77 38                	ja     f010254a <mem_init+0x142c>
				assert(pgdir[i] == 0);
f0102512:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102516:	74 d2                	je     f01024ea <mem_init+0x13cc>
f0102518:	68 38 49 10 f0       	push   $0xf0104938
f010251d:	68 5e 46 10 f0       	push   $0xf010465e
f0102522:	68 b0 02 00 00       	push   $0x2b0
f0102527:	68 38 46 10 f0       	push   $0xf0104638
f010252c:	e8 02 dc ff ff       	call   f0100133 <_panic>
			assert(pgdir[i] & PTE_P);
f0102531:	68 16 49 10 f0       	push   $0xf0104916
f0102536:	68 5e 46 10 f0       	push   $0xf010465e
f010253b:	68 a9 02 00 00       	push   $0x2a9
f0102540:	68 38 46 10 f0       	push   $0xf0104638
f0102545:	e8 e9 db ff ff       	call   f0100133 <_panic>
				assert(pgdir[i] & PTE_P);
f010254a:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f010254d:	f6 c2 01             	test   $0x1,%dl
f0102550:	74 1e                	je     f0102570 <mem_init+0x1452>
				assert(pgdir[i] & PTE_W);
f0102552:	f6 c2 02             	test   $0x2,%dl
f0102555:	75 93                	jne    f01024ea <mem_init+0x13cc>
f0102557:	68 27 49 10 f0       	push   $0xf0104927
f010255c:	68 5e 46 10 f0       	push   $0xf010465e
f0102561:	68 ae 02 00 00       	push   $0x2ae
f0102566:	68 38 46 10 f0       	push   $0xf0104638
f010256b:	e8 c3 db ff ff       	call   f0100133 <_panic>
				assert(pgdir[i] & PTE_P);
f0102570:	68 16 49 10 f0       	push   $0xf0104916
f0102575:	68 5e 46 10 f0       	push   $0xf010465e
f010257a:	68 ad 02 00 00       	push   $0x2ad
f010257f:	68 38 46 10 f0       	push   $0xf0104638
f0102584:	e8 aa db ff ff       	call   f0100133 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102589:	83 ec 0c             	sub    $0xc,%esp
f010258c:	68 78 45 10 f0       	push   $0xf0104578
f0102591:	e8 fa 03 00 00       	call   f0102990 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102596:	a1 68 89 11 f0       	mov    0xf0118968,%eax
	if ((uint32_t)kva < KERNBASE)
f010259b:	83 c4 10             	add    $0x10,%esp
f010259e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025a3:	0f 86 fe 01 00 00    	jbe    f01027a7 <mem_init+0x1689>
	return (physaddr_t)kva - KERNBASE;
f01025a9:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01025ae:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f01025b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01025b6:	e8 79 e4 ff ff       	call   f0100a34 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01025bb:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01025be:	83 e0 f3             	and    $0xfffffff3,%eax
f01025c1:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01025c6:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01025c9:	83 ec 0c             	sub    $0xc,%esp
f01025cc:	6a 00                	push   $0x0
f01025ce:	e8 e4 e7 ff ff       	call   f0100db7 <page_alloc>
f01025d3:	89 c3                	mov    %eax,%ebx
f01025d5:	83 c4 10             	add    $0x10,%esp
f01025d8:	85 c0                	test   %eax,%eax
f01025da:	0f 84 dc 01 00 00    	je     f01027bc <mem_init+0x169e>
	assert((pp1 = page_alloc(0)));
f01025e0:	83 ec 0c             	sub    $0xc,%esp
f01025e3:	6a 00                	push   $0x0
f01025e5:	e8 cd e7 ff ff       	call   f0100db7 <page_alloc>
f01025ea:	89 c7                	mov    %eax,%edi
f01025ec:	83 c4 10             	add    $0x10,%esp
f01025ef:	85 c0                	test   %eax,%eax
f01025f1:	0f 84 de 01 00 00    	je     f01027d5 <mem_init+0x16b7>
	assert((pp2 = page_alloc(0)));
f01025f7:	83 ec 0c             	sub    $0xc,%esp
f01025fa:	6a 00                	push   $0x0
f01025fc:	e8 b6 e7 ff ff       	call   f0100db7 <page_alloc>
f0102601:	89 c6                	mov    %eax,%esi
f0102603:	83 c4 10             	add    $0x10,%esp
f0102606:	85 c0                	test   %eax,%eax
f0102608:	0f 84 e0 01 00 00    	je     f01027ee <mem_init+0x16d0>
	page_free(pp0);
f010260e:	83 ec 0c             	sub    $0xc,%esp
f0102611:	53                   	push   %ebx
f0102612:	e8 12 e8 ff ff       	call   f0100e29 <page_free>
	return (pp - pages) << PGSHIFT;
f0102617:	89 f8                	mov    %edi,%eax
f0102619:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f010261f:	c1 f8 03             	sar    $0x3,%eax
f0102622:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102625:	89 c2                	mov    %eax,%edx
f0102627:	c1 ea 0c             	shr    $0xc,%edx
f010262a:	83 c4 10             	add    $0x10,%esp
f010262d:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f0102633:	0f 83 ce 01 00 00    	jae    f0102807 <mem_init+0x16e9>
	memset(page2kva(pp1), 1, PGSIZE);
f0102639:	83 ec 04             	sub    $0x4,%esp
f010263c:	68 00 10 00 00       	push   $0x1000
f0102641:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102643:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102648:	50                   	push   %eax
f0102649:	e8 71 0e 00 00       	call   f01034bf <memset>
	return (pp - pages) << PGSHIFT;
f010264e:	89 f0                	mov    %esi,%eax
f0102650:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0102656:	c1 f8 03             	sar    $0x3,%eax
f0102659:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010265c:	89 c2                	mov    %eax,%edx
f010265e:	c1 ea 0c             	shr    $0xc,%edx
f0102661:	83 c4 10             	add    $0x10,%esp
f0102664:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f010266a:	0f 83 a9 01 00 00    	jae    f0102819 <mem_init+0x16fb>
	memset(page2kva(pp2), 2, PGSIZE);
f0102670:	83 ec 04             	sub    $0x4,%esp
f0102673:	68 00 10 00 00       	push   $0x1000
f0102678:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f010267a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010267f:	50                   	push   %eax
f0102680:	e8 3a 0e 00 00       	call   f01034bf <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102685:	6a 02                	push   $0x2
f0102687:	68 00 10 00 00       	push   $0x1000
f010268c:	57                   	push   %edi
f010268d:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0102693:	e8 1f ea ff ff       	call   f01010b7 <page_insert>
	assert(pp1->pp_ref == 1);
f0102698:	83 c4 20             	add    $0x20,%esp
f010269b:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01026a0:	0f 85 85 01 00 00    	jne    f010282b <mem_init+0x170d>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01026a6:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01026ad:	01 01 01 
f01026b0:	0f 85 8e 01 00 00    	jne    f0102844 <mem_init+0x1726>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01026b6:	6a 02                	push   $0x2
f01026b8:	68 00 10 00 00       	push   $0x1000
f01026bd:	56                   	push   %esi
f01026be:	ff 35 68 89 11 f0    	pushl  0xf0118968
f01026c4:	e8 ee e9 ff ff       	call   f01010b7 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01026c9:	83 c4 10             	add    $0x10,%esp
f01026cc:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01026d3:	02 02 02 
f01026d6:	0f 85 81 01 00 00    	jne    f010285d <mem_init+0x173f>
	assert(pp2->pp_ref == 1);
f01026dc:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01026e1:	0f 85 8f 01 00 00    	jne    f0102876 <mem_init+0x1758>
	assert(pp1->pp_ref == 0);
f01026e7:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01026ec:	0f 85 9d 01 00 00    	jne    f010288f <mem_init+0x1771>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01026f2:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01026f9:	03 03 03 
	return (pp - pages) << PGSHIFT;
f01026fc:	89 f0                	mov    %esi,%eax
f01026fe:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0102704:	c1 f8 03             	sar    $0x3,%eax
f0102707:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010270a:	89 c2                	mov    %eax,%edx
f010270c:	c1 ea 0c             	shr    $0xc,%edx
f010270f:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f0102715:	0f 83 8d 01 00 00    	jae    f01028a8 <mem_init+0x178a>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010271b:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102722:	03 03 03 
f0102725:	0f 85 8f 01 00 00    	jne    f01028ba <mem_init+0x179c>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010272b:	83 ec 08             	sub    $0x8,%esp
f010272e:	68 00 10 00 00       	push   $0x1000
f0102733:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0102739:	e8 31 e9 ff ff       	call   f010106f <page_remove>
	assert(pp2->pp_ref == 0);
f010273e:	83 c4 10             	add    $0x10,%esp
f0102741:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102746:	0f 85 87 01 00 00    	jne    f01028d3 <mem_init+0x17b5>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010274c:	8b 0d 68 89 11 f0    	mov    0xf0118968,%ecx
f0102752:	8b 11                	mov    (%ecx),%edx
f0102754:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f010275a:	89 d8                	mov    %ebx,%eax
f010275c:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0102762:	c1 f8 03             	sar    $0x3,%eax
f0102765:	c1 e0 0c             	shl    $0xc,%eax
f0102768:	39 c2                	cmp    %eax,%edx
f010276a:	0f 85 7c 01 00 00    	jne    f01028ec <mem_init+0x17ce>
	kern_pgdir[0] = 0;
f0102770:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102776:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010277b:	0f 85 84 01 00 00    	jne    f0102905 <mem_init+0x17e7>
	pp0->pp_ref = 0;
f0102781:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102787:	83 ec 0c             	sub    $0xc,%esp
f010278a:	53                   	push   %ebx
f010278b:	e8 99 e6 ff ff       	call   f0100e29 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102790:	c7 04 24 0c 46 10 f0 	movl   $0xf010460c,(%esp)
f0102797:	e8 f4 01 00 00       	call   f0102990 <cprintf>
}
f010279c:	83 c4 10             	add    $0x10,%esp
f010279f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01027a2:	5b                   	pop    %ebx
f01027a3:	5e                   	pop    %esi
f01027a4:	5f                   	pop    %edi
f01027a5:	5d                   	pop    %ebp
f01027a6:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027a7:	50                   	push   %eax
f01027a8:	68 cc 3f 10 f0       	push   $0xf0103fcc
f01027ad:	68 d8 00 00 00       	push   $0xd8
f01027b2:	68 38 46 10 f0       	push   $0xf0104638
f01027b7:	e8 77 d9 ff ff       	call   f0100133 <_panic>
	assert((pp0 = page_alloc(0)));
f01027bc:	68 34 47 10 f0       	push   $0xf0104734
f01027c1:	68 5e 46 10 f0       	push   $0xf010465e
f01027c6:	68 72 03 00 00       	push   $0x372
f01027cb:	68 38 46 10 f0       	push   $0xf0104638
f01027d0:	e8 5e d9 ff ff       	call   f0100133 <_panic>
	assert((pp1 = page_alloc(0)));
f01027d5:	68 4a 47 10 f0       	push   $0xf010474a
f01027da:	68 5e 46 10 f0       	push   $0xf010465e
f01027df:	68 73 03 00 00       	push   $0x373
f01027e4:	68 38 46 10 f0       	push   $0xf0104638
f01027e9:	e8 45 d9 ff ff       	call   f0100133 <_panic>
	assert((pp2 = page_alloc(0)));
f01027ee:	68 60 47 10 f0       	push   $0xf0104760
f01027f3:	68 5e 46 10 f0       	push   $0xf010465e
f01027f8:	68 74 03 00 00       	push   $0x374
f01027fd:	68 38 46 10 f0       	push   $0xf0104638
f0102802:	e8 2c d9 ff ff       	call   f0100133 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102807:	50                   	push   %eax
f0102808:	68 c0 3e 10 f0       	push   $0xf0103ec0
f010280d:	6a 52                	push   $0x52
f010280f:	68 44 46 10 f0       	push   $0xf0104644
f0102814:	e8 1a d9 ff ff       	call   f0100133 <_panic>
f0102819:	50                   	push   %eax
f010281a:	68 c0 3e 10 f0       	push   $0xf0103ec0
f010281f:	6a 52                	push   $0x52
f0102821:	68 44 46 10 f0       	push   $0xf0104644
f0102826:	e8 08 d9 ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 1);
f010282b:	68 31 48 10 f0       	push   $0xf0104831
f0102830:	68 5e 46 10 f0       	push   $0xf010465e
f0102835:	68 79 03 00 00       	push   $0x379
f010283a:	68 38 46 10 f0       	push   $0xf0104638
f010283f:	e8 ef d8 ff ff       	call   f0100133 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102844:	68 98 45 10 f0       	push   $0xf0104598
f0102849:	68 5e 46 10 f0       	push   $0xf010465e
f010284e:	68 7a 03 00 00       	push   $0x37a
f0102853:	68 38 46 10 f0       	push   $0xf0104638
f0102858:	e8 d6 d8 ff ff       	call   f0100133 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010285d:	68 bc 45 10 f0       	push   $0xf01045bc
f0102862:	68 5e 46 10 f0       	push   $0xf010465e
f0102867:	68 7c 03 00 00       	push   $0x37c
f010286c:	68 38 46 10 f0       	push   $0xf0104638
f0102871:	e8 bd d8 ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 1);
f0102876:	68 53 48 10 f0       	push   $0xf0104853
f010287b:	68 5e 46 10 f0       	push   $0xf010465e
f0102880:	68 7d 03 00 00       	push   $0x37d
f0102885:	68 38 46 10 f0       	push   $0xf0104638
f010288a:	e8 a4 d8 ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 0);
f010288f:	68 bd 48 10 f0       	push   $0xf01048bd
f0102894:	68 5e 46 10 f0       	push   $0xf010465e
f0102899:	68 7e 03 00 00       	push   $0x37e
f010289e:	68 38 46 10 f0       	push   $0xf0104638
f01028a3:	e8 8b d8 ff ff       	call   f0100133 <_panic>
f01028a8:	50                   	push   %eax
f01028a9:	68 c0 3e 10 f0       	push   $0xf0103ec0
f01028ae:	6a 52                	push   $0x52
f01028b0:	68 44 46 10 f0       	push   $0xf0104644
f01028b5:	e8 79 d8 ff ff       	call   f0100133 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01028ba:	68 e0 45 10 f0       	push   $0xf01045e0
f01028bf:	68 5e 46 10 f0       	push   $0xf010465e
f01028c4:	68 80 03 00 00       	push   $0x380
f01028c9:	68 38 46 10 f0       	push   $0xf0104638
f01028ce:	e8 60 d8 ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 0);
f01028d3:	68 8b 48 10 f0       	push   $0xf010488b
f01028d8:	68 5e 46 10 f0       	push   $0xf010465e
f01028dd:	68 82 03 00 00       	push   $0x382
f01028e2:	68 38 46 10 f0       	push   $0xf0104638
f01028e7:	e8 47 d8 ff ff       	call   f0100133 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01028ec:	68 24 41 10 f0       	push   $0xf0104124
f01028f1:	68 5e 46 10 f0       	push   $0xf010465e
f01028f6:	68 85 03 00 00       	push   $0x385
f01028fb:	68 38 46 10 f0       	push   $0xf0104638
f0102900:	e8 2e d8 ff ff       	call   f0100133 <_panic>
	assert(pp0->pp_ref == 1);
f0102905:	68 42 48 10 f0       	push   $0xf0104842
f010290a:	68 5e 46 10 f0       	push   $0xf010465e
f010290f:	68 87 03 00 00       	push   $0x387
f0102914:	68 38 46 10 f0       	push   $0xf0104638
f0102919:	e8 15 d8 ff ff       	call   f0100133 <_panic>

f010291e <tlb_invalidate>:
{
f010291e:	55                   	push   %ebp
f010291f:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102921:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102924:	0f 01 38             	invlpg (%eax)
}
f0102927:	5d                   	pop    %ebp
f0102928:	c3                   	ret    

f0102929 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102929:	55                   	push   %ebp
f010292a:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010292c:	8b 45 08             	mov    0x8(%ebp),%eax
f010292f:	ba 70 00 00 00       	mov    $0x70,%edx
f0102934:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102935:	ba 71 00 00 00       	mov    $0x71,%edx
f010293a:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010293b:	0f b6 c0             	movzbl %al,%eax
}
f010293e:	5d                   	pop    %ebp
f010293f:	c3                   	ret    

f0102940 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102940:	55                   	push   %ebp
f0102941:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102943:	8b 45 08             	mov    0x8(%ebp),%eax
f0102946:	ba 70 00 00 00       	mov    $0x70,%edx
f010294b:	ee                   	out    %al,(%dx)
f010294c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010294f:	ba 71 00 00 00       	mov    $0x71,%edx
f0102954:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102955:	5d                   	pop    %ebp
f0102956:	c3                   	ret    

f0102957 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102957:	55                   	push   %ebp
f0102958:	89 e5                	mov    %esp,%ebp
f010295a:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010295d:	ff 75 08             	pushl  0x8(%ebp)
f0102960:	e8 21 dd ff ff       	call   f0100686 <cputchar>
	*cnt++;
}
f0102965:	83 c4 10             	add    $0x10,%esp
f0102968:	c9                   	leave  
f0102969:	c3                   	ret    

f010296a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010296a:	55                   	push   %ebp
f010296b:	89 e5                	mov    %esp,%ebp
f010296d:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102970:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102977:	ff 75 0c             	pushl  0xc(%ebp)
f010297a:	ff 75 08             	pushl  0x8(%ebp)
f010297d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102980:	50                   	push   %eax
f0102981:	68 57 29 10 f0       	push   $0xf0102957
f0102986:	e8 1b 04 00 00       	call   f0102da6 <vprintfmt>
	return cnt;
}
f010298b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010298e:	c9                   	leave  
f010298f:	c3                   	ret    

f0102990 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102990:	55                   	push   %ebp
f0102991:	89 e5                	mov    %esp,%ebp
f0102993:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102996:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102999:	50                   	push   %eax
f010299a:	ff 75 08             	pushl  0x8(%ebp)
f010299d:	e8 c8 ff ff ff       	call   f010296a <vcprintf>
	va_end(ap);

	return cnt;
}
f01029a2:	c9                   	leave  
f01029a3:	c3                   	ret    

f01029a4 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01029a4:	55                   	push   %ebp
f01029a5:	89 e5                	mov    %esp,%ebp
f01029a7:	57                   	push   %edi
f01029a8:	56                   	push   %esi
f01029a9:	53                   	push   %ebx
f01029aa:	83 ec 14             	sub    $0x14,%esp
f01029ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01029b0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01029b3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01029b6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01029b9:	8b 32                	mov    (%edx),%esi
f01029bb:	8b 01                	mov    (%ecx),%eax
f01029bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01029c0:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01029c7:	eb 2f                	jmp    f01029f8 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f01029c9:	48                   	dec    %eax
		while (m >= l && stabs[m].n_type != type)
f01029ca:	39 c6                	cmp    %eax,%esi
f01029cc:	7f 4d                	jg     f0102a1b <stab_binsearch+0x77>
f01029ce:	0f b6 0a             	movzbl (%edx),%ecx
f01029d1:	83 ea 0c             	sub    $0xc,%edx
f01029d4:	39 f9                	cmp    %edi,%ecx
f01029d6:	75 f1                	jne    f01029c9 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01029d8:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01029db:	01 c2                	add    %eax,%edx
f01029dd:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01029e0:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01029e4:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01029e7:	73 37                	jae    f0102a20 <stab_binsearch+0x7c>
			*region_left = m;
f01029e9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01029ec:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f01029ee:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f01029f1:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f01029f8:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f01029fb:	7f 4d                	jg     f0102a4a <stab_binsearch+0xa6>
		int true_m = (l + r) / 2, m = true_m;
f01029fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102a00:	01 f0                	add    %esi,%eax
f0102a02:	89 c3                	mov    %eax,%ebx
f0102a04:	c1 eb 1f             	shr    $0x1f,%ebx
f0102a07:	01 c3                	add    %eax,%ebx
f0102a09:	d1 fb                	sar    %ebx
f0102a0b:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0102a0e:	01 d8                	add    %ebx,%eax
f0102a10:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102a13:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0102a17:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0102a19:	eb af                	jmp    f01029ca <stab_binsearch+0x26>
			l = true_m + 1;
f0102a1b:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0102a1e:	eb d8                	jmp    f01029f8 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0102a20:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102a23:	76 12                	jbe    f0102a37 <stab_binsearch+0x93>
			*region_right = m - 1;
f0102a25:	48                   	dec    %eax
f0102a26:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102a29:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102a2c:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0102a2e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102a35:	eb c1                	jmp    f01029f8 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102a37:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102a3a:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0102a3c:	ff 45 0c             	incl   0xc(%ebp)
f0102a3f:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0102a41:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102a48:	eb ae                	jmp    f01029f8 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0102a4a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102a4e:	74 18                	je     f0102a68 <stab_binsearch+0xc4>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102a50:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102a53:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102a55:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102a58:	8b 0e                	mov    (%esi),%ecx
f0102a5a:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0102a5d:	01 c2                	add    %eax,%edx
f0102a5f:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0102a62:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0102a66:	eb 0e                	jmp    f0102a76 <stab_binsearch+0xd2>
		*region_right = *region_left - 1;
f0102a68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102a6b:	8b 00                	mov    (%eax),%eax
f0102a6d:	48                   	dec    %eax
f0102a6e:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0102a71:	89 07                	mov    %eax,(%edi)
f0102a73:	eb 14                	jmp    f0102a89 <stab_binsearch+0xe5>
		     l--)
f0102a75:	48                   	dec    %eax
		for (l = *region_right;
f0102a76:	39 c1                	cmp    %eax,%ecx
f0102a78:	7d 0a                	jge    f0102a84 <stab_binsearch+0xe0>
		     l > *region_left && stabs[l].n_type != type;
f0102a7a:	0f b6 1a             	movzbl (%edx),%ebx
f0102a7d:	83 ea 0c             	sub    $0xc,%edx
f0102a80:	39 fb                	cmp    %edi,%ebx
f0102a82:	75 f1                	jne    f0102a75 <stab_binsearch+0xd1>
			/* do nothing */;
		*region_left = l;
f0102a84:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102a87:	89 07                	mov    %eax,(%edi)
	}
}
f0102a89:	83 c4 14             	add    $0x14,%esp
f0102a8c:	5b                   	pop    %ebx
f0102a8d:	5e                   	pop    %esi
f0102a8e:	5f                   	pop    %edi
f0102a8f:	5d                   	pop    %ebp
f0102a90:	c3                   	ret    

f0102a91 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102a91:	55                   	push   %ebp
f0102a92:	89 e5                	mov    %esp,%ebp
f0102a94:	57                   	push   %edi
f0102a95:	56                   	push   %esi
f0102a96:	53                   	push   %ebx
f0102a97:	83 ec 3c             	sub    $0x3c,%esp
f0102a9a:	8b 75 08             	mov    0x8(%ebp),%esi
f0102a9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102aa0:	c7 03 46 49 10 f0    	movl   $0xf0104946,(%ebx)
	info->eip_line = 0;
f0102aa6:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102aad:	c7 43 08 46 49 10 f0 	movl   $0xf0104946,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102ab4:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102abb:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102abe:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102ac5:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102acb:	0f 86 31 01 00 00    	jbe    f0102c02 <debuginfo_eip+0x171>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102ad1:	b8 29 d2 10 f0       	mov    $0xf010d229,%eax
f0102ad6:	3d c9 b3 10 f0       	cmp    $0xf010b3c9,%eax
f0102adb:	0f 86 b6 01 00 00    	jbe    f0102c97 <debuginfo_eip+0x206>
f0102ae1:	80 3d 28 d2 10 f0 00 	cmpb   $0x0,0xf010d228
f0102ae8:	0f 85 b0 01 00 00    	jne    f0102c9e <debuginfo_eip+0x20d>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102aee:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102af5:	ba c8 b3 10 f0       	mov    $0xf010b3c8,%edx
f0102afa:	81 ea 7c 4b 10 f0    	sub    $0xf0104b7c,%edx
f0102b00:	c1 fa 02             	sar    $0x2,%edx
f0102b03:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0102b06:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0102b09:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0102b0c:	89 c1                	mov    %eax,%ecx
f0102b0e:	c1 e1 08             	shl    $0x8,%ecx
f0102b11:	01 c8                	add    %ecx,%eax
f0102b13:	89 c1                	mov    %eax,%ecx
f0102b15:	c1 e1 10             	shl    $0x10,%ecx
f0102b18:	01 c8                	add    %ecx,%eax
f0102b1a:	01 c0                	add    %eax,%eax
f0102b1c:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
f0102b20:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102b23:	83 ec 08             	sub    $0x8,%esp
f0102b26:	56                   	push   %esi
f0102b27:	6a 64                	push   $0x64
f0102b29:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102b2c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102b2f:	b8 7c 4b 10 f0       	mov    $0xf0104b7c,%eax
f0102b34:	e8 6b fe ff ff       	call   f01029a4 <stab_binsearch>
	if (lfile == 0)
f0102b39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102b3c:	83 c4 10             	add    $0x10,%esp
f0102b3f:	85 c0                	test   %eax,%eax
f0102b41:	0f 84 5e 01 00 00    	je     f0102ca5 <debuginfo_eip+0x214>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102b47:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0102b4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102b4d:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102b50:	83 ec 08             	sub    $0x8,%esp
f0102b53:	56                   	push   %esi
f0102b54:	6a 24                	push   $0x24
f0102b56:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102b59:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102b5c:	b8 7c 4b 10 f0       	mov    $0xf0104b7c,%eax
f0102b61:	e8 3e fe ff ff       	call   f01029a4 <stab_binsearch>

	if (lfun <= rfun) {
f0102b66:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102b69:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102b6c:	83 c4 10             	add    $0x10,%esp
f0102b6f:	39 d0                	cmp    %edx,%eax
f0102b71:	0f 8f 9f 00 00 00    	jg     f0102c16 <debuginfo_eip+0x185>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102b77:	8d 0c 00             	lea    (%eax,%eax,1),%ecx
f0102b7a:	01 c1                	add    %eax,%ecx
f0102b7c:	c1 e1 02             	shl    $0x2,%ecx
f0102b7f:	8d b9 7c 4b 10 f0    	lea    -0xfefb484(%ecx),%edi
f0102b85:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0102b88:	8b 89 7c 4b 10 f0    	mov    -0xfefb484(%ecx),%ecx
f0102b8e:	bf 29 d2 10 f0       	mov    $0xf010d229,%edi
f0102b93:	81 ef c9 b3 10 f0    	sub    $0xf010b3c9,%edi
f0102b99:	39 f9                	cmp    %edi,%ecx
f0102b9b:	73 09                	jae    f0102ba6 <debuginfo_eip+0x115>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102b9d:	81 c1 c9 b3 10 f0    	add    $0xf010b3c9,%ecx
f0102ba3:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102ba6:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0102ba9:	8b 4f 08             	mov    0x8(%edi),%ecx
f0102bac:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102baf:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0102bb1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0102bb4:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102bb7:	83 ec 08             	sub    $0x8,%esp
f0102bba:	6a 3a                	push   $0x3a
f0102bbc:	ff 73 08             	pushl  0x8(%ebx)
f0102bbf:	e8 e3 08 00 00       	call   f01034a7 <strfind>
f0102bc4:	2b 43 08             	sub    0x8(%ebx),%eax
f0102bc7:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// N_SLINE represents text segment
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0102bca:	83 c4 08             	add    $0x8,%esp
f0102bcd:	56                   	push   %esi
f0102bce:	6a 44                	push   $0x44
f0102bd0:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0102bd3:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0102bd6:	b8 7c 4b 10 f0       	mov    $0xf0104b7c,%eax
f0102bdb:	e8 c4 fd ff ff       	call   f01029a4 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0102be0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102be3:	8d 04 12             	lea    (%edx,%edx,1),%eax
f0102be6:	01 d0                	add    %edx,%eax
f0102be8:	c1 e0 02             	shl    $0x2,%eax
f0102beb:	0f b7 88 82 4b 10 f0 	movzwl -0xfefb47e(%eax),%ecx
f0102bf2:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102bf5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102bf8:	05 80 4b 10 f0       	add    $0xf0104b80,%eax
f0102bfd:	83 c4 10             	add    $0x10,%esp
f0102c00:	eb 29                	jmp    f0102c2b <debuginfo_eip+0x19a>
  	        panic("User address");
f0102c02:	83 ec 04             	sub    $0x4,%esp
f0102c05:	68 50 49 10 f0       	push   $0xf0104950
f0102c0a:	6a 7f                	push   $0x7f
f0102c0c:	68 5d 49 10 f0       	push   $0xf010495d
f0102c11:	e8 1d d5 ff ff       	call   f0100133 <_panic>
		info->eip_fn_addr = addr;
f0102c16:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102c19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102c1c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0102c1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102c22:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102c25:	eb 90                	jmp    f0102bb7 <debuginfo_eip+0x126>
f0102c27:	4a                   	dec    %edx
f0102c28:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0102c2b:	39 d6                	cmp    %edx,%esi
f0102c2d:	7f 34                	jg     f0102c63 <debuginfo_eip+0x1d2>
	       && stabs[lline].n_type != N_SOL
f0102c2f:	8a 08                	mov    (%eax),%cl
f0102c31:	80 f9 84             	cmp    $0x84,%cl
f0102c34:	74 0b                	je     f0102c41 <debuginfo_eip+0x1b0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102c36:	80 f9 64             	cmp    $0x64,%cl
f0102c39:	75 ec                	jne    f0102c27 <debuginfo_eip+0x196>
f0102c3b:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0102c3f:	74 e6                	je     f0102c27 <debuginfo_eip+0x196>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102c41:	8d 04 12             	lea    (%edx,%edx,1),%eax
f0102c44:	01 c2                	add    %eax,%edx
f0102c46:	8b 14 95 7c 4b 10 f0 	mov    -0xfefb484(,%edx,4),%edx
f0102c4d:	b8 29 d2 10 f0       	mov    $0xf010d229,%eax
f0102c52:	2d c9 b3 10 f0       	sub    $0xf010b3c9,%eax
f0102c57:	39 c2                	cmp    %eax,%edx
f0102c59:	73 08                	jae    f0102c63 <debuginfo_eip+0x1d2>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102c5b:	81 c2 c9 b3 10 f0    	add    $0xf010b3c9,%edx
f0102c61:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102c63:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102c66:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0102c69:	39 f2                	cmp    %esi,%edx
f0102c6b:	7d 3f                	jge    f0102cac <debuginfo_eip+0x21b>
		for (lline = lfun + 1;
f0102c6d:	42                   	inc    %edx
f0102c6e:	89 d0                	mov    %edx,%eax
f0102c70:	8d 0c 12             	lea    (%edx,%edx,1),%ecx
f0102c73:	01 ca                	add    %ecx,%edx
f0102c75:	8d 14 95 80 4b 10 f0 	lea    -0xfefb480(,%edx,4),%edx
f0102c7c:	eb 03                	jmp    f0102c81 <debuginfo_eip+0x1f0>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0102c7e:	ff 43 14             	incl   0x14(%ebx)
		for (lline = lfun + 1;
f0102c81:	39 c6                	cmp    %eax,%esi
f0102c83:	7e 34                	jle    f0102cb9 <debuginfo_eip+0x228>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102c85:	8a 0a                	mov    (%edx),%cl
f0102c87:	40                   	inc    %eax
f0102c88:	83 c2 0c             	add    $0xc,%edx
f0102c8b:	80 f9 a0             	cmp    $0xa0,%cl
f0102c8e:	74 ee                	je     f0102c7e <debuginfo_eip+0x1ed>

	return 0;
f0102c90:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c95:	eb 1a                	jmp    f0102cb1 <debuginfo_eip+0x220>
		return -1;
f0102c97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102c9c:	eb 13                	jmp    f0102cb1 <debuginfo_eip+0x220>
f0102c9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102ca3:	eb 0c                	jmp    f0102cb1 <debuginfo_eip+0x220>
		return -1;
f0102ca5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102caa:	eb 05                	jmp    f0102cb1 <debuginfo_eip+0x220>
	return 0;
f0102cac:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102cb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102cb4:	5b                   	pop    %ebx
f0102cb5:	5e                   	pop    %esi
f0102cb6:	5f                   	pop    %edi
f0102cb7:	5d                   	pop    %ebp
f0102cb8:	c3                   	ret    
	return 0;
f0102cb9:	b8 00 00 00 00       	mov    $0x0,%eax
f0102cbe:	eb f1                	jmp    f0102cb1 <debuginfo_eip+0x220>

f0102cc0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102cc0:	55                   	push   %ebp
f0102cc1:	89 e5                	mov    %esp,%ebp
f0102cc3:	57                   	push   %edi
f0102cc4:	56                   	push   %esi
f0102cc5:	53                   	push   %ebx
f0102cc6:	83 ec 1c             	sub    $0x1c,%esp
f0102cc9:	89 c7                	mov    %eax,%edi
f0102ccb:	89 d6                	mov    %edx,%esi
f0102ccd:	8b 45 08             	mov    0x8(%ebp),%eax
f0102cd0:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102cd3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102cd6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102cd9:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0102cdc:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102ce1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102ce4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0102ce7:	39 d3                	cmp    %edx,%ebx
f0102ce9:	72 05                	jb     f0102cf0 <printnum+0x30>
f0102ceb:	39 45 10             	cmp    %eax,0x10(%ebp)
f0102cee:	77 78                	ja     f0102d68 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102cf0:	83 ec 0c             	sub    $0xc,%esp
f0102cf3:	ff 75 18             	pushl  0x18(%ebp)
f0102cf6:	8b 45 14             	mov    0x14(%ebp),%eax
f0102cf9:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0102cfc:	53                   	push   %ebx
f0102cfd:	ff 75 10             	pushl  0x10(%ebp)
f0102d00:	83 ec 08             	sub    $0x8,%esp
f0102d03:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102d06:	ff 75 e0             	pushl  -0x20(%ebp)
f0102d09:	ff 75 dc             	pushl  -0x24(%ebp)
f0102d0c:	ff 75 d8             	pushl  -0x28(%ebp)
f0102d0f:	e8 8c 09 00 00       	call   f01036a0 <__udivdi3>
f0102d14:	83 c4 18             	add    $0x18,%esp
f0102d17:	52                   	push   %edx
f0102d18:	50                   	push   %eax
f0102d19:	89 f2                	mov    %esi,%edx
f0102d1b:	89 f8                	mov    %edi,%eax
f0102d1d:	e8 9e ff ff ff       	call   f0102cc0 <printnum>
f0102d22:	83 c4 20             	add    $0x20,%esp
f0102d25:	eb 11                	jmp    f0102d38 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102d27:	83 ec 08             	sub    $0x8,%esp
f0102d2a:	56                   	push   %esi
f0102d2b:	ff 75 18             	pushl  0x18(%ebp)
f0102d2e:	ff d7                	call   *%edi
f0102d30:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0102d33:	4b                   	dec    %ebx
f0102d34:	85 db                	test   %ebx,%ebx
f0102d36:	7f ef                	jg     f0102d27 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102d38:	83 ec 08             	sub    $0x8,%esp
f0102d3b:	56                   	push   %esi
f0102d3c:	83 ec 04             	sub    $0x4,%esp
f0102d3f:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102d42:	ff 75 e0             	pushl  -0x20(%ebp)
f0102d45:	ff 75 dc             	pushl  -0x24(%ebp)
f0102d48:	ff 75 d8             	pushl  -0x28(%ebp)
f0102d4b:	e8 50 0a 00 00       	call   f01037a0 <__umoddi3>
f0102d50:	83 c4 14             	add    $0x14,%esp
f0102d53:	0f be 80 6b 49 10 f0 	movsbl -0xfefb695(%eax),%eax
f0102d5a:	50                   	push   %eax
f0102d5b:	ff d7                	call   *%edi
}
f0102d5d:	83 c4 10             	add    $0x10,%esp
f0102d60:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d63:	5b                   	pop    %ebx
f0102d64:	5e                   	pop    %esi
f0102d65:	5f                   	pop    %edi
f0102d66:	5d                   	pop    %ebp
f0102d67:	c3                   	ret    
f0102d68:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0102d6b:	eb c6                	jmp    f0102d33 <printnum+0x73>

f0102d6d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102d6d:	55                   	push   %ebp
f0102d6e:	89 e5                	mov    %esp,%ebp
f0102d70:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102d73:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0102d76:	8b 10                	mov    (%eax),%edx
f0102d78:	3b 50 04             	cmp    0x4(%eax),%edx
f0102d7b:	73 0a                	jae    f0102d87 <sprintputch+0x1a>
		*b->buf++ = ch;
f0102d7d:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102d80:	89 08                	mov    %ecx,(%eax)
f0102d82:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d85:	88 02                	mov    %al,(%edx)
}
f0102d87:	5d                   	pop    %ebp
f0102d88:	c3                   	ret    

f0102d89 <printfmt>:
{
f0102d89:	55                   	push   %ebp
f0102d8a:	89 e5                	mov    %esp,%ebp
f0102d8c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0102d8f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102d92:	50                   	push   %eax
f0102d93:	ff 75 10             	pushl  0x10(%ebp)
f0102d96:	ff 75 0c             	pushl  0xc(%ebp)
f0102d99:	ff 75 08             	pushl  0x8(%ebp)
f0102d9c:	e8 05 00 00 00       	call   f0102da6 <vprintfmt>
}
f0102da1:	83 c4 10             	add    $0x10,%esp
f0102da4:	c9                   	leave  
f0102da5:	c3                   	ret    

f0102da6 <vprintfmt>:
{
f0102da6:	55                   	push   %ebp
f0102da7:	89 e5                	mov    %esp,%ebp
f0102da9:	57                   	push   %edi
f0102daa:	56                   	push   %esi
f0102dab:	53                   	push   %ebx
f0102dac:	83 ec 2c             	sub    $0x2c,%esp
f0102daf:	8b 75 08             	mov    0x8(%ebp),%esi
f0102db2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102db5:	8b 7d 10             	mov    0x10(%ebp),%edi
f0102db8:	e9 ac 03 00 00       	jmp    f0103169 <vprintfmt+0x3c3>
		padc = ' ';
f0102dbd:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0102dc1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0102dc8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f0102dcf:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0102dd6:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0102ddb:	8d 47 01             	lea    0x1(%edi),%eax
f0102dde:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102de1:	8a 17                	mov    (%edi),%dl
f0102de3:	8d 42 dd             	lea    -0x23(%edx),%eax
f0102de6:	3c 55                	cmp    $0x55,%al
f0102de8:	0f 87 fc 03 00 00    	ja     f01031ea <vprintfmt+0x444>
f0102dee:	0f b6 c0             	movzbl %al,%eax
f0102df1:	ff 24 85 f8 49 10 f0 	jmp    *-0xfefb608(,%eax,4)
f0102df8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0102dfb:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0102dff:	eb da                	jmp    f0102ddb <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0102e01:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0102e04:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0102e08:	eb d1                	jmp    f0102ddb <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0102e0a:	0f b6 d2             	movzbl %dl,%edx
f0102e0d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0102e10:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e15:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0102e18:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102e1b:	01 c0                	add    %eax,%eax
f0102e1d:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
f0102e21:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0102e24:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0102e27:	83 f9 09             	cmp    $0x9,%ecx
f0102e2a:	77 52                	ja     f0102e7e <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
f0102e2c:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
f0102e2d:	eb e9                	jmp    f0102e18 <vprintfmt+0x72>
			precision = va_arg(ap, int);
f0102e2f:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e32:	8b 00                	mov    (%eax),%eax
f0102e34:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102e37:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e3a:	8d 40 04             	lea    0x4(%eax),%eax
f0102e3d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0102e40:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0102e43:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102e47:	79 92                	jns    f0102ddb <vprintfmt+0x35>
				width = precision, precision = -1;
f0102e49:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102e4c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102e4f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102e56:	eb 83                	jmp    f0102ddb <vprintfmt+0x35>
f0102e58:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102e5c:	78 08                	js     f0102e66 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
f0102e5e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102e61:	e9 75 ff ff ff       	jmp    f0102ddb <vprintfmt+0x35>
f0102e66:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102e6d:	eb ef                	jmp    f0102e5e <vprintfmt+0xb8>
f0102e6f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0102e72:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0102e79:	e9 5d ff ff ff       	jmp    f0102ddb <vprintfmt+0x35>
f0102e7e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102e81:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102e84:	eb bd                	jmp    f0102e43 <vprintfmt+0x9d>
			lflag++;
f0102e86:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
f0102e87:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0102e8a:	e9 4c ff ff ff       	jmp    f0102ddb <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f0102e8f:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e92:	8d 78 04             	lea    0x4(%eax),%edi
f0102e95:	83 ec 08             	sub    $0x8,%esp
f0102e98:	53                   	push   %ebx
f0102e99:	ff 30                	pushl  (%eax)
f0102e9b:	ff d6                	call   *%esi
			break;
f0102e9d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0102ea0:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0102ea3:	e9 be 02 00 00       	jmp    f0103166 <vprintfmt+0x3c0>
			err = va_arg(ap, int);
f0102ea8:	8b 45 14             	mov    0x14(%ebp),%eax
f0102eab:	8d 78 04             	lea    0x4(%eax),%edi
f0102eae:	8b 00                	mov    (%eax),%eax
f0102eb0:	85 c0                	test   %eax,%eax
f0102eb2:	78 2a                	js     f0102ede <vprintfmt+0x138>
f0102eb4:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102eb6:	83 f8 06             	cmp    $0x6,%eax
f0102eb9:	7f 27                	jg     f0102ee2 <vprintfmt+0x13c>
f0102ebb:	8b 04 85 50 4b 10 f0 	mov    -0xfefb4b0(,%eax,4),%eax
f0102ec2:	85 c0                	test   %eax,%eax
f0102ec4:	74 1c                	je     f0102ee2 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
f0102ec6:	50                   	push   %eax
f0102ec7:	68 70 46 10 f0       	push   $0xf0104670
f0102ecc:	53                   	push   %ebx
f0102ecd:	56                   	push   %esi
f0102ece:	e8 b6 fe ff ff       	call   f0102d89 <printfmt>
f0102ed3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0102ed6:	89 7d 14             	mov    %edi,0x14(%ebp)
f0102ed9:	e9 88 02 00 00       	jmp    f0103166 <vprintfmt+0x3c0>
f0102ede:	f7 d8                	neg    %eax
f0102ee0:	eb d2                	jmp    f0102eb4 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
f0102ee2:	52                   	push   %edx
f0102ee3:	68 83 49 10 f0       	push   $0xf0104983
f0102ee8:	53                   	push   %ebx
f0102ee9:	56                   	push   %esi
f0102eea:	e8 9a fe ff ff       	call   f0102d89 <printfmt>
f0102eef:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0102ef2:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0102ef5:	e9 6c 02 00 00       	jmp    f0103166 <vprintfmt+0x3c0>
			if ((p = va_arg(ap, char *)) == NULL)
f0102efa:	8b 45 14             	mov    0x14(%ebp),%eax
f0102efd:	83 c0 04             	add    $0x4,%eax
f0102f00:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102f03:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f06:	8b 38                	mov    (%eax),%edi
f0102f08:	85 ff                	test   %edi,%edi
f0102f0a:	74 18                	je     f0102f24 <vprintfmt+0x17e>
			if (width > 0 && padc != '-')
f0102f0c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102f10:	0f 8e b7 00 00 00    	jle    f0102fcd <vprintfmt+0x227>
f0102f16:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0102f1a:	75 0f                	jne    f0102f2b <vprintfmt+0x185>
f0102f1c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102f1f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102f22:	eb 6e                	jmp    f0102f92 <vprintfmt+0x1ec>
				p = "(null)";
f0102f24:	bf 7c 49 10 f0       	mov    $0xf010497c,%edi
f0102f29:	eb e1                	jmp    f0102f0c <vprintfmt+0x166>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102f2b:	83 ec 08             	sub    $0x8,%esp
f0102f2e:	ff 75 d0             	pushl  -0x30(%ebp)
f0102f31:	57                   	push   %edi
f0102f32:	e8 45 04 00 00       	call   f010337c <strnlen>
f0102f37:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102f3a:	29 c1                	sub    %eax,%ecx
f0102f3c:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0102f3f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0102f42:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0102f46:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102f49:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102f4c:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0102f4e:	eb 0d                	jmp    f0102f5d <vprintfmt+0x1b7>
					putch(padc, putdat);
f0102f50:	83 ec 08             	sub    $0x8,%esp
f0102f53:	53                   	push   %ebx
f0102f54:	ff 75 e0             	pushl  -0x20(%ebp)
f0102f57:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0102f59:	4f                   	dec    %edi
f0102f5a:	83 c4 10             	add    $0x10,%esp
f0102f5d:	85 ff                	test   %edi,%edi
f0102f5f:	7f ef                	jg     f0102f50 <vprintfmt+0x1aa>
f0102f61:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102f64:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102f67:	89 c8                	mov    %ecx,%eax
f0102f69:	85 c9                	test   %ecx,%ecx
f0102f6b:	78 59                	js     f0102fc6 <vprintfmt+0x220>
f0102f6d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102f70:	29 c1                	sub    %eax,%ecx
f0102f72:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102f75:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102f78:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102f7b:	eb 15                	jmp    f0102f92 <vprintfmt+0x1ec>
				if (altflag && (ch < ' ' || ch > '~'))
f0102f7d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0102f81:	75 29                	jne    f0102fac <vprintfmt+0x206>
					putch(ch, putdat);
f0102f83:	83 ec 08             	sub    $0x8,%esp
f0102f86:	ff 75 0c             	pushl  0xc(%ebp)
f0102f89:	50                   	push   %eax
f0102f8a:	ff d6                	call   *%esi
f0102f8c:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102f8f:	ff 4d e0             	decl   -0x20(%ebp)
f0102f92:	47                   	inc    %edi
f0102f93:	8a 57 ff             	mov    -0x1(%edi),%dl
f0102f96:	0f be c2             	movsbl %dl,%eax
f0102f99:	85 c0                	test   %eax,%eax
f0102f9b:	74 53                	je     f0102ff0 <vprintfmt+0x24a>
f0102f9d:	85 db                	test   %ebx,%ebx
f0102f9f:	78 dc                	js     f0102f7d <vprintfmt+0x1d7>
f0102fa1:	4b                   	dec    %ebx
f0102fa2:	79 d9                	jns    f0102f7d <vprintfmt+0x1d7>
f0102fa4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102fa7:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0102faa:	eb 35                	jmp    f0102fe1 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
f0102fac:	0f be d2             	movsbl %dl,%edx
f0102faf:	83 ea 20             	sub    $0x20,%edx
f0102fb2:	83 fa 5e             	cmp    $0x5e,%edx
f0102fb5:	76 cc                	jbe    f0102f83 <vprintfmt+0x1dd>
					putch('?', putdat);
f0102fb7:	83 ec 08             	sub    $0x8,%esp
f0102fba:	ff 75 0c             	pushl  0xc(%ebp)
f0102fbd:	6a 3f                	push   $0x3f
f0102fbf:	ff d6                	call   *%esi
f0102fc1:	83 c4 10             	add    $0x10,%esp
f0102fc4:	eb c9                	jmp    f0102f8f <vprintfmt+0x1e9>
f0102fc6:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fcb:	eb a0                	jmp    f0102f6d <vprintfmt+0x1c7>
f0102fcd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102fd0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102fd3:	eb bd                	jmp    f0102f92 <vprintfmt+0x1ec>
				putch(' ', putdat);
f0102fd5:	83 ec 08             	sub    $0x8,%esp
f0102fd8:	53                   	push   %ebx
f0102fd9:	6a 20                	push   $0x20
f0102fdb:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0102fdd:	4f                   	dec    %edi
f0102fde:	83 c4 10             	add    $0x10,%esp
f0102fe1:	85 ff                	test   %edi,%edi
f0102fe3:	7f f0                	jg     f0102fd5 <vprintfmt+0x22f>
			if ((p = va_arg(ap, char *)) == NULL)
f0102fe5:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102fe8:	89 45 14             	mov    %eax,0x14(%ebp)
f0102feb:	e9 76 01 00 00       	jmp    f0103166 <vprintfmt+0x3c0>
f0102ff0:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0102ff3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102ff6:	eb e9                	jmp    f0102fe1 <vprintfmt+0x23b>
	if (lflag >= 2)
f0102ff8:	83 f9 01             	cmp    $0x1,%ecx
f0102ffb:	7e 3f                	jle    f010303c <vprintfmt+0x296>
		return va_arg(*ap, long long);
f0102ffd:	8b 45 14             	mov    0x14(%ebp),%eax
f0103000:	8b 50 04             	mov    0x4(%eax),%edx
f0103003:	8b 00                	mov    (%eax),%eax
f0103005:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103008:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010300b:	8b 45 14             	mov    0x14(%ebp),%eax
f010300e:	8d 40 08             	lea    0x8(%eax),%eax
f0103011:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0103014:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0103018:	79 5c                	jns    f0103076 <vprintfmt+0x2d0>
				putch('-', putdat);
f010301a:	83 ec 08             	sub    $0x8,%esp
f010301d:	53                   	push   %ebx
f010301e:	6a 2d                	push   $0x2d
f0103020:	ff d6                	call   *%esi
				num = -(long long) num;
f0103022:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103025:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103028:	f7 da                	neg    %edx
f010302a:	83 d1 00             	adc    $0x0,%ecx
f010302d:	f7 d9                	neg    %ecx
f010302f:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0103032:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103037:	e9 10 01 00 00       	jmp    f010314c <vprintfmt+0x3a6>
	else if (lflag)
f010303c:	85 c9                	test   %ecx,%ecx
f010303e:	75 1b                	jne    f010305b <vprintfmt+0x2b5>
		return va_arg(*ap, int);
f0103040:	8b 45 14             	mov    0x14(%ebp),%eax
f0103043:	8b 00                	mov    (%eax),%eax
f0103045:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103048:	89 c1                	mov    %eax,%ecx
f010304a:	c1 f9 1f             	sar    $0x1f,%ecx
f010304d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103050:	8b 45 14             	mov    0x14(%ebp),%eax
f0103053:	8d 40 04             	lea    0x4(%eax),%eax
f0103056:	89 45 14             	mov    %eax,0x14(%ebp)
f0103059:	eb b9                	jmp    f0103014 <vprintfmt+0x26e>
		return va_arg(*ap, long);
f010305b:	8b 45 14             	mov    0x14(%ebp),%eax
f010305e:	8b 00                	mov    (%eax),%eax
f0103060:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103063:	89 c1                	mov    %eax,%ecx
f0103065:	c1 f9 1f             	sar    $0x1f,%ecx
f0103068:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010306b:	8b 45 14             	mov    0x14(%ebp),%eax
f010306e:	8d 40 04             	lea    0x4(%eax),%eax
f0103071:	89 45 14             	mov    %eax,0x14(%ebp)
f0103074:	eb 9e                	jmp    f0103014 <vprintfmt+0x26e>
			num = getint(&ap, lflag);
f0103076:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103079:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f010307c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103081:	e9 c6 00 00 00       	jmp    f010314c <vprintfmt+0x3a6>
	if (lflag >= 2)
f0103086:	83 f9 01             	cmp    $0x1,%ecx
f0103089:	7e 18                	jle    f01030a3 <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
f010308b:	8b 45 14             	mov    0x14(%ebp),%eax
f010308e:	8b 10                	mov    (%eax),%edx
f0103090:	8b 48 04             	mov    0x4(%eax),%ecx
f0103093:	8d 40 08             	lea    0x8(%eax),%eax
f0103096:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103099:	b8 0a 00 00 00       	mov    $0xa,%eax
f010309e:	e9 a9 00 00 00       	jmp    f010314c <vprintfmt+0x3a6>
	else if (lflag)
f01030a3:	85 c9                	test   %ecx,%ecx
f01030a5:	75 1a                	jne    f01030c1 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned int);
f01030a7:	8b 45 14             	mov    0x14(%ebp),%eax
f01030aa:	8b 10                	mov    (%eax),%edx
f01030ac:	b9 00 00 00 00       	mov    $0x0,%ecx
f01030b1:	8d 40 04             	lea    0x4(%eax),%eax
f01030b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01030b7:	b8 0a 00 00 00       	mov    $0xa,%eax
f01030bc:	e9 8b 00 00 00       	jmp    f010314c <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f01030c1:	8b 45 14             	mov    0x14(%ebp),%eax
f01030c4:	8b 10                	mov    (%eax),%edx
f01030c6:	b9 00 00 00 00       	mov    $0x0,%ecx
f01030cb:	8d 40 04             	lea    0x4(%eax),%eax
f01030ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01030d1:	b8 0a 00 00 00       	mov    $0xa,%eax
f01030d6:	eb 74                	jmp    f010314c <vprintfmt+0x3a6>
	if (lflag >= 2)
f01030d8:	83 f9 01             	cmp    $0x1,%ecx
f01030db:	7e 15                	jle    f01030f2 <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
f01030dd:	8b 45 14             	mov    0x14(%ebp),%eax
f01030e0:	8b 10                	mov    (%eax),%edx
f01030e2:	8b 48 04             	mov    0x4(%eax),%ecx
f01030e5:	8d 40 08             	lea    0x8(%eax),%eax
f01030e8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01030eb:	b8 08 00 00 00       	mov    $0x8,%eax
f01030f0:	eb 5a                	jmp    f010314c <vprintfmt+0x3a6>
	else if (lflag)
f01030f2:	85 c9                	test   %ecx,%ecx
f01030f4:	75 17                	jne    f010310d <vprintfmt+0x367>
		return va_arg(*ap, unsigned int);
f01030f6:	8b 45 14             	mov    0x14(%ebp),%eax
f01030f9:	8b 10                	mov    (%eax),%edx
f01030fb:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103100:	8d 40 04             	lea    0x4(%eax),%eax
f0103103:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0103106:	b8 08 00 00 00       	mov    $0x8,%eax
f010310b:	eb 3f                	jmp    f010314c <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f010310d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103110:	8b 10                	mov    (%eax),%edx
f0103112:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103117:	8d 40 04             	lea    0x4(%eax),%eax
f010311a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010311d:	b8 08 00 00 00       	mov    $0x8,%eax
f0103122:	eb 28                	jmp    f010314c <vprintfmt+0x3a6>
			putch('0', putdat);
f0103124:	83 ec 08             	sub    $0x8,%esp
f0103127:	53                   	push   %ebx
f0103128:	6a 30                	push   $0x30
f010312a:	ff d6                	call   *%esi
			putch('x', putdat);
f010312c:	83 c4 08             	add    $0x8,%esp
f010312f:	53                   	push   %ebx
f0103130:	6a 78                	push   $0x78
f0103132:	ff d6                	call   *%esi
			num = (unsigned long long)
f0103134:	8b 45 14             	mov    0x14(%ebp),%eax
f0103137:	8b 10                	mov    (%eax),%edx
f0103139:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010313e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0103141:	8d 40 04             	lea    0x4(%eax),%eax
f0103144:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103147:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f010314c:	83 ec 0c             	sub    $0xc,%esp
f010314f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0103153:	57                   	push   %edi
f0103154:	ff 75 e0             	pushl  -0x20(%ebp)
f0103157:	50                   	push   %eax
f0103158:	51                   	push   %ecx
f0103159:	52                   	push   %edx
f010315a:	89 da                	mov    %ebx,%edx
f010315c:	89 f0                	mov    %esi,%eax
f010315e:	e8 5d fb ff ff       	call   f0102cc0 <printnum>
			break;
f0103163:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0103166:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103169:	47                   	inc    %edi
f010316a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010316e:	83 f8 25             	cmp    $0x25,%eax
f0103171:	0f 84 46 fc ff ff    	je     f0102dbd <vprintfmt+0x17>
			if (ch == '\0')
f0103177:	85 c0                	test   %eax,%eax
f0103179:	0f 84 89 00 00 00    	je     f0103208 <vprintfmt+0x462>
			putch(ch, putdat);
f010317f:	83 ec 08             	sub    $0x8,%esp
f0103182:	53                   	push   %ebx
f0103183:	50                   	push   %eax
f0103184:	ff d6                	call   *%esi
f0103186:	83 c4 10             	add    $0x10,%esp
f0103189:	eb de                	jmp    f0103169 <vprintfmt+0x3c3>
	if (lflag >= 2)
f010318b:	83 f9 01             	cmp    $0x1,%ecx
f010318e:	7e 15                	jle    f01031a5 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
f0103190:	8b 45 14             	mov    0x14(%ebp),%eax
f0103193:	8b 10                	mov    (%eax),%edx
f0103195:	8b 48 04             	mov    0x4(%eax),%ecx
f0103198:	8d 40 08             	lea    0x8(%eax),%eax
f010319b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010319e:	b8 10 00 00 00       	mov    $0x10,%eax
f01031a3:	eb a7                	jmp    f010314c <vprintfmt+0x3a6>
	else if (lflag)
f01031a5:	85 c9                	test   %ecx,%ecx
f01031a7:	75 17                	jne    f01031c0 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned int);
f01031a9:	8b 45 14             	mov    0x14(%ebp),%eax
f01031ac:	8b 10                	mov    (%eax),%edx
f01031ae:	b9 00 00 00 00       	mov    $0x0,%ecx
f01031b3:	8d 40 04             	lea    0x4(%eax),%eax
f01031b6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01031b9:	b8 10 00 00 00       	mov    $0x10,%eax
f01031be:	eb 8c                	jmp    f010314c <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f01031c0:	8b 45 14             	mov    0x14(%ebp),%eax
f01031c3:	8b 10                	mov    (%eax),%edx
f01031c5:	b9 00 00 00 00       	mov    $0x0,%ecx
f01031ca:	8d 40 04             	lea    0x4(%eax),%eax
f01031cd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01031d0:	b8 10 00 00 00       	mov    $0x10,%eax
f01031d5:	e9 72 ff ff ff       	jmp    f010314c <vprintfmt+0x3a6>
			putch(ch, putdat);
f01031da:	83 ec 08             	sub    $0x8,%esp
f01031dd:	53                   	push   %ebx
f01031de:	6a 25                	push   $0x25
f01031e0:	ff d6                	call   *%esi
			break;
f01031e2:	83 c4 10             	add    $0x10,%esp
f01031e5:	e9 7c ff ff ff       	jmp    f0103166 <vprintfmt+0x3c0>
			putch('%', putdat);
f01031ea:	83 ec 08             	sub    $0x8,%esp
f01031ed:	53                   	push   %ebx
f01031ee:	6a 25                	push   $0x25
f01031f0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01031f2:	83 c4 10             	add    $0x10,%esp
f01031f5:	89 f8                	mov    %edi,%eax
f01031f7:	eb 01                	jmp    f01031fa <vprintfmt+0x454>
f01031f9:	48                   	dec    %eax
f01031fa:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01031fe:	75 f9                	jne    f01031f9 <vprintfmt+0x453>
f0103200:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103203:	e9 5e ff ff ff       	jmp    f0103166 <vprintfmt+0x3c0>
}
f0103208:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010320b:	5b                   	pop    %ebx
f010320c:	5e                   	pop    %esi
f010320d:	5f                   	pop    %edi
f010320e:	5d                   	pop    %ebp
f010320f:	c3                   	ret    

f0103210 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103210:	55                   	push   %ebp
f0103211:	89 e5                	mov    %esp,%ebp
f0103213:	83 ec 18             	sub    $0x18,%esp
f0103216:	8b 45 08             	mov    0x8(%ebp),%eax
f0103219:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010321c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010321f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103223:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103226:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010322d:	85 c0                	test   %eax,%eax
f010322f:	74 26                	je     f0103257 <vsnprintf+0x47>
f0103231:	85 d2                	test   %edx,%edx
f0103233:	7e 29                	jle    f010325e <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103235:	ff 75 14             	pushl  0x14(%ebp)
f0103238:	ff 75 10             	pushl  0x10(%ebp)
f010323b:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010323e:	50                   	push   %eax
f010323f:	68 6d 2d 10 f0       	push   $0xf0102d6d
f0103244:	e8 5d fb ff ff       	call   f0102da6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103249:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010324c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010324f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103252:	83 c4 10             	add    $0x10,%esp
}
f0103255:	c9                   	leave  
f0103256:	c3                   	ret    
		return -E_INVAL;
f0103257:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010325c:	eb f7                	jmp    f0103255 <vsnprintf+0x45>
f010325e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103263:	eb f0                	jmp    f0103255 <vsnprintf+0x45>

f0103265 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103265:	55                   	push   %ebp
f0103266:	89 e5                	mov    %esp,%ebp
f0103268:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010326b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010326e:	50                   	push   %eax
f010326f:	ff 75 10             	pushl  0x10(%ebp)
f0103272:	ff 75 0c             	pushl  0xc(%ebp)
f0103275:	ff 75 08             	pushl  0x8(%ebp)
f0103278:	e8 93 ff ff ff       	call   f0103210 <vsnprintf>
	va_end(ap);

	return rc;
}
f010327d:	c9                   	leave  
f010327e:	c3                   	ret    

f010327f <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010327f:	55                   	push   %ebp
f0103280:	89 e5                	mov    %esp,%ebp
f0103282:	57                   	push   %edi
f0103283:	56                   	push   %esi
f0103284:	53                   	push   %ebx
f0103285:	83 ec 0c             	sub    $0xc,%esp
f0103288:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010328b:	85 c0                	test   %eax,%eax
f010328d:	74 11                	je     f01032a0 <readline+0x21>
		cprintf("%s", prompt);
f010328f:	83 ec 08             	sub    $0x8,%esp
f0103292:	50                   	push   %eax
f0103293:	68 70 46 10 f0       	push   $0xf0104670
f0103298:	e8 f3 f6 ff ff       	call   f0102990 <cprintf>
f010329d:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01032a0:	83 ec 0c             	sub    $0xc,%esp
f01032a3:	6a 00                	push   $0x0
f01032a5:	e8 fd d3 ff ff       	call   f01006a7 <iscons>
f01032aa:	89 c7                	mov    %eax,%edi
f01032ac:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01032af:	be 00 00 00 00       	mov    $0x0,%esi
f01032b4:	eb 6f                	jmp    f0103325 <readline+0xa6>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01032b6:	83 ec 08             	sub    $0x8,%esp
f01032b9:	50                   	push   %eax
f01032ba:	68 6c 4b 10 f0       	push   $0xf0104b6c
f01032bf:	e8 cc f6 ff ff       	call   f0102990 <cprintf>
			return NULL;
f01032c4:	83 c4 10             	add    $0x10,%esp
f01032c7:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01032cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01032cf:	5b                   	pop    %ebx
f01032d0:	5e                   	pop    %esi
f01032d1:	5f                   	pop    %edi
f01032d2:	5d                   	pop    %ebp
f01032d3:	c3                   	ret    
				cputchar('\b');
f01032d4:	83 ec 0c             	sub    $0xc,%esp
f01032d7:	6a 08                	push   $0x8
f01032d9:	e8 a8 d3 ff ff       	call   f0100686 <cputchar>
f01032de:	83 c4 10             	add    $0x10,%esp
f01032e1:	eb 41                	jmp    f0103324 <readline+0xa5>
				cputchar(c);
f01032e3:	83 ec 0c             	sub    $0xc,%esp
f01032e6:	53                   	push   %ebx
f01032e7:	e8 9a d3 ff ff       	call   f0100686 <cputchar>
f01032ec:	83 c4 10             	add    $0x10,%esp
f01032ef:	eb 5a                	jmp    f010334b <readline+0xcc>
		} else if (c == '\n' || c == '\r') {
f01032f1:	83 fb 0a             	cmp    $0xa,%ebx
f01032f4:	74 05                	je     f01032fb <readline+0x7c>
f01032f6:	83 fb 0d             	cmp    $0xd,%ebx
f01032f9:	75 2a                	jne    f0103325 <readline+0xa6>
			if (echoing)
f01032fb:	85 ff                	test   %edi,%edi
f01032fd:	75 0e                	jne    f010330d <readline+0x8e>
			buf[i] = 0;
f01032ff:	c6 86 60 85 11 f0 00 	movb   $0x0,-0xfee7aa0(%esi)
			return buf;
f0103306:	b8 60 85 11 f0       	mov    $0xf0118560,%eax
f010330b:	eb bf                	jmp    f01032cc <readline+0x4d>
				cputchar('\n');
f010330d:	83 ec 0c             	sub    $0xc,%esp
f0103310:	6a 0a                	push   $0xa
f0103312:	e8 6f d3 ff ff       	call   f0100686 <cputchar>
f0103317:	83 c4 10             	add    $0x10,%esp
f010331a:	eb e3                	jmp    f01032ff <readline+0x80>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010331c:	85 f6                	test   %esi,%esi
f010331e:	7e 3c                	jle    f010335c <readline+0xdd>
			if (echoing)
f0103320:	85 ff                	test   %edi,%edi
f0103322:	75 b0                	jne    f01032d4 <readline+0x55>
			i--;
f0103324:	4e                   	dec    %esi
		c = getchar();
f0103325:	e8 6c d3 ff ff       	call   f0100696 <getchar>
f010332a:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010332c:	85 c0                	test   %eax,%eax
f010332e:	78 86                	js     f01032b6 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103330:	83 f8 08             	cmp    $0x8,%eax
f0103333:	74 21                	je     f0103356 <readline+0xd7>
f0103335:	83 f8 7f             	cmp    $0x7f,%eax
f0103338:	74 e2                	je     f010331c <readline+0x9d>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010333a:	83 f8 1f             	cmp    $0x1f,%eax
f010333d:	7e b2                	jle    f01032f1 <readline+0x72>
f010333f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103345:	7f aa                	jg     f01032f1 <readline+0x72>
			if (echoing)
f0103347:	85 ff                	test   %edi,%edi
f0103349:	75 98                	jne    f01032e3 <readline+0x64>
			buf[i++] = c;
f010334b:	88 9e 60 85 11 f0    	mov    %bl,-0xfee7aa0(%esi)
f0103351:	8d 76 01             	lea    0x1(%esi),%esi
f0103354:	eb cf                	jmp    f0103325 <readline+0xa6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103356:	85 f6                	test   %esi,%esi
f0103358:	7e cb                	jle    f0103325 <readline+0xa6>
f010335a:	eb c4                	jmp    f0103320 <readline+0xa1>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010335c:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103362:	7e e3                	jle    f0103347 <readline+0xc8>
f0103364:	eb bf                	jmp    f0103325 <readline+0xa6>

f0103366 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103366:	55                   	push   %ebp
f0103367:	89 e5                	mov    %esp,%ebp
f0103369:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010336c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103371:	eb 01                	jmp    f0103374 <strlen+0xe>
		n++;
f0103373:	40                   	inc    %eax
	for (n = 0; *s != '\0'; s++)
f0103374:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103378:	75 f9                	jne    f0103373 <strlen+0xd>
	return n;
}
f010337a:	5d                   	pop    %ebp
f010337b:	c3                   	ret    

f010337c <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010337c:	55                   	push   %ebp
f010337d:	89 e5                	mov    %esp,%ebp
f010337f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103382:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103385:	b8 00 00 00 00       	mov    $0x0,%eax
f010338a:	eb 01                	jmp    f010338d <strnlen+0x11>
		n++;
f010338c:	40                   	inc    %eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010338d:	39 d0                	cmp    %edx,%eax
f010338f:	74 06                	je     f0103397 <strnlen+0x1b>
f0103391:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0103395:	75 f5                	jne    f010338c <strnlen+0x10>
	return n;
}
f0103397:	5d                   	pop    %ebp
f0103398:	c3                   	ret    

f0103399 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103399:	55                   	push   %ebp
f010339a:	89 e5                	mov    %esp,%ebp
f010339c:	53                   	push   %ebx
f010339d:	8b 45 08             	mov    0x8(%ebp),%eax
f01033a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01033a3:	89 c2                	mov    %eax,%edx
f01033a5:	41                   	inc    %ecx
f01033a6:	42                   	inc    %edx
f01033a7:	8a 59 ff             	mov    -0x1(%ecx),%bl
f01033aa:	88 5a ff             	mov    %bl,-0x1(%edx)
f01033ad:	84 db                	test   %bl,%bl
f01033af:	75 f4                	jne    f01033a5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01033b1:	5b                   	pop    %ebx
f01033b2:	5d                   	pop    %ebp
f01033b3:	c3                   	ret    

f01033b4 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01033b4:	55                   	push   %ebp
f01033b5:	89 e5                	mov    %esp,%ebp
f01033b7:	53                   	push   %ebx
f01033b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01033bb:	53                   	push   %ebx
f01033bc:	e8 a5 ff ff ff       	call   f0103366 <strlen>
f01033c1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01033c4:	ff 75 0c             	pushl  0xc(%ebp)
f01033c7:	01 d8                	add    %ebx,%eax
f01033c9:	50                   	push   %eax
f01033ca:	e8 ca ff ff ff       	call   f0103399 <strcpy>
	return dst;
}
f01033cf:	89 d8                	mov    %ebx,%eax
f01033d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01033d4:	c9                   	leave  
f01033d5:	c3                   	ret    

f01033d6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01033d6:	55                   	push   %ebp
f01033d7:	89 e5                	mov    %esp,%ebp
f01033d9:	56                   	push   %esi
f01033da:	53                   	push   %ebx
f01033db:	8b 75 08             	mov    0x8(%ebp),%esi
f01033de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01033e1:	89 f3                	mov    %esi,%ebx
f01033e3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01033e6:	89 f2                	mov    %esi,%edx
f01033e8:	39 da                	cmp    %ebx,%edx
f01033ea:	74 0e                	je     f01033fa <strncpy+0x24>
		*dst++ = *src;
f01033ec:	42                   	inc    %edx
f01033ed:	8a 01                	mov    (%ecx),%al
f01033ef:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f01033f2:	80 39 00             	cmpb   $0x0,(%ecx)
f01033f5:	74 f1                	je     f01033e8 <strncpy+0x12>
			src++;
f01033f7:	41                   	inc    %ecx
f01033f8:	eb ee                	jmp    f01033e8 <strncpy+0x12>
	}
	return ret;
}
f01033fa:	89 f0                	mov    %esi,%eax
f01033fc:	5b                   	pop    %ebx
f01033fd:	5e                   	pop    %esi
f01033fe:	5d                   	pop    %ebp
f01033ff:	c3                   	ret    

f0103400 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103400:	55                   	push   %ebp
f0103401:	89 e5                	mov    %esp,%ebp
f0103403:	56                   	push   %esi
f0103404:	53                   	push   %ebx
f0103405:	8b 75 08             	mov    0x8(%ebp),%esi
f0103408:	8b 55 0c             	mov    0xc(%ebp),%edx
f010340b:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010340e:	85 c0                	test   %eax,%eax
f0103410:	74 20                	je     f0103432 <strlcpy+0x32>
f0103412:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
f0103416:	89 f0                	mov    %esi,%eax
f0103418:	eb 05                	jmp    f010341f <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010341a:	42                   	inc    %edx
f010341b:	40                   	inc    %eax
f010341c:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f010341f:	39 d8                	cmp    %ebx,%eax
f0103421:	74 06                	je     f0103429 <strlcpy+0x29>
f0103423:	8a 0a                	mov    (%edx),%cl
f0103425:	84 c9                	test   %cl,%cl
f0103427:	75 f1                	jne    f010341a <strlcpy+0x1a>
		*dst = '\0';
f0103429:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010342c:	29 f0                	sub    %esi,%eax
}
f010342e:	5b                   	pop    %ebx
f010342f:	5e                   	pop    %esi
f0103430:	5d                   	pop    %ebp
f0103431:	c3                   	ret    
f0103432:	89 f0                	mov    %esi,%eax
f0103434:	eb f6                	jmp    f010342c <strlcpy+0x2c>

f0103436 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103436:	55                   	push   %ebp
f0103437:	89 e5                	mov    %esp,%ebp
f0103439:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010343c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010343f:	eb 02                	jmp    f0103443 <strcmp+0xd>
		p++, q++;
f0103441:	41                   	inc    %ecx
f0103442:	42                   	inc    %edx
	while (*p && *p == *q)
f0103443:	8a 01                	mov    (%ecx),%al
f0103445:	84 c0                	test   %al,%al
f0103447:	74 04                	je     f010344d <strcmp+0x17>
f0103449:	3a 02                	cmp    (%edx),%al
f010344b:	74 f4                	je     f0103441 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010344d:	0f b6 c0             	movzbl %al,%eax
f0103450:	0f b6 12             	movzbl (%edx),%edx
f0103453:	29 d0                	sub    %edx,%eax
}
f0103455:	5d                   	pop    %ebp
f0103456:	c3                   	ret    

f0103457 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103457:	55                   	push   %ebp
f0103458:	89 e5                	mov    %esp,%ebp
f010345a:	53                   	push   %ebx
f010345b:	8b 45 08             	mov    0x8(%ebp),%eax
f010345e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103461:	89 c3                	mov    %eax,%ebx
f0103463:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103466:	eb 02                	jmp    f010346a <strncmp+0x13>
		n--, p++, q++;
f0103468:	40                   	inc    %eax
f0103469:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
f010346a:	39 d8                	cmp    %ebx,%eax
f010346c:	74 15                	je     f0103483 <strncmp+0x2c>
f010346e:	8a 08                	mov    (%eax),%cl
f0103470:	84 c9                	test   %cl,%cl
f0103472:	74 04                	je     f0103478 <strncmp+0x21>
f0103474:	3a 0a                	cmp    (%edx),%cl
f0103476:	74 f0                	je     f0103468 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103478:	0f b6 00             	movzbl (%eax),%eax
f010347b:	0f b6 12             	movzbl (%edx),%edx
f010347e:	29 d0                	sub    %edx,%eax
}
f0103480:	5b                   	pop    %ebx
f0103481:	5d                   	pop    %ebp
f0103482:	c3                   	ret    
		return 0;
f0103483:	b8 00 00 00 00       	mov    $0x0,%eax
f0103488:	eb f6                	jmp    f0103480 <strncmp+0x29>

f010348a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010348a:	55                   	push   %ebp
f010348b:	89 e5                	mov    %esp,%ebp
f010348d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103490:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0103493:	8a 10                	mov    (%eax),%dl
f0103495:	84 d2                	test   %dl,%dl
f0103497:	74 07                	je     f01034a0 <strchr+0x16>
		if (*s == c)
f0103499:	38 ca                	cmp    %cl,%dl
f010349b:	74 08                	je     f01034a5 <strchr+0x1b>
	for (; *s; s++)
f010349d:	40                   	inc    %eax
f010349e:	eb f3                	jmp    f0103493 <strchr+0x9>
			return (char *) s;
	return 0;
f01034a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01034a5:	5d                   	pop    %ebp
f01034a6:	c3                   	ret    

f01034a7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01034a7:	55                   	push   %ebp
f01034a8:	89 e5                	mov    %esp,%ebp
f01034aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01034ad:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01034b0:	8a 10                	mov    (%eax),%dl
f01034b2:	84 d2                	test   %dl,%dl
f01034b4:	74 07                	je     f01034bd <strfind+0x16>
		if (*s == c)
f01034b6:	38 ca                	cmp    %cl,%dl
f01034b8:	74 03                	je     f01034bd <strfind+0x16>
	for (; *s; s++)
f01034ba:	40                   	inc    %eax
f01034bb:	eb f3                	jmp    f01034b0 <strfind+0x9>
			break;
	return (char *) s;
}
f01034bd:	5d                   	pop    %ebp
f01034be:	c3                   	ret    

f01034bf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01034bf:	55                   	push   %ebp
f01034c0:	89 e5                	mov    %esp,%ebp
f01034c2:	57                   	push   %edi
f01034c3:	56                   	push   %esi
f01034c4:	53                   	push   %ebx
f01034c5:	8b 7d 08             	mov    0x8(%ebp),%edi
f01034c8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01034cb:	85 c9                	test   %ecx,%ecx
f01034cd:	74 13                	je     f01034e2 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01034cf:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01034d5:	75 05                	jne    f01034dc <memset+0x1d>
f01034d7:	f6 c1 03             	test   $0x3,%cl
f01034da:	74 0d                	je     f01034e9 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01034dc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034df:	fc                   	cld    
f01034e0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01034e2:	89 f8                	mov    %edi,%eax
f01034e4:	5b                   	pop    %ebx
f01034e5:	5e                   	pop    %esi
f01034e6:	5f                   	pop    %edi
f01034e7:	5d                   	pop    %ebp
f01034e8:	c3                   	ret    
		c &= 0xFF;
f01034e9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01034ed:	89 d3                	mov    %edx,%ebx
f01034ef:	c1 e3 08             	shl    $0x8,%ebx
f01034f2:	89 d0                	mov    %edx,%eax
f01034f4:	c1 e0 18             	shl    $0x18,%eax
f01034f7:	89 d6                	mov    %edx,%esi
f01034f9:	c1 e6 10             	shl    $0x10,%esi
f01034fc:	09 f0                	or     %esi,%eax
f01034fe:	09 c2                	or     %eax,%edx
f0103500:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0103502:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0103505:	89 d0                	mov    %edx,%eax
f0103507:	fc                   	cld    
f0103508:	f3 ab                	rep stos %eax,%es:(%edi)
f010350a:	eb d6                	jmp    f01034e2 <memset+0x23>

f010350c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010350c:	55                   	push   %ebp
f010350d:	89 e5                	mov    %esp,%ebp
f010350f:	57                   	push   %edi
f0103510:	56                   	push   %esi
f0103511:	8b 45 08             	mov    0x8(%ebp),%eax
f0103514:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103517:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010351a:	39 c6                	cmp    %eax,%esi
f010351c:	73 33                	jae    f0103551 <memmove+0x45>
f010351e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103521:	39 c2                	cmp    %eax,%edx
f0103523:	76 2c                	jbe    f0103551 <memmove+0x45>
		s += n;
		d += n;
f0103525:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103528:	89 d6                	mov    %edx,%esi
f010352a:	09 fe                	or     %edi,%esi
f010352c:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103532:	74 0a                	je     f010353e <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0103534:	4f                   	dec    %edi
f0103535:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0103538:	fd                   	std    
f0103539:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010353b:	fc                   	cld    
f010353c:	eb 21                	jmp    f010355f <memmove+0x53>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010353e:	f6 c1 03             	test   $0x3,%cl
f0103541:	75 f1                	jne    f0103534 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103543:	83 ef 04             	sub    $0x4,%edi
f0103546:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103549:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f010354c:	fd                   	std    
f010354d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010354f:	eb ea                	jmp    f010353b <memmove+0x2f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103551:	89 f2                	mov    %esi,%edx
f0103553:	09 c2                	or     %eax,%edx
f0103555:	f6 c2 03             	test   $0x3,%dl
f0103558:	74 09                	je     f0103563 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010355a:	89 c7                	mov    %eax,%edi
f010355c:	fc                   	cld    
f010355d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010355f:	5e                   	pop    %esi
f0103560:	5f                   	pop    %edi
f0103561:	5d                   	pop    %ebp
f0103562:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103563:	f6 c1 03             	test   $0x3,%cl
f0103566:	75 f2                	jne    f010355a <memmove+0x4e>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103568:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f010356b:	89 c7                	mov    %eax,%edi
f010356d:	fc                   	cld    
f010356e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103570:	eb ed                	jmp    f010355f <memmove+0x53>

f0103572 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103572:	55                   	push   %ebp
f0103573:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0103575:	ff 75 10             	pushl  0x10(%ebp)
f0103578:	ff 75 0c             	pushl  0xc(%ebp)
f010357b:	ff 75 08             	pushl  0x8(%ebp)
f010357e:	e8 89 ff ff ff       	call   f010350c <memmove>
}
f0103583:	c9                   	leave  
f0103584:	c3                   	ret    

f0103585 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103585:	55                   	push   %ebp
f0103586:	89 e5                	mov    %esp,%ebp
f0103588:	56                   	push   %esi
f0103589:	53                   	push   %ebx
f010358a:	8b 45 08             	mov    0x8(%ebp),%eax
f010358d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103590:	89 c6                	mov    %eax,%esi
f0103592:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103595:	39 f0                	cmp    %esi,%eax
f0103597:	74 16                	je     f01035af <memcmp+0x2a>
		if (*s1 != *s2)
f0103599:	8a 08                	mov    (%eax),%cl
f010359b:	8a 1a                	mov    (%edx),%bl
f010359d:	38 d9                	cmp    %bl,%cl
f010359f:	75 04                	jne    f01035a5 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01035a1:	40                   	inc    %eax
f01035a2:	42                   	inc    %edx
f01035a3:	eb f0                	jmp    f0103595 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f01035a5:	0f b6 c1             	movzbl %cl,%eax
f01035a8:	0f b6 db             	movzbl %bl,%ebx
f01035ab:	29 d8                	sub    %ebx,%eax
f01035ad:	eb 05                	jmp    f01035b4 <memcmp+0x2f>
	}

	return 0;
f01035af:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01035b4:	5b                   	pop    %ebx
f01035b5:	5e                   	pop    %esi
f01035b6:	5d                   	pop    %ebp
f01035b7:	c3                   	ret    

f01035b8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01035b8:	55                   	push   %ebp
f01035b9:	89 e5                	mov    %esp,%ebp
f01035bb:	8b 45 08             	mov    0x8(%ebp),%eax
f01035be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01035c1:	89 c2                	mov    %eax,%edx
f01035c3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01035c6:	39 d0                	cmp    %edx,%eax
f01035c8:	73 07                	jae    f01035d1 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
f01035ca:	38 08                	cmp    %cl,(%eax)
f01035cc:	74 03                	je     f01035d1 <memfind+0x19>
	for (; s < ends; s++)
f01035ce:	40                   	inc    %eax
f01035cf:	eb f5                	jmp    f01035c6 <memfind+0xe>
			break;
	return (void *) s;
}
f01035d1:	5d                   	pop    %ebp
f01035d2:	c3                   	ret    

f01035d3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01035d3:	55                   	push   %ebp
f01035d4:	89 e5                	mov    %esp,%ebp
f01035d6:	57                   	push   %edi
f01035d7:	56                   	push   %esi
f01035d8:	53                   	push   %ebx
f01035d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01035dc:	eb 01                	jmp    f01035df <strtol+0xc>
		s++;
f01035de:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f01035df:	8a 01                	mov    (%ecx),%al
f01035e1:	3c 20                	cmp    $0x20,%al
f01035e3:	74 f9                	je     f01035de <strtol+0xb>
f01035e5:	3c 09                	cmp    $0x9,%al
f01035e7:	74 f5                	je     f01035de <strtol+0xb>

	// plus/minus sign
	if (*s == '+')
f01035e9:	3c 2b                	cmp    $0x2b,%al
f01035eb:	74 2b                	je     f0103618 <strtol+0x45>
		s++;
	else if (*s == '-')
f01035ed:	3c 2d                	cmp    $0x2d,%al
f01035ef:	74 2f                	je     f0103620 <strtol+0x4d>
	int neg = 0;
f01035f1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01035f6:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f01035fd:	75 12                	jne    f0103611 <strtol+0x3e>
f01035ff:	80 39 30             	cmpb   $0x30,(%ecx)
f0103602:	74 24                	je     f0103628 <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103604:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0103608:	75 07                	jne    f0103611 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010360a:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f0103611:	b8 00 00 00 00       	mov    $0x0,%eax
f0103616:	eb 4e                	jmp    f0103666 <strtol+0x93>
		s++;
f0103618:	41                   	inc    %ecx
	int neg = 0;
f0103619:	bf 00 00 00 00       	mov    $0x0,%edi
f010361e:	eb d6                	jmp    f01035f6 <strtol+0x23>
		s++, neg = 1;
f0103620:	41                   	inc    %ecx
f0103621:	bf 01 00 00 00       	mov    $0x1,%edi
f0103626:	eb ce                	jmp    f01035f6 <strtol+0x23>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103628:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010362c:	74 10                	je     f010363e <strtol+0x6b>
	else if (base == 0 && s[0] == '0')
f010362e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0103632:	75 dd                	jne    f0103611 <strtol+0x3e>
		s++, base = 8;
f0103634:	41                   	inc    %ecx
f0103635:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f010363c:	eb d3                	jmp    f0103611 <strtol+0x3e>
		s += 2, base = 16;
f010363e:	83 c1 02             	add    $0x2,%ecx
f0103641:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f0103648:	eb c7                	jmp    f0103611 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f010364a:	8d 72 9f             	lea    -0x61(%edx),%esi
f010364d:	89 f3                	mov    %esi,%ebx
f010364f:	80 fb 19             	cmp    $0x19,%bl
f0103652:	77 24                	ja     f0103678 <strtol+0xa5>
			dig = *s - 'a' + 10;
f0103654:	0f be d2             	movsbl %dl,%edx
f0103657:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010365a:	3b 55 10             	cmp    0x10(%ebp),%edx
f010365d:	7d 2b                	jge    f010368a <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
f010365f:	41                   	inc    %ecx
f0103660:	0f af 45 10          	imul   0x10(%ebp),%eax
f0103664:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0103666:	8a 11                	mov    (%ecx),%dl
f0103668:	8d 5a d0             	lea    -0x30(%edx),%ebx
f010366b:	80 fb 09             	cmp    $0x9,%bl
f010366e:	77 da                	ja     f010364a <strtol+0x77>
			dig = *s - '0';
f0103670:	0f be d2             	movsbl %dl,%edx
f0103673:	83 ea 30             	sub    $0x30,%edx
f0103676:	eb e2                	jmp    f010365a <strtol+0x87>
		else if (*s >= 'A' && *s <= 'Z')
f0103678:	8d 72 bf             	lea    -0x41(%edx),%esi
f010367b:	89 f3                	mov    %esi,%ebx
f010367d:	80 fb 19             	cmp    $0x19,%bl
f0103680:	77 08                	ja     f010368a <strtol+0xb7>
			dig = *s - 'A' + 10;
f0103682:	0f be d2             	movsbl %dl,%edx
f0103685:	83 ea 37             	sub    $0x37,%edx
f0103688:	eb d0                	jmp    f010365a <strtol+0x87>
		// we don't properly detect overflow!
	}

	if (endptr)
f010368a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010368e:	74 05                	je     f0103695 <strtol+0xc2>
		*endptr = (char *) s;
f0103690:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103693:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0103695:	85 ff                	test   %edi,%edi
f0103697:	74 02                	je     f010369b <strtol+0xc8>
f0103699:	f7 d8                	neg    %eax
}
f010369b:	5b                   	pop    %ebx
f010369c:	5e                   	pop    %esi
f010369d:	5f                   	pop    %edi
f010369e:	5d                   	pop    %ebp
f010369f:	c3                   	ret    

f01036a0 <__udivdi3>:
f01036a0:	55                   	push   %ebp
f01036a1:	57                   	push   %edi
f01036a2:	56                   	push   %esi
f01036a3:	53                   	push   %ebx
f01036a4:	83 ec 1c             	sub    $0x1c,%esp
f01036a7:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01036ab:	8b 74 24 34          	mov    0x34(%esp),%esi
f01036af:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01036b3:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01036b7:	85 d2                	test   %edx,%edx
f01036b9:	75 2d                	jne    f01036e8 <__udivdi3+0x48>
f01036bb:	39 f7                	cmp    %esi,%edi
f01036bd:	77 59                	ja     f0103718 <__udivdi3+0x78>
f01036bf:	89 f9                	mov    %edi,%ecx
f01036c1:	85 ff                	test   %edi,%edi
f01036c3:	75 0b                	jne    f01036d0 <__udivdi3+0x30>
f01036c5:	b8 01 00 00 00       	mov    $0x1,%eax
f01036ca:	31 d2                	xor    %edx,%edx
f01036cc:	f7 f7                	div    %edi
f01036ce:	89 c1                	mov    %eax,%ecx
f01036d0:	31 d2                	xor    %edx,%edx
f01036d2:	89 f0                	mov    %esi,%eax
f01036d4:	f7 f1                	div    %ecx
f01036d6:	89 c3                	mov    %eax,%ebx
f01036d8:	89 e8                	mov    %ebp,%eax
f01036da:	f7 f1                	div    %ecx
f01036dc:	89 da                	mov    %ebx,%edx
f01036de:	83 c4 1c             	add    $0x1c,%esp
f01036e1:	5b                   	pop    %ebx
f01036e2:	5e                   	pop    %esi
f01036e3:	5f                   	pop    %edi
f01036e4:	5d                   	pop    %ebp
f01036e5:	c3                   	ret    
f01036e6:	66 90                	xchg   %ax,%ax
f01036e8:	39 f2                	cmp    %esi,%edx
f01036ea:	77 1c                	ja     f0103708 <__udivdi3+0x68>
f01036ec:	0f bd da             	bsr    %edx,%ebx
f01036ef:	83 f3 1f             	xor    $0x1f,%ebx
f01036f2:	75 38                	jne    f010372c <__udivdi3+0x8c>
f01036f4:	39 f2                	cmp    %esi,%edx
f01036f6:	72 08                	jb     f0103700 <__udivdi3+0x60>
f01036f8:	39 ef                	cmp    %ebp,%edi
f01036fa:	0f 87 98 00 00 00    	ja     f0103798 <__udivdi3+0xf8>
f0103700:	b8 01 00 00 00       	mov    $0x1,%eax
f0103705:	eb 05                	jmp    f010370c <__udivdi3+0x6c>
f0103707:	90                   	nop
f0103708:	31 db                	xor    %ebx,%ebx
f010370a:	31 c0                	xor    %eax,%eax
f010370c:	89 da                	mov    %ebx,%edx
f010370e:	83 c4 1c             	add    $0x1c,%esp
f0103711:	5b                   	pop    %ebx
f0103712:	5e                   	pop    %esi
f0103713:	5f                   	pop    %edi
f0103714:	5d                   	pop    %ebp
f0103715:	c3                   	ret    
f0103716:	66 90                	xchg   %ax,%ax
f0103718:	89 e8                	mov    %ebp,%eax
f010371a:	89 f2                	mov    %esi,%edx
f010371c:	f7 f7                	div    %edi
f010371e:	31 db                	xor    %ebx,%ebx
f0103720:	89 da                	mov    %ebx,%edx
f0103722:	83 c4 1c             	add    $0x1c,%esp
f0103725:	5b                   	pop    %ebx
f0103726:	5e                   	pop    %esi
f0103727:	5f                   	pop    %edi
f0103728:	5d                   	pop    %ebp
f0103729:	c3                   	ret    
f010372a:	66 90                	xchg   %ax,%ax
f010372c:	b8 20 00 00 00       	mov    $0x20,%eax
f0103731:	29 d8                	sub    %ebx,%eax
f0103733:	88 d9                	mov    %bl,%cl
f0103735:	d3 e2                	shl    %cl,%edx
f0103737:	89 54 24 08          	mov    %edx,0x8(%esp)
f010373b:	89 fa                	mov    %edi,%edx
f010373d:	88 c1                	mov    %al,%cl
f010373f:	d3 ea                	shr    %cl,%edx
f0103741:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0103745:	09 d1                	or     %edx,%ecx
f0103747:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010374b:	88 d9                	mov    %bl,%cl
f010374d:	d3 e7                	shl    %cl,%edi
f010374f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0103753:	89 f7                	mov    %esi,%edi
f0103755:	88 c1                	mov    %al,%cl
f0103757:	d3 ef                	shr    %cl,%edi
f0103759:	88 d9                	mov    %bl,%cl
f010375b:	d3 e6                	shl    %cl,%esi
f010375d:	89 ea                	mov    %ebp,%edx
f010375f:	88 c1                	mov    %al,%cl
f0103761:	d3 ea                	shr    %cl,%edx
f0103763:	09 d6                	or     %edx,%esi
f0103765:	89 f0                	mov    %esi,%eax
f0103767:	89 fa                	mov    %edi,%edx
f0103769:	f7 74 24 08          	divl   0x8(%esp)
f010376d:	89 d7                	mov    %edx,%edi
f010376f:	89 c6                	mov    %eax,%esi
f0103771:	f7 64 24 0c          	mull   0xc(%esp)
f0103775:	39 d7                	cmp    %edx,%edi
f0103777:	72 13                	jb     f010378c <__udivdi3+0xec>
f0103779:	74 09                	je     f0103784 <__udivdi3+0xe4>
f010377b:	89 f0                	mov    %esi,%eax
f010377d:	31 db                	xor    %ebx,%ebx
f010377f:	eb 8b                	jmp    f010370c <__udivdi3+0x6c>
f0103781:	8d 76 00             	lea    0x0(%esi),%esi
f0103784:	88 d9                	mov    %bl,%cl
f0103786:	d3 e5                	shl    %cl,%ebp
f0103788:	39 c5                	cmp    %eax,%ebp
f010378a:	73 ef                	jae    f010377b <__udivdi3+0xdb>
f010378c:	8d 46 ff             	lea    -0x1(%esi),%eax
f010378f:	31 db                	xor    %ebx,%ebx
f0103791:	e9 76 ff ff ff       	jmp    f010370c <__udivdi3+0x6c>
f0103796:	66 90                	xchg   %ax,%ax
f0103798:	31 c0                	xor    %eax,%eax
f010379a:	e9 6d ff ff ff       	jmp    f010370c <__udivdi3+0x6c>
f010379f:	90                   	nop

f01037a0 <__umoddi3>:
f01037a0:	55                   	push   %ebp
f01037a1:	57                   	push   %edi
f01037a2:	56                   	push   %esi
f01037a3:	53                   	push   %ebx
f01037a4:	83 ec 1c             	sub    $0x1c,%esp
f01037a7:	8b 74 24 30          	mov    0x30(%esp),%esi
f01037ab:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01037af:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01037b3:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f01037b7:	89 f0                	mov    %esi,%eax
f01037b9:	89 da                	mov    %ebx,%edx
f01037bb:	85 ed                	test   %ebp,%ebp
f01037bd:	75 15                	jne    f01037d4 <__umoddi3+0x34>
f01037bf:	39 df                	cmp    %ebx,%edi
f01037c1:	76 39                	jbe    f01037fc <__umoddi3+0x5c>
f01037c3:	f7 f7                	div    %edi
f01037c5:	89 d0                	mov    %edx,%eax
f01037c7:	31 d2                	xor    %edx,%edx
f01037c9:	83 c4 1c             	add    $0x1c,%esp
f01037cc:	5b                   	pop    %ebx
f01037cd:	5e                   	pop    %esi
f01037ce:	5f                   	pop    %edi
f01037cf:	5d                   	pop    %ebp
f01037d0:	c3                   	ret    
f01037d1:	8d 76 00             	lea    0x0(%esi),%esi
f01037d4:	39 dd                	cmp    %ebx,%ebp
f01037d6:	77 f1                	ja     f01037c9 <__umoddi3+0x29>
f01037d8:	0f bd cd             	bsr    %ebp,%ecx
f01037db:	83 f1 1f             	xor    $0x1f,%ecx
f01037de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01037e2:	75 38                	jne    f010381c <__umoddi3+0x7c>
f01037e4:	39 dd                	cmp    %ebx,%ebp
f01037e6:	72 04                	jb     f01037ec <__umoddi3+0x4c>
f01037e8:	39 f7                	cmp    %esi,%edi
f01037ea:	77 dd                	ja     f01037c9 <__umoddi3+0x29>
f01037ec:	89 da                	mov    %ebx,%edx
f01037ee:	89 f0                	mov    %esi,%eax
f01037f0:	29 f8                	sub    %edi,%eax
f01037f2:	19 ea                	sbb    %ebp,%edx
f01037f4:	83 c4 1c             	add    $0x1c,%esp
f01037f7:	5b                   	pop    %ebx
f01037f8:	5e                   	pop    %esi
f01037f9:	5f                   	pop    %edi
f01037fa:	5d                   	pop    %ebp
f01037fb:	c3                   	ret    
f01037fc:	89 f9                	mov    %edi,%ecx
f01037fe:	85 ff                	test   %edi,%edi
f0103800:	75 0b                	jne    f010380d <__umoddi3+0x6d>
f0103802:	b8 01 00 00 00       	mov    $0x1,%eax
f0103807:	31 d2                	xor    %edx,%edx
f0103809:	f7 f7                	div    %edi
f010380b:	89 c1                	mov    %eax,%ecx
f010380d:	89 d8                	mov    %ebx,%eax
f010380f:	31 d2                	xor    %edx,%edx
f0103811:	f7 f1                	div    %ecx
f0103813:	89 f0                	mov    %esi,%eax
f0103815:	f7 f1                	div    %ecx
f0103817:	eb ac                	jmp    f01037c5 <__umoddi3+0x25>
f0103819:	8d 76 00             	lea    0x0(%esi),%esi
f010381c:	b8 20 00 00 00       	mov    $0x20,%eax
f0103821:	89 c2                	mov    %eax,%edx
f0103823:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103827:	29 c2                	sub    %eax,%edx
f0103829:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010382d:	88 c1                	mov    %al,%cl
f010382f:	d3 e5                	shl    %cl,%ebp
f0103831:	89 f8                	mov    %edi,%eax
f0103833:	88 d1                	mov    %dl,%cl
f0103835:	d3 e8                	shr    %cl,%eax
f0103837:	09 c5                	or     %eax,%ebp
f0103839:	8b 44 24 04          	mov    0x4(%esp),%eax
f010383d:	88 c1                	mov    %al,%cl
f010383f:	d3 e7                	shl    %cl,%edi
f0103841:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0103845:	89 df                	mov    %ebx,%edi
f0103847:	88 d1                	mov    %dl,%cl
f0103849:	d3 ef                	shr    %cl,%edi
f010384b:	88 c1                	mov    %al,%cl
f010384d:	d3 e3                	shl    %cl,%ebx
f010384f:	89 f0                	mov    %esi,%eax
f0103851:	88 d1                	mov    %dl,%cl
f0103853:	d3 e8                	shr    %cl,%eax
f0103855:	09 d8                	or     %ebx,%eax
f0103857:	8a 4c 24 04          	mov    0x4(%esp),%cl
f010385b:	d3 e6                	shl    %cl,%esi
f010385d:	89 fa                	mov    %edi,%edx
f010385f:	f7 f5                	div    %ebp
f0103861:	89 d1                	mov    %edx,%ecx
f0103863:	f7 64 24 08          	mull   0x8(%esp)
f0103867:	89 c3                	mov    %eax,%ebx
f0103869:	89 d7                	mov    %edx,%edi
f010386b:	39 d1                	cmp    %edx,%ecx
f010386d:	72 29                	jb     f0103898 <__umoddi3+0xf8>
f010386f:	74 23                	je     f0103894 <__umoddi3+0xf4>
f0103871:	89 ca                	mov    %ecx,%edx
f0103873:	29 de                	sub    %ebx,%esi
f0103875:	19 fa                	sbb    %edi,%edx
f0103877:	89 d0                	mov    %edx,%eax
f0103879:	8a 4c 24 0c          	mov    0xc(%esp),%cl
f010387d:	d3 e0                	shl    %cl,%eax
f010387f:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0103883:	88 d9                	mov    %bl,%cl
f0103885:	d3 ee                	shr    %cl,%esi
f0103887:	09 f0                	or     %esi,%eax
f0103889:	d3 ea                	shr    %cl,%edx
f010388b:	83 c4 1c             	add    $0x1c,%esp
f010388e:	5b                   	pop    %ebx
f010388f:	5e                   	pop    %esi
f0103890:	5f                   	pop    %edi
f0103891:	5d                   	pop    %ebp
f0103892:	c3                   	ret    
f0103893:	90                   	nop
f0103894:	39 c6                	cmp    %eax,%esi
f0103896:	73 d9                	jae    f0103871 <__umoddi3+0xd1>
f0103898:	2b 44 24 08          	sub    0x8(%esp),%eax
f010389c:	19 ea                	sbb    %ebp,%edx
f010389e:	89 d7                	mov    %edx,%edi
f01038a0:	89 c3                	mov    %eax,%ebx
f01038a2:	eb cd                	jmp    f0103871 <__umoddi3+0xd1>
