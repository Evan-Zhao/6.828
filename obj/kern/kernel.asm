
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
f010004b:	68 00 3c 10 f0       	push   $0xf0103c00
f0100050:	e8 ac 2b 00 00       	call   f0102c01 <cprintf>
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
f0100065:	e8 9e 09 00 00       	call   f0100a08 <mon_backtrace>
f010006a:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010006d:	83 ec 08             	sub    $0x8,%esp
f0100070:	53                   	push   %ebx
f0100071:	68 1c 3c 10 f0       	push   $0xf0103c1c
f0100076:	e8 86 2b 00 00       	call   f0102c01 <cprintf>
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
f01000ac:	e8 7f 36 00 00       	call   f0103730 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 d8 04 00 00       	call   f010058e <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 37 3c 10 f0       	push   $0xf0103c37
f01000c3:	e8 39 2b 00 00       	call   f0102c01 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000c8:	e8 c2 12 00 00       	call   f010138f <mem_init>
	cprintf(ANSI_COLOR_RED     "This text is RED!"     ANSI_COLOR_RESET "\n");
f01000cd:	c7 04 24 52 3c 10 f0 	movl   $0xf0103c52,(%esp)
f01000d4:	e8 28 2b 00 00       	call   f0102c01 <cprintf>
	cprintf(ANSI_COLOR_GREEN   "This text is GREEN!"   ANSI_COLOR_RESET "\n");
f01000d9:	c7 04 24 6e 3c 10 f0 	movl   $0xf0103c6e,(%esp)
f01000e0:	e8 1c 2b 00 00       	call   f0102c01 <cprintf>
	cprintf(ANSI_COLOR_YELLOW  "This text is YELLOW!"  ANSI_COLOR_RESET "\n");
f01000e5:	c7 04 24 f8 3c 10 f0 	movl   $0xf0103cf8,(%esp)
f01000ec:	e8 10 2b 00 00       	call   f0102c01 <cprintf>
	cprintf(ANSI_COLOR_BLUE    "This text is BLUE!"    ANSI_COLOR_RESET "\n");
f01000f1:	c7 04 24 8c 3c 10 f0 	movl   $0xf0103c8c,(%esp)
f01000f8:	e8 04 2b 00 00       	call   f0102c01 <cprintf>
	cprintf(ANSI_COLOR_MAGENTA "This text is MAGENTA!" ANSI_COLOR_RESET "\n");
f01000fd:	c7 04 24 18 3d 10 f0 	movl   $0xf0103d18,(%esp)
f0100104:	e8 f8 2a 00 00       	call   f0102c01 <cprintf>
	cprintf(ANSI_COLOR_CYAN    "This text is CYAN!"    ANSI_COLOR_RESET "\n");
f0100109:	c7 04 24 a9 3c 10 f0 	movl   $0xf0103ca9,(%esp)
f0100110:	e8 ec 2a 00 00       	call   f0102c01 <cprintf>

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
f0100129:	e8 7e 09 00 00       	call   f0100aac <monitor>
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
f0100149:	e8 5e 09 00 00       	call   f0100aac <monitor>
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
f0100167:	68 c6 3c 10 f0       	push   $0xf0103cc6
f010016c:	e8 90 2a 00 00       	call   f0102c01 <cprintf>
	vcprintf(fmt, ap);
f0100171:	83 c4 08             	add    $0x8,%esp
f0100174:	53                   	push   %ebx
f0100175:	56                   	push   %esi
f0100176:	e8 60 2a 00 00       	call   f0102bdb <vcprintf>
	cprintf("\n");
f010017b:	c7 04 24 44 4e 10 f0 	movl   $0xf0104e44,(%esp)
f0100182:	e8 7a 2a 00 00       	call   f0102c01 <cprintf>
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
f010019c:	68 de 3c 10 f0       	push   $0xf0103cde
f01001a1:	e8 5b 2a 00 00       	call   f0102c01 <cprintf>
	vcprintf(fmt, ap);
f01001a6:	83 c4 08             	add    $0x8,%esp
f01001a9:	53                   	push   %ebx
f01001aa:	ff 75 10             	pushl  0x10(%ebp)
f01001ad:	e8 29 2a 00 00       	call   f0102bdb <vcprintf>
	cprintf("\n");
f01001b2:	c7 04 24 44 4e 10 f0 	movl   $0xf0104e44,(%esp)
f01001b9:	e8 43 2a 00 00       	call   f0102c01 <cprintf>
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
f0100279:	0f b6 82 a0 3e 10 f0 	movzbl -0xfefc160(%edx),%eax
f0100280:	0b 05 00 83 11 f0    	or     0xf0118300,%eax
	shift ^= togglecode[data];
f0100286:	0f b6 8a a0 3d 10 f0 	movzbl -0xfefc260(%edx),%ecx
f010028d:	31 c8                	xor    %ecx,%eax
f010028f:	a3 00 83 11 f0       	mov    %eax,0xf0118300
	c = charcode[shift & (CTL | SHIFT)][data];
f0100294:	89 c1                	mov    %eax,%ecx
f0100296:	83 e1 03             	and    $0x3,%ecx
f0100299:	8b 0c 8d 80 3d 10 f0 	mov    -0xfefc280(,%ecx,4),%ecx
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
f01002c8:	68 38 3d 10 f0       	push   $0xf0103d38
f01002cd:	e8 2f 29 00 00       	call   f0102c01 <cprintf>
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
f0100305:	8a 82 a0 3e 10 f0    	mov    -0xfefc160(%edx),%al
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
f01004e3:	e8 95 32 00 00       	call   f010377d <memmove>
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
f0100677:	68 44 3d 10 f0       	push   $0xf0103d44
f010067c:	e8 80 25 00 00       	call   f0102c01 <cprintf>
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
f01006b7:	68 a0 3f 10 f0       	push   $0xf0103fa0
f01006bc:	68 be 3f 10 f0       	push   $0xf0103fbe
f01006c1:	68 c3 3f 10 f0       	push   $0xf0103fc3
f01006c6:	e8 36 25 00 00       	call   f0102c01 <cprintf>
f01006cb:	83 c4 0c             	add    $0xc,%esp
f01006ce:	68 9c 40 10 f0       	push   $0xf010409c
f01006d3:	68 cc 3f 10 f0       	push   $0xf0103fcc
f01006d8:	68 c3 3f 10 f0       	push   $0xf0103fc3
f01006dd:	e8 1f 25 00 00       	call   f0102c01 <cprintf>
f01006e2:	83 c4 0c             	add    $0xc,%esp
f01006e5:	68 c4 40 10 f0       	push   $0xf01040c4
f01006ea:	68 d5 3f 10 f0       	push   $0xf0103fd5
f01006ef:	68 c3 3f 10 f0       	push   $0xf0103fc3
f01006f4:	e8 08 25 00 00       	call   f0102c01 <cprintf>
f01006f9:	83 c4 0c             	add    $0xc,%esp
f01006fc:	68 f8 40 10 f0       	push   $0xf01040f8
f0100701:	68 dd 3f 10 f0       	push   $0xf0103fdd
f0100706:	68 c3 3f 10 f0       	push   $0xf0103fc3
f010070b:	e8 f1 24 00 00       	call   f0102c01 <cprintf>
	return 0;
}
f0100710:	b8 00 00 00 00       	mov    $0x0,%eax
f0100715:	c9                   	leave  
f0100716:	c3                   	ret    

f0100717 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100717:	55                   	push   %ebp
f0100718:	89 e5                	mov    %esp,%ebp
f010071a:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010071d:	68 e3 3f 10 f0       	push   $0xf0103fe3
f0100722:	e8 da 24 00 00       	call   f0102c01 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100727:	83 c4 08             	add    $0x8,%esp
f010072a:	68 0c 00 10 00       	push   $0x10000c
f010072f:	68 24 41 10 f0       	push   $0xf0104124
f0100734:	e8 c8 24 00 00       	call   f0102c01 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100739:	83 c4 0c             	add    $0xc,%esp
f010073c:	68 0c 00 10 00       	push   $0x10000c
f0100741:	68 0c 00 10 f0       	push   $0xf010000c
f0100746:	68 4c 41 10 f0       	push   $0xf010414c
f010074b:	e8 b1 24 00 00       	call   f0102c01 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100750:	83 c4 0c             	add    $0xc,%esp
f0100753:	68 e4 3b 10 00       	push   $0x103be4
f0100758:	68 e4 3b 10 f0       	push   $0xf0103be4
f010075d:	68 70 41 10 f0       	push   $0xf0104170
f0100762:	e8 9a 24 00 00       	call   f0102c01 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100767:	83 c4 0c             	add    $0xc,%esp
f010076a:	68 00 83 11 00       	push   $0x118300
f010076f:	68 00 83 11 f0       	push   $0xf0118300
f0100774:	68 94 41 10 f0       	push   $0xf0104194
f0100779:	e8 83 24 00 00       	call   f0102c01 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010077e:	83 c4 0c             	add    $0xc,%esp
f0100781:	68 70 89 11 00       	push   $0x118970
f0100786:	68 70 89 11 f0       	push   $0xf0118970
f010078b:	68 b8 41 10 f0       	push   $0xf01041b8
f0100790:	e8 6c 24 00 00       	call   f0102c01 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100795:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100798:	b8 6f 8d 11 f0       	mov    $0xf0118d6f,%eax
f010079d:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f01007a2:	c1 f8 0a             	sar    $0xa,%eax
f01007a5:	50                   	push   %eax
f01007a6:	68 dc 41 10 f0       	push   $0xf01041dc
f01007ab:	e8 51 24 00 00       	call   f0102c01 <cprintf>
	return 0;
}
f01007b0:	b8 00 00 00 00       	mov    $0x0,%eax
f01007b5:	c9                   	leave  
f01007b6:	c3                   	ret    

f01007b7 <mon_showmap>:
	}
	return 0;
}

int 
mon_showmap(int argc, char **argv, struct Trapframe *tf) {
f01007b7:	55                   	push   %ebp
f01007b8:	89 e5                	mov    %esp,%ebp
f01007ba:	56                   	push   %esi
f01007bb:	53                   	push   %ebx
f01007bc:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc <= 2) {
f01007bf:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f01007c3:	7e 3c                	jle    f0100801 <mon_showmap+0x4a>
		cprintf("Expecting a virtual addr range [l, r]\n");
		return 0;
	}
	uintptr_t l = strtoul(argv[1], NULL, 0), 
f01007c5:	83 ec 04             	sub    $0x4,%esp
f01007c8:	6a 00                	push   $0x0
f01007ca:	6a 00                	push   $0x0
f01007cc:	ff 76 04             	pushl  0x4(%esi)
f01007cf:	e8 3d 31 00 00       	call   f0103911 <strtoul>
f01007d4:	89 c3                	mov    %eax,%ebx
		 	  r = strtoul(argv[2], NULL, 0); // In string.h
f01007d6:	83 c4 0c             	add    $0xc,%esp
f01007d9:	6a 00                	push   $0x0
f01007db:	6a 00                	push   $0x0
f01007dd:	ff 76 08             	pushl  0x8(%esi)
f01007e0:	e8 2c 31 00 00       	call   f0103911 <strtoul>
	if (l > r) {
f01007e5:	83 c4 10             	add    $0x10,%esp
f01007e8:	39 c3                	cmp    %eax,%ebx
f01007ea:	77 31                	ja     f010081d <mon_showmap+0x66>
		cprintf("Invalid range; aborting.\n");
		return 0;
	}
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f01007ec:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f01007f2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f01007f8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01007fd:	89 c6                	mov    %eax,%esi
f01007ff:	eb 45                	jmp    f0100846 <mon_showmap+0x8f>
		cprintf("Expecting a virtual addr range [l, r]\n");
f0100801:	83 ec 0c             	sub    $0xc,%esp
f0100804:	68 08 42 10 f0       	push   $0xf0104208
f0100809:	e8 f3 23 00 00       	call   f0102c01 <cprintf>
		return 0;
f010080e:	83 c4 10             	add    $0x10,%esp
		else 
			cprintf("0x%08x -> 0x%08x; perm = 0x%03x\n", 
					sz, PTE_ADDR(*pte), *pte & 0xFFF);
	}
	return 0;
}
f0100811:	b8 00 00 00 00       	mov    $0x0,%eax
f0100816:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100819:	5b                   	pop    %ebx
f010081a:	5e                   	pop    %esi
f010081b:	5d                   	pop    %ebp
f010081c:	c3                   	ret    
		cprintf("Invalid range; aborting.\n");
f010081d:	83 ec 0c             	sub    $0xc,%esp
f0100820:	68 fc 3f 10 f0       	push   $0xf0103ffc
f0100825:	e8 d7 23 00 00       	call   f0102c01 <cprintf>
		return 0;
f010082a:	83 c4 10             	add    $0x10,%esp
f010082d:	eb e2                	jmp    f0100811 <mon_showmap+0x5a>
			cprintf("0x%08x -> ----------; perm = ---\n", sz);
f010082f:	83 ec 08             	sub    $0x8,%esp
f0100832:	53                   	push   %ebx
f0100833:	68 30 42 10 f0       	push   $0xf0104230
f0100838:	e8 c4 23 00 00       	call   f0102c01 <cprintf>
f010083d:	83 c4 10             	add    $0x10,%esp
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f0100840:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100846:	39 f3                	cmp    %esi,%ebx
f0100848:	77 c7                	ja     f0100811 <mon_showmap+0x5a>
		pte_t* pte = pgdir_walk(kern_pgdir, (void*) sz, 0);
f010084a:	83 ec 04             	sub    $0x4,%esp
f010084d:	6a 00                	push   $0x0
f010084f:	53                   	push   %ebx
f0100850:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0100856:	e8 b9 08 00 00       	call   f0101114 <pgdir_walk>
		if (pte == NULL || !*pte)
f010085b:	83 c4 10             	add    $0x10,%esp
f010085e:	85 c0                	test   %eax,%eax
f0100860:	74 cd                	je     f010082f <mon_showmap+0x78>
f0100862:	8b 00                	mov    (%eax),%eax
f0100864:	85 c0                	test   %eax,%eax
f0100866:	74 c7                	je     f010082f <mon_showmap+0x78>
			cprintf("0x%08x -> 0x%08x; perm = 0x%03x\n", 
f0100868:	89 c2                	mov    %eax,%edx
f010086a:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f0100870:	52                   	push   %edx
f0100871:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100876:	50                   	push   %eax
f0100877:	53                   	push   %ebx
f0100878:	68 54 42 10 f0       	push   $0xf0104254
f010087d:	e8 7f 23 00 00       	call   f0102c01 <cprintf>
f0100882:	83 c4 10             	add    $0x10,%esp
f0100885:	eb b9                	jmp    f0100840 <mon_showmap+0x89>

f0100887 <mon_chmod>:

int
mon_chmod(int argc, char **argv, struct Trapframe *tf) {
f0100887:	55                   	push   %ebp
f0100888:	89 e5                	mov    %esp,%ebp
f010088a:	57                   	push   %edi
f010088b:	56                   	push   %esi
f010088c:	53                   	push   %ebx
f010088d:	83 ec 1c             	sub    $0x1c,%esp
f0100890:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc <= 2) {
f0100893:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100897:	7e 67                	jle    f0100900 <mon_chmod+0x79>
		cprintf("Usage: chmod mod l [r] [-v]");
		return 0;
	}
	uintptr_t mod = strtoul(argv[1], NULL, 0),  
f0100899:	83 ec 04             	sub    $0x4,%esp
f010089c:	6a 00                	push   $0x0
f010089e:	6a 00                	push   $0x0
f01008a0:	ff 76 04             	pushl  0x4(%esi)
f01008a3:	e8 69 30 00 00       	call   f0103911 <strtoul>
f01008a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			  l = strtoul(argv[2], NULL, 0), 
f01008ab:	83 c4 0c             	add    $0xc,%esp
f01008ae:	6a 00                	push   $0x0
f01008b0:	6a 00                	push   $0x0
f01008b2:	ff 76 08             	pushl  0x8(%esi)
f01008b5:	e8 57 30 00 00       	call   f0103911 <strtoul>
f01008ba:	89 c3                	mov    %eax,%ebx
			  r = argc >= 4 ? strtoul(argv[3], NULL, 0) : l;
f01008bc:	83 c4 10             	add    $0x10,%esp
f01008bf:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f01008c3:	7f 58                	jg     f010091d <mon_chmod+0x96>
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
	if (mod > 0xFFF) {
f01008c5:	81 7d e4 ff 0f 00 00 	cmpl   $0xfff,-0x1c(%ebp)
f01008cc:	0f 87 9a 00 00 00    	ja     f010096c <mon_chmod+0xe5>
			  r = argc >= 4 ? strtoul(argv[3], NULL, 0) : l;
f01008d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
f01008d5:	bf 00 00 00 00       	mov    $0x0,%edi
	}
	if (l > r) {
		cprintf("Invalid range; aborting.\n");
		return 0;
	}
	if (!(mod & PTE_P)) {
f01008da:	f6 45 e4 01          	testb  $0x1,-0x1c(%ebp)
f01008de:	0f 84 9a 00 00 00    	je     f010097e <mon_chmod+0xf7>
		cprintf("Warning: PTE_P flag is not provided; added automatically.");
		mod |= PTE_P;
	}
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f01008e4:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f01008ea:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f01008f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01008f3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01008f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01008fb:	e9 a1 00 00 00       	jmp    f01009a1 <mon_chmod+0x11a>
		cprintf("Usage: chmod mod l [r] [-v]");
f0100900:	83 ec 0c             	sub    $0xc,%esp
f0100903:	68 16 40 10 f0       	push   $0xf0104016
f0100908:	e8 f4 22 00 00       	call   f0102c01 <cprintf>
		return 0;
f010090d:	83 c4 10             	add    $0x10,%esp
						sz, *pte & 0xFFF, mod);
			*pte = PTE_ADDR(*pte) | mod;
		}
	}
	return 0;
}
f0100910:	b8 00 00 00 00       	mov    $0x0,%eax
f0100915:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100918:	5b                   	pop    %ebx
f0100919:	5e                   	pop    %esi
f010091a:	5f                   	pop    %edi
f010091b:	5d                   	pop    %ebp
f010091c:	c3                   	ret    
			  r = argc >= 4 ? strtoul(argv[3], NULL, 0) : l;
f010091d:	83 ec 04             	sub    $0x4,%esp
f0100920:	6a 00                	push   $0x0
f0100922:	6a 00                	push   $0x0
f0100924:	ff 76 0c             	pushl  0xc(%esi)
f0100927:	e8 e5 2f 00 00       	call   f0103911 <strtoul>
f010092c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
f010092f:	83 c4 08             	add    $0x8,%esp
f0100932:	68 32 40 10 f0       	push   $0xf0104032
f0100937:	ff 76 0c             	pushl  0xc(%esi)
f010093a:	e8 68 2d 00 00       	call   f01036a7 <strcmp>
f010093f:	83 c4 10             	add    $0x10,%esp
f0100942:	85 c0                	test   %eax,%eax
f0100944:	0f 94 c0             	sete   %al
f0100947:	0f b6 c0             	movzbl %al,%eax
f010094a:	89 c7                	mov    %eax,%edi
	if (mod > 0xFFF) {
f010094c:	81 7d e4 ff 0f 00 00 	cmpl   $0xfff,-0x1c(%ebp)
f0100953:	77 17                	ja     f010096c <mon_chmod+0xe5>
	if (l > r) {
f0100955:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0100958:	76 80                	jbe    f01008da <mon_chmod+0x53>
		cprintf("Invalid range; aborting.\n");
f010095a:	83 ec 0c             	sub    $0xc,%esp
f010095d:	68 fc 3f 10 f0       	push   $0xf0103ffc
f0100962:	e8 9a 22 00 00       	call   f0102c01 <cprintf>
		return 0;
f0100967:	83 c4 10             	add    $0x10,%esp
f010096a:	eb a4                	jmp    f0100910 <mon_chmod+0x89>
		cprintf("Permission exceeds 0xfff; aborting.\n");
f010096c:	83 ec 0c             	sub    $0xc,%esp
f010096f:	68 78 42 10 f0       	push   $0xf0104278
f0100974:	e8 88 22 00 00       	call   f0102c01 <cprintf>
		return 0;
f0100979:	83 c4 10             	add    $0x10,%esp
f010097c:	eb 92                	jmp    f0100910 <mon_chmod+0x89>
		cprintf("Warning: PTE_P flag is not provided; added automatically.");
f010097e:	83 ec 0c             	sub    $0xc,%esp
f0100981:	68 a0 42 10 f0       	push   $0xf01042a0
f0100986:	e8 76 22 00 00       	call   f0102c01 <cprintf>
		mod |= PTE_P;
f010098b:	83 4d e4 01          	orl    $0x1,-0x1c(%ebp)
f010098f:	83 c4 10             	add    $0x10,%esp
f0100992:	e9 4d ff ff ff       	jmp    f01008e4 <mon_chmod+0x5d>
			if (verbose)
f0100997:	85 ff                	test   %edi,%edi
f0100999:	75 41                	jne    f01009dc <mon_chmod+0x155>
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f010099b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01009a1:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f01009a4:	0f 87 66 ff ff ff    	ja     f0100910 <mon_chmod+0x89>
		pte_t* pte = pgdir_walk(kern_pgdir, (void*) sz, 0);
f01009aa:	83 ec 04             	sub    $0x4,%esp
f01009ad:	6a 00                	push   $0x0
f01009af:	53                   	push   %ebx
f01009b0:	ff 35 68 89 11 f0    	pushl  0xf0118968
f01009b6:	e8 59 07 00 00       	call   f0101114 <pgdir_walk>
f01009bb:	89 c6                	mov    %eax,%esi
		if (pte == NULL || !*pte) {
f01009bd:	83 c4 10             	add    $0x10,%esp
f01009c0:	85 c0                	test   %eax,%eax
f01009c2:	74 d3                	je     f0100997 <mon_chmod+0x110>
f01009c4:	8b 00                	mov    (%eax),%eax
f01009c6:	85 c0                	test   %eax,%eax
f01009c8:	74 cd                	je     f0100997 <mon_chmod+0x110>
			if (verbose) 
f01009ca:	85 ff                	test   %edi,%edi
f01009cc:	75 21                	jne    f01009ef <mon_chmod+0x168>
			*pte = PTE_ADDR(*pte) | mod;
f01009ce:	8b 06                	mov    (%esi),%eax
f01009d0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009d5:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01009d8:	89 06                	mov    %eax,(%esi)
f01009da:	eb bf                	jmp    f010099b <mon_chmod+0x114>
				cprintf("Page va = 0x%08x is not mapped; skipping.\n", sz);
f01009dc:	83 ec 08             	sub    $0x8,%esp
f01009df:	53                   	push   %ebx
f01009e0:	68 dc 42 10 f0       	push   $0xf01042dc
f01009e5:	e8 17 22 00 00       	call   f0102c01 <cprintf>
f01009ea:	83 c4 10             	add    $0x10,%esp
f01009ed:	eb ac                	jmp    f010099b <mon_chmod+0x114>
				cprintf("Page va = 0x%08x perm = 0x%03x changed to 0x%03x\n", 
f01009ef:	ff 75 e4             	pushl  -0x1c(%ebp)
f01009f2:	25 ff 0f 00 00       	and    $0xfff,%eax
f01009f7:	50                   	push   %eax
f01009f8:	53                   	push   %ebx
f01009f9:	68 08 43 10 f0       	push   $0xf0104308
f01009fe:	e8 fe 21 00 00       	call   f0102c01 <cprintf>
f0100a03:	83 c4 10             	add    $0x10,%esp
f0100a06:	eb c6                	jmp    f01009ce <mon_chmod+0x147>

f0100a08 <mon_backtrace>:
{
f0100a08:	55                   	push   %ebp
f0100a09:	89 e5                	mov    %esp,%ebp
f0100a0b:	57                   	push   %edi
f0100a0c:	56                   	push   %esi
f0100a0d:	53                   	push   %ebx
f0100a0e:	83 ec 38             	sub    $0x38,%esp
	cprintf("Stack backtrace:\n");
f0100a11:	68 35 40 10 f0       	push   $0xf0104035
f0100a16:	e8 e6 21 00 00       	call   f0102c01 <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100a1b:	89 e8                	mov    %ebp,%eax
	while (ebp != 0) {
f0100a1d:	83 c4 10             	add    $0x10,%esp
f0100a20:	eb 34                	jmp    f0100a56 <mon_backtrace+0x4e>
			cprintf("%c", info.eip_fn_name[i]);
f0100a22:	83 ec 08             	sub    $0x8,%esp
f0100a25:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a28:	0f be 04 18          	movsbl (%eax,%ebx,1),%eax
f0100a2c:	50                   	push   %eax
f0100a2d:	68 58 40 10 f0       	push   $0xf0104058
f0100a32:	e8 ca 21 00 00       	call   f0102c01 <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f0100a37:	43                   	inc    %ebx
f0100a38:	83 c4 10             	add    $0x10,%esp
f0100a3b:	39 5d dc             	cmp    %ebx,-0x24(%ebp)
f0100a3e:	7f e2                	jg     f0100a22 <mon_backtrace+0x1a>
		cprintf("+%d\n", eip - info.eip_fn_addr);
f0100a40:	83 ec 08             	sub    $0x8,%esp
f0100a43:	2b 75 e0             	sub    -0x20(%ebp),%esi
f0100a46:	56                   	push   %esi
f0100a47:	68 5b 40 10 f0       	push   $0xf010405b
f0100a4c:	e8 b0 21 00 00       	call   f0102c01 <cprintf>
		ebp = prev_ebp;
f0100a51:	83 c4 10             	add    $0x10,%esp
f0100a54:	89 f8                	mov    %edi,%eax
	while (ebp != 0) {
f0100a56:	85 c0                	test   %eax,%eax
f0100a58:	74 4a                	je     f0100aa4 <mon_backtrace+0x9c>
		prev_ebp = *(int*)ebp;
f0100a5a:	8b 38                	mov    (%eax),%edi
		eip = *((int*)ebp + 1);
f0100a5c:	8b 70 04             	mov    0x4(%eax),%esi
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, 
f0100a5f:	ff 70 18             	pushl  0x18(%eax)
f0100a62:	ff 70 14             	pushl  0x14(%eax)
f0100a65:	ff 70 10             	pushl  0x10(%eax)
f0100a68:	ff 70 0c             	pushl  0xc(%eax)
f0100a6b:	ff 70 08             	pushl  0x8(%eax)
f0100a6e:	56                   	push   %esi
f0100a6f:	50                   	push   %eax
f0100a70:	68 3c 43 10 f0       	push   $0xf010433c
f0100a75:	e8 87 21 00 00       	call   f0102c01 <cprintf>
		int code = debuginfo_eip((uintptr_t)eip, &info);
f0100a7a:	83 c4 18             	add    $0x18,%esp
f0100a7d:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100a80:	50                   	push   %eax
f0100a81:	56                   	push   %esi
f0100a82:	e8 7b 22 00 00       	call   f0102d02 <debuginfo_eip>
		cprintf("         %s:%d: ", info.eip_file, info.eip_line);
f0100a87:	83 c4 0c             	add    $0xc,%esp
f0100a8a:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100a8d:	ff 75 d0             	pushl  -0x30(%ebp)
f0100a90:	68 47 40 10 f0       	push   $0xf0104047
f0100a95:	e8 67 21 00 00       	call   f0102c01 <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f0100a9a:	83 c4 10             	add    $0x10,%esp
f0100a9d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100aa2:	eb 97                	jmp    f0100a3b <mon_backtrace+0x33>
}
f0100aa4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100aa7:	5b                   	pop    %ebx
f0100aa8:	5e                   	pop    %esi
f0100aa9:	5f                   	pop    %edi
f0100aaa:	5d                   	pop    %ebp
f0100aab:	c3                   	ret    

f0100aac <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100aac:	55                   	push   %ebp
f0100aad:	89 e5                	mov    %esp,%ebp
f0100aaf:	57                   	push   %edi
f0100ab0:	56                   	push   %esi
f0100ab1:	53                   	push   %ebx
f0100ab2:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100ab5:	68 74 43 10 f0       	push   $0xf0104374
f0100aba:	e8 42 21 00 00       	call   f0102c01 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100abf:	c7 04 24 98 43 10 f0 	movl   $0xf0104398,(%esp)
f0100ac6:	e8 36 21 00 00       	call   f0102c01 <cprintf>
f0100acb:	83 c4 10             	add    $0x10,%esp
f0100ace:	eb 47                	jmp    f0100b17 <monitor+0x6b>
		while (*buf && strchr(WHITESPACE, *buf))
f0100ad0:	83 ec 08             	sub    $0x8,%esp
f0100ad3:	0f be c0             	movsbl %al,%eax
f0100ad6:	50                   	push   %eax
f0100ad7:	68 64 40 10 f0       	push   $0xf0104064
f0100adc:	e8 1a 2c 00 00       	call   f01036fb <strchr>
f0100ae1:	83 c4 10             	add    $0x10,%esp
f0100ae4:	85 c0                	test   %eax,%eax
f0100ae6:	74 0a                	je     f0100af2 <monitor+0x46>
			*buf++ = 0;
f0100ae8:	c6 03 00             	movb   $0x0,(%ebx)
f0100aeb:	89 fe                	mov    %edi,%esi
f0100aed:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100af0:	eb 68                	jmp    f0100b5a <monitor+0xae>
		if (*buf == 0)
f0100af2:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100af5:	74 6f                	je     f0100b66 <monitor+0xba>
		if (argc == MAXARGS-1) {
f0100af7:	83 ff 0f             	cmp    $0xf,%edi
f0100afa:	74 09                	je     f0100b05 <monitor+0x59>
		argv[argc++] = buf;
f0100afc:	8d 77 01             	lea    0x1(%edi),%esi
f0100aff:	89 5c bd a8          	mov    %ebx,-0x58(%ebp,%edi,4)
f0100b03:	eb 37                	jmp    f0100b3c <monitor+0x90>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100b05:	83 ec 08             	sub    $0x8,%esp
f0100b08:	6a 10                	push   $0x10
f0100b0a:	68 69 40 10 f0       	push   $0xf0104069
f0100b0f:	e8 ed 20 00 00       	call   f0102c01 <cprintf>
f0100b14:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100b17:	83 ec 0c             	sub    $0xc,%esp
f0100b1a:	68 60 40 10 f0       	push   $0xf0104060
f0100b1f:	e8 cc 29 00 00       	call   f01034f0 <readline>
f0100b24:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100b26:	83 c4 10             	add    $0x10,%esp
f0100b29:	85 c0                	test   %eax,%eax
f0100b2b:	74 ea                	je     f0100b17 <monitor+0x6b>
	argv[argc] = 0;
f0100b2d:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100b34:	bf 00 00 00 00       	mov    $0x0,%edi
f0100b39:	eb 21                	jmp    f0100b5c <monitor+0xb0>
			buf++;
f0100b3b:	43                   	inc    %ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100b3c:	8a 03                	mov    (%ebx),%al
f0100b3e:	84 c0                	test   %al,%al
f0100b40:	74 18                	je     f0100b5a <monitor+0xae>
f0100b42:	83 ec 08             	sub    $0x8,%esp
f0100b45:	0f be c0             	movsbl %al,%eax
f0100b48:	50                   	push   %eax
f0100b49:	68 64 40 10 f0       	push   $0xf0104064
f0100b4e:	e8 a8 2b 00 00       	call   f01036fb <strchr>
f0100b53:	83 c4 10             	add    $0x10,%esp
f0100b56:	85 c0                	test   %eax,%eax
f0100b58:	74 e1                	je     f0100b3b <monitor+0x8f>
			*buf++ = 0;
f0100b5a:	89 f7                	mov    %esi,%edi
		while (*buf && strchr(WHITESPACE, *buf))
f0100b5c:	8a 03                	mov    (%ebx),%al
f0100b5e:	84 c0                	test   %al,%al
f0100b60:	0f 85 6a ff ff ff    	jne    f0100ad0 <monitor+0x24>
	argv[argc] = 0;
f0100b66:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
f0100b6d:	00 
	if (argc == 0)
f0100b6e:	85 ff                	test   %edi,%edi
f0100b70:	74 a5                	je     f0100b17 <monitor+0x6b>
f0100b72:	be c0 43 10 f0       	mov    $0xf01043c0,%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100b77:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f0100b7c:	83 ec 08             	sub    $0x8,%esp
f0100b7f:	ff 36                	pushl  (%esi)
f0100b81:	ff 75 a8             	pushl  -0x58(%ebp)
f0100b84:	e8 1e 2b 00 00       	call   f01036a7 <strcmp>
f0100b89:	83 c4 10             	add    $0x10,%esp
f0100b8c:	85 c0                	test   %eax,%eax
f0100b8e:	74 21                	je     f0100bb1 <monitor+0x105>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100b90:	43                   	inc    %ebx
f0100b91:	83 c6 0c             	add    $0xc,%esi
f0100b94:	83 fb 04             	cmp    $0x4,%ebx
f0100b97:	75 e3                	jne    f0100b7c <monitor+0xd0>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100b99:	83 ec 08             	sub    $0x8,%esp
f0100b9c:	ff 75 a8             	pushl  -0x58(%ebp)
f0100b9f:	68 86 40 10 f0       	push   $0xf0104086
f0100ba4:	e8 58 20 00 00       	call   f0102c01 <cprintf>
f0100ba9:	83 c4 10             	add    $0x10,%esp
f0100bac:	e9 66 ff ff ff       	jmp    f0100b17 <monitor+0x6b>
			return commands[i].func(argc, argv, tf);
f0100bb1:	83 ec 04             	sub    $0x4,%esp
f0100bb4:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100bb7:	01 c3                	add    %eax,%ebx
f0100bb9:	ff 75 08             	pushl  0x8(%ebp)
f0100bbc:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100bbf:	50                   	push   %eax
f0100bc0:	57                   	push   %edi
f0100bc1:	ff 14 9d c8 43 10 f0 	call   *-0xfefbc38(,%ebx,4)
			if (runcmd(buf, tf) < 0)
f0100bc8:	83 c4 10             	add    $0x10,%esp
f0100bcb:	85 c0                	test   %eax,%eax
f0100bcd:	0f 89 44 ff ff ff    	jns    f0100b17 <monitor+0x6b>
				break;
	}
}
f0100bd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100bd6:	5b                   	pop    %ebx
f0100bd7:	5e                   	pop    %esi
f0100bd8:	5f                   	pop    %edi
f0100bd9:	5d                   	pop    %ebp
f0100bda:	c3                   	ret    

f0100bdb <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100bdb:	55                   	push   %ebp
f0100bdc:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100bde:	83 3d 38 85 11 f0 00 	cmpl   $0x0,0xf0118538
f0100be5:	74 1f                	je     f0100c06 <boot_alloc+0x2b>
	}

	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	if (!n)
f0100be7:	85 c0                	test   %eax,%eax
f0100be9:	74 2e                	je     f0100c19 <boot_alloc+0x3e>
		return (void*)nextfree;
	else {
		result = nextfree;
f0100beb:	8b 15 38 85 11 f0    	mov    0xf0118538,%edx
		nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100bf1:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100bf8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bfd:	a3 38 85 11 f0       	mov    %eax,0xf0118538
		return (void*)result;
	}
}
f0100c02:	89 d0                	mov    %edx,%eax
f0100c04:	5d                   	pop    %ebp
f0100c05:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100c06:	ba 6f 99 11 f0       	mov    $0xf011996f,%edx
f0100c0b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100c11:	89 15 38 85 11 f0    	mov    %edx,0xf0118538
f0100c17:	eb ce                	jmp    f0100be7 <boot_alloc+0xc>
		return (void*)nextfree;
f0100c19:	8b 15 38 85 11 f0    	mov    0xf0118538,%edx
f0100c1f:	eb e1                	jmp    f0100c02 <boot_alloc+0x27>

f0100c21 <nvram_read>:
{
f0100c21:	55                   	push   %ebp
f0100c22:	89 e5                	mov    %esp,%ebp
f0100c24:	56                   	push   %esi
f0100c25:	53                   	push   %ebx
f0100c26:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100c28:	83 ec 0c             	sub    $0xc,%esp
f0100c2b:	50                   	push   %eax
f0100c2c:	e8 69 1f 00 00       	call   f0102b9a <mc146818_read>
f0100c31:	89 c3                	mov    %eax,%ebx
f0100c33:	46                   	inc    %esi
f0100c34:	89 34 24             	mov    %esi,(%esp)
f0100c37:	e8 5e 1f 00 00       	call   f0102b9a <mc146818_read>
f0100c3c:	c1 e0 08             	shl    $0x8,%eax
f0100c3f:	09 d8                	or     %ebx,%eax
}
f0100c41:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100c44:	5b                   	pop    %ebx
f0100c45:	5e                   	pop    %esi
f0100c46:	5d                   	pop    %ebp
f0100c47:	c3                   	ret    

f0100c48 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100c48:	89 d1                	mov    %edx,%ecx
f0100c4a:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100c4d:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100c50:	a8 01                	test   $0x1,%al
f0100c52:	74 47                	je     f0100c9b <check_va2pa+0x53>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100c54:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c59:	89 c1                	mov    %eax,%ecx
f0100c5b:	c1 e9 0c             	shr    $0xc,%ecx
f0100c5e:	3b 0d 64 89 11 f0    	cmp    0xf0118964,%ecx
f0100c64:	73 1a                	jae    f0100c80 <check_va2pa+0x38>
	if (!(p[PTX(va)] & PTE_P))
f0100c66:	c1 ea 0c             	shr    $0xc,%edx
f0100c69:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100c6f:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100c76:	a8 01                	test   $0x1,%al
f0100c78:	74 27                	je     f0100ca1 <check_va2pa+0x59>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100c7a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c7f:	c3                   	ret    
{
f0100c80:	55                   	push   %ebp
f0100c81:	89 e5                	mov    %esp,%ebp
f0100c83:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c86:	50                   	push   %eax
f0100c87:	68 f0 43 10 f0       	push   $0xf01043f0
f0100c8c:	68 c2 02 00 00       	push   $0x2c2
f0100c91:	68 68 4b 10 f0       	push   $0xf0104b68
f0100c96:	e8 98 f4 ff ff       	call   f0100133 <_panic>
		return ~0;
f0100c9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ca0:	c3                   	ret    
		return ~0;
f0100ca1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100ca6:	c3                   	ret    

f0100ca7 <check_page_free_list>:
{
f0100ca7:	55                   	push   %ebp
f0100ca8:	89 e5                	mov    %esp,%ebp
f0100caa:	57                   	push   %edi
f0100cab:	56                   	push   %esi
f0100cac:	53                   	push   %ebx
f0100cad:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100cb0:	84 c0                	test   %al,%al
f0100cb2:	0f 85 50 02 00 00    	jne    f0100f08 <check_page_free_list+0x261>
	if (!page_free_list)
f0100cb8:	83 3d 3c 85 11 f0 00 	cmpl   $0x0,0xf011853c
f0100cbf:	74 0a                	je     f0100ccb <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100cc1:	be 00 04 00 00       	mov    $0x400,%esi
f0100cc6:	e9 98 02 00 00       	jmp    f0100f63 <check_page_free_list+0x2bc>
		panic("'page_free_list' is a null pointer!");
f0100ccb:	83 ec 04             	sub    $0x4,%esp
f0100cce:	68 14 44 10 f0       	push   $0xf0104414
f0100cd3:	68 02 02 00 00       	push   $0x202
f0100cd8:	68 68 4b 10 f0       	push   $0xf0104b68
f0100cdd:	e8 51 f4 ff ff       	call   f0100133 <_panic>
f0100ce2:	50                   	push   %eax
f0100ce3:	68 f0 43 10 f0       	push   $0xf01043f0
f0100ce8:	6a 52                	push   $0x52
f0100cea:	68 74 4b 10 f0       	push   $0xf0104b74
f0100cef:	e8 3f f4 ff ff       	call   f0100133 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100cf4:	8b 1b                	mov    (%ebx),%ebx
f0100cf6:	85 db                	test   %ebx,%ebx
f0100cf8:	74 41                	je     f0100d3b <check_page_free_list+0x94>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100cfa:	89 d8                	mov    %ebx,%eax
f0100cfc:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0100d02:	c1 f8 03             	sar    $0x3,%eax
f0100d05:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100d08:	89 c2                	mov    %eax,%edx
f0100d0a:	c1 ea 16             	shr    $0x16,%edx
f0100d0d:	39 f2                	cmp    %esi,%edx
f0100d0f:	73 e3                	jae    f0100cf4 <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100d11:	89 c2                	mov    %eax,%edx
f0100d13:	c1 ea 0c             	shr    $0xc,%edx
f0100d16:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f0100d1c:	73 c4                	jae    f0100ce2 <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100d1e:	83 ec 04             	sub    $0x4,%esp
f0100d21:	68 80 00 00 00       	push   $0x80
f0100d26:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100d2b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d30:	50                   	push   %eax
f0100d31:	e8 fa 29 00 00       	call   f0103730 <memset>
f0100d36:	83 c4 10             	add    $0x10,%esp
f0100d39:	eb b9                	jmp    f0100cf4 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100d3b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d40:	e8 96 fe ff ff       	call   f0100bdb <boot_alloc>
f0100d45:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d48:	8b 15 3c 85 11 f0    	mov    0xf011853c,%edx
		assert(pp >= pages);
f0100d4e:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
		assert(pp < pages + npages);
f0100d54:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0100d59:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100d5c:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d5f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0100d62:	be 00 00 00 00       	mov    $0x0,%esi
f0100d67:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d6a:	e9 c8 00 00 00       	jmp    f0100e37 <check_page_free_list+0x190>
		assert(pp >= pages);
f0100d6f:	68 82 4b 10 f0       	push   $0xf0104b82
f0100d74:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0100d79:	68 1c 02 00 00       	push   $0x21c
f0100d7e:	68 68 4b 10 f0       	push   $0xf0104b68
f0100d83:	e8 ab f3 ff ff       	call   f0100133 <_panic>
		assert(pp < pages + npages);
f0100d88:	68 a3 4b 10 f0       	push   $0xf0104ba3
f0100d8d:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0100d92:	68 1d 02 00 00       	push   $0x21d
f0100d97:	68 68 4b 10 f0       	push   $0xf0104b68
f0100d9c:	e8 92 f3 ff ff       	call   f0100133 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100da1:	68 38 44 10 f0       	push   $0xf0104438
f0100da6:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0100dab:	68 1e 02 00 00       	push   $0x21e
f0100db0:	68 68 4b 10 f0       	push   $0xf0104b68
f0100db5:	e8 79 f3 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) != 0);
f0100dba:	68 b7 4b 10 f0       	push   $0xf0104bb7
f0100dbf:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0100dc4:	68 21 02 00 00       	push   $0x221
f0100dc9:	68 68 4b 10 f0       	push   $0xf0104b68
f0100dce:	e8 60 f3 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100dd3:	68 c8 4b 10 f0       	push   $0xf0104bc8
f0100dd8:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0100ddd:	68 22 02 00 00       	push   $0x222
f0100de2:	68 68 4b 10 f0       	push   $0xf0104b68
f0100de7:	e8 47 f3 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100dec:	68 6c 44 10 f0       	push   $0xf010446c
f0100df1:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0100df6:	68 23 02 00 00       	push   $0x223
f0100dfb:	68 68 4b 10 f0       	push   $0xf0104b68
f0100e00:	e8 2e f3 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e05:	68 e1 4b 10 f0       	push   $0xf0104be1
f0100e0a:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0100e0f:	68 24 02 00 00       	push   $0x224
f0100e14:	68 68 4b 10 f0       	push   $0xf0104b68
f0100e19:	e8 15 f3 ff ff       	call   f0100133 <_panic>
	if (PGNUM(pa) >= npages)
f0100e1e:	89 c3                	mov    %eax,%ebx
f0100e20:	c1 eb 0c             	shr    $0xc,%ebx
f0100e23:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f0100e26:	76 63                	jbe    f0100e8b <check_page_free_list+0x1e4>
	return (void *)(pa + KERNBASE);
f0100e28:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e2d:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100e30:	77 6b                	ja     f0100e9d <check_page_free_list+0x1f6>
			++nfree_extmem;
f0100e32:	ff 45 d0             	incl   -0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e35:	8b 12                	mov    (%edx),%edx
f0100e37:	85 d2                	test   %edx,%edx
f0100e39:	74 7b                	je     f0100eb6 <check_page_free_list+0x20f>
		assert(pp >= pages);
f0100e3b:	39 d1                	cmp    %edx,%ecx
f0100e3d:	0f 87 2c ff ff ff    	ja     f0100d6f <check_page_free_list+0xc8>
		assert(pp < pages + npages);
f0100e43:	39 d7                	cmp    %edx,%edi
f0100e45:	0f 86 3d ff ff ff    	jbe    f0100d88 <check_page_free_list+0xe1>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100e4b:	89 d0                	mov    %edx,%eax
f0100e4d:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100e50:	a8 07                	test   $0x7,%al
f0100e52:	0f 85 49 ff ff ff    	jne    f0100da1 <check_page_free_list+0xfa>
	return (pp - pages) << PGSHIFT;
f0100e58:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100e5b:	c1 e0 0c             	shl    $0xc,%eax
f0100e5e:	0f 84 56 ff ff ff    	je     f0100dba <check_page_free_list+0x113>
		assert(page2pa(pp) != IOPHYSMEM);
f0100e64:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100e69:	0f 84 64 ff ff ff    	je     f0100dd3 <check_page_free_list+0x12c>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100e6f:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100e74:	0f 84 72 ff ff ff    	je     f0100dec <check_page_free_list+0x145>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e7a:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100e7f:	74 84                	je     f0100e05 <check_page_free_list+0x15e>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e81:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e86:	77 96                	ja     f0100e1e <check_page_free_list+0x177>
			++nfree_basemem;
f0100e88:	46                   	inc    %esi
f0100e89:	eb aa                	jmp    f0100e35 <check_page_free_list+0x18e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e8b:	50                   	push   %eax
f0100e8c:	68 f0 43 10 f0       	push   $0xf01043f0
f0100e91:	6a 52                	push   $0x52
f0100e93:	68 74 4b 10 f0       	push   $0xf0104b74
f0100e98:	e8 96 f2 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e9d:	68 90 44 10 f0       	push   $0xf0104490
f0100ea2:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0100ea7:	68 25 02 00 00       	push   $0x225
f0100eac:	68 68 4b 10 f0       	push   $0xf0104b68
f0100eb1:	e8 7d f2 ff ff       	call   f0100133 <_panic>
f0100eb6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
	assert(nfree_basemem > 0);
f0100eb9:	85 f6                	test   %esi,%esi
f0100ebb:	7e 19                	jle    f0100ed6 <check_page_free_list+0x22f>
	assert(nfree_extmem > 0);
f0100ebd:	85 db                	test   %ebx,%ebx
f0100ebf:	7e 2e                	jle    f0100eef <check_page_free_list+0x248>
	cprintf("check_page_free_list() succeeded!\n");
f0100ec1:	83 ec 0c             	sub    $0xc,%esp
f0100ec4:	68 d8 44 10 f0       	push   $0xf01044d8
f0100ec9:	e8 33 1d 00 00       	call   f0102c01 <cprintf>
}
f0100ece:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ed1:	5b                   	pop    %ebx
f0100ed2:	5e                   	pop    %esi
f0100ed3:	5f                   	pop    %edi
f0100ed4:	5d                   	pop    %ebp
f0100ed5:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100ed6:	68 fb 4b 10 f0       	push   $0xf0104bfb
f0100edb:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0100ee0:	68 2d 02 00 00       	push   $0x22d
f0100ee5:	68 68 4b 10 f0       	push   $0xf0104b68
f0100eea:	e8 44 f2 ff ff       	call   f0100133 <_panic>
	assert(nfree_extmem > 0);
f0100eef:	68 0d 4c 10 f0       	push   $0xf0104c0d
f0100ef4:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0100ef9:	68 2e 02 00 00       	push   $0x22e
f0100efe:	68 68 4b 10 f0       	push   $0xf0104b68
f0100f03:	e8 2b f2 ff ff       	call   f0100133 <_panic>
	if (!page_free_list)
f0100f08:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0100f0d:	85 c0                	test   %eax,%eax
f0100f0f:	0f 84 b6 fd ff ff    	je     f0100ccb <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100f15:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100f18:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100f1b:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100f1e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100f21:	89 c2                	mov    %eax,%edx
f0100f23:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit; 
f0100f29:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100f2f:	0f 95 c2             	setne  %dl
f0100f32:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100f35:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100f39:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100f3b:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f3f:	8b 00                	mov    (%eax),%eax
f0100f41:	85 c0                	test   %eax,%eax
f0100f43:	75 dc                	jne    f0100f21 <check_page_free_list+0x27a>
		*tp[1] = 0;
f0100f45:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f48:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100f4e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100f51:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f54:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100f56:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f59:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f5e:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100f63:	8b 1d 3c 85 11 f0    	mov    0xf011853c,%ebx
f0100f69:	e9 88 fd ff ff       	jmp    f0100cf6 <check_page_free_list+0x4f>

f0100f6e <page_init>:
{
f0100f6e:	55                   	push   %ebp
f0100f6f:	89 e5                	mov    %esp,%ebp
f0100f71:	57                   	push   %edi
f0100f72:	56                   	push   %esi
f0100f73:	53                   	push   %ebx
	for (i = 1; i < npages_basemem; i++) {
f0100f74:	8b 35 40 85 11 f0    	mov    0xf0118540,%esi
f0100f7a:	8b 1d 3c 85 11 f0    	mov    0xf011853c,%ebx
f0100f80:	b2 00                	mov    $0x0,%dl
f0100f82:	b8 01 00 00 00       	mov    $0x1,%eax
f0100f87:	bf 01 00 00 00       	mov    $0x1,%edi
f0100f8c:	eb 22                	jmp    f0100fb0 <page_init+0x42>
		pages[i].pp_ref = 0;
f0100f8e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100f95:	89 d1                	mov    %edx,%ecx
f0100f97:	03 0d 6c 89 11 f0    	add    0xf011896c,%ecx
f0100f9d:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100fa3:	89 19                	mov    %ebx,(%ecx)
	for (i = 1; i < npages_basemem; i++) {
f0100fa5:	40                   	inc    %eax
		page_free_list = &pages[i];
f0100fa6:	89 d3                	mov    %edx,%ebx
f0100fa8:	03 1d 6c 89 11 f0    	add    0xf011896c,%ebx
f0100fae:	89 fa                	mov    %edi,%edx
	for (i = 1; i < npages_basemem; i++) {
f0100fb0:	39 c6                	cmp    %eax,%esi
f0100fb2:	77 da                	ja     f0100f8e <page_init+0x20>
f0100fb4:	84 d2                	test   %dl,%dl
f0100fb6:	75 33                	jne    f0100feb <page_init+0x7d>
	size_t table_size = PTX(sizeof(struct PageInfo)*npages);
f0100fb8:	8b 15 64 89 11 f0    	mov    0xf0118964,%edx
f0100fbe:	c1 e2 0d             	shl    $0xd,%edx
f0100fc1:	c1 ea 16             	shr    $0x16,%edx
	size_t end_idx = PTX(ROUNDUP((char *) end, PGSIZE));
f0100fc4:	b8 6f 99 11 f0       	mov    $0xf011996f,%eax
f0100fc9:	c1 e8 0c             	shr    $0xc,%eax
f0100fcc:	25 ff 03 00 00       	and    $0x3ff,%eax
	for (i = table_size + end_idx + 1; i < npages; i++) {
f0100fd1:	8d 54 02 01          	lea    0x1(%edx,%eax,1),%edx
f0100fd5:	8b 1d 3c 85 11 f0    	mov    0xf011853c,%ebx
f0100fdb:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0100fe2:	b1 00                	mov    $0x0,%cl
f0100fe4:	be 01 00 00 00       	mov    $0x1,%esi
f0100fe9:	eb 26                	jmp    f0101011 <page_init+0xa3>
f0100feb:	89 1d 3c 85 11 f0    	mov    %ebx,0xf011853c
f0100ff1:	eb c5                	jmp    f0100fb8 <page_init+0x4a>
		pages[i].pp_ref = 0;
f0100ff3:	89 c1                	mov    %eax,%ecx
f0100ff5:	03 0d 6c 89 11 f0    	add    0xf011896c,%ecx
f0100ffb:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0101001:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0101003:	89 c3                	mov    %eax,%ebx
f0101005:	03 1d 6c 89 11 f0    	add    0xf011896c,%ebx
	for (i = table_size + end_idx + 1; i < npages; i++) {
f010100b:	42                   	inc    %edx
f010100c:	83 c0 08             	add    $0x8,%eax
f010100f:	89 f1                	mov    %esi,%ecx
f0101011:	39 15 64 89 11 f0    	cmp    %edx,0xf0118964
f0101017:	77 da                	ja     f0100ff3 <page_init+0x85>
f0101019:	84 c9                	test   %cl,%cl
f010101b:	75 05                	jne    f0101022 <page_init+0xb4>
}
f010101d:	5b                   	pop    %ebx
f010101e:	5e                   	pop    %esi
f010101f:	5f                   	pop    %edi
f0101020:	5d                   	pop    %ebp
f0101021:	c3                   	ret    
f0101022:	89 1d 3c 85 11 f0    	mov    %ebx,0xf011853c
f0101028:	eb f3                	jmp    f010101d <page_init+0xaf>

f010102a <page_alloc>:
{
f010102a:	55                   	push   %ebp
f010102b:	89 e5                	mov    %esp,%ebp
f010102d:	53                   	push   %ebx
f010102e:	83 ec 04             	sub    $0x4,%esp
	struct PageInfo* next = page_free_list;
f0101031:	8b 1d 3c 85 11 f0    	mov    0xf011853c,%ebx
	if (!next)
f0101037:	85 db                	test   %ebx,%ebx
f0101039:	74 13                	je     f010104e <page_alloc+0x24>
	page_free_list = page_free_list->pp_link;
f010103b:	8b 03                	mov    (%ebx),%eax
f010103d:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
	next->pp_link = NULL;
f0101042:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f0101048:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010104c:	75 07                	jne    f0101055 <page_alloc+0x2b>
}
f010104e:	89 d8                	mov    %ebx,%eax
f0101050:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101053:	c9                   	leave  
f0101054:	c3                   	ret    
f0101055:	89 d8                	mov    %ebx,%eax
f0101057:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f010105d:	c1 f8 03             	sar    $0x3,%eax
f0101060:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101063:	89 c2                	mov    %eax,%edx
f0101065:	c1 ea 0c             	shr    $0xc,%edx
f0101068:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f010106e:	73 1a                	jae    f010108a <page_alloc+0x60>
		memset(content, 0, PGSIZE);
f0101070:	83 ec 04             	sub    $0x4,%esp
f0101073:	68 00 10 00 00       	push   $0x1000
f0101078:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f010107a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010107f:	50                   	push   %eax
f0101080:	e8 ab 26 00 00       	call   f0103730 <memset>
f0101085:	83 c4 10             	add    $0x10,%esp
f0101088:	eb c4                	jmp    f010104e <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010108a:	50                   	push   %eax
f010108b:	68 f0 43 10 f0       	push   $0xf01043f0
f0101090:	6a 52                	push   $0x52
f0101092:	68 74 4b 10 f0       	push   $0xf0104b74
f0101097:	e8 97 f0 ff ff       	call   f0100133 <_panic>

f010109c <page_free>:
{
f010109c:	55                   	push   %ebp
f010109d:	89 e5                	mov    %esp,%ebp
f010109f:	83 ec 08             	sub    $0x8,%esp
f01010a2:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref)
f01010a5:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01010aa:	75 14                	jne    f01010c0 <page_free+0x24>
	if (pp->pp_link)
f01010ac:	83 38 00             	cmpl   $0x0,(%eax)
f01010af:	75 26                	jne    f01010d7 <page_free+0x3b>
	pp->pp_link = page_free_list;
f01010b1:	8b 15 3c 85 11 f0    	mov    0xf011853c,%edx
f01010b7:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f01010b9:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
}
f01010be:	c9                   	leave  
f01010bf:	c3                   	ret    
		panic("Ref count is non-zero");
f01010c0:	83 ec 04             	sub    $0x4,%esp
f01010c3:	68 1e 4c 10 f0       	push   $0xf0104c1e
f01010c8:	68 3a 01 00 00       	push   $0x13a
f01010cd:	68 68 4b 10 f0       	push   $0xf0104b68
f01010d2:	e8 5c f0 ff ff       	call   f0100133 <_panic>
		panic("Page is double-freed");
f01010d7:	83 ec 04             	sub    $0x4,%esp
f01010da:	68 34 4c 10 f0       	push   $0xf0104c34
f01010df:	68 3c 01 00 00       	push   $0x13c
f01010e4:	68 68 4b 10 f0       	push   $0xf0104b68
f01010e9:	e8 45 f0 ff ff       	call   f0100133 <_panic>

f01010ee <page_decref>:
{
f01010ee:	55                   	push   %ebp
f01010ef:	89 e5                	mov    %esp,%ebp
f01010f1:	83 ec 08             	sub    $0x8,%esp
f01010f4:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01010f7:	8b 42 04             	mov    0x4(%edx),%eax
f01010fa:	48                   	dec    %eax
f01010fb:	66 89 42 04          	mov    %ax,0x4(%edx)
f01010ff:	66 85 c0             	test   %ax,%ax
f0101102:	74 02                	je     f0101106 <page_decref+0x18>
}
f0101104:	c9                   	leave  
f0101105:	c3                   	ret    
		page_free(pp);
f0101106:	83 ec 0c             	sub    $0xc,%esp
f0101109:	52                   	push   %edx
f010110a:	e8 8d ff ff ff       	call   f010109c <page_free>
f010110f:	83 c4 10             	add    $0x10,%esp
}
f0101112:	eb f0                	jmp    f0101104 <page_decref+0x16>

f0101114 <pgdir_walk>:
{
f0101114:	55                   	push   %ebp
f0101115:	89 e5                	mov    %esp,%ebp
f0101117:	57                   	push   %edi
f0101118:	56                   	push   %esi
f0101119:	53                   	push   %ebx
f010111a:	83 ec 1c             	sub    $0x1c,%esp
	pde_t pd_entry = (pde_t)pgdir[PDX(va)];
f010111d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101120:	c1 eb 16             	shr    $0x16,%ebx
f0101123:	c1 e3 02             	shl    $0x2,%ebx
f0101126:	03 5d 08             	add    0x8(%ebp),%ebx
f0101129:	8b 03                	mov    (%ebx),%eax
	if (pd_entry) {
f010112b:	85 c0                	test   %eax,%eax
f010112d:	74 42                	je     f0101171 <pgdir_walk+0x5d>
		pte_t* pt_base = KADDR(PTE_ADDR(pd_entry));
f010112f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101134:	89 c2                	mov    %eax,%edx
f0101136:	c1 ea 0c             	shr    $0xc,%edx
f0101139:	39 15 64 89 11 f0    	cmp    %edx,0xf0118964
f010113f:	76 1b                	jbe    f010115c <pgdir_walk+0x48>
		return pt_base + PTX(va);
f0101141:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101144:	c1 ea 0a             	shr    $0xa,%edx
f0101147:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f010114d:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
}
f0101154:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101157:	5b                   	pop    %ebx
f0101158:	5e                   	pop    %esi
f0101159:	5f                   	pop    %edi
f010115a:	5d                   	pop    %ebp
f010115b:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010115c:	50                   	push   %eax
f010115d:	68 f0 43 10 f0       	push   $0xf01043f0
f0101162:	68 67 01 00 00       	push   $0x167
f0101167:	68 68 4b 10 f0       	push   $0xf0104b68
f010116c:	e8 c2 ef ff ff       	call   f0100133 <_panic>
	else if (create) {
f0101171:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101175:	0f 84 9c 00 00 00    	je     f0101217 <pgdir_walk+0x103>
		struct PageInfo *new_pt = page_alloc(0);
f010117b:	83 ec 0c             	sub    $0xc,%esp
f010117e:	6a 00                	push   $0x0
f0101180:	e8 a5 fe ff ff       	call   f010102a <page_alloc>
f0101185:	89 c7                	mov    %eax,%edi
		if (new_pt) {
f0101187:	83 c4 10             	add    $0x10,%esp
f010118a:	85 c0                	test   %eax,%eax
f010118c:	0f 84 8f 00 00 00    	je     f0101221 <pgdir_walk+0x10d>
	return (pp - pages) << PGSHIFT;
f0101192:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0101198:	c1 f8 03             	sar    $0x3,%eax
f010119b:	c1 e0 0c             	shl    $0xc,%eax
f010119e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (PGNUM(pa) >= npages)
f01011a1:	c1 e8 0c             	shr    $0xc,%eax
f01011a4:	3b 05 64 89 11 f0    	cmp    0xf0118964,%eax
f01011aa:	73 42                	jae    f01011ee <pgdir_walk+0xda>
	return (void *)(pa + KERNBASE);
f01011ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01011af:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
			memset(content, 0, PGSIZE);
f01011b5:	83 ec 04             	sub    $0x4,%esp
f01011b8:	68 00 10 00 00       	push   $0x1000
f01011bd:	6a 00                	push   $0x0
f01011bf:	56                   	push   %esi
f01011c0:	e8 6b 25 00 00       	call   f0103730 <memset>
			new_pt->pp_ref++;
f01011c5:	66 ff 47 04          	incw   0x4(%edi)
	if ((uint32_t)kva < KERNBASE)
f01011c9:	83 c4 10             	add    $0x10,%esp
f01011cc:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01011d2:	76 2e                	jbe    f0101202 <pgdir_walk+0xee>
			pgdir[PDX(va)] = PADDR(content) | 0xF; // Set all permissions.
f01011d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01011d7:	83 c8 0f             	or     $0xf,%eax
f01011da:	89 03                	mov    %eax,(%ebx)
			return (pte_t*) content + PTX(va);
f01011dc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011df:	c1 e8 0a             	shr    $0xa,%eax
f01011e2:	25 fc 0f 00 00       	and    $0xffc,%eax
f01011e7:	01 f0                	add    %esi,%eax
f01011e9:	e9 66 ff ff ff       	jmp    f0101154 <pgdir_walk+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011ee:	ff 75 e4             	pushl  -0x1c(%ebp)
f01011f1:	68 f0 43 10 f0       	push   $0xf01043f0
f01011f6:	6a 52                	push   $0x52
f01011f8:	68 74 4b 10 f0       	push   $0xf0104b74
f01011fd:	e8 31 ef ff ff       	call   f0100133 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101202:	56                   	push   %esi
f0101203:	68 fc 44 10 f0       	push   $0xf01044fc
f0101208:	68 70 01 00 00       	push   $0x170
f010120d:	68 68 4b 10 f0       	push   $0xf0104b68
f0101212:	e8 1c ef ff ff       	call   f0100133 <_panic>
	return NULL;
f0101217:	b8 00 00 00 00       	mov    $0x0,%eax
f010121c:	e9 33 ff ff ff       	jmp    f0101154 <pgdir_walk+0x40>
f0101221:	b8 00 00 00 00       	mov    $0x0,%eax
f0101226:	e9 29 ff ff ff       	jmp    f0101154 <pgdir_walk+0x40>

f010122b <boot_map_region>:
{
f010122b:	55                   	push   %ebp
f010122c:	89 e5                	mov    %esp,%ebp
f010122e:	57                   	push   %edi
f010122f:	56                   	push   %esi
f0101230:	53                   	push   %ebx
f0101231:	83 ec 1c             	sub    $0x1c,%esp
f0101234:	89 c7                	mov    %eax,%edi
f0101236:	89 d6                	mov    %edx,%esi
f0101238:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f010123b:	bb 00 00 00 00       	mov    $0x0,%ebx
		*page_entry = (pa + size0) | perm | PTE_P;
f0101240:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101243:	83 c8 01             	or     $0x1,%eax
f0101246:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f0101249:	eb 22                	jmp    f010126d <boot_map_region+0x42>
		pte_t *page_entry = pgdir_walk(pgdir, (void*) va + size0, 1);
f010124b:	83 ec 04             	sub    $0x4,%esp
f010124e:	6a 01                	push   $0x1
f0101250:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f0101253:	50                   	push   %eax
f0101254:	57                   	push   %edi
f0101255:	e8 ba fe ff ff       	call   f0101114 <pgdir_walk>
		*page_entry = (pa + size0) | perm | PTE_P;
f010125a:	89 da                	mov    %ebx,%edx
f010125c:	03 55 08             	add    0x8(%ebp),%edx
f010125f:	0b 55 e0             	or     -0x20(%ebp),%edx
f0101262:	89 10                	mov    %edx,(%eax)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f0101264:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010126a:	83 c4 10             	add    $0x10,%esp
f010126d:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101270:	72 d9                	jb     f010124b <boot_map_region+0x20>
}
f0101272:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101275:	5b                   	pop    %ebx
f0101276:	5e                   	pop    %esi
f0101277:	5f                   	pop    %edi
f0101278:	5d                   	pop    %ebp
f0101279:	c3                   	ret    

f010127a <page_lookup>:
{
f010127a:	55                   	push   %ebp
f010127b:	89 e5                	mov    %esp,%ebp
f010127d:	53                   	push   %ebx
f010127e:	83 ec 08             	sub    $0x8,%esp
f0101281:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *page_entry = pgdir_walk(pgdir, (void*) va, 0);
f0101284:	6a 00                	push   $0x0
f0101286:	ff 75 0c             	pushl  0xc(%ebp)
f0101289:	ff 75 08             	pushl  0x8(%ebp)
f010128c:	e8 83 fe ff ff       	call   f0101114 <pgdir_walk>
	if (!page_entry || !*page_entry)
f0101291:	83 c4 10             	add    $0x10,%esp
f0101294:	85 c0                	test   %eax,%eax
f0101296:	74 3a                	je     f01012d2 <page_lookup+0x58>
f0101298:	83 38 00             	cmpl   $0x0,(%eax)
f010129b:	74 3c                	je     f01012d9 <page_lookup+0x5f>
	if (pte_store)
f010129d:	85 db                	test   %ebx,%ebx
f010129f:	74 02                	je     f01012a3 <page_lookup+0x29>
		*pte_store = page_entry;
f01012a1:	89 03                	mov    %eax,(%ebx)
f01012a3:	8b 00                	mov    (%eax),%eax
f01012a5:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012a8:	39 05 64 89 11 f0    	cmp    %eax,0xf0118964
f01012ae:	76 0e                	jbe    f01012be <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01012b0:	8b 15 6c 89 11 f0    	mov    0xf011896c,%edx
f01012b6:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f01012b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01012bc:	c9                   	leave  
f01012bd:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01012be:	83 ec 04             	sub    $0x4,%esp
f01012c1:	68 20 45 10 f0       	push   $0xf0104520
f01012c6:	6a 4b                	push   $0x4b
f01012c8:	68 74 4b 10 f0       	push   $0xf0104b74
f01012cd:	e8 61 ee ff ff       	call   f0100133 <_panic>
		return NULL;
f01012d2:	b8 00 00 00 00       	mov    $0x0,%eax
f01012d7:	eb e0                	jmp    f01012b9 <page_lookup+0x3f>
f01012d9:	b8 00 00 00 00       	mov    $0x0,%eax
f01012de:	eb d9                	jmp    f01012b9 <page_lookup+0x3f>

f01012e0 <page_remove>:
{
f01012e0:	55                   	push   %ebp
f01012e1:	89 e5                	mov    %esp,%ebp
f01012e3:	53                   	push   %ebx
f01012e4:	83 ec 18             	sub    $0x18,%esp
f01012e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo *pp = page_lookup(pgdir, va, &pte_store);
f01012ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01012ed:	50                   	push   %eax
f01012ee:	53                   	push   %ebx
f01012ef:	ff 75 08             	pushl  0x8(%ebp)
f01012f2:	e8 83 ff ff ff       	call   f010127a <page_lookup>
	if (!pp)
f01012f7:	83 c4 10             	add    $0x10,%esp
f01012fa:	85 c0                	test   %eax,%eax
f01012fc:	74 17                	je     f0101315 <page_remove+0x35>
	pp->pp_ref--;
f01012fe:	66 ff 48 04          	decw   0x4(%eax)
	*pte_store = 0;
f0101302:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101305:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010130b:	0f 01 3b             	invlpg (%ebx)
	if (!pp->pp_ref)
f010130e:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101313:	74 05                	je     f010131a <page_remove+0x3a>
}
f0101315:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101318:	c9                   	leave  
f0101319:	c3                   	ret    
		page_free(pp);
f010131a:	83 ec 0c             	sub    $0xc,%esp
f010131d:	50                   	push   %eax
f010131e:	e8 79 fd ff ff       	call   f010109c <page_free>
f0101323:	83 c4 10             	add    $0x10,%esp
f0101326:	eb ed                	jmp    f0101315 <page_remove+0x35>

f0101328 <page_insert>:
{
f0101328:	55                   	push   %ebp
f0101329:	89 e5                	mov    %esp,%ebp
f010132b:	57                   	push   %edi
f010132c:	56                   	push   %esi
f010132d:	53                   	push   %ebx
f010132e:	83 ec 10             	sub    $0x10,%esp
f0101331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101334:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *page_entry = pgdir_walk(pgdir, (void*) va, 1);
f0101337:	6a 01                	push   $0x1
f0101339:	57                   	push   %edi
f010133a:	ff 75 08             	pushl  0x8(%ebp)
f010133d:	e8 d2 fd ff ff       	call   f0101114 <pgdir_walk>
	if (!page_entry)
f0101342:	83 c4 10             	add    $0x10,%esp
f0101345:	85 c0                	test   %eax,%eax
f0101347:	74 3f                	je     f0101388 <page_insert+0x60>
f0101349:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f010134b:	66 ff 43 04          	incw   0x4(%ebx)
	if (*page_entry) 
f010134f:	83 38 00             	cmpl   $0x0,(%eax)
f0101352:	75 23                	jne    f0101377 <page_insert+0x4f>
	return (pp - pages) << PGSHIFT;
f0101354:	2b 1d 6c 89 11 f0    	sub    0xf011896c,%ebx
f010135a:	c1 fb 03             	sar    $0x3,%ebx
f010135d:	c1 e3 0c             	shl    $0xc,%ebx
	*page_entry = page2pa(pp) | perm | PTE_P;
f0101360:	8b 45 14             	mov    0x14(%ebp),%eax
f0101363:	83 c8 01             	or     $0x1,%eax
f0101366:	09 c3                	or     %eax,%ebx
f0101368:	89 1e                	mov    %ebx,(%esi)
	return 0;
f010136a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010136f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101372:	5b                   	pop    %ebx
f0101373:	5e                   	pop    %esi
f0101374:	5f                   	pop    %edi
f0101375:	5d                   	pop    %ebp
f0101376:	c3                   	ret    
		page_remove(pgdir, va);
f0101377:	83 ec 08             	sub    $0x8,%esp
f010137a:	57                   	push   %edi
f010137b:	ff 75 08             	pushl  0x8(%ebp)
f010137e:	e8 5d ff ff ff       	call   f01012e0 <page_remove>
f0101383:	83 c4 10             	add    $0x10,%esp
f0101386:	eb cc                	jmp    f0101354 <page_insert+0x2c>
		return -E_NO_MEM;  // Has no page table AND cannot be allocated
f0101388:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010138d:	eb e0                	jmp    f010136f <page_insert+0x47>

f010138f <mem_init>:
{
f010138f:	55                   	push   %ebp
f0101390:	89 e5                	mov    %esp,%ebp
f0101392:	57                   	push   %edi
f0101393:	56                   	push   %esi
f0101394:	53                   	push   %ebx
f0101395:	83 ec 2c             	sub    $0x2c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0101398:	b8 15 00 00 00       	mov    $0x15,%eax
f010139d:	e8 7f f8 ff ff       	call   f0100c21 <nvram_read>
f01013a2:	89 c6                	mov    %eax,%esi
	extmem = nvram_read(NVRAM_EXTLO);
f01013a4:	b8 17 00 00 00       	mov    $0x17,%eax
f01013a9:	e8 73 f8 ff ff       	call   f0100c21 <nvram_read>
f01013ae:	89 c3                	mov    %eax,%ebx
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01013b0:	b8 34 00 00 00       	mov    $0x34,%eax
f01013b5:	e8 67 f8 ff ff       	call   f0100c21 <nvram_read>
	if (ext16mem)
f01013ba:	c1 e0 06             	shl    $0x6,%eax
f01013bd:	75 10                	jne    f01013cf <mem_init+0x40>
	else if (extmem)
f01013bf:	85 db                	test   %ebx,%ebx
f01013c1:	0f 84 c3 00 00 00    	je     f010148a <mem_init+0xfb>
		totalmem = 1 * 1024 + extmem;
f01013c7:	8d 83 00 04 00 00    	lea    0x400(%ebx),%eax
f01013cd:	eb 05                	jmp    f01013d4 <mem_init+0x45>
		totalmem = 16 * 1024 + ext16mem;
f01013cf:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f01013d4:	89 c2                	mov    %eax,%edx
f01013d6:	c1 ea 02             	shr    $0x2,%edx
f01013d9:	89 15 64 89 11 f0    	mov    %edx,0xf0118964
	npages_basemem = basemem / (PGSIZE / 1024);
f01013df:	89 f2                	mov    %esi,%edx
f01013e1:	c1 ea 02             	shr    $0x2,%edx
f01013e4:	89 15 40 85 11 f0    	mov    %edx,0xf0118540
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013ea:	89 c2                	mov    %eax,%edx
f01013ec:	29 f2                	sub    %esi,%edx
f01013ee:	52                   	push   %edx
f01013ef:	56                   	push   %esi
f01013f0:	50                   	push   %eax
f01013f1:	68 40 45 10 f0       	push   $0xf0104540
f01013f6:	e8 06 18 00 00       	call   f0102c01 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01013fb:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101400:	e8 d6 f7 ff ff       	call   f0100bdb <boot_alloc>
f0101405:	a3 68 89 11 f0       	mov    %eax,0xf0118968
	memset(kern_pgdir, 0, PGSIZE);
f010140a:	83 c4 0c             	add    $0xc,%esp
f010140d:	68 00 10 00 00       	push   $0x1000
f0101412:	6a 00                	push   $0x0
f0101414:	50                   	push   %eax
f0101415:	e8 16 23 00 00       	call   f0103730 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010141a:	a1 68 89 11 f0       	mov    0xf0118968,%eax
	if ((uint32_t)kva < KERNBASE)
f010141f:	83 c4 10             	add    $0x10,%esp
f0101422:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101427:	76 68                	jbe    f0101491 <mem_init+0x102>
	return (physaddr_t)kva - KERNBASE;
f0101429:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010142f:	83 ca 05             	or     $0x5,%edx
f0101432:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo)*npages);
f0101438:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f010143d:	c1 e0 03             	shl    $0x3,%eax
f0101440:	e8 96 f7 ff ff       	call   f0100bdb <boot_alloc>
f0101445:	a3 6c 89 11 f0       	mov    %eax,0xf011896c
	memset(pages, 0, sizeof(struct PageInfo)*npages);
f010144a:	83 ec 04             	sub    $0x4,%esp
f010144d:	8b 0d 64 89 11 f0    	mov    0xf0118964,%ecx
f0101453:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f010145a:	52                   	push   %edx
f010145b:	6a 00                	push   $0x0
f010145d:	50                   	push   %eax
f010145e:	e8 cd 22 00 00       	call   f0103730 <memset>
	page_init();
f0101463:	e8 06 fb ff ff       	call   f0100f6e <page_init>
	check_page_free_list(1);
f0101468:	b8 01 00 00 00       	mov    $0x1,%eax
f010146d:	e8 35 f8 ff ff       	call   f0100ca7 <check_page_free_list>
	if (!pages)
f0101472:	83 c4 10             	add    $0x10,%esp
f0101475:	83 3d 6c 89 11 f0 00 	cmpl   $0x0,0xf011896c
f010147c:	74 28                	je     f01014a6 <mem_init+0x117>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010147e:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0101483:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101488:	eb 36                	jmp    f01014c0 <mem_init+0x131>
		totalmem = basemem;
f010148a:	89 f0                	mov    %esi,%eax
f010148c:	e9 43 ff ff ff       	jmp    f01013d4 <mem_init+0x45>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101491:	50                   	push   %eax
f0101492:	68 fc 44 10 f0       	push   $0xf01044fc
f0101497:	68 91 00 00 00       	push   $0x91
f010149c:	68 68 4b 10 f0       	push   $0xf0104b68
f01014a1:	e8 8d ec ff ff       	call   f0100133 <_panic>
		panic("'pages' is a null pointer!");
f01014a6:	83 ec 04             	sub    $0x4,%esp
f01014a9:	68 49 4c 10 f0       	push   $0xf0104c49
f01014ae:	68 41 02 00 00       	push   $0x241
f01014b3:	68 68 4b 10 f0       	push   $0xf0104b68
f01014b8:	e8 76 ec ff ff       	call   f0100133 <_panic>
		++nfree;
f01014bd:	43                   	inc    %ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014be:	8b 00                	mov    (%eax),%eax
f01014c0:	85 c0                	test   %eax,%eax
f01014c2:	75 f9                	jne    f01014bd <mem_init+0x12e>
	assert((pp0 = page_alloc(0)));
f01014c4:	83 ec 0c             	sub    $0xc,%esp
f01014c7:	6a 00                	push   $0x0
f01014c9:	e8 5c fb ff ff       	call   f010102a <page_alloc>
f01014ce:	89 c7                	mov    %eax,%edi
f01014d0:	83 c4 10             	add    $0x10,%esp
f01014d3:	85 c0                	test   %eax,%eax
f01014d5:	0f 84 10 02 00 00    	je     f01016eb <mem_init+0x35c>
	assert((pp1 = page_alloc(0)));
f01014db:	83 ec 0c             	sub    $0xc,%esp
f01014de:	6a 00                	push   $0x0
f01014e0:	e8 45 fb ff ff       	call   f010102a <page_alloc>
f01014e5:	89 c6                	mov    %eax,%esi
f01014e7:	83 c4 10             	add    $0x10,%esp
f01014ea:	85 c0                	test   %eax,%eax
f01014ec:	0f 84 12 02 00 00    	je     f0101704 <mem_init+0x375>
	assert((pp2 = page_alloc(0)));
f01014f2:	83 ec 0c             	sub    $0xc,%esp
f01014f5:	6a 00                	push   $0x0
f01014f7:	e8 2e fb ff ff       	call   f010102a <page_alloc>
f01014fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01014ff:	83 c4 10             	add    $0x10,%esp
f0101502:	85 c0                	test   %eax,%eax
f0101504:	0f 84 13 02 00 00    	je     f010171d <mem_init+0x38e>
	assert(pp1 && pp1 != pp0);
f010150a:	39 f7                	cmp    %esi,%edi
f010150c:	0f 84 24 02 00 00    	je     f0101736 <mem_init+0x3a7>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101512:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101515:	39 c6                	cmp    %eax,%esi
f0101517:	0f 84 32 02 00 00    	je     f010174f <mem_init+0x3c0>
f010151d:	39 c7                	cmp    %eax,%edi
f010151f:	0f 84 2a 02 00 00    	je     f010174f <mem_init+0x3c0>
	return (pp - pages) << PGSHIFT;
f0101525:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010152b:	8b 15 64 89 11 f0    	mov    0xf0118964,%edx
f0101531:	c1 e2 0c             	shl    $0xc,%edx
f0101534:	89 f8                	mov    %edi,%eax
f0101536:	29 c8                	sub    %ecx,%eax
f0101538:	c1 f8 03             	sar    $0x3,%eax
f010153b:	c1 e0 0c             	shl    $0xc,%eax
f010153e:	39 d0                	cmp    %edx,%eax
f0101540:	0f 83 22 02 00 00    	jae    f0101768 <mem_init+0x3d9>
f0101546:	89 f0                	mov    %esi,%eax
f0101548:	29 c8                	sub    %ecx,%eax
f010154a:	c1 f8 03             	sar    $0x3,%eax
f010154d:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101550:	39 c2                	cmp    %eax,%edx
f0101552:	0f 86 29 02 00 00    	jbe    f0101781 <mem_init+0x3f2>
f0101558:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010155b:	29 c8                	sub    %ecx,%eax
f010155d:	c1 f8 03             	sar    $0x3,%eax
f0101560:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101563:	39 c2                	cmp    %eax,%edx
f0101565:	0f 86 2f 02 00 00    	jbe    f010179a <mem_init+0x40b>
	fl = page_free_list;
f010156b:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0101570:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101573:	c7 05 3c 85 11 f0 00 	movl   $0x0,0xf011853c
f010157a:	00 00 00 
	assert(!page_alloc(0));
f010157d:	83 ec 0c             	sub    $0xc,%esp
f0101580:	6a 00                	push   $0x0
f0101582:	e8 a3 fa ff ff       	call   f010102a <page_alloc>
f0101587:	83 c4 10             	add    $0x10,%esp
f010158a:	85 c0                	test   %eax,%eax
f010158c:	0f 85 21 02 00 00    	jne    f01017b3 <mem_init+0x424>
	page_free(pp0);
f0101592:	83 ec 0c             	sub    $0xc,%esp
f0101595:	57                   	push   %edi
f0101596:	e8 01 fb ff ff       	call   f010109c <page_free>
	page_free(pp1);
f010159b:	89 34 24             	mov    %esi,(%esp)
f010159e:	e8 f9 fa ff ff       	call   f010109c <page_free>
	page_free(pp2);
f01015a3:	83 c4 04             	add    $0x4,%esp
f01015a6:	ff 75 d4             	pushl  -0x2c(%ebp)
f01015a9:	e8 ee fa ff ff       	call   f010109c <page_free>
	assert((pp0 = page_alloc(0)));
f01015ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015b5:	e8 70 fa ff ff       	call   f010102a <page_alloc>
f01015ba:	89 c6                	mov    %eax,%esi
f01015bc:	83 c4 10             	add    $0x10,%esp
f01015bf:	85 c0                	test   %eax,%eax
f01015c1:	0f 84 05 02 00 00    	je     f01017cc <mem_init+0x43d>
	assert((pp1 = page_alloc(0)));
f01015c7:	83 ec 0c             	sub    $0xc,%esp
f01015ca:	6a 00                	push   $0x0
f01015cc:	e8 59 fa ff ff       	call   f010102a <page_alloc>
f01015d1:	89 c7                	mov    %eax,%edi
f01015d3:	83 c4 10             	add    $0x10,%esp
f01015d6:	85 c0                	test   %eax,%eax
f01015d8:	0f 84 07 02 00 00    	je     f01017e5 <mem_init+0x456>
	assert((pp2 = page_alloc(0)));
f01015de:	83 ec 0c             	sub    $0xc,%esp
f01015e1:	6a 00                	push   $0x0
f01015e3:	e8 42 fa ff ff       	call   f010102a <page_alloc>
f01015e8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015eb:	83 c4 10             	add    $0x10,%esp
f01015ee:	85 c0                	test   %eax,%eax
f01015f0:	0f 84 08 02 00 00    	je     f01017fe <mem_init+0x46f>
	assert(pp1 && pp1 != pp0);
f01015f6:	39 fe                	cmp    %edi,%esi
f01015f8:	0f 84 19 02 00 00    	je     f0101817 <mem_init+0x488>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015fe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101601:	39 c7                	cmp    %eax,%edi
f0101603:	0f 84 27 02 00 00    	je     f0101830 <mem_init+0x4a1>
f0101609:	39 c6                	cmp    %eax,%esi
f010160b:	0f 84 1f 02 00 00    	je     f0101830 <mem_init+0x4a1>
	assert(!page_alloc(0));
f0101611:	83 ec 0c             	sub    $0xc,%esp
f0101614:	6a 00                	push   $0x0
f0101616:	e8 0f fa ff ff       	call   f010102a <page_alloc>
f010161b:	83 c4 10             	add    $0x10,%esp
f010161e:	85 c0                	test   %eax,%eax
f0101620:	0f 85 23 02 00 00    	jne    f0101849 <mem_init+0x4ba>
f0101626:	89 f0                	mov    %esi,%eax
f0101628:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f010162e:	c1 f8 03             	sar    $0x3,%eax
f0101631:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101634:	89 c2                	mov    %eax,%edx
f0101636:	c1 ea 0c             	shr    $0xc,%edx
f0101639:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f010163f:	0f 83 1d 02 00 00    	jae    f0101862 <mem_init+0x4d3>
	memset(page2kva(pp0), 1, PGSIZE);
f0101645:	83 ec 04             	sub    $0x4,%esp
f0101648:	68 00 10 00 00       	push   $0x1000
f010164d:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f010164f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101654:	50                   	push   %eax
f0101655:	e8 d6 20 00 00       	call   f0103730 <memset>
	page_free(pp0);
f010165a:	89 34 24             	mov    %esi,(%esp)
f010165d:	e8 3a fa ff ff       	call   f010109c <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101662:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101669:	e8 bc f9 ff ff       	call   f010102a <page_alloc>
f010166e:	83 c4 10             	add    $0x10,%esp
f0101671:	85 c0                	test   %eax,%eax
f0101673:	0f 84 fb 01 00 00    	je     f0101874 <mem_init+0x4e5>
	assert(pp && pp0 == pp);
f0101679:	39 c6                	cmp    %eax,%esi
f010167b:	0f 85 0c 02 00 00    	jne    f010188d <mem_init+0x4fe>
	return (pp - pages) << PGSHIFT;
f0101681:	89 f2                	mov    %esi,%edx
f0101683:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f0101689:	c1 fa 03             	sar    $0x3,%edx
f010168c:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010168f:	89 d0                	mov    %edx,%eax
f0101691:	c1 e8 0c             	shr    $0xc,%eax
f0101694:	3b 05 64 89 11 f0    	cmp    0xf0118964,%eax
f010169a:	0f 83 06 02 00 00    	jae    f01018a6 <mem_init+0x517>
	return (void *)(pa + KERNBASE);
f01016a0:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01016a6:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f01016ac:	80 38 00             	cmpb   $0x0,(%eax)
f01016af:	0f 85 03 02 00 00    	jne    f01018b8 <mem_init+0x529>
f01016b5:	40                   	inc    %eax
	for (i = 0; i < PGSIZE; i++)
f01016b6:	39 d0                	cmp    %edx,%eax
f01016b8:	75 f2                	jne    f01016ac <mem_init+0x31d>
	page_free_list = fl;
f01016ba:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01016bd:	a3 3c 85 11 f0       	mov    %eax,0xf011853c
	page_free(pp0);
f01016c2:	83 ec 0c             	sub    $0xc,%esp
f01016c5:	56                   	push   %esi
f01016c6:	e8 d1 f9 ff ff       	call   f010109c <page_free>
	page_free(pp1);
f01016cb:	89 3c 24             	mov    %edi,(%esp)
f01016ce:	e8 c9 f9 ff ff       	call   f010109c <page_free>
	page_free(pp2);
f01016d3:	83 c4 04             	add    $0x4,%esp
f01016d6:	ff 75 d4             	pushl  -0x2c(%ebp)
f01016d9:	e8 be f9 ff ff       	call   f010109c <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016de:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f01016e3:	83 c4 10             	add    $0x10,%esp
f01016e6:	e9 e9 01 00 00       	jmp    f01018d4 <mem_init+0x545>
	assert((pp0 = page_alloc(0)));
f01016eb:	68 64 4c 10 f0       	push   $0xf0104c64
f01016f0:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01016f5:	68 49 02 00 00       	push   $0x249
f01016fa:	68 68 4b 10 f0       	push   $0xf0104b68
f01016ff:	e8 2f ea ff ff       	call   f0100133 <_panic>
	assert((pp1 = page_alloc(0)));
f0101704:	68 7a 4c 10 f0       	push   $0xf0104c7a
f0101709:	68 8e 4b 10 f0       	push   $0xf0104b8e
f010170e:	68 4a 02 00 00       	push   $0x24a
f0101713:	68 68 4b 10 f0       	push   $0xf0104b68
f0101718:	e8 16 ea ff ff       	call   f0100133 <_panic>
	assert((pp2 = page_alloc(0)));
f010171d:	68 90 4c 10 f0       	push   $0xf0104c90
f0101722:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0101727:	68 4b 02 00 00       	push   $0x24b
f010172c:	68 68 4b 10 f0       	push   $0xf0104b68
f0101731:	e8 fd e9 ff ff       	call   f0100133 <_panic>
	assert(pp1 && pp1 != pp0);
f0101736:	68 a6 4c 10 f0       	push   $0xf0104ca6
f010173b:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0101740:	68 4e 02 00 00       	push   $0x24e
f0101745:	68 68 4b 10 f0       	push   $0xf0104b68
f010174a:	e8 e4 e9 ff ff       	call   f0100133 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010174f:	68 7c 45 10 f0       	push   $0xf010457c
f0101754:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0101759:	68 4f 02 00 00       	push   $0x24f
f010175e:	68 68 4b 10 f0       	push   $0xf0104b68
f0101763:	e8 cb e9 ff ff       	call   f0100133 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101768:	68 b8 4c 10 f0       	push   $0xf0104cb8
f010176d:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0101772:	68 50 02 00 00       	push   $0x250
f0101777:	68 68 4b 10 f0       	push   $0xf0104b68
f010177c:	e8 b2 e9 ff ff       	call   f0100133 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101781:	68 d5 4c 10 f0       	push   $0xf0104cd5
f0101786:	68 8e 4b 10 f0       	push   $0xf0104b8e
f010178b:	68 51 02 00 00       	push   $0x251
f0101790:	68 68 4b 10 f0       	push   $0xf0104b68
f0101795:	e8 99 e9 ff ff       	call   f0100133 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010179a:	68 f2 4c 10 f0       	push   $0xf0104cf2
f010179f:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01017a4:	68 52 02 00 00       	push   $0x252
f01017a9:	68 68 4b 10 f0       	push   $0xf0104b68
f01017ae:	e8 80 e9 ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f01017b3:	68 0f 4d 10 f0       	push   $0xf0104d0f
f01017b8:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01017bd:	68 59 02 00 00       	push   $0x259
f01017c2:	68 68 4b 10 f0       	push   $0xf0104b68
f01017c7:	e8 67 e9 ff ff       	call   f0100133 <_panic>
	assert((pp0 = page_alloc(0)));
f01017cc:	68 64 4c 10 f0       	push   $0xf0104c64
f01017d1:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01017d6:	68 60 02 00 00       	push   $0x260
f01017db:	68 68 4b 10 f0       	push   $0xf0104b68
f01017e0:	e8 4e e9 ff ff       	call   f0100133 <_panic>
	assert((pp1 = page_alloc(0)));
f01017e5:	68 7a 4c 10 f0       	push   $0xf0104c7a
f01017ea:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01017ef:	68 61 02 00 00       	push   $0x261
f01017f4:	68 68 4b 10 f0       	push   $0xf0104b68
f01017f9:	e8 35 e9 ff ff       	call   f0100133 <_panic>
	assert((pp2 = page_alloc(0)));
f01017fe:	68 90 4c 10 f0       	push   $0xf0104c90
f0101803:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0101808:	68 62 02 00 00       	push   $0x262
f010180d:	68 68 4b 10 f0       	push   $0xf0104b68
f0101812:	e8 1c e9 ff ff       	call   f0100133 <_panic>
	assert(pp1 && pp1 != pp0);
f0101817:	68 a6 4c 10 f0       	push   $0xf0104ca6
f010181c:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0101821:	68 64 02 00 00       	push   $0x264
f0101826:	68 68 4b 10 f0       	push   $0xf0104b68
f010182b:	e8 03 e9 ff ff       	call   f0100133 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101830:	68 7c 45 10 f0       	push   $0xf010457c
f0101835:	68 8e 4b 10 f0       	push   $0xf0104b8e
f010183a:	68 65 02 00 00       	push   $0x265
f010183f:	68 68 4b 10 f0       	push   $0xf0104b68
f0101844:	e8 ea e8 ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f0101849:	68 0f 4d 10 f0       	push   $0xf0104d0f
f010184e:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0101853:	68 66 02 00 00       	push   $0x266
f0101858:	68 68 4b 10 f0       	push   $0xf0104b68
f010185d:	e8 d1 e8 ff ff       	call   f0100133 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101862:	50                   	push   %eax
f0101863:	68 f0 43 10 f0       	push   $0xf01043f0
f0101868:	6a 52                	push   $0x52
f010186a:	68 74 4b 10 f0       	push   $0xf0104b74
f010186f:	e8 bf e8 ff ff       	call   f0100133 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101874:	68 1e 4d 10 f0       	push   $0xf0104d1e
f0101879:	68 8e 4b 10 f0       	push   $0xf0104b8e
f010187e:	68 6b 02 00 00       	push   $0x26b
f0101883:	68 68 4b 10 f0       	push   $0xf0104b68
f0101888:	e8 a6 e8 ff ff       	call   f0100133 <_panic>
	assert(pp && pp0 == pp);
f010188d:	68 3c 4d 10 f0       	push   $0xf0104d3c
f0101892:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0101897:	68 6c 02 00 00       	push   $0x26c
f010189c:	68 68 4b 10 f0       	push   $0xf0104b68
f01018a1:	e8 8d e8 ff ff       	call   f0100133 <_panic>
f01018a6:	52                   	push   %edx
f01018a7:	68 f0 43 10 f0       	push   $0xf01043f0
f01018ac:	6a 52                	push   $0x52
f01018ae:	68 74 4b 10 f0       	push   $0xf0104b74
f01018b3:	e8 7b e8 ff ff       	call   f0100133 <_panic>
		assert(c[i] == 0);
f01018b8:	68 4c 4d 10 f0       	push   $0xf0104d4c
f01018bd:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01018c2:	68 6f 02 00 00       	push   $0x26f
f01018c7:	68 68 4b 10 f0       	push   $0xf0104b68
f01018cc:	e8 62 e8 ff ff       	call   f0100133 <_panic>
		--nfree;
f01018d1:	4b                   	dec    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01018d2:	8b 00                	mov    (%eax),%eax
f01018d4:	85 c0                	test   %eax,%eax
f01018d6:	75 f9                	jne    f01018d1 <mem_init+0x542>
	assert(nfree == 0);
f01018d8:	85 db                	test   %ebx,%ebx
f01018da:	0f 85 9c 07 00 00    	jne    f010207c <mem_init+0xced>
	cprintf("check_page_alloc() succeeded!\n");
f01018e0:	83 ec 0c             	sub    $0xc,%esp
f01018e3:	68 9c 45 10 f0       	push   $0xf010459c
f01018e8:	e8 14 13 00 00       	call   f0102c01 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01018ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018f4:	e8 31 f7 ff ff       	call   f010102a <page_alloc>
f01018f9:	89 c7                	mov    %eax,%edi
f01018fb:	83 c4 10             	add    $0x10,%esp
f01018fe:	85 c0                	test   %eax,%eax
f0101900:	0f 84 8f 07 00 00    	je     f0102095 <mem_init+0xd06>
	assert((pp1 = page_alloc(0)));
f0101906:	83 ec 0c             	sub    $0xc,%esp
f0101909:	6a 00                	push   $0x0
f010190b:	e8 1a f7 ff ff       	call   f010102a <page_alloc>
f0101910:	89 c3                	mov    %eax,%ebx
f0101912:	83 c4 10             	add    $0x10,%esp
f0101915:	85 c0                	test   %eax,%eax
f0101917:	0f 84 91 07 00 00    	je     f01020ae <mem_init+0xd1f>
	assert((pp2 = page_alloc(0)));
f010191d:	83 ec 0c             	sub    $0xc,%esp
f0101920:	6a 00                	push   $0x0
f0101922:	e8 03 f7 ff ff       	call   f010102a <page_alloc>
f0101927:	89 c6                	mov    %eax,%esi
f0101929:	83 c4 10             	add    $0x10,%esp
f010192c:	85 c0                	test   %eax,%eax
f010192e:	0f 84 93 07 00 00    	je     f01020c7 <mem_init+0xd38>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101934:	39 df                	cmp    %ebx,%edi
f0101936:	0f 84 a4 07 00 00    	je     f01020e0 <mem_init+0xd51>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010193c:	39 c3                	cmp    %eax,%ebx
f010193e:	0f 84 b5 07 00 00    	je     f01020f9 <mem_init+0xd6a>
f0101944:	39 c7                	cmp    %eax,%edi
f0101946:	0f 84 ad 07 00 00    	je     f01020f9 <mem_init+0xd6a>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010194c:	a1 3c 85 11 f0       	mov    0xf011853c,%eax
f0101951:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f0101954:	c7 05 3c 85 11 f0 00 	movl   $0x0,0xf011853c
f010195b:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010195e:	83 ec 0c             	sub    $0xc,%esp
f0101961:	6a 00                	push   $0x0
f0101963:	e8 c2 f6 ff ff       	call   f010102a <page_alloc>
f0101968:	83 c4 10             	add    $0x10,%esp
f010196b:	85 c0                	test   %eax,%eax
f010196d:	0f 85 9f 07 00 00    	jne    f0102112 <mem_init+0xd83>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101973:	83 ec 04             	sub    $0x4,%esp
f0101976:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101979:	50                   	push   %eax
f010197a:	6a 00                	push   $0x0
f010197c:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101982:	e8 f3 f8 ff ff       	call   f010127a <page_lookup>
f0101987:	83 c4 10             	add    $0x10,%esp
f010198a:	85 c0                	test   %eax,%eax
f010198c:	0f 85 99 07 00 00    	jne    f010212b <mem_init+0xd9c>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101992:	6a 02                	push   $0x2
f0101994:	6a 00                	push   $0x0
f0101996:	53                   	push   %ebx
f0101997:	ff 35 68 89 11 f0    	pushl  0xf0118968
f010199d:	e8 86 f9 ff ff       	call   f0101328 <page_insert>
f01019a2:	83 c4 10             	add    $0x10,%esp
f01019a5:	85 c0                	test   %eax,%eax
f01019a7:	0f 89 97 07 00 00    	jns    f0102144 <mem_init+0xdb5>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01019ad:	83 ec 0c             	sub    $0xc,%esp
f01019b0:	57                   	push   %edi
f01019b1:	e8 e6 f6 ff ff       	call   f010109c <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01019b6:	6a 02                	push   $0x2
f01019b8:	6a 00                	push   $0x0
f01019ba:	53                   	push   %ebx
f01019bb:	ff 35 68 89 11 f0    	pushl  0xf0118968
f01019c1:	e8 62 f9 ff ff       	call   f0101328 <page_insert>
f01019c6:	83 c4 20             	add    $0x20,%esp
f01019c9:	85 c0                	test   %eax,%eax
f01019cb:	0f 85 8c 07 00 00    	jne    f010215d <mem_init+0xdce>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01019d1:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f01019d6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	return (pp - pages) << PGSHIFT;
f01019d9:	8b 0d 6c 89 11 f0    	mov    0xf011896c,%ecx
f01019df:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01019e2:	8b 00                	mov    (%eax),%eax
f01019e4:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01019e7:	89 c2                	mov    %eax,%edx
f01019e9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01019ef:	89 f8                	mov    %edi,%eax
f01019f1:	29 c8                	sub    %ecx,%eax
f01019f3:	c1 f8 03             	sar    $0x3,%eax
f01019f6:	c1 e0 0c             	shl    $0xc,%eax
f01019f9:	39 c2                	cmp    %eax,%edx
f01019fb:	0f 85 75 07 00 00    	jne    f0102176 <mem_init+0xde7>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101a01:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a06:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a09:	e8 3a f2 ff ff       	call   f0100c48 <check_va2pa>
f0101a0e:	89 da                	mov    %ebx,%edx
f0101a10:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101a13:	c1 fa 03             	sar    $0x3,%edx
f0101a16:	c1 e2 0c             	shl    $0xc,%edx
f0101a19:	39 d0                	cmp    %edx,%eax
f0101a1b:	0f 85 6e 07 00 00    	jne    f010218f <mem_init+0xe00>
	assert(pp1->pp_ref == 1);
f0101a21:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a26:	0f 85 7c 07 00 00    	jne    f01021a8 <mem_init+0xe19>
	assert(pp0->pp_ref == 1);
f0101a2c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101a31:	0f 85 8a 07 00 00    	jne    f01021c1 <mem_init+0xe32>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a37:	6a 02                	push   $0x2
f0101a39:	68 00 10 00 00       	push   $0x1000
f0101a3e:	56                   	push   %esi
f0101a3f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a42:	e8 e1 f8 ff ff       	call   f0101328 <page_insert>
f0101a47:	83 c4 10             	add    $0x10,%esp
f0101a4a:	85 c0                	test   %eax,%eax
f0101a4c:	0f 85 88 07 00 00    	jne    f01021da <mem_init+0xe4b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a52:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a57:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101a5c:	e8 e7 f1 ff ff       	call   f0100c48 <check_va2pa>
f0101a61:	89 f2                	mov    %esi,%edx
f0101a63:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f0101a69:	c1 fa 03             	sar    $0x3,%edx
f0101a6c:	c1 e2 0c             	shl    $0xc,%edx
f0101a6f:	39 d0                	cmp    %edx,%eax
f0101a71:	0f 85 7c 07 00 00    	jne    f01021f3 <mem_init+0xe64>
	assert(pp2->pp_ref == 1);
f0101a77:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a7c:	0f 85 8a 07 00 00    	jne    f010220c <mem_init+0xe7d>

	// should be no free memory
	assert(!page_alloc(0));
f0101a82:	83 ec 0c             	sub    $0xc,%esp
f0101a85:	6a 00                	push   $0x0
f0101a87:	e8 9e f5 ff ff       	call   f010102a <page_alloc>
f0101a8c:	83 c4 10             	add    $0x10,%esp
f0101a8f:	85 c0                	test   %eax,%eax
f0101a91:	0f 85 8e 07 00 00    	jne    f0102225 <mem_init+0xe96>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a97:	6a 02                	push   $0x2
f0101a99:	68 00 10 00 00       	push   $0x1000
f0101a9e:	56                   	push   %esi
f0101a9f:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101aa5:	e8 7e f8 ff ff       	call   f0101328 <page_insert>
f0101aaa:	83 c4 10             	add    $0x10,%esp
f0101aad:	85 c0                	test   %eax,%eax
f0101aaf:	0f 85 89 07 00 00    	jne    f010223e <mem_init+0xeaf>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ab5:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101aba:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101abf:	e8 84 f1 ff ff       	call   f0100c48 <check_va2pa>
f0101ac4:	89 f2                	mov    %esi,%edx
f0101ac6:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f0101acc:	c1 fa 03             	sar    $0x3,%edx
f0101acf:	c1 e2 0c             	shl    $0xc,%edx
f0101ad2:	39 d0                	cmp    %edx,%eax
f0101ad4:	0f 85 7d 07 00 00    	jne    f0102257 <mem_init+0xec8>
	assert(pp2->pp_ref == 1);
f0101ada:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101adf:	0f 85 8b 07 00 00    	jne    f0102270 <mem_init+0xee1>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101ae5:	83 ec 0c             	sub    $0xc,%esp
f0101ae8:	6a 00                	push   $0x0
f0101aea:	e8 3b f5 ff ff       	call   f010102a <page_alloc>
f0101aef:	83 c4 10             	add    $0x10,%esp
f0101af2:	85 c0                	test   %eax,%eax
f0101af4:	0f 85 8f 07 00 00    	jne    f0102289 <mem_init+0xefa>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101afa:	8b 15 68 89 11 f0    	mov    0xf0118968,%edx
f0101b00:	8b 02                	mov    (%edx),%eax
f0101b02:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101b07:	89 c1                	mov    %eax,%ecx
f0101b09:	c1 e9 0c             	shr    $0xc,%ecx
f0101b0c:	3b 0d 64 89 11 f0    	cmp    0xf0118964,%ecx
f0101b12:	0f 83 8a 07 00 00    	jae    f01022a2 <mem_init+0xf13>
	return (void *)(pa + KERNBASE);
f0101b18:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101b1d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101b20:	83 ec 04             	sub    $0x4,%esp
f0101b23:	6a 00                	push   $0x0
f0101b25:	68 00 10 00 00       	push   $0x1000
f0101b2a:	52                   	push   %edx
f0101b2b:	e8 e4 f5 ff ff       	call   f0101114 <pgdir_walk>
f0101b30:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101b33:	8d 51 04             	lea    0x4(%ecx),%edx
f0101b36:	83 c4 10             	add    $0x10,%esp
f0101b39:	39 d0                	cmp    %edx,%eax
f0101b3b:	0f 85 76 07 00 00    	jne    f01022b7 <mem_init+0xf28>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101b41:	6a 06                	push   $0x6
f0101b43:	68 00 10 00 00       	push   $0x1000
f0101b48:	56                   	push   %esi
f0101b49:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101b4f:	e8 d4 f7 ff ff       	call   f0101328 <page_insert>
f0101b54:	83 c4 10             	add    $0x10,%esp
f0101b57:	85 c0                	test   %eax,%eax
f0101b59:	0f 85 71 07 00 00    	jne    f01022d0 <mem_init+0xf41>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b5f:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101b64:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101b67:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b6c:	e8 d7 f0 ff ff       	call   f0100c48 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101b71:	89 f2                	mov    %esi,%edx
f0101b73:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f0101b79:	c1 fa 03             	sar    $0x3,%edx
f0101b7c:	c1 e2 0c             	shl    $0xc,%edx
f0101b7f:	39 d0                	cmp    %edx,%eax
f0101b81:	0f 85 62 07 00 00    	jne    f01022e9 <mem_init+0xf5a>
	assert(pp2->pp_ref == 1);
f0101b87:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b8c:	0f 85 70 07 00 00    	jne    f0102302 <mem_init+0xf73>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b92:	83 ec 04             	sub    $0x4,%esp
f0101b95:	6a 00                	push   $0x0
f0101b97:	68 00 10 00 00       	push   $0x1000
f0101b9c:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b9f:	e8 70 f5 ff ff       	call   f0101114 <pgdir_walk>
f0101ba4:	83 c4 10             	add    $0x10,%esp
f0101ba7:	f6 00 04             	testb  $0x4,(%eax)
f0101baa:	0f 84 6b 07 00 00    	je     f010231b <mem_init+0xf8c>
	assert(kern_pgdir[0] & PTE_U);
f0101bb0:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101bb5:	f6 00 04             	testb  $0x4,(%eax)
f0101bb8:	0f 84 76 07 00 00    	je     f0102334 <mem_init+0xfa5>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bbe:	6a 02                	push   $0x2
f0101bc0:	68 00 10 00 00       	push   $0x1000
f0101bc5:	56                   	push   %esi
f0101bc6:	50                   	push   %eax
f0101bc7:	e8 5c f7 ff ff       	call   f0101328 <page_insert>
f0101bcc:	83 c4 10             	add    $0x10,%esp
f0101bcf:	85 c0                	test   %eax,%eax
f0101bd1:	0f 85 76 07 00 00    	jne    f010234d <mem_init+0xfbe>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101bd7:	83 ec 04             	sub    $0x4,%esp
f0101bda:	6a 00                	push   $0x0
f0101bdc:	68 00 10 00 00       	push   $0x1000
f0101be1:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101be7:	e8 28 f5 ff ff       	call   f0101114 <pgdir_walk>
f0101bec:	83 c4 10             	add    $0x10,%esp
f0101bef:	f6 00 02             	testb  $0x2,(%eax)
f0101bf2:	0f 84 6e 07 00 00    	je     f0102366 <mem_init+0xfd7>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bf8:	83 ec 04             	sub    $0x4,%esp
f0101bfb:	6a 00                	push   $0x0
f0101bfd:	68 00 10 00 00       	push   $0x1000
f0101c02:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101c08:	e8 07 f5 ff ff       	call   f0101114 <pgdir_walk>
f0101c0d:	83 c4 10             	add    $0x10,%esp
f0101c10:	f6 00 04             	testb  $0x4,(%eax)
f0101c13:	0f 85 66 07 00 00    	jne    f010237f <mem_init+0xff0>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101c19:	6a 02                	push   $0x2
f0101c1b:	68 00 00 40 00       	push   $0x400000
f0101c20:	57                   	push   %edi
f0101c21:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101c27:	e8 fc f6 ff ff       	call   f0101328 <page_insert>
f0101c2c:	83 c4 10             	add    $0x10,%esp
f0101c2f:	85 c0                	test   %eax,%eax
f0101c31:	0f 89 61 07 00 00    	jns    f0102398 <mem_init+0x1009>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101c37:	6a 02                	push   $0x2
f0101c39:	68 00 10 00 00       	push   $0x1000
f0101c3e:	53                   	push   %ebx
f0101c3f:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101c45:	e8 de f6 ff ff       	call   f0101328 <page_insert>
f0101c4a:	83 c4 10             	add    $0x10,%esp
f0101c4d:	85 c0                	test   %eax,%eax
f0101c4f:	0f 85 5c 07 00 00    	jne    f01023b1 <mem_init+0x1022>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c55:	83 ec 04             	sub    $0x4,%esp
f0101c58:	6a 00                	push   $0x0
f0101c5a:	68 00 10 00 00       	push   $0x1000
f0101c5f:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101c65:	e8 aa f4 ff ff       	call   f0101114 <pgdir_walk>
f0101c6a:	83 c4 10             	add    $0x10,%esp
f0101c6d:	f6 00 04             	testb  $0x4,(%eax)
f0101c70:	0f 85 54 07 00 00    	jne    f01023ca <mem_init+0x103b>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101c76:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101c7b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101c7e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c83:	e8 c0 ef ff ff       	call   f0100c48 <check_va2pa>
f0101c88:	89 c1                	mov    %eax,%ecx
f0101c8a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101c8d:	89 d8                	mov    %ebx,%eax
f0101c8f:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0101c95:	c1 f8 03             	sar    $0x3,%eax
f0101c98:	c1 e0 0c             	shl    $0xc,%eax
f0101c9b:	39 c1                	cmp    %eax,%ecx
f0101c9d:	0f 85 40 07 00 00    	jne    f01023e3 <mem_init+0x1054>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ca3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ca8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cab:	e8 98 ef ff ff       	call   f0100c48 <check_va2pa>
f0101cb0:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101cb3:	0f 85 43 07 00 00    	jne    f01023fc <mem_init+0x106d>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101cb9:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101cbe:	0f 85 51 07 00 00    	jne    f0102415 <mem_init+0x1086>
	assert(pp2->pp_ref == 0);
f0101cc4:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101cc9:	0f 85 5f 07 00 00    	jne    f010242e <mem_init+0x109f>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101ccf:	83 ec 0c             	sub    $0xc,%esp
f0101cd2:	6a 00                	push   $0x0
f0101cd4:	e8 51 f3 ff ff       	call   f010102a <page_alloc>
f0101cd9:	83 c4 10             	add    $0x10,%esp
f0101cdc:	85 c0                	test   %eax,%eax
f0101cde:	0f 84 63 07 00 00    	je     f0102447 <mem_init+0x10b8>
f0101ce4:	39 c6                	cmp    %eax,%esi
f0101ce6:	0f 85 5b 07 00 00    	jne    f0102447 <mem_init+0x10b8>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101cec:	83 ec 08             	sub    $0x8,%esp
f0101cef:	6a 00                	push   $0x0
f0101cf1:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101cf7:	e8 e4 f5 ff ff       	call   f01012e0 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101cfc:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101d01:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101d04:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d09:	e8 3a ef ff ff       	call   f0100c48 <check_va2pa>
f0101d0e:	83 c4 10             	add    $0x10,%esp
f0101d11:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d14:	0f 85 46 07 00 00    	jne    f0102460 <mem_init+0x10d1>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d1a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d1f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d22:	e8 21 ef ff ff       	call   f0100c48 <check_va2pa>
f0101d27:	89 da                	mov    %ebx,%edx
f0101d29:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f0101d2f:	c1 fa 03             	sar    $0x3,%edx
f0101d32:	c1 e2 0c             	shl    $0xc,%edx
f0101d35:	39 d0                	cmp    %edx,%eax
f0101d37:	0f 85 3c 07 00 00    	jne    f0102479 <mem_init+0x10ea>
	assert(pp1->pp_ref == 1);
f0101d3d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d42:	0f 85 4a 07 00 00    	jne    f0102492 <mem_init+0x1103>
	assert(pp2->pp_ref == 0);
f0101d48:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d4d:	0f 85 58 07 00 00    	jne    f01024ab <mem_init+0x111c>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101d53:	6a 00                	push   $0x0
f0101d55:	68 00 10 00 00       	push   $0x1000
f0101d5a:	53                   	push   %ebx
f0101d5b:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101d5e:	e8 c5 f5 ff ff       	call   f0101328 <page_insert>
f0101d63:	83 c4 10             	add    $0x10,%esp
f0101d66:	85 c0                	test   %eax,%eax
f0101d68:	0f 85 56 07 00 00    	jne    f01024c4 <mem_init+0x1135>
	assert(pp1->pp_ref);
f0101d6e:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d73:	0f 84 64 07 00 00    	je     f01024dd <mem_init+0x114e>
	assert(pp1->pp_link == NULL);
f0101d79:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101d7c:	0f 85 74 07 00 00    	jne    f01024f6 <mem_init+0x1167>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101d82:	83 ec 08             	sub    $0x8,%esp
f0101d85:	68 00 10 00 00       	push   $0x1000
f0101d8a:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101d90:	e8 4b f5 ff ff       	call   f01012e0 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d95:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101d9a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101d9d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101da2:	e8 a1 ee ff ff       	call   f0100c48 <check_va2pa>
f0101da7:	83 c4 10             	add    $0x10,%esp
f0101daa:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101dad:	0f 85 5c 07 00 00    	jne    f010250f <mem_init+0x1180>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101db3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101db8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dbb:	e8 88 ee ff ff       	call   f0100c48 <check_va2pa>
f0101dc0:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101dc3:	0f 85 5f 07 00 00    	jne    f0102528 <mem_init+0x1199>
	assert(pp1->pp_ref == 0);
f0101dc9:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101dce:	0f 85 6d 07 00 00    	jne    f0102541 <mem_init+0x11b2>
	assert(pp2->pp_ref == 0);
f0101dd4:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101dd9:	0f 85 7b 07 00 00    	jne    f010255a <mem_init+0x11cb>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101ddf:	83 ec 0c             	sub    $0xc,%esp
f0101de2:	6a 00                	push   $0x0
f0101de4:	e8 41 f2 ff ff       	call   f010102a <page_alloc>
f0101de9:	83 c4 10             	add    $0x10,%esp
f0101dec:	85 c0                	test   %eax,%eax
f0101dee:	0f 84 7f 07 00 00    	je     f0102573 <mem_init+0x11e4>
f0101df4:	39 c3                	cmp    %eax,%ebx
f0101df6:	0f 85 77 07 00 00    	jne    f0102573 <mem_init+0x11e4>

	// should be no free memory
	assert(!page_alloc(0));
f0101dfc:	83 ec 0c             	sub    $0xc,%esp
f0101dff:	6a 00                	push   $0x0
f0101e01:	e8 24 f2 ff ff       	call   f010102a <page_alloc>
f0101e06:	83 c4 10             	add    $0x10,%esp
f0101e09:	85 c0                	test   %eax,%eax
f0101e0b:	0f 85 7b 07 00 00    	jne    f010258c <mem_init+0x11fd>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e11:	8b 0d 68 89 11 f0    	mov    0xf0118968,%ecx
f0101e17:	8b 11                	mov    (%ecx),%edx
f0101e19:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101e1f:	89 f8                	mov    %edi,%eax
f0101e21:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0101e27:	c1 f8 03             	sar    $0x3,%eax
f0101e2a:	c1 e0 0c             	shl    $0xc,%eax
f0101e2d:	39 c2                	cmp    %eax,%edx
f0101e2f:	0f 85 70 07 00 00    	jne    f01025a5 <mem_init+0x1216>
	kern_pgdir[0] = 0;
f0101e35:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101e3b:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101e40:	0f 85 78 07 00 00    	jne    f01025be <mem_init+0x122f>
	pp0->pp_ref = 0;
f0101e46:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101e4c:	83 ec 0c             	sub    $0xc,%esp
f0101e4f:	57                   	push   %edi
f0101e50:	e8 47 f2 ff ff       	call   f010109c <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101e55:	83 c4 0c             	add    $0xc,%esp
f0101e58:	6a 01                	push   $0x1
f0101e5a:	68 00 10 40 00       	push   $0x401000
f0101e5f:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101e65:	e8 aa f2 ff ff       	call   f0101114 <pgdir_walk>
f0101e6a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101e6d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101e70:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101e75:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101e78:	8b 50 04             	mov    0x4(%eax),%edx
f0101e7b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101e81:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0101e86:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101e89:	89 d1                	mov    %edx,%ecx
f0101e8b:	c1 e9 0c             	shr    $0xc,%ecx
f0101e8e:	83 c4 10             	add    $0x10,%esp
f0101e91:	39 c1                	cmp    %eax,%ecx
f0101e93:	0f 83 3e 07 00 00    	jae    f01025d7 <mem_init+0x1248>
	assert(ptep == ptep1 + PTX(va));
f0101e99:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0101e9f:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0101ea2:	0f 85 44 07 00 00    	jne    f01025ec <mem_init+0x125d>
	kern_pgdir[PDX(va)] = 0;
f0101ea8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101eab:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101eb2:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
	return (pp - pages) << PGSHIFT;
f0101eb8:	89 f8                	mov    %edi,%eax
f0101eba:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0101ec0:	c1 f8 03             	sar    $0x3,%eax
f0101ec3:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101ec6:	89 c2                	mov    %eax,%edx
f0101ec8:	c1 ea 0c             	shr    $0xc,%edx
f0101ecb:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f0101ece:	0f 86 31 07 00 00    	jbe    f0102605 <mem_init+0x1276>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101ed4:	83 ec 04             	sub    $0x4,%esp
f0101ed7:	68 00 10 00 00       	push   $0x1000
f0101edc:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101ee1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ee6:	50                   	push   %eax
f0101ee7:	e8 44 18 00 00       	call   f0103730 <memset>
	page_free(pp0);
f0101eec:	89 3c 24             	mov    %edi,(%esp)
f0101eef:	e8 a8 f1 ff ff       	call   f010109c <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101ef4:	83 c4 0c             	add    $0xc,%esp
f0101ef7:	6a 01                	push   $0x1
f0101ef9:	6a 00                	push   $0x0
f0101efb:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0101f01:	e8 0e f2 ff ff       	call   f0101114 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101f06:	89 fa                	mov    %edi,%edx
f0101f08:	2b 15 6c 89 11 f0    	sub    0xf011896c,%edx
f0101f0e:	c1 fa 03             	sar    $0x3,%edx
f0101f11:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101f14:	89 d0                	mov    %edx,%eax
f0101f16:	c1 e8 0c             	shr    $0xc,%eax
f0101f19:	83 c4 10             	add    $0x10,%esp
f0101f1c:	3b 05 64 89 11 f0    	cmp    0xf0118964,%eax
f0101f22:	0f 83 ef 06 00 00    	jae    f0102617 <mem_init+0x1288>
	return (void *)(pa + KERNBASE);
f0101f28:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101f2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101f31:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101f37:	f6 00 01             	testb  $0x1,(%eax)
f0101f3a:	0f 85 e9 06 00 00    	jne    f0102629 <mem_init+0x129a>
f0101f40:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0101f43:	39 c2                	cmp    %eax,%edx
f0101f45:	75 f0                	jne    f0101f37 <mem_init+0xba8>
	kern_pgdir[0] = 0;
f0101f47:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101f4c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101f52:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0101f58:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0101f5b:	a3 3c 85 11 f0       	mov    %eax,0xf011853c

	// free the pages we took
	page_free(pp0);
f0101f60:	83 ec 0c             	sub    $0xc,%esp
f0101f63:	57                   	push   %edi
f0101f64:	e8 33 f1 ff ff       	call   f010109c <page_free>
	page_free(pp1);
f0101f69:	89 1c 24             	mov    %ebx,(%esp)
f0101f6c:	e8 2b f1 ff ff       	call   f010109c <page_free>
	page_free(pp2);
f0101f71:	89 34 24             	mov    %esi,(%esp)
f0101f74:	e8 23 f1 ff ff       	call   f010109c <page_free>

	cprintf("check_page() succeeded!\n");
f0101f79:	c7 04 24 2d 4e 10 f0 	movl   $0xf0104e2d,(%esp)
f0101f80:	e8 7c 0c 00 00       	call   f0102c01 <cprintf>
	sz = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0101f85:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0101f8a:	8d 0c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ecx
f0101f91:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_region(kern_pgdir, UPAGES, sz, PADDR(pages), PTE_U | PTE_P);
f0101f97:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
	if ((uint32_t)kva < KERNBASE)
f0101f9c:	83 c4 10             	add    $0x10,%esp
f0101f9f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101fa4:	0f 86 98 06 00 00    	jbe    f0102642 <mem_init+0x12b3>
f0101faa:	83 ec 08             	sub    $0x8,%esp
f0101fad:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0101faf:	05 00 00 00 10       	add    $0x10000000,%eax
f0101fb4:	50                   	push   %eax
f0101fb5:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0101fba:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101fbf:	e8 67 f2 ff ff       	call   f010122b <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0101fc4:	83 c4 10             	add    $0x10,%esp
f0101fc7:	b8 00 e0 10 f0       	mov    $0xf010e000,%eax
f0101fcc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101fd1:	0f 86 80 06 00 00    	jbe    f0102657 <mem_init+0x12c8>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, 
f0101fd7:	83 ec 08             	sub    $0x8,%esp
f0101fda:	6a 03                	push   $0x3
f0101fdc:	68 00 e0 10 00       	push   $0x10e000
f0101fe1:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0101fe6:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0101feb:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101ff0:	e8 36 f2 ff ff       	call   f010122b <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 1 << 28, // 2^32 - 0xf0000000
f0101ff5:	83 c4 08             	add    $0x8,%esp
f0101ff8:	6a 03                	push   $0x3
f0101ffa:	6a 00                	push   $0x0
f0101ffc:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102001:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102006:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f010200b:	e8 1b f2 ff ff       	call   f010122b <boot_map_region>
	pgdir = kern_pgdir;
f0102010:	8b 1d 68 89 11 f0    	mov    0xf0118968,%ebx
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102016:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f010201b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010201e:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102025:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010202a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010202d:	a1 6c 89 11 f0       	mov    0xf011896c,%eax
f0102032:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102035:	89 45 d0             	mov    %eax,-0x30(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0102038:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f010203e:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i += PGSIZE) 
f0102041:	be 00 00 00 00       	mov    $0x0,%esi
f0102046:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0102049:	0f 86 4d 06 00 00    	jbe    f010269c <mem_init+0x130d>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010204f:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f0102055:	89 d8                	mov    %ebx,%eax
f0102057:	e8 ec eb ff ff       	call   f0100c48 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f010205c:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102063:	0f 86 03 06 00 00    	jbe    f010266c <mem_init+0x12dd>
f0102069:	8d 14 3e             	lea    (%esi,%edi,1),%edx
f010206c:	39 d0                	cmp    %edx,%eax
f010206e:	0f 85 0f 06 00 00    	jne    f0102683 <mem_init+0x12f4>
	for (i = 0; i < n; i += PGSIZE) 
f0102074:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010207a:	eb ca                	jmp    f0102046 <mem_init+0xcb7>
	assert(nfree == 0);
f010207c:	68 56 4d 10 f0       	push   $0xf0104d56
f0102081:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102086:	68 7c 02 00 00       	push   $0x27c
f010208b:	68 68 4b 10 f0       	push   $0xf0104b68
f0102090:	e8 9e e0 ff ff       	call   f0100133 <_panic>
	assert((pp0 = page_alloc(0)));
f0102095:	68 64 4c 10 f0       	push   $0xf0104c64
f010209a:	68 8e 4b 10 f0       	push   $0xf0104b8e
f010209f:	68 d6 02 00 00       	push   $0x2d6
f01020a4:	68 68 4b 10 f0       	push   $0xf0104b68
f01020a9:	e8 85 e0 ff ff       	call   f0100133 <_panic>
	assert((pp1 = page_alloc(0)));
f01020ae:	68 7a 4c 10 f0       	push   $0xf0104c7a
f01020b3:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01020b8:	68 d7 02 00 00       	push   $0x2d7
f01020bd:	68 68 4b 10 f0       	push   $0xf0104b68
f01020c2:	e8 6c e0 ff ff       	call   f0100133 <_panic>
	assert((pp2 = page_alloc(0)));
f01020c7:	68 90 4c 10 f0       	push   $0xf0104c90
f01020cc:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01020d1:	68 d8 02 00 00       	push   $0x2d8
f01020d6:	68 68 4b 10 f0       	push   $0xf0104b68
f01020db:	e8 53 e0 ff ff       	call   f0100133 <_panic>
	assert(pp1 && pp1 != pp0);
f01020e0:	68 a6 4c 10 f0       	push   $0xf0104ca6
f01020e5:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01020ea:	68 db 02 00 00       	push   $0x2db
f01020ef:	68 68 4b 10 f0       	push   $0xf0104b68
f01020f4:	e8 3a e0 ff ff       	call   f0100133 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01020f9:	68 7c 45 10 f0       	push   $0xf010457c
f01020fe:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102103:	68 dc 02 00 00       	push   $0x2dc
f0102108:	68 68 4b 10 f0       	push   $0xf0104b68
f010210d:	e8 21 e0 ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f0102112:	68 0f 4d 10 f0       	push   $0xf0104d0f
f0102117:	68 8e 4b 10 f0       	push   $0xf0104b8e
f010211c:	68 e3 02 00 00       	push   $0x2e3
f0102121:	68 68 4b 10 f0       	push   $0xf0104b68
f0102126:	e8 08 e0 ff ff       	call   f0100133 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010212b:	68 bc 45 10 f0       	push   $0xf01045bc
f0102130:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102135:	68 e6 02 00 00       	push   $0x2e6
f010213a:	68 68 4b 10 f0       	push   $0xf0104b68
f010213f:	e8 ef df ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102144:	68 f4 45 10 f0       	push   $0xf01045f4
f0102149:	68 8e 4b 10 f0       	push   $0xf0104b8e
f010214e:	68 e9 02 00 00       	push   $0x2e9
f0102153:	68 68 4b 10 f0       	push   $0xf0104b68
f0102158:	e8 d6 df ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010215d:	68 24 46 10 f0       	push   $0xf0104624
f0102162:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102167:	68 ed 02 00 00       	push   $0x2ed
f010216c:	68 68 4b 10 f0       	push   $0xf0104b68
f0102171:	e8 bd df ff ff       	call   f0100133 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102176:	68 54 46 10 f0       	push   $0xf0104654
f010217b:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102180:	68 ee 02 00 00       	push   $0x2ee
f0102185:	68 68 4b 10 f0       	push   $0xf0104b68
f010218a:	e8 a4 df ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010218f:	68 7c 46 10 f0       	push   $0xf010467c
f0102194:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102199:	68 ef 02 00 00       	push   $0x2ef
f010219e:	68 68 4b 10 f0       	push   $0xf0104b68
f01021a3:	e8 8b df ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 1);
f01021a8:	68 61 4d 10 f0       	push   $0xf0104d61
f01021ad:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01021b2:	68 f0 02 00 00       	push   $0x2f0
f01021b7:	68 68 4b 10 f0       	push   $0xf0104b68
f01021bc:	e8 72 df ff ff       	call   f0100133 <_panic>
	assert(pp0->pp_ref == 1);
f01021c1:	68 72 4d 10 f0       	push   $0xf0104d72
f01021c6:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01021cb:	68 f1 02 00 00       	push   $0x2f1
f01021d0:	68 68 4b 10 f0       	push   $0xf0104b68
f01021d5:	e8 59 df ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01021da:	68 ac 46 10 f0       	push   $0xf01046ac
f01021df:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01021e4:	68 f4 02 00 00       	push   $0x2f4
f01021e9:	68 68 4b 10 f0       	push   $0xf0104b68
f01021ee:	e8 40 df ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01021f3:	68 e8 46 10 f0       	push   $0xf01046e8
f01021f8:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01021fd:	68 f5 02 00 00       	push   $0x2f5
f0102202:	68 68 4b 10 f0       	push   $0xf0104b68
f0102207:	e8 27 df ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 1);
f010220c:	68 83 4d 10 f0       	push   $0xf0104d83
f0102211:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102216:	68 f6 02 00 00       	push   $0x2f6
f010221b:	68 68 4b 10 f0       	push   $0xf0104b68
f0102220:	e8 0e df ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f0102225:	68 0f 4d 10 f0       	push   $0xf0104d0f
f010222a:	68 8e 4b 10 f0       	push   $0xf0104b8e
f010222f:	68 f9 02 00 00       	push   $0x2f9
f0102234:	68 68 4b 10 f0       	push   $0xf0104b68
f0102239:	e8 f5 de ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010223e:	68 ac 46 10 f0       	push   $0xf01046ac
f0102243:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102248:	68 fc 02 00 00       	push   $0x2fc
f010224d:	68 68 4b 10 f0       	push   $0xf0104b68
f0102252:	e8 dc de ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102257:	68 e8 46 10 f0       	push   $0xf01046e8
f010225c:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102261:	68 fd 02 00 00       	push   $0x2fd
f0102266:	68 68 4b 10 f0       	push   $0xf0104b68
f010226b:	e8 c3 de ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 1);
f0102270:	68 83 4d 10 f0       	push   $0xf0104d83
f0102275:	68 8e 4b 10 f0       	push   $0xf0104b8e
f010227a:	68 fe 02 00 00       	push   $0x2fe
f010227f:	68 68 4b 10 f0       	push   $0xf0104b68
f0102284:	e8 aa de ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f0102289:	68 0f 4d 10 f0       	push   $0xf0104d0f
f010228e:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102293:	68 02 03 00 00       	push   $0x302
f0102298:	68 68 4b 10 f0       	push   $0xf0104b68
f010229d:	e8 91 de ff ff       	call   f0100133 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01022a2:	50                   	push   %eax
f01022a3:	68 f0 43 10 f0       	push   $0xf01043f0
f01022a8:	68 05 03 00 00       	push   $0x305
f01022ad:	68 68 4b 10 f0       	push   $0xf0104b68
f01022b2:	e8 7c de ff ff       	call   f0100133 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01022b7:	68 18 47 10 f0       	push   $0xf0104718
f01022bc:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01022c1:	68 06 03 00 00       	push   $0x306
f01022c6:	68 68 4b 10 f0       	push   $0xf0104b68
f01022cb:	e8 63 de ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01022d0:	68 58 47 10 f0       	push   $0xf0104758
f01022d5:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01022da:	68 09 03 00 00       	push   $0x309
f01022df:	68 68 4b 10 f0       	push   $0xf0104b68
f01022e4:	e8 4a de ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01022e9:	68 e8 46 10 f0       	push   $0xf01046e8
f01022ee:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01022f3:	68 0a 03 00 00       	push   $0x30a
f01022f8:	68 68 4b 10 f0       	push   $0xf0104b68
f01022fd:	e8 31 de ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 1);
f0102302:	68 83 4d 10 f0       	push   $0xf0104d83
f0102307:	68 8e 4b 10 f0       	push   $0xf0104b8e
f010230c:	68 0b 03 00 00       	push   $0x30b
f0102311:	68 68 4b 10 f0       	push   $0xf0104b68
f0102316:	e8 18 de ff ff       	call   f0100133 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010231b:	68 98 47 10 f0       	push   $0xf0104798
f0102320:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102325:	68 0c 03 00 00       	push   $0x30c
f010232a:	68 68 4b 10 f0       	push   $0xf0104b68
f010232f:	e8 ff dd ff ff       	call   f0100133 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102334:	68 94 4d 10 f0       	push   $0xf0104d94
f0102339:	68 8e 4b 10 f0       	push   $0xf0104b8e
f010233e:	68 0d 03 00 00       	push   $0x30d
f0102343:	68 68 4b 10 f0       	push   $0xf0104b68
f0102348:	e8 e6 dd ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010234d:	68 ac 46 10 f0       	push   $0xf01046ac
f0102352:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102357:	68 10 03 00 00       	push   $0x310
f010235c:	68 68 4b 10 f0       	push   $0xf0104b68
f0102361:	e8 cd dd ff ff       	call   f0100133 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102366:	68 cc 47 10 f0       	push   $0xf01047cc
f010236b:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102370:	68 11 03 00 00       	push   $0x311
f0102375:	68 68 4b 10 f0       	push   $0xf0104b68
f010237a:	e8 b4 dd ff ff       	call   f0100133 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010237f:	68 00 48 10 f0       	push   $0xf0104800
f0102384:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102389:	68 12 03 00 00       	push   $0x312
f010238e:	68 68 4b 10 f0       	push   $0xf0104b68
f0102393:	e8 9b dd ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102398:	68 38 48 10 f0       	push   $0xf0104838
f010239d:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01023a2:	68 15 03 00 00       	push   $0x315
f01023a7:	68 68 4b 10 f0       	push   $0xf0104b68
f01023ac:	e8 82 dd ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01023b1:	68 70 48 10 f0       	push   $0xf0104870
f01023b6:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01023bb:	68 18 03 00 00       	push   $0x318
f01023c0:	68 68 4b 10 f0       	push   $0xf0104b68
f01023c5:	e8 69 dd ff ff       	call   f0100133 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01023ca:	68 00 48 10 f0       	push   $0xf0104800
f01023cf:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01023d4:	68 19 03 00 00       	push   $0x319
f01023d9:	68 68 4b 10 f0       	push   $0xf0104b68
f01023de:	e8 50 dd ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01023e3:	68 ac 48 10 f0       	push   $0xf01048ac
f01023e8:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01023ed:	68 1c 03 00 00       	push   $0x31c
f01023f2:	68 68 4b 10 f0       	push   $0xf0104b68
f01023f7:	e8 37 dd ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01023fc:	68 d8 48 10 f0       	push   $0xf01048d8
f0102401:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102406:	68 1d 03 00 00       	push   $0x31d
f010240b:	68 68 4b 10 f0       	push   $0xf0104b68
f0102410:	e8 1e dd ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 2);
f0102415:	68 aa 4d 10 f0       	push   $0xf0104daa
f010241a:	68 8e 4b 10 f0       	push   $0xf0104b8e
f010241f:	68 1f 03 00 00       	push   $0x31f
f0102424:	68 68 4b 10 f0       	push   $0xf0104b68
f0102429:	e8 05 dd ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 0);
f010242e:	68 bb 4d 10 f0       	push   $0xf0104dbb
f0102433:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102438:	68 20 03 00 00       	push   $0x320
f010243d:	68 68 4b 10 f0       	push   $0xf0104b68
f0102442:	e8 ec dc ff ff       	call   f0100133 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102447:	68 08 49 10 f0       	push   $0xf0104908
f010244c:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102451:	68 23 03 00 00       	push   $0x323
f0102456:	68 68 4b 10 f0       	push   $0xf0104b68
f010245b:	e8 d3 dc ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102460:	68 2c 49 10 f0       	push   $0xf010492c
f0102465:	68 8e 4b 10 f0       	push   $0xf0104b8e
f010246a:	68 27 03 00 00       	push   $0x327
f010246f:	68 68 4b 10 f0       	push   $0xf0104b68
f0102474:	e8 ba dc ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102479:	68 d8 48 10 f0       	push   $0xf01048d8
f010247e:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102483:	68 28 03 00 00       	push   $0x328
f0102488:	68 68 4b 10 f0       	push   $0xf0104b68
f010248d:	e8 a1 dc ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 1);
f0102492:	68 61 4d 10 f0       	push   $0xf0104d61
f0102497:	68 8e 4b 10 f0       	push   $0xf0104b8e
f010249c:	68 29 03 00 00       	push   $0x329
f01024a1:	68 68 4b 10 f0       	push   $0xf0104b68
f01024a6:	e8 88 dc ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 0);
f01024ab:	68 bb 4d 10 f0       	push   $0xf0104dbb
f01024b0:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01024b5:	68 2a 03 00 00       	push   $0x32a
f01024ba:	68 68 4b 10 f0       	push   $0xf0104b68
f01024bf:	e8 6f dc ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01024c4:	68 50 49 10 f0       	push   $0xf0104950
f01024c9:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01024ce:	68 2d 03 00 00       	push   $0x32d
f01024d3:	68 68 4b 10 f0       	push   $0xf0104b68
f01024d8:	e8 56 dc ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref);
f01024dd:	68 cc 4d 10 f0       	push   $0xf0104dcc
f01024e2:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01024e7:	68 2e 03 00 00       	push   $0x32e
f01024ec:	68 68 4b 10 f0       	push   $0xf0104b68
f01024f1:	e8 3d dc ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_link == NULL);
f01024f6:	68 d8 4d 10 f0       	push   $0xf0104dd8
f01024fb:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102500:	68 2f 03 00 00       	push   $0x32f
f0102505:	68 68 4b 10 f0       	push   $0xf0104b68
f010250a:	e8 24 dc ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010250f:	68 2c 49 10 f0       	push   $0xf010492c
f0102514:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102519:	68 33 03 00 00       	push   $0x333
f010251e:	68 68 4b 10 f0       	push   $0xf0104b68
f0102523:	e8 0b dc ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102528:	68 88 49 10 f0       	push   $0xf0104988
f010252d:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102532:	68 34 03 00 00       	push   $0x334
f0102537:	68 68 4b 10 f0       	push   $0xf0104b68
f010253c:	e8 f2 db ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 0);
f0102541:	68 ed 4d 10 f0       	push   $0xf0104ded
f0102546:	68 8e 4b 10 f0       	push   $0xf0104b8e
f010254b:	68 35 03 00 00       	push   $0x335
f0102550:	68 68 4b 10 f0       	push   $0xf0104b68
f0102555:	e8 d9 db ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 0);
f010255a:	68 bb 4d 10 f0       	push   $0xf0104dbb
f010255f:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102564:	68 36 03 00 00       	push   $0x336
f0102569:	68 68 4b 10 f0       	push   $0xf0104b68
f010256e:	e8 c0 db ff ff       	call   f0100133 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102573:	68 b0 49 10 f0       	push   $0xf01049b0
f0102578:	68 8e 4b 10 f0       	push   $0xf0104b8e
f010257d:	68 39 03 00 00       	push   $0x339
f0102582:	68 68 4b 10 f0       	push   $0xf0104b68
f0102587:	e8 a7 db ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f010258c:	68 0f 4d 10 f0       	push   $0xf0104d0f
f0102591:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102596:	68 3c 03 00 00       	push   $0x33c
f010259b:	68 68 4b 10 f0       	push   $0xf0104b68
f01025a0:	e8 8e db ff ff       	call   f0100133 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01025a5:	68 54 46 10 f0       	push   $0xf0104654
f01025aa:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01025af:	68 3f 03 00 00       	push   $0x33f
f01025b4:	68 68 4b 10 f0       	push   $0xf0104b68
f01025b9:	e8 75 db ff ff       	call   f0100133 <_panic>
	assert(pp0->pp_ref == 1);
f01025be:	68 72 4d 10 f0       	push   $0xf0104d72
f01025c3:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01025c8:	68 41 03 00 00       	push   $0x341
f01025cd:	68 68 4b 10 f0       	push   $0xf0104b68
f01025d2:	e8 5c db ff ff       	call   f0100133 <_panic>
f01025d7:	52                   	push   %edx
f01025d8:	68 f0 43 10 f0       	push   $0xf01043f0
f01025dd:	68 48 03 00 00       	push   $0x348
f01025e2:	68 68 4b 10 f0       	push   $0xf0104b68
f01025e7:	e8 47 db ff ff       	call   f0100133 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01025ec:	68 fe 4d 10 f0       	push   $0xf0104dfe
f01025f1:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01025f6:	68 49 03 00 00       	push   $0x349
f01025fb:	68 68 4b 10 f0       	push   $0xf0104b68
f0102600:	e8 2e db ff ff       	call   f0100133 <_panic>
f0102605:	50                   	push   %eax
f0102606:	68 f0 43 10 f0       	push   $0xf01043f0
f010260b:	6a 52                	push   $0x52
f010260d:	68 74 4b 10 f0       	push   $0xf0104b74
f0102612:	e8 1c db ff ff       	call   f0100133 <_panic>
f0102617:	52                   	push   %edx
f0102618:	68 f0 43 10 f0       	push   $0xf01043f0
f010261d:	6a 52                	push   $0x52
f010261f:	68 74 4b 10 f0       	push   $0xf0104b74
f0102624:	e8 0a db ff ff       	call   f0100133 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102629:	68 16 4e 10 f0       	push   $0xf0104e16
f010262e:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102633:	68 53 03 00 00       	push   $0x353
f0102638:	68 68 4b 10 f0       	push   $0xf0104b68
f010263d:	e8 f1 da ff ff       	call   f0100133 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102642:	50                   	push   %eax
f0102643:	68 fc 44 10 f0       	push   $0xf01044fc
f0102648:	68 b5 00 00 00       	push   $0xb5
f010264d:	68 68 4b 10 f0       	push   $0xf0104b68
f0102652:	e8 dc da ff ff       	call   f0100133 <_panic>
f0102657:	50                   	push   %eax
f0102658:	68 fc 44 10 f0       	push   $0xf01044fc
f010265d:	68 c2 00 00 00       	push   $0xc2
f0102662:	68 68 4b 10 f0       	push   $0xf0104b68
f0102667:	e8 c7 da ff ff       	call   f0100133 <_panic>
f010266c:	ff 75 c8             	pushl  -0x38(%ebp)
f010266f:	68 fc 44 10 f0       	push   $0xf01044fc
f0102674:	68 94 02 00 00       	push   $0x294
f0102679:	68 68 4b 10 f0       	push   $0xf0104b68
f010267e:	e8 b0 da ff ff       	call   f0100133 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102683:	68 d4 49 10 f0       	push   $0xf01049d4
f0102688:	68 8e 4b 10 f0       	push   $0xf0104b8e
f010268d:	68 94 02 00 00       	push   $0x294
f0102692:	68 68 4b 10 f0       	push   $0xf0104b68
f0102697:	e8 97 da ff ff       	call   f0100133 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010269c:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010269f:	c1 e7 0c             	shl    $0xc,%edi
f01026a2:	be 00 00 00 00       	mov    $0x0,%esi
f01026a7:	eb 17                	jmp    f01026c0 <mem_init+0x1331>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01026a9:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f01026af:	89 d8                	mov    %ebx,%eax
f01026b1:	e8 92 e5 ff ff       	call   f0100c48 <check_va2pa>
f01026b6:	39 c6                	cmp    %eax,%esi
f01026b8:	75 50                	jne    f010270a <mem_init+0x137b>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01026ba:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01026c0:	39 fe                	cmp    %edi,%esi
f01026c2:	72 e5                	jb     f01026a9 <mem_init+0x131a>
f01026c4:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01026c9:	b8 00 e0 10 f0       	mov    $0xf010e000,%eax
f01026ce:	8d b8 00 80 00 20    	lea    0x20008000(%eax),%edi
f01026d4:	89 f2                	mov    %esi,%edx
f01026d6:	89 d8                	mov    %ebx,%eax
f01026d8:	e8 6b e5 ff ff       	call   f0100c48 <check_va2pa>
f01026dd:	8d 14 37             	lea    (%edi,%esi,1),%edx
f01026e0:	39 d0                	cmp    %edx,%eax
f01026e2:	75 3f                	jne    f0102723 <mem_init+0x1394>
f01026e4:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < KSTKSIZE; i += PGSIZE) {
f01026ea:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01026f0:	75 e2                	jne    f01026d4 <mem_init+0x1345>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01026f2:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01026f7:	89 d8                	mov    %ebx,%eax
f01026f9:	e8 4a e5 ff ff       	call   f0100c48 <check_va2pa>
f01026fe:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102701:	75 39                	jne    f010273c <mem_init+0x13ad>
	for (i = 0; i < NPDENTRIES; i++) {
f0102703:	b8 00 00 00 00       	mov    $0x0,%eax
f0102708:	eb 72                	jmp    f010277c <mem_init+0x13ed>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010270a:	68 08 4a 10 f0       	push   $0xf0104a08
f010270f:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102714:	68 99 02 00 00       	push   $0x299
f0102719:	68 68 4b 10 f0       	push   $0xf0104b68
f010271e:	e8 10 da ff ff       	call   f0100133 <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102723:	68 30 4a 10 f0       	push   $0xf0104a30
f0102728:	68 8e 4b 10 f0       	push   $0xf0104b8e
f010272d:	68 9d 02 00 00       	push   $0x29d
f0102732:	68 68 4b 10 f0       	push   $0xf0104b68
f0102737:	e8 f7 d9 ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010273c:	68 78 4a 10 f0       	push   $0xf0104a78
f0102741:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102746:	68 9f 02 00 00       	push   $0x29f
f010274b:	68 68 4b 10 f0       	push   $0xf0104b68
f0102750:	e8 de d9 ff ff       	call   f0100133 <_panic>
			assert(pgdir[i] & PTE_P);
f0102755:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102759:	74 47                	je     f01027a2 <mem_init+0x1413>
	for (i = 0; i < NPDENTRIES; i++) {
f010275b:	40                   	inc    %eax
f010275c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102761:	0f 87 93 00 00 00    	ja     f01027fa <mem_init+0x146b>
		switch (i) {
f0102767:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f010276c:	72 0e                	jb     f010277c <mem_init+0x13ed>
f010276e:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102773:	76 e0                	jbe    f0102755 <mem_init+0x13c6>
f0102775:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010277a:	74 d9                	je     f0102755 <mem_init+0x13c6>
			if (i >= PDX(KERNBASE)) {
f010277c:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102781:	77 38                	ja     f01027bb <mem_init+0x142c>
				assert(pgdir[i] == 0);
f0102783:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102787:	74 d2                	je     f010275b <mem_init+0x13cc>
f0102789:	68 68 4e 10 f0       	push   $0xf0104e68
f010278e:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102793:	68 ae 02 00 00       	push   $0x2ae
f0102798:	68 68 4b 10 f0       	push   $0xf0104b68
f010279d:	e8 91 d9 ff ff       	call   f0100133 <_panic>
			assert(pgdir[i] & PTE_P);
f01027a2:	68 46 4e 10 f0       	push   $0xf0104e46
f01027a7:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01027ac:	68 a7 02 00 00       	push   $0x2a7
f01027b1:	68 68 4b 10 f0       	push   $0xf0104b68
f01027b6:	e8 78 d9 ff ff       	call   f0100133 <_panic>
				assert(pgdir[i] & PTE_P);
f01027bb:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f01027be:	f6 c2 01             	test   $0x1,%dl
f01027c1:	74 1e                	je     f01027e1 <mem_init+0x1452>
				assert(pgdir[i] & PTE_W);
f01027c3:	f6 c2 02             	test   $0x2,%dl
f01027c6:	75 93                	jne    f010275b <mem_init+0x13cc>
f01027c8:	68 57 4e 10 f0       	push   $0xf0104e57
f01027cd:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01027d2:	68 ac 02 00 00       	push   $0x2ac
f01027d7:	68 68 4b 10 f0       	push   $0xf0104b68
f01027dc:	e8 52 d9 ff ff       	call   f0100133 <_panic>
				assert(pgdir[i] & PTE_P);
f01027e1:	68 46 4e 10 f0       	push   $0xf0104e46
f01027e6:	68 8e 4b 10 f0       	push   $0xf0104b8e
f01027eb:	68 ab 02 00 00       	push   $0x2ab
f01027f0:	68 68 4b 10 f0       	push   $0xf0104b68
f01027f5:	e8 39 d9 ff ff       	call   f0100133 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f01027fa:	83 ec 0c             	sub    $0xc,%esp
f01027fd:	68 a8 4a 10 f0       	push   $0xf0104aa8
f0102802:	e8 fa 03 00 00       	call   f0102c01 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102807:	a1 68 89 11 f0       	mov    0xf0118968,%eax
	if ((uint32_t)kva < KERNBASE)
f010280c:	83 c4 10             	add    $0x10,%esp
f010280f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102814:	0f 86 fe 01 00 00    	jbe    f0102a18 <mem_init+0x1689>
	return (physaddr_t)kva - KERNBASE;
f010281a:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010281f:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102822:	b8 00 00 00 00       	mov    $0x0,%eax
f0102827:	e8 7b e4 ff ff       	call   f0100ca7 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f010282c:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010282f:	83 e0 f3             	and    $0xfffffff3,%eax
f0102832:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102837:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010283a:	83 ec 0c             	sub    $0xc,%esp
f010283d:	6a 00                	push   $0x0
f010283f:	e8 e6 e7 ff ff       	call   f010102a <page_alloc>
f0102844:	89 c3                	mov    %eax,%ebx
f0102846:	83 c4 10             	add    $0x10,%esp
f0102849:	85 c0                	test   %eax,%eax
f010284b:	0f 84 dc 01 00 00    	je     f0102a2d <mem_init+0x169e>
	assert((pp1 = page_alloc(0)));
f0102851:	83 ec 0c             	sub    $0xc,%esp
f0102854:	6a 00                	push   $0x0
f0102856:	e8 cf e7 ff ff       	call   f010102a <page_alloc>
f010285b:	89 c7                	mov    %eax,%edi
f010285d:	83 c4 10             	add    $0x10,%esp
f0102860:	85 c0                	test   %eax,%eax
f0102862:	0f 84 de 01 00 00    	je     f0102a46 <mem_init+0x16b7>
	assert((pp2 = page_alloc(0)));
f0102868:	83 ec 0c             	sub    $0xc,%esp
f010286b:	6a 00                	push   $0x0
f010286d:	e8 b8 e7 ff ff       	call   f010102a <page_alloc>
f0102872:	89 c6                	mov    %eax,%esi
f0102874:	83 c4 10             	add    $0x10,%esp
f0102877:	85 c0                	test   %eax,%eax
f0102879:	0f 84 e0 01 00 00    	je     f0102a5f <mem_init+0x16d0>
	page_free(pp0);
f010287f:	83 ec 0c             	sub    $0xc,%esp
f0102882:	53                   	push   %ebx
f0102883:	e8 14 e8 ff ff       	call   f010109c <page_free>
	return (pp - pages) << PGSHIFT;
f0102888:	89 f8                	mov    %edi,%eax
f010288a:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0102890:	c1 f8 03             	sar    $0x3,%eax
f0102893:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102896:	89 c2                	mov    %eax,%edx
f0102898:	c1 ea 0c             	shr    $0xc,%edx
f010289b:	83 c4 10             	add    $0x10,%esp
f010289e:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f01028a4:	0f 83 ce 01 00 00    	jae    f0102a78 <mem_init+0x16e9>
	memset(page2kva(pp1), 1, PGSIZE);
f01028aa:	83 ec 04             	sub    $0x4,%esp
f01028ad:	68 00 10 00 00       	push   $0x1000
f01028b2:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01028b4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01028b9:	50                   	push   %eax
f01028ba:	e8 71 0e 00 00       	call   f0103730 <memset>
	return (pp - pages) << PGSHIFT;
f01028bf:	89 f0                	mov    %esi,%eax
f01028c1:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f01028c7:	c1 f8 03             	sar    $0x3,%eax
f01028ca:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01028cd:	89 c2                	mov    %eax,%edx
f01028cf:	c1 ea 0c             	shr    $0xc,%edx
f01028d2:	83 c4 10             	add    $0x10,%esp
f01028d5:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f01028db:	0f 83 a9 01 00 00    	jae    f0102a8a <mem_init+0x16fb>
	memset(page2kva(pp2), 2, PGSIZE);
f01028e1:	83 ec 04             	sub    $0x4,%esp
f01028e4:	68 00 10 00 00       	push   $0x1000
f01028e9:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f01028eb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01028f0:	50                   	push   %eax
f01028f1:	e8 3a 0e 00 00       	call   f0103730 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01028f6:	6a 02                	push   $0x2
f01028f8:	68 00 10 00 00       	push   $0x1000
f01028fd:	57                   	push   %edi
f01028fe:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0102904:	e8 1f ea ff ff       	call   f0101328 <page_insert>
	assert(pp1->pp_ref == 1);
f0102909:	83 c4 20             	add    $0x20,%esp
f010290c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102911:	0f 85 85 01 00 00    	jne    f0102a9c <mem_init+0x170d>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102917:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f010291e:	01 01 01 
f0102921:	0f 85 8e 01 00 00    	jne    f0102ab5 <mem_init+0x1726>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102927:	6a 02                	push   $0x2
f0102929:	68 00 10 00 00       	push   $0x1000
f010292e:	56                   	push   %esi
f010292f:	ff 35 68 89 11 f0    	pushl  0xf0118968
f0102935:	e8 ee e9 ff ff       	call   f0101328 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010293a:	83 c4 10             	add    $0x10,%esp
f010293d:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102944:	02 02 02 
f0102947:	0f 85 81 01 00 00    	jne    f0102ace <mem_init+0x173f>
	assert(pp2->pp_ref == 1);
f010294d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102952:	0f 85 8f 01 00 00    	jne    f0102ae7 <mem_init+0x1758>
	assert(pp1->pp_ref == 0);
f0102958:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010295d:	0f 85 9d 01 00 00    	jne    f0102b00 <mem_init+0x1771>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102963:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010296a:	03 03 03 
	return (pp - pages) << PGSHIFT;
f010296d:	89 f0                	mov    %esi,%eax
f010296f:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f0102975:	c1 f8 03             	sar    $0x3,%eax
f0102978:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010297b:	89 c2                	mov    %eax,%edx
f010297d:	c1 ea 0c             	shr    $0xc,%edx
f0102980:	3b 15 64 89 11 f0    	cmp    0xf0118964,%edx
f0102986:	0f 83 8d 01 00 00    	jae    f0102b19 <mem_init+0x178a>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010298c:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102993:	03 03 03 
f0102996:	0f 85 8f 01 00 00    	jne    f0102b2b <mem_init+0x179c>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010299c:	83 ec 08             	sub    $0x8,%esp
f010299f:	68 00 10 00 00       	push   $0x1000
f01029a4:	ff 35 68 89 11 f0    	pushl  0xf0118968
f01029aa:	e8 31 e9 ff ff       	call   f01012e0 <page_remove>
	assert(pp2->pp_ref == 0);
f01029af:	83 c4 10             	add    $0x10,%esp
f01029b2:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01029b7:	0f 85 87 01 00 00    	jne    f0102b44 <mem_init+0x17b5>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01029bd:	8b 0d 68 89 11 f0    	mov    0xf0118968,%ecx
f01029c3:	8b 11                	mov    (%ecx),%edx
f01029c5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f01029cb:	89 d8                	mov    %ebx,%eax
f01029cd:	2b 05 6c 89 11 f0    	sub    0xf011896c,%eax
f01029d3:	c1 f8 03             	sar    $0x3,%eax
f01029d6:	c1 e0 0c             	shl    $0xc,%eax
f01029d9:	39 c2                	cmp    %eax,%edx
f01029db:	0f 85 7c 01 00 00    	jne    f0102b5d <mem_init+0x17ce>
	kern_pgdir[0] = 0;
f01029e1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01029e7:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01029ec:	0f 85 84 01 00 00    	jne    f0102b76 <mem_init+0x17e7>
	pp0->pp_ref = 0;
f01029f2:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f01029f8:	83 ec 0c             	sub    $0xc,%esp
f01029fb:	53                   	push   %ebx
f01029fc:	e8 9b e6 ff ff       	call   f010109c <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102a01:	c7 04 24 3c 4b 10 f0 	movl   $0xf0104b3c,(%esp)
f0102a08:	e8 f4 01 00 00       	call   f0102c01 <cprintf>
}
f0102a0d:	83 c4 10             	add    $0x10,%esp
f0102a10:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102a13:	5b                   	pop    %ebx
f0102a14:	5e                   	pop    %esi
f0102a15:	5f                   	pop    %edi
f0102a16:	5d                   	pop    %ebp
f0102a17:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a18:	50                   	push   %eax
f0102a19:	68 fc 44 10 f0       	push   $0xf01044fc
f0102a1e:	68 d8 00 00 00       	push   $0xd8
f0102a23:	68 68 4b 10 f0       	push   $0xf0104b68
f0102a28:	e8 06 d7 ff ff       	call   f0100133 <_panic>
	assert((pp0 = page_alloc(0)));
f0102a2d:	68 64 4c 10 f0       	push   $0xf0104c64
f0102a32:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102a37:	68 6e 03 00 00       	push   $0x36e
f0102a3c:	68 68 4b 10 f0       	push   $0xf0104b68
f0102a41:	e8 ed d6 ff ff       	call   f0100133 <_panic>
	assert((pp1 = page_alloc(0)));
f0102a46:	68 7a 4c 10 f0       	push   $0xf0104c7a
f0102a4b:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102a50:	68 6f 03 00 00       	push   $0x36f
f0102a55:	68 68 4b 10 f0       	push   $0xf0104b68
f0102a5a:	e8 d4 d6 ff ff       	call   f0100133 <_panic>
	assert((pp2 = page_alloc(0)));
f0102a5f:	68 90 4c 10 f0       	push   $0xf0104c90
f0102a64:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102a69:	68 70 03 00 00       	push   $0x370
f0102a6e:	68 68 4b 10 f0       	push   $0xf0104b68
f0102a73:	e8 bb d6 ff ff       	call   f0100133 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a78:	50                   	push   %eax
f0102a79:	68 f0 43 10 f0       	push   $0xf01043f0
f0102a7e:	6a 52                	push   $0x52
f0102a80:	68 74 4b 10 f0       	push   $0xf0104b74
f0102a85:	e8 a9 d6 ff ff       	call   f0100133 <_panic>
f0102a8a:	50                   	push   %eax
f0102a8b:	68 f0 43 10 f0       	push   $0xf01043f0
f0102a90:	6a 52                	push   $0x52
f0102a92:	68 74 4b 10 f0       	push   $0xf0104b74
f0102a97:	e8 97 d6 ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 1);
f0102a9c:	68 61 4d 10 f0       	push   $0xf0104d61
f0102aa1:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102aa6:	68 75 03 00 00       	push   $0x375
f0102aab:	68 68 4b 10 f0       	push   $0xf0104b68
f0102ab0:	e8 7e d6 ff ff       	call   f0100133 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102ab5:	68 c8 4a 10 f0       	push   $0xf0104ac8
f0102aba:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102abf:	68 76 03 00 00       	push   $0x376
f0102ac4:	68 68 4b 10 f0       	push   $0xf0104b68
f0102ac9:	e8 65 d6 ff ff       	call   f0100133 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102ace:	68 ec 4a 10 f0       	push   $0xf0104aec
f0102ad3:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102ad8:	68 78 03 00 00       	push   $0x378
f0102add:	68 68 4b 10 f0       	push   $0xf0104b68
f0102ae2:	e8 4c d6 ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 1);
f0102ae7:	68 83 4d 10 f0       	push   $0xf0104d83
f0102aec:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102af1:	68 79 03 00 00       	push   $0x379
f0102af6:	68 68 4b 10 f0       	push   $0xf0104b68
f0102afb:	e8 33 d6 ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 0);
f0102b00:	68 ed 4d 10 f0       	push   $0xf0104ded
f0102b05:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102b0a:	68 7a 03 00 00       	push   $0x37a
f0102b0f:	68 68 4b 10 f0       	push   $0xf0104b68
f0102b14:	e8 1a d6 ff ff       	call   f0100133 <_panic>
f0102b19:	50                   	push   %eax
f0102b1a:	68 f0 43 10 f0       	push   $0xf01043f0
f0102b1f:	6a 52                	push   $0x52
f0102b21:	68 74 4b 10 f0       	push   $0xf0104b74
f0102b26:	e8 08 d6 ff ff       	call   f0100133 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102b2b:	68 10 4b 10 f0       	push   $0xf0104b10
f0102b30:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102b35:	68 7c 03 00 00       	push   $0x37c
f0102b3a:	68 68 4b 10 f0       	push   $0xf0104b68
f0102b3f:	e8 ef d5 ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 0);
f0102b44:	68 bb 4d 10 f0       	push   $0xf0104dbb
f0102b49:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102b4e:	68 7e 03 00 00       	push   $0x37e
f0102b53:	68 68 4b 10 f0       	push   $0xf0104b68
f0102b58:	e8 d6 d5 ff ff       	call   f0100133 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102b5d:	68 54 46 10 f0       	push   $0xf0104654
f0102b62:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102b67:	68 81 03 00 00       	push   $0x381
f0102b6c:	68 68 4b 10 f0       	push   $0xf0104b68
f0102b71:	e8 bd d5 ff ff       	call   f0100133 <_panic>
	assert(pp0->pp_ref == 1);
f0102b76:	68 72 4d 10 f0       	push   $0xf0104d72
f0102b7b:	68 8e 4b 10 f0       	push   $0xf0104b8e
f0102b80:	68 83 03 00 00       	push   $0x383
f0102b85:	68 68 4b 10 f0       	push   $0xf0104b68
f0102b8a:	e8 a4 d5 ff ff       	call   f0100133 <_panic>

f0102b8f <tlb_invalidate>:
{
f0102b8f:	55                   	push   %ebp
f0102b90:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102b92:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102b95:	0f 01 38             	invlpg (%eax)
}
f0102b98:	5d                   	pop    %ebp
f0102b99:	c3                   	ret    

f0102b9a <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102b9a:	55                   	push   %ebp
f0102b9b:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102b9d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ba0:	ba 70 00 00 00       	mov    $0x70,%edx
f0102ba5:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102ba6:	ba 71 00 00 00       	mov    $0x71,%edx
f0102bab:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102bac:	0f b6 c0             	movzbl %al,%eax
}
f0102baf:	5d                   	pop    %ebp
f0102bb0:	c3                   	ret    

f0102bb1 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102bb1:	55                   	push   %ebp
f0102bb2:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102bb4:	8b 45 08             	mov    0x8(%ebp),%eax
f0102bb7:	ba 70 00 00 00       	mov    $0x70,%edx
f0102bbc:	ee                   	out    %al,(%dx)
f0102bbd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102bc0:	ba 71 00 00 00       	mov    $0x71,%edx
f0102bc5:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102bc6:	5d                   	pop    %ebp
f0102bc7:	c3                   	ret    

f0102bc8 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102bc8:	55                   	push   %ebp
f0102bc9:	89 e5                	mov    %esp,%ebp
f0102bcb:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102bce:	ff 75 08             	pushl  0x8(%ebp)
f0102bd1:	e8 b0 da ff ff       	call   f0100686 <cputchar>
	*cnt++;
}
f0102bd6:	83 c4 10             	add    $0x10,%esp
f0102bd9:	c9                   	leave  
f0102bda:	c3                   	ret    

f0102bdb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102bdb:	55                   	push   %ebp
f0102bdc:	89 e5                	mov    %esp,%ebp
f0102bde:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102be1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102be8:	ff 75 0c             	pushl  0xc(%ebp)
f0102beb:	ff 75 08             	pushl  0x8(%ebp)
f0102bee:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102bf1:	50                   	push   %eax
f0102bf2:	68 c8 2b 10 f0       	push   $0xf0102bc8
f0102bf7:	e8 1b 04 00 00       	call   f0103017 <vprintfmt>
	return cnt;
}
f0102bfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102bff:	c9                   	leave  
f0102c00:	c3                   	ret    

f0102c01 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102c01:	55                   	push   %ebp
f0102c02:	89 e5                	mov    %esp,%ebp
f0102c04:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102c07:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102c0a:	50                   	push   %eax
f0102c0b:	ff 75 08             	pushl  0x8(%ebp)
f0102c0e:	e8 c8 ff ff ff       	call   f0102bdb <vcprintf>
	va_end(ap);

	return cnt;
}
f0102c13:	c9                   	leave  
f0102c14:	c3                   	ret    

f0102c15 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102c15:	55                   	push   %ebp
f0102c16:	89 e5                	mov    %esp,%ebp
f0102c18:	57                   	push   %edi
f0102c19:	56                   	push   %esi
f0102c1a:	53                   	push   %ebx
f0102c1b:	83 ec 14             	sub    $0x14,%esp
f0102c1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102c21:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0102c24:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102c27:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102c2a:	8b 32                	mov    (%edx),%esi
f0102c2c:	8b 01                	mov    (%ecx),%eax
f0102c2e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102c31:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0102c38:	eb 2f                	jmp    f0102c69 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0102c3a:	48                   	dec    %eax
		while (m >= l && stabs[m].n_type != type)
f0102c3b:	39 c6                	cmp    %eax,%esi
f0102c3d:	7f 4d                	jg     f0102c8c <stab_binsearch+0x77>
f0102c3f:	0f b6 0a             	movzbl (%edx),%ecx
f0102c42:	83 ea 0c             	sub    $0xc,%edx
f0102c45:	39 f9                	cmp    %edi,%ecx
f0102c47:	75 f1                	jne    f0102c3a <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102c49:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0102c4c:	01 c2                	add    %eax,%edx
f0102c4e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102c51:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0102c55:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102c58:	73 37                	jae    f0102c91 <stab_binsearch+0x7c>
			*region_left = m;
f0102c5a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102c5d:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0102c5f:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0102c62:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0102c69:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0102c6c:	7f 4d                	jg     f0102cbb <stab_binsearch+0xa6>
		int true_m = (l + r) / 2, m = true_m;
f0102c6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102c71:	01 f0                	add    %esi,%eax
f0102c73:	89 c3                	mov    %eax,%ebx
f0102c75:	c1 eb 1f             	shr    $0x1f,%ebx
f0102c78:	01 c3                	add    %eax,%ebx
f0102c7a:	d1 fb                	sar    %ebx
f0102c7c:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0102c7f:	01 d8                	add    %ebx,%eax
f0102c81:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102c84:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0102c88:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0102c8a:	eb af                	jmp    f0102c3b <stab_binsearch+0x26>
			l = true_m + 1;
f0102c8c:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0102c8f:	eb d8                	jmp    f0102c69 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0102c91:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102c94:	76 12                	jbe    f0102ca8 <stab_binsearch+0x93>
			*region_right = m - 1;
f0102c96:	48                   	dec    %eax
f0102c97:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102c9a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102c9d:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0102c9f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102ca6:	eb c1                	jmp    f0102c69 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102ca8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102cab:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0102cad:	ff 45 0c             	incl   0xc(%ebp)
f0102cb0:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0102cb2:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102cb9:	eb ae                	jmp    f0102c69 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0102cbb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102cbf:	74 18                	je     f0102cd9 <stab_binsearch+0xc4>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102cc1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102cc4:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102cc6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102cc9:	8b 0e                	mov    (%esi),%ecx
f0102ccb:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0102cce:	01 c2                	add    %eax,%edx
f0102cd0:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0102cd3:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0102cd7:	eb 0e                	jmp    f0102ce7 <stab_binsearch+0xd2>
		*region_right = *region_left - 1;
f0102cd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102cdc:	8b 00                	mov    (%eax),%eax
f0102cde:	48                   	dec    %eax
f0102cdf:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0102ce2:	89 07                	mov    %eax,(%edi)
f0102ce4:	eb 14                	jmp    f0102cfa <stab_binsearch+0xe5>
		     l--)
f0102ce6:	48                   	dec    %eax
		for (l = *region_right;
f0102ce7:	39 c1                	cmp    %eax,%ecx
f0102ce9:	7d 0a                	jge    f0102cf5 <stab_binsearch+0xe0>
		     l > *region_left && stabs[l].n_type != type;
f0102ceb:	0f b6 1a             	movzbl (%edx),%ebx
f0102cee:	83 ea 0c             	sub    $0xc,%edx
f0102cf1:	39 fb                	cmp    %edi,%ebx
f0102cf3:	75 f1                	jne    f0102ce6 <stab_binsearch+0xd1>
			/* do nothing */;
		*region_left = l;
f0102cf5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102cf8:	89 07                	mov    %eax,(%edi)
	}
}
f0102cfa:	83 c4 14             	add    $0x14,%esp
f0102cfd:	5b                   	pop    %ebx
f0102cfe:	5e                   	pop    %esi
f0102cff:	5f                   	pop    %edi
f0102d00:	5d                   	pop    %ebp
f0102d01:	c3                   	ret    

f0102d02 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102d02:	55                   	push   %ebp
f0102d03:	89 e5                	mov    %esp,%ebp
f0102d05:	57                   	push   %edi
f0102d06:	56                   	push   %esi
f0102d07:	53                   	push   %ebx
f0102d08:	83 ec 3c             	sub    $0x3c,%esp
f0102d0b:	8b 75 08             	mov    0x8(%ebp),%esi
f0102d0e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102d11:	c7 03 76 4e 10 f0    	movl   $0xf0104e76,(%ebx)
	info->eip_line = 0;
f0102d17:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102d1e:	c7 43 08 76 4e 10 f0 	movl   $0xf0104e76,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102d25:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102d2c:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102d2f:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102d36:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102d3c:	0f 86 31 01 00 00    	jbe    f0102e73 <debuginfo_eip+0x171>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102d42:	b8 69 de 10 f0       	mov    $0xf010de69,%eax
f0102d47:	3d 71 bf 10 f0       	cmp    $0xf010bf71,%eax
f0102d4c:	0f 86 b6 01 00 00    	jbe    f0102f08 <debuginfo_eip+0x206>
f0102d52:	80 3d 68 de 10 f0 00 	cmpb   $0x0,0xf010de68
f0102d59:	0f 85 b0 01 00 00    	jne    f0102f0f <debuginfo_eip+0x20d>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102d5f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102d66:	ba 70 bf 10 f0       	mov    $0xf010bf70,%edx
f0102d6b:	81 ea ac 50 10 f0    	sub    $0xf01050ac,%edx
f0102d71:	c1 fa 02             	sar    $0x2,%edx
f0102d74:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0102d77:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0102d7a:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0102d7d:	89 c1                	mov    %eax,%ecx
f0102d7f:	c1 e1 08             	shl    $0x8,%ecx
f0102d82:	01 c8                	add    %ecx,%eax
f0102d84:	89 c1                	mov    %eax,%ecx
f0102d86:	c1 e1 10             	shl    $0x10,%ecx
f0102d89:	01 c8                	add    %ecx,%eax
f0102d8b:	01 c0                	add    %eax,%eax
f0102d8d:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
f0102d91:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102d94:	83 ec 08             	sub    $0x8,%esp
f0102d97:	56                   	push   %esi
f0102d98:	6a 64                	push   $0x64
f0102d9a:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102d9d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102da0:	b8 ac 50 10 f0       	mov    $0xf01050ac,%eax
f0102da5:	e8 6b fe ff ff       	call   f0102c15 <stab_binsearch>
	if (lfile == 0)
f0102daa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102dad:	83 c4 10             	add    $0x10,%esp
f0102db0:	85 c0                	test   %eax,%eax
f0102db2:	0f 84 5e 01 00 00    	je     f0102f16 <debuginfo_eip+0x214>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102db8:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0102dbb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102dbe:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102dc1:	83 ec 08             	sub    $0x8,%esp
f0102dc4:	56                   	push   %esi
f0102dc5:	6a 24                	push   $0x24
f0102dc7:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102dca:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102dcd:	b8 ac 50 10 f0       	mov    $0xf01050ac,%eax
f0102dd2:	e8 3e fe ff ff       	call   f0102c15 <stab_binsearch>

	if (lfun <= rfun) {
f0102dd7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102dda:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102ddd:	83 c4 10             	add    $0x10,%esp
f0102de0:	39 d0                	cmp    %edx,%eax
f0102de2:	0f 8f 9f 00 00 00    	jg     f0102e87 <debuginfo_eip+0x185>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102de8:	8d 0c 00             	lea    (%eax,%eax,1),%ecx
f0102deb:	01 c1                	add    %eax,%ecx
f0102ded:	c1 e1 02             	shl    $0x2,%ecx
f0102df0:	8d b9 ac 50 10 f0    	lea    -0xfefaf54(%ecx),%edi
f0102df6:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0102df9:	8b 89 ac 50 10 f0    	mov    -0xfefaf54(%ecx),%ecx
f0102dff:	bf 69 de 10 f0       	mov    $0xf010de69,%edi
f0102e04:	81 ef 71 bf 10 f0    	sub    $0xf010bf71,%edi
f0102e0a:	39 f9                	cmp    %edi,%ecx
f0102e0c:	73 09                	jae    f0102e17 <debuginfo_eip+0x115>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102e0e:	81 c1 71 bf 10 f0    	add    $0xf010bf71,%ecx
f0102e14:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102e17:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0102e1a:	8b 4f 08             	mov    0x8(%edi),%ecx
f0102e1d:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102e20:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0102e22:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0102e25:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102e28:	83 ec 08             	sub    $0x8,%esp
f0102e2b:	6a 3a                	push   $0x3a
f0102e2d:	ff 73 08             	pushl  0x8(%ebx)
f0102e30:	e8 e3 08 00 00       	call   f0103718 <strfind>
f0102e35:	2b 43 08             	sub    0x8(%ebx),%eax
f0102e38:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// N_SLINE represents text segment
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0102e3b:	83 c4 08             	add    $0x8,%esp
f0102e3e:	56                   	push   %esi
f0102e3f:	6a 44                	push   $0x44
f0102e41:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0102e44:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0102e47:	b8 ac 50 10 f0       	mov    $0xf01050ac,%eax
f0102e4c:	e8 c4 fd ff ff       	call   f0102c15 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0102e51:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102e54:	8d 04 12             	lea    (%edx,%edx,1),%eax
f0102e57:	01 d0                	add    %edx,%eax
f0102e59:	c1 e0 02             	shl    $0x2,%eax
f0102e5c:	0f b7 88 b2 50 10 f0 	movzwl -0xfefaf4e(%eax),%ecx
f0102e63:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102e66:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102e69:	05 b0 50 10 f0       	add    $0xf01050b0,%eax
f0102e6e:	83 c4 10             	add    $0x10,%esp
f0102e71:	eb 29                	jmp    f0102e9c <debuginfo_eip+0x19a>
  	        panic("User address");
f0102e73:	83 ec 04             	sub    $0x4,%esp
f0102e76:	68 80 4e 10 f0       	push   $0xf0104e80
f0102e7b:	6a 7f                	push   $0x7f
f0102e7d:	68 8d 4e 10 f0       	push   $0xf0104e8d
f0102e82:	e8 ac d2 ff ff       	call   f0100133 <_panic>
		info->eip_fn_addr = addr;
f0102e87:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102e8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102e8d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0102e90:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102e93:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102e96:	eb 90                	jmp    f0102e28 <debuginfo_eip+0x126>
f0102e98:	4a                   	dec    %edx
f0102e99:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0102e9c:	39 d6                	cmp    %edx,%esi
f0102e9e:	7f 34                	jg     f0102ed4 <debuginfo_eip+0x1d2>
	       && stabs[lline].n_type != N_SOL
f0102ea0:	8a 08                	mov    (%eax),%cl
f0102ea2:	80 f9 84             	cmp    $0x84,%cl
f0102ea5:	74 0b                	je     f0102eb2 <debuginfo_eip+0x1b0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102ea7:	80 f9 64             	cmp    $0x64,%cl
f0102eaa:	75 ec                	jne    f0102e98 <debuginfo_eip+0x196>
f0102eac:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0102eb0:	74 e6                	je     f0102e98 <debuginfo_eip+0x196>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102eb2:	8d 04 12             	lea    (%edx,%edx,1),%eax
f0102eb5:	01 c2                	add    %eax,%edx
f0102eb7:	8b 14 95 ac 50 10 f0 	mov    -0xfefaf54(,%edx,4),%edx
f0102ebe:	b8 69 de 10 f0       	mov    $0xf010de69,%eax
f0102ec3:	2d 71 bf 10 f0       	sub    $0xf010bf71,%eax
f0102ec8:	39 c2                	cmp    %eax,%edx
f0102eca:	73 08                	jae    f0102ed4 <debuginfo_eip+0x1d2>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102ecc:	81 c2 71 bf 10 f0    	add    $0xf010bf71,%edx
f0102ed2:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102ed4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102ed7:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0102eda:	39 f2                	cmp    %esi,%edx
f0102edc:	7d 3f                	jge    f0102f1d <debuginfo_eip+0x21b>
		for (lline = lfun + 1;
f0102ede:	42                   	inc    %edx
f0102edf:	89 d0                	mov    %edx,%eax
f0102ee1:	8d 0c 12             	lea    (%edx,%edx,1),%ecx
f0102ee4:	01 ca                	add    %ecx,%edx
f0102ee6:	8d 14 95 b0 50 10 f0 	lea    -0xfefaf50(,%edx,4),%edx
f0102eed:	eb 03                	jmp    f0102ef2 <debuginfo_eip+0x1f0>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0102eef:	ff 43 14             	incl   0x14(%ebx)
		for (lline = lfun + 1;
f0102ef2:	39 c6                	cmp    %eax,%esi
f0102ef4:	7e 34                	jle    f0102f2a <debuginfo_eip+0x228>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102ef6:	8a 0a                	mov    (%edx),%cl
f0102ef8:	40                   	inc    %eax
f0102ef9:	83 c2 0c             	add    $0xc,%edx
f0102efc:	80 f9 a0             	cmp    $0xa0,%cl
f0102eff:	74 ee                	je     f0102eef <debuginfo_eip+0x1ed>

	return 0;
f0102f01:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f06:	eb 1a                	jmp    f0102f22 <debuginfo_eip+0x220>
		return -1;
f0102f08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102f0d:	eb 13                	jmp    f0102f22 <debuginfo_eip+0x220>
f0102f0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102f14:	eb 0c                	jmp    f0102f22 <debuginfo_eip+0x220>
		return -1;
f0102f16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102f1b:	eb 05                	jmp    f0102f22 <debuginfo_eip+0x220>
	return 0;
f0102f1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102f22:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f25:	5b                   	pop    %ebx
f0102f26:	5e                   	pop    %esi
f0102f27:	5f                   	pop    %edi
f0102f28:	5d                   	pop    %ebp
f0102f29:	c3                   	ret    
	return 0;
f0102f2a:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f2f:	eb f1                	jmp    f0102f22 <debuginfo_eip+0x220>

f0102f31 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102f31:	55                   	push   %ebp
f0102f32:	89 e5                	mov    %esp,%ebp
f0102f34:	57                   	push   %edi
f0102f35:	56                   	push   %esi
f0102f36:	53                   	push   %ebx
f0102f37:	83 ec 1c             	sub    $0x1c,%esp
f0102f3a:	89 c7                	mov    %eax,%edi
f0102f3c:	89 d6                	mov    %edx,%esi
f0102f3e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f41:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102f44:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102f47:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102f4a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0102f4d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102f52:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102f55:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0102f58:	39 d3                	cmp    %edx,%ebx
f0102f5a:	72 05                	jb     f0102f61 <printnum+0x30>
f0102f5c:	39 45 10             	cmp    %eax,0x10(%ebp)
f0102f5f:	77 78                	ja     f0102fd9 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102f61:	83 ec 0c             	sub    $0xc,%esp
f0102f64:	ff 75 18             	pushl  0x18(%ebp)
f0102f67:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f6a:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0102f6d:	53                   	push   %ebx
f0102f6e:	ff 75 10             	pushl  0x10(%ebp)
f0102f71:	83 ec 08             	sub    $0x8,%esp
f0102f74:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102f77:	ff 75 e0             	pushl  -0x20(%ebp)
f0102f7a:	ff 75 dc             	pushl  -0x24(%ebp)
f0102f7d:	ff 75 d8             	pushl  -0x28(%ebp)
f0102f80:	e8 5b 0a 00 00       	call   f01039e0 <__udivdi3>
f0102f85:	83 c4 18             	add    $0x18,%esp
f0102f88:	52                   	push   %edx
f0102f89:	50                   	push   %eax
f0102f8a:	89 f2                	mov    %esi,%edx
f0102f8c:	89 f8                	mov    %edi,%eax
f0102f8e:	e8 9e ff ff ff       	call   f0102f31 <printnum>
f0102f93:	83 c4 20             	add    $0x20,%esp
f0102f96:	eb 11                	jmp    f0102fa9 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102f98:	83 ec 08             	sub    $0x8,%esp
f0102f9b:	56                   	push   %esi
f0102f9c:	ff 75 18             	pushl  0x18(%ebp)
f0102f9f:	ff d7                	call   *%edi
f0102fa1:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0102fa4:	4b                   	dec    %ebx
f0102fa5:	85 db                	test   %ebx,%ebx
f0102fa7:	7f ef                	jg     f0102f98 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102fa9:	83 ec 08             	sub    $0x8,%esp
f0102fac:	56                   	push   %esi
f0102fad:	83 ec 04             	sub    $0x4,%esp
f0102fb0:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102fb3:	ff 75 e0             	pushl  -0x20(%ebp)
f0102fb6:	ff 75 dc             	pushl  -0x24(%ebp)
f0102fb9:	ff 75 d8             	pushl  -0x28(%ebp)
f0102fbc:	e8 1f 0b 00 00       	call   f0103ae0 <__umoddi3>
f0102fc1:	83 c4 14             	add    $0x14,%esp
f0102fc4:	0f be 80 9b 4e 10 f0 	movsbl -0xfefb165(%eax),%eax
f0102fcb:	50                   	push   %eax
f0102fcc:	ff d7                	call   *%edi
}
f0102fce:	83 c4 10             	add    $0x10,%esp
f0102fd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102fd4:	5b                   	pop    %ebx
f0102fd5:	5e                   	pop    %esi
f0102fd6:	5f                   	pop    %edi
f0102fd7:	5d                   	pop    %ebp
f0102fd8:	c3                   	ret    
f0102fd9:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0102fdc:	eb c6                	jmp    f0102fa4 <printnum+0x73>

f0102fde <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102fde:	55                   	push   %ebp
f0102fdf:	89 e5                	mov    %esp,%ebp
f0102fe1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102fe4:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0102fe7:	8b 10                	mov    (%eax),%edx
f0102fe9:	3b 50 04             	cmp    0x4(%eax),%edx
f0102fec:	73 0a                	jae    f0102ff8 <sprintputch+0x1a>
		*b->buf++ = ch;
f0102fee:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102ff1:	89 08                	mov    %ecx,(%eax)
f0102ff3:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ff6:	88 02                	mov    %al,(%edx)
}
f0102ff8:	5d                   	pop    %ebp
f0102ff9:	c3                   	ret    

f0102ffa <printfmt>:
{
f0102ffa:	55                   	push   %ebp
f0102ffb:	89 e5                	mov    %esp,%ebp
f0102ffd:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0103000:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103003:	50                   	push   %eax
f0103004:	ff 75 10             	pushl  0x10(%ebp)
f0103007:	ff 75 0c             	pushl  0xc(%ebp)
f010300a:	ff 75 08             	pushl  0x8(%ebp)
f010300d:	e8 05 00 00 00       	call   f0103017 <vprintfmt>
}
f0103012:	83 c4 10             	add    $0x10,%esp
f0103015:	c9                   	leave  
f0103016:	c3                   	ret    

f0103017 <vprintfmt>:
{
f0103017:	55                   	push   %ebp
f0103018:	89 e5                	mov    %esp,%ebp
f010301a:	57                   	push   %edi
f010301b:	56                   	push   %esi
f010301c:	53                   	push   %ebx
f010301d:	83 ec 2c             	sub    $0x2c,%esp
f0103020:	8b 75 08             	mov    0x8(%ebp),%esi
f0103023:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103026:	8b 7d 10             	mov    0x10(%ebp),%edi
f0103029:	e9 ac 03 00 00       	jmp    f01033da <vprintfmt+0x3c3>
		padc = ' ';
f010302e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0103032:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0103039:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f0103040:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0103047:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f010304c:	8d 47 01             	lea    0x1(%edi),%eax
f010304f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103052:	8a 17                	mov    (%edi),%dl
f0103054:	8d 42 dd             	lea    -0x23(%edx),%eax
f0103057:	3c 55                	cmp    $0x55,%al
f0103059:	0f 87 fc 03 00 00    	ja     f010345b <vprintfmt+0x444>
f010305f:	0f b6 c0             	movzbl %al,%eax
f0103062:	ff 24 85 28 4f 10 f0 	jmp    *-0xfefb0d8(,%eax,4)
f0103069:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f010306c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0103070:	eb da                	jmp    f010304c <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0103072:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0103075:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0103079:	eb d1                	jmp    f010304c <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f010307b:	0f b6 d2             	movzbl %dl,%edx
f010307e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0103081:	b8 00 00 00 00       	mov    $0x0,%eax
f0103086:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0103089:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010308c:	01 c0                	add    %eax,%eax
f010308e:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
f0103092:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0103095:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0103098:	83 f9 09             	cmp    $0x9,%ecx
f010309b:	77 52                	ja     f01030ef <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
f010309d:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
f010309e:	eb e9                	jmp    f0103089 <vprintfmt+0x72>
			precision = va_arg(ap, int);
f01030a0:	8b 45 14             	mov    0x14(%ebp),%eax
f01030a3:	8b 00                	mov    (%eax),%eax
f01030a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01030a8:	8b 45 14             	mov    0x14(%ebp),%eax
f01030ab:	8d 40 04             	lea    0x4(%eax),%eax
f01030ae:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01030b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f01030b4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01030b8:	79 92                	jns    f010304c <vprintfmt+0x35>
				width = precision, precision = -1;
f01030ba:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01030bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01030c0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01030c7:	eb 83                	jmp    f010304c <vprintfmt+0x35>
f01030c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01030cd:	78 08                	js     f01030d7 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
f01030cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01030d2:	e9 75 ff ff ff       	jmp    f010304c <vprintfmt+0x35>
f01030d7:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01030de:	eb ef                	jmp    f01030cf <vprintfmt+0xb8>
f01030e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f01030e3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01030ea:	e9 5d ff ff ff       	jmp    f010304c <vprintfmt+0x35>
f01030ef:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01030f2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01030f5:	eb bd                	jmp    f01030b4 <vprintfmt+0x9d>
			lflag++;
f01030f7:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
f01030f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01030fb:	e9 4c ff ff ff       	jmp    f010304c <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f0103100:	8b 45 14             	mov    0x14(%ebp),%eax
f0103103:	8d 78 04             	lea    0x4(%eax),%edi
f0103106:	83 ec 08             	sub    $0x8,%esp
f0103109:	53                   	push   %ebx
f010310a:	ff 30                	pushl  (%eax)
f010310c:	ff d6                	call   *%esi
			break;
f010310e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0103111:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0103114:	e9 be 02 00 00       	jmp    f01033d7 <vprintfmt+0x3c0>
			err = va_arg(ap, int);
f0103119:	8b 45 14             	mov    0x14(%ebp),%eax
f010311c:	8d 78 04             	lea    0x4(%eax),%edi
f010311f:	8b 00                	mov    (%eax),%eax
f0103121:	85 c0                	test   %eax,%eax
f0103123:	78 2a                	js     f010314f <vprintfmt+0x138>
f0103125:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103127:	83 f8 06             	cmp    $0x6,%eax
f010312a:	7f 27                	jg     f0103153 <vprintfmt+0x13c>
f010312c:	8b 04 85 80 50 10 f0 	mov    -0xfefaf80(,%eax,4),%eax
f0103133:	85 c0                	test   %eax,%eax
f0103135:	74 1c                	je     f0103153 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
f0103137:	50                   	push   %eax
f0103138:	68 a0 4b 10 f0       	push   $0xf0104ba0
f010313d:	53                   	push   %ebx
f010313e:	56                   	push   %esi
f010313f:	e8 b6 fe ff ff       	call   f0102ffa <printfmt>
f0103144:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103147:	89 7d 14             	mov    %edi,0x14(%ebp)
f010314a:	e9 88 02 00 00       	jmp    f01033d7 <vprintfmt+0x3c0>
f010314f:	f7 d8                	neg    %eax
f0103151:	eb d2                	jmp    f0103125 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
f0103153:	52                   	push   %edx
f0103154:	68 b3 4e 10 f0       	push   $0xf0104eb3
f0103159:	53                   	push   %ebx
f010315a:	56                   	push   %esi
f010315b:	e8 9a fe ff ff       	call   f0102ffa <printfmt>
f0103160:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103163:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0103166:	e9 6c 02 00 00       	jmp    f01033d7 <vprintfmt+0x3c0>
			if ((p = va_arg(ap, char *)) == NULL)
f010316b:	8b 45 14             	mov    0x14(%ebp),%eax
f010316e:	83 c0 04             	add    $0x4,%eax
f0103171:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0103174:	8b 45 14             	mov    0x14(%ebp),%eax
f0103177:	8b 38                	mov    (%eax),%edi
f0103179:	85 ff                	test   %edi,%edi
f010317b:	74 18                	je     f0103195 <vprintfmt+0x17e>
			if (width > 0 && padc != '-')
f010317d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103181:	0f 8e b7 00 00 00    	jle    f010323e <vprintfmt+0x227>
f0103187:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010318b:	75 0f                	jne    f010319c <vprintfmt+0x185>
f010318d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103190:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103193:	eb 6e                	jmp    f0103203 <vprintfmt+0x1ec>
				p = "(null)";
f0103195:	bf ac 4e 10 f0       	mov    $0xf0104eac,%edi
f010319a:	eb e1                	jmp    f010317d <vprintfmt+0x166>
				for (width -= strnlen(p, precision); width > 0; width--)
f010319c:	83 ec 08             	sub    $0x8,%esp
f010319f:	ff 75 d0             	pushl  -0x30(%ebp)
f01031a2:	57                   	push   %edi
f01031a3:	e8 45 04 00 00       	call   f01035ed <strnlen>
f01031a8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01031ab:	29 c1                	sub    %eax,%ecx
f01031ad:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f01031b0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f01031b3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01031b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01031ba:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01031bd:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f01031bf:	eb 0d                	jmp    f01031ce <vprintfmt+0x1b7>
					putch(padc, putdat);
f01031c1:	83 ec 08             	sub    $0x8,%esp
f01031c4:	53                   	push   %ebx
f01031c5:	ff 75 e0             	pushl  -0x20(%ebp)
f01031c8:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f01031ca:	4f                   	dec    %edi
f01031cb:	83 c4 10             	add    $0x10,%esp
f01031ce:	85 ff                	test   %edi,%edi
f01031d0:	7f ef                	jg     f01031c1 <vprintfmt+0x1aa>
f01031d2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01031d5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01031d8:	89 c8                	mov    %ecx,%eax
f01031da:	85 c9                	test   %ecx,%ecx
f01031dc:	78 59                	js     f0103237 <vprintfmt+0x220>
f01031de:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01031e1:	29 c1                	sub    %eax,%ecx
f01031e3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01031e6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01031e9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01031ec:	eb 15                	jmp    f0103203 <vprintfmt+0x1ec>
				if (altflag && (ch < ' ' || ch > '~'))
f01031ee:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01031f2:	75 29                	jne    f010321d <vprintfmt+0x206>
					putch(ch, putdat);
f01031f4:	83 ec 08             	sub    $0x8,%esp
f01031f7:	ff 75 0c             	pushl  0xc(%ebp)
f01031fa:	50                   	push   %eax
f01031fb:	ff d6                	call   *%esi
f01031fd:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103200:	ff 4d e0             	decl   -0x20(%ebp)
f0103203:	47                   	inc    %edi
f0103204:	8a 57 ff             	mov    -0x1(%edi),%dl
f0103207:	0f be c2             	movsbl %dl,%eax
f010320a:	85 c0                	test   %eax,%eax
f010320c:	74 53                	je     f0103261 <vprintfmt+0x24a>
f010320e:	85 db                	test   %ebx,%ebx
f0103210:	78 dc                	js     f01031ee <vprintfmt+0x1d7>
f0103212:	4b                   	dec    %ebx
f0103213:	79 d9                	jns    f01031ee <vprintfmt+0x1d7>
f0103215:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103218:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010321b:	eb 35                	jmp    f0103252 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
f010321d:	0f be d2             	movsbl %dl,%edx
f0103220:	83 ea 20             	sub    $0x20,%edx
f0103223:	83 fa 5e             	cmp    $0x5e,%edx
f0103226:	76 cc                	jbe    f01031f4 <vprintfmt+0x1dd>
					putch('?', putdat);
f0103228:	83 ec 08             	sub    $0x8,%esp
f010322b:	ff 75 0c             	pushl  0xc(%ebp)
f010322e:	6a 3f                	push   $0x3f
f0103230:	ff d6                	call   *%esi
f0103232:	83 c4 10             	add    $0x10,%esp
f0103235:	eb c9                	jmp    f0103200 <vprintfmt+0x1e9>
f0103237:	b8 00 00 00 00       	mov    $0x0,%eax
f010323c:	eb a0                	jmp    f01031de <vprintfmt+0x1c7>
f010323e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103241:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103244:	eb bd                	jmp    f0103203 <vprintfmt+0x1ec>
				putch(' ', putdat);
f0103246:	83 ec 08             	sub    $0x8,%esp
f0103249:	53                   	push   %ebx
f010324a:	6a 20                	push   $0x20
f010324c:	ff d6                	call   *%esi
			for (; width > 0; width--)
f010324e:	4f                   	dec    %edi
f010324f:	83 c4 10             	add    $0x10,%esp
f0103252:	85 ff                	test   %edi,%edi
f0103254:	7f f0                	jg     f0103246 <vprintfmt+0x22f>
			if ((p = va_arg(ap, char *)) == NULL)
f0103256:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103259:	89 45 14             	mov    %eax,0x14(%ebp)
f010325c:	e9 76 01 00 00       	jmp    f01033d7 <vprintfmt+0x3c0>
f0103261:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103264:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103267:	eb e9                	jmp    f0103252 <vprintfmt+0x23b>
	if (lflag >= 2)
f0103269:	83 f9 01             	cmp    $0x1,%ecx
f010326c:	7e 3f                	jle    f01032ad <vprintfmt+0x296>
		return va_arg(*ap, long long);
f010326e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103271:	8b 50 04             	mov    0x4(%eax),%edx
f0103274:	8b 00                	mov    (%eax),%eax
f0103276:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103279:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010327c:	8b 45 14             	mov    0x14(%ebp),%eax
f010327f:	8d 40 08             	lea    0x8(%eax),%eax
f0103282:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0103285:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0103289:	79 5c                	jns    f01032e7 <vprintfmt+0x2d0>
				putch('-', putdat);
f010328b:	83 ec 08             	sub    $0x8,%esp
f010328e:	53                   	push   %ebx
f010328f:	6a 2d                	push   $0x2d
f0103291:	ff d6                	call   *%esi
				num = -(long long) num;
f0103293:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103296:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103299:	f7 da                	neg    %edx
f010329b:	83 d1 00             	adc    $0x0,%ecx
f010329e:	f7 d9                	neg    %ecx
f01032a0:	83 c4 10             	add    $0x10,%esp
			base = 10;
f01032a3:	b8 0a 00 00 00       	mov    $0xa,%eax
f01032a8:	e9 10 01 00 00       	jmp    f01033bd <vprintfmt+0x3a6>
	else if (lflag)
f01032ad:	85 c9                	test   %ecx,%ecx
f01032af:	75 1b                	jne    f01032cc <vprintfmt+0x2b5>
		return va_arg(*ap, int);
f01032b1:	8b 45 14             	mov    0x14(%ebp),%eax
f01032b4:	8b 00                	mov    (%eax),%eax
f01032b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01032b9:	89 c1                	mov    %eax,%ecx
f01032bb:	c1 f9 1f             	sar    $0x1f,%ecx
f01032be:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01032c1:	8b 45 14             	mov    0x14(%ebp),%eax
f01032c4:	8d 40 04             	lea    0x4(%eax),%eax
f01032c7:	89 45 14             	mov    %eax,0x14(%ebp)
f01032ca:	eb b9                	jmp    f0103285 <vprintfmt+0x26e>
		return va_arg(*ap, long);
f01032cc:	8b 45 14             	mov    0x14(%ebp),%eax
f01032cf:	8b 00                	mov    (%eax),%eax
f01032d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01032d4:	89 c1                	mov    %eax,%ecx
f01032d6:	c1 f9 1f             	sar    $0x1f,%ecx
f01032d9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01032dc:	8b 45 14             	mov    0x14(%ebp),%eax
f01032df:	8d 40 04             	lea    0x4(%eax),%eax
f01032e2:	89 45 14             	mov    %eax,0x14(%ebp)
f01032e5:	eb 9e                	jmp    f0103285 <vprintfmt+0x26e>
			num = getint(&ap, lflag);
f01032e7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01032ea:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01032ed:	b8 0a 00 00 00       	mov    $0xa,%eax
f01032f2:	e9 c6 00 00 00       	jmp    f01033bd <vprintfmt+0x3a6>
	if (lflag >= 2)
f01032f7:	83 f9 01             	cmp    $0x1,%ecx
f01032fa:	7e 18                	jle    f0103314 <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
f01032fc:	8b 45 14             	mov    0x14(%ebp),%eax
f01032ff:	8b 10                	mov    (%eax),%edx
f0103301:	8b 48 04             	mov    0x4(%eax),%ecx
f0103304:	8d 40 08             	lea    0x8(%eax),%eax
f0103307:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010330a:	b8 0a 00 00 00       	mov    $0xa,%eax
f010330f:	e9 a9 00 00 00       	jmp    f01033bd <vprintfmt+0x3a6>
	else if (lflag)
f0103314:	85 c9                	test   %ecx,%ecx
f0103316:	75 1a                	jne    f0103332 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned int);
f0103318:	8b 45 14             	mov    0x14(%ebp),%eax
f010331b:	8b 10                	mov    (%eax),%edx
f010331d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103322:	8d 40 04             	lea    0x4(%eax),%eax
f0103325:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103328:	b8 0a 00 00 00       	mov    $0xa,%eax
f010332d:	e9 8b 00 00 00       	jmp    f01033bd <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0103332:	8b 45 14             	mov    0x14(%ebp),%eax
f0103335:	8b 10                	mov    (%eax),%edx
f0103337:	b9 00 00 00 00       	mov    $0x0,%ecx
f010333c:	8d 40 04             	lea    0x4(%eax),%eax
f010333f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103342:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103347:	eb 74                	jmp    f01033bd <vprintfmt+0x3a6>
	if (lflag >= 2)
f0103349:	83 f9 01             	cmp    $0x1,%ecx
f010334c:	7e 15                	jle    f0103363 <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
f010334e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103351:	8b 10                	mov    (%eax),%edx
f0103353:	8b 48 04             	mov    0x4(%eax),%ecx
f0103356:	8d 40 08             	lea    0x8(%eax),%eax
f0103359:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010335c:	b8 08 00 00 00       	mov    $0x8,%eax
f0103361:	eb 5a                	jmp    f01033bd <vprintfmt+0x3a6>
	else if (lflag)
f0103363:	85 c9                	test   %ecx,%ecx
f0103365:	75 17                	jne    f010337e <vprintfmt+0x367>
		return va_arg(*ap, unsigned int);
f0103367:	8b 45 14             	mov    0x14(%ebp),%eax
f010336a:	8b 10                	mov    (%eax),%edx
f010336c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103371:	8d 40 04             	lea    0x4(%eax),%eax
f0103374:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0103377:	b8 08 00 00 00       	mov    $0x8,%eax
f010337c:	eb 3f                	jmp    f01033bd <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f010337e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103381:	8b 10                	mov    (%eax),%edx
f0103383:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103388:	8d 40 04             	lea    0x4(%eax),%eax
f010338b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010338e:	b8 08 00 00 00       	mov    $0x8,%eax
f0103393:	eb 28                	jmp    f01033bd <vprintfmt+0x3a6>
			putch('0', putdat);
f0103395:	83 ec 08             	sub    $0x8,%esp
f0103398:	53                   	push   %ebx
f0103399:	6a 30                	push   $0x30
f010339b:	ff d6                	call   *%esi
			putch('x', putdat);
f010339d:	83 c4 08             	add    $0x8,%esp
f01033a0:	53                   	push   %ebx
f01033a1:	6a 78                	push   $0x78
f01033a3:	ff d6                	call   *%esi
			num = (unsigned long long)
f01033a5:	8b 45 14             	mov    0x14(%ebp),%eax
f01033a8:	8b 10                	mov    (%eax),%edx
f01033aa:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01033af:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01033b2:	8d 40 04             	lea    0x4(%eax),%eax
f01033b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01033b8:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01033bd:	83 ec 0c             	sub    $0xc,%esp
f01033c0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01033c4:	57                   	push   %edi
f01033c5:	ff 75 e0             	pushl  -0x20(%ebp)
f01033c8:	50                   	push   %eax
f01033c9:	51                   	push   %ecx
f01033ca:	52                   	push   %edx
f01033cb:	89 da                	mov    %ebx,%edx
f01033cd:	89 f0                	mov    %esi,%eax
f01033cf:	e8 5d fb ff ff       	call   f0102f31 <printnum>
			break;
f01033d4:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f01033d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01033da:	47                   	inc    %edi
f01033db:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01033df:	83 f8 25             	cmp    $0x25,%eax
f01033e2:	0f 84 46 fc ff ff    	je     f010302e <vprintfmt+0x17>
			if (ch == '\0')
f01033e8:	85 c0                	test   %eax,%eax
f01033ea:	0f 84 89 00 00 00    	je     f0103479 <vprintfmt+0x462>
			putch(ch, putdat);
f01033f0:	83 ec 08             	sub    $0x8,%esp
f01033f3:	53                   	push   %ebx
f01033f4:	50                   	push   %eax
f01033f5:	ff d6                	call   *%esi
f01033f7:	83 c4 10             	add    $0x10,%esp
f01033fa:	eb de                	jmp    f01033da <vprintfmt+0x3c3>
	if (lflag >= 2)
f01033fc:	83 f9 01             	cmp    $0x1,%ecx
f01033ff:	7e 15                	jle    f0103416 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
f0103401:	8b 45 14             	mov    0x14(%ebp),%eax
f0103404:	8b 10                	mov    (%eax),%edx
f0103406:	8b 48 04             	mov    0x4(%eax),%ecx
f0103409:	8d 40 08             	lea    0x8(%eax),%eax
f010340c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010340f:	b8 10 00 00 00       	mov    $0x10,%eax
f0103414:	eb a7                	jmp    f01033bd <vprintfmt+0x3a6>
	else if (lflag)
f0103416:	85 c9                	test   %ecx,%ecx
f0103418:	75 17                	jne    f0103431 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned int);
f010341a:	8b 45 14             	mov    0x14(%ebp),%eax
f010341d:	8b 10                	mov    (%eax),%edx
f010341f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103424:	8d 40 04             	lea    0x4(%eax),%eax
f0103427:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010342a:	b8 10 00 00 00       	mov    $0x10,%eax
f010342f:	eb 8c                	jmp    f01033bd <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0103431:	8b 45 14             	mov    0x14(%ebp),%eax
f0103434:	8b 10                	mov    (%eax),%edx
f0103436:	b9 00 00 00 00       	mov    $0x0,%ecx
f010343b:	8d 40 04             	lea    0x4(%eax),%eax
f010343e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103441:	b8 10 00 00 00       	mov    $0x10,%eax
f0103446:	e9 72 ff ff ff       	jmp    f01033bd <vprintfmt+0x3a6>
			putch(ch, putdat);
f010344b:	83 ec 08             	sub    $0x8,%esp
f010344e:	53                   	push   %ebx
f010344f:	6a 25                	push   $0x25
f0103451:	ff d6                	call   *%esi
			break;
f0103453:	83 c4 10             	add    $0x10,%esp
f0103456:	e9 7c ff ff ff       	jmp    f01033d7 <vprintfmt+0x3c0>
			putch('%', putdat);
f010345b:	83 ec 08             	sub    $0x8,%esp
f010345e:	53                   	push   %ebx
f010345f:	6a 25                	push   $0x25
f0103461:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103463:	83 c4 10             	add    $0x10,%esp
f0103466:	89 f8                	mov    %edi,%eax
f0103468:	eb 01                	jmp    f010346b <vprintfmt+0x454>
f010346a:	48                   	dec    %eax
f010346b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010346f:	75 f9                	jne    f010346a <vprintfmt+0x453>
f0103471:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103474:	e9 5e ff ff ff       	jmp    f01033d7 <vprintfmt+0x3c0>
}
f0103479:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010347c:	5b                   	pop    %ebx
f010347d:	5e                   	pop    %esi
f010347e:	5f                   	pop    %edi
f010347f:	5d                   	pop    %ebp
f0103480:	c3                   	ret    

f0103481 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103481:	55                   	push   %ebp
f0103482:	89 e5                	mov    %esp,%ebp
f0103484:	83 ec 18             	sub    $0x18,%esp
f0103487:	8b 45 08             	mov    0x8(%ebp),%eax
f010348a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010348d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103490:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103494:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103497:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010349e:	85 c0                	test   %eax,%eax
f01034a0:	74 26                	je     f01034c8 <vsnprintf+0x47>
f01034a2:	85 d2                	test   %edx,%edx
f01034a4:	7e 29                	jle    f01034cf <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01034a6:	ff 75 14             	pushl  0x14(%ebp)
f01034a9:	ff 75 10             	pushl  0x10(%ebp)
f01034ac:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01034af:	50                   	push   %eax
f01034b0:	68 de 2f 10 f0       	push   $0xf0102fde
f01034b5:	e8 5d fb ff ff       	call   f0103017 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01034ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01034bd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01034c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01034c3:	83 c4 10             	add    $0x10,%esp
}
f01034c6:	c9                   	leave  
f01034c7:	c3                   	ret    
		return -E_INVAL;
f01034c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01034cd:	eb f7                	jmp    f01034c6 <vsnprintf+0x45>
f01034cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01034d4:	eb f0                	jmp    f01034c6 <vsnprintf+0x45>

f01034d6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01034d6:	55                   	push   %ebp
f01034d7:	89 e5                	mov    %esp,%ebp
f01034d9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01034dc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01034df:	50                   	push   %eax
f01034e0:	ff 75 10             	pushl  0x10(%ebp)
f01034e3:	ff 75 0c             	pushl  0xc(%ebp)
f01034e6:	ff 75 08             	pushl  0x8(%ebp)
f01034e9:	e8 93 ff ff ff       	call   f0103481 <vsnprintf>
	va_end(ap);

	return rc;
}
f01034ee:	c9                   	leave  
f01034ef:	c3                   	ret    

f01034f0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01034f0:	55                   	push   %ebp
f01034f1:	89 e5                	mov    %esp,%ebp
f01034f3:	57                   	push   %edi
f01034f4:	56                   	push   %esi
f01034f5:	53                   	push   %ebx
f01034f6:	83 ec 0c             	sub    $0xc,%esp
f01034f9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01034fc:	85 c0                	test   %eax,%eax
f01034fe:	74 11                	je     f0103511 <readline+0x21>
		cprintf("%s", prompt);
f0103500:	83 ec 08             	sub    $0x8,%esp
f0103503:	50                   	push   %eax
f0103504:	68 a0 4b 10 f0       	push   $0xf0104ba0
f0103509:	e8 f3 f6 ff ff       	call   f0102c01 <cprintf>
f010350e:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103511:	83 ec 0c             	sub    $0xc,%esp
f0103514:	6a 00                	push   $0x0
f0103516:	e8 8c d1 ff ff       	call   f01006a7 <iscons>
f010351b:	89 c7                	mov    %eax,%edi
f010351d:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0103520:	be 00 00 00 00       	mov    $0x0,%esi
f0103525:	eb 6f                	jmp    f0103596 <readline+0xa6>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0103527:	83 ec 08             	sub    $0x8,%esp
f010352a:	50                   	push   %eax
f010352b:	68 9c 50 10 f0       	push   $0xf010509c
f0103530:	e8 cc f6 ff ff       	call   f0102c01 <cprintf>
			return NULL;
f0103535:	83 c4 10             	add    $0x10,%esp
f0103538:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f010353d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103540:	5b                   	pop    %ebx
f0103541:	5e                   	pop    %esi
f0103542:	5f                   	pop    %edi
f0103543:	5d                   	pop    %ebp
f0103544:	c3                   	ret    
				cputchar('\b');
f0103545:	83 ec 0c             	sub    $0xc,%esp
f0103548:	6a 08                	push   $0x8
f010354a:	e8 37 d1 ff ff       	call   f0100686 <cputchar>
f010354f:	83 c4 10             	add    $0x10,%esp
f0103552:	eb 41                	jmp    f0103595 <readline+0xa5>
				cputchar(c);
f0103554:	83 ec 0c             	sub    $0xc,%esp
f0103557:	53                   	push   %ebx
f0103558:	e8 29 d1 ff ff       	call   f0100686 <cputchar>
f010355d:	83 c4 10             	add    $0x10,%esp
f0103560:	eb 5a                	jmp    f01035bc <readline+0xcc>
		} else if (c == '\n' || c == '\r') {
f0103562:	83 fb 0a             	cmp    $0xa,%ebx
f0103565:	74 05                	je     f010356c <readline+0x7c>
f0103567:	83 fb 0d             	cmp    $0xd,%ebx
f010356a:	75 2a                	jne    f0103596 <readline+0xa6>
			if (echoing)
f010356c:	85 ff                	test   %edi,%edi
f010356e:	75 0e                	jne    f010357e <readline+0x8e>
			buf[i] = 0;
f0103570:	c6 86 60 85 11 f0 00 	movb   $0x0,-0xfee7aa0(%esi)
			return buf;
f0103577:	b8 60 85 11 f0       	mov    $0xf0118560,%eax
f010357c:	eb bf                	jmp    f010353d <readline+0x4d>
				cputchar('\n');
f010357e:	83 ec 0c             	sub    $0xc,%esp
f0103581:	6a 0a                	push   $0xa
f0103583:	e8 fe d0 ff ff       	call   f0100686 <cputchar>
f0103588:	83 c4 10             	add    $0x10,%esp
f010358b:	eb e3                	jmp    f0103570 <readline+0x80>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010358d:	85 f6                	test   %esi,%esi
f010358f:	7e 3c                	jle    f01035cd <readline+0xdd>
			if (echoing)
f0103591:	85 ff                	test   %edi,%edi
f0103593:	75 b0                	jne    f0103545 <readline+0x55>
			i--;
f0103595:	4e                   	dec    %esi
		c = getchar();
f0103596:	e8 fb d0 ff ff       	call   f0100696 <getchar>
f010359b:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010359d:	85 c0                	test   %eax,%eax
f010359f:	78 86                	js     f0103527 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01035a1:	83 f8 08             	cmp    $0x8,%eax
f01035a4:	74 21                	je     f01035c7 <readline+0xd7>
f01035a6:	83 f8 7f             	cmp    $0x7f,%eax
f01035a9:	74 e2                	je     f010358d <readline+0x9d>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01035ab:	83 f8 1f             	cmp    $0x1f,%eax
f01035ae:	7e b2                	jle    f0103562 <readline+0x72>
f01035b0:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01035b6:	7f aa                	jg     f0103562 <readline+0x72>
			if (echoing)
f01035b8:	85 ff                	test   %edi,%edi
f01035ba:	75 98                	jne    f0103554 <readline+0x64>
			buf[i++] = c;
f01035bc:	88 9e 60 85 11 f0    	mov    %bl,-0xfee7aa0(%esi)
f01035c2:	8d 76 01             	lea    0x1(%esi),%esi
f01035c5:	eb cf                	jmp    f0103596 <readline+0xa6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01035c7:	85 f6                	test   %esi,%esi
f01035c9:	7e cb                	jle    f0103596 <readline+0xa6>
f01035cb:	eb c4                	jmp    f0103591 <readline+0xa1>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01035cd:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01035d3:	7e e3                	jle    f01035b8 <readline+0xc8>
f01035d5:	eb bf                	jmp    f0103596 <readline+0xa6>

f01035d7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01035d7:	55                   	push   %ebp
f01035d8:	89 e5                	mov    %esp,%ebp
f01035da:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01035dd:	b8 00 00 00 00       	mov    $0x0,%eax
f01035e2:	eb 01                	jmp    f01035e5 <strlen+0xe>
		n++;
f01035e4:	40                   	inc    %eax
	for (n = 0; *s != '\0'; s++)
f01035e5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01035e9:	75 f9                	jne    f01035e4 <strlen+0xd>
	return n;
}
f01035eb:	5d                   	pop    %ebp
f01035ec:	c3                   	ret    

f01035ed <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01035ed:	55                   	push   %ebp
f01035ee:	89 e5                	mov    %esp,%ebp
f01035f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01035f3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01035f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01035fb:	eb 01                	jmp    f01035fe <strnlen+0x11>
		n++;
f01035fd:	40                   	inc    %eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01035fe:	39 d0                	cmp    %edx,%eax
f0103600:	74 06                	je     f0103608 <strnlen+0x1b>
f0103602:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0103606:	75 f5                	jne    f01035fd <strnlen+0x10>
	return n;
}
f0103608:	5d                   	pop    %ebp
f0103609:	c3                   	ret    

f010360a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010360a:	55                   	push   %ebp
f010360b:	89 e5                	mov    %esp,%ebp
f010360d:	53                   	push   %ebx
f010360e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103611:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103614:	89 c2                	mov    %eax,%edx
f0103616:	41                   	inc    %ecx
f0103617:	42                   	inc    %edx
f0103618:	8a 59 ff             	mov    -0x1(%ecx),%bl
f010361b:	88 5a ff             	mov    %bl,-0x1(%edx)
f010361e:	84 db                	test   %bl,%bl
f0103620:	75 f4                	jne    f0103616 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0103622:	5b                   	pop    %ebx
f0103623:	5d                   	pop    %ebp
f0103624:	c3                   	ret    

f0103625 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103625:	55                   	push   %ebp
f0103626:	89 e5                	mov    %esp,%ebp
f0103628:	53                   	push   %ebx
f0103629:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010362c:	53                   	push   %ebx
f010362d:	e8 a5 ff ff ff       	call   f01035d7 <strlen>
f0103632:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0103635:	ff 75 0c             	pushl  0xc(%ebp)
f0103638:	01 d8                	add    %ebx,%eax
f010363a:	50                   	push   %eax
f010363b:	e8 ca ff ff ff       	call   f010360a <strcpy>
	return dst;
}
f0103640:	89 d8                	mov    %ebx,%eax
f0103642:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103645:	c9                   	leave  
f0103646:	c3                   	ret    

f0103647 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103647:	55                   	push   %ebp
f0103648:	89 e5                	mov    %esp,%ebp
f010364a:	56                   	push   %esi
f010364b:	53                   	push   %ebx
f010364c:	8b 75 08             	mov    0x8(%ebp),%esi
f010364f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103652:	89 f3                	mov    %esi,%ebx
f0103654:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103657:	89 f2                	mov    %esi,%edx
f0103659:	39 da                	cmp    %ebx,%edx
f010365b:	74 0e                	je     f010366b <strncpy+0x24>
		*dst++ = *src;
f010365d:	42                   	inc    %edx
f010365e:	8a 01                	mov    (%ecx),%al
f0103660:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f0103663:	80 39 00             	cmpb   $0x0,(%ecx)
f0103666:	74 f1                	je     f0103659 <strncpy+0x12>
			src++;
f0103668:	41                   	inc    %ecx
f0103669:	eb ee                	jmp    f0103659 <strncpy+0x12>
	}
	return ret;
}
f010366b:	89 f0                	mov    %esi,%eax
f010366d:	5b                   	pop    %ebx
f010366e:	5e                   	pop    %esi
f010366f:	5d                   	pop    %ebp
f0103670:	c3                   	ret    

f0103671 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103671:	55                   	push   %ebp
f0103672:	89 e5                	mov    %esp,%ebp
f0103674:	56                   	push   %esi
f0103675:	53                   	push   %ebx
f0103676:	8b 75 08             	mov    0x8(%ebp),%esi
f0103679:	8b 55 0c             	mov    0xc(%ebp),%edx
f010367c:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010367f:	85 c0                	test   %eax,%eax
f0103681:	74 20                	je     f01036a3 <strlcpy+0x32>
f0103683:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
f0103687:	89 f0                	mov    %esi,%eax
f0103689:	eb 05                	jmp    f0103690 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010368b:	42                   	inc    %edx
f010368c:	40                   	inc    %eax
f010368d:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0103690:	39 d8                	cmp    %ebx,%eax
f0103692:	74 06                	je     f010369a <strlcpy+0x29>
f0103694:	8a 0a                	mov    (%edx),%cl
f0103696:	84 c9                	test   %cl,%cl
f0103698:	75 f1                	jne    f010368b <strlcpy+0x1a>
		*dst = '\0';
f010369a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010369d:	29 f0                	sub    %esi,%eax
}
f010369f:	5b                   	pop    %ebx
f01036a0:	5e                   	pop    %esi
f01036a1:	5d                   	pop    %ebp
f01036a2:	c3                   	ret    
f01036a3:	89 f0                	mov    %esi,%eax
f01036a5:	eb f6                	jmp    f010369d <strlcpy+0x2c>

f01036a7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01036a7:	55                   	push   %ebp
f01036a8:	89 e5                	mov    %esp,%ebp
f01036aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01036ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01036b0:	eb 02                	jmp    f01036b4 <strcmp+0xd>
		p++, q++;
f01036b2:	41                   	inc    %ecx
f01036b3:	42                   	inc    %edx
	while (*p && *p == *q)
f01036b4:	8a 01                	mov    (%ecx),%al
f01036b6:	84 c0                	test   %al,%al
f01036b8:	74 04                	je     f01036be <strcmp+0x17>
f01036ba:	3a 02                	cmp    (%edx),%al
f01036bc:	74 f4                	je     f01036b2 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01036be:	0f b6 c0             	movzbl %al,%eax
f01036c1:	0f b6 12             	movzbl (%edx),%edx
f01036c4:	29 d0                	sub    %edx,%eax
}
f01036c6:	5d                   	pop    %ebp
f01036c7:	c3                   	ret    

f01036c8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01036c8:	55                   	push   %ebp
f01036c9:	89 e5                	mov    %esp,%ebp
f01036cb:	53                   	push   %ebx
f01036cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01036cf:	8b 55 0c             	mov    0xc(%ebp),%edx
f01036d2:	89 c3                	mov    %eax,%ebx
f01036d4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01036d7:	eb 02                	jmp    f01036db <strncmp+0x13>
		n--, p++, q++;
f01036d9:	40                   	inc    %eax
f01036da:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
f01036db:	39 d8                	cmp    %ebx,%eax
f01036dd:	74 15                	je     f01036f4 <strncmp+0x2c>
f01036df:	8a 08                	mov    (%eax),%cl
f01036e1:	84 c9                	test   %cl,%cl
f01036e3:	74 04                	je     f01036e9 <strncmp+0x21>
f01036e5:	3a 0a                	cmp    (%edx),%cl
f01036e7:	74 f0                	je     f01036d9 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01036e9:	0f b6 00             	movzbl (%eax),%eax
f01036ec:	0f b6 12             	movzbl (%edx),%edx
f01036ef:	29 d0                	sub    %edx,%eax
}
f01036f1:	5b                   	pop    %ebx
f01036f2:	5d                   	pop    %ebp
f01036f3:	c3                   	ret    
		return 0;
f01036f4:	b8 00 00 00 00       	mov    $0x0,%eax
f01036f9:	eb f6                	jmp    f01036f1 <strncmp+0x29>

f01036fb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01036fb:	55                   	push   %ebp
f01036fc:	89 e5                	mov    %esp,%ebp
f01036fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0103701:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0103704:	8a 10                	mov    (%eax),%dl
f0103706:	84 d2                	test   %dl,%dl
f0103708:	74 07                	je     f0103711 <strchr+0x16>
		if (*s == c)
f010370a:	38 ca                	cmp    %cl,%dl
f010370c:	74 08                	je     f0103716 <strchr+0x1b>
	for (; *s; s++)
f010370e:	40                   	inc    %eax
f010370f:	eb f3                	jmp    f0103704 <strchr+0x9>
			return (char *) s;
	return 0;
f0103711:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103716:	5d                   	pop    %ebp
f0103717:	c3                   	ret    

f0103718 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103718:	55                   	push   %ebp
f0103719:	89 e5                	mov    %esp,%ebp
f010371b:	8b 45 08             	mov    0x8(%ebp),%eax
f010371e:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0103721:	8a 10                	mov    (%eax),%dl
f0103723:	84 d2                	test   %dl,%dl
f0103725:	74 07                	je     f010372e <strfind+0x16>
		if (*s == c)
f0103727:	38 ca                	cmp    %cl,%dl
f0103729:	74 03                	je     f010372e <strfind+0x16>
	for (; *s; s++)
f010372b:	40                   	inc    %eax
f010372c:	eb f3                	jmp    f0103721 <strfind+0x9>
			break;
	return (char *) s;
}
f010372e:	5d                   	pop    %ebp
f010372f:	c3                   	ret    

f0103730 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103730:	55                   	push   %ebp
f0103731:	89 e5                	mov    %esp,%ebp
f0103733:	57                   	push   %edi
f0103734:	56                   	push   %esi
f0103735:	53                   	push   %ebx
f0103736:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103739:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010373c:	85 c9                	test   %ecx,%ecx
f010373e:	74 13                	je     f0103753 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103740:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103746:	75 05                	jne    f010374d <memset+0x1d>
f0103748:	f6 c1 03             	test   $0x3,%cl
f010374b:	74 0d                	je     f010375a <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010374d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103750:	fc                   	cld    
f0103751:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103753:	89 f8                	mov    %edi,%eax
f0103755:	5b                   	pop    %ebx
f0103756:	5e                   	pop    %esi
f0103757:	5f                   	pop    %edi
f0103758:	5d                   	pop    %ebp
f0103759:	c3                   	ret    
		c &= 0xFF;
f010375a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010375e:	89 d3                	mov    %edx,%ebx
f0103760:	c1 e3 08             	shl    $0x8,%ebx
f0103763:	89 d0                	mov    %edx,%eax
f0103765:	c1 e0 18             	shl    $0x18,%eax
f0103768:	89 d6                	mov    %edx,%esi
f010376a:	c1 e6 10             	shl    $0x10,%esi
f010376d:	09 f0                	or     %esi,%eax
f010376f:	09 c2                	or     %eax,%edx
f0103771:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0103773:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0103776:	89 d0                	mov    %edx,%eax
f0103778:	fc                   	cld    
f0103779:	f3 ab                	rep stos %eax,%es:(%edi)
f010377b:	eb d6                	jmp    f0103753 <memset+0x23>

f010377d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010377d:	55                   	push   %ebp
f010377e:	89 e5                	mov    %esp,%ebp
f0103780:	57                   	push   %edi
f0103781:	56                   	push   %esi
f0103782:	8b 45 08             	mov    0x8(%ebp),%eax
f0103785:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103788:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010378b:	39 c6                	cmp    %eax,%esi
f010378d:	73 33                	jae    f01037c2 <memmove+0x45>
f010378f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103792:	39 c2                	cmp    %eax,%edx
f0103794:	76 2c                	jbe    f01037c2 <memmove+0x45>
		s += n;
		d += n;
f0103796:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103799:	89 d6                	mov    %edx,%esi
f010379b:	09 fe                	or     %edi,%esi
f010379d:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01037a3:	74 0a                	je     f01037af <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01037a5:	4f                   	dec    %edi
f01037a6:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01037a9:	fd                   	std    
f01037aa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01037ac:	fc                   	cld    
f01037ad:	eb 21                	jmp    f01037d0 <memmove+0x53>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01037af:	f6 c1 03             	test   $0x3,%cl
f01037b2:	75 f1                	jne    f01037a5 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01037b4:	83 ef 04             	sub    $0x4,%edi
f01037b7:	8d 72 fc             	lea    -0x4(%edx),%esi
f01037ba:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01037bd:	fd                   	std    
f01037be:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01037c0:	eb ea                	jmp    f01037ac <memmove+0x2f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01037c2:	89 f2                	mov    %esi,%edx
f01037c4:	09 c2                	or     %eax,%edx
f01037c6:	f6 c2 03             	test   $0x3,%dl
f01037c9:	74 09                	je     f01037d4 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01037cb:	89 c7                	mov    %eax,%edi
f01037cd:	fc                   	cld    
f01037ce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01037d0:	5e                   	pop    %esi
f01037d1:	5f                   	pop    %edi
f01037d2:	5d                   	pop    %ebp
f01037d3:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01037d4:	f6 c1 03             	test   $0x3,%cl
f01037d7:	75 f2                	jne    f01037cb <memmove+0x4e>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01037d9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01037dc:	89 c7                	mov    %eax,%edi
f01037de:	fc                   	cld    
f01037df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01037e1:	eb ed                	jmp    f01037d0 <memmove+0x53>

f01037e3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01037e3:	55                   	push   %ebp
f01037e4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01037e6:	ff 75 10             	pushl  0x10(%ebp)
f01037e9:	ff 75 0c             	pushl  0xc(%ebp)
f01037ec:	ff 75 08             	pushl  0x8(%ebp)
f01037ef:	e8 89 ff ff ff       	call   f010377d <memmove>
}
f01037f4:	c9                   	leave  
f01037f5:	c3                   	ret    

f01037f6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01037f6:	55                   	push   %ebp
f01037f7:	89 e5                	mov    %esp,%ebp
f01037f9:	56                   	push   %esi
f01037fa:	53                   	push   %ebx
f01037fb:	8b 45 08             	mov    0x8(%ebp),%eax
f01037fe:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103801:	89 c6                	mov    %eax,%esi
f0103803:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103806:	39 f0                	cmp    %esi,%eax
f0103808:	74 16                	je     f0103820 <memcmp+0x2a>
		if (*s1 != *s2)
f010380a:	8a 08                	mov    (%eax),%cl
f010380c:	8a 1a                	mov    (%edx),%bl
f010380e:	38 d9                	cmp    %bl,%cl
f0103810:	75 04                	jne    f0103816 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0103812:	40                   	inc    %eax
f0103813:	42                   	inc    %edx
f0103814:	eb f0                	jmp    f0103806 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0103816:	0f b6 c1             	movzbl %cl,%eax
f0103819:	0f b6 db             	movzbl %bl,%ebx
f010381c:	29 d8                	sub    %ebx,%eax
f010381e:	eb 05                	jmp    f0103825 <memcmp+0x2f>
	}

	return 0;
f0103820:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103825:	5b                   	pop    %ebx
f0103826:	5e                   	pop    %esi
f0103827:	5d                   	pop    %ebp
f0103828:	c3                   	ret    

f0103829 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103829:	55                   	push   %ebp
f010382a:	89 e5                	mov    %esp,%ebp
f010382c:	8b 45 08             	mov    0x8(%ebp),%eax
f010382f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0103832:	89 c2                	mov    %eax,%edx
f0103834:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103837:	39 d0                	cmp    %edx,%eax
f0103839:	73 07                	jae    f0103842 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
f010383b:	38 08                	cmp    %cl,(%eax)
f010383d:	74 03                	je     f0103842 <memfind+0x19>
	for (; s < ends; s++)
f010383f:	40                   	inc    %eax
f0103840:	eb f5                	jmp    f0103837 <memfind+0xe>
			break;
	return (void *) s;
}
f0103842:	5d                   	pop    %ebp
f0103843:	c3                   	ret    

f0103844 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103844:	55                   	push   %ebp
f0103845:	89 e5                	mov    %esp,%ebp
f0103847:	57                   	push   %edi
f0103848:	56                   	push   %esi
f0103849:	53                   	push   %ebx
f010384a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010384d:	eb 01                	jmp    f0103850 <strtol+0xc>
		s++;
f010384f:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f0103850:	8a 01                	mov    (%ecx),%al
f0103852:	3c 20                	cmp    $0x20,%al
f0103854:	74 f9                	je     f010384f <strtol+0xb>
f0103856:	3c 09                	cmp    $0x9,%al
f0103858:	74 f5                	je     f010384f <strtol+0xb>

	// plus/minus sign
	if (*s == '+')
f010385a:	3c 2b                	cmp    $0x2b,%al
f010385c:	74 2b                	je     f0103889 <strtol+0x45>
		s++;
	else if (*s == '-')
f010385e:	3c 2d                	cmp    $0x2d,%al
f0103860:	74 2f                	je     f0103891 <strtol+0x4d>
	int neg = 0;
f0103862:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103867:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f010386e:	75 12                	jne    f0103882 <strtol+0x3e>
f0103870:	80 39 30             	cmpb   $0x30,(%ecx)
f0103873:	74 24                	je     f0103899 <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103875:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0103879:	75 07                	jne    f0103882 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010387b:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f0103882:	b8 00 00 00 00       	mov    $0x0,%eax
f0103887:	eb 4e                	jmp    f01038d7 <strtol+0x93>
		s++;
f0103889:	41                   	inc    %ecx
	int neg = 0;
f010388a:	bf 00 00 00 00       	mov    $0x0,%edi
f010388f:	eb d6                	jmp    f0103867 <strtol+0x23>
		s++, neg = 1;
f0103891:	41                   	inc    %ecx
f0103892:	bf 01 00 00 00       	mov    $0x1,%edi
f0103897:	eb ce                	jmp    f0103867 <strtol+0x23>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103899:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010389d:	74 10                	je     f01038af <strtol+0x6b>
	else if (base == 0 && s[0] == '0')
f010389f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01038a3:	75 dd                	jne    f0103882 <strtol+0x3e>
		s++, base = 8;
f01038a5:	41                   	inc    %ecx
f01038a6:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f01038ad:	eb d3                	jmp    f0103882 <strtol+0x3e>
		s += 2, base = 16;
f01038af:	83 c1 02             	add    $0x2,%ecx
f01038b2:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f01038b9:	eb c7                	jmp    f0103882 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01038bb:	8d 72 9f             	lea    -0x61(%edx),%esi
f01038be:	89 f3                	mov    %esi,%ebx
f01038c0:	80 fb 19             	cmp    $0x19,%bl
f01038c3:	77 24                	ja     f01038e9 <strtol+0xa5>
			dig = *s - 'a' + 10;
f01038c5:	0f be d2             	movsbl %dl,%edx
f01038c8:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01038cb:	3b 55 10             	cmp    0x10(%ebp),%edx
f01038ce:	7d 2b                	jge    f01038fb <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
f01038d0:	41                   	inc    %ecx
f01038d1:	0f af 45 10          	imul   0x10(%ebp),%eax
f01038d5:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01038d7:	8a 11                	mov    (%ecx),%dl
f01038d9:	8d 5a d0             	lea    -0x30(%edx),%ebx
f01038dc:	80 fb 09             	cmp    $0x9,%bl
f01038df:	77 da                	ja     f01038bb <strtol+0x77>
			dig = *s - '0';
f01038e1:	0f be d2             	movsbl %dl,%edx
f01038e4:	83 ea 30             	sub    $0x30,%edx
f01038e7:	eb e2                	jmp    f01038cb <strtol+0x87>
		else if (*s >= 'A' && *s <= 'Z')
f01038e9:	8d 72 bf             	lea    -0x41(%edx),%esi
f01038ec:	89 f3                	mov    %esi,%ebx
f01038ee:	80 fb 19             	cmp    $0x19,%bl
f01038f1:	77 08                	ja     f01038fb <strtol+0xb7>
			dig = *s - 'A' + 10;
f01038f3:	0f be d2             	movsbl %dl,%edx
f01038f6:	83 ea 37             	sub    $0x37,%edx
f01038f9:	eb d0                	jmp    f01038cb <strtol+0x87>
		// we don't properly detect overflow!
	}

	if (endptr)
f01038fb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01038ff:	74 05                	je     f0103906 <strtol+0xc2>
		*endptr = (char *) s;
f0103901:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103904:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0103906:	85 ff                	test   %edi,%edi
f0103908:	74 02                	je     f010390c <strtol+0xc8>
f010390a:	f7 d8                	neg    %eax
}
f010390c:	5b                   	pop    %ebx
f010390d:	5e                   	pop    %esi
f010390e:	5f                   	pop    %edi
f010390f:	5d                   	pop    %ebp
f0103910:	c3                   	ret    

f0103911 <strtoul>:

unsigned long
strtoul(const char *s, char **endptr, int base)
{
f0103911:	55                   	push   %ebp
f0103912:	89 e5                	mov    %esp,%ebp
f0103914:	57                   	push   %edi
f0103915:	56                   	push   %esi
f0103916:	53                   	push   %ebx
f0103917:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	unsigned long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010391a:	eb 01                	jmp    f010391d <strtoul+0xc>
		s++;
f010391c:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f010391d:	8a 01                	mov    (%ecx),%al
f010391f:	3c 20                	cmp    $0x20,%al
f0103921:	74 f9                	je     f010391c <strtoul+0xb>
f0103923:	3c 09                	cmp    $0x9,%al
f0103925:	74 f5                	je     f010391c <strtoul+0xb>

	// plus/minus sign
	if (*s == '+')
f0103927:	3c 2b                	cmp    $0x2b,%al
f0103929:	74 2b                	je     f0103956 <strtoul+0x45>
		s++;
	else if (*s == '-')
f010392b:	3c 2d                	cmp    $0x2d,%al
f010392d:	74 2f                	je     f010395e <strtoul+0x4d>
	int neg = 0;
f010392f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103934:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f010393b:	75 12                	jne    f010394f <strtoul+0x3e>
f010393d:	80 39 30             	cmpb   $0x30,(%ecx)
f0103940:	74 24                	je     f0103966 <strtoul+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103942:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0103946:	75 07                	jne    f010394f <strtoul+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103948:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f010394f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103954:	eb 4e                	jmp    f01039a4 <strtoul+0x93>
		s++;
f0103956:	41                   	inc    %ecx
	int neg = 0;
f0103957:	bf 00 00 00 00       	mov    $0x0,%edi
f010395c:	eb d6                	jmp    f0103934 <strtoul+0x23>
		s++, neg = 1;
f010395e:	41                   	inc    %ecx
f010395f:	bf 01 00 00 00       	mov    $0x1,%edi
f0103964:	eb ce                	jmp    f0103934 <strtoul+0x23>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103966:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010396a:	74 10                	je     f010397c <strtoul+0x6b>
	else if (base == 0 && s[0] == '0')
f010396c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0103970:	75 dd                	jne    f010394f <strtoul+0x3e>
		s++, base = 8;
f0103972:	41                   	inc    %ecx
f0103973:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f010397a:	eb d3                	jmp    f010394f <strtoul+0x3e>
		s += 2, base = 16;
f010397c:	83 c1 02             	add    $0x2,%ecx
f010397f:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f0103986:	eb c7                	jmp    f010394f <strtoul+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0103988:	8d 72 9f             	lea    -0x61(%edx),%esi
f010398b:	89 f3                	mov    %esi,%ebx
f010398d:	80 fb 19             	cmp    $0x19,%bl
f0103990:	77 24                	ja     f01039b6 <strtoul+0xa5>
			dig = *s - 'a' + 10;
f0103992:	0f be d2             	movsbl %dl,%edx
f0103995:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0103998:	3b 55 10             	cmp    0x10(%ebp),%edx
f010399b:	7d 2b                	jge    f01039c8 <strtoul+0xb7>
			break;
		s++, val = (val * base) + dig;
f010399d:	41                   	inc    %ecx
f010399e:	0f af 45 10          	imul   0x10(%ebp),%eax
f01039a2:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01039a4:	8a 11                	mov    (%ecx),%dl
f01039a6:	8d 5a d0             	lea    -0x30(%edx),%ebx
f01039a9:	80 fb 09             	cmp    $0x9,%bl
f01039ac:	77 da                	ja     f0103988 <strtoul+0x77>
			dig = *s - '0';
f01039ae:	0f be d2             	movsbl %dl,%edx
f01039b1:	83 ea 30             	sub    $0x30,%edx
f01039b4:	eb e2                	jmp    f0103998 <strtoul+0x87>
		else if (*s >= 'A' && *s <= 'Z')
f01039b6:	8d 72 bf             	lea    -0x41(%edx),%esi
f01039b9:	89 f3                	mov    %esi,%ebx
f01039bb:	80 fb 19             	cmp    $0x19,%bl
f01039be:	77 08                	ja     f01039c8 <strtoul+0xb7>
			dig = *s - 'A' + 10;
f01039c0:	0f be d2             	movsbl %dl,%edx
f01039c3:	83 ea 37             	sub    $0x37,%edx
f01039c6:	eb d0                	jmp    f0103998 <strtoul+0x87>
		// we don't properly detect overflow!
	}

	if (endptr)
f01039c8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01039cc:	74 05                	je     f01039d3 <strtoul+0xc2>
		*endptr = (char *) s;
f01039ce:	8b 75 0c             	mov    0xc(%ebp),%esi
f01039d1:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f01039d3:	85 ff                	test   %edi,%edi
f01039d5:	74 02                	je     f01039d9 <strtoul+0xc8>
f01039d7:	f7 d8                	neg    %eax
}
f01039d9:	5b                   	pop    %ebx
f01039da:	5e                   	pop    %esi
f01039db:	5f                   	pop    %edi
f01039dc:	5d                   	pop    %ebp
f01039dd:	c3                   	ret    
f01039de:	66 90                	xchg   %ax,%ax

f01039e0 <__udivdi3>:
f01039e0:	55                   	push   %ebp
f01039e1:	57                   	push   %edi
f01039e2:	56                   	push   %esi
f01039e3:	53                   	push   %ebx
f01039e4:	83 ec 1c             	sub    $0x1c,%esp
f01039e7:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01039eb:	8b 74 24 34          	mov    0x34(%esp),%esi
f01039ef:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01039f3:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01039f7:	85 d2                	test   %edx,%edx
f01039f9:	75 2d                	jne    f0103a28 <__udivdi3+0x48>
f01039fb:	39 f7                	cmp    %esi,%edi
f01039fd:	77 59                	ja     f0103a58 <__udivdi3+0x78>
f01039ff:	89 f9                	mov    %edi,%ecx
f0103a01:	85 ff                	test   %edi,%edi
f0103a03:	75 0b                	jne    f0103a10 <__udivdi3+0x30>
f0103a05:	b8 01 00 00 00       	mov    $0x1,%eax
f0103a0a:	31 d2                	xor    %edx,%edx
f0103a0c:	f7 f7                	div    %edi
f0103a0e:	89 c1                	mov    %eax,%ecx
f0103a10:	31 d2                	xor    %edx,%edx
f0103a12:	89 f0                	mov    %esi,%eax
f0103a14:	f7 f1                	div    %ecx
f0103a16:	89 c3                	mov    %eax,%ebx
f0103a18:	89 e8                	mov    %ebp,%eax
f0103a1a:	f7 f1                	div    %ecx
f0103a1c:	89 da                	mov    %ebx,%edx
f0103a1e:	83 c4 1c             	add    $0x1c,%esp
f0103a21:	5b                   	pop    %ebx
f0103a22:	5e                   	pop    %esi
f0103a23:	5f                   	pop    %edi
f0103a24:	5d                   	pop    %ebp
f0103a25:	c3                   	ret    
f0103a26:	66 90                	xchg   %ax,%ax
f0103a28:	39 f2                	cmp    %esi,%edx
f0103a2a:	77 1c                	ja     f0103a48 <__udivdi3+0x68>
f0103a2c:	0f bd da             	bsr    %edx,%ebx
f0103a2f:	83 f3 1f             	xor    $0x1f,%ebx
f0103a32:	75 38                	jne    f0103a6c <__udivdi3+0x8c>
f0103a34:	39 f2                	cmp    %esi,%edx
f0103a36:	72 08                	jb     f0103a40 <__udivdi3+0x60>
f0103a38:	39 ef                	cmp    %ebp,%edi
f0103a3a:	0f 87 98 00 00 00    	ja     f0103ad8 <__udivdi3+0xf8>
f0103a40:	b8 01 00 00 00       	mov    $0x1,%eax
f0103a45:	eb 05                	jmp    f0103a4c <__udivdi3+0x6c>
f0103a47:	90                   	nop
f0103a48:	31 db                	xor    %ebx,%ebx
f0103a4a:	31 c0                	xor    %eax,%eax
f0103a4c:	89 da                	mov    %ebx,%edx
f0103a4e:	83 c4 1c             	add    $0x1c,%esp
f0103a51:	5b                   	pop    %ebx
f0103a52:	5e                   	pop    %esi
f0103a53:	5f                   	pop    %edi
f0103a54:	5d                   	pop    %ebp
f0103a55:	c3                   	ret    
f0103a56:	66 90                	xchg   %ax,%ax
f0103a58:	89 e8                	mov    %ebp,%eax
f0103a5a:	89 f2                	mov    %esi,%edx
f0103a5c:	f7 f7                	div    %edi
f0103a5e:	31 db                	xor    %ebx,%ebx
f0103a60:	89 da                	mov    %ebx,%edx
f0103a62:	83 c4 1c             	add    $0x1c,%esp
f0103a65:	5b                   	pop    %ebx
f0103a66:	5e                   	pop    %esi
f0103a67:	5f                   	pop    %edi
f0103a68:	5d                   	pop    %ebp
f0103a69:	c3                   	ret    
f0103a6a:	66 90                	xchg   %ax,%ax
f0103a6c:	b8 20 00 00 00       	mov    $0x20,%eax
f0103a71:	29 d8                	sub    %ebx,%eax
f0103a73:	88 d9                	mov    %bl,%cl
f0103a75:	d3 e2                	shl    %cl,%edx
f0103a77:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103a7b:	89 fa                	mov    %edi,%edx
f0103a7d:	88 c1                	mov    %al,%cl
f0103a7f:	d3 ea                	shr    %cl,%edx
f0103a81:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0103a85:	09 d1                	or     %edx,%ecx
f0103a87:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103a8b:	88 d9                	mov    %bl,%cl
f0103a8d:	d3 e7                	shl    %cl,%edi
f0103a8f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0103a93:	89 f7                	mov    %esi,%edi
f0103a95:	88 c1                	mov    %al,%cl
f0103a97:	d3 ef                	shr    %cl,%edi
f0103a99:	88 d9                	mov    %bl,%cl
f0103a9b:	d3 e6                	shl    %cl,%esi
f0103a9d:	89 ea                	mov    %ebp,%edx
f0103a9f:	88 c1                	mov    %al,%cl
f0103aa1:	d3 ea                	shr    %cl,%edx
f0103aa3:	09 d6                	or     %edx,%esi
f0103aa5:	89 f0                	mov    %esi,%eax
f0103aa7:	89 fa                	mov    %edi,%edx
f0103aa9:	f7 74 24 08          	divl   0x8(%esp)
f0103aad:	89 d7                	mov    %edx,%edi
f0103aaf:	89 c6                	mov    %eax,%esi
f0103ab1:	f7 64 24 0c          	mull   0xc(%esp)
f0103ab5:	39 d7                	cmp    %edx,%edi
f0103ab7:	72 13                	jb     f0103acc <__udivdi3+0xec>
f0103ab9:	74 09                	je     f0103ac4 <__udivdi3+0xe4>
f0103abb:	89 f0                	mov    %esi,%eax
f0103abd:	31 db                	xor    %ebx,%ebx
f0103abf:	eb 8b                	jmp    f0103a4c <__udivdi3+0x6c>
f0103ac1:	8d 76 00             	lea    0x0(%esi),%esi
f0103ac4:	88 d9                	mov    %bl,%cl
f0103ac6:	d3 e5                	shl    %cl,%ebp
f0103ac8:	39 c5                	cmp    %eax,%ebp
f0103aca:	73 ef                	jae    f0103abb <__udivdi3+0xdb>
f0103acc:	8d 46 ff             	lea    -0x1(%esi),%eax
f0103acf:	31 db                	xor    %ebx,%ebx
f0103ad1:	e9 76 ff ff ff       	jmp    f0103a4c <__udivdi3+0x6c>
f0103ad6:	66 90                	xchg   %ax,%ax
f0103ad8:	31 c0                	xor    %eax,%eax
f0103ada:	e9 6d ff ff ff       	jmp    f0103a4c <__udivdi3+0x6c>
f0103adf:	90                   	nop

f0103ae0 <__umoddi3>:
f0103ae0:	55                   	push   %ebp
f0103ae1:	57                   	push   %edi
f0103ae2:	56                   	push   %esi
f0103ae3:	53                   	push   %ebx
f0103ae4:	83 ec 1c             	sub    $0x1c,%esp
f0103ae7:	8b 74 24 30          	mov    0x30(%esp),%esi
f0103aeb:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0103aef:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103af3:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0103af7:	89 f0                	mov    %esi,%eax
f0103af9:	89 da                	mov    %ebx,%edx
f0103afb:	85 ed                	test   %ebp,%ebp
f0103afd:	75 15                	jne    f0103b14 <__umoddi3+0x34>
f0103aff:	39 df                	cmp    %ebx,%edi
f0103b01:	76 39                	jbe    f0103b3c <__umoddi3+0x5c>
f0103b03:	f7 f7                	div    %edi
f0103b05:	89 d0                	mov    %edx,%eax
f0103b07:	31 d2                	xor    %edx,%edx
f0103b09:	83 c4 1c             	add    $0x1c,%esp
f0103b0c:	5b                   	pop    %ebx
f0103b0d:	5e                   	pop    %esi
f0103b0e:	5f                   	pop    %edi
f0103b0f:	5d                   	pop    %ebp
f0103b10:	c3                   	ret    
f0103b11:	8d 76 00             	lea    0x0(%esi),%esi
f0103b14:	39 dd                	cmp    %ebx,%ebp
f0103b16:	77 f1                	ja     f0103b09 <__umoddi3+0x29>
f0103b18:	0f bd cd             	bsr    %ebp,%ecx
f0103b1b:	83 f1 1f             	xor    $0x1f,%ecx
f0103b1e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103b22:	75 38                	jne    f0103b5c <__umoddi3+0x7c>
f0103b24:	39 dd                	cmp    %ebx,%ebp
f0103b26:	72 04                	jb     f0103b2c <__umoddi3+0x4c>
f0103b28:	39 f7                	cmp    %esi,%edi
f0103b2a:	77 dd                	ja     f0103b09 <__umoddi3+0x29>
f0103b2c:	89 da                	mov    %ebx,%edx
f0103b2e:	89 f0                	mov    %esi,%eax
f0103b30:	29 f8                	sub    %edi,%eax
f0103b32:	19 ea                	sbb    %ebp,%edx
f0103b34:	83 c4 1c             	add    $0x1c,%esp
f0103b37:	5b                   	pop    %ebx
f0103b38:	5e                   	pop    %esi
f0103b39:	5f                   	pop    %edi
f0103b3a:	5d                   	pop    %ebp
f0103b3b:	c3                   	ret    
f0103b3c:	89 f9                	mov    %edi,%ecx
f0103b3e:	85 ff                	test   %edi,%edi
f0103b40:	75 0b                	jne    f0103b4d <__umoddi3+0x6d>
f0103b42:	b8 01 00 00 00       	mov    $0x1,%eax
f0103b47:	31 d2                	xor    %edx,%edx
f0103b49:	f7 f7                	div    %edi
f0103b4b:	89 c1                	mov    %eax,%ecx
f0103b4d:	89 d8                	mov    %ebx,%eax
f0103b4f:	31 d2                	xor    %edx,%edx
f0103b51:	f7 f1                	div    %ecx
f0103b53:	89 f0                	mov    %esi,%eax
f0103b55:	f7 f1                	div    %ecx
f0103b57:	eb ac                	jmp    f0103b05 <__umoddi3+0x25>
f0103b59:	8d 76 00             	lea    0x0(%esi),%esi
f0103b5c:	b8 20 00 00 00       	mov    $0x20,%eax
f0103b61:	89 c2                	mov    %eax,%edx
f0103b63:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103b67:	29 c2                	sub    %eax,%edx
f0103b69:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103b6d:	88 c1                	mov    %al,%cl
f0103b6f:	d3 e5                	shl    %cl,%ebp
f0103b71:	89 f8                	mov    %edi,%eax
f0103b73:	88 d1                	mov    %dl,%cl
f0103b75:	d3 e8                	shr    %cl,%eax
f0103b77:	09 c5                	or     %eax,%ebp
f0103b79:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103b7d:	88 c1                	mov    %al,%cl
f0103b7f:	d3 e7                	shl    %cl,%edi
f0103b81:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0103b85:	89 df                	mov    %ebx,%edi
f0103b87:	88 d1                	mov    %dl,%cl
f0103b89:	d3 ef                	shr    %cl,%edi
f0103b8b:	88 c1                	mov    %al,%cl
f0103b8d:	d3 e3                	shl    %cl,%ebx
f0103b8f:	89 f0                	mov    %esi,%eax
f0103b91:	88 d1                	mov    %dl,%cl
f0103b93:	d3 e8                	shr    %cl,%eax
f0103b95:	09 d8                	or     %ebx,%eax
f0103b97:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0103b9b:	d3 e6                	shl    %cl,%esi
f0103b9d:	89 fa                	mov    %edi,%edx
f0103b9f:	f7 f5                	div    %ebp
f0103ba1:	89 d1                	mov    %edx,%ecx
f0103ba3:	f7 64 24 08          	mull   0x8(%esp)
f0103ba7:	89 c3                	mov    %eax,%ebx
f0103ba9:	89 d7                	mov    %edx,%edi
f0103bab:	39 d1                	cmp    %edx,%ecx
f0103bad:	72 29                	jb     f0103bd8 <__umoddi3+0xf8>
f0103baf:	74 23                	je     f0103bd4 <__umoddi3+0xf4>
f0103bb1:	89 ca                	mov    %ecx,%edx
f0103bb3:	29 de                	sub    %ebx,%esi
f0103bb5:	19 fa                	sbb    %edi,%edx
f0103bb7:	89 d0                	mov    %edx,%eax
f0103bb9:	8a 4c 24 0c          	mov    0xc(%esp),%cl
f0103bbd:	d3 e0                	shl    %cl,%eax
f0103bbf:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0103bc3:	88 d9                	mov    %bl,%cl
f0103bc5:	d3 ee                	shr    %cl,%esi
f0103bc7:	09 f0                	or     %esi,%eax
f0103bc9:	d3 ea                	shr    %cl,%edx
f0103bcb:	83 c4 1c             	add    $0x1c,%esp
f0103bce:	5b                   	pop    %ebx
f0103bcf:	5e                   	pop    %esi
f0103bd0:	5f                   	pop    %edi
f0103bd1:	5d                   	pop    %ebp
f0103bd2:	c3                   	ret    
f0103bd3:	90                   	nop
f0103bd4:	39 c6                	cmp    %eax,%esi
f0103bd6:	73 d9                	jae    f0103bb1 <__umoddi3+0xd1>
f0103bd8:	2b 44 24 08          	sub    0x8(%esp),%eax
f0103bdc:	19 ea                	sbb    %ebp,%edx
f0103bde:	89 d7                	mov    %edx,%edi
f0103be0:	89 c3                	mov    %eax,%ebx
f0103be2:	eb cd                	jmp    f0103bb1 <__umoddi3+0xd1>
