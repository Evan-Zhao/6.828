
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
f0100015:	b8 00 70 11 00       	mov    $0x117000,%eax
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
f0100034:	bc 00 70 11 f0       	mov    $0xf0117000,%esp

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
f010004b:	68 c0 3d 10 f0       	push   $0xf0103dc0
f0100050:	e8 6e 2d 00 00       	call   f0102dc3 <cprintf>
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
f0100065:	e8 60 0b 00 00       	call   f0100bca <mon_backtrace>
f010006a:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010006d:	83 ec 08             	sub    $0x8,%esp
f0100070:	53                   	push   %ebx
f0100071:	68 dc 3d 10 f0       	push   $0xf0103ddc
f0100076:	e8 48 2d 00 00       	call   f0102dc3 <cprintf>
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
f010009a:	b8 70 99 11 f0       	mov    $0xf0119970,%eax
f010009f:	2d 00 93 11 f0       	sub    $0xf0119300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 93 11 f0       	push   $0xf0119300
f01000ac:	e8 41 38 00 00       	call   f01038f2 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 d8 04 00 00       	call   f010058e <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 f7 3d 10 f0       	push   $0xf0103df7
f01000c3:	e8 fb 2c 00 00       	call   f0102dc3 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000c8:	e8 84 14 00 00       	call   f0101551 <mem_init>
	cprintf(ANSI_COLOR_RED     "This text is RED!"     ANSI_COLOR_RESET "\n");
f01000cd:	c7 04 24 12 3e 10 f0 	movl   $0xf0103e12,(%esp)
f01000d4:	e8 ea 2c 00 00       	call   f0102dc3 <cprintf>
	cprintf(ANSI_COLOR_GREEN   "This text is GREEN!"   ANSI_COLOR_RESET "\n");
f01000d9:	c7 04 24 2e 3e 10 f0 	movl   $0xf0103e2e,(%esp)
f01000e0:	e8 de 2c 00 00       	call   f0102dc3 <cprintf>
	cprintf(ANSI_COLOR_YELLOW  "This text is YELLOW!"  ANSI_COLOR_RESET "\n");
f01000e5:	c7 04 24 b8 3e 10 f0 	movl   $0xf0103eb8,(%esp)
f01000ec:	e8 d2 2c 00 00       	call   f0102dc3 <cprintf>
	cprintf(ANSI_COLOR_BLUE    "This text is BLUE!"    ANSI_COLOR_RESET "\n");
f01000f1:	c7 04 24 4c 3e 10 f0 	movl   $0xf0103e4c,(%esp)
f01000f8:	e8 c6 2c 00 00       	call   f0102dc3 <cprintf>
	cprintf(ANSI_COLOR_MAGENTA "This text is MAGENTA!" ANSI_COLOR_RESET "\n");
f01000fd:	c7 04 24 d8 3e 10 f0 	movl   $0xf0103ed8,(%esp)
f0100104:	e8 ba 2c 00 00       	call   f0102dc3 <cprintf>
	cprintf(ANSI_COLOR_CYAN    "This text is CYAN!"    ANSI_COLOR_RESET "\n");
f0100109:	c7 04 24 69 3e 10 f0 	movl   $0xf0103e69,(%esp)
f0100110:	e8 ae 2c 00 00       	call   f0102dc3 <cprintf>

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
f0100129:	e8 40 0b 00 00       	call   f0100c6e <monitor>
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
f010013b:	83 3d 60 99 11 f0 00 	cmpl   $0x0,0xf0119960
f0100142:	74 0f                	je     f0100153 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100144:	83 ec 0c             	sub    $0xc,%esp
f0100147:	6a 00                	push   $0x0
f0100149:	e8 20 0b 00 00       	call   f0100c6e <monitor>
f010014e:	83 c4 10             	add    $0x10,%esp
f0100151:	eb f1                	jmp    f0100144 <_panic+0x11>
	panicstr = fmt;
f0100153:	89 35 60 99 11 f0    	mov    %esi,0xf0119960
	asm volatile("cli; cld");
f0100159:	fa                   	cli    
f010015a:	fc                   	cld    
	va_start(ap, fmt);
f010015b:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f010015e:	83 ec 04             	sub    $0x4,%esp
f0100161:	ff 75 0c             	pushl  0xc(%ebp)
f0100164:	ff 75 08             	pushl  0x8(%ebp)
f0100167:	68 86 3e 10 f0       	push   $0xf0103e86
f010016c:	e8 52 2c 00 00       	call   f0102dc3 <cprintf>
	vcprintf(fmt, ap);
f0100171:	83 c4 08             	add    $0x8,%esp
f0100174:	53                   	push   %ebx
f0100175:	56                   	push   %esi
f0100176:	e8 22 2c 00 00       	call   f0102d9d <vcprintf>
	cprintf("\n");
f010017b:	c7 04 24 1b 42 10 f0 	movl   $0xf010421b,(%esp)
f0100182:	e8 3c 2c 00 00       	call   f0102dc3 <cprintf>
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
f010019c:	68 9e 3e 10 f0       	push   $0xf0103e9e
f01001a1:	e8 1d 2c 00 00       	call   f0102dc3 <cprintf>
	vcprintf(fmt, ap);
f01001a6:	83 c4 08             	add    $0x8,%esp
f01001a9:	53                   	push   %ebx
f01001aa:	ff 75 10             	pushl  0x10(%ebp)
f01001ad:	e8 eb 2b 00 00       	call   f0102d9d <vcprintf>
	cprintf("\n");
f01001b2:	c7 04 24 1b 42 10 f0 	movl   $0xf010421b,(%esp)
f01001b9:	e8 05 2c 00 00       	call   f0102dc3 <cprintf>
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
f01001f9:	8b 0d 24 95 11 f0    	mov    0xf0119524,%ecx
f01001ff:	8d 51 01             	lea    0x1(%ecx),%edx
f0100202:	89 15 24 95 11 f0    	mov    %edx,0xf0119524
f0100208:	88 81 20 93 11 f0    	mov    %al,-0xfee6ce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010020e:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100214:	75 d8                	jne    f01001ee <cons_intr+0x9>
			cons.wpos = 0;
f0100216:	c7 05 24 95 11 f0 00 	movl   $0x0,0xf0119524
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
f010025d:	8b 0d 00 93 11 f0    	mov    0xf0119300,%ecx
f0100263:	f6 c1 40             	test   $0x40,%cl
f0100266:	74 0e                	je     f0100276 <kbd_proc_data+0x4e>
		data |= 0x80;
f0100268:	83 c8 80             	or     $0xffffff80,%eax
f010026b:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f010026d:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100270:	89 0d 00 93 11 f0    	mov    %ecx,0xf0119300
	shift |= shiftcode[data];
f0100276:	0f b6 d2             	movzbl %dl,%edx
f0100279:	0f b6 82 60 40 10 f0 	movzbl -0xfefbfa0(%edx),%eax
f0100280:	0b 05 00 93 11 f0    	or     0xf0119300,%eax
	shift ^= togglecode[data];
f0100286:	0f b6 8a 60 3f 10 f0 	movzbl -0xfefc0a0(%edx),%ecx
f010028d:	31 c8                	xor    %ecx,%eax
f010028f:	a3 00 93 11 f0       	mov    %eax,0xf0119300
	c = charcode[shift & (CTL | SHIFT)][data];
f0100294:	89 c1                	mov    %eax,%ecx
f0100296:	83 e1 03             	and    $0x3,%ecx
f0100299:	8b 0c 8d 40 3f 10 f0 	mov    -0xfefc0c0(,%ecx,4),%ecx
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
f01002c8:	68 f8 3e 10 f0       	push   $0xf0103ef8
f01002cd:	e8 f1 2a 00 00       	call   f0102dc3 <cprintf>
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
f01002df:	83 0d 00 93 11 f0 40 	orl    $0x40,0xf0119300
		return 0;
f01002e6:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f01002eb:	89 d8                	mov    %ebx,%eax
f01002ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002f0:	c9                   	leave  
f01002f1:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002f2:	8b 0d 00 93 11 f0    	mov    0xf0119300,%ecx
f01002f8:	f6 c1 40             	test   $0x40,%cl
f01002fb:	75 05                	jne    f0100302 <kbd_proc_data+0xda>
f01002fd:	83 e0 7f             	and    $0x7f,%eax
f0100300:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f0100302:	0f b6 d2             	movzbl %dl,%edx
f0100305:	8a 82 60 40 10 f0    	mov    -0xfefbfa0(%edx),%al
f010030b:	83 c8 40             	or     $0x40,%eax
f010030e:	0f b6 c0             	movzbl %al,%eax
f0100311:	f7 d0                	not    %eax
f0100313:	21 c8                	and    %ecx,%eax
f0100315:	a3 00 93 11 f0       	mov    %eax,0xf0119300
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
f01003db:	66 8b 0d 28 95 11 f0 	mov    0xf0119528,%cx
f01003e2:	bb 50 00 00 00       	mov    $0x50,%ebx
f01003e7:	89 c8                	mov    %ecx,%eax
f01003e9:	ba 00 00 00 00       	mov    $0x0,%edx
f01003ee:	66 f7 f3             	div    %bx
f01003f1:	29 d1                	sub    %edx,%ecx
f01003f3:	66 89 0d 28 95 11 f0 	mov    %cx,0xf0119528
	if (crt_pos >= CRT_SIZE) {
f01003fa:	66 81 3d 28 95 11 f0 	cmpw   $0x7cf,0xf0119528
f0100401:	cf 07 
f0100403:	0f 87 c5 00 00 00    	ja     f01004ce <cons_putc+0x192>
	outb(addr_6845, 14);
f0100409:	8b 0d 30 95 11 f0    	mov    0xf0119530,%ecx
f010040f:	b0 0e                	mov    $0xe,%al
f0100411:	89 ca                	mov    %ecx,%edx
f0100413:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100414:	8d 59 01             	lea    0x1(%ecx),%ebx
f0100417:	66 a1 28 95 11 f0    	mov    0xf0119528,%ax
f010041d:	66 c1 e8 08          	shr    $0x8,%ax
f0100421:	89 da                	mov    %ebx,%edx
f0100423:	ee                   	out    %al,(%dx)
f0100424:	b0 0f                	mov    $0xf,%al
f0100426:	89 ca                	mov    %ecx,%edx
f0100428:	ee                   	out    %al,(%dx)
f0100429:	a0 28 95 11 f0       	mov    0xf0119528,%al
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
f010043e:	66 a1 28 95 11 f0    	mov    0xf0119528,%ax
f0100444:	66 85 c0             	test   %ax,%ax
f0100447:	74 c0                	je     f0100409 <cons_putc+0xcd>
			crt_pos--;
f0100449:	48                   	dec    %eax
f010044a:	66 a3 28 95 11 f0    	mov    %ax,0xf0119528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100450:	0f b7 c0             	movzwl %ax,%eax
f0100453:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f0100459:	83 cf 20             	or     $0x20,%edi
f010045c:	8b 15 2c 95 11 f0    	mov    0xf011952c,%edx
f0100462:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100466:	eb 92                	jmp    f01003fa <cons_putc+0xbe>
		crt_pos += CRT_COLS;
f0100468:	66 83 05 28 95 11 f0 	addw   $0x50,0xf0119528
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
f01004ac:	66 a1 28 95 11 f0    	mov    0xf0119528,%ax
f01004b2:	8d 50 01             	lea    0x1(%eax),%edx
f01004b5:	66 89 15 28 95 11 f0 	mov    %dx,0xf0119528
f01004bc:	0f b7 c0             	movzwl %ax,%eax
f01004bf:	8b 15 2c 95 11 f0    	mov    0xf011952c,%edx
f01004c5:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004c9:	e9 2c ff ff ff       	jmp    f01003fa <cons_putc+0xbe>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004ce:	a1 2c 95 11 f0       	mov    0xf011952c,%eax
f01004d3:	83 ec 04             	sub    $0x4,%esp
f01004d6:	68 00 0f 00 00       	push   $0xf00
f01004db:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004e1:	52                   	push   %edx
f01004e2:	50                   	push   %eax
f01004e3:	e8 57 34 00 00       	call   f010393f <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01004e8:	8b 15 2c 95 11 f0    	mov    0xf011952c,%edx
f01004ee:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01004f4:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01004fa:	83 c4 10             	add    $0x10,%esp
f01004fd:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100502:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100505:	39 d0                	cmp    %edx,%eax
f0100507:	75 f4                	jne    f01004fd <cons_putc+0x1c1>
		crt_pos -= CRT_COLS;
f0100509:	66 83 2d 28 95 11 f0 	subw   $0x50,0xf0119528
f0100510:	50 
f0100511:	e9 f3 fe ff ff       	jmp    f0100409 <cons_putc+0xcd>

f0100516 <serial_intr>:
	if (serial_exists)
f0100516:	80 3d 34 95 11 f0 00 	cmpb   $0x0,0xf0119534
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
f0100554:	a1 20 95 11 f0       	mov    0xf0119520,%eax
f0100559:	3b 05 24 95 11 f0    	cmp    0xf0119524,%eax
f010055f:	74 26                	je     f0100587 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100561:	8d 50 01             	lea    0x1(%eax),%edx
f0100564:	89 15 20 95 11 f0    	mov    %edx,0xf0119520
f010056a:	0f b6 80 20 93 11 f0 	movzbl -0xfee6ce0(%eax),%eax
		if (cons.rpos == CONSBUFSIZE)
f0100571:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100577:	74 02                	je     f010057b <cons_getc+0x37>
}
f0100579:	c9                   	leave  
f010057a:	c3                   	ret    
			cons.rpos = 0;
f010057b:	c7 05 20 95 11 f0 00 	movl   $0x0,0xf0119520
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
f01005b7:	c7 05 30 95 11 f0 b4 	movl   $0x3b4,0xf0119530
f01005be:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005c1:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f01005c6:	8b 3d 30 95 11 f0    	mov    0xf0119530,%edi
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
f01005e7:	89 35 2c 95 11 f0    	mov    %esi,0xf011952c
	pos |= inb(addr_6845 + 1);
f01005ed:	0f b6 c0             	movzbl %al,%eax
f01005f0:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01005f2:	66 a3 28 95 11 f0    	mov    %ax,0xf0119528
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
f010063c:	0f 95 05 34 95 11 f0 	setne  0xf0119534
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
f0100660:	c7 05 30 95 11 f0 d4 	movl   $0x3d4,0xf0119530
f0100667:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010066a:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f010066f:	e9 52 ff ff ff       	jmp    f01005c6 <cons_init+0x38>
		cprintf("Serial port does not exist!\n");
f0100674:	83 ec 0c             	sub    $0xc,%esp
f0100677:	68 04 3f 10 f0       	push   $0xf0103f04
f010067c:	e8 42 27 00 00       	call   f0102dc3 <cprintf>
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
f01006b4:	53                   	push   %ebx
f01006b5:	83 ec 04             	sub    $0x4,%esp
f01006b8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006bd:	83 ec 04             	sub    $0x4,%esp
f01006c0:	ff b3 64 46 10 f0    	pushl  -0xfefb99c(%ebx)
f01006c6:	ff b3 60 46 10 f0    	pushl  -0xfefb9a0(%ebx)
f01006cc:	68 60 41 10 f0       	push   $0xf0104160
f01006d1:	e8 ed 26 00 00       	call   f0102dc3 <cprintf>
f01006d6:	83 c3 0c             	add    $0xc,%ebx
	for (i = 0; i < ARRAY_SIZE(commands); i++)
f01006d9:	83 c4 10             	add    $0x10,%esp
f01006dc:	83 fb 3c             	cmp    $0x3c,%ebx
f01006df:	75 dc                	jne    f01006bd <mon_help+0xc>
	return 0;
}
f01006e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01006e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01006e9:	c9                   	leave  
f01006ea:	c3                   	ret    

f01006eb <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006eb:	55                   	push   %ebp
f01006ec:	89 e5                	mov    %esp,%ebp
f01006ee:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006f1:	68 69 41 10 f0       	push   $0xf0104169
f01006f6:	e8 c8 26 00 00       	call   f0102dc3 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006fb:	83 c4 08             	add    $0x8,%esp
f01006fe:	68 0c 00 10 00       	push   $0x10000c
f0100703:	68 c0 42 10 f0       	push   $0xf01042c0
f0100708:	e8 b6 26 00 00       	call   f0102dc3 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010070d:	83 c4 0c             	add    $0xc,%esp
f0100710:	68 0c 00 10 00       	push   $0x10000c
f0100715:	68 0c 00 10 f0       	push   $0xf010000c
f010071a:	68 e8 42 10 f0       	push   $0xf01042e8
f010071f:	e8 9f 26 00 00       	call   f0102dc3 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100724:	83 c4 0c             	add    $0xc,%esp
f0100727:	68 a4 3d 10 00       	push   $0x103da4
f010072c:	68 a4 3d 10 f0       	push   $0xf0103da4
f0100731:	68 0c 43 10 f0       	push   $0xf010430c
f0100736:	e8 88 26 00 00       	call   f0102dc3 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010073b:	83 c4 0c             	add    $0xc,%esp
f010073e:	68 00 93 11 00       	push   $0x119300
f0100743:	68 00 93 11 f0       	push   $0xf0119300
f0100748:	68 30 43 10 f0       	push   $0xf0104330
f010074d:	e8 71 26 00 00       	call   f0102dc3 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100752:	83 c4 0c             	add    $0xc,%esp
f0100755:	68 70 99 11 00       	push   $0x119970
f010075a:	68 70 99 11 f0       	push   $0xf0119970
f010075f:	68 54 43 10 f0       	push   $0xf0104354
f0100764:	e8 5a 26 00 00       	call   f0102dc3 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100769:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010076c:	b8 6f 9d 11 f0       	mov    $0xf0119d6f,%eax
f0100771:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100776:	c1 f8 0a             	sar    $0xa,%eax
f0100779:	50                   	push   %eax
f010077a:	68 78 43 10 f0       	push   $0xf0104378
f010077f:	e8 3f 26 00 00       	call   f0102dc3 <cprintf>
	return 0;
}
f0100784:	b8 00 00 00 00       	mov    $0x0,%eax
f0100789:	c9                   	leave  
f010078a:	c3                   	ret    

f010078b <mon_showmap>:
	}
	return 0;
}

int 
mon_showmap(int argc, char **argv, struct Trapframe *tf) {
f010078b:	55                   	push   %ebp
f010078c:	89 e5                	mov    %esp,%ebp
f010078e:	56                   	push   %esi
f010078f:	53                   	push   %ebx
f0100790:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc <= 2) {
f0100793:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100797:	7e 3c                	jle    f01007d5 <mon_showmap+0x4a>
		cprintf("Usage: showmap l r\n");
		return 0;
	}
	uintptr_t l = strtoul(argv[1], NULL, 0), 
f0100799:	83 ec 04             	sub    $0x4,%esp
f010079c:	6a 00                	push   $0x0
f010079e:	6a 00                	push   $0x0
f01007a0:	ff 76 04             	pushl  0x4(%esi)
f01007a3:	e8 2b 33 00 00       	call   f0103ad3 <strtoul>
f01007a8:	89 c3                	mov    %eax,%ebx
		 	  r = strtoul(argv[2], NULL, 0); // In string.h
f01007aa:	83 c4 0c             	add    $0xc,%esp
f01007ad:	6a 00                	push   $0x0
f01007af:	6a 00                	push   $0x0
f01007b1:	ff 76 08             	pushl  0x8(%esi)
f01007b4:	e8 1a 33 00 00       	call   f0103ad3 <strtoul>
	if (l > r) {
f01007b9:	83 c4 10             	add    $0x10,%esp
f01007bc:	39 c3                	cmp    %eax,%ebx
f01007be:	77 31                	ja     f01007f1 <mon_showmap+0x66>
		cprintf("Invalid range; aborting.\n");
		return 0;
	}
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f01007c0:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f01007c6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f01007cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01007d1:	89 c6                	mov    %eax,%esi
f01007d3:	eb 45                	jmp    f010081a <mon_showmap+0x8f>
		cprintf("Usage: showmap l r\n");
f01007d5:	83 ec 0c             	sub    $0xc,%esp
f01007d8:	68 82 41 10 f0       	push   $0xf0104182
f01007dd:	e8 e1 25 00 00       	call   f0102dc3 <cprintf>
		return 0;
f01007e2:	83 c4 10             	add    $0x10,%esp
		else 
			cprintf("0x%08x -> 0x%08x; perm = 0x%03x\n", 
					sz, PTE_ADDR(*pte), *pte & 0xFFF);
	}
	return 0;
}
f01007e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007ed:	5b                   	pop    %ebx
f01007ee:	5e                   	pop    %esi
f01007ef:	5d                   	pop    %ebp
f01007f0:	c3                   	ret    
		cprintf("Invalid range; aborting.\n");
f01007f1:	83 ec 0c             	sub    $0xc,%esp
f01007f4:	68 96 41 10 f0       	push   $0xf0104196
f01007f9:	e8 c5 25 00 00       	call   f0102dc3 <cprintf>
		return 0;
f01007fe:	83 c4 10             	add    $0x10,%esp
f0100801:	eb e2                	jmp    f01007e5 <mon_showmap+0x5a>
			cprintf("0x%08x -> ----------; perm = ---\n", sz);
f0100803:	83 ec 08             	sub    $0x8,%esp
f0100806:	53                   	push   %ebx
f0100807:	68 a4 43 10 f0       	push   $0xf01043a4
f010080c:	e8 b2 25 00 00       	call   f0102dc3 <cprintf>
f0100811:	83 c4 10             	add    $0x10,%esp
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f0100814:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010081a:	39 f3                	cmp    %esi,%ebx
f010081c:	77 c7                	ja     f01007e5 <mon_showmap+0x5a>
		pte_t* pte = pgdir_walk(kern_pgdir, (void*) sz, 0);
f010081e:	83 ec 04             	sub    $0x4,%esp
f0100821:	6a 00                	push   $0x0
f0100823:	53                   	push   %ebx
f0100824:	ff 35 68 99 11 f0    	pushl  0xf0119968
f010082a:	e8 a7 0a 00 00       	call   f01012d6 <pgdir_walk>
		if (pte == NULL || !*pte)
f010082f:	83 c4 10             	add    $0x10,%esp
f0100832:	85 c0                	test   %eax,%eax
f0100834:	74 cd                	je     f0100803 <mon_showmap+0x78>
f0100836:	8b 00                	mov    (%eax),%eax
f0100838:	85 c0                	test   %eax,%eax
f010083a:	74 c7                	je     f0100803 <mon_showmap+0x78>
			cprintf("0x%08x -> 0x%08x; perm = 0x%03x\n", 
f010083c:	89 c2                	mov    %eax,%edx
f010083e:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f0100844:	52                   	push   %edx
f0100845:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010084a:	50                   	push   %eax
f010084b:	53                   	push   %ebx
f010084c:	68 c8 43 10 f0       	push   $0xf01043c8
f0100851:	e8 6d 25 00 00       	call   f0102dc3 <cprintf>
f0100856:	83 c4 10             	add    $0x10,%esp
f0100859:	eb b9                	jmp    f0100814 <mon_showmap+0x89>

f010085b <mon_chmod>:

int
mon_chmod(int argc, char **argv, struct Trapframe *tf) {
f010085b:	55                   	push   %ebp
f010085c:	89 e5                	mov    %esp,%ebp
f010085e:	57                   	push   %edi
f010085f:	56                   	push   %esi
f0100860:	53                   	push   %ebx
f0100861:	83 ec 1c             	sub    $0x1c,%esp
f0100864:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc <= 2) {
f0100867:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f010086b:	7e 67                	jle    f01008d4 <mon_chmod+0x79>
		cprintf("Usage: chmod mod l [r] [-v]\n");
		return 0;
	}
	uintptr_t mod = strtoul(argv[1], NULL, 0),  
f010086d:	83 ec 04             	sub    $0x4,%esp
f0100870:	6a 00                	push   $0x0
f0100872:	6a 00                	push   $0x0
f0100874:	ff 76 04             	pushl  0x4(%esi)
f0100877:	e8 57 32 00 00       	call   f0103ad3 <strtoul>
f010087c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			  l = strtoul(argv[2], NULL, 0), 
f010087f:	83 c4 0c             	add    $0xc,%esp
f0100882:	6a 00                	push   $0x0
f0100884:	6a 00                	push   $0x0
f0100886:	ff 76 08             	pushl  0x8(%esi)
f0100889:	e8 45 32 00 00       	call   f0103ad3 <strtoul>
f010088e:	89 c3                	mov    %eax,%ebx
			  r = argc >= 4 ? strtoul(argv[3], NULL, 0) : l;
f0100890:	83 c4 10             	add    $0x10,%esp
f0100893:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100897:	7f 58                	jg     f01008f1 <mon_chmod+0x96>
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
	if (mod > 0xFFF) {
f0100899:	81 7d e4 ff 0f 00 00 	cmpl   $0xfff,-0x1c(%ebp)
f01008a0:	0f 87 9a 00 00 00    	ja     f0100940 <mon_chmod+0xe5>
			  r = argc >= 4 ? strtoul(argv[3], NULL, 0) : l;
f01008a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
f01008a9:	bf 00 00 00 00       	mov    $0x0,%edi
	}
	if (l > r) {
		cprintf("Invalid range; aborting.\n");
		return 0;
	}
	if (!(mod & PTE_P)) {
f01008ae:	f6 45 e4 01          	testb  $0x1,-0x1c(%ebp)
f01008b2:	0f 84 9a 00 00 00    	je     f0100952 <mon_chmod+0xf7>
		cprintf("Warning: PTE_P flag is not provided; added automatically.");
		mod |= PTE_P;
	}
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f01008b8:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f01008be:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f01008c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01008c7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01008cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01008cf:	e9 a1 00 00 00       	jmp    f0100975 <mon_chmod+0x11a>
		cprintf("Usage: chmod mod l [r] [-v]\n");
f01008d4:	83 ec 0c             	sub    $0xc,%esp
f01008d7:	68 b0 41 10 f0       	push   $0xf01041b0
f01008dc:	e8 e2 24 00 00       	call   f0102dc3 <cprintf>
		return 0;
f01008e1:	83 c4 10             	add    $0x10,%esp
						sz, *pte & 0xFFF, mod);
			*pte = PTE_ADDR(*pte) | mod;
		}
	}
	return 0;
}
f01008e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01008e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008ec:	5b                   	pop    %ebx
f01008ed:	5e                   	pop    %esi
f01008ee:	5f                   	pop    %edi
f01008ef:	5d                   	pop    %ebp
f01008f0:	c3                   	ret    
			  r = argc >= 4 ? strtoul(argv[3], NULL, 0) : l;
f01008f1:	83 ec 04             	sub    $0x4,%esp
f01008f4:	6a 00                	push   $0x0
f01008f6:	6a 00                	push   $0x0
f01008f8:	ff 76 0c             	pushl  0xc(%esi)
f01008fb:	e8 d3 31 00 00       	call   f0103ad3 <strtoul>
f0100900:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
f0100903:	83 c4 08             	add    $0x8,%esp
f0100906:	68 cd 41 10 f0       	push   $0xf01041cd
f010090b:	ff 76 0c             	pushl  0xc(%esi)
f010090e:	e8 56 2f 00 00       	call   f0103869 <strcmp>
f0100913:	83 c4 10             	add    $0x10,%esp
f0100916:	85 c0                	test   %eax,%eax
f0100918:	0f 94 c0             	sete   %al
f010091b:	0f b6 c0             	movzbl %al,%eax
f010091e:	89 c7                	mov    %eax,%edi
	if (mod > 0xFFF) {
f0100920:	81 7d e4 ff 0f 00 00 	cmpl   $0xfff,-0x1c(%ebp)
f0100927:	77 17                	ja     f0100940 <mon_chmod+0xe5>
	if (l > r) {
f0100929:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f010092c:	76 80                	jbe    f01008ae <mon_chmod+0x53>
		cprintf("Invalid range; aborting.\n");
f010092e:	83 ec 0c             	sub    $0xc,%esp
f0100931:	68 96 41 10 f0       	push   $0xf0104196
f0100936:	e8 88 24 00 00       	call   f0102dc3 <cprintf>
		return 0;
f010093b:	83 c4 10             	add    $0x10,%esp
f010093e:	eb a4                	jmp    f01008e4 <mon_chmod+0x89>
		cprintf("Permission exceeds 0xfff; aborting.\n");
f0100940:	83 ec 0c             	sub    $0xc,%esp
f0100943:	68 ec 43 10 f0       	push   $0xf01043ec
f0100948:	e8 76 24 00 00       	call   f0102dc3 <cprintf>
		return 0;
f010094d:	83 c4 10             	add    $0x10,%esp
f0100950:	eb 92                	jmp    f01008e4 <mon_chmod+0x89>
		cprintf("Warning: PTE_P flag is not provided; added automatically.");
f0100952:	83 ec 0c             	sub    $0xc,%esp
f0100955:	68 14 44 10 f0       	push   $0xf0104414
f010095a:	e8 64 24 00 00       	call   f0102dc3 <cprintf>
		mod |= PTE_P;
f010095f:	83 4d e4 01          	orl    $0x1,-0x1c(%ebp)
f0100963:	83 c4 10             	add    $0x10,%esp
f0100966:	e9 4d ff ff ff       	jmp    f01008b8 <mon_chmod+0x5d>
			if (verbose)
f010096b:	85 ff                	test   %edi,%edi
f010096d:	75 41                	jne    f01009b0 <mon_chmod+0x155>
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f010096f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100975:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0100978:	0f 87 66 ff ff ff    	ja     f01008e4 <mon_chmod+0x89>
		pte_t* pte = pgdir_walk(kern_pgdir, (void*) sz, 0);
f010097e:	83 ec 04             	sub    $0x4,%esp
f0100981:	6a 00                	push   $0x0
f0100983:	53                   	push   %ebx
f0100984:	ff 35 68 99 11 f0    	pushl  0xf0119968
f010098a:	e8 47 09 00 00       	call   f01012d6 <pgdir_walk>
f010098f:	89 c6                	mov    %eax,%esi
		if (pte == NULL || !*pte) {
f0100991:	83 c4 10             	add    $0x10,%esp
f0100994:	85 c0                	test   %eax,%eax
f0100996:	74 d3                	je     f010096b <mon_chmod+0x110>
f0100998:	8b 00                	mov    (%eax),%eax
f010099a:	85 c0                	test   %eax,%eax
f010099c:	74 cd                	je     f010096b <mon_chmod+0x110>
			if (verbose) 
f010099e:	85 ff                	test   %edi,%edi
f01009a0:	75 21                	jne    f01009c3 <mon_chmod+0x168>
			*pte = PTE_ADDR(*pte) | mod;
f01009a2:	8b 06                	mov    (%esi),%eax
f01009a4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009a9:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01009ac:	89 06                	mov    %eax,(%esi)
f01009ae:	eb bf                	jmp    f010096f <mon_chmod+0x114>
				cprintf("Page va = 0x%08x is not mapped; skipping.\n", sz);
f01009b0:	83 ec 08             	sub    $0x8,%esp
f01009b3:	53                   	push   %ebx
f01009b4:	68 50 44 10 f0       	push   $0xf0104450
f01009b9:	e8 05 24 00 00       	call   f0102dc3 <cprintf>
f01009be:	83 c4 10             	add    $0x10,%esp
f01009c1:	eb ac                	jmp    f010096f <mon_chmod+0x114>
				cprintf("Page va = 0x%08x perm = 0x%03x changed to 0x%03x\n", 
f01009c3:	ff 75 e4             	pushl  -0x1c(%ebp)
f01009c6:	25 ff 0f 00 00       	and    $0xfff,%eax
f01009cb:	50                   	push   %eax
f01009cc:	53                   	push   %ebx
f01009cd:	68 7c 44 10 f0       	push   $0xf010447c
f01009d2:	e8 ec 23 00 00       	call   f0102dc3 <cprintf>
f01009d7:	83 c4 10             	add    $0x10,%esp
f01009da:	eb c6                	jmp    f01009a2 <mon_chmod+0x147>

f01009dc <mon_dump>:

int
mon_dump(int argc, char **argv, struct Trapframe *tf) {
f01009dc:	55                   	push   %ebp
f01009dd:	89 e5                	mov    %esp,%ebp
f01009df:	57                   	push   %edi
f01009e0:	56                   	push   %esi
f01009e1:	53                   	push   %ebx
f01009e2:	83 ec 1c             	sub    $0x1c,%esp
f01009e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (argc <= 2 || argc > 4) {
f01009e8:	8d 43 fd             	lea    -0x3(%ebx),%eax
f01009eb:	83 f8 01             	cmp    $0x1,%eax
f01009ee:	76 1d                	jbe    f0100a0d <mon_dump+0x31>
		cprintf("Usage: dump l r [-v/-p]\n");
f01009f0:	83 ec 0c             	sub    $0xc,%esp
f01009f3:	68 d0 41 10 f0       	push   $0xf01041d0
f01009f8:	e8 c6 23 00 00       	call   f0102dc3 <cprintf>
		return 0;
f01009fd:	83 c4 10             	add    $0x10,%esp
		cprintf("|\n");
	}
	if (ROUNDDOWN(r, 16) != r)
		cprintf("%08x  \n", r);
	return 0;
}
f0100a00:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a05:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a08:	5b                   	pop    %ebx
f0100a09:	5e                   	pop    %esi
f0100a0a:	5f                   	pop    %edi
f0100a0b:	5d                   	pop    %ebp
f0100a0c:	c3                   	ret    
	unsigned long l = strtoul(argv[1], NULL, 0),
f0100a0d:	83 ec 04             	sub    $0x4,%esp
f0100a10:	6a 00                	push   $0x0
f0100a12:	6a 00                	push   $0x0
f0100a14:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a17:	ff 70 04             	pushl  0x4(%eax)
f0100a1a:	e8 b4 30 00 00       	call   f0103ad3 <strtoul>
f0100a1f:	89 c6                	mov    %eax,%esi
			  	  r = strtoul(argv[2], NULL, 0);
f0100a21:	83 c4 0c             	add    $0xc,%esp
f0100a24:	6a 00                	push   $0x0
f0100a26:	6a 00                	push   $0x0
f0100a28:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a2b:	ff 70 08             	pushl  0x8(%eax)
f0100a2e:	e8 a0 30 00 00       	call   f0103ad3 <strtoul>
f0100a33:	89 c7                	mov    %eax,%edi
	if (argc <= 3)
f0100a35:	83 c4 10             	add    $0x10,%esp
f0100a38:	83 fb 03             	cmp    $0x3,%ebx
f0100a3b:	7f 18                	jg     f0100a55 <mon_dump+0x79>
		cprintf("Defaulting to virtual address.\n");
f0100a3d:	83 ec 0c             	sub    $0xc,%esp
f0100a40:	68 b0 44 10 f0       	push   $0xf01044b0
f0100a45:	e8 79 23 00 00       	call   f0102dc3 <cprintf>
f0100a4a:	83 c4 10             	add    $0x10,%esp
	for (ptr = ROUNDDOWN(l, 16); ptr <= r; ptr += 16) {
f0100a4d:	83 e6 f0             	and    $0xfffffff0,%esi
f0100a50:	e9 31 01 00 00       	jmp    f0100b86 <mon_dump+0x1aa>
	else if (!strcmp(argv[3], "-p"))
f0100a55:	83 ec 08             	sub    $0x8,%esp
f0100a58:	68 e9 41 10 f0       	push   $0xf01041e9
f0100a5d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a60:	ff 70 0c             	pushl  0xc(%eax)
f0100a63:	e8 01 2e 00 00       	call   f0103869 <strcmp>
f0100a68:	83 c4 10             	add    $0x10,%esp
f0100a6b:	85 c0                	test   %eax,%eax
f0100a6d:	75 4f                	jne    f0100abe <mon_dump+0xe2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a6f:	a1 64 99 11 f0       	mov    0xf0119964,%eax
f0100a74:	89 f2                	mov    %esi,%edx
f0100a76:	c1 ea 0c             	shr    $0xc,%edx
f0100a79:	39 c2                	cmp    %eax,%edx
f0100a7b:	73 17                	jae    f0100a94 <mon_dump+0xb8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f0100a7d:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
	if (PGNUM(pa) >= npages)
f0100a83:	89 fa                	mov    %edi,%edx
f0100a85:	c1 ea 0c             	shr    $0xc,%edx
f0100a88:	39 c2                	cmp    %eax,%edx
f0100a8a:	73 1d                	jae    f0100aa9 <mon_dump+0xcd>
	return (void *)(pa + KERNBASE);
f0100a8c:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
f0100a92:	eb b9                	jmp    f0100a4d <mon_dump+0x71>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a94:	56                   	push   %esi
f0100a95:	68 d0 44 10 f0       	push   $0xf01044d0
f0100a9a:	68 9c 00 00 00       	push   $0x9c
f0100a9f:	68 ec 41 10 f0       	push   $0xf01041ec
f0100aa4:	e8 8a f6 ff ff       	call   f0100133 <_panic>
f0100aa9:	57                   	push   %edi
f0100aaa:	68 d0 44 10 f0       	push   $0xf01044d0
f0100aaf:	68 9c 00 00 00       	push   $0x9c
f0100ab4:	68 ec 41 10 f0       	push   $0xf01041ec
f0100ab9:	e8 75 f6 ff ff       	call   f0100133 <_panic>
	else if (strcmp(argv[3], "-v")) {
f0100abe:	83 ec 08             	sub    $0x8,%esp
f0100ac1:	68 cd 41 10 f0       	push   $0xf01041cd
f0100ac6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100ac9:	ff 70 0c             	pushl  0xc(%eax)
f0100acc:	e8 98 2d 00 00       	call   f0103869 <strcmp>
f0100ad1:	83 c4 10             	add    $0x10,%esp
f0100ad4:	85 c0                	test   %eax,%eax
f0100ad6:	0f 84 71 ff ff ff    	je     f0100a4d <mon_dump+0x71>
		cprintf("Unknown flag %s at position 3; aborting.\n", argv[3]);
f0100adc:	83 ec 08             	sub    $0x8,%esp
f0100adf:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100ae2:	ff 70 0c             	pushl  0xc(%eax)
f0100ae5:	68 f4 44 10 f0       	push   $0xf01044f4
f0100aea:	e8 d4 22 00 00       	call   f0102dc3 <cprintf>
		return 0;
f0100aef:	83 c4 10             	add    $0x10,%esp
f0100af2:	e9 09 ff ff ff       	jmp    f0100a00 <mon_dump+0x24>
				cprintf("   ");
f0100af7:	83 ec 0c             	sub    $0xc,%esp
f0100afa:	68 08 42 10 f0       	push   $0xf0104208
f0100aff:	e8 bf 22 00 00       	call   f0102dc3 <cprintf>
f0100b04:	83 c4 10             	add    $0x10,%esp
f0100b07:	43                   	inc    %ebx
		for (int i = 0; i < 16; i++) {
f0100b08:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0100b0b:	74 1a                	je     f0100b27 <mon_dump+0x14b>
			if (ptr + i <= r)
f0100b0d:	39 df                	cmp    %ebx,%edi
f0100b0f:	72 e6                	jb     f0100af7 <mon_dump+0x11b>
				cprintf("%02x ", *(unsigned char*)(ptr + i));
f0100b11:	83 ec 08             	sub    $0x8,%esp
f0100b14:	0f b6 03             	movzbl (%ebx),%eax
f0100b17:	50                   	push   %eax
f0100b18:	68 02 42 10 f0       	push   $0xf0104202
f0100b1d:	e8 a1 22 00 00       	call   f0102dc3 <cprintf>
f0100b22:	83 c4 10             	add    $0x10,%esp
f0100b25:	eb e0                	jmp    f0100b07 <mon_dump+0x12b>
		cprintf(" |");
f0100b27:	83 ec 0c             	sub    $0xc,%esp
f0100b2a:	68 0c 42 10 f0       	push   $0xf010420c
f0100b2f:	e8 8f 22 00 00       	call   f0102dc3 <cprintf>
f0100b34:	83 c4 10             	add    $0x10,%esp
f0100b37:	eb 19                	jmp    f0100b52 <mon_dump+0x176>
				cprintf("%c", (ch >= ' ' && ch <= '~') ? ch : '.');
f0100b39:	83 ec 08             	sub    $0x8,%esp
f0100b3c:	0f be c0             	movsbl %al,%eax
f0100b3f:	50                   	push   %eax
f0100b40:	68 0f 42 10 f0       	push   $0xf010420f
f0100b45:	e8 79 22 00 00       	call   f0102dc3 <cprintf>
f0100b4a:	83 c4 10             	add    $0x10,%esp
f0100b4d:	46                   	inc    %esi
		for (int i = 0; i < 16; i++) {
f0100b4e:	39 de                	cmp    %ebx,%esi
f0100b50:	74 24                	je     f0100b76 <mon_dump+0x19a>
			if (ptr + i <= r) {
f0100b52:	39 f7                	cmp    %esi,%edi
f0100b54:	72 0e                	jb     f0100b64 <mon_dump+0x188>
				char ch = *(char*)(ptr + i);
f0100b56:	8a 06                	mov    (%esi),%al
				cprintf("%c", (ch >= ' ' && ch <= '~') ? ch : '.');
f0100b58:	8d 50 e0             	lea    -0x20(%eax),%edx
f0100b5b:	80 fa 5e             	cmp    $0x5e,%dl
f0100b5e:	76 d9                	jbe    f0100b39 <mon_dump+0x15d>
f0100b60:	b0 2e                	mov    $0x2e,%al
f0100b62:	eb d5                	jmp    f0100b39 <mon_dump+0x15d>
				cprintf(" ");
f0100b64:	83 ec 0c             	sub    $0xc,%esp
f0100b67:	68 4c 42 10 f0       	push   $0xf010424c
f0100b6c:	e8 52 22 00 00       	call   f0102dc3 <cprintf>
f0100b71:	83 c4 10             	add    $0x10,%esp
f0100b74:	eb d7                	jmp    f0100b4d <mon_dump+0x171>
		cprintf("|\n");
f0100b76:	83 ec 0c             	sub    $0xc,%esp
f0100b79:	68 12 42 10 f0       	push   $0xf0104212
f0100b7e:	e8 40 22 00 00       	call   f0102dc3 <cprintf>
	for (ptr = ROUNDDOWN(l, 16); ptr <= r; ptr += 16) {
f0100b83:	83 c4 10             	add    $0x10,%esp
f0100b86:	39 f7                	cmp    %esi,%edi
f0100b88:	72 1e                	jb     f0100ba8 <mon_dump+0x1cc>
		cprintf("%08x  ", ptr);
f0100b8a:	83 ec 08             	sub    $0x8,%esp
f0100b8d:	56                   	push   %esi
f0100b8e:	68 fb 41 10 f0       	push   $0xf01041fb
f0100b93:	e8 2b 22 00 00       	call   f0102dc3 <cprintf>
f0100b98:	8d 46 10             	lea    0x10(%esi),%eax
f0100b9b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100b9e:	83 c4 10             	add    $0x10,%esp
f0100ba1:	89 f3                	mov    %esi,%ebx
f0100ba3:	e9 65 ff ff ff       	jmp    f0100b0d <mon_dump+0x131>
	if (ROUNDDOWN(r, 16) != r)
f0100ba8:	f7 c7 0f 00 00 00    	test   $0xf,%edi
f0100bae:	0f 84 4c fe ff ff    	je     f0100a00 <mon_dump+0x24>
		cprintf("%08x  \n", r);
f0100bb4:	83 ec 08             	sub    $0x8,%esp
f0100bb7:	57                   	push   %edi
f0100bb8:	68 15 42 10 f0       	push   $0xf0104215
f0100bbd:	e8 01 22 00 00       	call   f0102dc3 <cprintf>
f0100bc2:	83 c4 10             	add    $0x10,%esp
f0100bc5:	e9 36 fe ff ff       	jmp    f0100a00 <mon_dump+0x24>

f0100bca <mon_backtrace>:
{
f0100bca:	55                   	push   %ebp
f0100bcb:	89 e5                	mov    %esp,%ebp
f0100bcd:	57                   	push   %edi
f0100bce:	56                   	push   %esi
f0100bcf:	53                   	push   %ebx
f0100bd0:	83 ec 38             	sub    $0x38,%esp
	cprintf("Stack backtrace:\n");
f0100bd3:	68 1d 42 10 f0       	push   $0xf010421d
f0100bd8:	e8 e6 21 00 00       	call   f0102dc3 <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100bdd:	89 e8                	mov    %ebp,%eax
	while (ebp != 0) {
f0100bdf:	83 c4 10             	add    $0x10,%esp
f0100be2:	eb 34                	jmp    f0100c18 <mon_backtrace+0x4e>
			cprintf("%c", info.eip_fn_name[i]);
f0100be4:	83 ec 08             	sub    $0x8,%esp
f0100be7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100bea:	0f be 04 18          	movsbl (%eax,%ebx,1),%eax
f0100bee:	50                   	push   %eax
f0100bef:	68 0f 42 10 f0       	push   $0xf010420f
f0100bf4:	e8 ca 21 00 00       	call   f0102dc3 <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f0100bf9:	43                   	inc    %ebx
f0100bfa:	83 c4 10             	add    $0x10,%esp
f0100bfd:	39 5d dc             	cmp    %ebx,-0x24(%ebp)
f0100c00:	7f e2                	jg     f0100be4 <mon_backtrace+0x1a>
		cprintf("+%d\n", eip - info.eip_fn_addr);
f0100c02:	83 ec 08             	sub    $0x8,%esp
f0100c05:	2b 75 e0             	sub    -0x20(%ebp),%esi
f0100c08:	56                   	push   %esi
f0100c09:	68 40 42 10 f0       	push   $0xf0104240
f0100c0e:	e8 b0 21 00 00       	call   f0102dc3 <cprintf>
		ebp = prev_ebp;
f0100c13:	83 c4 10             	add    $0x10,%esp
f0100c16:	89 f8                	mov    %edi,%eax
	while (ebp != 0) {
f0100c18:	85 c0                	test   %eax,%eax
f0100c1a:	74 4a                	je     f0100c66 <mon_backtrace+0x9c>
		prev_ebp = *(int*)ebp;
f0100c1c:	8b 38                	mov    (%eax),%edi
		eip = *((int*)ebp + 1);
f0100c1e:	8b 70 04             	mov    0x4(%eax),%esi
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, 
f0100c21:	ff 70 18             	pushl  0x18(%eax)
f0100c24:	ff 70 14             	pushl  0x14(%eax)
f0100c27:	ff 70 10             	pushl  0x10(%eax)
f0100c2a:	ff 70 0c             	pushl  0xc(%eax)
f0100c2d:	ff 70 08             	pushl  0x8(%eax)
f0100c30:	56                   	push   %esi
f0100c31:	50                   	push   %eax
f0100c32:	68 20 45 10 f0       	push   $0xf0104520
f0100c37:	e8 87 21 00 00       	call   f0102dc3 <cprintf>
		int code = debuginfo_eip((uintptr_t)eip, &info);
f0100c3c:	83 c4 18             	add    $0x18,%esp
f0100c3f:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100c42:	50                   	push   %eax
f0100c43:	56                   	push   %esi
f0100c44:	e8 7b 22 00 00       	call   f0102ec4 <debuginfo_eip>
		cprintf("         %s:%d: ", info.eip_file, info.eip_line);
f0100c49:	83 c4 0c             	add    $0xc,%esp
f0100c4c:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100c4f:	ff 75 d0             	pushl  -0x30(%ebp)
f0100c52:	68 2f 42 10 f0       	push   $0xf010422f
f0100c57:	e8 67 21 00 00       	call   f0102dc3 <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f0100c5c:	83 c4 10             	add    $0x10,%esp
f0100c5f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100c64:	eb 97                	jmp    f0100bfd <mon_backtrace+0x33>
}
f0100c66:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c69:	5b                   	pop    %ebx
f0100c6a:	5e                   	pop    %esi
f0100c6b:	5f                   	pop    %edi
f0100c6c:	5d                   	pop    %ebp
f0100c6d:	c3                   	ret    

f0100c6e <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100c6e:	55                   	push   %ebp
f0100c6f:	89 e5                	mov    %esp,%ebp
f0100c71:	57                   	push   %edi
f0100c72:	56                   	push   %esi
f0100c73:	53                   	push   %ebx
f0100c74:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100c77:	68 58 45 10 f0       	push   $0xf0104558
f0100c7c:	e8 42 21 00 00       	call   f0102dc3 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100c81:	c7 04 24 7c 45 10 f0 	movl   $0xf010457c,(%esp)
f0100c88:	e8 36 21 00 00       	call   f0102dc3 <cprintf>
f0100c8d:	83 c4 10             	add    $0x10,%esp
f0100c90:	eb 47                	jmp    f0100cd9 <monitor+0x6b>
		while (*buf && strchr(WHITESPACE, *buf))
f0100c92:	83 ec 08             	sub    $0x8,%esp
f0100c95:	0f be c0             	movsbl %al,%eax
f0100c98:	50                   	push   %eax
f0100c99:	68 49 42 10 f0       	push   $0xf0104249
f0100c9e:	e8 1a 2c 00 00       	call   f01038bd <strchr>
f0100ca3:	83 c4 10             	add    $0x10,%esp
f0100ca6:	85 c0                	test   %eax,%eax
f0100ca8:	74 0a                	je     f0100cb4 <monitor+0x46>
			*buf++ = 0;
f0100caa:	c6 03 00             	movb   $0x0,(%ebx)
f0100cad:	89 fe                	mov    %edi,%esi
f0100caf:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100cb2:	eb 68                	jmp    f0100d1c <monitor+0xae>
		if (*buf == 0)
f0100cb4:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100cb7:	74 6f                	je     f0100d28 <monitor+0xba>
		if (argc == MAXARGS-1) {
f0100cb9:	83 ff 0f             	cmp    $0xf,%edi
f0100cbc:	74 09                	je     f0100cc7 <monitor+0x59>
		argv[argc++] = buf;
f0100cbe:	8d 77 01             	lea    0x1(%edi),%esi
f0100cc1:	89 5c bd a8          	mov    %ebx,-0x58(%ebp,%edi,4)
f0100cc5:	eb 37                	jmp    f0100cfe <monitor+0x90>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100cc7:	83 ec 08             	sub    $0x8,%esp
f0100cca:	6a 10                	push   $0x10
f0100ccc:	68 4e 42 10 f0       	push   $0xf010424e
f0100cd1:	e8 ed 20 00 00       	call   f0102dc3 <cprintf>
f0100cd6:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100cd9:	83 ec 0c             	sub    $0xc,%esp
f0100cdc:	68 45 42 10 f0       	push   $0xf0104245
f0100ce1:	e8 cc 29 00 00       	call   f01036b2 <readline>
f0100ce6:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100ce8:	83 c4 10             	add    $0x10,%esp
f0100ceb:	85 c0                	test   %eax,%eax
f0100ced:	74 ea                	je     f0100cd9 <monitor+0x6b>
	argv[argc] = 0;
f0100cef:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100cf6:	bf 00 00 00 00       	mov    $0x0,%edi
f0100cfb:	eb 21                	jmp    f0100d1e <monitor+0xb0>
			buf++;
f0100cfd:	43                   	inc    %ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100cfe:	8a 03                	mov    (%ebx),%al
f0100d00:	84 c0                	test   %al,%al
f0100d02:	74 18                	je     f0100d1c <monitor+0xae>
f0100d04:	83 ec 08             	sub    $0x8,%esp
f0100d07:	0f be c0             	movsbl %al,%eax
f0100d0a:	50                   	push   %eax
f0100d0b:	68 49 42 10 f0       	push   $0xf0104249
f0100d10:	e8 a8 2b 00 00       	call   f01038bd <strchr>
f0100d15:	83 c4 10             	add    $0x10,%esp
f0100d18:	85 c0                	test   %eax,%eax
f0100d1a:	74 e1                	je     f0100cfd <monitor+0x8f>
			*buf++ = 0;
f0100d1c:	89 f7                	mov    %esi,%edi
		while (*buf && strchr(WHITESPACE, *buf))
f0100d1e:	8a 03                	mov    (%ebx),%al
f0100d20:	84 c0                	test   %al,%al
f0100d22:	0f 85 6a ff ff ff    	jne    f0100c92 <monitor+0x24>
	argv[argc] = 0;
f0100d28:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
f0100d2f:	00 
	if (argc == 0)
f0100d30:	85 ff                	test   %edi,%edi
f0100d32:	74 a5                	je     f0100cd9 <monitor+0x6b>
f0100d34:	be 60 46 10 f0       	mov    $0xf0104660,%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100d39:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f0100d3e:	83 ec 08             	sub    $0x8,%esp
f0100d41:	ff 36                	pushl  (%esi)
f0100d43:	ff 75 a8             	pushl  -0x58(%ebp)
f0100d46:	e8 1e 2b 00 00       	call   f0103869 <strcmp>
f0100d4b:	83 c4 10             	add    $0x10,%esp
f0100d4e:	85 c0                	test   %eax,%eax
f0100d50:	74 21                	je     f0100d73 <monitor+0x105>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100d52:	43                   	inc    %ebx
f0100d53:	83 c6 0c             	add    $0xc,%esi
f0100d56:	83 fb 05             	cmp    $0x5,%ebx
f0100d59:	75 e3                	jne    f0100d3e <monitor+0xd0>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100d5b:	83 ec 08             	sub    $0x8,%esp
f0100d5e:	ff 75 a8             	pushl  -0x58(%ebp)
f0100d61:	68 6b 42 10 f0       	push   $0xf010426b
f0100d66:	e8 58 20 00 00       	call   f0102dc3 <cprintf>
f0100d6b:	83 c4 10             	add    $0x10,%esp
f0100d6e:	e9 66 ff ff ff       	jmp    f0100cd9 <monitor+0x6b>
			return commands[i].func(argc, argv, tf);
f0100d73:	83 ec 04             	sub    $0x4,%esp
f0100d76:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100d79:	01 c3                	add    %eax,%ebx
f0100d7b:	ff 75 08             	pushl  0x8(%ebp)
f0100d7e:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100d81:	50                   	push   %eax
f0100d82:	57                   	push   %edi
f0100d83:	ff 14 9d 68 46 10 f0 	call   *-0xfefb998(,%ebx,4)
			if (runcmd(buf, tf) < 0)
f0100d8a:	83 c4 10             	add    $0x10,%esp
f0100d8d:	85 c0                	test   %eax,%eax
f0100d8f:	0f 89 44 ff ff ff    	jns    f0100cd9 <monitor+0x6b>
				break;
	}
}
f0100d95:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d98:	5b                   	pop    %ebx
f0100d99:	5e                   	pop    %esi
f0100d9a:	5f                   	pop    %edi
f0100d9b:	5d                   	pop    %ebp
f0100d9c:	c3                   	ret    

f0100d9d <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100d9d:	55                   	push   %ebp
f0100d9e:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100da0:	83 3d 38 95 11 f0 00 	cmpl   $0x0,0xf0119538
f0100da7:	74 1f                	je     f0100dc8 <boot_alloc+0x2b>
	}

	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	if (!n)
f0100da9:	85 c0                	test   %eax,%eax
f0100dab:	74 2e                	je     f0100ddb <boot_alloc+0x3e>
		return (void*)nextfree;
	else {
		result = nextfree;
f0100dad:	8b 15 38 95 11 f0    	mov    0xf0119538,%edx
		nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100db3:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100dba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100dbf:	a3 38 95 11 f0       	mov    %eax,0xf0119538
		return (void*)result;
	}
}
f0100dc4:	89 d0                	mov    %edx,%eax
f0100dc6:	5d                   	pop    %ebp
f0100dc7:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100dc8:	ba 6f a9 11 f0       	mov    $0xf011a96f,%edx
f0100dcd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100dd3:	89 15 38 95 11 f0    	mov    %edx,0xf0119538
f0100dd9:	eb ce                	jmp    f0100da9 <boot_alloc+0xc>
		return (void*)nextfree;
f0100ddb:	8b 15 38 95 11 f0    	mov    0xf0119538,%edx
f0100de1:	eb e1                	jmp    f0100dc4 <boot_alloc+0x27>

f0100de3 <nvram_read>:
{
f0100de3:	55                   	push   %ebp
f0100de4:	89 e5                	mov    %esp,%ebp
f0100de6:	56                   	push   %esi
f0100de7:	53                   	push   %ebx
f0100de8:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100dea:	83 ec 0c             	sub    $0xc,%esp
f0100ded:	50                   	push   %eax
f0100dee:	e8 69 1f 00 00       	call   f0102d5c <mc146818_read>
f0100df3:	89 c3                	mov    %eax,%ebx
f0100df5:	46                   	inc    %esi
f0100df6:	89 34 24             	mov    %esi,(%esp)
f0100df9:	e8 5e 1f 00 00       	call   f0102d5c <mc146818_read>
f0100dfe:	c1 e0 08             	shl    $0x8,%eax
f0100e01:	09 d8                	or     %ebx,%eax
}
f0100e03:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100e06:	5b                   	pop    %ebx
f0100e07:	5e                   	pop    %esi
f0100e08:	5d                   	pop    %ebp
f0100e09:	c3                   	ret    

f0100e0a <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100e0a:	89 d1                	mov    %edx,%ecx
f0100e0c:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100e0f:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100e12:	a8 01                	test   $0x1,%al
f0100e14:	74 47                	je     f0100e5d <check_va2pa+0x53>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100e16:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100e1b:	89 c1                	mov    %eax,%ecx
f0100e1d:	c1 e9 0c             	shr    $0xc,%ecx
f0100e20:	3b 0d 64 99 11 f0    	cmp    0xf0119964,%ecx
f0100e26:	73 1a                	jae    f0100e42 <check_va2pa+0x38>
	if (!(p[PTX(va)] & PTE_P))
f0100e28:	c1 ea 0c             	shr    $0xc,%edx
f0100e2b:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100e31:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100e38:	a8 01                	test   $0x1,%al
f0100e3a:	74 27                	je     f0100e63 <check_va2pa+0x59>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100e3c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100e41:	c3                   	ret    
{
f0100e42:	55                   	push   %ebp
f0100e43:	89 e5                	mov    %esp,%ebp
f0100e45:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e48:	50                   	push   %eax
f0100e49:	68 d0 44 10 f0       	push   $0xf01044d0
f0100e4e:	68 c2 02 00 00       	push   $0x2c2
f0100e53:	68 f0 4d 10 f0       	push   $0xf0104df0
f0100e58:	e8 d6 f2 ff ff       	call   f0100133 <_panic>
		return ~0;
f0100e5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e62:	c3                   	ret    
		return ~0;
f0100e63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100e68:	c3                   	ret    

f0100e69 <check_page_free_list>:
{
f0100e69:	55                   	push   %ebp
f0100e6a:	89 e5                	mov    %esp,%ebp
f0100e6c:	57                   	push   %edi
f0100e6d:	56                   	push   %esi
f0100e6e:	53                   	push   %ebx
f0100e6f:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e72:	84 c0                	test   %al,%al
f0100e74:	0f 85 50 02 00 00    	jne    f01010ca <check_page_free_list+0x261>
	if (!page_free_list)
f0100e7a:	83 3d 3c 95 11 f0 00 	cmpl   $0x0,0xf011953c
f0100e81:	74 0a                	je     f0100e8d <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e83:	be 00 04 00 00       	mov    $0x400,%esi
f0100e88:	e9 98 02 00 00       	jmp    f0101125 <check_page_free_list+0x2bc>
		panic("'page_free_list' is a null pointer!");
f0100e8d:	83 ec 04             	sub    $0x4,%esp
f0100e90:	68 9c 46 10 f0       	push   $0xf010469c
f0100e95:	68 02 02 00 00       	push   $0x202
f0100e9a:	68 f0 4d 10 f0       	push   $0xf0104df0
f0100e9f:	e8 8f f2 ff ff       	call   f0100133 <_panic>
f0100ea4:	50                   	push   %eax
f0100ea5:	68 d0 44 10 f0       	push   $0xf01044d0
f0100eaa:	6a 52                	push   $0x52
f0100eac:	68 fc 4d 10 f0       	push   $0xf0104dfc
f0100eb1:	e8 7d f2 ff ff       	call   f0100133 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100eb6:	8b 1b                	mov    (%ebx),%ebx
f0100eb8:	85 db                	test   %ebx,%ebx
f0100eba:	74 41                	je     f0100efd <check_page_free_list+0x94>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ebc:	89 d8                	mov    %ebx,%eax
f0100ebe:	2b 05 6c 99 11 f0    	sub    0xf011996c,%eax
f0100ec4:	c1 f8 03             	sar    $0x3,%eax
f0100ec7:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100eca:	89 c2                	mov    %eax,%edx
f0100ecc:	c1 ea 16             	shr    $0x16,%edx
f0100ecf:	39 f2                	cmp    %esi,%edx
f0100ed1:	73 e3                	jae    f0100eb6 <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100ed3:	89 c2                	mov    %eax,%edx
f0100ed5:	c1 ea 0c             	shr    $0xc,%edx
f0100ed8:	3b 15 64 99 11 f0    	cmp    0xf0119964,%edx
f0100ede:	73 c4                	jae    f0100ea4 <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100ee0:	83 ec 04             	sub    $0x4,%esp
f0100ee3:	68 80 00 00 00       	push   $0x80
f0100ee8:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100eed:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ef2:	50                   	push   %eax
f0100ef3:	e8 fa 29 00 00       	call   f01038f2 <memset>
f0100ef8:	83 c4 10             	add    $0x10,%esp
f0100efb:	eb b9                	jmp    f0100eb6 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100efd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f02:	e8 96 fe ff ff       	call   f0100d9d <boot_alloc>
f0100f07:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f0a:	8b 15 3c 95 11 f0    	mov    0xf011953c,%edx
		assert(pp >= pages);
f0100f10:	8b 0d 6c 99 11 f0    	mov    0xf011996c,%ecx
		assert(pp < pages + npages);
f0100f16:	a1 64 99 11 f0       	mov    0xf0119964,%eax
f0100f1b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100f1e:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100f21:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0100f24:	be 00 00 00 00       	mov    $0x0,%esi
f0100f29:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f2c:	e9 c8 00 00 00       	jmp    f0100ff9 <check_page_free_list+0x190>
		assert(pp >= pages);
f0100f31:	68 0a 4e 10 f0       	push   $0xf0104e0a
f0100f36:	68 16 4e 10 f0       	push   $0xf0104e16
f0100f3b:	68 1c 02 00 00       	push   $0x21c
f0100f40:	68 f0 4d 10 f0       	push   $0xf0104df0
f0100f45:	e8 e9 f1 ff ff       	call   f0100133 <_panic>
		assert(pp < pages + npages);
f0100f4a:	68 2b 4e 10 f0       	push   $0xf0104e2b
f0100f4f:	68 16 4e 10 f0       	push   $0xf0104e16
f0100f54:	68 1d 02 00 00       	push   $0x21d
f0100f59:	68 f0 4d 10 f0       	push   $0xf0104df0
f0100f5e:	e8 d0 f1 ff ff       	call   f0100133 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100f63:	68 c0 46 10 f0       	push   $0xf01046c0
f0100f68:	68 16 4e 10 f0       	push   $0xf0104e16
f0100f6d:	68 1e 02 00 00       	push   $0x21e
f0100f72:	68 f0 4d 10 f0       	push   $0xf0104df0
f0100f77:	e8 b7 f1 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) != 0);
f0100f7c:	68 3f 4e 10 f0       	push   $0xf0104e3f
f0100f81:	68 16 4e 10 f0       	push   $0xf0104e16
f0100f86:	68 21 02 00 00       	push   $0x221
f0100f8b:	68 f0 4d 10 f0       	push   $0xf0104df0
f0100f90:	e8 9e f1 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100f95:	68 50 4e 10 f0       	push   $0xf0104e50
f0100f9a:	68 16 4e 10 f0       	push   $0xf0104e16
f0100f9f:	68 22 02 00 00       	push   $0x222
f0100fa4:	68 f0 4d 10 f0       	push   $0xf0104df0
f0100fa9:	e8 85 f1 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100fae:	68 f4 46 10 f0       	push   $0xf01046f4
f0100fb3:	68 16 4e 10 f0       	push   $0xf0104e16
f0100fb8:	68 23 02 00 00       	push   $0x223
f0100fbd:	68 f0 4d 10 f0       	push   $0xf0104df0
f0100fc2:	e8 6c f1 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100fc7:	68 69 4e 10 f0       	push   $0xf0104e69
f0100fcc:	68 16 4e 10 f0       	push   $0xf0104e16
f0100fd1:	68 24 02 00 00       	push   $0x224
f0100fd6:	68 f0 4d 10 f0       	push   $0xf0104df0
f0100fdb:	e8 53 f1 ff ff       	call   f0100133 <_panic>
	if (PGNUM(pa) >= npages)
f0100fe0:	89 c3                	mov    %eax,%ebx
f0100fe2:	c1 eb 0c             	shr    $0xc,%ebx
f0100fe5:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f0100fe8:	76 63                	jbe    f010104d <check_page_free_list+0x1e4>
	return (void *)(pa + KERNBASE);
f0100fea:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100fef:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100ff2:	77 6b                	ja     f010105f <check_page_free_list+0x1f6>
			++nfree_extmem;
f0100ff4:	ff 45 d0             	incl   -0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ff7:	8b 12                	mov    (%edx),%edx
f0100ff9:	85 d2                	test   %edx,%edx
f0100ffb:	74 7b                	je     f0101078 <check_page_free_list+0x20f>
		assert(pp >= pages);
f0100ffd:	39 d1                	cmp    %edx,%ecx
f0100fff:	0f 87 2c ff ff ff    	ja     f0100f31 <check_page_free_list+0xc8>
		assert(pp < pages + npages);
f0101005:	39 d7                	cmp    %edx,%edi
f0101007:	0f 86 3d ff ff ff    	jbe    f0100f4a <check_page_free_list+0xe1>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010100d:	89 d0                	mov    %edx,%eax
f010100f:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0101012:	a8 07                	test   $0x7,%al
f0101014:	0f 85 49 ff ff ff    	jne    f0100f63 <check_page_free_list+0xfa>
	return (pp - pages) << PGSHIFT;
f010101a:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f010101d:	c1 e0 0c             	shl    $0xc,%eax
f0101020:	0f 84 56 ff ff ff    	je     f0100f7c <check_page_free_list+0x113>
		assert(page2pa(pp) != IOPHYSMEM);
f0101026:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010102b:	0f 84 64 ff ff ff    	je     f0100f95 <check_page_free_list+0x12c>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101031:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101036:	0f 84 72 ff ff ff    	je     f0100fae <check_page_free_list+0x145>
		assert(page2pa(pp) != EXTPHYSMEM);
f010103c:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101041:	74 84                	je     f0100fc7 <check_page_free_list+0x15e>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101043:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101048:	77 96                	ja     f0100fe0 <check_page_free_list+0x177>
			++nfree_basemem;
f010104a:	46                   	inc    %esi
f010104b:	eb aa                	jmp    f0100ff7 <check_page_free_list+0x18e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010104d:	50                   	push   %eax
f010104e:	68 d0 44 10 f0       	push   $0xf01044d0
f0101053:	6a 52                	push   $0x52
f0101055:	68 fc 4d 10 f0       	push   $0xf0104dfc
f010105a:	e8 d4 f0 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010105f:	68 18 47 10 f0       	push   $0xf0104718
f0101064:	68 16 4e 10 f0       	push   $0xf0104e16
f0101069:	68 25 02 00 00       	push   $0x225
f010106e:	68 f0 4d 10 f0       	push   $0xf0104df0
f0101073:	e8 bb f0 ff ff       	call   f0100133 <_panic>
f0101078:	8b 5d d0             	mov    -0x30(%ebp),%ebx
	assert(nfree_basemem > 0);
f010107b:	85 f6                	test   %esi,%esi
f010107d:	7e 19                	jle    f0101098 <check_page_free_list+0x22f>
	assert(nfree_extmem > 0);
f010107f:	85 db                	test   %ebx,%ebx
f0101081:	7e 2e                	jle    f01010b1 <check_page_free_list+0x248>
	cprintf("check_page_free_list() succeeded!\n");
f0101083:	83 ec 0c             	sub    $0xc,%esp
f0101086:	68 60 47 10 f0       	push   $0xf0104760
f010108b:	e8 33 1d 00 00       	call   f0102dc3 <cprintf>
}
f0101090:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101093:	5b                   	pop    %ebx
f0101094:	5e                   	pop    %esi
f0101095:	5f                   	pop    %edi
f0101096:	5d                   	pop    %ebp
f0101097:	c3                   	ret    
	assert(nfree_basemem > 0);
f0101098:	68 83 4e 10 f0       	push   $0xf0104e83
f010109d:	68 16 4e 10 f0       	push   $0xf0104e16
f01010a2:	68 2d 02 00 00       	push   $0x22d
f01010a7:	68 f0 4d 10 f0       	push   $0xf0104df0
f01010ac:	e8 82 f0 ff ff       	call   f0100133 <_panic>
	assert(nfree_extmem > 0);
f01010b1:	68 95 4e 10 f0       	push   $0xf0104e95
f01010b6:	68 16 4e 10 f0       	push   $0xf0104e16
f01010bb:	68 2e 02 00 00       	push   $0x22e
f01010c0:	68 f0 4d 10 f0       	push   $0xf0104df0
f01010c5:	e8 69 f0 ff ff       	call   f0100133 <_panic>
	if (!page_free_list)
f01010ca:	a1 3c 95 11 f0       	mov    0xf011953c,%eax
f01010cf:	85 c0                	test   %eax,%eax
f01010d1:	0f 84 b6 fd ff ff    	je     f0100e8d <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01010d7:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01010da:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01010dd:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01010e0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f01010e3:	89 c2                	mov    %eax,%edx
f01010e5:	2b 15 6c 99 11 f0    	sub    0xf011996c,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit; 
f01010eb:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f01010f1:	0f 95 c2             	setne  %dl
f01010f4:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f01010f7:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f01010fb:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f01010fd:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101101:	8b 00                	mov    (%eax),%eax
f0101103:	85 c0                	test   %eax,%eax
f0101105:	75 dc                	jne    f01010e3 <check_page_free_list+0x27a>
		*tp[1] = 0;
f0101107:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010110a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101110:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101113:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101116:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101118:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010111b:	a3 3c 95 11 f0       	mov    %eax,0xf011953c
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101120:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101125:	8b 1d 3c 95 11 f0    	mov    0xf011953c,%ebx
f010112b:	e9 88 fd ff ff       	jmp    f0100eb8 <check_page_free_list+0x4f>

f0101130 <page_init>:
{
f0101130:	55                   	push   %ebp
f0101131:	89 e5                	mov    %esp,%ebp
f0101133:	57                   	push   %edi
f0101134:	56                   	push   %esi
f0101135:	53                   	push   %ebx
	for (i = 1; i < npages_basemem; i++) {
f0101136:	8b 35 40 95 11 f0    	mov    0xf0119540,%esi
f010113c:	8b 1d 3c 95 11 f0    	mov    0xf011953c,%ebx
f0101142:	b2 00                	mov    $0x0,%dl
f0101144:	b8 01 00 00 00       	mov    $0x1,%eax
f0101149:	bf 01 00 00 00       	mov    $0x1,%edi
f010114e:	eb 22                	jmp    f0101172 <page_init+0x42>
		pages[i].pp_ref = 0;
f0101150:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0101157:	89 d1                	mov    %edx,%ecx
f0101159:	03 0d 6c 99 11 f0    	add    0xf011996c,%ecx
f010115f:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0101165:	89 19                	mov    %ebx,(%ecx)
	for (i = 1; i < npages_basemem; i++) {
f0101167:	40                   	inc    %eax
		page_free_list = &pages[i];
f0101168:	89 d3                	mov    %edx,%ebx
f010116a:	03 1d 6c 99 11 f0    	add    0xf011996c,%ebx
f0101170:	89 fa                	mov    %edi,%edx
	for (i = 1; i < npages_basemem; i++) {
f0101172:	39 c6                	cmp    %eax,%esi
f0101174:	77 da                	ja     f0101150 <page_init+0x20>
f0101176:	84 d2                	test   %dl,%dl
f0101178:	75 33                	jne    f01011ad <page_init+0x7d>
	size_t table_size = PTX(sizeof(struct PageInfo)*npages);
f010117a:	8b 15 64 99 11 f0    	mov    0xf0119964,%edx
f0101180:	c1 e2 0d             	shl    $0xd,%edx
f0101183:	c1 ea 16             	shr    $0x16,%edx
	size_t end_idx = PTX(ROUNDUP((char *) end, PGSIZE));
f0101186:	b8 6f a9 11 f0       	mov    $0xf011a96f,%eax
f010118b:	c1 e8 0c             	shr    $0xc,%eax
f010118e:	25 ff 03 00 00       	and    $0x3ff,%eax
	for (i = table_size + end_idx + 1; i < npages; i++) {
f0101193:	8d 54 02 01          	lea    0x1(%edx,%eax,1),%edx
f0101197:	8b 1d 3c 95 11 f0    	mov    0xf011953c,%ebx
f010119d:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f01011a4:	b1 00                	mov    $0x0,%cl
f01011a6:	be 01 00 00 00       	mov    $0x1,%esi
f01011ab:	eb 26                	jmp    f01011d3 <page_init+0xa3>
f01011ad:	89 1d 3c 95 11 f0    	mov    %ebx,0xf011953c
f01011b3:	eb c5                	jmp    f010117a <page_init+0x4a>
		pages[i].pp_ref = 0;
f01011b5:	89 c1                	mov    %eax,%ecx
f01011b7:	03 0d 6c 99 11 f0    	add    0xf011996c,%ecx
f01011bd:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f01011c3:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f01011c5:	89 c3                	mov    %eax,%ebx
f01011c7:	03 1d 6c 99 11 f0    	add    0xf011996c,%ebx
	for (i = table_size + end_idx + 1; i < npages; i++) {
f01011cd:	42                   	inc    %edx
f01011ce:	83 c0 08             	add    $0x8,%eax
f01011d1:	89 f1                	mov    %esi,%ecx
f01011d3:	39 15 64 99 11 f0    	cmp    %edx,0xf0119964
f01011d9:	77 da                	ja     f01011b5 <page_init+0x85>
f01011db:	84 c9                	test   %cl,%cl
f01011dd:	75 05                	jne    f01011e4 <page_init+0xb4>
}
f01011df:	5b                   	pop    %ebx
f01011e0:	5e                   	pop    %esi
f01011e1:	5f                   	pop    %edi
f01011e2:	5d                   	pop    %ebp
f01011e3:	c3                   	ret    
f01011e4:	89 1d 3c 95 11 f0    	mov    %ebx,0xf011953c
f01011ea:	eb f3                	jmp    f01011df <page_init+0xaf>

f01011ec <page_alloc>:
{
f01011ec:	55                   	push   %ebp
f01011ed:	89 e5                	mov    %esp,%ebp
f01011ef:	53                   	push   %ebx
f01011f0:	83 ec 04             	sub    $0x4,%esp
	struct PageInfo* next = page_free_list;
f01011f3:	8b 1d 3c 95 11 f0    	mov    0xf011953c,%ebx
	if (!next)
f01011f9:	85 db                	test   %ebx,%ebx
f01011fb:	74 13                	je     f0101210 <page_alloc+0x24>
	page_free_list = page_free_list->pp_link;
f01011fd:	8b 03                	mov    (%ebx),%eax
f01011ff:	a3 3c 95 11 f0       	mov    %eax,0xf011953c
	next->pp_link = NULL;
f0101204:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f010120a:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010120e:	75 07                	jne    f0101217 <page_alloc+0x2b>
}
f0101210:	89 d8                	mov    %ebx,%eax
f0101212:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101215:	c9                   	leave  
f0101216:	c3                   	ret    
f0101217:	89 d8                	mov    %ebx,%eax
f0101219:	2b 05 6c 99 11 f0    	sub    0xf011996c,%eax
f010121f:	c1 f8 03             	sar    $0x3,%eax
f0101222:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101225:	89 c2                	mov    %eax,%edx
f0101227:	c1 ea 0c             	shr    $0xc,%edx
f010122a:	3b 15 64 99 11 f0    	cmp    0xf0119964,%edx
f0101230:	73 1a                	jae    f010124c <page_alloc+0x60>
		memset(content, 0, PGSIZE);
f0101232:	83 ec 04             	sub    $0x4,%esp
f0101235:	68 00 10 00 00       	push   $0x1000
f010123a:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f010123c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101241:	50                   	push   %eax
f0101242:	e8 ab 26 00 00       	call   f01038f2 <memset>
f0101247:	83 c4 10             	add    $0x10,%esp
f010124a:	eb c4                	jmp    f0101210 <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010124c:	50                   	push   %eax
f010124d:	68 d0 44 10 f0       	push   $0xf01044d0
f0101252:	6a 52                	push   $0x52
f0101254:	68 fc 4d 10 f0       	push   $0xf0104dfc
f0101259:	e8 d5 ee ff ff       	call   f0100133 <_panic>

f010125e <page_free>:
{
f010125e:	55                   	push   %ebp
f010125f:	89 e5                	mov    %esp,%ebp
f0101261:	83 ec 08             	sub    $0x8,%esp
f0101264:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref)
f0101267:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010126c:	75 14                	jne    f0101282 <page_free+0x24>
	if (pp->pp_link)
f010126e:	83 38 00             	cmpl   $0x0,(%eax)
f0101271:	75 26                	jne    f0101299 <page_free+0x3b>
	pp->pp_link = page_free_list;
f0101273:	8b 15 3c 95 11 f0    	mov    0xf011953c,%edx
f0101279:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f010127b:	a3 3c 95 11 f0       	mov    %eax,0xf011953c
}
f0101280:	c9                   	leave  
f0101281:	c3                   	ret    
		panic("Ref count is non-zero");
f0101282:	83 ec 04             	sub    $0x4,%esp
f0101285:	68 a6 4e 10 f0       	push   $0xf0104ea6
f010128a:	68 3a 01 00 00       	push   $0x13a
f010128f:	68 f0 4d 10 f0       	push   $0xf0104df0
f0101294:	e8 9a ee ff ff       	call   f0100133 <_panic>
		panic("Page is double-freed");
f0101299:	83 ec 04             	sub    $0x4,%esp
f010129c:	68 bc 4e 10 f0       	push   $0xf0104ebc
f01012a1:	68 3c 01 00 00       	push   $0x13c
f01012a6:	68 f0 4d 10 f0       	push   $0xf0104df0
f01012ab:	e8 83 ee ff ff       	call   f0100133 <_panic>

f01012b0 <page_decref>:
{
f01012b0:	55                   	push   %ebp
f01012b1:	89 e5                	mov    %esp,%ebp
f01012b3:	83 ec 08             	sub    $0x8,%esp
f01012b6:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01012b9:	8b 42 04             	mov    0x4(%edx),%eax
f01012bc:	48                   	dec    %eax
f01012bd:	66 89 42 04          	mov    %ax,0x4(%edx)
f01012c1:	66 85 c0             	test   %ax,%ax
f01012c4:	74 02                	je     f01012c8 <page_decref+0x18>
}
f01012c6:	c9                   	leave  
f01012c7:	c3                   	ret    
		page_free(pp);
f01012c8:	83 ec 0c             	sub    $0xc,%esp
f01012cb:	52                   	push   %edx
f01012cc:	e8 8d ff ff ff       	call   f010125e <page_free>
f01012d1:	83 c4 10             	add    $0x10,%esp
}
f01012d4:	eb f0                	jmp    f01012c6 <page_decref+0x16>

f01012d6 <pgdir_walk>:
{
f01012d6:	55                   	push   %ebp
f01012d7:	89 e5                	mov    %esp,%ebp
f01012d9:	57                   	push   %edi
f01012da:	56                   	push   %esi
f01012db:	53                   	push   %ebx
f01012dc:	83 ec 1c             	sub    $0x1c,%esp
	pde_t pd_entry = (pde_t)pgdir[PDX(va)];
f01012df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01012e2:	c1 eb 16             	shr    $0x16,%ebx
f01012e5:	c1 e3 02             	shl    $0x2,%ebx
f01012e8:	03 5d 08             	add    0x8(%ebp),%ebx
f01012eb:	8b 03                	mov    (%ebx),%eax
	if (pd_entry) {
f01012ed:	85 c0                	test   %eax,%eax
f01012ef:	74 42                	je     f0101333 <pgdir_walk+0x5d>
		pte_t* pt_base = KADDR(PTE_ADDR(pd_entry));
f01012f1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01012f6:	89 c2                	mov    %eax,%edx
f01012f8:	c1 ea 0c             	shr    $0xc,%edx
f01012fb:	39 15 64 99 11 f0    	cmp    %edx,0xf0119964
f0101301:	76 1b                	jbe    f010131e <pgdir_walk+0x48>
		return pt_base + PTX(va);
f0101303:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101306:	c1 ea 0a             	shr    $0xa,%edx
f0101309:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f010130f:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
}
f0101316:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101319:	5b                   	pop    %ebx
f010131a:	5e                   	pop    %esi
f010131b:	5f                   	pop    %edi
f010131c:	5d                   	pop    %ebp
f010131d:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010131e:	50                   	push   %eax
f010131f:	68 d0 44 10 f0       	push   $0xf01044d0
f0101324:	68 67 01 00 00       	push   $0x167
f0101329:	68 f0 4d 10 f0       	push   $0xf0104df0
f010132e:	e8 00 ee ff ff       	call   f0100133 <_panic>
	else if (create) {
f0101333:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101337:	0f 84 9c 00 00 00    	je     f01013d9 <pgdir_walk+0x103>
		struct PageInfo *new_pt = page_alloc(0);
f010133d:	83 ec 0c             	sub    $0xc,%esp
f0101340:	6a 00                	push   $0x0
f0101342:	e8 a5 fe ff ff       	call   f01011ec <page_alloc>
f0101347:	89 c7                	mov    %eax,%edi
		if (new_pt) {
f0101349:	83 c4 10             	add    $0x10,%esp
f010134c:	85 c0                	test   %eax,%eax
f010134e:	0f 84 8f 00 00 00    	je     f01013e3 <pgdir_walk+0x10d>
	return (pp - pages) << PGSHIFT;
f0101354:	2b 05 6c 99 11 f0    	sub    0xf011996c,%eax
f010135a:	c1 f8 03             	sar    $0x3,%eax
f010135d:	c1 e0 0c             	shl    $0xc,%eax
f0101360:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (PGNUM(pa) >= npages)
f0101363:	c1 e8 0c             	shr    $0xc,%eax
f0101366:	3b 05 64 99 11 f0    	cmp    0xf0119964,%eax
f010136c:	73 42                	jae    f01013b0 <pgdir_walk+0xda>
	return (void *)(pa + KERNBASE);
f010136e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101371:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
			memset(content, 0, PGSIZE);
f0101377:	83 ec 04             	sub    $0x4,%esp
f010137a:	68 00 10 00 00       	push   $0x1000
f010137f:	6a 00                	push   $0x0
f0101381:	56                   	push   %esi
f0101382:	e8 6b 25 00 00       	call   f01038f2 <memset>
			new_pt->pp_ref++;
f0101387:	66 ff 47 04          	incw   0x4(%edi)
	if ((uint32_t)kva < KERNBASE)
f010138b:	83 c4 10             	add    $0x10,%esp
f010138e:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0101394:	76 2e                	jbe    f01013c4 <pgdir_walk+0xee>
			pgdir[PDX(va)] = PADDR(content) | 0xF; // Set all permissions.
f0101396:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101399:	83 c8 0f             	or     $0xf,%eax
f010139c:	89 03                	mov    %eax,(%ebx)
			return (pte_t*) content + PTX(va);
f010139e:	8b 45 0c             	mov    0xc(%ebp),%eax
f01013a1:	c1 e8 0a             	shr    $0xa,%eax
f01013a4:	25 fc 0f 00 00       	and    $0xffc,%eax
f01013a9:	01 f0                	add    %esi,%eax
f01013ab:	e9 66 ff ff ff       	jmp    f0101316 <pgdir_walk+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013b0:	ff 75 e4             	pushl  -0x1c(%ebp)
f01013b3:	68 d0 44 10 f0       	push   $0xf01044d0
f01013b8:	6a 52                	push   $0x52
f01013ba:	68 fc 4d 10 f0       	push   $0xf0104dfc
f01013bf:	e8 6f ed ff ff       	call   f0100133 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013c4:	56                   	push   %esi
f01013c5:	68 84 47 10 f0       	push   $0xf0104784
f01013ca:	68 70 01 00 00       	push   $0x170
f01013cf:	68 f0 4d 10 f0       	push   $0xf0104df0
f01013d4:	e8 5a ed ff ff       	call   f0100133 <_panic>
	return NULL;
f01013d9:	b8 00 00 00 00       	mov    $0x0,%eax
f01013de:	e9 33 ff ff ff       	jmp    f0101316 <pgdir_walk+0x40>
f01013e3:	b8 00 00 00 00       	mov    $0x0,%eax
f01013e8:	e9 29 ff ff ff       	jmp    f0101316 <pgdir_walk+0x40>

f01013ed <boot_map_region>:
{
f01013ed:	55                   	push   %ebp
f01013ee:	89 e5                	mov    %esp,%ebp
f01013f0:	57                   	push   %edi
f01013f1:	56                   	push   %esi
f01013f2:	53                   	push   %ebx
f01013f3:	83 ec 1c             	sub    $0x1c,%esp
f01013f6:	89 c7                	mov    %eax,%edi
f01013f8:	89 d6                	mov    %edx,%esi
f01013fa:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f01013fd:	bb 00 00 00 00       	mov    $0x0,%ebx
		*page_entry = (pa + size0) | perm | PTE_P;
f0101402:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101405:	83 c8 01             	or     $0x1,%eax
f0101408:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f010140b:	eb 22                	jmp    f010142f <boot_map_region+0x42>
		pte_t *page_entry = pgdir_walk(pgdir, (void*) va + size0, 1);
f010140d:	83 ec 04             	sub    $0x4,%esp
f0101410:	6a 01                	push   $0x1
f0101412:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f0101415:	50                   	push   %eax
f0101416:	57                   	push   %edi
f0101417:	e8 ba fe ff ff       	call   f01012d6 <pgdir_walk>
		*page_entry = (pa + size0) | perm | PTE_P;
f010141c:	89 da                	mov    %ebx,%edx
f010141e:	03 55 08             	add    0x8(%ebp),%edx
f0101421:	0b 55 e0             	or     -0x20(%ebp),%edx
f0101424:	89 10                	mov    %edx,(%eax)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f0101426:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010142c:	83 c4 10             	add    $0x10,%esp
f010142f:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101432:	72 d9                	jb     f010140d <boot_map_region+0x20>
}
f0101434:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101437:	5b                   	pop    %ebx
f0101438:	5e                   	pop    %esi
f0101439:	5f                   	pop    %edi
f010143a:	5d                   	pop    %ebp
f010143b:	c3                   	ret    

f010143c <page_lookup>:
{
f010143c:	55                   	push   %ebp
f010143d:	89 e5                	mov    %esp,%ebp
f010143f:	53                   	push   %ebx
f0101440:	83 ec 08             	sub    $0x8,%esp
f0101443:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *page_entry = pgdir_walk(pgdir, (void*) va, 0);
f0101446:	6a 00                	push   $0x0
f0101448:	ff 75 0c             	pushl  0xc(%ebp)
f010144b:	ff 75 08             	pushl  0x8(%ebp)
f010144e:	e8 83 fe ff ff       	call   f01012d6 <pgdir_walk>
	if (!page_entry || !*page_entry)
f0101453:	83 c4 10             	add    $0x10,%esp
f0101456:	85 c0                	test   %eax,%eax
f0101458:	74 3a                	je     f0101494 <page_lookup+0x58>
f010145a:	83 38 00             	cmpl   $0x0,(%eax)
f010145d:	74 3c                	je     f010149b <page_lookup+0x5f>
	if (pte_store)
f010145f:	85 db                	test   %ebx,%ebx
f0101461:	74 02                	je     f0101465 <page_lookup+0x29>
		*pte_store = page_entry;
f0101463:	89 03                	mov    %eax,(%ebx)
f0101465:	8b 00                	mov    (%eax),%eax
f0101467:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010146a:	39 05 64 99 11 f0    	cmp    %eax,0xf0119964
f0101470:	76 0e                	jbe    f0101480 <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0101472:	8b 15 6c 99 11 f0    	mov    0xf011996c,%edx
f0101478:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f010147b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010147e:	c9                   	leave  
f010147f:	c3                   	ret    
		panic("pa2page called with invalid pa");
f0101480:	83 ec 04             	sub    $0x4,%esp
f0101483:	68 a8 47 10 f0       	push   $0xf01047a8
f0101488:	6a 4b                	push   $0x4b
f010148a:	68 fc 4d 10 f0       	push   $0xf0104dfc
f010148f:	e8 9f ec ff ff       	call   f0100133 <_panic>
		return NULL;
f0101494:	b8 00 00 00 00       	mov    $0x0,%eax
f0101499:	eb e0                	jmp    f010147b <page_lookup+0x3f>
f010149b:	b8 00 00 00 00       	mov    $0x0,%eax
f01014a0:	eb d9                	jmp    f010147b <page_lookup+0x3f>

f01014a2 <page_remove>:
{
f01014a2:	55                   	push   %ebp
f01014a3:	89 e5                	mov    %esp,%ebp
f01014a5:	53                   	push   %ebx
f01014a6:	83 ec 18             	sub    $0x18,%esp
f01014a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo *pp = page_lookup(pgdir, va, &pte_store);
f01014ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01014af:	50                   	push   %eax
f01014b0:	53                   	push   %ebx
f01014b1:	ff 75 08             	pushl  0x8(%ebp)
f01014b4:	e8 83 ff ff ff       	call   f010143c <page_lookup>
	if (!pp)
f01014b9:	83 c4 10             	add    $0x10,%esp
f01014bc:	85 c0                	test   %eax,%eax
f01014be:	74 17                	je     f01014d7 <page_remove+0x35>
	pp->pp_ref--;
f01014c0:	66 ff 48 04          	decw   0x4(%eax)
	*pte_store = 0;
f01014c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01014c7:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01014cd:	0f 01 3b             	invlpg (%ebx)
	if (!pp->pp_ref)
f01014d0:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01014d5:	74 05                	je     f01014dc <page_remove+0x3a>
}
f01014d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01014da:	c9                   	leave  
f01014db:	c3                   	ret    
		page_free(pp);
f01014dc:	83 ec 0c             	sub    $0xc,%esp
f01014df:	50                   	push   %eax
f01014e0:	e8 79 fd ff ff       	call   f010125e <page_free>
f01014e5:	83 c4 10             	add    $0x10,%esp
f01014e8:	eb ed                	jmp    f01014d7 <page_remove+0x35>

f01014ea <page_insert>:
{
f01014ea:	55                   	push   %ebp
f01014eb:	89 e5                	mov    %esp,%ebp
f01014ed:	57                   	push   %edi
f01014ee:	56                   	push   %esi
f01014ef:	53                   	push   %ebx
f01014f0:	83 ec 10             	sub    $0x10,%esp
f01014f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01014f6:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *page_entry = pgdir_walk(pgdir, (void*) va, 1);
f01014f9:	6a 01                	push   $0x1
f01014fb:	57                   	push   %edi
f01014fc:	ff 75 08             	pushl  0x8(%ebp)
f01014ff:	e8 d2 fd ff ff       	call   f01012d6 <pgdir_walk>
	if (!page_entry)
f0101504:	83 c4 10             	add    $0x10,%esp
f0101507:	85 c0                	test   %eax,%eax
f0101509:	74 3f                	je     f010154a <page_insert+0x60>
f010150b:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f010150d:	66 ff 43 04          	incw   0x4(%ebx)
	if (*page_entry) 
f0101511:	83 38 00             	cmpl   $0x0,(%eax)
f0101514:	75 23                	jne    f0101539 <page_insert+0x4f>
	return (pp - pages) << PGSHIFT;
f0101516:	2b 1d 6c 99 11 f0    	sub    0xf011996c,%ebx
f010151c:	c1 fb 03             	sar    $0x3,%ebx
f010151f:	c1 e3 0c             	shl    $0xc,%ebx
	*page_entry = page2pa(pp) | perm | PTE_P;
f0101522:	8b 45 14             	mov    0x14(%ebp),%eax
f0101525:	83 c8 01             	or     $0x1,%eax
f0101528:	09 c3                	or     %eax,%ebx
f010152a:	89 1e                	mov    %ebx,(%esi)
	return 0;
f010152c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101531:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101534:	5b                   	pop    %ebx
f0101535:	5e                   	pop    %esi
f0101536:	5f                   	pop    %edi
f0101537:	5d                   	pop    %ebp
f0101538:	c3                   	ret    
		page_remove(pgdir, va);
f0101539:	83 ec 08             	sub    $0x8,%esp
f010153c:	57                   	push   %edi
f010153d:	ff 75 08             	pushl  0x8(%ebp)
f0101540:	e8 5d ff ff ff       	call   f01014a2 <page_remove>
f0101545:	83 c4 10             	add    $0x10,%esp
f0101548:	eb cc                	jmp    f0101516 <page_insert+0x2c>
		return -E_NO_MEM;  // Has no page table AND cannot be allocated
f010154a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010154f:	eb e0                	jmp    f0101531 <page_insert+0x47>

f0101551 <mem_init>:
{
f0101551:	55                   	push   %ebp
f0101552:	89 e5                	mov    %esp,%ebp
f0101554:	57                   	push   %edi
f0101555:	56                   	push   %esi
f0101556:	53                   	push   %ebx
f0101557:	83 ec 2c             	sub    $0x2c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f010155a:	b8 15 00 00 00       	mov    $0x15,%eax
f010155f:	e8 7f f8 ff ff       	call   f0100de3 <nvram_read>
f0101564:	89 c6                	mov    %eax,%esi
	extmem = nvram_read(NVRAM_EXTLO);
f0101566:	b8 17 00 00 00       	mov    $0x17,%eax
f010156b:	e8 73 f8 ff ff       	call   f0100de3 <nvram_read>
f0101570:	89 c3                	mov    %eax,%ebx
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101572:	b8 34 00 00 00       	mov    $0x34,%eax
f0101577:	e8 67 f8 ff ff       	call   f0100de3 <nvram_read>
	if (ext16mem)
f010157c:	c1 e0 06             	shl    $0x6,%eax
f010157f:	75 10                	jne    f0101591 <mem_init+0x40>
	else if (extmem)
f0101581:	85 db                	test   %ebx,%ebx
f0101583:	0f 84 c3 00 00 00    	je     f010164c <mem_init+0xfb>
		totalmem = 1 * 1024 + extmem;
f0101589:	8d 83 00 04 00 00    	lea    0x400(%ebx),%eax
f010158f:	eb 05                	jmp    f0101596 <mem_init+0x45>
		totalmem = 16 * 1024 + ext16mem;
f0101591:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101596:	89 c2                	mov    %eax,%edx
f0101598:	c1 ea 02             	shr    $0x2,%edx
f010159b:	89 15 64 99 11 f0    	mov    %edx,0xf0119964
	npages_basemem = basemem / (PGSIZE / 1024);
f01015a1:	89 f2                	mov    %esi,%edx
f01015a3:	c1 ea 02             	shr    $0x2,%edx
f01015a6:	89 15 40 95 11 f0    	mov    %edx,0xf0119540
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01015ac:	89 c2                	mov    %eax,%edx
f01015ae:	29 f2                	sub    %esi,%edx
f01015b0:	52                   	push   %edx
f01015b1:	56                   	push   %esi
f01015b2:	50                   	push   %eax
f01015b3:	68 c8 47 10 f0       	push   $0xf01047c8
f01015b8:	e8 06 18 00 00       	call   f0102dc3 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01015bd:	b8 00 10 00 00       	mov    $0x1000,%eax
f01015c2:	e8 d6 f7 ff ff       	call   f0100d9d <boot_alloc>
f01015c7:	a3 68 99 11 f0       	mov    %eax,0xf0119968
	memset(kern_pgdir, 0, PGSIZE);
f01015cc:	83 c4 0c             	add    $0xc,%esp
f01015cf:	68 00 10 00 00       	push   $0x1000
f01015d4:	6a 00                	push   $0x0
f01015d6:	50                   	push   %eax
f01015d7:	e8 16 23 00 00       	call   f01038f2 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01015dc:	a1 68 99 11 f0       	mov    0xf0119968,%eax
	if ((uint32_t)kva < KERNBASE)
f01015e1:	83 c4 10             	add    $0x10,%esp
f01015e4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01015e9:	76 68                	jbe    f0101653 <mem_init+0x102>
	return (physaddr_t)kva - KERNBASE;
f01015eb:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01015f1:	83 ca 05             	or     $0x5,%edx
f01015f4:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo)*npages);
f01015fa:	a1 64 99 11 f0       	mov    0xf0119964,%eax
f01015ff:	c1 e0 03             	shl    $0x3,%eax
f0101602:	e8 96 f7 ff ff       	call   f0100d9d <boot_alloc>
f0101607:	a3 6c 99 11 f0       	mov    %eax,0xf011996c
	memset(pages, 0, sizeof(struct PageInfo)*npages);
f010160c:	83 ec 04             	sub    $0x4,%esp
f010160f:	8b 0d 64 99 11 f0    	mov    0xf0119964,%ecx
f0101615:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f010161c:	52                   	push   %edx
f010161d:	6a 00                	push   $0x0
f010161f:	50                   	push   %eax
f0101620:	e8 cd 22 00 00       	call   f01038f2 <memset>
	page_init();
f0101625:	e8 06 fb ff ff       	call   f0101130 <page_init>
	check_page_free_list(1);
f010162a:	b8 01 00 00 00       	mov    $0x1,%eax
f010162f:	e8 35 f8 ff ff       	call   f0100e69 <check_page_free_list>
	if (!pages)
f0101634:	83 c4 10             	add    $0x10,%esp
f0101637:	83 3d 6c 99 11 f0 00 	cmpl   $0x0,0xf011996c
f010163e:	74 28                	je     f0101668 <mem_init+0x117>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101640:	a1 3c 95 11 f0       	mov    0xf011953c,%eax
f0101645:	bb 00 00 00 00       	mov    $0x0,%ebx
f010164a:	eb 36                	jmp    f0101682 <mem_init+0x131>
		totalmem = basemem;
f010164c:	89 f0                	mov    %esi,%eax
f010164e:	e9 43 ff ff ff       	jmp    f0101596 <mem_init+0x45>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101653:	50                   	push   %eax
f0101654:	68 84 47 10 f0       	push   $0xf0104784
f0101659:	68 91 00 00 00       	push   $0x91
f010165e:	68 f0 4d 10 f0       	push   $0xf0104df0
f0101663:	e8 cb ea ff ff       	call   f0100133 <_panic>
		panic("'pages' is a null pointer!");
f0101668:	83 ec 04             	sub    $0x4,%esp
f010166b:	68 d1 4e 10 f0       	push   $0xf0104ed1
f0101670:	68 41 02 00 00       	push   $0x241
f0101675:	68 f0 4d 10 f0       	push   $0xf0104df0
f010167a:	e8 b4 ea ff ff       	call   f0100133 <_panic>
		++nfree;
f010167f:	43                   	inc    %ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101680:	8b 00                	mov    (%eax),%eax
f0101682:	85 c0                	test   %eax,%eax
f0101684:	75 f9                	jne    f010167f <mem_init+0x12e>
	assert((pp0 = page_alloc(0)));
f0101686:	83 ec 0c             	sub    $0xc,%esp
f0101689:	6a 00                	push   $0x0
f010168b:	e8 5c fb ff ff       	call   f01011ec <page_alloc>
f0101690:	89 c7                	mov    %eax,%edi
f0101692:	83 c4 10             	add    $0x10,%esp
f0101695:	85 c0                	test   %eax,%eax
f0101697:	0f 84 10 02 00 00    	je     f01018ad <mem_init+0x35c>
	assert((pp1 = page_alloc(0)));
f010169d:	83 ec 0c             	sub    $0xc,%esp
f01016a0:	6a 00                	push   $0x0
f01016a2:	e8 45 fb ff ff       	call   f01011ec <page_alloc>
f01016a7:	89 c6                	mov    %eax,%esi
f01016a9:	83 c4 10             	add    $0x10,%esp
f01016ac:	85 c0                	test   %eax,%eax
f01016ae:	0f 84 12 02 00 00    	je     f01018c6 <mem_init+0x375>
	assert((pp2 = page_alloc(0)));
f01016b4:	83 ec 0c             	sub    $0xc,%esp
f01016b7:	6a 00                	push   $0x0
f01016b9:	e8 2e fb ff ff       	call   f01011ec <page_alloc>
f01016be:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01016c1:	83 c4 10             	add    $0x10,%esp
f01016c4:	85 c0                	test   %eax,%eax
f01016c6:	0f 84 13 02 00 00    	je     f01018df <mem_init+0x38e>
	assert(pp1 && pp1 != pp0);
f01016cc:	39 f7                	cmp    %esi,%edi
f01016ce:	0f 84 24 02 00 00    	je     f01018f8 <mem_init+0x3a7>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016d4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016d7:	39 c6                	cmp    %eax,%esi
f01016d9:	0f 84 32 02 00 00    	je     f0101911 <mem_init+0x3c0>
f01016df:	39 c7                	cmp    %eax,%edi
f01016e1:	0f 84 2a 02 00 00    	je     f0101911 <mem_init+0x3c0>
	return (pp - pages) << PGSHIFT;
f01016e7:	8b 0d 6c 99 11 f0    	mov    0xf011996c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01016ed:	8b 15 64 99 11 f0    	mov    0xf0119964,%edx
f01016f3:	c1 e2 0c             	shl    $0xc,%edx
f01016f6:	89 f8                	mov    %edi,%eax
f01016f8:	29 c8                	sub    %ecx,%eax
f01016fa:	c1 f8 03             	sar    $0x3,%eax
f01016fd:	c1 e0 0c             	shl    $0xc,%eax
f0101700:	39 d0                	cmp    %edx,%eax
f0101702:	0f 83 22 02 00 00    	jae    f010192a <mem_init+0x3d9>
f0101708:	89 f0                	mov    %esi,%eax
f010170a:	29 c8                	sub    %ecx,%eax
f010170c:	c1 f8 03             	sar    $0x3,%eax
f010170f:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101712:	39 c2                	cmp    %eax,%edx
f0101714:	0f 86 29 02 00 00    	jbe    f0101943 <mem_init+0x3f2>
f010171a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010171d:	29 c8                	sub    %ecx,%eax
f010171f:	c1 f8 03             	sar    $0x3,%eax
f0101722:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101725:	39 c2                	cmp    %eax,%edx
f0101727:	0f 86 2f 02 00 00    	jbe    f010195c <mem_init+0x40b>
	fl = page_free_list;
f010172d:	a1 3c 95 11 f0       	mov    0xf011953c,%eax
f0101732:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101735:	c7 05 3c 95 11 f0 00 	movl   $0x0,0xf011953c
f010173c:	00 00 00 
	assert(!page_alloc(0));
f010173f:	83 ec 0c             	sub    $0xc,%esp
f0101742:	6a 00                	push   $0x0
f0101744:	e8 a3 fa ff ff       	call   f01011ec <page_alloc>
f0101749:	83 c4 10             	add    $0x10,%esp
f010174c:	85 c0                	test   %eax,%eax
f010174e:	0f 85 21 02 00 00    	jne    f0101975 <mem_init+0x424>
	page_free(pp0);
f0101754:	83 ec 0c             	sub    $0xc,%esp
f0101757:	57                   	push   %edi
f0101758:	e8 01 fb ff ff       	call   f010125e <page_free>
	page_free(pp1);
f010175d:	89 34 24             	mov    %esi,(%esp)
f0101760:	e8 f9 fa ff ff       	call   f010125e <page_free>
	page_free(pp2);
f0101765:	83 c4 04             	add    $0x4,%esp
f0101768:	ff 75 d4             	pushl  -0x2c(%ebp)
f010176b:	e8 ee fa ff ff       	call   f010125e <page_free>
	assert((pp0 = page_alloc(0)));
f0101770:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101777:	e8 70 fa ff ff       	call   f01011ec <page_alloc>
f010177c:	89 c6                	mov    %eax,%esi
f010177e:	83 c4 10             	add    $0x10,%esp
f0101781:	85 c0                	test   %eax,%eax
f0101783:	0f 84 05 02 00 00    	je     f010198e <mem_init+0x43d>
	assert((pp1 = page_alloc(0)));
f0101789:	83 ec 0c             	sub    $0xc,%esp
f010178c:	6a 00                	push   $0x0
f010178e:	e8 59 fa ff ff       	call   f01011ec <page_alloc>
f0101793:	89 c7                	mov    %eax,%edi
f0101795:	83 c4 10             	add    $0x10,%esp
f0101798:	85 c0                	test   %eax,%eax
f010179a:	0f 84 07 02 00 00    	je     f01019a7 <mem_init+0x456>
	assert((pp2 = page_alloc(0)));
f01017a0:	83 ec 0c             	sub    $0xc,%esp
f01017a3:	6a 00                	push   $0x0
f01017a5:	e8 42 fa ff ff       	call   f01011ec <page_alloc>
f01017aa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017ad:	83 c4 10             	add    $0x10,%esp
f01017b0:	85 c0                	test   %eax,%eax
f01017b2:	0f 84 08 02 00 00    	je     f01019c0 <mem_init+0x46f>
	assert(pp1 && pp1 != pp0);
f01017b8:	39 fe                	cmp    %edi,%esi
f01017ba:	0f 84 19 02 00 00    	je     f01019d9 <mem_init+0x488>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017c3:	39 c7                	cmp    %eax,%edi
f01017c5:	0f 84 27 02 00 00    	je     f01019f2 <mem_init+0x4a1>
f01017cb:	39 c6                	cmp    %eax,%esi
f01017cd:	0f 84 1f 02 00 00    	je     f01019f2 <mem_init+0x4a1>
	assert(!page_alloc(0));
f01017d3:	83 ec 0c             	sub    $0xc,%esp
f01017d6:	6a 00                	push   $0x0
f01017d8:	e8 0f fa ff ff       	call   f01011ec <page_alloc>
f01017dd:	83 c4 10             	add    $0x10,%esp
f01017e0:	85 c0                	test   %eax,%eax
f01017e2:	0f 85 23 02 00 00    	jne    f0101a0b <mem_init+0x4ba>
f01017e8:	89 f0                	mov    %esi,%eax
f01017ea:	2b 05 6c 99 11 f0    	sub    0xf011996c,%eax
f01017f0:	c1 f8 03             	sar    $0x3,%eax
f01017f3:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01017f6:	89 c2                	mov    %eax,%edx
f01017f8:	c1 ea 0c             	shr    $0xc,%edx
f01017fb:	3b 15 64 99 11 f0    	cmp    0xf0119964,%edx
f0101801:	0f 83 1d 02 00 00    	jae    f0101a24 <mem_init+0x4d3>
	memset(page2kva(pp0), 1, PGSIZE);
f0101807:	83 ec 04             	sub    $0x4,%esp
f010180a:	68 00 10 00 00       	push   $0x1000
f010180f:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101811:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101816:	50                   	push   %eax
f0101817:	e8 d6 20 00 00       	call   f01038f2 <memset>
	page_free(pp0);
f010181c:	89 34 24             	mov    %esi,(%esp)
f010181f:	e8 3a fa ff ff       	call   f010125e <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101824:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010182b:	e8 bc f9 ff ff       	call   f01011ec <page_alloc>
f0101830:	83 c4 10             	add    $0x10,%esp
f0101833:	85 c0                	test   %eax,%eax
f0101835:	0f 84 fb 01 00 00    	je     f0101a36 <mem_init+0x4e5>
	assert(pp && pp0 == pp);
f010183b:	39 c6                	cmp    %eax,%esi
f010183d:	0f 85 0c 02 00 00    	jne    f0101a4f <mem_init+0x4fe>
	return (pp - pages) << PGSHIFT;
f0101843:	89 f2                	mov    %esi,%edx
f0101845:	2b 15 6c 99 11 f0    	sub    0xf011996c,%edx
f010184b:	c1 fa 03             	sar    $0x3,%edx
f010184e:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101851:	89 d0                	mov    %edx,%eax
f0101853:	c1 e8 0c             	shr    $0xc,%eax
f0101856:	3b 05 64 99 11 f0    	cmp    0xf0119964,%eax
f010185c:	0f 83 06 02 00 00    	jae    f0101a68 <mem_init+0x517>
	return (void *)(pa + KERNBASE);
f0101862:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101868:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f010186e:	80 38 00             	cmpb   $0x0,(%eax)
f0101871:	0f 85 03 02 00 00    	jne    f0101a7a <mem_init+0x529>
f0101877:	40                   	inc    %eax
	for (i = 0; i < PGSIZE; i++)
f0101878:	39 d0                	cmp    %edx,%eax
f010187a:	75 f2                	jne    f010186e <mem_init+0x31d>
	page_free_list = fl;
f010187c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010187f:	a3 3c 95 11 f0       	mov    %eax,0xf011953c
	page_free(pp0);
f0101884:	83 ec 0c             	sub    $0xc,%esp
f0101887:	56                   	push   %esi
f0101888:	e8 d1 f9 ff ff       	call   f010125e <page_free>
	page_free(pp1);
f010188d:	89 3c 24             	mov    %edi,(%esp)
f0101890:	e8 c9 f9 ff ff       	call   f010125e <page_free>
	page_free(pp2);
f0101895:	83 c4 04             	add    $0x4,%esp
f0101898:	ff 75 d4             	pushl  -0x2c(%ebp)
f010189b:	e8 be f9 ff ff       	call   f010125e <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01018a0:	a1 3c 95 11 f0       	mov    0xf011953c,%eax
f01018a5:	83 c4 10             	add    $0x10,%esp
f01018a8:	e9 e9 01 00 00       	jmp    f0101a96 <mem_init+0x545>
	assert((pp0 = page_alloc(0)));
f01018ad:	68 ec 4e 10 f0       	push   $0xf0104eec
f01018b2:	68 16 4e 10 f0       	push   $0xf0104e16
f01018b7:	68 49 02 00 00       	push   $0x249
f01018bc:	68 f0 4d 10 f0       	push   $0xf0104df0
f01018c1:	e8 6d e8 ff ff       	call   f0100133 <_panic>
	assert((pp1 = page_alloc(0)));
f01018c6:	68 02 4f 10 f0       	push   $0xf0104f02
f01018cb:	68 16 4e 10 f0       	push   $0xf0104e16
f01018d0:	68 4a 02 00 00       	push   $0x24a
f01018d5:	68 f0 4d 10 f0       	push   $0xf0104df0
f01018da:	e8 54 e8 ff ff       	call   f0100133 <_panic>
	assert((pp2 = page_alloc(0)));
f01018df:	68 18 4f 10 f0       	push   $0xf0104f18
f01018e4:	68 16 4e 10 f0       	push   $0xf0104e16
f01018e9:	68 4b 02 00 00       	push   $0x24b
f01018ee:	68 f0 4d 10 f0       	push   $0xf0104df0
f01018f3:	e8 3b e8 ff ff       	call   f0100133 <_panic>
	assert(pp1 && pp1 != pp0);
f01018f8:	68 2e 4f 10 f0       	push   $0xf0104f2e
f01018fd:	68 16 4e 10 f0       	push   $0xf0104e16
f0101902:	68 4e 02 00 00       	push   $0x24e
f0101907:	68 f0 4d 10 f0       	push   $0xf0104df0
f010190c:	e8 22 e8 ff ff       	call   f0100133 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101911:	68 04 48 10 f0       	push   $0xf0104804
f0101916:	68 16 4e 10 f0       	push   $0xf0104e16
f010191b:	68 4f 02 00 00       	push   $0x24f
f0101920:	68 f0 4d 10 f0       	push   $0xf0104df0
f0101925:	e8 09 e8 ff ff       	call   f0100133 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f010192a:	68 40 4f 10 f0       	push   $0xf0104f40
f010192f:	68 16 4e 10 f0       	push   $0xf0104e16
f0101934:	68 50 02 00 00       	push   $0x250
f0101939:	68 f0 4d 10 f0       	push   $0xf0104df0
f010193e:	e8 f0 e7 ff ff       	call   f0100133 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101943:	68 5d 4f 10 f0       	push   $0xf0104f5d
f0101948:	68 16 4e 10 f0       	push   $0xf0104e16
f010194d:	68 51 02 00 00       	push   $0x251
f0101952:	68 f0 4d 10 f0       	push   $0xf0104df0
f0101957:	e8 d7 e7 ff ff       	call   f0100133 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010195c:	68 7a 4f 10 f0       	push   $0xf0104f7a
f0101961:	68 16 4e 10 f0       	push   $0xf0104e16
f0101966:	68 52 02 00 00       	push   $0x252
f010196b:	68 f0 4d 10 f0       	push   $0xf0104df0
f0101970:	e8 be e7 ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f0101975:	68 97 4f 10 f0       	push   $0xf0104f97
f010197a:	68 16 4e 10 f0       	push   $0xf0104e16
f010197f:	68 59 02 00 00       	push   $0x259
f0101984:	68 f0 4d 10 f0       	push   $0xf0104df0
f0101989:	e8 a5 e7 ff ff       	call   f0100133 <_panic>
	assert((pp0 = page_alloc(0)));
f010198e:	68 ec 4e 10 f0       	push   $0xf0104eec
f0101993:	68 16 4e 10 f0       	push   $0xf0104e16
f0101998:	68 60 02 00 00       	push   $0x260
f010199d:	68 f0 4d 10 f0       	push   $0xf0104df0
f01019a2:	e8 8c e7 ff ff       	call   f0100133 <_panic>
	assert((pp1 = page_alloc(0)));
f01019a7:	68 02 4f 10 f0       	push   $0xf0104f02
f01019ac:	68 16 4e 10 f0       	push   $0xf0104e16
f01019b1:	68 61 02 00 00       	push   $0x261
f01019b6:	68 f0 4d 10 f0       	push   $0xf0104df0
f01019bb:	e8 73 e7 ff ff       	call   f0100133 <_panic>
	assert((pp2 = page_alloc(0)));
f01019c0:	68 18 4f 10 f0       	push   $0xf0104f18
f01019c5:	68 16 4e 10 f0       	push   $0xf0104e16
f01019ca:	68 62 02 00 00       	push   $0x262
f01019cf:	68 f0 4d 10 f0       	push   $0xf0104df0
f01019d4:	e8 5a e7 ff ff       	call   f0100133 <_panic>
	assert(pp1 && pp1 != pp0);
f01019d9:	68 2e 4f 10 f0       	push   $0xf0104f2e
f01019de:	68 16 4e 10 f0       	push   $0xf0104e16
f01019e3:	68 64 02 00 00       	push   $0x264
f01019e8:	68 f0 4d 10 f0       	push   $0xf0104df0
f01019ed:	e8 41 e7 ff ff       	call   f0100133 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019f2:	68 04 48 10 f0       	push   $0xf0104804
f01019f7:	68 16 4e 10 f0       	push   $0xf0104e16
f01019fc:	68 65 02 00 00       	push   $0x265
f0101a01:	68 f0 4d 10 f0       	push   $0xf0104df0
f0101a06:	e8 28 e7 ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f0101a0b:	68 97 4f 10 f0       	push   $0xf0104f97
f0101a10:	68 16 4e 10 f0       	push   $0xf0104e16
f0101a15:	68 66 02 00 00       	push   $0x266
f0101a1a:	68 f0 4d 10 f0       	push   $0xf0104df0
f0101a1f:	e8 0f e7 ff ff       	call   f0100133 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a24:	50                   	push   %eax
f0101a25:	68 d0 44 10 f0       	push   $0xf01044d0
f0101a2a:	6a 52                	push   $0x52
f0101a2c:	68 fc 4d 10 f0       	push   $0xf0104dfc
f0101a31:	e8 fd e6 ff ff       	call   f0100133 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101a36:	68 a6 4f 10 f0       	push   $0xf0104fa6
f0101a3b:	68 16 4e 10 f0       	push   $0xf0104e16
f0101a40:	68 6b 02 00 00       	push   $0x26b
f0101a45:	68 f0 4d 10 f0       	push   $0xf0104df0
f0101a4a:	e8 e4 e6 ff ff       	call   f0100133 <_panic>
	assert(pp && pp0 == pp);
f0101a4f:	68 c4 4f 10 f0       	push   $0xf0104fc4
f0101a54:	68 16 4e 10 f0       	push   $0xf0104e16
f0101a59:	68 6c 02 00 00       	push   $0x26c
f0101a5e:	68 f0 4d 10 f0       	push   $0xf0104df0
f0101a63:	e8 cb e6 ff ff       	call   f0100133 <_panic>
f0101a68:	52                   	push   %edx
f0101a69:	68 d0 44 10 f0       	push   $0xf01044d0
f0101a6e:	6a 52                	push   $0x52
f0101a70:	68 fc 4d 10 f0       	push   $0xf0104dfc
f0101a75:	e8 b9 e6 ff ff       	call   f0100133 <_panic>
		assert(c[i] == 0);
f0101a7a:	68 d4 4f 10 f0       	push   $0xf0104fd4
f0101a7f:	68 16 4e 10 f0       	push   $0xf0104e16
f0101a84:	68 6f 02 00 00       	push   $0x26f
f0101a89:	68 f0 4d 10 f0       	push   $0xf0104df0
f0101a8e:	e8 a0 e6 ff ff       	call   f0100133 <_panic>
		--nfree;
f0101a93:	4b                   	dec    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a94:	8b 00                	mov    (%eax),%eax
f0101a96:	85 c0                	test   %eax,%eax
f0101a98:	75 f9                	jne    f0101a93 <mem_init+0x542>
	assert(nfree == 0);
f0101a9a:	85 db                	test   %ebx,%ebx
f0101a9c:	0f 85 9c 07 00 00    	jne    f010223e <mem_init+0xced>
	cprintf("check_page_alloc() succeeded!\n");
f0101aa2:	83 ec 0c             	sub    $0xc,%esp
f0101aa5:	68 24 48 10 f0       	push   $0xf0104824
f0101aaa:	e8 14 13 00 00       	call   f0102dc3 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101aaf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ab6:	e8 31 f7 ff ff       	call   f01011ec <page_alloc>
f0101abb:	89 c7                	mov    %eax,%edi
f0101abd:	83 c4 10             	add    $0x10,%esp
f0101ac0:	85 c0                	test   %eax,%eax
f0101ac2:	0f 84 8f 07 00 00    	je     f0102257 <mem_init+0xd06>
	assert((pp1 = page_alloc(0)));
f0101ac8:	83 ec 0c             	sub    $0xc,%esp
f0101acb:	6a 00                	push   $0x0
f0101acd:	e8 1a f7 ff ff       	call   f01011ec <page_alloc>
f0101ad2:	89 c3                	mov    %eax,%ebx
f0101ad4:	83 c4 10             	add    $0x10,%esp
f0101ad7:	85 c0                	test   %eax,%eax
f0101ad9:	0f 84 91 07 00 00    	je     f0102270 <mem_init+0xd1f>
	assert((pp2 = page_alloc(0)));
f0101adf:	83 ec 0c             	sub    $0xc,%esp
f0101ae2:	6a 00                	push   $0x0
f0101ae4:	e8 03 f7 ff ff       	call   f01011ec <page_alloc>
f0101ae9:	89 c6                	mov    %eax,%esi
f0101aeb:	83 c4 10             	add    $0x10,%esp
f0101aee:	85 c0                	test   %eax,%eax
f0101af0:	0f 84 93 07 00 00    	je     f0102289 <mem_init+0xd38>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101af6:	39 df                	cmp    %ebx,%edi
f0101af8:	0f 84 a4 07 00 00    	je     f01022a2 <mem_init+0xd51>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101afe:	39 c3                	cmp    %eax,%ebx
f0101b00:	0f 84 b5 07 00 00    	je     f01022bb <mem_init+0xd6a>
f0101b06:	39 c7                	cmp    %eax,%edi
f0101b08:	0f 84 ad 07 00 00    	je     f01022bb <mem_init+0xd6a>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101b0e:	a1 3c 95 11 f0       	mov    0xf011953c,%eax
f0101b13:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f0101b16:	c7 05 3c 95 11 f0 00 	movl   $0x0,0xf011953c
f0101b1d:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101b20:	83 ec 0c             	sub    $0xc,%esp
f0101b23:	6a 00                	push   $0x0
f0101b25:	e8 c2 f6 ff ff       	call   f01011ec <page_alloc>
f0101b2a:	83 c4 10             	add    $0x10,%esp
f0101b2d:	85 c0                	test   %eax,%eax
f0101b2f:	0f 85 9f 07 00 00    	jne    f01022d4 <mem_init+0xd83>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101b35:	83 ec 04             	sub    $0x4,%esp
f0101b38:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101b3b:	50                   	push   %eax
f0101b3c:	6a 00                	push   $0x0
f0101b3e:	ff 35 68 99 11 f0    	pushl  0xf0119968
f0101b44:	e8 f3 f8 ff ff       	call   f010143c <page_lookup>
f0101b49:	83 c4 10             	add    $0x10,%esp
f0101b4c:	85 c0                	test   %eax,%eax
f0101b4e:	0f 85 99 07 00 00    	jne    f01022ed <mem_init+0xd9c>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101b54:	6a 02                	push   $0x2
f0101b56:	6a 00                	push   $0x0
f0101b58:	53                   	push   %ebx
f0101b59:	ff 35 68 99 11 f0    	pushl  0xf0119968
f0101b5f:	e8 86 f9 ff ff       	call   f01014ea <page_insert>
f0101b64:	83 c4 10             	add    $0x10,%esp
f0101b67:	85 c0                	test   %eax,%eax
f0101b69:	0f 89 97 07 00 00    	jns    f0102306 <mem_init+0xdb5>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101b6f:	83 ec 0c             	sub    $0xc,%esp
f0101b72:	57                   	push   %edi
f0101b73:	e8 e6 f6 ff ff       	call   f010125e <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b78:	6a 02                	push   $0x2
f0101b7a:	6a 00                	push   $0x0
f0101b7c:	53                   	push   %ebx
f0101b7d:	ff 35 68 99 11 f0    	pushl  0xf0119968
f0101b83:	e8 62 f9 ff ff       	call   f01014ea <page_insert>
f0101b88:	83 c4 20             	add    $0x20,%esp
f0101b8b:	85 c0                	test   %eax,%eax
f0101b8d:	0f 85 8c 07 00 00    	jne    f010231f <mem_init+0xdce>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b93:	a1 68 99 11 f0       	mov    0xf0119968,%eax
f0101b98:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	return (pp - pages) << PGSHIFT;
f0101b9b:	8b 0d 6c 99 11 f0    	mov    0xf011996c,%ecx
f0101ba1:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101ba4:	8b 00                	mov    (%eax),%eax
f0101ba6:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101ba9:	89 c2                	mov    %eax,%edx
f0101bab:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101bb1:	89 f8                	mov    %edi,%eax
f0101bb3:	29 c8                	sub    %ecx,%eax
f0101bb5:	c1 f8 03             	sar    $0x3,%eax
f0101bb8:	c1 e0 0c             	shl    $0xc,%eax
f0101bbb:	39 c2                	cmp    %eax,%edx
f0101bbd:	0f 85 75 07 00 00    	jne    f0102338 <mem_init+0xde7>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101bc3:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bc8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bcb:	e8 3a f2 ff ff       	call   f0100e0a <check_va2pa>
f0101bd0:	89 da                	mov    %ebx,%edx
f0101bd2:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101bd5:	c1 fa 03             	sar    $0x3,%edx
f0101bd8:	c1 e2 0c             	shl    $0xc,%edx
f0101bdb:	39 d0                	cmp    %edx,%eax
f0101bdd:	0f 85 6e 07 00 00    	jne    f0102351 <mem_init+0xe00>
	assert(pp1->pp_ref == 1);
f0101be3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101be8:	0f 85 7c 07 00 00    	jne    f010236a <mem_init+0xe19>
	assert(pp0->pp_ref == 1);
f0101bee:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101bf3:	0f 85 8a 07 00 00    	jne    f0102383 <mem_init+0xe32>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bf9:	6a 02                	push   $0x2
f0101bfb:	68 00 10 00 00       	push   $0x1000
f0101c00:	56                   	push   %esi
f0101c01:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c04:	e8 e1 f8 ff ff       	call   f01014ea <page_insert>
f0101c09:	83 c4 10             	add    $0x10,%esp
f0101c0c:	85 c0                	test   %eax,%eax
f0101c0e:	0f 85 88 07 00 00    	jne    f010239c <mem_init+0xe4b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c14:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c19:	a1 68 99 11 f0       	mov    0xf0119968,%eax
f0101c1e:	e8 e7 f1 ff ff       	call   f0100e0a <check_va2pa>
f0101c23:	89 f2                	mov    %esi,%edx
f0101c25:	2b 15 6c 99 11 f0    	sub    0xf011996c,%edx
f0101c2b:	c1 fa 03             	sar    $0x3,%edx
f0101c2e:	c1 e2 0c             	shl    $0xc,%edx
f0101c31:	39 d0                	cmp    %edx,%eax
f0101c33:	0f 85 7c 07 00 00    	jne    f01023b5 <mem_init+0xe64>
	assert(pp2->pp_ref == 1);
f0101c39:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c3e:	0f 85 8a 07 00 00    	jne    f01023ce <mem_init+0xe7d>

	// should be no free memory
	assert(!page_alloc(0));
f0101c44:	83 ec 0c             	sub    $0xc,%esp
f0101c47:	6a 00                	push   $0x0
f0101c49:	e8 9e f5 ff ff       	call   f01011ec <page_alloc>
f0101c4e:	83 c4 10             	add    $0x10,%esp
f0101c51:	85 c0                	test   %eax,%eax
f0101c53:	0f 85 8e 07 00 00    	jne    f01023e7 <mem_init+0xe96>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c59:	6a 02                	push   $0x2
f0101c5b:	68 00 10 00 00       	push   $0x1000
f0101c60:	56                   	push   %esi
f0101c61:	ff 35 68 99 11 f0    	pushl  0xf0119968
f0101c67:	e8 7e f8 ff ff       	call   f01014ea <page_insert>
f0101c6c:	83 c4 10             	add    $0x10,%esp
f0101c6f:	85 c0                	test   %eax,%eax
f0101c71:	0f 85 89 07 00 00    	jne    f0102400 <mem_init+0xeaf>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c77:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c7c:	a1 68 99 11 f0       	mov    0xf0119968,%eax
f0101c81:	e8 84 f1 ff ff       	call   f0100e0a <check_va2pa>
f0101c86:	89 f2                	mov    %esi,%edx
f0101c88:	2b 15 6c 99 11 f0    	sub    0xf011996c,%edx
f0101c8e:	c1 fa 03             	sar    $0x3,%edx
f0101c91:	c1 e2 0c             	shl    $0xc,%edx
f0101c94:	39 d0                	cmp    %edx,%eax
f0101c96:	0f 85 7d 07 00 00    	jne    f0102419 <mem_init+0xec8>
	assert(pp2->pp_ref == 1);
f0101c9c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ca1:	0f 85 8b 07 00 00    	jne    f0102432 <mem_init+0xee1>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101ca7:	83 ec 0c             	sub    $0xc,%esp
f0101caa:	6a 00                	push   $0x0
f0101cac:	e8 3b f5 ff ff       	call   f01011ec <page_alloc>
f0101cb1:	83 c4 10             	add    $0x10,%esp
f0101cb4:	85 c0                	test   %eax,%eax
f0101cb6:	0f 85 8f 07 00 00    	jne    f010244b <mem_init+0xefa>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101cbc:	8b 15 68 99 11 f0    	mov    0xf0119968,%edx
f0101cc2:	8b 02                	mov    (%edx),%eax
f0101cc4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101cc9:	89 c1                	mov    %eax,%ecx
f0101ccb:	c1 e9 0c             	shr    $0xc,%ecx
f0101cce:	3b 0d 64 99 11 f0    	cmp    0xf0119964,%ecx
f0101cd4:	0f 83 8a 07 00 00    	jae    f0102464 <mem_init+0xf13>
	return (void *)(pa + KERNBASE);
f0101cda:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101cdf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101ce2:	83 ec 04             	sub    $0x4,%esp
f0101ce5:	6a 00                	push   $0x0
f0101ce7:	68 00 10 00 00       	push   $0x1000
f0101cec:	52                   	push   %edx
f0101ced:	e8 e4 f5 ff ff       	call   f01012d6 <pgdir_walk>
f0101cf2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101cf5:	8d 51 04             	lea    0x4(%ecx),%edx
f0101cf8:	83 c4 10             	add    $0x10,%esp
f0101cfb:	39 d0                	cmp    %edx,%eax
f0101cfd:	0f 85 76 07 00 00    	jne    f0102479 <mem_init+0xf28>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101d03:	6a 06                	push   $0x6
f0101d05:	68 00 10 00 00       	push   $0x1000
f0101d0a:	56                   	push   %esi
f0101d0b:	ff 35 68 99 11 f0    	pushl  0xf0119968
f0101d11:	e8 d4 f7 ff ff       	call   f01014ea <page_insert>
f0101d16:	83 c4 10             	add    $0x10,%esp
f0101d19:	85 c0                	test   %eax,%eax
f0101d1b:	0f 85 71 07 00 00    	jne    f0102492 <mem_init+0xf41>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d21:	a1 68 99 11 f0       	mov    0xf0119968,%eax
f0101d26:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101d29:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d2e:	e8 d7 f0 ff ff       	call   f0100e0a <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101d33:	89 f2                	mov    %esi,%edx
f0101d35:	2b 15 6c 99 11 f0    	sub    0xf011996c,%edx
f0101d3b:	c1 fa 03             	sar    $0x3,%edx
f0101d3e:	c1 e2 0c             	shl    $0xc,%edx
f0101d41:	39 d0                	cmp    %edx,%eax
f0101d43:	0f 85 62 07 00 00    	jne    f01024ab <mem_init+0xf5a>
	assert(pp2->pp_ref == 1);
f0101d49:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d4e:	0f 85 70 07 00 00    	jne    f01024c4 <mem_init+0xf73>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101d54:	83 ec 04             	sub    $0x4,%esp
f0101d57:	6a 00                	push   $0x0
f0101d59:	68 00 10 00 00       	push   $0x1000
f0101d5e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101d61:	e8 70 f5 ff ff       	call   f01012d6 <pgdir_walk>
f0101d66:	83 c4 10             	add    $0x10,%esp
f0101d69:	f6 00 04             	testb  $0x4,(%eax)
f0101d6c:	0f 84 6b 07 00 00    	je     f01024dd <mem_init+0xf8c>
	assert(kern_pgdir[0] & PTE_U);
f0101d72:	a1 68 99 11 f0       	mov    0xf0119968,%eax
f0101d77:	f6 00 04             	testb  $0x4,(%eax)
f0101d7a:	0f 84 76 07 00 00    	je     f01024f6 <mem_init+0xfa5>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d80:	6a 02                	push   $0x2
f0101d82:	68 00 10 00 00       	push   $0x1000
f0101d87:	56                   	push   %esi
f0101d88:	50                   	push   %eax
f0101d89:	e8 5c f7 ff ff       	call   f01014ea <page_insert>
f0101d8e:	83 c4 10             	add    $0x10,%esp
f0101d91:	85 c0                	test   %eax,%eax
f0101d93:	0f 85 76 07 00 00    	jne    f010250f <mem_init+0xfbe>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101d99:	83 ec 04             	sub    $0x4,%esp
f0101d9c:	6a 00                	push   $0x0
f0101d9e:	68 00 10 00 00       	push   $0x1000
f0101da3:	ff 35 68 99 11 f0    	pushl  0xf0119968
f0101da9:	e8 28 f5 ff ff       	call   f01012d6 <pgdir_walk>
f0101dae:	83 c4 10             	add    $0x10,%esp
f0101db1:	f6 00 02             	testb  $0x2,(%eax)
f0101db4:	0f 84 6e 07 00 00    	je     f0102528 <mem_init+0xfd7>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101dba:	83 ec 04             	sub    $0x4,%esp
f0101dbd:	6a 00                	push   $0x0
f0101dbf:	68 00 10 00 00       	push   $0x1000
f0101dc4:	ff 35 68 99 11 f0    	pushl  0xf0119968
f0101dca:	e8 07 f5 ff ff       	call   f01012d6 <pgdir_walk>
f0101dcf:	83 c4 10             	add    $0x10,%esp
f0101dd2:	f6 00 04             	testb  $0x4,(%eax)
f0101dd5:	0f 85 66 07 00 00    	jne    f0102541 <mem_init+0xff0>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101ddb:	6a 02                	push   $0x2
f0101ddd:	68 00 00 40 00       	push   $0x400000
f0101de2:	57                   	push   %edi
f0101de3:	ff 35 68 99 11 f0    	pushl  0xf0119968
f0101de9:	e8 fc f6 ff ff       	call   f01014ea <page_insert>
f0101dee:	83 c4 10             	add    $0x10,%esp
f0101df1:	85 c0                	test   %eax,%eax
f0101df3:	0f 89 61 07 00 00    	jns    f010255a <mem_init+0x1009>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101df9:	6a 02                	push   $0x2
f0101dfb:	68 00 10 00 00       	push   $0x1000
f0101e00:	53                   	push   %ebx
f0101e01:	ff 35 68 99 11 f0    	pushl  0xf0119968
f0101e07:	e8 de f6 ff ff       	call   f01014ea <page_insert>
f0101e0c:	83 c4 10             	add    $0x10,%esp
f0101e0f:	85 c0                	test   %eax,%eax
f0101e11:	0f 85 5c 07 00 00    	jne    f0102573 <mem_init+0x1022>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e17:	83 ec 04             	sub    $0x4,%esp
f0101e1a:	6a 00                	push   $0x0
f0101e1c:	68 00 10 00 00       	push   $0x1000
f0101e21:	ff 35 68 99 11 f0    	pushl  0xf0119968
f0101e27:	e8 aa f4 ff ff       	call   f01012d6 <pgdir_walk>
f0101e2c:	83 c4 10             	add    $0x10,%esp
f0101e2f:	f6 00 04             	testb  $0x4,(%eax)
f0101e32:	0f 85 54 07 00 00    	jne    f010258c <mem_init+0x103b>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101e38:	a1 68 99 11 f0       	mov    0xf0119968,%eax
f0101e3d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101e40:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e45:	e8 c0 ef ff ff       	call   f0100e0a <check_va2pa>
f0101e4a:	89 c1                	mov    %eax,%ecx
f0101e4c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101e4f:	89 d8                	mov    %ebx,%eax
f0101e51:	2b 05 6c 99 11 f0    	sub    0xf011996c,%eax
f0101e57:	c1 f8 03             	sar    $0x3,%eax
f0101e5a:	c1 e0 0c             	shl    $0xc,%eax
f0101e5d:	39 c1                	cmp    %eax,%ecx
f0101e5f:	0f 85 40 07 00 00    	jne    f01025a5 <mem_init+0x1054>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e65:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e6a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e6d:	e8 98 ef ff ff       	call   f0100e0a <check_va2pa>
f0101e72:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101e75:	0f 85 43 07 00 00    	jne    f01025be <mem_init+0x106d>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101e7b:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101e80:	0f 85 51 07 00 00    	jne    f01025d7 <mem_init+0x1086>
	assert(pp2->pp_ref == 0);
f0101e86:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101e8b:	0f 85 5f 07 00 00    	jne    f01025f0 <mem_init+0x109f>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101e91:	83 ec 0c             	sub    $0xc,%esp
f0101e94:	6a 00                	push   $0x0
f0101e96:	e8 51 f3 ff ff       	call   f01011ec <page_alloc>
f0101e9b:	83 c4 10             	add    $0x10,%esp
f0101e9e:	85 c0                	test   %eax,%eax
f0101ea0:	0f 84 63 07 00 00    	je     f0102609 <mem_init+0x10b8>
f0101ea6:	39 c6                	cmp    %eax,%esi
f0101ea8:	0f 85 5b 07 00 00    	jne    f0102609 <mem_init+0x10b8>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101eae:	83 ec 08             	sub    $0x8,%esp
f0101eb1:	6a 00                	push   $0x0
f0101eb3:	ff 35 68 99 11 f0    	pushl  0xf0119968
f0101eb9:	e8 e4 f5 ff ff       	call   f01014a2 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101ebe:	a1 68 99 11 f0       	mov    0xf0119968,%eax
f0101ec3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101ec6:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ecb:	e8 3a ef ff ff       	call   f0100e0a <check_va2pa>
f0101ed0:	83 c4 10             	add    $0x10,%esp
f0101ed3:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ed6:	0f 85 46 07 00 00    	jne    f0102622 <mem_init+0x10d1>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101edc:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ee1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ee4:	e8 21 ef ff ff       	call   f0100e0a <check_va2pa>
f0101ee9:	89 da                	mov    %ebx,%edx
f0101eeb:	2b 15 6c 99 11 f0    	sub    0xf011996c,%edx
f0101ef1:	c1 fa 03             	sar    $0x3,%edx
f0101ef4:	c1 e2 0c             	shl    $0xc,%edx
f0101ef7:	39 d0                	cmp    %edx,%eax
f0101ef9:	0f 85 3c 07 00 00    	jne    f010263b <mem_init+0x10ea>
	assert(pp1->pp_ref == 1);
f0101eff:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f04:	0f 85 4a 07 00 00    	jne    f0102654 <mem_init+0x1103>
	assert(pp2->pp_ref == 0);
f0101f0a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f0f:	0f 85 58 07 00 00    	jne    f010266d <mem_init+0x111c>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101f15:	6a 00                	push   $0x0
f0101f17:	68 00 10 00 00       	push   $0x1000
f0101f1c:	53                   	push   %ebx
f0101f1d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f20:	e8 c5 f5 ff ff       	call   f01014ea <page_insert>
f0101f25:	83 c4 10             	add    $0x10,%esp
f0101f28:	85 c0                	test   %eax,%eax
f0101f2a:	0f 85 56 07 00 00    	jne    f0102686 <mem_init+0x1135>
	assert(pp1->pp_ref);
f0101f30:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101f35:	0f 84 64 07 00 00    	je     f010269f <mem_init+0x114e>
	assert(pp1->pp_link == NULL);
f0101f3b:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101f3e:	0f 85 74 07 00 00    	jne    f01026b8 <mem_init+0x1167>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101f44:	83 ec 08             	sub    $0x8,%esp
f0101f47:	68 00 10 00 00       	push   $0x1000
f0101f4c:	ff 35 68 99 11 f0    	pushl  0xf0119968
f0101f52:	e8 4b f5 ff ff       	call   f01014a2 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f57:	a1 68 99 11 f0       	mov    0xf0119968,%eax
f0101f5c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f5f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f64:	e8 a1 ee ff ff       	call   f0100e0a <check_va2pa>
f0101f69:	83 c4 10             	add    $0x10,%esp
f0101f6c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f6f:	0f 85 5c 07 00 00    	jne    f01026d1 <mem_init+0x1180>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101f75:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f7a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f7d:	e8 88 ee ff ff       	call   f0100e0a <check_va2pa>
f0101f82:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f85:	0f 85 5f 07 00 00    	jne    f01026ea <mem_init+0x1199>
	assert(pp1->pp_ref == 0);
f0101f8b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101f90:	0f 85 6d 07 00 00    	jne    f0102703 <mem_init+0x11b2>
	assert(pp2->pp_ref == 0);
f0101f96:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f9b:	0f 85 7b 07 00 00    	jne    f010271c <mem_init+0x11cb>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101fa1:	83 ec 0c             	sub    $0xc,%esp
f0101fa4:	6a 00                	push   $0x0
f0101fa6:	e8 41 f2 ff ff       	call   f01011ec <page_alloc>
f0101fab:	83 c4 10             	add    $0x10,%esp
f0101fae:	85 c0                	test   %eax,%eax
f0101fb0:	0f 84 7f 07 00 00    	je     f0102735 <mem_init+0x11e4>
f0101fb6:	39 c3                	cmp    %eax,%ebx
f0101fb8:	0f 85 77 07 00 00    	jne    f0102735 <mem_init+0x11e4>

	// should be no free memory
	assert(!page_alloc(0));
f0101fbe:	83 ec 0c             	sub    $0xc,%esp
f0101fc1:	6a 00                	push   $0x0
f0101fc3:	e8 24 f2 ff ff       	call   f01011ec <page_alloc>
f0101fc8:	83 c4 10             	add    $0x10,%esp
f0101fcb:	85 c0                	test   %eax,%eax
f0101fcd:	0f 85 7b 07 00 00    	jne    f010274e <mem_init+0x11fd>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101fd3:	8b 0d 68 99 11 f0    	mov    0xf0119968,%ecx
f0101fd9:	8b 11                	mov    (%ecx),%edx
f0101fdb:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101fe1:	89 f8                	mov    %edi,%eax
f0101fe3:	2b 05 6c 99 11 f0    	sub    0xf011996c,%eax
f0101fe9:	c1 f8 03             	sar    $0x3,%eax
f0101fec:	c1 e0 0c             	shl    $0xc,%eax
f0101fef:	39 c2                	cmp    %eax,%edx
f0101ff1:	0f 85 70 07 00 00    	jne    f0102767 <mem_init+0x1216>
	kern_pgdir[0] = 0;
f0101ff7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101ffd:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102002:	0f 85 78 07 00 00    	jne    f0102780 <mem_init+0x122f>
	pp0->pp_ref = 0;
f0102008:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010200e:	83 ec 0c             	sub    $0xc,%esp
f0102011:	57                   	push   %edi
f0102012:	e8 47 f2 ff ff       	call   f010125e <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102017:	83 c4 0c             	add    $0xc,%esp
f010201a:	6a 01                	push   $0x1
f010201c:	68 00 10 40 00       	push   $0x401000
f0102021:	ff 35 68 99 11 f0    	pushl  0xf0119968
f0102027:	e8 aa f2 ff ff       	call   f01012d6 <pgdir_walk>
f010202c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010202f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102032:	a1 68 99 11 f0       	mov    0xf0119968,%eax
f0102037:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010203a:	8b 50 04             	mov    0x4(%eax),%edx
f010203d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0102043:	a1 64 99 11 f0       	mov    0xf0119964,%eax
f0102048:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010204b:	89 d1                	mov    %edx,%ecx
f010204d:	c1 e9 0c             	shr    $0xc,%ecx
f0102050:	83 c4 10             	add    $0x10,%esp
f0102053:	39 c1                	cmp    %eax,%ecx
f0102055:	0f 83 3e 07 00 00    	jae    f0102799 <mem_init+0x1248>
	assert(ptep == ptep1 + PTX(va));
f010205b:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102061:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0102064:	0f 85 44 07 00 00    	jne    f01027ae <mem_init+0x125d>
	kern_pgdir[PDX(va)] = 0;
f010206a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010206d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102074:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
	return (pp - pages) << PGSHIFT;
f010207a:	89 f8                	mov    %edi,%eax
f010207c:	2b 05 6c 99 11 f0    	sub    0xf011996c,%eax
f0102082:	c1 f8 03             	sar    $0x3,%eax
f0102085:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102088:	89 c2                	mov    %eax,%edx
f010208a:	c1 ea 0c             	shr    $0xc,%edx
f010208d:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f0102090:	0f 86 31 07 00 00    	jbe    f01027c7 <mem_init+0x1276>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102096:	83 ec 04             	sub    $0x4,%esp
f0102099:	68 00 10 00 00       	push   $0x1000
f010209e:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01020a3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01020a8:	50                   	push   %eax
f01020a9:	e8 44 18 00 00       	call   f01038f2 <memset>
	page_free(pp0);
f01020ae:	89 3c 24             	mov    %edi,(%esp)
f01020b1:	e8 a8 f1 ff ff       	call   f010125e <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01020b6:	83 c4 0c             	add    $0xc,%esp
f01020b9:	6a 01                	push   $0x1
f01020bb:	6a 00                	push   $0x0
f01020bd:	ff 35 68 99 11 f0    	pushl  0xf0119968
f01020c3:	e8 0e f2 ff ff       	call   f01012d6 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f01020c8:	89 fa                	mov    %edi,%edx
f01020ca:	2b 15 6c 99 11 f0    	sub    0xf011996c,%edx
f01020d0:	c1 fa 03             	sar    $0x3,%edx
f01020d3:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01020d6:	89 d0                	mov    %edx,%eax
f01020d8:	c1 e8 0c             	shr    $0xc,%eax
f01020db:	83 c4 10             	add    $0x10,%esp
f01020de:	3b 05 64 99 11 f0    	cmp    0xf0119964,%eax
f01020e4:	0f 83 ef 06 00 00    	jae    f01027d9 <mem_init+0x1288>
	return (void *)(pa + KERNBASE);
f01020ea:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01020f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01020f3:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01020f9:	f6 00 01             	testb  $0x1,(%eax)
f01020fc:	0f 85 e9 06 00 00    	jne    f01027eb <mem_init+0x129a>
f0102102:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0102105:	39 c2                	cmp    %eax,%edx
f0102107:	75 f0                	jne    f01020f9 <mem_init+0xba8>
	kern_pgdir[0] = 0;
f0102109:	a1 68 99 11 f0       	mov    0xf0119968,%eax
f010210e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102114:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f010211a:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010211d:	a3 3c 95 11 f0       	mov    %eax,0xf011953c

	// free the pages we took
	page_free(pp0);
f0102122:	83 ec 0c             	sub    $0xc,%esp
f0102125:	57                   	push   %edi
f0102126:	e8 33 f1 ff ff       	call   f010125e <page_free>
	page_free(pp1);
f010212b:	89 1c 24             	mov    %ebx,(%esp)
f010212e:	e8 2b f1 ff ff       	call   f010125e <page_free>
	page_free(pp2);
f0102133:	89 34 24             	mov    %esi,(%esp)
f0102136:	e8 23 f1 ff ff       	call   f010125e <page_free>

	cprintf("check_page() succeeded!\n");
f010213b:	c7 04 24 b5 50 10 f0 	movl   $0xf01050b5,(%esp)
f0102142:	e8 7c 0c 00 00       	call   f0102dc3 <cprintf>
	sz = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102147:	a1 64 99 11 f0       	mov    0xf0119964,%eax
f010214c:	8d 0c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ecx
f0102153:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_region(kern_pgdir, UPAGES, sz, PADDR(pages), PTE_U | PTE_P);
f0102159:	a1 6c 99 11 f0       	mov    0xf011996c,%eax
	if ((uint32_t)kva < KERNBASE)
f010215e:	83 c4 10             	add    $0x10,%esp
f0102161:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102166:	0f 86 98 06 00 00    	jbe    f0102804 <mem_init+0x12b3>
f010216c:	83 ec 08             	sub    $0x8,%esp
f010216f:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102171:	05 00 00 00 10       	add    $0x10000000,%eax
f0102176:	50                   	push   %eax
f0102177:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010217c:	a1 68 99 11 f0       	mov    0xf0119968,%eax
f0102181:	e8 67 f2 ff ff       	call   f01013ed <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0102186:	83 c4 10             	add    $0x10,%esp
f0102189:	b8 00 f0 10 f0       	mov    $0xf010f000,%eax
f010218e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102193:	0f 86 80 06 00 00    	jbe    f0102819 <mem_init+0x12c8>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, 
f0102199:	83 ec 08             	sub    $0x8,%esp
f010219c:	6a 03                	push   $0x3
f010219e:	68 00 f0 10 00       	push   $0x10f000
f01021a3:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01021a8:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01021ad:	a1 68 99 11 f0       	mov    0xf0119968,%eax
f01021b2:	e8 36 f2 ff ff       	call   f01013ed <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 1 << 28, // 2^32 - 0xf0000000
f01021b7:	83 c4 08             	add    $0x8,%esp
f01021ba:	6a 03                	push   $0x3
f01021bc:	6a 00                	push   $0x0
f01021be:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01021c3:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01021c8:	a1 68 99 11 f0       	mov    0xf0119968,%eax
f01021cd:	e8 1b f2 ff ff       	call   f01013ed <boot_map_region>
	pgdir = kern_pgdir;
f01021d2:	8b 1d 68 99 11 f0    	mov    0xf0119968,%ebx
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01021d8:	a1 64 99 11 f0       	mov    0xf0119964,%eax
f01021dd:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01021e0:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01021e7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01021ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01021ef:	a1 6c 99 11 f0       	mov    0xf011996c,%eax
f01021f4:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01021f7:	89 45 d0             	mov    %eax,-0x30(%ebp)
	return (physaddr_t)kva - KERNBASE;
f01021fa:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f0102200:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i += PGSIZE) 
f0102203:	be 00 00 00 00       	mov    $0x0,%esi
f0102208:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f010220b:	0f 86 4d 06 00 00    	jbe    f010285e <mem_init+0x130d>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102211:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f0102217:	89 d8                	mov    %ebx,%eax
f0102219:	e8 ec eb ff ff       	call   f0100e0a <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f010221e:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102225:	0f 86 03 06 00 00    	jbe    f010282e <mem_init+0x12dd>
f010222b:	8d 14 3e             	lea    (%esi,%edi,1),%edx
f010222e:	39 d0                	cmp    %edx,%eax
f0102230:	0f 85 0f 06 00 00    	jne    f0102845 <mem_init+0x12f4>
	for (i = 0; i < n; i += PGSIZE) 
f0102236:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010223c:	eb ca                	jmp    f0102208 <mem_init+0xcb7>
	assert(nfree == 0);
f010223e:	68 de 4f 10 f0       	push   $0xf0104fde
f0102243:	68 16 4e 10 f0       	push   $0xf0104e16
f0102248:	68 7c 02 00 00       	push   $0x27c
f010224d:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102252:	e8 dc de ff ff       	call   f0100133 <_panic>
	assert((pp0 = page_alloc(0)));
f0102257:	68 ec 4e 10 f0       	push   $0xf0104eec
f010225c:	68 16 4e 10 f0       	push   $0xf0104e16
f0102261:	68 d6 02 00 00       	push   $0x2d6
f0102266:	68 f0 4d 10 f0       	push   $0xf0104df0
f010226b:	e8 c3 de ff ff       	call   f0100133 <_panic>
	assert((pp1 = page_alloc(0)));
f0102270:	68 02 4f 10 f0       	push   $0xf0104f02
f0102275:	68 16 4e 10 f0       	push   $0xf0104e16
f010227a:	68 d7 02 00 00       	push   $0x2d7
f010227f:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102284:	e8 aa de ff ff       	call   f0100133 <_panic>
	assert((pp2 = page_alloc(0)));
f0102289:	68 18 4f 10 f0       	push   $0xf0104f18
f010228e:	68 16 4e 10 f0       	push   $0xf0104e16
f0102293:	68 d8 02 00 00       	push   $0x2d8
f0102298:	68 f0 4d 10 f0       	push   $0xf0104df0
f010229d:	e8 91 de ff ff       	call   f0100133 <_panic>
	assert(pp1 && pp1 != pp0);
f01022a2:	68 2e 4f 10 f0       	push   $0xf0104f2e
f01022a7:	68 16 4e 10 f0       	push   $0xf0104e16
f01022ac:	68 db 02 00 00       	push   $0x2db
f01022b1:	68 f0 4d 10 f0       	push   $0xf0104df0
f01022b6:	e8 78 de ff ff       	call   f0100133 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01022bb:	68 04 48 10 f0       	push   $0xf0104804
f01022c0:	68 16 4e 10 f0       	push   $0xf0104e16
f01022c5:	68 dc 02 00 00       	push   $0x2dc
f01022ca:	68 f0 4d 10 f0       	push   $0xf0104df0
f01022cf:	e8 5f de ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f01022d4:	68 97 4f 10 f0       	push   $0xf0104f97
f01022d9:	68 16 4e 10 f0       	push   $0xf0104e16
f01022de:	68 e3 02 00 00       	push   $0x2e3
f01022e3:	68 f0 4d 10 f0       	push   $0xf0104df0
f01022e8:	e8 46 de ff ff       	call   f0100133 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01022ed:	68 44 48 10 f0       	push   $0xf0104844
f01022f2:	68 16 4e 10 f0       	push   $0xf0104e16
f01022f7:	68 e6 02 00 00       	push   $0x2e6
f01022fc:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102301:	e8 2d de ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102306:	68 7c 48 10 f0       	push   $0xf010487c
f010230b:	68 16 4e 10 f0       	push   $0xf0104e16
f0102310:	68 e9 02 00 00       	push   $0x2e9
f0102315:	68 f0 4d 10 f0       	push   $0xf0104df0
f010231a:	e8 14 de ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010231f:	68 ac 48 10 f0       	push   $0xf01048ac
f0102324:	68 16 4e 10 f0       	push   $0xf0104e16
f0102329:	68 ed 02 00 00       	push   $0x2ed
f010232e:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102333:	e8 fb dd ff ff       	call   f0100133 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102338:	68 dc 48 10 f0       	push   $0xf01048dc
f010233d:	68 16 4e 10 f0       	push   $0xf0104e16
f0102342:	68 ee 02 00 00       	push   $0x2ee
f0102347:	68 f0 4d 10 f0       	push   $0xf0104df0
f010234c:	e8 e2 dd ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102351:	68 04 49 10 f0       	push   $0xf0104904
f0102356:	68 16 4e 10 f0       	push   $0xf0104e16
f010235b:	68 ef 02 00 00       	push   $0x2ef
f0102360:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102365:	e8 c9 dd ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 1);
f010236a:	68 e9 4f 10 f0       	push   $0xf0104fe9
f010236f:	68 16 4e 10 f0       	push   $0xf0104e16
f0102374:	68 f0 02 00 00       	push   $0x2f0
f0102379:	68 f0 4d 10 f0       	push   $0xf0104df0
f010237e:	e8 b0 dd ff ff       	call   f0100133 <_panic>
	assert(pp0->pp_ref == 1);
f0102383:	68 fa 4f 10 f0       	push   $0xf0104ffa
f0102388:	68 16 4e 10 f0       	push   $0xf0104e16
f010238d:	68 f1 02 00 00       	push   $0x2f1
f0102392:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102397:	e8 97 dd ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010239c:	68 34 49 10 f0       	push   $0xf0104934
f01023a1:	68 16 4e 10 f0       	push   $0xf0104e16
f01023a6:	68 f4 02 00 00       	push   $0x2f4
f01023ab:	68 f0 4d 10 f0       	push   $0xf0104df0
f01023b0:	e8 7e dd ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023b5:	68 70 49 10 f0       	push   $0xf0104970
f01023ba:	68 16 4e 10 f0       	push   $0xf0104e16
f01023bf:	68 f5 02 00 00       	push   $0x2f5
f01023c4:	68 f0 4d 10 f0       	push   $0xf0104df0
f01023c9:	e8 65 dd ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 1);
f01023ce:	68 0b 50 10 f0       	push   $0xf010500b
f01023d3:	68 16 4e 10 f0       	push   $0xf0104e16
f01023d8:	68 f6 02 00 00       	push   $0x2f6
f01023dd:	68 f0 4d 10 f0       	push   $0xf0104df0
f01023e2:	e8 4c dd ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f01023e7:	68 97 4f 10 f0       	push   $0xf0104f97
f01023ec:	68 16 4e 10 f0       	push   $0xf0104e16
f01023f1:	68 f9 02 00 00       	push   $0x2f9
f01023f6:	68 f0 4d 10 f0       	push   $0xf0104df0
f01023fb:	e8 33 dd ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102400:	68 34 49 10 f0       	push   $0xf0104934
f0102405:	68 16 4e 10 f0       	push   $0xf0104e16
f010240a:	68 fc 02 00 00       	push   $0x2fc
f010240f:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102414:	e8 1a dd ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102419:	68 70 49 10 f0       	push   $0xf0104970
f010241e:	68 16 4e 10 f0       	push   $0xf0104e16
f0102423:	68 fd 02 00 00       	push   $0x2fd
f0102428:	68 f0 4d 10 f0       	push   $0xf0104df0
f010242d:	e8 01 dd ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 1);
f0102432:	68 0b 50 10 f0       	push   $0xf010500b
f0102437:	68 16 4e 10 f0       	push   $0xf0104e16
f010243c:	68 fe 02 00 00       	push   $0x2fe
f0102441:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102446:	e8 e8 dc ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f010244b:	68 97 4f 10 f0       	push   $0xf0104f97
f0102450:	68 16 4e 10 f0       	push   $0xf0104e16
f0102455:	68 02 03 00 00       	push   $0x302
f010245a:	68 f0 4d 10 f0       	push   $0xf0104df0
f010245f:	e8 cf dc ff ff       	call   f0100133 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102464:	50                   	push   %eax
f0102465:	68 d0 44 10 f0       	push   $0xf01044d0
f010246a:	68 05 03 00 00       	push   $0x305
f010246f:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102474:	e8 ba dc ff ff       	call   f0100133 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102479:	68 a0 49 10 f0       	push   $0xf01049a0
f010247e:	68 16 4e 10 f0       	push   $0xf0104e16
f0102483:	68 06 03 00 00       	push   $0x306
f0102488:	68 f0 4d 10 f0       	push   $0xf0104df0
f010248d:	e8 a1 dc ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102492:	68 e0 49 10 f0       	push   $0xf01049e0
f0102497:	68 16 4e 10 f0       	push   $0xf0104e16
f010249c:	68 09 03 00 00       	push   $0x309
f01024a1:	68 f0 4d 10 f0       	push   $0xf0104df0
f01024a6:	e8 88 dc ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024ab:	68 70 49 10 f0       	push   $0xf0104970
f01024b0:	68 16 4e 10 f0       	push   $0xf0104e16
f01024b5:	68 0a 03 00 00       	push   $0x30a
f01024ba:	68 f0 4d 10 f0       	push   $0xf0104df0
f01024bf:	e8 6f dc ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 1);
f01024c4:	68 0b 50 10 f0       	push   $0xf010500b
f01024c9:	68 16 4e 10 f0       	push   $0xf0104e16
f01024ce:	68 0b 03 00 00       	push   $0x30b
f01024d3:	68 f0 4d 10 f0       	push   $0xf0104df0
f01024d8:	e8 56 dc ff ff       	call   f0100133 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01024dd:	68 20 4a 10 f0       	push   $0xf0104a20
f01024e2:	68 16 4e 10 f0       	push   $0xf0104e16
f01024e7:	68 0c 03 00 00       	push   $0x30c
f01024ec:	68 f0 4d 10 f0       	push   $0xf0104df0
f01024f1:	e8 3d dc ff ff       	call   f0100133 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01024f6:	68 1c 50 10 f0       	push   $0xf010501c
f01024fb:	68 16 4e 10 f0       	push   $0xf0104e16
f0102500:	68 0d 03 00 00       	push   $0x30d
f0102505:	68 f0 4d 10 f0       	push   $0xf0104df0
f010250a:	e8 24 dc ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010250f:	68 34 49 10 f0       	push   $0xf0104934
f0102514:	68 16 4e 10 f0       	push   $0xf0104e16
f0102519:	68 10 03 00 00       	push   $0x310
f010251e:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102523:	e8 0b dc ff ff       	call   f0100133 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102528:	68 54 4a 10 f0       	push   $0xf0104a54
f010252d:	68 16 4e 10 f0       	push   $0xf0104e16
f0102532:	68 11 03 00 00       	push   $0x311
f0102537:	68 f0 4d 10 f0       	push   $0xf0104df0
f010253c:	e8 f2 db ff ff       	call   f0100133 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102541:	68 88 4a 10 f0       	push   $0xf0104a88
f0102546:	68 16 4e 10 f0       	push   $0xf0104e16
f010254b:	68 12 03 00 00       	push   $0x312
f0102550:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102555:	e8 d9 db ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010255a:	68 c0 4a 10 f0       	push   $0xf0104ac0
f010255f:	68 16 4e 10 f0       	push   $0xf0104e16
f0102564:	68 15 03 00 00       	push   $0x315
f0102569:	68 f0 4d 10 f0       	push   $0xf0104df0
f010256e:	e8 c0 db ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102573:	68 f8 4a 10 f0       	push   $0xf0104af8
f0102578:	68 16 4e 10 f0       	push   $0xf0104e16
f010257d:	68 18 03 00 00       	push   $0x318
f0102582:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102587:	e8 a7 db ff ff       	call   f0100133 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010258c:	68 88 4a 10 f0       	push   $0xf0104a88
f0102591:	68 16 4e 10 f0       	push   $0xf0104e16
f0102596:	68 19 03 00 00       	push   $0x319
f010259b:	68 f0 4d 10 f0       	push   $0xf0104df0
f01025a0:	e8 8e db ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01025a5:	68 34 4b 10 f0       	push   $0xf0104b34
f01025aa:	68 16 4e 10 f0       	push   $0xf0104e16
f01025af:	68 1c 03 00 00       	push   $0x31c
f01025b4:	68 f0 4d 10 f0       	push   $0xf0104df0
f01025b9:	e8 75 db ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01025be:	68 60 4b 10 f0       	push   $0xf0104b60
f01025c3:	68 16 4e 10 f0       	push   $0xf0104e16
f01025c8:	68 1d 03 00 00       	push   $0x31d
f01025cd:	68 f0 4d 10 f0       	push   $0xf0104df0
f01025d2:	e8 5c db ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 2);
f01025d7:	68 32 50 10 f0       	push   $0xf0105032
f01025dc:	68 16 4e 10 f0       	push   $0xf0104e16
f01025e1:	68 1f 03 00 00       	push   $0x31f
f01025e6:	68 f0 4d 10 f0       	push   $0xf0104df0
f01025eb:	e8 43 db ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 0);
f01025f0:	68 43 50 10 f0       	push   $0xf0105043
f01025f5:	68 16 4e 10 f0       	push   $0xf0104e16
f01025fa:	68 20 03 00 00       	push   $0x320
f01025ff:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102604:	e8 2a db ff ff       	call   f0100133 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102609:	68 90 4b 10 f0       	push   $0xf0104b90
f010260e:	68 16 4e 10 f0       	push   $0xf0104e16
f0102613:	68 23 03 00 00       	push   $0x323
f0102618:	68 f0 4d 10 f0       	push   $0xf0104df0
f010261d:	e8 11 db ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102622:	68 b4 4b 10 f0       	push   $0xf0104bb4
f0102627:	68 16 4e 10 f0       	push   $0xf0104e16
f010262c:	68 27 03 00 00       	push   $0x327
f0102631:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102636:	e8 f8 da ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010263b:	68 60 4b 10 f0       	push   $0xf0104b60
f0102640:	68 16 4e 10 f0       	push   $0xf0104e16
f0102645:	68 28 03 00 00       	push   $0x328
f010264a:	68 f0 4d 10 f0       	push   $0xf0104df0
f010264f:	e8 df da ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 1);
f0102654:	68 e9 4f 10 f0       	push   $0xf0104fe9
f0102659:	68 16 4e 10 f0       	push   $0xf0104e16
f010265e:	68 29 03 00 00       	push   $0x329
f0102663:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102668:	e8 c6 da ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 0);
f010266d:	68 43 50 10 f0       	push   $0xf0105043
f0102672:	68 16 4e 10 f0       	push   $0xf0104e16
f0102677:	68 2a 03 00 00       	push   $0x32a
f010267c:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102681:	e8 ad da ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102686:	68 d8 4b 10 f0       	push   $0xf0104bd8
f010268b:	68 16 4e 10 f0       	push   $0xf0104e16
f0102690:	68 2d 03 00 00       	push   $0x32d
f0102695:	68 f0 4d 10 f0       	push   $0xf0104df0
f010269a:	e8 94 da ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref);
f010269f:	68 54 50 10 f0       	push   $0xf0105054
f01026a4:	68 16 4e 10 f0       	push   $0xf0104e16
f01026a9:	68 2e 03 00 00       	push   $0x32e
f01026ae:	68 f0 4d 10 f0       	push   $0xf0104df0
f01026b3:	e8 7b da ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_link == NULL);
f01026b8:	68 60 50 10 f0       	push   $0xf0105060
f01026bd:	68 16 4e 10 f0       	push   $0xf0104e16
f01026c2:	68 2f 03 00 00       	push   $0x32f
f01026c7:	68 f0 4d 10 f0       	push   $0xf0104df0
f01026cc:	e8 62 da ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01026d1:	68 b4 4b 10 f0       	push   $0xf0104bb4
f01026d6:	68 16 4e 10 f0       	push   $0xf0104e16
f01026db:	68 33 03 00 00       	push   $0x333
f01026e0:	68 f0 4d 10 f0       	push   $0xf0104df0
f01026e5:	e8 49 da ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01026ea:	68 10 4c 10 f0       	push   $0xf0104c10
f01026ef:	68 16 4e 10 f0       	push   $0xf0104e16
f01026f4:	68 34 03 00 00       	push   $0x334
f01026f9:	68 f0 4d 10 f0       	push   $0xf0104df0
f01026fe:	e8 30 da ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 0);
f0102703:	68 75 50 10 f0       	push   $0xf0105075
f0102708:	68 16 4e 10 f0       	push   $0xf0104e16
f010270d:	68 35 03 00 00       	push   $0x335
f0102712:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102717:	e8 17 da ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 0);
f010271c:	68 43 50 10 f0       	push   $0xf0105043
f0102721:	68 16 4e 10 f0       	push   $0xf0104e16
f0102726:	68 36 03 00 00       	push   $0x336
f010272b:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102730:	e8 fe d9 ff ff       	call   f0100133 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102735:	68 38 4c 10 f0       	push   $0xf0104c38
f010273a:	68 16 4e 10 f0       	push   $0xf0104e16
f010273f:	68 39 03 00 00       	push   $0x339
f0102744:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102749:	e8 e5 d9 ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f010274e:	68 97 4f 10 f0       	push   $0xf0104f97
f0102753:	68 16 4e 10 f0       	push   $0xf0104e16
f0102758:	68 3c 03 00 00       	push   $0x33c
f010275d:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102762:	e8 cc d9 ff ff       	call   f0100133 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102767:	68 dc 48 10 f0       	push   $0xf01048dc
f010276c:	68 16 4e 10 f0       	push   $0xf0104e16
f0102771:	68 3f 03 00 00       	push   $0x33f
f0102776:	68 f0 4d 10 f0       	push   $0xf0104df0
f010277b:	e8 b3 d9 ff ff       	call   f0100133 <_panic>
	assert(pp0->pp_ref == 1);
f0102780:	68 fa 4f 10 f0       	push   $0xf0104ffa
f0102785:	68 16 4e 10 f0       	push   $0xf0104e16
f010278a:	68 41 03 00 00       	push   $0x341
f010278f:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102794:	e8 9a d9 ff ff       	call   f0100133 <_panic>
f0102799:	52                   	push   %edx
f010279a:	68 d0 44 10 f0       	push   $0xf01044d0
f010279f:	68 48 03 00 00       	push   $0x348
f01027a4:	68 f0 4d 10 f0       	push   $0xf0104df0
f01027a9:	e8 85 d9 ff ff       	call   f0100133 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01027ae:	68 86 50 10 f0       	push   $0xf0105086
f01027b3:	68 16 4e 10 f0       	push   $0xf0104e16
f01027b8:	68 49 03 00 00       	push   $0x349
f01027bd:	68 f0 4d 10 f0       	push   $0xf0104df0
f01027c2:	e8 6c d9 ff ff       	call   f0100133 <_panic>
f01027c7:	50                   	push   %eax
f01027c8:	68 d0 44 10 f0       	push   $0xf01044d0
f01027cd:	6a 52                	push   $0x52
f01027cf:	68 fc 4d 10 f0       	push   $0xf0104dfc
f01027d4:	e8 5a d9 ff ff       	call   f0100133 <_panic>
f01027d9:	52                   	push   %edx
f01027da:	68 d0 44 10 f0       	push   $0xf01044d0
f01027df:	6a 52                	push   $0x52
f01027e1:	68 fc 4d 10 f0       	push   $0xf0104dfc
f01027e6:	e8 48 d9 ff ff       	call   f0100133 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f01027eb:	68 9e 50 10 f0       	push   $0xf010509e
f01027f0:	68 16 4e 10 f0       	push   $0xf0104e16
f01027f5:	68 53 03 00 00       	push   $0x353
f01027fa:	68 f0 4d 10 f0       	push   $0xf0104df0
f01027ff:	e8 2f d9 ff ff       	call   f0100133 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102804:	50                   	push   %eax
f0102805:	68 84 47 10 f0       	push   $0xf0104784
f010280a:	68 b5 00 00 00       	push   $0xb5
f010280f:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102814:	e8 1a d9 ff ff       	call   f0100133 <_panic>
f0102819:	50                   	push   %eax
f010281a:	68 84 47 10 f0       	push   $0xf0104784
f010281f:	68 c2 00 00 00       	push   $0xc2
f0102824:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102829:	e8 05 d9 ff ff       	call   f0100133 <_panic>
f010282e:	ff 75 c8             	pushl  -0x38(%ebp)
f0102831:	68 84 47 10 f0       	push   $0xf0104784
f0102836:	68 94 02 00 00       	push   $0x294
f010283b:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102840:	e8 ee d8 ff ff       	call   f0100133 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102845:	68 5c 4c 10 f0       	push   $0xf0104c5c
f010284a:	68 16 4e 10 f0       	push   $0xf0104e16
f010284f:	68 94 02 00 00       	push   $0x294
f0102854:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102859:	e8 d5 d8 ff ff       	call   f0100133 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010285e:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102861:	c1 e7 0c             	shl    $0xc,%edi
f0102864:	be 00 00 00 00       	mov    $0x0,%esi
f0102869:	eb 17                	jmp    f0102882 <mem_init+0x1331>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010286b:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102871:	89 d8                	mov    %ebx,%eax
f0102873:	e8 92 e5 ff ff       	call   f0100e0a <check_va2pa>
f0102878:	39 c6                	cmp    %eax,%esi
f010287a:	75 50                	jne    f01028cc <mem_init+0x137b>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010287c:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102882:	39 fe                	cmp    %edi,%esi
f0102884:	72 e5                	jb     f010286b <mem_init+0x131a>
f0102886:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010288b:	b8 00 f0 10 f0       	mov    $0xf010f000,%eax
f0102890:	8d b8 00 80 00 20    	lea    0x20008000(%eax),%edi
f0102896:	89 f2                	mov    %esi,%edx
f0102898:	89 d8                	mov    %ebx,%eax
f010289a:	e8 6b e5 ff ff       	call   f0100e0a <check_va2pa>
f010289f:	8d 14 37             	lea    (%edi,%esi,1),%edx
f01028a2:	39 d0                	cmp    %edx,%eax
f01028a4:	75 3f                	jne    f01028e5 <mem_init+0x1394>
f01028a6:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < KSTKSIZE; i += PGSIZE) {
f01028ac:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01028b2:	75 e2                	jne    f0102896 <mem_init+0x1345>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01028b4:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01028b9:	89 d8                	mov    %ebx,%eax
f01028bb:	e8 4a e5 ff ff       	call   f0100e0a <check_va2pa>
f01028c0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01028c3:	75 39                	jne    f01028fe <mem_init+0x13ad>
	for (i = 0; i < NPDENTRIES; i++) {
f01028c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01028ca:	eb 72                	jmp    f010293e <mem_init+0x13ed>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01028cc:	68 90 4c 10 f0       	push   $0xf0104c90
f01028d1:	68 16 4e 10 f0       	push   $0xf0104e16
f01028d6:	68 99 02 00 00       	push   $0x299
f01028db:	68 f0 4d 10 f0       	push   $0xf0104df0
f01028e0:	e8 4e d8 ff ff       	call   f0100133 <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01028e5:	68 b8 4c 10 f0       	push   $0xf0104cb8
f01028ea:	68 16 4e 10 f0       	push   $0xf0104e16
f01028ef:	68 9d 02 00 00       	push   $0x29d
f01028f4:	68 f0 4d 10 f0       	push   $0xf0104df0
f01028f9:	e8 35 d8 ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01028fe:	68 00 4d 10 f0       	push   $0xf0104d00
f0102903:	68 16 4e 10 f0       	push   $0xf0104e16
f0102908:	68 9f 02 00 00       	push   $0x29f
f010290d:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102912:	e8 1c d8 ff ff       	call   f0100133 <_panic>
			assert(pgdir[i] & PTE_P);
f0102917:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f010291b:	74 47                	je     f0102964 <mem_init+0x1413>
	for (i = 0; i < NPDENTRIES; i++) {
f010291d:	40                   	inc    %eax
f010291e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102923:	0f 87 93 00 00 00    	ja     f01029bc <mem_init+0x146b>
		switch (i) {
f0102929:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f010292e:	72 0e                	jb     f010293e <mem_init+0x13ed>
f0102930:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102935:	76 e0                	jbe    f0102917 <mem_init+0x13c6>
f0102937:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010293c:	74 d9                	je     f0102917 <mem_init+0x13c6>
			if (i >= PDX(KERNBASE)) {
f010293e:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102943:	77 38                	ja     f010297d <mem_init+0x142c>
				assert(pgdir[i] == 0);
f0102945:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102949:	74 d2                	je     f010291d <mem_init+0x13cc>
f010294b:	68 f0 50 10 f0       	push   $0xf01050f0
f0102950:	68 16 4e 10 f0       	push   $0xf0104e16
f0102955:	68 ae 02 00 00       	push   $0x2ae
f010295a:	68 f0 4d 10 f0       	push   $0xf0104df0
f010295f:	e8 cf d7 ff ff       	call   f0100133 <_panic>
			assert(pgdir[i] & PTE_P);
f0102964:	68 ce 50 10 f0       	push   $0xf01050ce
f0102969:	68 16 4e 10 f0       	push   $0xf0104e16
f010296e:	68 a7 02 00 00       	push   $0x2a7
f0102973:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102978:	e8 b6 d7 ff ff       	call   f0100133 <_panic>
				assert(pgdir[i] & PTE_P);
f010297d:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102980:	f6 c2 01             	test   $0x1,%dl
f0102983:	74 1e                	je     f01029a3 <mem_init+0x1452>
				assert(pgdir[i] & PTE_W);
f0102985:	f6 c2 02             	test   $0x2,%dl
f0102988:	75 93                	jne    f010291d <mem_init+0x13cc>
f010298a:	68 df 50 10 f0       	push   $0xf01050df
f010298f:	68 16 4e 10 f0       	push   $0xf0104e16
f0102994:	68 ac 02 00 00       	push   $0x2ac
f0102999:	68 f0 4d 10 f0       	push   $0xf0104df0
f010299e:	e8 90 d7 ff ff       	call   f0100133 <_panic>
				assert(pgdir[i] & PTE_P);
f01029a3:	68 ce 50 10 f0       	push   $0xf01050ce
f01029a8:	68 16 4e 10 f0       	push   $0xf0104e16
f01029ad:	68 ab 02 00 00       	push   $0x2ab
f01029b2:	68 f0 4d 10 f0       	push   $0xf0104df0
f01029b7:	e8 77 d7 ff ff       	call   f0100133 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f01029bc:	83 ec 0c             	sub    $0xc,%esp
f01029bf:	68 30 4d 10 f0       	push   $0xf0104d30
f01029c4:	e8 fa 03 00 00       	call   f0102dc3 <cprintf>
	lcr3(PADDR(kern_pgdir));
f01029c9:	a1 68 99 11 f0       	mov    0xf0119968,%eax
	if ((uint32_t)kva < KERNBASE)
f01029ce:	83 c4 10             	add    $0x10,%esp
f01029d1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029d6:	0f 86 fe 01 00 00    	jbe    f0102bda <mem_init+0x1689>
	return (physaddr_t)kva - KERNBASE;
f01029dc:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01029e1:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f01029e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01029e9:	e8 7b e4 ff ff       	call   f0100e69 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01029ee:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01029f1:	83 e0 f3             	and    $0xfffffff3,%eax
f01029f4:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01029f9:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01029fc:	83 ec 0c             	sub    $0xc,%esp
f01029ff:	6a 00                	push   $0x0
f0102a01:	e8 e6 e7 ff ff       	call   f01011ec <page_alloc>
f0102a06:	89 c3                	mov    %eax,%ebx
f0102a08:	83 c4 10             	add    $0x10,%esp
f0102a0b:	85 c0                	test   %eax,%eax
f0102a0d:	0f 84 dc 01 00 00    	je     f0102bef <mem_init+0x169e>
	assert((pp1 = page_alloc(0)));
f0102a13:	83 ec 0c             	sub    $0xc,%esp
f0102a16:	6a 00                	push   $0x0
f0102a18:	e8 cf e7 ff ff       	call   f01011ec <page_alloc>
f0102a1d:	89 c7                	mov    %eax,%edi
f0102a1f:	83 c4 10             	add    $0x10,%esp
f0102a22:	85 c0                	test   %eax,%eax
f0102a24:	0f 84 de 01 00 00    	je     f0102c08 <mem_init+0x16b7>
	assert((pp2 = page_alloc(0)));
f0102a2a:	83 ec 0c             	sub    $0xc,%esp
f0102a2d:	6a 00                	push   $0x0
f0102a2f:	e8 b8 e7 ff ff       	call   f01011ec <page_alloc>
f0102a34:	89 c6                	mov    %eax,%esi
f0102a36:	83 c4 10             	add    $0x10,%esp
f0102a39:	85 c0                	test   %eax,%eax
f0102a3b:	0f 84 e0 01 00 00    	je     f0102c21 <mem_init+0x16d0>
	page_free(pp0);
f0102a41:	83 ec 0c             	sub    $0xc,%esp
f0102a44:	53                   	push   %ebx
f0102a45:	e8 14 e8 ff ff       	call   f010125e <page_free>
	return (pp - pages) << PGSHIFT;
f0102a4a:	89 f8                	mov    %edi,%eax
f0102a4c:	2b 05 6c 99 11 f0    	sub    0xf011996c,%eax
f0102a52:	c1 f8 03             	sar    $0x3,%eax
f0102a55:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102a58:	89 c2                	mov    %eax,%edx
f0102a5a:	c1 ea 0c             	shr    $0xc,%edx
f0102a5d:	83 c4 10             	add    $0x10,%esp
f0102a60:	3b 15 64 99 11 f0    	cmp    0xf0119964,%edx
f0102a66:	0f 83 ce 01 00 00    	jae    f0102c3a <mem_init+0x16e9>
	memset(page2kva(pp1), 1, PGSIZE);
f0102a6c:	83 ec 04             	sub    $0x4,%esp
f0102a6f:	68 00 10 00 00       	push   $0x1000
f0102a74:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102a76:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a7b:	50                   	push   %eax
f0102a7c:	e8 71 0e 00 00       	call   f01038f2 <memset>
	return (pp - pages) << PGSHIFT;
f0102a81:	89 f0                	mov    %esi,%eax
f0102a83:	2b 05 6c 99 11 f0    	sub    0xf011996c,%eax
f0102a89:	c1 f8 03             	sar    $0x3,%eax
f0102a8c:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102a8f:	89 c2                	mov    %eax,%edx
f0102a91:	c1 ea 0c             	shr    $0xc,%edx
f0102a94:	83 c4 10             	add    $0x10,%esp
f0102a97:	3b 15 64 99 11 f0    	cmp    0xf0119964,%edx
f0102a9d:	0f 83 a9 01 00 00    	jae    f0102c4c <mem_init+0x16fb>
	memset(page2kva(pp2), 2, PGSIZE);
f0102aa3:	83 ec 04             	sub    $0x4,%esp
f0102aa6:	68 00 10 00 00       	push   $0x1000
f0102aab:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102aad:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102ab2:	50                   	push   %eax
f0102ab3:	e8 3a 0e 00 00       	call   f01038f2 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102ab8:	6a 02                	push   $0x2
f0102aba:	68 00 10 00 00       	push   $0x1000
f0102abf:	57                   	push   %edi
f0102ac0:	ff 35 68 99 11 f0    	pushl  0xf0119968
f0102ac6:	e8 1f ea ff ff       	call   f01014ea <page_insert>
	assert(pp1->pp_ref == 1);
f0102acb:	83 c4 20             	add    $0x20,%esp
f0102ace:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102ad3:	0f 85 85 01 00 00    	jne    f0102c5e <mem_init+0x170d>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102ad9:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102ae0:	01 01 01 
f0102ae3:	0f 85 8e 01 00 00    	jne    f0102c77 <mem_init+0x1726>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102ae9:	6a 02                	push   $0x2
f0102aeb:	68 00 10 00 00       	push   $0x1000
f0102af0:	56                   	push   %esi
f0102af1:	ff 35 68 99 11 f0    	pushl  0xf0119968
f0102af7:	e8 ee e9 ff ff       	call   f01014ea <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102afc:	83 c4 10             	add    $0x10,%esp
f0102aff:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102b06:	02 02 02 
f0102b09:	0f 85 81 01 00 00    	jne    f0102c90 <mem_init+0x173f>
	assert(pp2->pp_ref == 1);
f0102b0f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102b14:	0f 85 8f 01 00 00    	jne    f0102ca9 <mem_init+0x1758>
	assert(pp1->pp_ref == 0);
f0102b1a:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102b1f:	0f 85 9d 01 00 00    	jne    f0102cc2 <mem_init+0x1771>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102b25:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102b2c:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102b2f:	89 f0                	mov    %esi,%eax
f0102b31:	2b 05 6c 99 11 f0    	sub    0xf011996c,%eax
f0102b37:	c1 f8 03             	sar    $0x3,%eax
f0102b3a:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102b3d:	89 c2                	mov    %eax,%edx
f0102b3f:	c1 ea 0c             	shr    $0xc,%edx
f0102b42:	3b 15 64 99 11 f0    	cmp    0xf0119964,%edx
f0102b48:	0f 83 8d 01 00 00    	jae    f0102cdb <mem_init+0x178a>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102b4e:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102b55:	03 03 03 
f0102b58:	0f 85 8f 01 00 00    	jne    f0102ced <mem_init+0x179c>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102b5e:	83 ec 08             	sub    $0x8,%esp
f0102b61:	68 00 10 00 00       	push   $0x1000
f0102b66:	ff 35 68 99 11 f0    	pushl  0xf0119968
f0102b6c:	e8 31 e9 ff ff       	call   f01014a2 <page_remove>
	assert(pp2->pp_ref == 0);
f0102b71:	83 c4 10             	add    $0x10,%esp
f0102b74:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102b79:	0f 85 87 01 00 00    	jne    f0102d06 <mem_init+0x17b5>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102b7f:	8b 0d 68 99 11 f0    	mov    0xf0119968,%ecx
f0102b85:	8b 11                	mov    (%ecx),%edx
f0102b87:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102b8d:	89 d8                	mov    %ebx,%eax
f0102b8f:	2b 05 6c 99 11 f0    	sub    0xf011996c,%eax
f0102b95:	c1 f8 03             	sar    $0x3,%eax
f0102b98:	c1 e0 0c             	shl    $0xc,%eax
f0102b9b:	39 c2                	cmp    %eax,%edx
f0102b9d:	0f 85 7c 01 00 00    	jne    f0102d1f <mem_init+0x17ce>
	kern_pgdir[0] = 0;
f0102ba3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102ba9:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102bae:	0f 85 84 01 00 00    	jne    f0102d38 <mem_init+0x17e7>
	pp0->pp_ref = 0;
f0102bb4:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102bba:	83 ec 0c             	sub    $0xc,%esp
f0102bbd:	53                   	push   %ebx
f0102bbe:	e8 9b e6 ff ff       	call   f010125e <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102bc3:	c7 04 24 c4 4d 10 f0 	movl   $0xf0104dc4,(%esp)
f0102bca:	e8 f4 01 00 00       	call   f0102dc3 <cprintf>
}
f0102bcf:	83 c4 10             	add    $0x10,%esp
f0102bd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102bd5:	5b                   	pop    %ebx
f0102bd6:	5e                   	pop    %esi
f0102bd7:	5f                   	pop    %edi
f0102bd8:	5d                   	pop    %ebp
f0102bd9:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bda:	50                   	push   %eax
f0102bdb:	68 84 47 10 f0       	push   $0xf0104784
f0102be0:	68 d8 00 00 00       	push   $0xd8
f0102be5:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102bea:	e8 44 d5 ff ff       	call   f0100133 <_panic>
	assert((pp0 = page_alloc(0)));
f0102bef:	68 ec 4e 10 f0       	push   $0xf0104eec
f0102bf4:	68 16 4e 10 f0       	push   $0xf0104e16
f0102bf9:	68 6e 03 00 00       	push   $0x36e
f0102bfe:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102c03:	e8 2b d5 ff ff       	call   f0100133 <_panic>
	assert((pp1 = page_alloc(0)));
f0102c08:	68 02 4f 10 f0       	push   $0xf0104f02
f0102c0d:	68 16 4e 10 f0       	push   $0xf0104e16
f0102c12:	68 6f 03 00 00       	push   $0x36f
f0102c17:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102c1c:	e8 12 d5 ff ff       	call   f0100133 <_panic>
	assert((pp2 = page_alloc(0)));
f0102c21:	68 18 4f 10 f0       	push   $0xf0104f18
f0102c26:	68 16 4e 10 f0       	push   $0xf0104e16
f0102c2b:	68 70 03 00 00       	push   $0x370
f0102c30:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102c35:	e8 f9 d4 ff ff       	call   f0100133 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c3a:	50                   	push   %eax
f0102c3b:	68 d0 44 10 f0       	push   $0xf01044d0
f0102c40:	6a 52                	push   $0x52
f0102c42:	68 fc 4d 10 f0       	push   $0xf0104dfc
f0102c47:	e8 e7 d4 ff ff       	call   f0100133 <_panic>
f0102c4c:	50                   	push   %eax
f0102c4d:	68 d0 44 10 f0       	push   $0xf01044d0
f0102c52:	6a 52                	push   $0x52
f0102c54:	68 fc 4d 10 f0       	push   $0xf0104dfc
f0102c59:	e8 d5 d4 ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 1);
f0102c5e:	68 e9 4f 10 f0       	push   $0xf0104fe9
f0102c63:	68 16 4e 10 f0       	push   $0xf0104e16
f0102c68:	68 75 03 00 00       	push   $0x375
f0102c6d:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102c72:	e8 bc d4 ff ff       	call   f0100133 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c77:	68 50 4d 10 f0       	push   $0xf0104d50
f0102c7c:	68 16 4e 10 f0       	push   $0xf0104e16
f0102c81:	68 76 03 00 00       	push   $0x376
f0102c86:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102c8b:	e8 a3 d4 ff ff       	call   f0100133 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102c90:	68 74 4d 10 f0       	push   $0xf0104d74
f0102c95:	68 16 4e 10 f0       	push   $0xf0104e16
f0102c9a:	68 78 03 00 00       	push   $0x378
f0102c9f:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102ca4:	e8 8a d4 ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 1);
f0102ca9:	68 0b 50 10 f0       	push   $0xf010500b
f0102cae:	68 16 4e 10 f0       	push   $0xf0104e16
f0102cb3:	68 79 03 00 00       	push   $0x379
f0102cb8:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102cbd:	e8 71 d4 ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 0);
f0102cc2:	68 75 50 10 f0       	push   $0xf0105075
f0102cc7:	68 16 4e 10 f0       	push   $0xf0104e16
f0102ccc:	68 7a 03 00 00       	push   $0x37a
f0102cd1:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102cd6:	e8 58 d4 ff ff       	call   f0100133 <_panic>
f0102cdb:	50                   	push   %eax
f0102cdc:	68 d0 44 10 f0       	push   $0xf01044d0
f0102ce1:	6a 52                	push   $0x52
f0102ce3:	68 fc 4d 10 f0       	push   $0xf0104dfc
f0102ce8:	e8 46 d4 ff ff       	call   f0100133 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102ced:	68 98 4d 10 f0       	push   $0xf0104d98
f0102cf2:	68 16 4e 10 f0       	push   $0xf0104e16
f0102cf7:	68 7c 03 00 00       	push   $0x37c
f0102cfc:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102d01:	e8 2d d4 ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 0);
f0102d06:	68 43 50 10 f0       	push   $0xf0105043
f0102d0b:	68 16 4e 10 f0       	push   $0xf0104e16
f0102d10:	68 7e 03 00 00       	push   $0x37e
f0102d15:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102d1a:	e8 14 d4 ff ff       	call   f0100133 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d1f:	68 dc 48 10 f0       	push   $0xf01048dc
f0102d24:	68 16 4e 10 f0       	push   $0xf0104e16
f0102d29:	68 81 03 00 00       	push   $0x381
f0102d2e:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102d33:	e8 fb d3 ff ff       	call   f0100133 <_panic>
	assert(pp0->pp_ref == 1);
f0102d38:	68 fa 4f 10 f0       	push   $0xf0104ffa
f0102d3d:	68 16 4e 10 f0       	push   $0xf0104e16
f0102d42:	68 83 03 00 00       	push   $0x383
f0102d47:	68 f0 4d 10 f0       	push   $0xf0104df0
f0102d4c:	e8 e2 d3 ff ff       	call   f0100133 <_panic>

f0102d51 <tlb_invalidate>:
{
f0102d51:	55                   	push   %ebp
f0102d52:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102d54:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d57:	0f 01 38             	invlpg (%eax)
}
f0102d5a:	5d                   	pop    %ebp
f0102d5b:	c3                   	ret    

f0102d5c <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102d5c:	55                   	push   %ebp
f0102d5d:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102d5f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d62:	ba 70 00 00 00       	mov    $0x70,%edx
f0102d67:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102d68:	ba 71 00 00 00       	mov    $0x71,%edx
f0102d6d:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102d6e:	0f b6 c0             	movzbl %al,%eax
}
f0102d71:	5d                   	pop    %ebp
f0102d72:	c3                   	ret    

f0102d73 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102d73:	55                   	push   %ebp
f0102d74:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102d76:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d79:	ba 70 00 00 00       	mov    $0x70,%edx
f0102d7e:	ee                   	out    %al,(%dx)
f0102d7f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d82:	ba 71 00 00 00       	mov    $0x71,%edx
f0102d87:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102d88:	5d                   	pop    %ebp
f0102d89:	c3                   	ret    

f0102d8a <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102d8a:	55                   	push   %ebp
f0102d8b:	89 e5                	mov    %esp,%ebp
f0102d8d:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102d90:	ff 75 08             	pushl  0x8(%ebp)
f0102d93:	e8 ee d8 ff ff       	call   f0100686 <cputchar>
	*cnt++;
}
f0102d98:	83 c4 10             	add    $0x10,%esp
f0102d9b:	c9                   	leave  
f0102d9c:	c3                   	ret    

f0102d9d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102d9d:	55                   	push   %ebp
f0102d9e:	89 e5                	mov    %esp,%ebp
f0102da0:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102da3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102daa:	ff 75 0c             	pushl  0xc(%ebp)
f0102dad:	ff 75 08             	pushl  0x8(%ebp)
f0102db0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102db3:	50                   	push   %eax
f0102db4:	68 8a 2d 10 f0       	push   $0xf0102d8a
f0102db9:	e8 1b 04 00 00       	call   f01031d9 <vprintfmt>
	return cnt;
}
f0102dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102dc1:	c9                   	leave  
f0102dc2:	c3                   	ret    

f0102dc3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102dc3:	55                   	push   %ebp
f0102dc4:	89 e5                	mov    %esp,%ebp
f0102dc6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102dc9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102dcc:	50                   	push   %eax
f0102dcd:	ff 75 08             	pushl  0x8(%ebp)
f0102dd0:	e8 c8 ff ff ff       	call   f0102d9d <vcprintf>
	va_end(ap);

	return cnt;
}
f0102dd5:	c9                   	leave  
f0102dd6:	c3                   	ret    

f0102dd7 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102dd7:	55                   	push   %ebp
f0102dd8:	89 e5                	mov    %esp,%ebp
f0102dda:	57                   	push   %edi
f0102ddb:	56                   	push   %esi
f0102ddc:	53                   	push   %ebx
f0102ddd:	83 ec 14             	sub    $0x14,%esp
f0102de0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102de3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0102de6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102de9:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102dec:	8b 32                	mov    (%edx),%esi
f0102dee:	8b 01                	mov    (%ecx),%eax
f0102df0:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102df3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0102dfa:	eb 2f                	jmp    f0102e2b <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0102dfc:	48                   	dec    %eax
		while (m >= l && stabs[m].n_type != type)
f0102dfd:	39 c6                	cmp    %eax,%esi
f0102dff:	7f 4d                	jg     f0102e4e <stab_binsearch+0x77>
f0102e01:	0f b6 0a             	movzbl (%edx),%ecx
f0102e04:	83 ea 0c             	sub    $0xc,%edx
f0102e07:	39 f9                	cmp    %edi,%ecx
f0102e09:	75 f1                	jne    f0102dfc <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102e0b:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0102e0e:	01 c2                	add    %eax,%edx
f0102e10:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102e13:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0102e17:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102e1a:	73 37                	jae    f0102e53 <stab_binsearch+0x7c>
			*region_left = m;
f0102e1c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102e1f:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0102e21:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0102e24:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0102e2b:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0102e2e:	7f 4d                	jg     f0102e7d <stab_binsearch+0xa6>
		int true_m = (l + r) / 2, m = true_m;
f0102e30:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102e33:	01 f0                	add    %esi,%eax
f0102e35:	89 c3                	mov    %eax,%ebx
f0102e37:	c1 eb 1f             	shr    $0x1f,%ebx
f0102e3a:	01 c3                	add    %eax,%ebx
f0102e3c:	d1 fb                	sar    %ebx
f0102e3e:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0102e41:	01 d8                	add    %ebx,%eax
f0102e43:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102e46:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0102e4a:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0102e4c:	eb af                	jmp    f0102dfd <stab_binsearch+0x26>
			l = true_m + 1;
f0102e4e:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0102e51:	eb d8                	jmp    f0102e2b <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0102e53:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102e56:	76 12                	jbe    f0102e6a <stab_binsearch+0x93>
			*region_right = m - 1;
f0102e58:	48                   	dec    %eax
f0102e59:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102e5c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102e5f:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0102e61:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102e68:	eb c1                	jmp    f0102e2b <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102e6a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102e6d:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0102e6f:	ff 45 0c             	incl   0xc(%ebp)
f0102e72:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0102e74:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102e7b:	eb ae                	jmp    f0102e2b <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0102e7d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102e81:	74 18                	je     f0102e9b <stab_binsearch+0xc4>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102e83:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102e86:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102e88:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102e8b:	8b 0e                	mov    (%esi),%ecx
f0102e8d:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0102e90:	01 c2                	add    %eax,%edx
f0102e92:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0102e95:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0102e99:	eb 0e                	jmp    f0102ea9 <stab_binsearch+0xd2>
		*region_right = *region_left - 1;
f0102e9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102e9e:	8b 00                	mov    (%eax),%eax
f0102ea0:	48                   	dec    %eax
f0102ea1:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0102ea4:	89 07                	mov    %eax,(%edi)
f0102ea6:	eb 14                	jmp    f0102ebc <stab_binsearch+0xe5>
		     l--)
f0102ea8:	48                   	dec    %eax
		for (l = *region_right;
f0102ea9:	39 c1                	cmp    %eax,%ecx
f0102eab:	7d 0a                	jge    f0102eb7 <stab_binsearch+0xe0>
		     l > *region_left && stabs[l].n_type != type;
f0102ead:	0f b6 1a             	movzbl (%edx),%ebx
f0102eb0:	83 ea 0c             	sub    $0xc,%edx
f0102eb3:	39 fb                	cmp    %edi,%ebx
f0102eb5:	75 f1                	jne    f0102ea8 <stab_binsearch+0xd1>
			/* do nothing */;
		*region_left = l;
f0102eb7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102eba:	89 07                	mov    %eax,(%edi)
	}
}
f0102ebc:	83 c4 14             	add    $0x14,%esp
f0102ebf:	5b                   	pop    %ebx
f0102ec0:	5e                   	pop    %esi
f0102ec1:	5f                   	pop    %edi
f0102ec2:	5d                   	pop    %ebp
f0102ec3:	c3                   	ret    

f0102ec4 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102ec4:	55                   	push   %ebp
f0102ec5:	89 e5                	mov    %esp,%ebp
f0102ec7:	57                   	push   %edi
f0102ec8:	56                   	push   %esi
f0102ec9:	53                   	push   %ebx
f0102eca:	83 ec 3c             	sub    $0x3c,%esp
f0102ecd:	8b 75 08             	mov    0x8(%ebp),%esi
f0102ed0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102ed3:	c7 03 fe 50 10 f0    	movl   $0xf01050fe,(%ebx)
	info->eip_line = 0;
f0102ed9:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102ee0:	c7 43 08 fe 50 10 f0 	movl   $0xf01050fe,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102ee7:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102eee:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102ef1:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102ef8:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102efe:	0f 86 31 01 00 00    	jbe    f0103035 <debuginfo_eip+0x171>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102f04:	b8 d5 e3 10 f0       	mov    $0xf010e3d5,%eax
f0102f09:	3d 99 c4 10 f0       	cmp    $0xf010c499,%eax
f0102f0e:	0f 86 b6 01 00 00    	jbe    f01030ca <debuginfo_eip+0x206>
f0102f14:	80 3d d4 e3 10 f0 00 	cmpb   $0x0,0xf010e3d4
f0102f1b:	0f 85 b0 01 00 00    	jne    f01030d1 <debuginfo_eip+0x20d>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102f21:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102f28:	ba 98 c4 10 f0       	mov    $0xf010c498,%edx
f0102f2d:	81 ea 34 53 10 f0    	sub    $0xf0105334,%edx
f0102f33:	c1 fa 02             	sar    $0x2,%edx
f0102f36:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0102f39:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0102f3c:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0102f3f:	89 c1                	mov    %eax,%ecx
f0102f41:	c1 e1 08             	shl    $0x8,%ecx
f0102f44:	01 c8                	add    %ecx,%eax
f0102f46:	89 c1                	mov    %eax,%ecx
f0102f48:	c1 e1 10             	shl    $0x10,%ecx
f0102f4b:	01 c8                	add    %ecx,%eax
f0102f4d:	01 c0                	add    %eax,%eax
f0102f4f:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
f0102f53:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102f56:	83 ec 08             	sub    $0x8,%esp
f0102f59:	56                   	push   %esi
f0102f5a:	6a 64                	push   $0x64
f0102f5c:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102f5f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102f62:	b8 34 53 10 f0       	mov    $0xf0105334,%eax
f0102f67:	e8 6b fe ff ff       	call   f0102dd7 <stab_binsearch>
	if (lfile == 0)
f0102f6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102f6f:	83 c4 10             	add    $0x10,%esp
f0102f72:	85 c0                	test   %eax,%eax
f0102f74:	0f 84 5e 01 00 00    	je     f01030d8 <debuginfo_eip+0x214>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102f7a:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0102f7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102f80:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102f83:	83 ec 08             	sub    $0x8,%esp
f0102f86:	56                   	push   %esi
f0102f87:	6a 24                	push   $0x24
f0102f89:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102f8c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102f8f:	b8 34 53 10 f0       	mov    $0xf0105334,%eax
f0102f94:	e8 3e fe ff ff       	call   f0102dd7 <stab_binsearch>

	if (lfun <= rfun) {
f0102f99:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102f9c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102f9f:	83 c4 10             	add    $0x10,%esp
f0102fa2:	39 d0                	cmp    %edx,%eax
f0102fa4:	0f 8f 9f 00 00 00    	jg     f0103049 <debuginfo_eip+0x185>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102faa:	8d 0c 00             	lea    (%eax,%eax,1),%ecx
f0102fad:	01 c1                	add    %eax,%ecx
f0102faf:	c1 e1 02             	shl    $0x2,%ecx
f0102fb2:	8d b9 34 53 10 f0    	lea    -0xfefaccc(%ecx),%edi
f0102fb8:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0102fbb:	8b 89 34 53 10 f0    	mov    -0xfefaccc(%ecx),%ecx
f0102fc1:	bf d5 e3 10 f0       	mov    $0xf010e3d5,%edi
f0102fc6:	81 ef 99 c4 10 f0    	sub    $0xf010c499,%edi
f0102fcc:	39 f9                	cmp    %edi,%ecx
f0102fce:	73 09                	jae    f0102fd9 <debuginfo_eip+0x115>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102fd0:	81 c1 99 c4 10 f0    	add    $0xf010c499,%ecx
f0102fd6:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102fd9:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0102fdc:	8b 4f 08             	mov    0x8(%edi),%ecx
f0102fdf:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102fe2:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0102fe4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0102fe7:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102fea:	83 ec 08             	sub    $0x8,%esp
f0102fed:	6a 3a                	push   $0x3a
f0102fef:	ff 73 08             	pushl  0x8(%ebx)
f0102ff2:	e8 e3 08 00 00       	call   f01038da <strfind>
f0102ff7:	2b 43 08             	sub    0x8(%ebx),%eax
f0102ffa:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// N_SLINE represents text segment
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0102ffd:	83 c4 08             	add    $0x8,%esp
f0103000:	56                   	push   %esi
f0103001:	6a 44                	push   $0x44
f0103003:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103006:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103009:	b8 34 53 10 f0       	mov    $0xf0105334,%eax
f010300e:	e8 c4 fd ff ff       	call   f0102dd7 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0103013:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103016:	8d 04 12             	lea    (%edx,%edx,1),%eax
f0103019:	01 d0                	add    %edx,%eax
f010301b:	c1 e0 02             	shl    $0x2,%eax
f010301e:	0f b7 88 3a 53 10 f0 	movzwl -0xfefacc6(%eax),%ecx
f0103025:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103028:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010302b:	05 38 53 10 f0       	add    $0xf0105338,%eax
f0103030:	83 c4 10             	add    $0x10,%esp
f0103033:	eb 29                	jmp    f010305e <debuginfo_eip+0x19a>
  	        panic("User address");
f0103035:	83 ec 04             	sub    $0x4,%esp
f0103038:	68 08 51 10 f0       	push   $0xf0105108
f010303d:	6a 7f                	push   $0x7f
f010303f:	68 15 51 10 f0       	push   $0xf0105115
f0103044:	e8 ea d0 ff ff       	call   f0100133 <_panic>
		info->eip_fn_addr = addr;
f0103049:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010304c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010304f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103052:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103055:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103058:	eb 90                	jmp    f0102fea <debuginfo_eip+0x126>
f010305a:	4a                   	dec    %edx
f010305b:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f010305e:	39 d6                	cmp    %edx,%esi
f0103060:	7f 34                	jg     f0103096 <debuginfo_eip+0x1d2>
	       && stabs[lline].n_type != N_SOL
f0103062:	8a 08                	mov    (%eax),%cl
f0103064:	80 f9 84             	cmp    $0x84,%cl
f0103067:	74 0b                	je     f0103074 <debuginfo_eip+0x1b0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103069:	80 f9 64             	cmp    $0x64,%cl
f010306c:	75 ec                	jne    f010305a <debuginfo_eip+0x196>
f010306e:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0103072:	74 e6                	je     f010305a <debuginfo_eip+0x196>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103074:	8d 04 12             	lea    (%edx,%edx,1),%eax
f0103077:	01 c2                	add    %eax,%edx
f0103079:	8b 14 95 34 53 10 f0 	mov    -0xfefaccc(,%edx,4),%edx
f0103080:	b8 d5 e3 10 f0       	mov    $0xf010e3d5,%eax
f0103085:	2d 99 c4 10 f0       	sub    $0xf010c499,%eax
f010308a:	39 c2                	cmp    %eax,%edx
f010308c:	73 08                	jae    f0103096 <debuginfo_eip+0x1d2>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010308e:	81 c2 99 c4 10 f0    	add    $0xf010c499,%edx
f0103094:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103096:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103099:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010309c:	39 f2                	cmp    %esi,%edx
f010309e:	7d 3f                	jge    f01030df <debuginfo_eip+0x21b>
		for (lline = lfun + 1;
f01030a0:	42                   	inc    %edx
f01030a1:	89 d0                	mov    %edx,%eax
f01030a3:	8d 0c 12             	lea    (%edx,%edx,1),%ecx
f01030a6:	01 ca                	add    %ecx,%edx
f01030a8:	8d 14 95 38 53 10 f0 	lea    -0xfefacc8(,%edx,4),%edx
f01030af:	eb 03                	jmp    f01030b4 <debuginfo_eip+0x1f0>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01030b1:	ff 43 14             	incl   0x14(%ebx)
		for (lline = lfun + 1;
f01030b4:	39 c6                	cmp    %eax,%esi
f01030b6:	7e 34                	jle    f01030ec <debuginfo_eip+0x228>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01030b8:	8a 0a                	mov    (%edx),%cl
f01030ba:	40                   	inc    %eax
f01030bb:	83 c2 0c             	add    $0xc,%edx
f01030be:	80 f9 a0             	cmp    $0xa0,%cl
f01030c1:	74 ee                	je     f01030b1 <debuginfo_eip+0x1ed>

	return 0;
f01030c3:	b8 00 00 00 00       	mov    $0x0,%eax
f01030c8:	eb 1a                	jmp    f01030e4 <debuginfo_eip+0x220>
		return -1;
f01030ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01030cf:	eb 13                	jmp    f01030e4 <debuginfo_eip+0x220>
f01030d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01030d6:	eb 0c                	jmp    f01030e4 <debuginfo_eip+0x220>
		return -1;
f01030d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01030dd:	eb 05                	jmp    f01030e4 <debuginfo_eip+0x220>
	return 0;
f01030df:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01030e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01030e7:	5b                   	pop    %ebx
f01030e8:	5e                   	pop    %esi
f01030e9:	5f                   	pop    %edi
f01030ea:	5d                   	pop    %ebp
f01030eb:	c3                   	ret    
	return 0;
f01030ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01030f1:	eb f1                	jmp    f01030e4 <debuginfo_eip+0x220>

f01030f3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01030f3:	55                   	push   %ebp
f01030f4:	89 e5                	mov    %esp,%ebp
f01030f6:	57                   	push   %edi
f01030f7:	56                   	push   %esi
f01030f8:	53                   	push   %ebx
f01030f9:	83 ec 1c             	sub    $0x1c,%esp
f01030fc:	89 c7                	mov    %eax,%edi
f01030fe:	89 d6                	mov    %edx,%esi
f0103100:	8b 45 08             	mov    0x8(%ebp),%eax
f0103103:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103106:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103109:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010310c:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010310f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103114:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103117:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f010311a:	39 d3                	cmp    %edx,%ebx
f010311c:	72 05                	jb     f0103123 <printnum+0x30>
f010311e:	39 45 10             	cmp    %eax,0x10(%ebp)
f0103121:	77 78                	ja     f010319b <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103123:	83 ec 0c             	sub    $0xc,%esp
f0103126:	ff 75 18             	pushl  0x18(%ebp)
f0103129:	8b 45 14             	mov    0x14(%ebp),%eax
f010312c:	8d 58 ff             	lea    -0x1(%eax),%ebx
f010312f:	53                   	push   %ebx
f0103130:	ff 75 10             	pushl  0x10(%ebp)
f0103133:	83 ec 08             	sub    $0x8,%esp
f0103136:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103139:	ff 75 e0             	pushl  -0x20(%ebp)
f010313c:	ff 75 dc             	pushl  -0x24(%ebp)
f010313f:	ff 75 d8             	pushl  -0x28(%ebp)
f0103142:	e8 59 0a 00 00       	call   f0103ba0 <__udivdi3>
f0103147:	83 c4 18             	add    $0x18,%esp
f010314a:	52                   	push   %edx
f010314b:	50                   	push   %eax
f010314c:	89 f2                	mov    %esi,%edx
f010314e:	89 f8                	mov    %edi,%eax
f0103150:	e8 9e ff ff ff       	call   f01030f3 <printnum>
f0103155:	83 c4 20             	add    $0x20,%esp
f0103158:	eb 11                	jmp    f010316b <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010315a:	83 ec 08             	sub    $0x8,%esp
f010315d:	56                   	push   %esi
f010315e:	ff 75 18             	pushl  0x18(%ebp)
f0103161:	ff d7                	call   *%edi
f0103163:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0103166:	4b                   	dec    %ebx
f0103167:	85 db                	test   %ebx,%ebx
f0103169:	7f ef                	jg     f010315a <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010316b:	83 ec 08             	sub    $0x8,%esp
f010316e:	56                   	push   %esi
f010316f:	83 ec 04             	sub    $0x4,%esp
f0103172:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103175:	ff 75 e0             	pushl  -0x20(%ebp)
f0103178:	ff 75 dc             	pushl  -0x24(%ebp)
f010317b:	ff 75 d8             	pushl  -0x28(%ebp)
f010317e:	e8 1d 0b 00 00       	call   f0103ca0 <__umoddi3>
f0103183:	83 c4 14             	add    $0x14,%esp
f0103186:	0f be 80 23 51 10 f0 	movsbl -0xfefaedd(%eax),%eax
f010318d:	50                   	push   %eax
f010318e:	ff d7                	call   *%edi
}
f0103190:	83 c4 10             	add    $0x10,%esp
f0103193:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103196:	5b                   	pop    %ebx
f0103197:	5e                   	pop    %esi
f0103198:	5f                   	pop    %edi
f0103199:	5d                   	pop    %ebp
f010319a:	c3                   	ret    
f010319b:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010319e:	eb c6                	jmp    f0103166 <printnum+0x73>

f01031a0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01031a0:	55                   	push   %ebp
f01031a1:	89 e5                	mov    %esp,%ebp
f01031a3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01031a6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f01031a9:	8b 10                	mov    (%eax),%edx
f01031ab:	3b 50 04             	cmp    0x4(%eax),%edx
f01031ae:	73 0a                	jae    f01031ba <sprintputch+0x1a>
		*b->buf++ = ch;
f01031b0:	8d 4a 01             	lea    0x1(%edx),%ecx
f01031b3:	89 08                	mov    %ecx,(%eax)
f01031b5:	8b 45 08             	mov    0x8(%ebp),%eax
f01031b8:	88 02                	mov    %al,(%edx)
}
f01031ba:	5d                   	pop    %ebp
f01031bb:	c3                   	ret    

f01031bc <printfmt>:
{
f01031bc:	55                   	push   %ebp
f01031bd:	89 e5                	mov    %esp,%ebp
f01031bf:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01031c2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01031c5:	50                   	push   %eax
f01031c6:	ff 75 10             	pushl  0x10(%ebp)
f01031c9:	ff 75 0c             	pushl  0xc(%ebp)
f01031cc:	ff 75 08             	pushl  0x8(%ebp)
f01031cf:	e8 05 00 00 00       	call   f01031d9 <vprintfmt>
}
f01031d4:	83 c4 10             	add    $0x10,%esp
f01031d7:	c9                   	leave  
f01031d8:	c3                   	ret    

f01031d9 <vprintfmt>:
{
f01031d9:	55                   	push   %ebp
f01031da:	89 e5                	mov    %esp,%ebp
f01031dc:	57                   	push   %edi
f01031dd:	56                   	push   %esi
f01031de:	53                   	push   %ebx
f01031df:	83 ec 2c             	sub    $0x2c,%esp
f01031e2:	8b 75 08             	mov    0x8(%ebp),%esi
f01031e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01031e8:	8b 7d 10             	mov    0x10(%ebp),%edi
f01031eb:	e9 ac 03 00 00       	jmp    f010359c <vprintfmt+0x3c3>
		padc = ' ';
f01031f0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f01031f4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f01031fb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f0103202:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0103209:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f010320e:	8d 47 01             	lea    0x1(%edi),%eax
f0103211:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103214:	8a 17                	mov    (%edi),%dl
f0103216:	8d 42 dd             	lea    -0x23(%edx),%eax
f0103219:	3c 55                	cmp    $0x55,%al
f010321b:	0f 87 fc 03 00 00    	ja     f010361d <vprintfmt+0x444>
f0103221:	0f b6 c0             	movzbl %al,%eax
f0103224:	ff 24 85 b0 51 10 f0 	jmp    *-0xfefae50(,%eax,4)
f010322b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f010322e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0103232:	eb da                	jmp    f010320e <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0103234:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0103237:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f010323b:	eb d1                	jmp    f010320e <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f010323d:	0f b6 d2             	movzbl %dl,%edx
f0103240:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0103243:	b8 00 00 00 00       	mov    $0x0,%eax
f0103248:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f010324b:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010324e:	01 c0                	add    %eax,%eax
f0103250:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
f0103254:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0103257:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010325a:	83 f9 09             	cmp    $0x9,%ecx
f010325d:	77 52                	ja     f01032b1 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
f010325f:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
f0103260:	eb e9                	jmp    f010324b <vprintfmt+0x72>
			precision = va_arg(ap, int);
f0103262:	8b 45 14             	mov    0x14(%ebp),%eax
f0103265:	8b 00                	mov    (%eax),%eax
f0103267:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010326a:	8b 45 14             	mov    0x14(%ebp),%eax
f010326d:	8d 40 04             	lea    0x4(%eax),%eax
f0103270:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103273:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0103276:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010327a:	79 92                	jns    f010320e <vprintfmt+0x35>
				width = precision, precision = -1;
f010327c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010327f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103282:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103289:	eb 83                	jmp    f010320e <vprintfmt+0x35>
f010328b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010328f:	78 08                	js     f0103299 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
f0103291:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103294:	e9 75 ff ff ff       	jmp    f010320e <vprintfmt+0x35>
f0103299:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01032a0:	eb ef                	jmp    f0103291 <vprintfmt+0xb8>
f01032a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f01032a5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01032ac:	e9 5d ff ff ff       	jmp    f010320e <vprintfmt+0x35>
f01032b1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01032b4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01032b7:	eb bd                	jmp    f0103276 <vprintfmt+0x9d>
			lflag++;
f01032b9:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
f01032ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01032bd:	e9 4c ff ff ff       	jmp    f010320e <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f01032c2:	8b 45 14             	mov    0x14(%ebp),%eax
f01032c5:	8d 78 04             	lea    0x4(%eax),%edi
f01032c8:	83 ec 08             	sub    $0x8,%esp
f01032cb:	53                   	push   %ebx
f01032cc:	ff 30                	pushl  (%eax)
f01032ce:	ff d6                	call   *%esi
			break;
f01032d0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01032d3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01032d6:	e9 be 02 00 00       	jmp    f0103599 <vprintfmt+0x3c0>
			err = va_arg(ap, int);
f01032db:	8b 45 14             	mov    0x14(%ebp),%eax
f01032de:	8d 78 04             	lea    0x4(%eax),%edi
f01032e1:	8b 00                	mov    (%eax),%eax
f01032e3:	85 c0                	test   %eax,%eax
f01032e5:	78 2a                	js     f0103311 <vprintfmt+0x138>
f01032e7:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01032e9:	83 f8 06             	cmp    $0x6,%eax
f01032ec:	7f 27                	jg     f0103315 <vprintfmt+0x13c>
f01032ee:	8b 04 85 08 53 10 f0 	mov    -0xfefacf8(,%eax,4),%eax
f01032f5:	85 c0                	test   %eax,%eax
f01032f7:	74 1c                	je     f0103315 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
f01032f9:	50                   	push   %eax
f01032fa:	68 28 4e 10 f0       	push   $0xf0104e28
f01032ff:	53                   	push   %ebx
f0103300:	56                   	push   %esi
f0103301:	e8 b6 fe ff ff       	call   f01031bc <printfmt>
f0103306:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103309:	89 7d 14             	mov    %edi,0x14(%ebp)
f010330c:	e9 88 02 00 00       	jmp    f0103599 <vprintfmt+0x3c0>
f0103311:	f7 d8                	neg    %eax
f0103313:	eb d2                	jmp    f01032e7 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
f0103315:	52                   	push   %edx
f0103316:	68 3b 51 10 f0       	push   $0xf010513b
f010331b:	53                   	push   %ebx
f010331c:	56                   	push   %esi
f010331d:	e8 9a fe ff ff       	call   f01031bc <printfmt>
f0103322:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103325:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0103328:	e9 6c 02 00 00       	jmp    f0103599 <vprintfmt+0x3c0>
			if ((p = va_arg(ap, char *)) == NULL)
f010332d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103330:	83 c0 04             	add    $0x4,%eax
f0103333:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0103336:	8b 45 14             	mov    0x14(%ebp),%eax
f0103339:	8b 38                	mov    (%eax),%edi
f010333b:	85 ff                	test   %edi,%edi
f010333d:	74 18                	je     f0103357 <vprintfmt+0x17e>
			if (width > 0 && padc != '-')
f010333f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103343:	0f 8e b7 00 00 00    	jle    f0103400 <vprintfmt+0x227>
f0103349:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010334d:	75 0f                	jne    f010335e <vprintfmt+0x185>
f010334f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103352:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103355:	eb 6e                	jmp    f01033c5 <vprintfmt+0x1ec>
				p = "(null)";
f0103357:	bf 34 51 10 f0       	mov    $0xf0105134,%edi
f010335c:	eb e1                	jmp    f010333f <vprintfmt+0x166>
				for (width -= strnlen(p, precision); width > 0; width--)
f010335e:	83 ec 08             	sub    $0x8,%esp
f0103361:	ff 75 d0             	pushl  -0x30(%ebp)
f0103364:	57                   	push   %edi
f0103365:	e8 45 04 00 00       	call   f01037af <strnlen>
f010336a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010336d:	29 c1                	sub    %eax,%ecx
f010336f:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0103372:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0103375:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0103379:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010337c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010337f:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0103381:	eb 0d                	jmp    f0103390 <vprintfmt+0x1b7>
					putch(padc, putdat);
f0103383:	83 ec 08             	sub    $0x8,%esp
f0103386:	53                   	push   %ebx
f0103387:	ff 75 e0             	pushl  -0x20(%ebp)
f010338a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f010338c:	4f                   	dec    %edi
f010338d:	83 c4 10             	add    $0x10,%esp
f0103390:	85 ff                	test   %edi,%edi
f0103392:	7f ef                	jg     f0103383 <vprintfmt+0x1aa>
f0103394:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103397:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010339a:	89 c8                	mov    %ecx,%eax
f010339c:	85 c9                	test   %ecx,%ecx
f010339e:	78 59                	js     f01033f9 <vprintfmt+0x220>
f01033a0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01033a3:	29 c1                	sub    %eax,%ecx
f01033a5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01033a8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01033ab:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01033ae:	eb 15                	jmp    f01033c5 <vprintfmt+0x1ec>
				if (altflag && (ch < ' ' || ch > '~'))
f01033b0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01033b4:	75 29                	jne    f01033df <vprintfmt+0x206>
					putch(ch, putdat);
f01033b6:	83 ec 08             	sub    $0x8,%esp
f01033b9:	ff 75 0c             	pushl  0xc(%ebp)
f01033bc:	50                   	push   %eax
f01033bd:	ff d6                	call   *%esi
f01033bf:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01033c2:	ff 4d e0             	decl   -0x20(%ebp)
f01033c5:	47                   	inc    %edi
f01033c6:	8a 57 ff             	mov    -0x1(%edi),%dl
f01033c9:	0f be c2             	movsbl %dl,%eax
f01033cc:	85 c0                	test   %eax,%eax
f01033ce:	74 53                	je     f0103423 <vprintfmt+0x24a>
f01033d0:	85 db                	test   %ebx,%ebx
f01033d2:	78 dc                	js     f01033b0 <vprintfmt+0x1d7>
f01033d4:	4b                   	dec    %ebx
f01033d5:	79 d9                	jns    f01033b0 <vprintfmt+0x1d7>
f01033d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01033da:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01033dd:	eb 35                	jmp    f0103414 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
f01033df:	0f be d2             	movsbl %dl,%edx
f01033e2:	83 ea 20             	sub    $0x20,%edx
f01033e5:	83 fa 5e             	cmp    $0x5e,%edx
f01033e8:	76 cc                	jbe    f01033b6 <vprintfmt+0x1dd>
					putch('?', putdat);
f01033ea:	83 ec 08             	sub    $0x8,%esp
f01033ed:	ff 75 0c             	pushl  0xc(%ebp)
f01033f0:	6a 3f                	push   $0x3f
f01033f2:	ff d6                	call   *%esi
f01033f4:	83 c4 10             	add    $0x10,%esp
f01033f7:	eb c9                	jmp    f01033c2 <vprintfmt+0x1e9>
f01033f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01033fe:	eb a0                	jmp    f01033a0 <vprintfmt+0x1c7>
f0103400:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103403:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103406:	eb bd                	jmp    f01033c5 <vprintfmt+0x1ec>
				putch(' ', putdat);
f0103408:	83 ec 08             	sub    $0x8,%esp
f010340b:	53                   	push   %ebx
f010340c:	6a 20                	push   $0x20
f010340e:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0103410:	4f                   	dec    %edi
f0103411:	83 c4 10             	add    $0x10,%esp
f0103414:	85 ff                	test   %edi,%edi
f0103416:	7f f0                	jg     f0103408 <vprintfmt+0x22f>
			if ((p = va_arg(ap, char *)) == NULL)
f0103418:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010341b:	89 45 14             	mov    %eax,0x14(%ebp)
f010341e:	e9 76 01 00 00       	jmp    f0103599 <vprintfmt+0x3c0>
f0103423:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103426:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103429:	eb e9                	jmp    f0103414 <vprintfmt+0x23b>
	if (lflag >= 2)
f010342b:	83 f9 01             	cmp    $0x1,%ecx
f010342e:	7e 3f                	jle    f010346f <vprintfmt+0x296>
		return va_arg(*ap, long long);
f0103430:	8b 45 14             	mov    0x14(%ebp),%eax
f0103433:	8b 50 04             	mov    0x4(%eax),%edx
f0103436:	8b 00                	mov    (%eax),%eax
f0103438:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010343b:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010343e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103441:	8d 40 08             	lea    0x8(%eax),%eax
f0103444:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0103447:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010344b:	79 5c                	jns    f01034a9 <vprintfmt+0x2d0>
				putch('-', putdat);
f010344d:	83 ec 08             	sub    $0x8,%esp
f0103450:	53                   	push   %ebx
f0103451:	6a 2d                	push   $0x2d
f0103453:	ff d6                	call   *%esi
				num = -(long long) num;
f0103455:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103458:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010345b:	f7 da                	neg    %edx
f010345d:	83 d1 00             	adc    $0x0,%ecx
f0103460:	f7 d9                	neg    %ecx
f0103462:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0103465:	b8 0a 00 00 00       	mov    $0xa,%eax
f010346a:	e9 10 01 00 00       	jmp    f010357f <vprintfmt+0x3a6>
	else if (lflag)
f010346f:	85 c9                	test   %ecx,%ecx
f0103471:	75 1b                	jne    f010348e <vprintfmt+0x2b5>
		return va_arg(*ap, int);
f0103473:	8b 45 14             	mov    0x14(%ebp),%eax
f0103476:	8b 00                	mov    (%eax),%eax
f0103478:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010347b:	89 c1                	mov    %eax,%ecx
f010347d:	c1 f9 1f             	sar    $0x1f,%ecx
f0103480:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103483:	8b 45 14             	mov    0x14(%ebp),%eax
f0103486:	8d 40 04             	lea    0x4(%eax),%eax
f0103489:	89 45 14             	mov    %eax,0x14(%ebp)
f010348c:	eb b9                	jmp    f0103447 <vprintfmt+0x26e>
		return va_arg(*ap, long);
f010348e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103491:	8b 00                	mov    (%eax),%eax
f0103493:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103496:	89 c1                	mov    %eax,%ecx
f0103498:	c1 f9 1f             	sar    $0x1f,%ecx
f010349b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010349e:	8b 45 14             	mov    0x14(%ebp),%eax
f01034a1:	8d 40 04             	lea    0x4(%eax),%eax
f01034a4:	89 45 14             	mov    %eax,0x14(%ebp)
f01034a7:	eb 9e                	jmp    f0103447 <vprintfmt+0x26e>
			num = getint(&ap, lflag);
f01034a9:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01034ac:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01034af:	b8 0a 00 00 00       	mov    $0xa,%eax
f01034b4:	e9 c6 00 00 00       	jmp    f010357f <vprintfmt+0x3a6>
	if (lflag >= 2)
f01034b9:	83 f9 01             	cmp    $0x1,%ecx
f01034bc:	7e 18                	jle    f01034d6 <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
f01034be:	8b 45 14             	mov    0x14(%ebp),%eax
f01034c1:	8b 10                	mov    (%eax),%edx
f01034c3:	8b 48 04             	mov    0x4(%eax),%ecx
f01034c6:	8d 40 08             	lea    0x8(%eax),%eax
f01034c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01034cc:	b8 0a 00 00 00       	mov    $0xa,%eax
f01034d1:	e9 a9 00 00 00       	jmp    f010357f <vprintfmt+0x3a6>
	else if (lflag)
f01034d6:	85 c9                	test   %ecx,%ecx
f01034d8:	75 1a                	jne    f01034f4 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned int);
f01034da:	8b 45 14             	mov    0x14(%ebp),%eax
f01034dd:	8b 10                	mov    (%eax),%edx
f01034df:	b9 00 00 00 00       	mov    $0x0,%ecx
f01034e4:	8d 40 04             	lea    0x4(%eax),%eax
f01034e7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01034ea:	b8 0a 00 00 00       	mov    $0xa,%eax
f01034ef:	e9 8b 00 00 00       	jmp    f010357f <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f01034f4:	8b 45 14             	mov    0x14(%ebp),%eax
f01034f7:	8b 10                	mov    (%eax),%edx
f01034f9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01034fe:	8d 40 04             	lea    0x4(%eax),%eax
f0103501:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103504:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103509:	eb 74                	jmp    f010357f <vprintfmt+0x3a6>
	if (lflag >= 2)
f010350b:	83 f9 01             	cmp    $0x1,%ecx
f010350e:	7e 15                	jle    f0103525 <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
f0103510:	8b 45 14             	mov    0x14(%ebp),%eax
f0103513:	8b 10                	mov    (%eax),%edx
f0103515:	8b 48 04             	mov    0x4(%eax),%ecx
f0103518:	8d 40 08             	lea    0x8(%eax),%eax
f010351b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010351e:	b8 08 00 00 00       	mov    $0x8,%eax
f0103523:	eb 5a                	jmp    f010357f <vprintfmt+0x3a6>
	else if (lflag)
f0103525:	85 c9                	test   %ecx,%ecx
f0103527:	75 17                	jne    f0103540 <vprintfmt+0x367>
		return va_arg(*ap, unsigned int);
f0103529:	8b 45 14             	mov    0x14(%ebp),%eax
f010352c:	8b 10                	mov    (%eax),%edx
f010352e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103533:	8d 40 04             	lea    0x4(%eax),%eax
f0103536:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0103539:	b8 08 00 00 00       	mov    $0x8,%eax
f010353e:	eb 3f                	jmp    f010357f <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0103540:	8b 45 14             	mov    0x14(%ebp),%eax
f0103543:	8b 10                	mov    (%eax),%edx
f0103545:	b9 00 00 00 00       	mov    $0x0,%ecx
f010354a:	8d 40 04             	lea    0x4(%eax),%eax
f010354d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0103550:	b8 08 00 00 00       	mov    $0x8,%eax
f0103555:	eb 28                	jmp    f010357f <vprintfmt+0x3a6>
			putch('0', putdat);
f0103557:	83 ec 08             	sub    $0x8,%esp
f010355a:	53                   	push   %ebx
f010355b:	6a 30                	push   $0x30
f010355d:	ff d6                	call   *%esi
			putch('x', putdat);
f010355f:	83 c4 08             	add    $0x8,%esp
f0103562:	53                   	push   %ebx
f0103563:	6a 78                	push   $0x78
f0103565:	ff d6                	call   *%esi
			num = (unsigned long long)
f0103567:	8b 45 14             	mov    0x14(%ebp),%eax
f010356a:	8b 10                	mov    (%eax),%edx
f010356c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0103571:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0103574:	8d 40 04             	lea    0x4(%eax),%eax
f0103577:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010357a:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f010357f:	83 ec 0c             	sub    $0xc,%esp
f0103582:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0103586:	57                   	push   %edi
f0103587:	ff 75 e0             	pushl  -0x20(%ebp)
f010358a:	50                   	push   %eax
f010358b:	51                   	push   %ecx
f010358c:	52                   	push   %edx
f010358d:	89 da                	mov    %ebx,%edx
f010358f:	89 f0                	mov    %esi,%eax
f0103591:	e8 5d fb ff ff       	call   f01030f3 <printnum>
			break;
f0103596:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0103599:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010359c:	47                   	inc    %edi
f010359d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01035a1:	83 f8 25             	cmp    $0x25,%eax
f01035a4:	0f 84 46 fc ff ff    	je     f01031f0 <vprintfmt+0x17>
			if (ch == '\0')
f01035aa:	85 c0                	test   %eax,%eax
f01035ac:	0f 84 89 00 00 00    	je     f010363b <vprintfmt+0x462>
			putch(ch, putdat);
f01035b2:	83 ec 08             	sub    $0x8,%esp
f01035b5:	53                   	push   %ebx
f01035b6:	50                   	push   %eax
f01035b7:	ff d6                	call   *%esi
f01035b9:	83 c4 10             	add    $0x10,%esp
f01035bc:	eb de                	jmp    f010359c <vprintfmt+0x3c3>
	if (lflag >= 2)
f01035be:	83 f9 01             	cmp    $0x1,%ecx
f01035c1:	7e 15                	jle    f01035d8 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
f01035c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01035c6:	8b 10                	mov    (%eax),%edx
f01035c8:	8b 48 04             	mov    0x4(%eax),%ecx
f01035cb:	8d 40 08             	lea    0x8(%eax),%eax
f01035ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01035d1:	b8 10 00 00 00       	mov    $0x10,%eax
f01035d6:	eb a7                	jmp    f010357f <vprintfmt+0x3a6>
	else if (lflag)
f01035d8:	85 c9                	test   %ecx,%ecx
f01035da:	75 17                	jne    f01035f3 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned int);
f01035dc:	8b 45 14             	mov    0x14(%ebp),%eax
f01035df:	8b 10                	mov    (%eax),%edx
f01035e1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01035e6:	8d 40 04             	lea    0x4(%eax),%eax
f01035e9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01035ec:	b8 10 00 00 00       	mov    $0x10,%eax
f01035f1:	eb 8c                	jmp    f010357f <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f01035f3:	8b 45 14             	mov    0x14(%ebp),%eax
f01035f6:	8b 10                	mov    (%eax),%edx
f01035f8:	b9 00 00 00 00       	mov    $0x0,%ecx
f01035fd:	8d 40 04             	lea    0x4(%eax),%eax
f0103600:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103603:	b8 10 00 00 00       	mov    $0x10,%eax
f0103608:	e9 72 ff ff ff       	jmp    f010357f <vprintfmt+0x3a6>
			putch(ch, putdat);
f010360d:	83 ec 08             	sub    $0x8,%esp
f0103610:	53                   	push   %ebx
f0103611:	6a 25                	push   $0x25
f0103613:	ff d6                	call   *%esi
			break;
f0103615:	83 c4 10             	add    $0x10,%esp
f0103618:	e9 7c ff ff ff       	jmp    f0103599 <vprintfmt+0x3c0>
			putch('%', putdat);
f010361d:	83 ec 08             	sub    $0x8,%esp
f0103620:	53                   	push   %ebx
f0103621:	6a 25                	push   $0x25
f0103623:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103625:	83 c4 10             	add    $0x10,%esp
f0103628:	89 f8                	mov    %edi,%eax
f010362a:	eb 01                	jmp    f010362d <vprintfmt+0x454>
f010362c:	48                   	dec    %eax
f010362d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0103631:	75 f9                	jne    f010362c <vprintfmt+0x453>
f0103633:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103636:	e9 5e ff ff ff       	jmp    f0103599 <vprintfmt+0x3c0>
}
f010363b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010363e:	5b                   	pop    %ebx
f010363f:	5e                   	pop    %esi
f0103640:	5f                   	pop    %edi
f0103641:	5d                   	pop    %ebp
f0103642:	c3                   	ret    

f0103643 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103643:	55                   	push   %ebp
f0103644:	89 e5                	mov    %esp,%ebp
f0103646:	83 ec 18             	sub    $0x18,%esp
f0103649:	8b 45 08             	mov    0x8(%ebp),%eax
f010364c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010364f:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103652:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103656:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103659:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103660:	85 c0                	test   %eax,%eax
f0103662:	74 26                	je     f010368a <vsnprintf+0x47>
f0103664:	85 d2                	test   %edx,%edx
f0103666:	7e 29                	jle    f0103691 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103668:	ff 75 14             	pushl  0x14(%ebp)
f010366b:	ff 75 10             	pushl  0x10(%ebp)
f010366e:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103671:	50                   	push   %eax
f0103672:	68 a0 31 10 f0       	push   $0xf01031a0
f0103677:	e8 5d fb ff ff       	call   f01031d9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010367c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010367f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103682:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103685:	83 c4 10             	add    $0x10,%esp
}
f0103688:	c9                   	leave  
f0103689:	c3                   	ret    
		return -E_INVAL;
f010368a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010368f:	eb f7                	jmp    f0103688 <vsnprintf+0x45>
f0103691:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103696:	eb f0                	jmp    f0103688 <vsnprintf+0x45>

f0103698 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103698:	55                   	push   %ebp
f0103699:	89 e5                	mov    %esp,%ebp
f010369b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010369e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01036a1:	50                   	push   %eax
f01036a2:	ff 75 10             	pushl  0x10(%ebp)
f01036a5:	ff 75 0c             	pushl  0xc(%ebp)
f01036a8:	ff 75 08             	pushl  0x8(%ebp)
f01036ab:	e8 93 ff ff ff       	call   f0103643 <vsnprintf>
	va_end(ap);

	return rc;
}
f01036b0:	c9                   	leave  
f01036b1:	c3                   	ret    

f01036b2 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01036b2:	55                   	push   %ebp
f01036b3:	89 e5                	mov    %esp,%ebp
f01036b5:	57                   	push   %edi
f01036b6:	56                   	push   %esi
f01036b7:	53                   	push   %ebx
f01036b8:	83 ec 0c             	sub    $0xc,%esp
f01036bb:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01036be:	85 c0                	test   %eax,%eax
f01036c0:	74 11                	je     f01036d3 <readline+0x21>
		cprintf("%s", prompt);
f01036c2:	83 ec 08             	sub    $0x8,%esp
f01036c5:	50                   	push   %eax
f01036c6:	68 28 4e 10 f0       	push   $0xf0104e28
f01036cb:	e8 f3 f6 ff ff       	call   f0102dc3 <cprintf>
f01036d0:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01036d3:	83 ec 0c             	sub    $0xc,%esp
f01036d6:	6a 00                	push   $0x0
f01036d8:	e8 ca cf ff ff       	call   f01006a7 <iscons>
f01036dd:	89 c7                	mov    %eax,%edi
f01036df:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01036e2:	be 00 00 00 00       	mov    $0x0,%esi
f01036e7:	eb 6f                	jmp    f0103758 <readline+0xa6>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01036e9:	83 ec 08             	sub    $0x8,%esp
f01036ec:	50                   	push   %eax
f01036ed:	68 24 53 10 f0       	push   $0xf0105324
f01036f2:	e8 cc f6 ff ff       	call   f0102dc3 <cprintf>
			return NULL;
f01036f7:	83 c4 10             	add    $0x10,%esp
f01036fa:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01036ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103702:	5b                   	pop    %ebx
f0103703:	5e                   	pop    %esi
f0103704:	5f                   	pop    %edi
f0103705:	5d                   	pop    %ebp
f0103706:	c3                   	ret    
				cputchar('\b');
f0103707:	83 ec 0c             	sub    $0xc,%esp
f010370a:	6a 08                	push   $0x8
f010370c:	e8 75 cf ff ff       	call   f0100686 <cputchar>
f0103711:	83 c4 10             	add    $0x10,%esp
f0103714:	eb 41                	jmp    f0103757 <readline+0xa5>
				cputchar(c);
f0103716:	83 ec 0c             	sub    $0xc,%esp
f0103719:	53                   	push   %ebx
f010371a:	e8 67 cf ff ff       	call   f0100686 <cputchar>
f010371f:	83 c4 10             	add    $0x10,%esp
f0103722:	eb 5a                	jmp    f010377e <readline+0xcc>
		} else if (c == '\n' || c == '\r') {
f0103724:	83 fb 0a             	cmp    $0xa,%ebx
f0103727:	74 05                	je     f010372e <readline+0x7c>
f0103729:	83 fb 0d             	cmp    $0xd,%ebx
f010372c:	75 2a                	jne    f0103758 <readline+0xa6>
			if (echoing)
f010372e:	85 ff                	test   %edi,%edi
f0103730:	75 0e                	jne    f0103740 <readline+0x8e>
			buf[i] = 0;
f0103732:	c6 86 60 95 11 f0 00 	movb   $0x0,-0xfee6aa0(%esi)
			return buf;
f0103739:	b8 60 95 11 f0       	mov    $0xf0119560,%eax
f010373e:	eb bf                	jmp    f01036ff <readline+0x4d>
				cputchar('\n');
f0103740:	83 ec 0c             	sub    $0xc,%esp
f0103743:	6a 0a                	push   $0xa
f0103745:	e8 3c cf ff ff       	call   f0100686 <cputchar>
f010374a:	83 c4 10             	add    $0x10,%esp
f010374d:	eb e3                	jmp    f0103732 <readline+0x80>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010374f:	85 f6                	test   %esi,%esi
f0103751:	7e 3c                	jle    f010378f <readline+0xdd>
			if (echoing)
f0103753:	85 ff                	test   %edi,%edi
f0103755:	75 b0                	jne    f0103707 <readline+0x55>
			i--;
f0103757:	4e                   	dec    %esi
		c = getchar();
f0103758:	e8 39 cf ff ff       	call   f0100696 <getchar>
f010375d:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010375f:	85 c0                	test   %eax,%eax
f0103761:	78 86                	js     f01036e9 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103763:	83 f8 08             	cmp    $0x8,%eax
f0103766:	74 21                	je     f0103789 <readline+0xd7>
f0103768:	83 f8 7f             	cmp    $0x7f,%eax
f010376b:	74 e2                	je     f010374f <readline+0x9d>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010376d:	83 f8 1f             	cmp    $0x1f,%eax
f0103770:	7e b2                	jle    f0103724 <readline+0x72>
f0103772:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103778:	7f aa                	jg     f0103724 <readline+0x72>
			if (echoing)
f010377a:	85 ff                	test   %edi,%edi
f010377c:	75 98                	jne    f0103716 <readline+0x64>
			buf[i++] = c;
f010377e:	88 9e 60 95 11 f0    	mov    %bl,-0xfee6aa0(%esi)
f0103784:	8d 76 01             	lea    0x1(%esi),%esi
f0103787:	eb cf                	jmp    f0103758 <readline+0xa6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103789:	85 f6                	test   %esi,%esi
f010378b:	7e cb                	jle    f0103758 <readline+0xa6>
f010378d:	eb c4                	jmp    f0103753 <readline+0xa1>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010378f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103795:	7e e3                	jle    f010377a <readline+0xc8>
f0103797:	eb bf                	jmp    f0103758 <readline+0xa6>

f0103799 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103799:	55                   	push   %ebp
f010379a:	89 e5                	mov    %esp,%ebp
f010379c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010379f:	b8 00 00 00 00       	mov    $0x0,%eax
f01037a4:	eb 01                	jmp    f01037a7 <strlen+0xe>
		n++;
f01037a6:	40                   	inc    %eax
	for (n = 0; *s != '\0'; s++)
f01037a7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01037ab:	75 f9                	jne    f01037a6 <strlen+0xd>
	return n;
}
f01037ad:	5d                   	pop    %ebp
f01037ae:	c3                   	ret    

f01037af <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01037af:	55                   	push   %ebp
f01037b0:	89 e5                	mov    %esp,%ebp
f01037b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01037b5:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01037b8:	b8 00 00 00 00       	mov    $0x0,%eax
f01037bd:	eb 01                	jmp    f01037c0 <strnlen+0x11>
		n++;
f01037bf:	40                   	inc    %eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01037c0:	39 d0                	cmp    %edx,%eax
f01037c2:	74 06                	je     f01037ca <strnlen+0x1b>
f01037c4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01037c8:	75 f5                	jne    f01037bf <strnlen+0x10>
	return n;
}
f01037ca:	5d                   	pop    %ebp
f01037cb:	c3                   	ret    

f01037cc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01037cc:	55                   	push   %ebp
f01037cd:	89 e5                	mov    %esp,%ebp
f01037cf:	53                   	push   %ebx
f01037d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01037d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01037d6:	89 c2                	mov    %eax,%edx
f01037d8:	41                   	inc    %ecx
f01037d9:	42                   	inc    %edx
f01037da:	8a 59 ff             	mov    -0x1(%ecx),%bl
f01037dd:	88 5a ff             	mov    %bl,-0x1(%edx)
f01037e0:	84 db                	test   %bl,%bl
f01037e2:	75 f4                	jne    f01037d8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01037e4:	5b                   	pop    %ebx
f01037e5:	5d                   	pop    %ebp
f01037e6:	c3                   	ret    

f01037e7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01037e7:	55                   	push   %ebp
f01037e8:	89 e5                	mov    %esp,%ebp
f01037ea:	53                   	push   %ebx
f01037eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01037ee:	53                   	push   %ebx
f01037ef:	e8 a5 ff ff ff       	call   f0103799 <strlen>
f01037f4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01037f7:	ff 75 0c             	pushl  0xc(%ebp)
f01037fa:	01 d8                	add    %ebx,%eax
f01037fc:	50                   	push   %eax
f01037fd:	e8 ca ff ff ff       	call   f01037cc <strcpy>
	return dst;
}
f0103802:	89 d8                	mov    %ebx,%eax
f0103804:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103807:	c9                   	leave  
f0103808:	c3                   	ret    

f0103809 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103809:	55                   	push   %ebp
f010380a:	89 e5                	mov    %esp,%ebp
f010380c:	56                   	push   %esi
f010380d:	53                   	push   %ebx
f010380e:	8b 75 08             	mov    0x8(%ebp),%esi
f0103811:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103814:	89 f3                	mov    %esi,%ebx
f0103816:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103819:	89 f2                	mov    %esi,%edx
f010381b:	39 da                	cmp    %ebx,%edx
f010381d:	74 0e                	je     f010382d <strncpy+0x24>
		*dst++ = *src;
f010381f:	42                   	inc    %edx
f0103820:	8a 01                	mov    (%ecx),%al
f0103822:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f0103825:	80 39 00             	cmpb   $0x0,(%ecx)
f0103828:	74 f1                	je     f010381b <strncpy+0x12>
			src++;
f010382a:	41                   	inc    %ecx
f010382b:	eb ee                	jmp    f010381b <strncpy+0x12>
	}
	return ret;
}
f010382d:	89 f0                	mov    %esi,%eax
f010382f:	5b                   	pop    %ebx
f0103830:	5e                   	pop    %esi
f0103831:	5d                   	pop    %ebp
f0103832:	c3                   	ret    

f0103833 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103833:	55                   	push   %ebp
f0103834:	89 e5                	mov    %esp,%ebp
f0103836:	56                   	push   %esi
f0103837:	53                   	push   %ebx
f0103838:	8b 75 08             	mov    0x8(%ebp),%esi
f010383b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010383e:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103841:	85 c0                	test   %eax,%eax
f0103843:	74 20                	je     f0103865 <strlcpy+0x32>
f0103845:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
f0103849:	89 f0                	mov    %esi,%eax
f010384b:	eb 05                	jmp    f0103852 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010384d:	42                   	inc    %edx
f010384e:	40                   	inc    %eax
f010384f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0103852:	39 d8                	cmp    %ebx,%eax
f0103854:	74 06                	je     f010385c <strlcpy+0x29>
f0103856:	8a 0a                	mov    (%edx),%cl
f0103858:	84 c9                	test   %cl,%cl
f010385a:	75 f1                	jne    f010384d <strlcpy+0x1a>
		*dst = '\0';
f010385c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010385f:	29 f0                	sub    %esi,%eax
}
f0103861:	5b                   	pop    %ebx
f0103862:	5e                   	pop    %esi
f0103863:	5d                   	pop    %ebp
f0103864:	c3                   	ret    
f0103865:	89 f0                	mov    %esi,%eax
f0103867:	eb f6                	jmp    f010385f <strlcpy+0x2c>

f0103869 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103869:	55                   	push   %ebp
f010386a:	89 e5                	mov    %esp,%ebp
f010386c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010386f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103872:	eb 02                	jmp    f0103876 <strcmp+0xd>
		p++, q++;
f0103874:	41                   	inc    %ecx
f0103875:	42                   	inc    %edx
	while (*p && *p == *q)
f0103876:	8a 01                	mov    (%ecx),%al
f0103878:	84 c0                	test   %al,%al
f010387a:	74 04                	je     f0103880 <strcmp+0x17>
f010387c:	3a 02                	cmp    (%edx),%al
f010387e:	74 f4                	je     f0103874 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103880:	0f b6 c0             	movzbl %al,%eax
f0103883:	0f b6 12             	movzbl (%edx),%edx
f0103886:	29 d0                	sub    %edx,%eax
}
f0103888:	5d                   	pop    %ebp
f0103889:	c3                   	ret    

f010388a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010388a:	55                   	push   %ebp
f010388b:	89 e5                	mov    %esp,%ebp
f010388d:	53                   	push   %ebx
f010388e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103891:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103894:	89 c3                	mov    %eax,%ebx
f0103896:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103899:	eb 02                	jmp    f010389d <strncmp+0x13>
		n--, p++, q++;
f010389b:	40                   	inc    %eax
f010389c:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
f010389d:	39 d8                	cmp    %ebx,%eax
f010389f:	74 15                	je     f01038b6 <strncmp+0x2c>
f01038a1:	8a 08                	mov    (%eax),%cl
f01038a3:	84 c9                	test   %cl,%cl
f01038a5:	74 04                	je     f01038ab <strncmp+0x21>
f01038a7:	3a 0a                	cmp    (%edx),%cl
f01038a9:	74 f0                	je     f010389b <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01038ab:	0f b6 00             	movzbl (%eax),%eax
f01038ae:	0f b6 12             	movzbl (%edx),%edx
f01038b1:	29 d0                	sub    %edx,%eax
}
f01038b3:	5b                   	pop    %ebx
f01038b4:	5d                   	pop    %ebp
f01038b5:	c3                   	ret    
		return 0;
f01038b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01038bb:	eb f6                	jmp    f01038b3 <strncmp+0x29>

f01038bd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01038bd:	55                   	push   %ebp
f01038be:	89 e5                	mov    %esp,%ebp
f01038c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01038c3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01038c6:	8a 10                	mov    (%eax),%dl
f01038c8:	84 d2                	test   %dl,%dl
f01038ca:	74 07                	je     f01038d3 <strchr+0x16>
		if (*s == c)
f01038cc:	38 ca                	cmp    %cl,%dl
f01038ce:	74 08                	je     f01038d8 <strchr+0x1b>
	for (; *s; s++)
f01038d0:	40                   	inc    %eax
f01038d1:	eb f3                	jmp    f01038c6 <strchr+0x9>
			return (char *) s;
	return 0;
f01038d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01038d8:	5d                   	pop    %ebp
f01038d9:	c3                   	ret    

f01038da <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01038da:	55                   	push   %ebp
f01038db:	89 e5                	mov    %esp,%ebp
f01038dd:	8b 45 08             	mov    0x8(%ebp),%eax
f01038e0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01038e3:	8a 10                	mov    (%eax),%dl
f01038e5:	84 d2                	test   %dl,%dl
f01038e7:	74 07                	je     f01038f0 <strfind+0x16>
		if (*s == c)
f01038e9:	38 ca                	cmp    %cl,%dl
f01038eb:	74 03                	je     f01038f0 <strfind+0x16>
	for (; *s; s++)
f01038ed:	40                   	inc    %eax
f01038ee:	eb f3                	jmp    f01038e3 <strfind+0x9>
			break;
	return (char *) s;
}
f01038f0:	5d                   	pop    %ebp
f01038f1:	c3                   	ret    

f01038f2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01038f2:	55                   	push   %ebp
f01038f3:	89 e5                	mov    %esp,%ebp
f01038f5:	57                   	push   %edi
f01038f6:	56                   	push   %esi
f01038f7:	53                   	push   %ebx
f01038f8:	8b 7d 08             	mov    0x8(%ebp),%edi
f01038fb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01038fe:	85 c9                	test   %ecx,%ecx
f0103900:	74 13                	je     f0103915 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103902:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103908:	75 05                	jne    f010390f <memset+0x1d>
f010390a:	f6 c1 03             	test   $0x3,%cl
f010390d:	74 0d                	je     f010391c <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010390f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103912:	fc                   	cld    
f0103913:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103915:	89 f8                	mov    %edi,%eax
f0103917:	5b                   	pop    %ebx
f0103918:	5e                   	pop    %esi
f0103919:	5f                   	pop    %edi
f010391a:	5d                   	pop    %ebp
f010391b:	c3                   	ret    
		c &= 0xFF;
f010391c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103920:	89 d3                	mov    %edx,%ebx
f0103922:	c1 e3 08             	shl    $0x8,%ebx
f0103925:	89 d0                	mov    %edx,%eax
f0103927:	c1 e0 18             	shl    $0x18,%eax
f010392a:	89 d6                	mov    %edx,%esi
f010392c:	c1 e6 10             	shl    $0x10,%esi
f010392f:	09 f0                	or     %esi,%eax
f0103931:	09 c2                	or     %eax,%edx
f0103933:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0103935:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0103938:	89 d0                	mov    %edx,%eax
f010393a:	fc                   	cld    
f010393b:	f3 ab                	rep stos %eax,%es:(%edi)
f010393d:	eb d6                	jmp    f0103915 <memset+0x23>

f010393f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010393f:	55                   	push   %ebp
f0103940:	89 e5                	mov    %esp,%ebp
f0103942:	57                   	push   %edi
f0103943:	56                   	push   %esi
f0103944:	8b 45 08             	mov    0x8(%ebp),%eax
f0103947:	8b 75 0c             	mov    0xc(%ebp),%esi
f010394a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010394d:	39 c6                	cmp    %eax,%esi
f010394f:	73 33                	jae    f0103984 <memmove+0x45>
f0103951:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103954:	39 c2                	cmp    %eax,%edx
f0103956:	76 2c                	jbe    f0103984 <memmove+0x45>
		s += n;
		d += n;
f0103958:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010395b:	89 d6                	mov    %edx,%esi
f010395d:	09 fe                	or     %edi,%esi
f010395f:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103965:	74 0a                	je     f0103971 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0103967:	4f                   	dec    %edi
f0103968:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f010396b:	fd                   	std    
f010396c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010396e:	fc                   	cld    
f010396f:	eb 21                	jmp    f0103992 <memmove+0x53>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103971:	f6 c1 03             	test   $0x3,%cl
f0103974:	75 f1                	jne    f0103967 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103976:	83 ef 04             	sub    $0x4,%edi
f0103979:	8d 72 fc             	lea    -0x4(%edx),%esi
f010397c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f010397f:	fd                   	std    
f0103980:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103982:	eb ea                	jmp    f010396e <memmove+0x2f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103984:	89 f2                	mov    %esi,%edx
f0103986:	09 c2                	or     %eax,%edx
f0103988:	f6 c2 03             	test   $0x3,%dl
f010398b:	74 09                	je     f0103996 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010398d:	89 c7                	mov    %eax,%edi
f010398f:	fc                   	cld    
f0103990:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103992:	5e                   	pop    %esi
f0103993:	5f                   	pop    %edi
f0103994:	5d                   	pop    %ebp
f0103995:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103996:	f6 c1 03             	test   $0x3,%cl
f0103999:	75 f2                	jne    f010398d <memmove+0x4e>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010399b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f010399e:	89 c7                	mov    %eax,%edi
f01039a0:	fc                   	cld    
f01039a1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01039a3:	eb ed                	jmp    f0103992 <memmove+0x53>

f01039a5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01039a5:	55                   	push   %ebp
f01039a6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01039a8:	ff 75 10             	pushl  0x10(%ebp)
f01039ab:	ff 75 0c             	pushl  0xc(%ebp)
f01039ae:	ff 75 08             	pushl  0x8(%ebp)
f01039b1:	e8 89 ff ff ff       	call   f010393f <memmove>
}
f01039b6:	c9                   	leave  
f01039b7:	c3                   	ret    

f01039b8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01039b8:	55                   	push   %ebp
f01039b9:	89 e5                	mov    %esp,%ebp
f01039bb:	56                   	push   %esi
f01039bc:	53                   	push   %ebx
f01039bd:	8b 45 08             	mov    0x8(%ebp),%eax
f01039c0:	8b 55 0c             	mov    0xc(%ebp),%edx
f01039c3:	89 c6                	mov    %eax,%esi
f01039c5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01039c8:	39 f0                	cmp    %esi,%eax
f01039ca:	74 16                	je     f01039e2 <memcmp+0x2a>
		if (*s1 != *s2)
f01039cc:	8a 08                	mov    (%eax),%cl
f01039ce:	8a 1a                	mov    (%edx),%bl
f01039d0:	38 d9                	cmp    %bl,%cl
f01039d2:	75 04                	jne    f01039d8 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01039d4:	40                   	inc    %eax
f01039d5:	42                   	inc    %edx
f01039d6:	eb f0                	jmp    f01039c8 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f01039d8:	0f b6 c1             	movzbl %cl,%eax
f01039db:	0f b6 db             	movzbl %bl,%ebx
f01039de:	29 d8                	sub    %ebx,%eax
f01039e0:	eb 05                	jmp    f01039e7 <memcmp+0x2f>
	}

	return 0;
f01039e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01039e7:	5b                   	pop    %ebx
f01039e8:	5e                   	pop    %esi
f01039e9:	5d                   	pop    %ebp
f01039ea:	c3                   	ret    

f01039eb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01039eb:	55                   	push   %ebp
f01039ec:	89 e5                	mov    %esp,%ebp
f01039ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01039f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01039f4:	89 c2                	mov    %eax,%edx
f01039f6:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01039f9:	39 d0                	cmp    %edx,%eax
f01039fb:	73 07                	jae    f0103a04 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
f01039fd:	38 08                	cmp    %cl,(%eax)
f01039ff:	74 03                	je     f0103a04 <memfind+0x19>
	for (; s < ends; s++)
f0103a01:	40                   	inc    %eax
f0103a02:	eb f5                	jmp    f01039f9 <memfind+0xe>
			break;
	return (void *) s;
}
f0103a04:	5d                   	pop    %ebp
f0103a05:	c3                   	ret    

f0103a06 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103a06:	55                   	push   %ebp
f0103a07:	89 e5                	mov    %esp,%ebp
f0103a09:	57                   	push   %edi
f0103a0a:	56                   	push   %esi
f0103a0b:	53                   	push   %ebx
f0103a0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103a0f:	eb 01                	jmp    f0103a12 <strtol+0xc>
		s++;
f0103a11:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f0103a12:	8a 01                	mov    (%ecx),%al
f0103a14:	3c 20                	cmp    $0x20,%al
f0103a16:	74 f9                	je     f0103a11 <strtol+0xb>
f0103a18:	3c 09                	cmp    $0x9,%al
f0103a1a:	74 f5                	je     f0103a11 <strtol+0xb>

	// plus/minus sign
	if (*s == '+')
f0103a1c:	3c 2b                	cmp    $0x2b,%al
f0103a1e:	74 2b                	je     f0103a4b <strtol+0x45>
		s++;
	else if (*s == '-')
f0103a20:	3c 2d                	cmp    $0x2d,%al
f0103a22:	74 2f                	je     f0103a53 <strtol+0x4d>
	int neg = 0;
f0103a24:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103a29:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f0103a30:	75 12                	jne    f0103a44 <strtol+0x3e>
f0103a32:	80 39 30             	cmpb   $0x30,(%ecx)
f0103a35:	74 24                	je     f0103a5b <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103a37:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0103a3b:	75 07                	jne    f0103a44 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103a3d:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f0103a44:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a49:	eb 4e                	jmp    f0103a99 <strtol+0x93>
		s++;
f0103a4b:	41                   	inc    %ecx
	int neg = 0;
f0103a4c:	bf 00 00 00 00       	mov    $0x0,%edi
f0103a51:	eb d6                	jmp    f0103a29 <strtol+0x23>
		s++, neg = 1;
f0103a53:	41                   	inc    %ecx
f0103a54:	bf 01 00 00 00       	mov    $0x1,%edi
f0103a59:	eb ce                	jmp    f0103a29 <strtol+0x23>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103a5b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0103a5f:	74 10                	je     f0103a71 <strtol+0x6b>
	else if (base == 0 && s[0] == '0')
f0103a61:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0103a65:	75 dd                	jne    f0103a44 <strtol+0x3e>
		s++, base = 8;
f0103a67:	41                   	inc    %ecx
f0103a68:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f0103a6f:	eb d3                	jmp    f0103a44 <strtol+0x3e>
		s += 2, base = 16;
f0103a71:	83 c1 02             	add    $0x2,%ecx
f0103a74:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f0103a7b:	eb c7                	jmp    f0103a44 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0103a7d:	8d 72 9f             	lea    -0x61(%edx),%esi
f0103a80:	89 f3                	mov    %esi,%ebx
f0103a82:	80 fb 19             	cmp    $0x19,%bl
f0103a85:	77 24                	ja     f0103aab <strtol+0xa5>
			dig = *s - 'a' + 10;
f0103a87:	0f be d2             	movsbl %dl,%edx
f0103a8a:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0103a8d:	3b 55 10             	cmp    0x10(%ebp),%edx
f0103a90:	7d 2b                	jge    f0103abd <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
f0103a92:	41                   	inc    %ecx
f0103a93:	0f af 45 10          	imul   0x10(%ebp),%eax
f0103a97:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0103a99:	8a 11                	mov    (%ecx),%dl
f0103a9b:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0103a9e:	80 fb 09             	cmp    $0x9,%bl
f0103aa1:	77 da                	ja     f0103a7d <strtol+0x77>
			dig = *s - '0';
f0103aa3:	0f be d2             	movsbl %dl,%edx
f0103aa6:	83 ea 30             	sub    $0x30,%edx
f0103aa9:	eb e2                	jmp    f0103a8d <strtol+0x87>
		else if (*s >= 'A' && *s <= 'Z')
f0103aab:	8d 72 bf             	lea    -0x41(%edx),%esi
f0103aae:	89 f3                	mov    %esi,%ebx
f0103ab0:	80 fb 19             	cmp    $0x19,%bl
f0103ab3:	77 08                	ja     f0103abd <strtol+0xb7>
			dig = *s - 'A' + 10;
f0103ab5:	0f be d2             	movsbl %dl,%edx
f0103ab8:	83 ea 37             	sub    $0x37,%edx
f0103abb:	eb d0                	jmp    f0103a8d <strtol+0x87>
		// we don't properly detect overflow!
	}

	if (endptr)
f0103abd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103ac1:	74 05                	je     f0103ac8 <strtol+0xc2>
		*endptr = (char *) s;
f0103ac3:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103ac6:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0103ac8:	85 ff                	test   %edi,%edi
f0103aca:	74 02                	je     f0103ace <strtol+0xc8>
f0103acc:	f7 d8                	neg    %eax
}
f0103ace:	5b                   	pop    %ebx
f0103acf:	5e                   	pop    %esi
f0103ad0:	5f                   	pop    %edi
f0103ad1:	5d                   	pop    %ebp
f0103ad2:	c3                   	ret    

f0103ad3 <strtoul>:

unsigned long
strtoul(const char *s, char **endptr, int base)
{
f0103ad3:	55                   	push   %ebp
f0103ad4:	89 e5                	mov    %esp,%ebp
f0103ad6:	57                   	push   %edi
f0103ad7:	56                   	push   %esi
f0103ad8:	53                   	push   %ebx
f0103ad9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	unsigned long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103adc:	eb 01                	jmp    f0103adf <strtoul+0xc>
		s++;
f0103ade:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f0103adf:	8a 01                	mov    (%ecx),%al
f0103ae1:	3c 20                	cmp    $0x20,%al
f0103ae3:	74 f9                	je     f0103ade <strtoul+0xb>
f0103ae5:	3c 09                	cmp    $0x9,%al
f0103ae7:	74 f5                	je     f0103ade <strtoul+0xb>

	// plus/minus sign
	if (*s == '+')
f0103ae9:	3c 2b                	cmp    $0x2b,%al
f0103aeb:	74 2b                	je     f0103b18 <strtoul+0x45>
		s++;
	else if (*s == '-')
f0103aed:	3c 2d                	cmp    $0x2d,%al
f0103aef:	74 2f                	je     f0103b20 <strtoul+0x4d>
	int neg = 0;
f0103af1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103af6:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f0103afd:	75 12                	jne    f0103b11 <strtoul+0x3e>
f0103aff:	80 39 30             	cmpb   $0x30,(%ecx)
f0103b02:	74 24                	je     f0103b28 <strtoul+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103b04:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0103b08:	75 07                	jne    f0103b11 <strtoul+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103b0a:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f0103b11:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b16:	eb 4e                	jmp    f0103b66 <strtoul+0x93>
		s++;
f0103b18:	41                   	inc    %ecx
	int neg = 0;
f0103b19:	bf 00 00 00 00       	mov    $0x0,%edi
f0103b1e:	eb d6                	jmp    f0103af6 <strtoul+0x23>
		s++, neg = 1;
f0103b20:	41                   	inc    %ecx
f0103b21:	bf 01 00 00 00       	mov    $0x1,%edi
f0103b26:	eb ce                	jmp    f0103af6 <strtoul+0x23>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103b28:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0103b2c:	74 10                	je     f0103b3e <strtoul+0x6b>
	else if (base == 0 && s[0] == '0')
f0103b2e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0103b32:	75 dd                	jne    f0103b11 <strtoul+0x3e>
		s++, base = 8;
f0103b34:	41                   	inc    %ecx
f0103b35:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f0103b3c:	eb d3                	jmp    f0103b11 <strtoul+0x3e>
		s += 2, base = 16;
f0103b3e:	83 c1 02             	add    $0x2,%ecx
f0103b41:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f0103b48:	eb c7                	jmp    f0103b11 <strtoul+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0103b4a:	8d 72 9f             	lea    -0x61(%edx),%esi
f0103b4d:	89 f3                	mov    %esi,%ebx
f0103b4f:	80 fb 19             	cmp    $0x19,%bl
f0103b52:	77 24                	ja     f0103b78 <strtoul+0xa5>
			dig = *s - 'a' + 10;
f0103b54:	0f be d2             	movsbl %dl,%edx
f0103b57:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0103b5a:	3b 55 10             	cmp    0x10(%ebp),%edx
f0103b5d:	7d 2b                	jge    f0103b8a <strtoul+0xb7>
			break;
		s++, val = (val * base) + dig;
f0103b5f:	41                   	inc    %ecx
f0103b60:	0f af 45 10          	imul   0x10(%ebp),%eax
f0103b64:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0103b66:	8a 11                	mov    (%ecx),%dl
f0103b68:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0103b6b:	80 fb 09             	cmp    $0x9,%bl
f0103b6e:	77 da                	ja     f0103b4a <strtoul+0x77>
			dig = *s - '0';
f0103b70:	0f be d2             	movsbl %dl,%edx
f0103b73:	83 ea 30             	sub    $0x30,%edx
f0103b76:	eb e2                	jmp    f0103b5a <strtoul+0x87>
		else if (*s >= 'A' && *s <= 'Z')
f0103b78:	8d 72 bf             	lea    -0x41(%edx),%esi
f0103b7b:	89 f3                	mov    %esi,%ebx
f0103b7d:	80 fb 19             	cmp    $0x19,%bl
f0103b80:	77 08                	ja     f0103b8a <strtoul+0xb7>
			dig = *s - 'A' + 10;
f0103b82:	0f be d2             	movsbl %dl,%edx
f0103b85:	83 ea 37             	sub    $0x37,%edx
f0103b88:	eb d0                	jmp    f0103b5a <strtoul+0x87>
		// we don't properly detect overflow!
	}

	if (endptr)
f0103b8a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103b8e:	74 05                	je     f0103b95 <strtoul+0xc2>
		*endptr = (char *) s;
f0103b90:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103b93:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0103b95:	85 ff                	test   %edi,%edi
f0103b97:	74 02                	je     f0103b9b <strtoul+0xc8>
f0103b99:	f7 d8                	neg    %eax
}
f0103b9b:	5b                   	pop    %ebx
f0103b9c:	5e                   	pop    %esi
f0103b9d:	5f                   	pop    %edi
f0103b9e:	5d                   	pop    %ebp
f0103b9f:	c3                   	ret    

f0103ba0 <__udivdi3>:
f0103ba0:	55                   	push   %ebp
f0103ba1:	57                   	push   %edi
f0103ba2:	56                   	push   %esi
f0103ba3:	53                   	push   %ebx
f0103ba4:	83 ec 1c             	sub    $0x1c,%esp
f0103ba7:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0103bab:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103baf:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103bb3:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0103bb7:	85 d2                	test   %edx,%edx
f0103bb9:	75 2d                	jne    f0103be8 <__udivdi3+0x48>
f0103bbb:	39 f7                	cmp    %esi,%edi
f0103bbd:	77 59                	ja     f0103c18 <__udivdi3+0x78>
f0103bbf:	89 f9                	mov    %edi,%ecx
f0103bc1:	85 ff                	test   %edi,%edi
f0103bc3:	75 0b                	jne    f0103bd0 <__udivdi3+0x30>
f0103bc5:	b8 01 00 00 00       	mov    $0x1,%eax
f0103bca:	31 d2                	xor    %edx,%edx
f0103bcc:	f7 f7                	div    %edi
f0103bce:	89 c1                	mov    %eax,%ecx
f0103bd0:	31 d2                	xor    %edx,%edx
f0103bd2:	89 f0                	mov    %esi,%eax
f0103bd4:	f7 f1                	div    %ecx
f0103bd6:	89 c3                	mov    %eax,%ebx
f0103bd8:	89 e8                	mov    %ebp,%eax
f0103bda:	f7 f1                	div    %ecx
f0103bdc:	89 da                	mov    %ebx,%edx
f0103bde:	83 c4 1c             	add    $0x1c,%esp
f0103be1:	5b                   	pop    %ebx
f0103be2:	5e                   	pop    %esi
f0103be3:	5f                   	pop    %edi
f0103be4:	5d                   	pop    %ebp
f0103be5:	c3                   	ret    
f0103be6:	66 90                	xchg   %ax,%ax
f0103be8:	39 f2                	cmp    %esi,%edx
f0103bea:	77 1c                	ja     f0103c08 <__udivdi3+0x68>
f0103bec:	0f bd da             	bsr    %edx,%ebx
f0103bef:	83 f3 1f             	xor    $0x1f,%ebx
f0103bf2:	75 38                	jne    f0103c2c <__udivdi3+0x8c>
f0103bf4:	39 f2                	cmp    %esi,%edx
f0103bf6:	72 08                	jb     f0103c00 <__udivdi3+0x60>
f0103bf8:	39 ef                	cmp    %ebp,%edi
f0103bfa:	0f 87 98 00 00 00    	ja     f0103c98 <__udivdi3+0xf8>
f0103c00:	b8 01 00 00 00       	mov    $0x1,%eax
f0103c05:	eb 05                	jmp    f0103c0c <__udivdi3+0x6c>
f0103c07:	90                   	nop
f0103c08:	31 db                	xor    %ebx,%ebx
f0103c0a:	31 c0                	xor    %eax,%eax
f0103c0c:	89 da                	mov    %ebx,%edx
f0103c0e:	83 c4 1c             	add    $0x1c,%esp
f0103c11:	5b                   	pop    %ebx
f0103c12:	5e                   	pop    %esi
f0103c13:	5f                   	pop    %edi
f0103c14:	5d                   	pop    %ebp
f0103c15:	c3                   	ret    
f0103c16:	66 90                	xchg   %ax,%ax
f0103c18:	89 e8                	mov    %ebp,%eax
f0103c1a:	89 f2                	mov    %esi,%edx
f0103c1c:	f7 f7                	div    %edi
f0103c1e:	31 db                	xor    %ebx,%ebx
f0103c20:	89 da                	mov    %ebx,%edx
f0103c22:	83 c4 1c             	add    $0x1c,%esp
f0103c25:	5b                   	pop    %ebx
f0103c26:	5e                   	pop    %esi
f0103c27:	5f                   	pop    %edi
f0103c28:	5d                   	pop    %ebp
f0103c29:	c3                   	ret    
f0103c2a:	66 90                	xchg   %ax,%ax
f0103c2c:	b8 20 00 00 00       	mov    $0x20,%eax
f0103c31:	29 d8                	sub    %ebx,%eax
f0103c33:	88 d9                	mov    %bl,%cl
f0103c35:	d3 e2                	shl    %cl,%edx
f0103c37:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103c3b:	89 fa                	mov    %edi,%edx
f0103c3d:	88 c1                	mov    %al,%cl
f0103c3f:	d3 ea                	shr    %cl,%edx
f0103c41:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0103c45:	09 d1                	or     %edx,%ecx
f0103c47:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103c4b:	88 d9                	mov    %bl,%cl
f0103c4d:	d3 e7                	shl    %cl,%edi
f0103c4f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0103c53:	89 f7                	mov    %esi,%edi
f0103c55:	88 c1                	mov    %al,%cl
f0103c57:	d3 ef                	shr    %cl,%edi
f0103c59:	88 d9                	mov    %bl,%cl
f0103c5b:	d3 e6                	shl    %cl,%esi
f0103c5d:	89 ea                	mov    %ebp,%edx
f0103c5f:	88 c1                	mov    %al,%cl
f0103c61:	d3 ea                	shr    %cl,%edx
f0103c63:	09 d6                	or     %edx,%esi
f0103c65:	89 f0                	mov    %esi,%eax
f0103c67:	89 fa                	mov    %edi,%edx
f0103c69:	f7 74 24 08          	divl   0x8(%esp)
f0103c6d:	89 d7                	mov    %edx,%edi
f0103c6f:	89 c6                	mov    %eax,%esi
f0103c71:	f7 64 24 0c          	mull   0xc(%esp)
f0103c75:	39 d7                	cmp    %edx,%edi
f0103c77:	72 13                	jb     f0103c8c <__udivdi3+0xec>
f0103c79:	74 09                	je     f0103c84 <__udivdi3+0xe4>
f0103c7b:	89 f0                	mov    %esi,%eax
f0103c7d:	31 db                	xor    %ebx,%ebx
f0103c7f:	eb 8b                	jmp    f0103c0c <__udivdi3+0x6c>
f0103c81:	8d 76 00             	lea    0x0(%esi),%esi
f0103c84:	88 d9                	mov    %bl,%cl
f0103c86:	d3 e5                	shl    %cl,%ebp
f0103c88:	39 c5                	cmp    %eax,%ebp
f0103c8a:	73 ef                	jae    f0103c7b <__udivdi3+0xdb>
f0103c8c:	8d 46 ff             	lea    -0x1(%esi),%eax
f0103c8f:	31 db                	xor    %ebx,%ebx
f0103c91:	e9 76 ff ff ff       	jmp    f0103c0c <__udivdi3+0x6c>
f0103c96:	66 90                	xchg   %ax,%ax
f0103c98:	31 c0                	xor    %eax,%eax
f0103c9a:	e9 6d ff ff ff       	jmp    f0103c0c <__udivdi3+0x6c>
f0103c9f:	90                   	nop

f0103ca0 <__umoddi3>:
f0103ca0:	55                   	push   %ebp
f0103ca1:	57                   	push   %edi
f0103ca2:	56                   	push   %esi
f0103ca3:	53                   	push   %ebx
f0103ca4:	83 ec 1c             	sub    $0x1c,%esp
f0103ca7:	8b 74 24 30          	mov    0x30(%esp),%esi
f0103cab:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0103caf:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103cb3:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0103cb7:	89 f0                	mov    %esi,%eax
f0103cb9:	89 da                	mov    %ebx,%edx
f0103cbb:	85 ed                	test   %ebp,%ebp
f0103cbd:	75 15                	jne    f0103cd4 <__umoddi3+0x34>
f0103cbf:	39 df                	cmp    %ebx,%edi
f0103cc1:	76 39                	jbe    f0103cfc <__umoddi3+0x5c>
f0103cc3:	f7 f7                	div    %edi
f0103cc5:	89 d0                	mov    %edx,%eax
f0103cc7:	31 d2                	xor    %edx,%edx
f0103cc9:	83 c4 1c             	add    $0x1c,%esp
f0103ccc:	5b                   	pop    %ebx
f0103ccd:	5e                   	pop    %esi
f0103cce:	5f                   	pop    %edi
f0103ccf:	5d                   	pop    %ebp
f0103cd0:	c3                   	ret    
f0103cd1:	8d 76 00             	lea    0x0(%esi),%esi
f0103cd4:	39 dd                	cmp    %ebx,%ebp
f0103cd6:	77 f1                	ja     f0103cc9 <__umoddi3+0x29>
f0103cd8:	0f bd cd             	bsr    %ebp,%ecx
f0103cdb:	83 f1 1f             	xor    $0x1f,%ecx
f0103cde:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103ce2:	75 38                	jne    f0103d1c <__umoddi3+0x7c>
f0103ce4:	39 dd                	cmp    %ebx,%ebp
f0103ce6:	72 04                	jb     f0103cec <__umoddi3+0x4c>
f0103ce8:	39 f7                	cmp    %esi,%edi
f0103cea:	77 dd                	ja     f0103cc9 <__umoddi3+0x29>
f0103cec:	89 da                	mov    %ebx,%edx
f0103cee:	89 f0                	mov    %esi,%eax
f0103cf0:	29 f8                	sub    %edi,%eax
f0103cf2:	19 ea                	sbb    %ebp,%edx
f0103cf4:	83 c4 1c             	add    $0x1c,%esp
f0103cf7:	5b                   	pop    %ebx
f0103cf8:	5e                   	pop    %esi
f0103cf9:	5f                   	pop    %edi
f0103cfa:	5d                   	pop    %ebp
f0103cfb:	c3                   	ret    
f0103cfc:	89 f9                	mov    %edi,%ecx
f0103cfe:	85 ff                	test   %edi,%edi
f0103d00:	75 0b                	jne    f0103d0d <__umoddi3+0x6d>
f0103d02:	b8 01 00 00 00       	mov    $0x1,%eax
f0103d07:	31 d2                	xor    %edx,%edx
f0103d09:	f7 f7                	div    %edi
f0103d0b:	89 c1                	mov    %eax,%ecx
f0103d0d:	89 d8                	mov    %ebx,%eax
f0103d0f:	31 d2                	xor    %edx,%edx
f0103d11:	f7 f1                	div    %ecx
f0103d13:	89 f0                	mov    %esi,%eax
f0103d15:	f7 f1                	div    %ecx
f0103d17:	eb ac                	jmp    f0103cc5 <__umoddi3+0x25>
f0103d19:	8d 76 00             	lea    0x0(%esi),%esi
f0103d1c:	b8 20 00 00 00       	mov    $0x20,%eax
f0103d21:	89 c2                	mov    %eax,%edx
f0103d23:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103d27:	29 c2                	sub    %eax,%edx
f0103d29:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103d2d:	88 c1                	mov    %al,%cl
f0103d2f:	d3 e5                	shl    %cl,%ebp
f0103d31:	89 f8                	mov    %edi,%eax
f0103d33:	88 d1                	mov    %dl,%cl
f0103d35:	d3 e8                	shr    %cl,%eax
f0103d37:	09 c5                	or     %eax,%ebp
f0103d39:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103d3d:	88 c1                	mov    %al,%cl
f0103d3f:	d3 e7                	shl    %cl,%edi
f0103d41:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0103d45:	89 df                	mov    %ebx,%edi
f0103d47:	88 d1                	mov    %dl,%cl
f0103d49:	d3 ef                	shr    %cl,%edi
f0103d4b:	88 c1                	mov    %al,%cl
f0103d4d:	d3 e3                	shl    %cl,%ebx
f0103d4f:	89 f0                	mov    %esi,%eax
f0103d51:	88 d1                	mov    %dl,%cl
f0103d53:	d3 e8                	shr    %cl,%eax
f0103d55:	09 d8                	or     %ebx,%eax
f0103d57:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0103d5b:	d3 e6                	shl    %cl,%esi
f0103d5d:	89 fa                	mov    %edi,%edx
f0103d5f:	f7 f5                	div    %ebp
f0103d61:	89 d1                	mov    %edx,%ecx
f0103d63:	f7 64 24 08          	mull   0x8(%esp)
f0103d67:	89 c3                	mov    %eax,%ebx
f0103d69:	89 d7                	mov    %edx,%edi
f0103d6b:	39 d1                	cmp    %edx,%ecx
f0103d6d:	72 29                	jb     f0103d98 <__umoddi3+0xf8>
f0103d6f:	74 23                	je     f0103d94 <__umoddi3+0xf4>
f0103d71:	89 ca                	mov    %ecx,%edx
f0103d73:	29 de                	sub    %ebx,%esi
f0103d75:	19 fa                	sbb    %edi,%edx
f0103d77:	89 d0                	mov    %edx,%eax
f0103d79:	8a 4c 24 0c          	mov    0xc(%esp),%cl
f0103d7d:	d3 e0                	shl    %cl,%eax
f0103d7f:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0103d83:	88 d9                	mov    %bl,%cl
f0103d85:	d3 ee                	shr    %cl,%esi
f0103d87:	09 f0                	or     %esi,%eax
f0103d89:	d3 ea                	shr    %cl,%edx
f0103d8b:	83 c4 1c             	add    $0x1c,%esp
f0103d8e:	5b                   	pop    %ebx
f0103d8f:	5e                   	pop    %esi
f0103d90:	5f                   	pop    %edi
f0103d91:	5d                   	pop    %ebp
f0103d92:	c3                   	ret    
f0103d93:	90                   	nop
f0103d94:	39 c6                	cmp    %eax,%esi
f0103d96:	73 d9                	jae    f0103d71 <__umoddi3+0xd1>
f0103d98:	2b 44 24 08          	sub    0x8(%esp),%eax
f0103d9c:	19 ea                	sbb    %ebp,%edx
f0103d9e:	89 d7                	mov    %edx,%edi
f0103da0:	89 c3                	mov    %eax,%ebx
f0103da2:	eb cd                	jmp    f0103d71 <__umoddi3+0xd1>
