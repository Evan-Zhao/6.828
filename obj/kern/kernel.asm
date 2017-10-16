
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
f0100015:	b8 00 50 11 00       	mov    $0x115000,%eax
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
f0100034:	bc 00 50 11 f0       	mov    $0xf0115000,%esp

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
f010004b:	68 e0 37 10 f0       	push   $0xf01037e0
f0100050:	e8 5a 28 00 00       	call   f01028af <cprintf>
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
f0100071:	68 fc 37 10 f0       	push   $0xf01037fc
f0100076:	e8 34 28 00 00       	call   f01028af <cprintf>
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
f010009a:	b8 70 79 11 f0       	mov    $0xf0117970,%eax
f010009f:	2d 00 73 11 f0       	sub    $0xf0117300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 73 11 f0       	push   $0xf0117300
f01000ac:	e8 2d 33 00 00       	call   f01033de <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 d8 04 00 00       	call   f010058e <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 17 38 10 f0       	push   $0xf0103817
f01000c3:	e8 e7 27 00 00       	call   f01028af <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000c8:	e8 fa 0f 00 00       	call   f01010c7 <mem_init>
	cprintf(ANSI_COLOR_RED     "This text is RED!"     ANSI_COLOR_RESET "\n");
f01000cd:	c7 04 24 32 38 10 f0 	movl   $0xf0103832,(%esp)
f01000d4:	e8 d6 27 00 00       	call   f01028af <cprintf>
	cprintf(ANSI_COLOR_GREEN   "This text is GREEN!"   ANSI_COLOR_RESET "\n");
f01000d9:	c7 04 24 4e 38 10 f0 	movl   $0xf010384e,(%esp)
f01000e0:	e8 ca 27 00 00       	call   f01028af <cprintf>
	cprintf(ANSI_COLOR_YELLOW  "This text is YELLOW!"  ANSI_COLOR_RESET "\n");
f01000e5:	c7 04 24 d8 38 10 f0 	movl   $0xf01038d8,(%esp)
f01000ec:	e8 be 27 00 00       	call   f01028af <cprintf>
	cprintf(ANSI_COLOR_BLUE    "This text is BLUE!"    ANSI_COLOR_RESET "\n");
f01000f1:	c7 04 24 6c 38 10 f0 	movl   $0xf010386c,(%esp)
f01000f8:	e8 b2 27 00 00       	call   f01028af <cprintf>
	cprintf(ANSI_COLOR_MAGENTA "This text is MAGENTA!" ANSI_COLOR_RESET "\n");
f01000fd:	c7 04 24 f8 38 10 f0 	movl   $0xf01038f8,(%esp)
f0100104:	e8 a6 27 00 00       	call   f01028af <cprintf>
	cprintf(ANSI_COLOR_CYAN    "This text is CYAN!"    ANSI_COLOR_RESET "\n");
f0100109:	c7 04 24 89 38 10 f0 	movl   $0xf0103889,(%esp)
f0100110:	e8 9a 27 00 00       	call   f01028af <cprintf>

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
f010013b:	83 3d 60 79 11 f0 00 	cmpl   $0x0,0xf0117960
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
f0100153:	89 35 60 79 11 f0    	mov    %esi,0xf0117960
	asm volatile("cli; cld");
f0100159:	fa                   	cli    
f010015a:	fc                   	cld    
	va_start(ap, fmt);
f010015b:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f010015e:	83 ec 04             	sub    $0x4,%esp
f0100161:	ff 75 0c             	pushl  0xc(%ebp)
f0100164:	ff 75 08             	pushl  0x8(%ebp)
f0100167:	68 a6 38 10 f0       	push   $0xf01038a6
f010016c:	e8 3e 27 00 00       	call   f01028af <cprintf>
	vcprintf(fmt, ap);
f0100171:	83 c4 08             	add    $0x8,%esp
f0100174:	53                   	push   %ebx
f0100175:	56                   	push   %esi
f0100176:	e8 0e 27 00 00       	call   f0102889 <vcprintf>
	cprintf("\n");
f010017b:	c7 04 24 5c 48 10 f0 	movl   $0xf010485c,(%esp)
f0100182:	e8 28 27 00 00       	call   f01028af <cprintf>
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
f010019c:	68 be 38 10 f0       	push   $0xf01038be
f01001a1:	e8 09 27 00 00       	call   f01028af <cprintf>
	vcprintf(fmt, ap);
f01001a6:	83 c4 08             	add    $0x8,%esp
f01001a9:	53                   	push   %ebx
f01001aa:	ff 75 10             	pushl  0x10(%ebp)
f01001ad:	e8 d7 26 00 00       	call   f0102889 <vcprintf>
	cprintf("\n");
f01001b2:	c7 04 24 5c 48 10 f0 	movl   $0xf010485c,(%esp)
f01001b9:	e8 f1 26 00 00       	call   f01028af <cprintf>
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
f01001f9:	8b 0d 24 75 11 f0    	mov    0xf0117524,%ecx
f01001ff:	8d 51 01             	lea    0x1(%ecx),%edx
f0100202:	89 15 24 75 11 f0    	mov    %edx,0xf0117524
f0100208:	88 81 20 73 11 f0    	mov    %al,-0xfee8ce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010020e:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100214:	75 d8                	jne    f01001ee <cons_intr+0x9>
			cons.wpos = 0;
f0100216:	c7 05 24 75 11 f0 00 	movl   $0x0,0xf0117524
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
f010025d:	8b 0d 00 73 11 f0    	mov    0xf0117300,%ecx
f0100263:	f6 c1 40             	test   $0x40,%cl
f0100266:	74 0e                	je     f0100276 <kbd_proc_data+0x4e>
		data |= 0x80;
f0100268:	83 c8 80             	or     $0xffffff80,%eax
f010026b:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f010026d:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100270:	89 0d 00 73 11 f0    	mov    %ecx,0xf0117300
	shift |= shiftcode[data];
f0100276:	0f b6 d2             	movzbl %dl,%edx
f0100279:	0f b6 82 80 3a 10 f0 	movzbl -0xfefc580(%edx),%eax
f0100280:	0b 05 00 73 11 f0    	or     0xf0117300,%eax
	shift ^= togglecode[data];
f0100286:	0f b6 8a 80 39 10 f0 	movzbl -0xfefc680(%edx),%ecx
f010028d:	31 c8                	xor    %ecx,%eax
f010028f:	a3 00 73 11 f0       	mov    %eax,0xf0117300
	c = charcode[shift & (CTL | SHIFT)][data];
f0100294:	89 c1                	mov    %eax,%ecx
f0100296:	83 e1 03             	and    $0x3,%ecx
f0100299:	8b 0c 8d 60 39 10 f0 	mov    -0xfefc6a0(,%ecx,4),%ecx
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
f01002c8:	68 18 39 10 f0       	push   $0xf0103918
f01002cd:	e8 dd 25 00 00       	call   f01028af <cprintf>
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
f01002df:	83 0d 00 73 11 f0 40 	orl    $0x40,0xf0117300
		return 0;
f01002e6:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f01002eb:	89 d8                	mov    %ebx,%eax
f01002ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002f0:	c9                   	leave  
f01002f1:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002f2:	8b 0d 00 73 11 f0    	mov    0xf0117300,%ecx
f01002f8:	f6 c1 40             	test   $0x40,%cl
f01002fb:	75 05                	jne    f0100302 <kbd_proc_data+0xda>
f01002fd:	83 e0 7f             	and    $0x7f,%eax
f0100300:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f0100302:	0f b6 d2             	movzbl %dl,%edx
f0100305:	8a 82 80 3a 10 f0    	mov    -0xfefc580(%edx),%al
f010030b:	83 c8 40             	or     $0x40,%eax
f010030e:	0f b6 c0             	movzbl %al,%eax
f0100311:	f7 d0                	not    %eax
f0100313:	21 c8                	and    %ecx,%eax
f0100315:	a3 00 73 11 f0       	mov    %eax,0xf0117300
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
f01003db:	66 8b 0d 28 75 11 f0 	mov    0xf0117528,%cx
f01003e2:	bb 50 00 00 00       	mov    $0x50,%ebx
f01003e7:	89 c8                	mov    %ecx,%eax
f01003e9:	ba 00 00 00 00       	mov    $0x0,%edx
f01003ee:	66 f7 f3             	div    %bx
f01003f1:	29 d1                	sub    %edx,%ecx
f01003f3:	66 89 0d 28 75 11 f0 	mov    %cx,0xf0117528
	if (crt_pos >= CRT_SIZE) {
f01003fa:	66 81 3d 28 75 11 f0 	cmpw   $0x7cf,0xf0117528
f0100401:	cf 07 
f0100403:	0f 87 c5 00 00 00    	ja     f01004ce <cons_putc+0x192>
	outb(addr_6845, 14);
f0100409:	8b 0d 30 75 11 f0    	mov    0xf0117530,%ecx
f010040f:	b0 0e                	mov    $0xe,%al
f0100411:	89 ca                	mov    %ecx,%edx
f0100413:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100414:	8d 59 01             	lea    0x1(%ecx),%ebx
f0100417:	66 a1 28 75 11 f0    	mov    0xf0117528,%ax
f010041d:	66 c1 e8 08          	shr    $0x8,%ax
f0100421:	89 da                	mov    %ebx,%edx
f0100423:	ee                   	out    %al,(%dx)
f0100424:	b0 0f                	mov    $0xf,%al
f0100426:	89 ca                	mov    %ecx,%edx
f0100428:	ee                   	out    %al,(%dx)
f0100429:	a0 28 75 11 f0       	mov    0xf0117528,%al
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
f010043e:	66 a1 28 75 11 f0    	mov    0xf0117528,%ax
f0100444:	66 85 c0             	test   %ax,%ax
f0100447:	74 c0                	je     f0100409 <cons_putc+0xcd>
			crt_pos--;
f0100449:	48                   	dec    %eax
f010044a:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100450:	0f b7 c0             	movzwl %ax,%eax
f0100453:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f0100459:	83 cf 20             	or     $0x20,%edi
f010045c:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f0100462:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100466:	eb 92                	jmp    f01003fa <cons_putc+0xbe>
		crt_pos += CRT_COLS;
f0100468:	66 83 05 28 75 11 f0 	addw   $0x50,0xf0117528
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
f01004ac:	66 a1 28 75 11 f0    	mov    0xf0117528,%ax
f01004b2:	8d 50 01             	lea    0x1(%eax),%edx
f01004b5:	66 89 15 28 75 11 f0 	mov    %dx,0xf0117528
f01004bc:	0f b7 c0             	movzwl %ax,%eax
f01004bf:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f01004c5:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004c9:	e9 2c ff ff ff       	jmp    f01003fa <cons_putc+0xbe>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004ce:	a1 2c 75 11 f0       	mov    0xf011752c,%eax
f01004d3:	83 ec 04             	sub    $0x4,%esp
f01004d6:	68 00 0f 00 00       	push   $0xf00
f01004db:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004e1:	52                   	push   %edx
f01004e2:	50                   	push   %eax
f01004e3:	e8 43 2f 00 00       	call   f010342b <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01004e8:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f01004ee:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01004f4:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01004fa:	83 c4 10             	add    $0x10,%esp
f01004fd:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100502:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100505:	39 d0                	cmp    %edx,%eax
f0100507:	75 f4                	jne    f01004fd <cons_putc+0x1c1>
		crt_pos -= CRT_COLS;
f0100509:	66 83 2d 28 75 11 f0 	subw   $0x50,0xf0117528
f0100510:	50 
f0100511:	e9 f3 fe ff ff       	jmp    f0100409 <cons_putc+0xcd>

f0100516 <serial_intr>:
	if (serial_exists)
f0100516:	80 3d 34 75 11 f0 00 	cmpb   $0x0,0xf0117534
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
f0100554:	a1 20 75 11 f0       	mov    0xf0117520,%eax
f0100559:	3b 05 24 75 11 f0    	cmp    0xf0117524,%eax
f010055f:	74 26                	je     f0100587 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100561:	8d 50 01             	lea    0x1(%eax),%edx
f0100564:	89 15 20 75 11 f0    	mov    %edx,0xf0117520
f010056a:	0f b6 80 20 73 11 f0 	movzbl -0xfee8ce0(%eax),%eax
		if (cons.rpos == CONSBUFSIZE)
f0100571:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100577:	74 02                	je     f010057b <cons_getc+0x37>
}
f0100579:	c9                   	leave  
f010057a:	c3                   	ret    
			cons.rpos = 0;
f010057b:	c7 05 20 75 11 f0 00 	movl   $0x0,0xf0117520
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
f01005b7:	c7 05 30 75 11 f0 b4 	movl   $0x3b4,0xf0117530
f01005be:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005c1:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f01005c6:	8b 3d 30 75 11 f0    	mov    0xf0117530,%edi
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
f01005e7:	89 35 2c 75 11 f0    	mov    %esi,0xf011752c
	pos |= inb(addr_6845 + 1);
f01005ed:	0f b6 c0             	movzbl %al,%eax
f01005f0:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01005f2:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
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
f010063c:	0f 95 05 34 75 11 f0 	setne  0xf0117534
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
f0100660:	c7 05 30 75 11 f0 d4 	movl   $0x3d4,0xf0117530
f0100667:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010066a:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f010066f:	e9 52 ff ff ff       	jmp    f01005c6 <cons_init+0x38>
		cprintf("Serial port does not exist!\n");
f0100674:	83 ec 0c             	sub    $0xc,%esp
f0100677:	68 24 39 10 f0       	push   $0xf0103924
f010067c:	e8 2e 22 00 00       	call   f01028af <cprintf>
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
f01006b7:	68 80 3b 10 f0       	push   $0xf0103b80
f01006bc:	68 9e 3b 10 f0       	push   $0xf0103b9e
f01006c1:	68 a3 3b 10 f0       	push   $0xf0103ba3
f01006c6:	e8 e4 21 00 00       	call   f01028af <cprintf>
f01006cb:	83 c4 0c             	add    $0xc,%esp
f01006ce:	68 38 3c 10 f0       	push   $0xf0103c38
f01006d3:	68 ac 3b 10 f0       	push   $0xf0103bac
f01006d8:	68 a3 3b 10 f0       	push   $0xf0103ba3
f01006dd:	e8 cd 21 00 00       	call   f01028af <cprintf>
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
f01006ef:	68 b5 3b 10 f0       	push   $0xf0103bb5
f01006f4:	e8 b6 21 00 00       	call   f01028af <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006f9:	83 c4 08             	add    $0x8,%esp
f01006fc:	68 0c 00 10 00       	push   $0x10000c
f0100701:	68 60 3c 10 f0       	push   $0xf0103c60
f0100706:	e8 a4 21 00 00       	call   f01028af <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010070b:	83 c4 0c             	add    $0xc,%esp
f010070e:	68 0c 00 10 00       	push   $0x10000c
f0100713:	68 0c 00 10 f0       	push   $0xf010000c
f0100718:	68 88 3c 10 f0       	push   $0xf0103c88
f010071d:	e8 8d 21 00 00       	call   f01028af <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100722:	83 c4 0c             	add    $0xc,%esp
f0100725:	68 c4 37 10 00       	push   $0x1037c4
f010072a:	68 c4 37 10 f0       	push   $0xf01037c4
f010072f:	68 ac 3c 10 f0       	push   $0xf0103cac
f0100734:	e8 76 21 00 00       	call   f01028af <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100739:	83 c4 0c             	add    $0xc,%esp
f010073c:	68 00 73 11 00       	push   $0x117300
f0100741:	68 00 73 11 f0       	push   $0xf0117300
f0100746:	68 d0 3c 10 f0       	push   $0xf0103cd0
f010074b:	e8 5f 21 00 00       	call   f01028af <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100750:	83 c4 0c             	add    $0xc,%esp
f0100753:	68 70 79 11 00       	push   $0x117970
f0100758:	68 70 79 11 f0       	push   $0xf0117970
f010075d:	68 f4 3c 10 f0       	push   $0xf0103cf4
f0100762:	e8 48 21 00 00       	call   f01028af <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100767:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010076a:	b8 6f 7d 11 f0       	mov    $0xf0117d6f,%eax
f010076f:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100774:	c1 f8 0a             	sar    $0xa,%eax
f0100777:	50                   	push   %eax
f0100778:	68 18 3d 10 f0       	push   $0xf0103d18
f010077d:	e8 2d 21 00 00       	call   f01028af <cprintf>
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
f0100792:	68 ce 3b 10 f0       	push   $0xf0103bce
f0100797:	e8 13 21 00 00       	call   f01028af <cprintf>

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
f01007ae:	68 f1 3b 10 f0       	push   $0xf0103bf1
f01007b3:	e8 f7 20 00 00       	call   f01028af <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f01007b8:	43                   	inc    %ebx
f01007b9:	83 c4 10             	add    $0x10,%esp
f01007bc:	39 5d dc             	cmp    %ebx,-0x24(%ebp)
f01007bf:	7f e2                	jg     f01007a3 <mon_backtrace+0x1a>
		cprintf("+%d\n", eip - info.eip_fn_addr);
f01007c1:	83 ec 08             	sub    $0x8,%esp
f01007c4:	2b 75 e0             	sub    -0x20(%ebp),%esi
f01007c7:	56                   	push   %esi
f01007c8:	68 f4 3b 10 f0       	push   $0xf0103bf4
f01007cd:	e8 dd 20 00 00       	call   f01028af <cprintf>
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
f01007f1:	68 44 3d 10 f0       	push   $0xf0103d44
f01007f6:	e8 b4 20 00 00       	call   f01028af <cprintf>
		int code = debuginfo_eip((uintptr_t)eip, &info);
f01007fb:	83 c4 18             	add    $0x18,%esp
f01007fe:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100801:	50                   	push   %eax
f0100802:	56                   	push   %esi
f0100803:	e8 a8 21 00 00       	call   f01029b0 <debuginfo_eip>
		cprintf("         %s:%d: ", info.eip_file, info.eip_line);
f0100808:	83 c4 0c             	add    $0xc,%esp
f010080b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010080e:	ff 75 d0             	pushl  -0x30(%ebp)
f0100811:	68 e0 3b 10 f0       	push   $0xf0103be0
f0100816:	e8 94 20 00 00       	call   f01028af <cprintf>
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
f0100836:	68 7c 3d 10 f0       	push   $0xf0103d7c
f010083b:	e8 6f 20 00 00       	call   f01028af <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100840:	c7 04 24 a0 3d 10 f0 	movl   $0xf0103da0,(%esp)
f0100847:	e8 63 20 00 00       	call   f01028af <cprintf>
f010084c:	83 c4 10             	add    $0x10,%esp
f010084f:	eb 47                	jmp    f0100898 <monitor+0x6b>
		while (*buf && strchr(WHITESPACE, *buf))
f0100851:	83 ec 08             	sub    $0x8,%esp
f0100854:	0f be c0             	movsbl %al,%eax
f0100857:	50                   	push   %eax
f0100858:	68 fd 3b 10 f0       	push   $0xf0103bfd
f010085d:	e8 47 2b 00 00       	call   f01033a9 <strchr>
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
f010088b:	68 02 3c 10 f0       	push   $0xf0103c02
f0100890:	e8 1a 20 00 00       	call   f01028af <cprintf>
f0100895:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100898:	83 ec 0c             	sub    $0xc,%esp
f010089b:	68 f9 3b 10 f0       	push   $0xf0103bf9
f01008a0:	e8 f9 28 00 00       	call   f010319e <readline>
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
f01008ca:	68 fd 3b 10 f0       	push   $0xf0103bfd
f01008cf:	e8 d5 2a 00 00       	call   f01033a9 <strchr>
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
f01008f6:	68 9e 3b 10 f0       	push   $0xf0103b9e
f01008fb:	ff 75 a8             	pushl  -0x58(%ebp)
f01008fe:	e8 52 2a 00 00       	call   f0103355 <strcmp>
f0100903:	83 c4 10             	add    $0x10,%esp
f0100906:	85 c0                	test   %eax,%eax
f0100908:	74 34                	je     f010093e <monitor+0x111>
f010090a:	83 ec 08             	sub    $0x8,%esp
f010090d:	68 ac 3b 10 f0       	push   $0xf0103bac
f0100912:	ff 75 a8             	pushl  -0x58(%ebp)
f0100915:	e8 3b 2a 00 00       	call   f0103355 <strcmp>
f010091a:	83 c4 10             	add    $0x10,%esp
f010091d:	85 c0                	test   %eax,%eax
f010091f:	74 18                	je     f0100939 <monitor+0x10c>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100921:	83 ec 08             	sub    $0x8,%esp
f0100924:	ff 75 a8             	pushl  -0x58(%ebp)
f0100927:	68 1f 3c 10 f0       	push   $0xf0103c1f
f010092c:	e8 7e 1f 00 00       	call   f01028af <cprintf>
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
f010094e:	ff 14 85 d0 3d 10 f0 	call   *-0xfefc230(,%eax,4)
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
f010096b:	83 3d 38 75 11 f0 00 	cmpl   $0x0,0xf0117538
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
f0100978:	8b 15 38 75 11 f0    	mov    0xf0117538,%edx
		nextfree = ROUNDUP(nextfree + n, PGSIZE);
f010097e:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100985:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010098a:	a3 38 75 11 f0       	mov    %eax,0xf0117538
		return (void*)result;
	}
}
f010098f:	89 d0                	mov    %edx,%eax
f0100991:	5d                   	pop    %ebp
f0100992:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100993:	ba 6f 89 11 f0       	mov    $0xf011896f,%edx
f0100998:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010099e:	89 15 38 75 11 f0    	mov    %edx,0xf0117538
f01009a4:	eb ce                	jmp    f0100974 <boot_alloc+0xc>
		return (void*)nextfree;
f01009a6:	8b 15 38 75 11 f0    	mov    0xf0117538,%edx
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
f01009b9:	e8 8a 1e 00 00       	call   f0102848 <mc146818_read>
f01009be:	89 c3                	mov    %eax,%ebx
f01009c0:	46                   	inc    %esi
f01009c1:	89 34 24             	mov    %esi,(%esp)
f01009c4:	e8 7f 1e 00 00       	call   f0102848 <mc146818_read>
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
	if (!(*pgdir & PTE_P))
f01009da:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01009dd:	a8 01                	test   $0x1,%al
f01009df:	74 47                	je     f0100a28 <check_va2pa+0x53>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01009e1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01009e6:	89 c1                	mov    %eax,%ecx
f01009e8:	c1 e9 0c             	shr    $0xc,%ecx
f01009eb:	3b 0d 64 79 11 f0    	cmp    0xf0117964,%ecx
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
f0100a14:	68 e0 3d 10 f0       	push   $0xf0103de0
f0100a19:	68 bd 02 00 00       	push   $0x2bd
f0100a1e:	68 80 45 10 f0       	push   $0xf0104580
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
f0100a45:	83 3d 3c 75 11 f0 00 	cmpl   $0x0,0xf011753c
f0100a4c:	74 0a                	je     f0100a58 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a4e:	be 00 04 00 00       	mov    $0x400,%esi
f0100a53:	e9 98 02 00 00       	jmp    f0100cf0 <check_page_free_list+0x2bc>
		panic("'page_free_list' is a null pointer!");
f0100a58:	83 ec 04             	sub    $0x4,%esp
f0100a5b:	68 04 3e 10 f0       	push   $0xf0103e04
f0100a60:	68 fc 01 00 00       	push   $0x1fc
f0100a65:	68 80 45 10 f0       	push   $0xf0104580
f0100a6a:	e8 c4 f6 ff ff       	call   f0100133 <_panic>
f0100a6f:	50                   	push   %eax
f0100a70:	68 e0 3d 10 f0       	push   $0xf0103de0
f0100a75:	6a 52                	push   $0x52
f0100a77:	68 8c 45 10 f0       	push   $0xf010458c
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
f0100a89:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
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
f0100aa3:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0100aa9:	73 c4                	jae    f0100a6f <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100aab:	83 ec 04             	sub    $0x4,%esp
f0100aae:	68 80 00 00 00       	push   $0x80
f0100ab3:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100ab8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100abd:	50                   	push   %eax
f0100abe:	e8 1b 29 00 00       	call   f01033de <memset>
f0100ac3:	83 c4 10             	add    $0x10,%esp
f0100ac6:	eb b9                	jmp    f0100a81 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100ac8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100acd:	e8 96 fe ff ff       	call   f0100968 <boot_alloc>
f0100ad2:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ad5:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
		assert(pp >= pages);
f0100adb:	8b 0d 6c 79 11 f0    	mov    0xf011796c,%ecx
		assert(pp < pages + npages);
f0100ae1:	a1 64 79 11 f0       	mov    0xf0117964,%eax
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
f0100afc:	68 9a 45 10 f0       	push   $0xf010459a
f0100b01:	68 a6 45 10 f0       	push   $0xf01045a6
f0100b06:	68 16 02 00 00       	push   $0x216
f0100b0b:	68 80 45 10 f0       	push   $0xf0104580
f0100b10:	e8 1e f6 ff ff       	call   f0100133 <_panic>
		assert(pp < pages + npages);
f0100b15:	68 bb 45 10 f0       	push   $0xf01045bb
f0100b1a:	68 a6 45 10 f0       	push   $0xf01045a6
f0100b1f:	68 17 02 00 00       	push   $0x217
f0100b24:	68 80 45 10 f0       	push   $0xf0104580
f0100b29:	e8 05 f6 ff ff       	call   f0100133 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b2e:	68 28 3e 10 f0       	push   $0xf0103e28
f0100b33:	68 a6 45 10 f0       	push   $0xf01045a6
f0100b38:	68 18 02 00 00       	push   $0x218
f0100b3d:	68 80 45 10 f0       	push   $0xf0104580
f0100b42:	e8 ec f5 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) != 0);
f0100b47:	68 cf 45 10 f0       	push   $0xf01045cf
f0100b4c:	68 a6 45 10 f0       	push   $0xf01045a6
f0100b51:	68 1b 02 00 00       	push   $0x21b
f0100b56:	68 80 45 10 f0       	push   $0xf0104580
f0100b5b:	e8 d3 f5 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100b60:	68 e0 45 10 f0       	push   $0xf01045e0
f0100b65:	68 a6 45 10 f0       	push   $0xf01045a6
f0100b6a:	68 1c 02 00 00       	push   $0x21c
f0100b6f:	68 80 45 10 f0       	push   $0xf0104580
f0100b74:	e8 ba f5 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100b79:	68 5c 3e 10 f0       	push   $0xf0103e5c
f0100b7e:	68 a6 45 10 f0       	push   $0xf01045a6
f0100b83:	68 1d 02 00 00       	push   $0x21d
f0100b88:	68 80 45 10 f0       	push   $0xf0104580
f0100b8d:	e8 a1 f5 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100b92:	68 f9 45 10 f0       	push   $0xf01045f9
f0100b97:	68 a6 45 10 f0       	push   $0xf01045a6
f0100b9c:	68 1e 02 00 00       	push   $0x21e
f0100ba1:	68 80 45 10 f0       	push   $0xf0104580
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
f0100c19:	68 e0 3d 10 f0       	push   $0xf0103de0
f0100c1e:	6a 52                	push   $0x52
f0100c20:	68 8c 45 10 f0       	push   $0xf010458c
f0100c25:	e8 09 f5 ff ff       	call   f0100133 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c2a:	68 80 3e 10 f0       	push   $0xf0103e80
f0100c2f:	68 a6 45 10 f0       	push   $0xf01045a6
f0100c34:	68 1f 02 00 00       	push   $0x21f
f0100c39:	68 80 45 10 f0       	push   $0xf0104580
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
f0100c51:	68 c8 3e 10 f0       	push   $0xf0103ec8
f0100c56:	e8 54 1c 00 00       	call   f01028af <cprintf>
}
f0100c5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c5e:	5b                   	pop    %ebx
f0100c5f:	5e                   	pop    %esi
f0100c60:	5f                   	pop    %edi
f0100c61:	5d                   	pop    %ebp
f0100c62:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100c63:	68 13 46 10 f0       	push   $0xf0104613
f0100c68:	68 a6 45 10 f0       	push   $0xf01045a6
f0100c6d:	68 27 02 00 00       	push   $0x227
f0100c72:	68 80 45 10 f0       	push   $0xf0104580
f0100c77:	e8 b7 f4 ff ff       	call   f0100133 <_panic>
	assert(nfree_extmem > 0);
f0100c7c:	68 25 46 10 f0       	push   $0xf0104625
f0100c81:	68 a6 45 10 f0       	push   $0xf01045a6
f0100c86:	68 28 02 00 00       	push   $0x228
f0100c8b:	68 80 45 10 f0       	push   $0xf0104580
f0100c90:	e8 9e f4 ff ff       	call   f0100133 <_panic>
	if (!page_free_list)
f0100c95:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0100c9a:	85 c0                	test   %eax,%eax
f0100c9c:	0f 84 b6 fd ff ff    	je     f0100a58 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100ca2:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100ca5:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100ca8:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100cab:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100cae:	89 c2                	mov    %eax,%edx
f0100cb0:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
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
f0100ce6:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ceb:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100cf0:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100cf6:	e9 88 fd ff ff       	jmp    f0100a83 <check_page_free_list+0x4f>

f0100cfb <page_init>:
{
f0100cfb:	55                   	push   %ebp
f0100cfc:	89 e5                	mov    %esp,%ebp
f0100cfe:	57                   	push   %edi
f0100cff:	56                   	push   %esi
f0100d00:	53                   	push   %ebx
	for (i = 1; i < npages_basemem; i++) {
f0100d01:	8b 35 40 75 11 f0    	mov    0xf0117540,%esi
f0100d07:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100d0d:	b2 00                	mov    $0x0,%dl
f0100d0f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100d14:	bf 01 00 00 00       	mov    $0x1,%edi
f0100d19:	eb 22                	jmp    f0100d3d <page_init+0x42>
		pages[i].pp_ref = 0;
f0100d1b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100d22:	89 d1                	mov    %edx,%ecx
f0100d24:	03 0d 6c 79 11 f0    	add    0xf011796c,%ecx
f0100d2a:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100d30:	89 19                	mov    %ebx,(%ecx)
	for (i = 1; i < npages_basemem; i++) {
f0100d32:	40                   	inc    %eax
		page_free_list = &pages[i];
f0100d33:	89 d3                	mov    %edx,%ebx
f0100d35:	03 1d 6c 79 11 f0    	add    0xf011796c,%ebx
f0100d3b:	89 fa                	mov    %edi,%edx
	for (i = 1; i < npages_basemem; i++) {
f0100d3d:	39 c6                	cmp    %eax,%esi
f0100d3f:	77 da                	ja     f0100d1b <page_init+0x20>
f0100d41:	84 d2                	test   %dl,%dl
f0100d43:	75 33                	jne    f0100d78 <page_init+0x7d>
	size_t table_size = PTX(8*npages);;
f0100d45:	8b 15 64 79 11 f0    	mov    0xf0117964,%edx
f0100d4b:	c1 e2 0d             	shl    $0xd,%edx
f0100d4e:	c1 ea 16             	shr    $0x16,%edx
	size_t end_idx = PTX(ROUNDUP((char *) end, PGSIZE));
f0100d51:	b8 6f 89 11 f0       	mov    $0xf011896f,%eax
f0100d56:	c1 e8 0c             	shr    $0xc,%eax
f0100d59:	25 ff 03 00 00       	and    $0x3ff,%eax
	for (i = table_size + end_idx + 1; i < npages; i++) {
f0100d5e:	8d 54 02 01          	lea    0x1(%edx,%eax,1),%edx
f0100d62:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100d68:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0100d6f:	b1 00                	mov    $0x0,%cl
f0100d71:	be 01 00 00 00       	mov    $0x1,%esi
f0100d76:	eb 26                	jmp    f0100d9e <page_init+0xa3>
f0100d78:	89 1d 3c 75 11 f0    	mov    %ebx,0xf011753c
f0100d7e:	eb c5                	jmp    f0100d45 <page_init+0x4a>
		pages[i].pp_ref = 0;
f0100d80:	89 c1                	mov    %eax,%ecx
f0100d82:	03 0d 6c 79 11 f0    	add    0xf011796c,%ecx
f0100d88:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100d8e:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0100d90:	89 c3                	mov    %eax,%ebx
f0100d92:	03 1d 6c 79 11 f0    	add    0xf011796c,%ebx
	for (i = table_size + end_idx + 1; i < npages; i++) {
f0100d98:	42                   	inc    %edx
f0100d99:	83 c0 08             	add    $0x8,%eax
f0100d9c:	89 f1                	mov    %esi,%ecx
f0100d9e:	39 15 64 79 11 f0    	cmp    %edx,0xf0117964
f0100da4:	77 da                	ja     f0100d80 <page_init+0x85>
f0100da6:	84 c9                	test   %cl,%cl
f0100da8:	75 05                	jne    f0100daf <page_init+0xb4>
}
f0100daa:	5b                   	pop    %ebx
f0100dab:	5e                   	pop    %esi
f0100dac:	5f                   	pop    %edi
f0100dad:	5d                   	pop    %ebp
f0100dae:	c3                   	ret    
f0100daf:	89 1d 3c 75 11 f0    	mov    %ebx,0xf011753c
f0100db5:	eb f3                	jmp    f0100daa <page_init+0xaf>

f0100db7 <page_alloc>:
{
f0100db7:	55                   	push   %ebp
f0100db8:	89 e5                	mov    %esp,%ebp
f0100dba:	53                   	push   %ebx
f0100dbb:	83 ec 04             	sub    $0x4,%esp
	struct PageInfo* next = page_free_list;
f0100dbe:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
	if (!next)
f0100dc4:	85 db                	test   %ebx,%ebx
f0100dc6:	74 13                	je     f0100ddb <page_alloc+0x24>
	page_free_list = page_free_list->pp_link;
f0100dc8:	8b 03                	mov    (%ebx),%eax
f0100dca:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
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
f0100de4:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0100dea:	c1 f8 03             	sar    $0x3,%eax
f0100ded:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100df0:	89 c2                	mov    %eax,%edx
f0100df2:	c1 ea 0c             	shr    $0xc,%edx
f0100df5:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0100dfb:	73 1a                	jae    f0100e17 <page_alloc+0x60>
		memset(content, 0, PGSIZE);
f0100dfd:	83 ec 04             	sub    $0x4,%esp
f0100e00:	68 00 10 00 00       	push   $0x1000
f0100e05:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100e07:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e0c:	50                   	push   %eax
f0100e0d:	e8 cc 25 00 00       	call   f01033de <memset>
f0100e12:	83 c4 10             	add    $0x10,%esp
f0100e15:	eb c4                	jmp    f0100ddb <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e17:	50                   	push   %eax
f0100e18:	68 e0 3d 10 f0       	push   $0xf0103de0
f0100e1d:	6a 52                	push   $0x52
f0100e1f:	68 8c 45 10 f0       	push   $0xf010458c
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
f0100e3e:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
f0100e44:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100e46:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
}
f0100e4b:	c9                   	leave  
f0100e4c:	c3                   	ret    
		panic("Ref count is non-zero");
f0100e4d:	83 ec 04             	sub    $0x4,%esp
f0100e50:	68 36 46 10 f0       	push   $0xf0104636
f0100e55:	68 36 01 00 00       	push   $0x136
f0100e5a:	68 80 45 10 f0       	push   $0xf0104580
f0100e5f:	e8 cf f2 ff ff       	call   f0100133 <_panic>
		panic("Page is double-freed");
f0100e64:	83 ec 04             	sub    $0x4,%esp
f0100e67:	68 4c 46 10 f0       	push   $0xf010464c
f0100e6c:	68 38 01 00 00       	push   $0x138
f0100e71:	68 80 45 10 f0       	push   $0xf0104580
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
f0100ec6:	39 15 64 79 11 f0    	cmp    %edx,0xf0117964
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
f0100eea:	68 e0 3d 10 f0       	push   $0xf0103de0
f0100eef:	68 63 01 00 00       	push   $0x163
f0100ef4:	68 80 45 10 f0       	push   $0xf0104580
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
f0100f1f:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0100f25:	c1 f8 03             	sar    $0x3,%eax
f0100f28:	c1 e0 0c             	shl    $0xc,%eax
f0100f2b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (PGNUM(pa) >= npages)
f0100f2e:	c1 e8 0c             	shr    $0xc,%eax
f0100f31:	3b 05 64 79 11 f0    	cmp    0xf0117964,%eax
f0100f37:	73 44                	jae    f0100f7d <pgdir_walk+0xdc>
	return (void *)(pa + KERNBASE);
f0100f39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f3c:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
			memset(content, 0, PGSIZE);
f0100f42:	83 ec 04             	sub    $0x4,%esp
f0100f45:	68 00 10 00 00       	push   $0x1000
f0100f4a:	6a 00                	push   $0x0
f0100f4c:	56                   	push   %esi
f0100f4d:	e8 8c 24 00 00       	call   f01033de <memset>
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
f0100f80:	68 e0 3d 10 f0       	push   $0xf0103de0
f0100f85:	6a 52                	push   $0x52
f0100f87:	68 8c 45 10 f0       	push   $0xf010458c
f0100f8c:	e8 a2 f1 ff ff       	call   f0100133 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f91:	56                   	push   %esi
f0100f92:	68 ec 3e 10 f0       	push   $0xf0103eec
f0100f97:	68 6c 01 00 00       	push   $0x16c
f0100f9c:	68 80 45 10 f0       	push   $0xf0104580
f0100fa1:	e8 8d f1 ff ff       	call   f0100133 <_panic>
	return NULL;
f0100fa6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fab:	e9 31 ff ff ff       	jmp    f0100ee1 <pgdir_walk+0x40>
f0100fb0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fb5:	e9 27 ff ff ff       	jmp    f0100ee1 <pgdir_walk+0x40>

f0100fba <page_lookup>:
{
f0100fba:	55                   	push   %ebp
f0100fbb:	89 e5                	mov    %esp,%ebp
f0100fbd:	53                   	push   %ebx
f0100fbe:	83 ec 08             	sub    $0x8,%esp
f0100fc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *page_entry = pgdir_walk(pgdir, (void*) va, 0);
f0100fc4:	6a 00                	push   $0x0
f0100fc6:	ff 75 0c             	pushl  0xc(%ebp)
f0100fc9:	ff 75 08             	pushl  0x8(%ebp)
f0100fcc:	e8 d0 fe ff ff       	call   f0100ea1 <pgdir_walk>
	if (!page_entry || !*page_entry)
f0100fd1:	83 c4 10             	add    $0x10,%esp
f0100fd4:	85 c0                	test   %eax,%eax
f0100fd6:	74 3a                	je     f0101012 <page_lookup+0x58>
f0100fd8:	83 38 00             	cmpl   $0x0,(%eax)
f0100fdb:	74 3c                	je     f0101019 <page_lookup+0x5f>
	if (pte_store)
f0100fdd:	85 db                	test   %ebx,%ebx
f0100fdf:	74 02                	je     f0100fe3 <page_lookup+0x29>
		*pte_store = page_entry;
f0100fe1:	89 03                	mov    %eax,(%ebx)
f0100fe3:	8b 00                	mov    (%eax),%eax
f0100fe5:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fe8:	39 05 64 79 11 f0    	cmp    %eax,0xf0117964
f0100fee:	76 0e                	jbe    f0100ffe <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0100ff0:	8b 15 6c 79 11 f0    	mov    0xf011796c,%edx
f0100ff6:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0100ff9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ffc:	c9                   	leave  
f0100ffd:	c3                   	ret    
		panic("pa2page called with invalid pa");
f0100ffe:	83 ec 04             	sub    $0x4,%esp
f0101001:	68 10 3f 10 f0       	push   $0xf0103f10
f0101006:	6a 4b                	push   $0x4b
f0101008:	68 8c 45 10 f0       	push   $0xf010458c
f010100d:	e8 21 f1 ff ff       	call   f0100133 <_panic>
		return NULL;
f0101012:	b8 00 00 00 00       	mov    $0x0,%eax
f0101017:	eb e0                	jmp    f0100ff9 <page_lookup+0x3f>
f0101019:	b8 00 00 00 00       	mov    $0x0,%eax
f010101e:	eb d9                	jmp    f0100ff9 <page_lookup+0x3f>

f0101020 <page_remove>:
{
f0101020:	55                   	push   %ebp
f0101021:	89 e5                	mov    %esp,%ebp
f0101023:	83 ec 1c             	sub    $0x1c,%esp
	struct PageInfo *pp = page_lookup(pgdir, va, &pte_store);
f0101026:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101029:	50                   	push   %eax
f010102a:	ff 75 0c             	pushl  0xc(%ebp)
f010102d:	ff 75 08             	pushl  0x8(%ebp)
f0101030:	e8 85 ff ff ff       	call   f0100fba <page_lookup>
	if (!pp)
f0101035:	83 c4 10             	add    $0x10,%esp
f0101038:	85 c0                	test   %eax,%eax
f010103a:	74 14                	je     f0101050 <page_remove+0x30>
	pp->pp_ref--;
f010103c:	66 ff 48 04          	decw   0x4(%eax)
	*pte_store = 0;
f0101040:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101043:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	if (!pp->pp_ref)
f0101049:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010104e:	74 02                	je     f0101052 <page_remove+0x32>
}
f0101050:	c9                   	leave  
f0101051:	c3                   	ret    
		page_free(pp);
f0101052:	83 ec 0c             	sub    $0xc,%esp
f0101055:	50                   	push   %eax
f0101056:	e8 ce fd ff ff       	call   f0100e29 <page_free>
f010105b:	83 c4 10             	add    $0x10,%esp
f010105e:	eb f0                	jmp    f0101050 <page_remove+0x30>

f0101060 <page_insert>:
{
f0101060:	55                   	push   %ebp
f0101061:	89 e5                	mov    %esp,%ebp
f0101063:	57                   	push   %edi
f0101064:	56                   	push   %esi
f0101065:	53                   	push   %ebx
f0101066:	83 ec 10             	sub    $0x10,%esp
f0101069:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010106c:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *page_entry = pgdir_walk(pgdir, (void*) va, 1);
f010106f:	6a 01                	push   $0x1
f0101071:	57                   	push   %edi
f0101072:	ff 75 08             	pushl  0x8(%ebp)
f0101075:	e8 27 fe ff ff       	call   f0100ea1 <pgdir_walk>
	if (!page_entry)
f010107a:	83 c4 10             	add    $0x10,%esp
f010107d:	85 c0                	test   %eax,%eax
f010107f:	74 3f                	je     f01010c0 <page_insert+0x60>
f0101081:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f0101083:	66 ff 43 04          	incw   0x4(%ebx)
	if (*page_entry) 
f0101087:	83 38 00             	cmpl   $0x0,(%eax)
f010108a:	75 23                	jne    f01010af <page_insert+0x4f>
	return (pp - pages) << PGSHIFT;
f010108c:	2b 1d 6c 79 11 f0    	sub    0xf011796c,%ebx
f0101092:	c1 fb 03             	sar    $0x3,%ebx
f0101095:	c1 e3 0c             	shl    $0xc,%ebx
	*page_entry = page2pa(pp) | perm | PTE_P;
f0101098:	8b 45 14             	mov    0x14(%ebp),%eax
f010109b:	83 c8 01             	or     $0x1,%eax
f010109e:	09 c3                	or     %eax,%ebx
f01010a0:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01010a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01010a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010aa:	5b                   	pop    %ebx
f01010ab:	5e                   	pop    %esi
f01010ac:	5f                   	pop    %edi
f01010ad:	5d                   	pop    %ebp
f01010ae:	c3                   	ret    
		page_remove(pgdir, va);
f01010af:	83 ec 08             	sub    $0x8,%esp
f01010b2:	57                   	push   %edi
f01010b3:	ff 75 08             	pushl  0x8(%ebp)
f01010b6:	e8 65 ff ff ff       	call   f0101020 <page_remove>
f01010bb:	83 c4 10             	add    $0x10,%esp
f01010be:	eb cc                	jmp    f010108c <page_insert+0x2c>
		return -E_NO_MEM;  // Has no page table AND cannot be allocated
f01010c0:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01010c5:	eb e0                	jmp    f01010a7 <page_insert+0x47>

f01010c7 <mem_init>:
{
f01010c7:	55                   	push   %ebp
f01010c8:	89 e5                	mov    %esp,%ebp
f01010ca:	57                   	push   %edi
f01010cb:	56                   	push   %esi
f01010cc:	53                   	push   %ebx
f01010cd:	83 ec 2c             	sub    $0x2c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f01010d0:	b8 15 00 00 00       	mov    $0x15,%eax
f01010d5:	e8 d4 f8 ff ff       	call   f01009ae <nvram_read>
f01010da:	89 c6                	mov    %eax,%esi
	extmem = nvram_read(NVRAM_EXTLO);
f01010dc:	b8 17 00 00 00       	mov    $0x17,%eax
f01010e1:	e8 c8 f8 ff ff       	call   f01009ae <nvram_read>
f01010e6:	89 c3                	mov    %eax,%ebx
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01010e8:	b8 34 00 00 00       	mov    $0x34,%eax
f01010ed:	e8 bc f8 ff ff       	call   f01009ae <nvram_read>
	if (ext16mem)
f01010f2:	c1 e0 06             	shl    $0x6,%eax
f01010f5:	75 10                	jne    f0101107 <mem_init+0x40>
	else if (extmem)
f01010f7:	85 db                	test   %ebx,%ebx
f01010f9:	0f 84 c3 00 00 00    	je     f01011c2 <mem_init+0xfb>
		totalmem = 1 * 1024 + extmem;
f01010ff:	8d 83 00 04 00 00    	lea    0x400(%ebx),%eax
f0101105:	eb 05                	jmp    f010110c <mem_init+0x45>
		totalmem = 16 * 1024 + ext16mem;
f0101107:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f010110c:	89 c2                	mov    %eax,%edx
f010110e:	c1 ea 02             	shr    $0x2,%edx
f0101111:	89 15 64 79 11 f0    	mov    %edx,0xf0117964
	npages_basemem = basemem / (PGSIZE / 1024);
f0101117:	89 f2                	mov    %esi,%edx
f0101119:	c1 ea 02             	shr    $0x2,%edx
f010111c:	89 15 40 75 11 f0    	mov    %edx,0xf0117540
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101122:	89 c2                	mov    %eax,%edx
f0101124:	29 f2                	sub    %esi,%edx
f0101126:	52                   	push   %edx
f0101127:	56                   	push   %esi
f0101128:	50                   	push   %eax
f0101129:	68 30 3f 10 f0       	push   $0xf0103f30
f010112e:	e8 7c 17 00 00       	call   f01028af <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101133:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101138:	e8 2b f8 ff ff       	call   f0100968 <boot_alloc>
f010113d:	a3 68 79 11 f0       	mov    %eax,0xf0117968
	memset(kern_pgdir, 0, PGSIZE);
f0101142:	83 c4 0c             	add    $0xc,%esp
f0101145:	68 00 10 00 00       	push   $0x1000
f010114a:	6a 00                	push   $0x0
f010114c:	50                   	push   %eax
f010114d:	e8 8c 22 00 00       	call   f01033de <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101152:	a1 68 79 11 f0       	mov    0xf0117968,%eax
	if ((uint32_t)kva < KERNBASE)
f0101157:	83 c4 10             	add    $0x10,%esp
f010115a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010115f:	76 68                	jbe    f01011c9 <mem_init+0x102>
	return (physaddr_t)kva - KERNBASE;
f0101161:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101167:	83 ca 05             	or     $0x5,%edx
f010116a:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(8*npages);
f0101170:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f0101175:	c1 e0 03             	shl    $0x3,%eax
f0101178:	e8 eb f7 ff ff       	call   f0100968 <boot_alloc>
f010117d:	a3 6c 79 11 f0       	mov    %eax,0xf011796c
	memset(pages, 0, 8*npages);
f0101182:	83 ec 04             	sub    $0x4,%esp
f0101185:	8b 0d 64 79 11 f0    	mov    0xf0117964,%ecx
f010118b:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101192:	52                   	push   %edx
f0101193:	6a 00                	push   $0x0
f0101195:	50                   	push   %eax
f0101196:	e8 43 22 00 00       	call   f01033de <memset>
	page_init();
f010119b:	e8 5b fb ff ff       	call   f0100cfb <page_init>
	check_page_free_list(1);
f01011a0:	b8 01 00 00 00       	mov    $0x1,%eax
f01011a5:	e8 8a f8 ff ff       	call   f0100a34 <check_page_free_list>
	if (!pages)
f01011aa:	83 c4 10             	add    $0x10,%esp
f01011ad:	83 3d 6c 79 11 f0 00 	cmpl   $0x0,0xf011796c
f01011b4:	74 28                	je     f01011de <mem_init+0x117>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01011b6:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f01011bb:	bb 00 00 00 00       	mov    $0x0,%ebx
f01011c0:	eb 36                	jmp    f01011f8 <mem_init+0x131>
		totalmem = basemem;
f01011c2:	89 f0                	mov    %esi,%eax
f01011c4:	e9 43 ff ff ff       	jmp    f010110c <mem_init+0x45>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01011c9:	50                   	push   %eax
f01011ca:	68 ec 3e 10 f0       	push   $0xf0103eec
f01011cf:	68 91 00 00 00       	push   $0x91
f01011d4:	68 80 45 10 f0       	push   $0xf0104580
f01011d9:	e8 55 ef ff ff       	call   f0100133 <_panic>
		panic("'pages' is a null pointer!");
f01011de:	83 ec 04             	sub    $0x4,%esp
f01011e1:	68 61 46 10 f0       	push   $0xf0104661
f01011e6:	68 3b 02 00 00       	push   $0x23b
f01011eb:	68 80 45 10 f0       	push   $0xf0104580
f01011f0:	e8 3e ef ff ff       	call   f0100133 <_panic>
		++nfree;
f01011f5:	43                   	inc    %ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01011f6:	8b 00                	mov    (%eax),%eax
f01011f8:	85 c0                	test   %eax,%eax
f01011fa:	75 f9                	jne    f01011f5 <mem_init+0x12e>
	assert((pp0 = page_alloc(0)));
f01011fc:	83 ec 0c             	sub    $0xc,%esp
f01011ff:	6a 00                	push   $0x0
f0101201:	e8 b1 fb ff ff       	call   f0100db7 <page_alloc>
f0101206:	89 c7                	mov    %eax,%edi
f0101208:	83 c4 10             	add    $0x10,%esp
f010120b:	85 c0                	test   %eax,%eax
f010120d:	0f 84 10 02 00 00    	je     f0101423 <mem_init+0x35c>
	assert((pp1 = page_alloc(0)));
f0101213:	83 ec 0c             	sub    $0xc,%esp
f0101216:	6a 00                	push   $0x0
f0101218:	e8 9a fb ff ff       	call   f0100db7 <page_alloc>
f010121d:	89 c6                	mov    %eax,%esi
f010121f:	83 c4 10             	add    $0x10,%esp
f0101222:	85 c0                	test   %eax,%eax
f0101224:	0f 84 12 02 00 00    	je     f010143c <mem_init+0x375>
	assert((pp2 = page_alloc(0)));
f010122a:	83 ec 0c             	sub    $0xc,%esp
f010122d:	6a 00                	push   $0x0
f010122f:	e8 83 fb ff ff       	call   f0100db7 <page_alloc>
f0101234:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101237:	83 c4 10             	add    $0x10,%esp
f010123a:	85 c0                	test   %eax,%eax
f010123c:	0f 84 13 02 00 00    	je     f0101455 <mem_init+0x38e>
	assert(pp1 && pp1 != pp0);
f0101242:	39 f7                	cmp    %esi,%edi
f0101244:	0f 84 24 02 00 00    	je     f010146e <mem_init+0x3a7>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010124a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010124d:	39 c6                	cmp    %eax,%esi
f010124f:	0f 84 32 02 00 00    	je     f0101487 <mem_init+0x3c0>
f0101255:	39 c7                	cmp    %eax,%edi
f0101257:	0f 84 2a 02 00 00    	je     f0101487 <mem_init+0x3c0>
	return (pp - pages) << PGSHIFT;
f010125d:	8b 0d 6c 79 11 f0    	mov    0xf011796c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101263:	8b 15 64 79 11 f0    	mov    0xf0117964,%edx
f0101269:	c1 e2 0c             	shl    $0xc,%edx
f010126c:	89 f8                	mov    %edi,%eax
f010126e:	29 c8                	sub    %ecx,%eax
f0101270:	c1 f8 03             	sar    $0x3,%eax
f0101273:	c1 e0 0c             	shl    $0xc,%eax
f0101276:	39 d0                	cmp    %edx,%eax
f0101278:	0f 83 22 02 00 00    	jae    f01014a0 <mem_init+0x3d9>
f010127e:	89 f0                	mov    %esi,%eax
f0101280:	29 c8                	sub    %ecx,%eax
f0101282:	c1 f8 03             	sar    $0x3,%eax
f0101285:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101288:	39 c2                	cmp    %eax,%edx
f010128a:	0f 86 29 02 00 00    	jbe    f01014b9 <mem_init+0x3f2>
f0101290:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101293:	29 c8                	sub    %ecx,%eax
f0101295:	c1 f8 03             	sar    $0x3,%eax
f0101298:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f010129b:	39 c2                	cmp    %eax,%edx
f010129d:	0f 86 2f 02 00 00    	jbe    f01014d2 <mem_init+0x40b>
	fl = page_free_list;
f01012a3:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f01012a8:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01012ab:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f01012b2:	00 00 00 
	assert(!page_alloc(0));
f01012b5:	83 ec 0c             	sub    $0xc,%esp
f01012b8:	6a 00                	push   $0x0
f01012ba:	e8 f8 fa ff ff       	call   f0100db7 <page_alloc>
f01012bf:	83 c4 10             	add    $0x10,%esp
f01012c2:	85 c0                	test   %eax,%eax
f01012c4:	0f 85 21 02 00 00    	jne    f01014eb <mem_init+0x424>
	page_free(pp0);
f01012ca:	83 ec 0c             	sub    $0xc,%esp
f01012cd:	57                   	push   %edi
f01012ce:	e8 56 fb ff ff       	call   f0100e29 <page_free>
	page_free(pp1);
f01012d3:	89 34 24             	mov    %esi,(%esp)
f01012d6:	e8 4e fb ff ff       	call   f0100e29 <page_free>
	page_free(pp2);
f01012db:	83 c4 04             	add    $0x4,%esp
f01012de:	ff 75 d4             	pushl  -0x2c(%ebp)
f01012e1:	e8 43 fb ff ff       	call   f0100e29 <page_free>
	assert((pp0 = page_alloc(0)));
f01012e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012ed:	e8 c5 fa ff ff       	call   f0100db7 <page_alloc>
f01012f2:	89 c6                	mov    %eax,%esi
f01012f4:	83 c4 10             	add    $0x10,%esp
f01012f7:	85 c0                	test   %eax,%eax
f01012f9:	0f 84 05 02 00 00    	je     f0101504 <mem_init+0x43d>
	assert((pp1 = page_alloc(0)));
f01012ff:	83 ec 0c             	sub    $0xc,%esp
f0101302:	6a 00                	push   $0x0
f0101304:	e8 ae fa ff ff       	call   f0100db7 <page_alloc>
f0101309:	89 c7                	mov    %eax,%edi
f010130b:	83 c4 10             	add    $0x10,%esp
f010130e:	85 c0                	test   %eax,%eax
f0101310:	0f 84 07 02 00 00    	je     f010151d <mem_init+0x456>
	assert((pp2 = page_alloc(0)));
f0101316:	83 ec 0c             	sub    $0xc,%esp
f0101319:	6a 00                	push   $0x0
f010131b:	e8 97 fa ff ff       	call   f0100db7 <page_alloc>
f0101320:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101323:	83 c4 10             	add    $0x10,%esp
f0101326:	85 c0                	test   %eax,%eax
f0101328:	0f 84 08 02 00 00    	je     f0101536 <mem_init+0x46f>
	assert(pp1 && pp1 != pp0);
f010132e:	39 fe                	cmp    %edi,%esi
f0101330:	0f 84 19 02 00 00    	je     f010154f <mem_init+0x488>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101336:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101339:	39 c7                	cmp    %eax,%edi
f010133b:	0f 84 27 02 00 00    	je     f0101568 <mem_init+0x4a1>
f0101341:	39 c6                	cmp    %eax,%esi
f0101343:	0f 84 1f 02 00 00    	je     f0101568 <mem_init+0x4a1>
	assert(!page_alloc(0));
f0101349:	83 ec 0c             	sub    $0xc,%esp
f010134c:	6a 00                	push   $0x0
f010134e:	e8 64 fa ff ff       	call   f0100db7 <page_alloc>
f0101353:	83 c4 10             	add    $0x10,%esp
f0101356:	85 c0                	test   %eax,%eax
f0101358:	0f 85 23 02 00 00    	jne    f0101581 <mem_init+0x4ba>
f010135e:	89 f0                	mov    %esi,%eax
f0101360:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0101366:	c1 f8 03             	sar    $0x3,%eax
f0101369:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010136c:	89 c2                	mov    %eax,%edx
f010136e:	c1 ea 0c             	shr    $0xc,%edx
f0101371:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0101377:	0f 83 1d 02 00 00    	jae    f010159a <mem_init+0x4d3>
	memset(page2kva(pp0), 1, PGSIZE);
f010137d:	83 ec 04             	sub    $0x4,%esp
f0101380:	68 00 10 00 00       	push   $0x1000
f0101385:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101387:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010138c:	50                   	push   %eax
f010138d:	e8 4c 20 00 00       	call   f01033de <memset>
	page_free(pp0);
f0101392:	89 34 24             	mov    %esi,(%esp)
f0101395:	e8 8f fa ff ff       	call   f0100e29 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010139a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01013a1:	e8 11 fa ff ff       	call   f0100db7 <page_alloc>
f01013a6:	83 c4 10             	add    $0x10,%esp
f01013a9:	85 c0                	test   %eax,%eax
f01013ab:	0f 84 fb 01 00 00    	je     f01015ac <mem_init+0x4e5>
	assert(pp && pp0 == pp);
f01013b1:	39 c6                	cmp    %eax,%esi
f01013b3:	0f 85 0c 02 00 00    	jne    f01015c5 <mem_init+0x4fe>
	return (pp - pages) << PGSHIFT;
f01013b9:	89 f2                	mov    %esi,%edx
f01013bb:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f01013c1:	c1 fa 03             	sar    $0x3,%edx
f01013c4:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01013c7:	89 d0                	mov    %edx,%eax
f01013c9:	c1 e8 0c             	shr    $0xc,%eax
f01013cc:	3b 05 64 79 11 f0    	cmp    0xf0117964,%eax
f01013d2:	0f 83 06 02 00 00    	jae    f01015de <mem_init+0x517>
	return (void *)(pa + KERNBASE);
f01013d8:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01013de:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f01013e4:	80 38 00             	cmpb   $0x0,(%eax)
f01013e7:	0f 85 03 02 00 00    	jne    f01015f0 <mem_init+0x529>
f01013ed:	40                   	inc    %eax
	for (i = 0; i < PGSIZE; i++)
f01013ee:	39 d0                	cmp    %edx,%eax
f01013f0:	75 f2                	jne    f01013e4 <mem_init+0x31d>
	page_free_list = fl;
f01013f2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01013f5:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
	page_free(pp0);
f01013fa:	83 ec 0c             	sub    $0xc,%esp
f01013fd:	56                   	push   %esi
f01013fe:	e8 26 fa ff ff       	call   f0100e29 <page_free>
	page_free(pp1);
f0101403:	89 3c 24             	mov    %edi,(%esp)
f0101406:	e8 1e fa ff ff       	call   f0100e29 <page_free>
	page_free(pp2);
f010140b:	83 c4 04             	add    $0x4,%esp
f010140e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101411:	e8 13 fa ff ff       	call   f0100e29 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101416:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f010141b:	83 c4 10             	add    $0x10,%esp
f010141e:	e9 e9 01 00 00       	jmp    f010160c <mem_init+0x545>
	assert((pp0 = page_alloc(0)));
f0101423:	68 7c 46 10 f0       	push   $0xf010467c
f0101428:	68 a6 45 10 f0       	push   $0xf01045a6
f010142d:	68 43 02 00 00       	push   $0x243
f0101432:	68 80 45 10 f0       	push   $0xf0104580
f0101437:	e8 f7 ec ff ff       	call   f0100133 <_panic>
	assert((pp1 = page_alloc(0)));
f010143c:	68 92 46 10 f0       	push   $0xf0104692
f0101441:	68 a6 45 10 f0       	push   $0xf01045a6
f0101446:	68 44 02 00 00       	push   $0x244
f010144b:	68 80 45 10 f0       	push   $0xf0104580
f0101450:	e8 de ec ff ff       	call   f0100133 <_panic>
	assert((pp2 = page_alloc(0)));
f0101455:	68 a8 46 10 f0       	push   $0xf01046a8
f010145a:	68 a6 45 10 f0       	push   $0xf01045a6
f010145f:	68 45 02 00 00       	push   $0x245
f0101464:	68 80 45 10 f0       	push   $0xf0104580
f0101469:	e8 c5 ec ff ff       	call   f0100133 <_panic>
	assert(pp1 && pp1 != pp0);
f010146e:	68 be 46 10 f0       	push   $0xf01046be
f0101473:	68 a6 45 10 f0       	push   $0xf01045a6
f0101478:	68 48 02 00 00       	push   $0x248
f010147d:	68 80 45 10 f0       	push   $0xf0104580
f0101482:	e8 ac ec ff ff       	call   f0100133 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101487:	68 6c 3f 10 f0       	push   $0xf0103f6c
f010148c:	68 a6 45 10 f0       	push   $0xf01045a6
f0101491:	68 49 02 00 00       	push   $0x249
f0101496:	68 80 45 10 f0       	push   $0xf0104580
f010149b:	e8 93 ec ff ff       	call   f0100133 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f01014a0:	68 d0 46 10 f0       	push   $0xf01046d0
f01014a5:	68 a6 45 10 f0       	push   $0xf01045a6
f01014aa:	68 4a 02 00 00       	push   $0x24a
f01014af:	68 80 45 10 f0       	push   $0xf0104580
f01014b4:	e8 7a ec ff ff       	call   f0100133 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01014b9:	68 ed 46 10 f0       	push   $0xf01046ed
f01014be:	68 a6 45 10 f0       	push   $0xf01045a6
f01014c3:	68 4b 02 00 00       	push   $0x24b
f01014c8:	68 80 45 10 f0       	push   $0xf0104580
f01014cd:	e8 61 ec ff ff       	call   f0100133 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01014d2:	68 0a 47 10 f0       	push   $0xf010470a
f01014d7:	68 a6 45 10 f0       	push   $0xf01045a6
f01014dc:	68 4c 02 00 00       	push   $0x24c
f01014e1:	68 80 45 10 f0       	push   $0xf0104580
f01014e6:	e8 48 ec ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f01014eb:	68 27 47 10 f0       	push   $0xf0104727
f01014f0:	68 a6 45 10 f0       	push   $0xf01045a6
f01014f5:	68 53 02 00 00       	push   $0x253
f01014fa:	68 80 45 10 f0       	push   $0xf0104580
f01014ff:	e8 2f ec ff ff       	call   f0100133 <_panic>
	assert((pp0 = page_alloc(0)));
f0101504:	68 7c 46 10 f0       	push   $0xf010467c
f0101509:	68 a6 45 10 f0       	push   $0xf01045a6
f010150e:	68 5a 02 00 00       	push   $0x25a
f0101513:	68 80 45 10 f0       	push   $0xf0104580
f0101518:	e8 16 ec ff ff       	call   f0100133 <_panic>
	assert((pp1 = page_alloc(0)));
f010151d:	68 92 46 10 f0       	push   $0xf0104692
f0101522:	68 a6 45 10 f0       	push   $0xf01045a6
f0101527:	68 5b 02 00 00       	push   $0x25b
f010152c:	68 80 45 10 f0       	push   $0xf0104580
f0101531:	e8 fd eb ff ff       	call   f0100133 <_panic>
	assert((pp2 = page_alloc(0)));
f0101536:	68 a8 46 10 f0       	push   $0xf01046a8
f010153b:	68 a6 45 10 f0       	push   $0xf01045a6
f0101540:	68 5c 02 00 00       	push   $0x25c
f0101545:	68 80 45 10 f0       	push   $0xf0104580
f010154a:	e8 e4 eb ff ff       	call   f0100133 <_panic>
	assert(pp1 && pp1 != pp0);
f010154f:	68 be 46 10 f0       	push   $0xf01046be
f0101554:	68 a6 45 10 f0       	push   $0xf01045a6
f0101559:	68 5e 02 00 00       	push   $0x25e
f010155e:	68 80 45 10 f0       	push   $0xf0104580
f0101563:	e8 cb eb ff ff       	call   f0100133 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101568:	68 6c 3f 10 f0       	push   $0xf0103f6c
f010156d:	68 a6 45 10 f0       	push   $0xf01045a6
f0101572:	68 5f 02 00 00       	push   $0x25f
f0101577:	68 80 45 10 f0       	push   $0xf0104580
f010157c:	e8 b2 eb ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f0101581:	68 27 47 10 f0       	push   $0xf0104727
f0101586:	68 a6 45 10 f0       	push   $0xf01045a6
f010158b:	68 60 02 00 00       	push   $0x260
f0101590:	68 80 45 10 f0       	push   $0xf0104580
f0101595:	e8 99 eb ff ff       	call   f0100133 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010159a:	50                   	push   %eax
f010159b:	68 e0 3d 10 f0       	push   $0xf0103de0
f01015a0:	6a 52                	push   $0x52
f01015a2:	68 8c 45 10 f0       	push   $0xf010458c
f01015a7:	e8 87 eb ff ff       	call   f0100133 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01015ac:	68 36 47 10 f0       	push   $0xf0104736
f01015b1:	68 a6 45 10 f0       	push   $0xf01045a6
f01015b6:	68 65 02 00 00       	push   $0x265
f01015bb:	68 80 45 10 f0       	push   $0xf0104580
f01015c0:	e8 6e eb ff ff       	call   f0100133 <_panic>
	assert(pp && pp0 == pp);
f01015c5:	68 54 47 10 f0       	push   $0xf0104754
f01015ca:	68 a6 45 10 f0       	push   $0xf01045a6
f01015cf:	68 66 02 00 00       	push   $0x266
f01015d4:	68 80 45 10 f0       	push   $0xf0104580
f01015d9:	e8 55 eb ff ff       	call   f0100133 <_panic>
f01015de:	52                   	push   %edx
f01015df:	68 e0 3d 10 f0       	push   $0xf0103de0
f01015e4:	6a 52                	push   $0x52
f01015e6:	68 8c 45 10 f0       	push   $0xf010458c
f01015eb:	e8 43 eb ff ff       	call   f0100133 <_panic>
		assert(c[i] == 0);
f01015f0:	68 64 47 10 f0       	push   $0xf0104764
f01015f5:	68 a6 45 10 f0       	push   $0xf01045a6
f01015fa:	68 69 02 00 00       	push   $0x269
f01015ff:	68 80 45 10 f0       	push   $0xf0104580
f0101604:	e8 2a eb ff ff       	call   f0100133 <_panic>
		--nfree;
f0101609:	4b                   	dec    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010160a:	8b 00                	mov    (%eax),%eax
f010160c:	85 c0                	test   %eax,%eax
f010160e:	75 f9                	jne    f0101609 <mem_init+0x542>
	assert(nfree == 0);
f0101610:	85 db                	test   %ebx,%ebx
f0101612:	0f 85 cc 06 00 00    	jne    f0101ce4 <mem_init+0xc1d>
	cprintf("check_page_alloc() succeeded!\n");
f0101618:	83 ec 0c             	sub    $0xc,%esp
f010161b:	68 8c 3f 10 f0       	push   $0xf0103f8c
f0101620:	e8 8a 12 00 00       	call   f01028af <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101625:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010162c:	e8 86 f7 ff ff       	call   f0100db7 <page_alloc>
f0101631:	89 c7                	mov    %eax,%edi
f0101633:	83 c4 10             	add    $0x10,%esp
f0101636:	85 c0                	test   %eax,%eax
f0101638:	0f 84 bf 06 00 00    	je     f0101cfd <mem_init+0xc36>
	assert((pp1 = page_alloc(0)));
f010163e:	83 ec 0c             	sub    $0xc,%esp
f0101641:	6a 00                	push   $0x0
f0101643:	e8 6f f7 ff ff       	call   f0100db7 <page_alloc>
f0101648:	89 c3                	mov    %eax,%ebx
f010164a:	83 c4 10             	add    $0x10,%esp
f010164d:	85 c0                	test   %eax,%eax
f010164f:	0f 84 c1 06 00 00    	je     f0101d16 <mem_init+0xc4f>
	assert((pp2 = page_alloc(0)));
f0101655:	83 ec 0c             	sub    $0xc,%esp
f0101658:	6a 00                	push   $0x0
f010165a:	e8 58 f7 ff ff       	call   f0100db7 <page_alloc>
f010165f:	89 c6                	mov    %eax,%esi
f0101661:	83 c4 10             	add    $0x10,%esp
f0101664:	85 c0                	test   %eax,%eax
f0101666:	0f 84 c3 06 00 00    	je     f0101d2f <mem_init+0xc68>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010166c:	39 df                	cmp    %ebx,%edi
f010166e:	0f 84 d4 06 00 00    	je     f0101d48 <mem_init+0xc81>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101674:	39 c3                	cmp    %eax,%ebx
f0101676:	0f 84 e5 06 00 00    	je     f0101d61 <mem_init+0xc9a>
f010167c:	39 c7                	cmp    %eax,%edi
f010167e:	0f 84 dd 06 00 00    	je     f0101d61 <mem_init+0xc9a>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101684:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0101689:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f010168c:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f0101693:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101696:	83 ec 0c             	sub    $0xc,%esp
f0101699:	6a 00                	push   $0x0
f010169b:	e8 17 f7 ff ff       	call   f0100db7 <page_alloc>
f01016a0:	83 c4 10             	add    $0x10,%esp
f01016a3:	85 c0                	test   %eax,%eax
f01016a5:	0f 85 cf 06 00 00    	jne    f0101d7a <mem_init+0xcb3>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01016ab:	83 ec 04             	sub    $0x4,%esp
f01016ae:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01016b1:	50                   	push   %eax
f01016b2:	6a 00                	push   $0x0
f01016b4:	ff 35 68 79 11 f0    	pushl  0xf0117968
f01016ba:	e8 fb f8 ff ff       	call   f0100fba <page_lookup>
f01016bf:	83 c4 10             	add    $0x10,%esp
f01016c2:	85 c0                	test   %eax,%eax
f01016c4:	0f 85 c9 06 00 00    	jne    f0101d93 <mem_init+0xccc>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01016ca:	6a 02                	push   $0x2
f01016cc:	6a 00                	push   $0x0
f01016ce:	53                   	push   %ebx
f01016cf:	ff 35 68 79 11 f0    	pushl  0xf0117968
f01016d5:	e8 86 f9 ff ff       	call   f0101060 <page_insert>
f01016da:	83 c4 10             	add    $0x10,%esp
f01016dd:	85 c0                	test   %eax,%eax
f01016df:	0f 89 c7 06 00 00    	jns    f0101dac <mem_init+0xce5>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01016e5:	83 ec 0c             	sub    $0xc,%esp
f01016e8:	57                   	push   %edi
f01016e9:	e8 3b f7 ff ff       	call   f0100e29 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01016ee:	6a 02                	push   $0x2
f01016f0:	6a 00                	push   $0x0
f01016f2:	53                   	push   %ebx
f01016f3:	ff 35 68 79 11 f0    	pushl  0xf0117968
f01016f9:	e8 62 f9 ff ff       	call   f0101060 <page_insert>
f01016fe:	83 c4 20             	add    $0x20,%esp
f0101701:	85 c0                	test   %eax,%eax
f0101703:	0f 85 bc 06 00 00    	jne    f0101dc5 <mem_init+0xcfe>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101709:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f010170e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	return (pp - pages) << PGSHIFT;
f0101711:	8b 0d 6c 79 11 f0    	mov    0xf011796c,%ecx
f0101717:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010171a:	8b 00                	mov    (%eax),%eax
f010171c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010171f:	89 c2                	mov    %eax,%edx
f0101721:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101727:	89 f8                	mov    %edi,%eax
f0101729:	29 c8                	sub    %ecx,%eax
f010172b:	c1 f8 03             	sar    $0x3,%eax
f010172e:	c1 e0 0c             	shl    $0xc,%eax
f0101731:	39 c2                	cmp    %eax,%edx
f0101733:	0f 85 a5 06 00 00    	jne    f0101dde <mem_init+0xd17>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101739:	ba 00 00 00 00       	mov    $0x0,%edx
f010173e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101741:	e8 8f f2 ff ff       	call   f01009d5 <check_va2pa>
f0101746:	89 da                	mov    %ebx,%edx
f0101748:	2b 55 d0             	sub    -0x30(%ebp),%edx
f010174b:	c1 fa 03             	sar    $0x3,%edx
f010174e:	c1 e2 0c             	shl    $0xc,%edx
f0101751:	39 d0                	cmp    %edx,%eax
f0101753:	0f 85 9e 06 00 00    	jne    f0101df7 <mem_init+0xd30>
	assert(pp1->pp_ref == 1);
f0101759:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010175e:	0f 85 ac 06 00 00    	jne    f0101e10 <mem_init+0xd49>
	assert(pp0->pp_ref == 1);
f0101764:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101769:	0f 85 ba 06 00 00    	jne    f0101e29 <mem_init+0xd62>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010176f:	6a 02                	push   $0x2
f0101771:	68 00 10 00 00       	push   $0x1000
f0101776:	56                   	push   %esi
f0101777:	ff 75 d4             	pushl  -0x2c(%ebp)
f010177a:	e8 e1 f8 ff ff       	call   f0101060 <page_insert>
f010177f:	83 c4 10             	add    $0x10,%esp
f0101782:	85 c0                	test   %eax,%eax
f0101784:	0f 85 b8 06 00 00    	jne    f0101e42 <mem_init+0xd7b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010178a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010178f:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101794:	e8 3c f2 ff ff       	call   f01009d5 <check_va2pa>
f0101799:	89 f2                	mov    %esi,%edx
f010179b:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f01017a1:	c1 fa 03             	sar    $0x3,%edx
f01017a4:	c1 e2 0c             	shl    $0xc,%edx
f01017a7:	39 d0                	cmp    %edx,%eax
f01017a9:	0f 85 ac 06 00 00    	jne    f0101e5b <mem_init+0xd94>
	assert(pp2->pp_ref == 1);
f01017af:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01017b4:	0f 85 ba 06 00 00    	jne    f0101e74 <mem_init+0xdad>

	// should be no free memory
	assert(!page_alloc(0));
f01017ba:	83 ec 0c             	sub    $0xc,%esp
f01017bd:	6a 00                	push   $0x0
f01017bf:	e8 f3 f5 ff ff       	call   f0100db7 <page_alloc>
f01017c4:	83 c4 10             	add    $0x10,%esp
f01017c7:	85 c0                	test   %eax,%eax
f01017c9:	0f 85 be 06 00 00    	jne    f0101e8d <mem_init+0xdc6>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01017cf:	6a 02                	push   $0x2
f01017d1:	68 00 10 00 00       	push   $0x1000
f01017d6:	56                   	push   %esi
f01017d7:	ff 35 68 79 11 f0    	pushl  0xf0117968
f01017dd:	e8 7e f8 ff ff       	call   f0101060 <page_insert>
f01017e2:	83 c4 10             	add    $0x10,%esp
f01017e5:	85 c0                	test   %eax,%eax
f01017e7:	0f 85 b9 06 00 00    	jne    f0101ea6 <mem_init+0xddf>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01017ed:	ba 00 10 00 00       	mov    $0x1000,%edx
f01017f2:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01017f7:	e8 d9 f1 ff ff       	call   f01009d5 <check_va2pa>
f01017fc:	89 f2                	mov    %esi,%edx
f01017fe:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101804:	c1 fa 03             	sar    $0x3,%edx
f0101807:	c1 e2 0c             	shl    $0xc,%edx
f010180a:	39 d0                	cmp    %edx,%eax
f010180c:	0f 85 ad 06 00 00    	jne    f0101ebf <mem_init+0xdf8>
	assert(pp2->pp_ref == 1);
f0101812:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101817:	0f 85 bb 06 00 00    	jne    f0101ed8 <mem_init+0xe11>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f010181d:	83 ec 0c             	sub    $0xc,%esp
f0101820:	6a 00                	push   $0x0
f0101822:	e8 90 f5 ff ff       	call   f0100db7 <page_alloc>
f0101827:	83 c4 10             	add    $0x10,%esp
f010182a:	85 c0                	test   %eax,%eax
f010182c:	0f 85 bf 06 00 00    	jne    f0101ef1 <mem_init+0xe2a>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101832:	8b 15 68 79 11 f0    	mov    0xf0117968,%edx
f0101838:	8b 02                	mov    (%edx),%eax
f010183a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f010183f:	89 c1                	mov    %eax,%ecx
f0101841:	c1 e9 0c             	shr    $0xc,%ecx
f0101844:	3b 0d 64 79 11 f0    	cmp    0xf0117964,%ecx
f010184a:	0f 83 ba 06 00 00    	jae    f0101f0a <mem_init+0xe43>
	return (void *)(pa + KERNBASE);
f0101850:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101855:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101858:	83 ec 04             	sub    $0x4,%esp
f010185b:	6a 00                	push   $0x0
f010185d:	68 00 10 00 00       	push   $0x1000
f0101862:	52                   	push   %edx
f0101863:	e8 39 f6 ff ff       	call   f0100ea1 <pgdir_walk>
f0101868:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010186b:	8d 51 04             	lea    0x4(%ecx),%edx
f010186e:	83 c4 10             	add    $0x10,%esp
f0101871:	39 d0                	cmp    %edx,%eax
f0101873:	0f 85 a6 06 00 00    	jne    f0101f1f <mem_init+0xe58>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101879:	6a 06                	push   $0x6
f010187b:	68 00 10 00 00       	push   $0x1000
f0101880:	56                   	push   %esi
f0101881:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101887:	e8 d4 f7 ff ff       	call   f0101060 <page_insert>
f010188c:	83 c4 10             	add    $0x10,%esp
f010188f:	85 c0                	test   %eax,%eax
f0101891:	0f 85 a1 06 00 00    	jne    f0101f38 <mem_init+0xe71>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101897:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f010189c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010189f:	ba 00 10 00 00       	mov    $0x1000,%edx
f01018a4:	e8 2c f1 ff ff       	call   f01009d5 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f01018a9:	89 f2                	mov    %esi,%edx
f01018ab:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f01018b1:	c1 fa 03             	sar    $0x3,%edx
f01018b4:	c1 e2 0c             	shl    $0xc,%edx
f01018b7:	39 d0                	cmp    %edx,%eax
f01018b9:	0f 85 92 06 00 00    	jne    f0101f51 <mem_init+0xe8a>
	assert(pp2->pp_ref == 1);
f01018bf:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01018c4:	0f 85 a0 06 00 00    	jne    f0101f6a <mem_init+0xea3>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01018ca:	83 ec 04             	sub    $0x4,%esp
f01018cd:	6a 00                	push   $0x0
f01018cf:	68 00 10 00 00       	push   $0x1000
f01018d4:	ff 75 d4             	pushl  -0x2c(%ebp)
f01018d7:	e8 c5 f5 ff ff       	call   f0100ea1 <pgdir_walk>
f01018dc:	83 c4 10             	add    $0x10,%esp
f01018df:	f6 00 04             	testb  $0x4,(%eax)
f01018e2:	0f 84 9b 06 00 00    	je     f0101f83 <mem_init+0xebc>
	assert(kern_pgdir[0] & PTE_U);
f01018e8:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01018ed:	f6 00 04             	testb  $0x4,(%eax)
f01018f0:	0f 84 a6 06 00 00    	je     f0101f9c <mem_init+0xed5>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01018f6:	6a 02                	push   $0x2
f01018f8:	68 00 10 00 00       	push   $0x1000
f01018fd:	56                   	push   %esi
f01018fe:	50                   	push   %eax
f01018ff:	e8 5c f7 ff ff       	call   f0101060 <page_insert>
f0101904:	83 c4 10             	add    $0x10,%esp
f0101907:	85 c0                	test   %eax,%eax
f0101909:	0f 85 a6 06 00 00    	jne    f0101fb5 <mem_init+0xeee>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010190f:	83 ec 04             	sub    $0x4,%esp
f0101912:	6a 00                	push   $0x0
f0101914:	68 00 10 00 00       	push   $0x1000
f0101919:	ff 35 68 79 11 f0    	pushl  0xf0117968
f010191f:	e8 7d f5 ff ff       	call   f0100ea1 <pgdir_walk>
f0101924:	83 c4 10             	add    $0x10,%esp
f0101927:	f6 00 02             	testb  $0x2,(%eax)
f010192a:	0f 84 9e 06 00 00    	je     f0101fce <mem_init+0xf07>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101930:	83 ec 04             	sub    $0x4,%esp
f0101933:	6a 00                	push   $0x0
f0101935:	68 00 10 00 00       	push   $0x1000
f010193a:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101940:	e8 5c f5 ff ff       	call   f0100ea1 <pgdir_walk>
f0101945:	83 c4 10             	add    $0x10,%esp
f0101948:	f6 00 04             	testb  $0x4,(%eax)
f010194b:	0f 85 96 06 00 00    	jne    f0101fe7 <mem_init+0xf20>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101951:	6a 02                	push   $0x2
f0101953:	68 00 00 40 00       	push   $0x400000
f0101958:	57                   	push   %edi
f0101959:	ff 35 68 79 11 f0    	pushl  0xf0117968
f010195f:	e8 fc f6 ff ff       	call   f0101060 <page_insert>
f0101964:	83 c4 10             	add    $0x10,%esp
f0101967:	85 c0                	test   %eax,%eax
f0101969:	0f 89 91 06 00 00    	jns    f0102000 <mem_init+0xf39>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010196f:	6a 02                	push   $0x2
f0101971:	68 00 10 00 00       	push   $0x1000
f0101976:	53                   	push   %ebx
f0101977:	ff 35 68 79 11 f0    	pushl  0xf0117968
f010197d:	e8 de f6 ff ff       	call   f0101060 <page_insert>
f0101982:	83 c4 10             	add    $0x10,%esp
f0101985:	85 c0                	test   %eax,%eax
f0101987:	0f 85 8c 06 00 00    	jne    f0102019 <mem_init+0xf52>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010198d:	83 ec 04             	sub    $0x4,%esp
f0101990:	6a 00                	push   $0x0
f0101992:	68 00 10 00 00       	push   $0x1000
f0101997:	ff 35 68 79 11 f0    	pushl  0xf0117968
f010199d:	e8 ff f4 ff ff       	call   f0100ea1 <pgdir_walk>
f01019a2:	83 c4 10             	add    $0x10,%esp
f01019a5:	f6 00 04             	testb  $0x4,(%eax)
f01019a8:	0f 85 84 06 00 00    	jne    f0102032 <mem_init+0xf6b>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01019ae:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01019b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019b6:	ba 00 00 00 00       	mov    $0x0,%edx
f01019bb:	e8 15 f0 ff ff       	call   f01009d5 <check_va2pa>
f01019c0:	89 c1                	mov    %eax,%ecx
f01019c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01019c5:	89 d8                	mov    %ebx,%eax
f01019c7:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f01019cd:	c1 f8 03             	sar    $0x3,%eax
f01019d0:	c1 e0 0c             	shl    $0xc,%eax
f01019d3:	39 c1                	cmp    %eax,%ecx
f01019d5:	0f 85 70 06 00 00    	jne    f010204b <mem_init+0xf84>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01019db:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019e0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019e3:	e8 ed ef ff ff       	call   f01009d5 <check_va2pa>
f01019e8:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01019eb:	0f 85 73 06 00 00    	jne    f0102064 <mem_init+0xf9d>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01019f1:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f01019f6:	0f 85 81 06 00 00    	jne    f010207d <mem_init+0xfb6>
	assert(pp2->pp_ref == 0);
f01019fc:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101a01:	0f 85 8f 06 00 00    	jne    f0102096 <mem_init+0xfcf>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101a07:	83 ec 0c             	sub    $0xc,%esp
f0101a0a:	6a 00                	push   $0x0
f0101a0c:	e8 a6 f3 ff ff       	call   f0100db7 <page_alloc>
f0101a11:	83 c4 10             	add    $0x10,%esp
f0101a14:	85 c0                	test   %eax,%eax
f0101a16:	0f 84 93 06 00 00    	je     f01020af <mem_init+0xfe8>
f0101a1c:	39 c6                	cmp    %eax,%esi
f0101a1e:	0f 85 8b 06 00 00    	jne    f01020af <mem_init+0xfe8>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101a24:	83 ec 08             	sub    $0x8,%esp
f0101a27:	6a 00                	push   $0x0
f0101a29:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101a2f:	e8 ec f5 ff ff       	call   f0101020 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101a34:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101a39:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a3c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a41:	e8 8f ef ff ff       	call   f01009d5 <check_va2pa>
f0101a46:	83 c4 10             	add    $0x10,%esp
f0101a49:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101a4c:	0f 85 76 06 00 00    	jne    f01020c8 <mem_init+0x1001>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101a52:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a57:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a5a:	e8 76 ef ff ff       	call   f01009d5 <check_va2pa>
f0101a5f:	89 da                	mov    %ebx,%edx
f0101a61:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101a67:	c1 fa 03             	sar    $0x3,%edx
f0101a6a:	c1 e2 0c             	shl    $0xc,%edx
f0101a6d:	39 d0                	cmp    %edx,%eax
f0101a6f:	0f 85 6c 06 00 00    	jne    f01020e1 <mem_init+0x101a>
	assert(pp1->pp_ref == 1);
f0101a75:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a7a:	0f 85 7a 06 00 00    	jne    f01020fa <mem_init+0x1033>
	assert(pp2->pp_ref == 0);
f0101a80:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101a85:	0f 85 88 06 00 00    	jne    f0102113 <mem_init+0x104c>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101a8b:	6a 00                	push   $0x0
f0101a8d:	68 00 10 00 00       	push   $0x1000
f0101a92:	53                   	push   %ebx
f0101a93:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a96:	e8 c5 f5 ff ff       	call   f0101060 <page_insert>
f0101a9b:	83 c4 10             	add    $0x10,%esp
f0101a9e:	85 c0                	test   %eax,%eax
f0101aa0:	0f 85 86 06 00 00    	jne    f010212c <mem_init+0x1065>
	assert(pp1->pp_ref);
f0101aa6:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101aab:	0f 84 94 06 00 00    	je     f0102145 <mem_init+0x107e>
	assert(pp1->pp_link == NULL);
f0101ab1:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101ab4:	0f 85 a4 06 00 00    	jne    f010215e <mem_init+0x1097>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101aba:	83 ec 08             	sub    $0x8,%esp
f0101abd:	68 00 10 00 00       	push   $0x1000
f0101ac2:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101ac8:	e8 53 f5 ff ff       	call   f0101020 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101acd:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101ad2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101ad5:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ada:	e8 f6 ee ff ff       	call   f01009d5 <check_va2pa>
f0101adf:	83 c4 10             	add    $0x10,%esp
f0101ae2:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ae5:	0f 85 8c 06 00 00    	jne    f0102177 <mem_init+0x10b0>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101aeb:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101af0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101af3:	e8 dd ee ff ff       	call   f01009d5 <check_va2pa>
f0101af8:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101afb:	0f 85 8f 06 00 00    	jne    f0102190 <mem_init+0x10c9>
	assert(pp1->pp_ref == 0);
f0101b01:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101b06:	0f 85 9d 06 00 00    	jne    f01021a9 <mem_init+0x10e2>
	assert(pp2->pp_ref == 0);
f0101b0c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101b11:	0f 85 ab 06 00 00    	jne    f01021c2 <mem_init+0x10fb>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101b17:	83 ec 0c             	sub    $0xc,%esp
f0101b1a:	6a 00                	push   $0x0
f0101b1c:	e8 96 f2 ff ff       	call   f0100db7 <page_alloc>
f0101b21:	83 c4 10             	add    $0x10,%esp
f0101b24:	85 c0                	test   %eax,%eax
f0101b26:	0f 84 af 06 00 00    	je     f01021db <mem_init+0x1114>
f0101b2c:	39 c3                	cmp    %eax,%ebx
f0101b2e:	0f 85 a7 06 00 00    	jne    f01021db <mem_init+0x1114>

	// should be no free memory
	assert(!page_alloc(0));
f0101b34:	83 ec 0c             	sub    $0xc,%esp
f0101b37:	6a 00                	push   $0x0
f0101b39:	e8 79 f2 ff ff       	call   f0100db7 <page_alloc>
f0101b3e:	83 c4 10             	add    $0x10,%esp
f0101b41:	85 c0                	test   %eax,%eax
f0101b43:	0f 85 ab 06 00 00    	jne    f01021f4 <mem_init+0x112d>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b49:	8b 0d 68 79 11 f0    	mov    0xf0117968,%ecx
f0101b4f:	8b 11                	mov    (%ecx),%edx
f0101b51:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b57:	89 f8                	mov    %edi,%eax
f0101b59:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0101b5f:	c1 f8 03             	sar    $0x3,%eax
f0101b62:	c1 e0 0c             	shl    $0xc,%eax
f0101b65:	39 c2                	cmp    %eax,%edx
f0101b67:	0f 85 a0 06 00 00    	jne    f010220d <mem_init+0x1146>
	kern_pgdir[0] = 0;
f0101b6d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101b73:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101b78:	0f 85 a8 06 00 00    	jne    f0102226 <mem_init+0x115f>
	pp0->pp_ref = 0;
f0101b7e:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101b84:	83 ec 0c             	sub    $0xc,%esp
f0101b87:	57                   	push   %edi
f0101b88:	e8 9c f2 ff ff       	call   f0100e29 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101b8d:	83 c4 0c             	add    $0xc,%esp
f0101b90:	6a 01                	push   $0x1
f0101b92:	68 00 10 40 00       	push   $0x401000
f0101b97:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101b9d:	e8 ff f2 ff ff       	call   f0100ea1 <pgdir_walk>
f0101ba2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101ba5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101ba8:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101bad:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101bb0:	8b 50 04             	mov    0x4(%eax),%edx
f0101bb3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101bb9:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f0101bbe:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101bc1:	89 d1                	mov    %edx,%ecx
f0101bc3:	c1 e9 0c             	shr    $0xc,%ecx
f0101bc6:	83 c4 10             	add    $0x10,%esp
f0101bc9:	39 c1                	cmp    %eax,%ecx
f0101bcb:	0f 83 6e 06 00 00    	jae    f010223f <mem_init+0x1178>
	assert(ptep == ptep1 + PTX(va));
f0101bd1:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0101bd7:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0101bda:	0f 85 74 06 00 00    	jne    f0102254 <mem_init+0x118d>
	kern_pgdir[PDX(va)] = 0;
f0101be0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101be3:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101bea:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
	return (pp - pages) << PGSHIFT;
f0101bf0:	89 f8                	mov    %edi,%eax
f0101bf2:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0101bf8:	c1 f8 03             	sar    $0x3,%eax
f0101bfb:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101bfe:	89 c2                	mov    %eax,%edx
f0101c00:	c1 ea 0c             	shr    $0xc,%edx
f0101c03:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f0101c06:	0f 86 61 06 00 00    	jbe    f010226d <mem_init+0x11a6>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101c0c:	83 ec 04             	sub    $0x4,%esp
f0101c0f:	68 00 10 00 00       	push   $0x1000
f0101c14:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101c19:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c1e:	50                   	push   %eax
f0101c1f:	e8 ba 17 00 00       	call   f01033de <memset>
	page_free(pp0);
f0101c24:	89 3c 24             	mov    %edi,(%esp)
f0101c27:	e8 fd f1 ff ff       	call   f0100e29 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101c2c:	83 c4 0c             	add    $0xc,%esp
f0101c2f:	6a 01                	push   $0x1
f0101c31:	6a 00                	push   $0x0
f0101c33:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101c39:	e8 63 f2 ff ff       	call   f0100ea1 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101c3e:	89 fa                	mov    %edi,%edx
f0101c40:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101c46:	c1 fa 03             	sar    $0x3,%edx
f0101c49:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101c4c:	89 d0                	mov    %edx,%eax
f0101c4e:	c1 e8 0c             	shr    $0xc,%eax
f0101c51:	83 c4 10             	add    $0x10,%esp
f0101c54:	3b 05 64 79 11 f0    	cmp    0xf0117964,%eax
f0101c5a:	0f 83 1f 06 00 00    	jae    f010227f <mem_init+0x11b8>
	return (void *)(pa + KERNBASE);
f0101c60:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101c66:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101c69:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101c6f:	f6 00 01             	testb  $0x1,(%eax)
f0101c72:	0f 85 19 06 00 00    	jne    f0102291 <mem_init+0x11ca>
f0101c78:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0101c7b:	39 c2                	cmp    %eax,%edx
f0101c7d:	75 f0                	jne    f0101c6f <mem_init+0xba8>
	kern_pgdir[0] = 0;
f0101c7f:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101c84:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101c8a:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0101c90:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0101c93:	a3 3c 75 11 f0       	mov    %eax,0xf011753c

	// free the pages we took
	page_free(pp0);
f0101c98:	83 ec 0c             	sub    $0xc,%esp
f0101c9b:	57                   	push   %edi
f0101c9c:	e8 88 f1 ff ff       	call   f0100e29 <page_free>
	page_free(pp1);
f0101ca1:	89 1c 24             	mov    %ebx,(%esp)
f0101ca4:	e8 80 f1 ff ff       	call   f0100e29 <page_free>
	page_free(pp2);
f0101ca9:	89 34 24             	mov    %esi,(%esp)
f0101cac:	e8 78 f1 ff ff       	call   f0100e29 <page_free>

	cprintf("check_page() succeeded!\n");
f0101cb1:	c7 04 24 45 48 10 f0 	movl   $0xf0104845,(%esp)
f0101cb8:	e8 f2 0b 00 00       	call   f01028af <cprintf>
	pgdir = kern_pgdir;
f0101cbd:	8b 1d 68 79 11 f0    	mov    0xf0117968,%ebx
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0101cc3:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f0101cc8:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0101ccf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101cd4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101cd7:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i += PGSIZE) {
f0101cda:	be 00 00 00 00       	mov    $0x0,%esi
f0101cdf:	e9 e1 05 00 00       	jmp    f01022c5 <mem_init+0x11fe>
	assert(nfree == 0);
f0101ce4:	68 6e 47 10 f0       	push   $0xf010476e
f0101ce9:	68 a6 45 10 f0       	push   $0xf01045a6
f0101cee:	68 76 02 00 00       	push   $0x276
f0101cf3:	68 80 45 10 f0       	push   $0xf0104580
f0101cf8:	e8 36 e4 ff ff       	call   f0100133 <_panic>
	assert((pp0 = page_alloc(0)));
f0101cfd:	68 7c 46 10 f0       	push   $0xf010467c
f0101d02:	68 a6 45 10 f0       	push   $0xf01045a6
f0101d07:	68 d1 02 00 00       	push   $0x2d1
f0101d0c:	68 80 45 10 f0       	push   $0xf0104580
f0101d11:	e8 1d e4 ff ff       	call   f0100133 <_panic>
	assert((pp1 = page_alloc(0)));
f0101d16:	68 92 46 10 f0       	push   $0xf0104692
f0101d1b:	68 a6 45 10 f0       	push   $0xf01045a6
f0101d20:	68 d2 02 00 00       	push   $0x2d2
f0101d25:	68 80 45 10 f0       	push   $0xf0104580
f0101d2a:	e8 04 e4 ff ff       	call   f0100133 <_panic>
	assert((pp2 = page_alloc(0)));
f0101d2f:	68 a8 46 10 f0       	push   $0xf01046a8
f0101d34:	68 a6 45 10 f0       	push   $0xf01045a6
f0101d39:	68 d3 02 00 00       	push   $0x2d3
f0101d3e:	68 80 45 10 f0       	push   $0xf0104580
f0101d43:	e8 eb e3 ff ff       	call   f0100133 <_panic>
	assert(pp1 && pp1 != pp0);
f0101d48:	68 be 46 10 f0       	push   $0xf01046be
f0101d4d:	68 a6 45 10 f0       	push   $0xf01045a6
f0101d52:	68 d6 02 00 00       	push   $0x2d6
f0101d57:	68 80 45 10 f0       	push   $0xf0104580
f0101d5c:	e8 d2 e3 ff ff       	call   f0100133 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101d61:	68 6c 3f 10 f0       	push   $0xf0103f6c
f0101d66:	68 a6 45 10 f0       	push   $0xf01045a6
f0101d6b:	68 d7 02 00 00       	push   $0x2d7
f0101d70:	68 80 45 10 f0       	push   $0xf0104580
f0101d75:	e8 b9 e3 ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f0101d7a:	68 27 47 10 f0       	push   $0xf0104727
f0101d7f:	68 a6 45 10 f0       	push   $0xf01045a6
f0101d84:	68 de 02 00 00       	push   $0x2de
f0101d89:	68 80 45 10 f0       	push   $0xf0104580
f0101d8e:	e8 a0 e3 ff ff       	call   f0100133 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101d93:	68 ac 3f 10 f0       	push   $0xf0103fac
f0101d98:	68 a6 45 10 f0       	push   $0xf01045a6
f0101d9d:	68 e1 02 00 00       	push   $0x2e1
f0101da2:	68 80 45 10 f0       	push   $0xf0104580
f0101da7:	e8 87 e3 ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101dac:	68 e4 3f 10 f0       	push   $0xf0103fe4
f0101db1:	68 a6 45 10 f0       	push   $0xf01045a6
f0101db6:	68 e4 02 00 00       	push   $0x2e4
f0101dbb:	68 80 45 10 f0       	push   $0xf0104580
f0101dc0:	e8 6e e3 ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101dc5:	68 14 40 10 f0       	push   $0xf0104014
f0101dca:	68 a6 45 10 f0       	push   $0xf01045a6
f0101dcf:	68 e8 02 00 00       	push   $0x2e8
f0101dd4:	68 80 45 10 f0       	push   $0xf0104580
f0101dd9:	e8 55 e3 ff ff       	call   f0100133 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101dde:	68 44 40 10 f0       	push   $0xf0104044
f0101de3:	68 a6 45 10 f0       	push   $0xf01045a6
f0101de8:	68 e9 02 00 00       	push   $0x2e9
f0101ded:	68 80 45 10 f0       	push   $0xf0104580
f0101df2:	e8 3c e3 ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101df7:	68 6c 40 10 f0       	push   $0xf010406c
f0101dfc:	68 a6 45 10 f0       	push   $0xf01045a6
f0101e01:	68 ea 02 00 00       	push   $0x2ea
f0101e06:	68 80 45 10 f0       	push   $0xf0104580
f0101e0b:	e8 23 e3 ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 1);
f0101e10:	68 79 47 10 f0       	push   $0xf0104779
f0101e15:	68 a6 45 10 f0       	push   $0xf01045a6
f0101e1a:	68 eb 02 00 00       	push   $0x2eb
f0101e1f:	68 80 45 10 f0       	push   $0xf0104580
f0101e24:	e8 0a e3 ff ff       	call   f0100133 <_panic>
	assert(pp0->pp_ref == 1);
f0101e29:	68 8a 47 10 f0       	push   $0xf010478a
f0101e2e:	68 a6 45 10 f0       	push   $0xf01045a6
f0101e33:	68 ec 02 00 00       	push   $0x2ec
f0101e38:	68 80 45 10 f0       	push   $0xf0104580
f0101e3d:	e8 f1 e2 ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e42:	68 9c 40 10 f0       	push   $0xf010409c
f0101e47:	68 a6 45 10 f0       	push   $0xf01045a6
f0101e4c:	68 ef 02 00 00       	push   $0x2ef
f0101e51:	68 80 45 10 f0       	push   $0xf0104580
f0101e56:	e8 d8 e2 ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e5b:	68 d8 40 10 f0       	push   $0xf01040d8
f0101e60:	68 a6 45 10 f0       	push   $0xf01045a6
f0101e65:	68 f0 02 00 00       	push   $0x2f0
f0101e6a:	68 80 45 10 f0       	push   $0xf0104580
f0101e6f:	e8 bf e2 ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 1);
f0101e74:	68 9b 47 10 f0       	push   $0xf010479b
f0101e79:	68 a6 45 10 f0       	push   $0xf01045a6
f0101e7e:	68 f1 02 00 00       	push   $0x2f1
f0101e83:	68 80 45 10 f0       	push   $0xf0104580
f0101e88:	e8 a6 e2 ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f0101e8d:	68 27 47 10 f0       	push   $0xf0104727
f0101e92:	68 a6 45 10 f0       	push   $0xf01045a6
f0101e97:	68 f4 02 00 00       	push   $0x2f4
f0101e9c:	68 80 45 10 f0       	push   $0xf0104580
f0101ea1:	e8 8d e2 ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ea6:	68 9c 40 10 f0       	push   $0xf010409c
f0101eab:	68 a6 45 10 f0       	push   $0xf01045a6
f0101eb0:	68 f7 02 00 00       	push   $0x2f7
f0101eb5:	68 80 45 10 f0       	push   $0xf0104580
f0101eba:	e8 74 e2 ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ebf:	68 d8 40 10 f0       	push   $0xf01040d8
f0101ec4:	68 a6 45 10 f0       	push   $0xf01045a6
f0101ec9:	68 f8 02 00 00       	push   $0x2f8
f0101ece:	68 80 45 10 f0       	push   $0xf0104580
f0101ed3:	e8 5b e2 ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 1);
f0101ed8:	68 9b 47 10 f0       	push   $0xf010479b
f0101edd:	68 a6 45 10 f0       	push   $0xf01045a6
f0101ee2:	68 f9 02 00 00       	push   $0x2f9
f0101ee7:	68 80 45 10 f0       	push   $0xf0104580
f0101eec:	e8 42 e2 ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f0101ef1:	68 27 47 10 f0       	push   $0xf0104727
f0101ef6:	68 a6 45 10 f0       	push   $0xf01045a6
f0101efb:	68 fd 02 00 00       	push   $0x2fd
f0101f00:	68 80 45 10 f0       	push   $0xf0104580
f0101f05:	e8 29 e2 ff ff       	call   f0100133 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f0a:	50                   	push   %eax
f0101f0b:	68 e0 3d 10 f0       	push   $0xf0103de0
f0101f10:	68 00 03 00 00       	push   $0x300
f0101f15:	68 80 45 10 f0       	push   $0xf0104580
f0101f1a:	e8 14 e2 ff ff       	call   f0100133 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101f1f:	68 08 41 10 f0       	push   $0xf0104108
f0101f24:	68 a6 45 10 f0       	push   $0xf01045a6
f0101f29:	68 01 03 00 00       	push   $0x301
f0101f2e:	68 80 45 10 f0       	push   $0xf0104580
f0101f33:	e8 fb e1 ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101f38:	68 48 41 10 f0       	push   $0xf0104148
f0101f3d:	68 a6 45 10 f0       	push   $0xf01045a6
f0101f42:	68 04 03 00 00       	push   $0x304
f0101f47:	68 80 45 10 f0       	push   $0xf0104580
f0101f4c:	e8 e2 e1 ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f51:	68 d8 40 10 f0       	push   $0xf01040d8
f0101f56:	68 a6 45 10 f0       	push   $0xf01045a6
f0101f5b:	68 05 03 00 00       	push   $0x305
f0101f60:	68 80 45 10 f0       	push   $0xf0104580
f0101f65:	e8 c9 e1 ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 1);
f0101f6a:	68 9b 47 10 f0       	push   $0xf010479b
f0101f6f:	68 a6 45 10 f0       	push   $0xf01045a6
f0101f74:	68 06 03 00 00       	push   $0x306
f0101f79:	68 80 45 10 f0       	push   $0xf0104580
f0101f7e:	e8 b0 e1 ff ff       	call   f0100133 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101f83:	68 88 41 10 f0       	push   $0xf0104188
f0101f88:	68 a6 45 10 f0       	push   $0xf01045a6
f0101f8d:	68 07 03 00 00       	push   $0x307
f0101f92:	68 80 45 10 f0       	push   $0xf0104580
f0101f97:	e8 97 e1 ff ff       	call   f0100133 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101f9c:	68 ac 47 10 f0       	push   $0xf01047ac
f0101fa1:	68 a6 45 10 f0       	push   $0xf01045a6
f0101fa6:	68 08 03 00 00       	push   $0x308
f0101fab:	68 80 45 10 f0       	push   $0xf0104580
f0101fb0:	e8 7e e1 ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101fb5:	68 9c 40 10 f0       	push   $0xf010409c
f0101fba:	68 a6 45 10 f0       	push   $0xf01045a6
f0101fbf:	68 0b 03 00 00       	push   $0x30b
f0101fc4:	68 80 45 10 f0       	push   $0xf0104580
f0101fc9:	e8 65 e1 ff ff       	call   f0100133 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101fce:	68 bc 41 10 f0       	push   $0xf01041bc
f0101fd3:	68 a6 45 10 f0       	push   $0xf01045a6
f0101fd8:	68 0c 03 00 00       	push   $0x30c
f0101fdd:	68 80 45 10 f0       	push   $0xf0104580
f0101fe2:	e8 4c e1 ff ff       	call   f0100133 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101fe7:	68 f0 41 10 f0       	push   $0xf01041f0
f0101fec:	68 a6 45 10 f0       	push   $0xf01045a6
f0101ff1:	68 0d 03 00 00       	push   $0x30d
f0101ff6:	68 80 45 10 f0       	push   $0xf0104580
f0101ffb:	e8 33 e1 ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102000:	68 28 42 10 f0       	push   $0xf0104228
f0102005:	68 a6 45 10 f0       	push   $0xf01045a6
f010200a:	68 10 03 00 00       	push   $0x310
f010200f:	68 80 45 10 f0       	push   $0xf0104580
f0102014:	e8 1a e1 ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102019:	68 60 42 10 f0       	push   $0xf0104260
f010201e:	68 a6 45 10 f0       	push   $0xf01045a6
f0102023:	68 13 03 00 00       	push   $0x313
f0102028:	68 80 45 10 f0       	push   $0xf0104580
f010202d:	e8 01 e1 ff ff       	call   f0100133 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102032:	68 f0 41 10 f0       	push   $0xf01041f0
f0102037:	68 a6 45 10 f0       	push   $0xf01045a6
f010203c:	68 14 03 00 00       	push   $0x314
f0102041:	68 80 45 10 f0       	push   $0xf0104580
f0102046:	e8 e8 e0 ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010204b:	68 9c 42 10 f0       	push   $0xf010429c
f0102050:	68 a6 45 10 f0       	push   $0xf01045a6
f0102055:	68 17 03 00 00       	push   $0x317
f010205a:	68 80 45 10 f0       	push   $0xf0104580
f010205f:	e8 cf e0 ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102064:	68 c8 42 10 f0       	push   $0xf01042c8
f0102069:	68 a6 45 10 f0       	push   $0xf01045a6
f010206e:	68 18 03 00 00       	push   $0x318
f0102073:	68 80 45 10 f0       	push   $0xf0104580
f0102078:	e8 b6 e0 ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 2);
f010207d:	68 c2 47 10 f0       	push   $0xf01047c2
f0102082:	68 a6 45 10 f0       	push   $0xf01045a6
f0102087:	68 1a 03 00 00       	push   $0x31a
f010208c:	68 80 45 10 f0       	push   $0xf0104580
f0102091:	e8 9d e0 ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 0);
f0102096:	68 d3 47 10 f0       	push   $0xf01047d3
f010209b:	68 a6 45 10 f0       	push   $0xf01045a6
f01020a0:	68 1b 03 00 00       	push   $0x31b
f01020a5:	68 80 45 10 f0       	push   $0xf0104580
f01020aa:	e8 84 e0 ff ff       	call   f0100133 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01020af:	68 f8 42 10 f0       	push   $0xf01042f8
f01020b4:	68 a6 45 10 f0       	push   $0xf01045a6
f01020b9:	68 1e 03 00 00       	push   $0x31e
f01020be:	68 80 45 10 f0       	push   $0xf0104580
f01020c3:	e8 6b e0 ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01020c8:	68 1c 43 10 f0       	push   $0xf010431c
f01020cd:	68 a6 45 10 f0       	push   $0xf01045a6
f01020d2:	68 22 03 00 00       	push   $0x322
f01020d7:	68 80 45 10 f0       	push   $0xf0104580
f01020dc:	e8 52 e0 ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01020e1:	68 c8 42 10 f0       	push   $0xf01042c8
f01020e6:	68 a6 45 10 f0       	push   $0xf01045a6
f01020eb:	68 23 03 00 00       	push   $0x323
f01020f0:	68 80 45 10 f0       	push   $0xf0104580
f01020f5:	e8 39 e0 ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 1);
f01020fa:	68 79 47 10 f0       	push   $0xf0104779
f01020ff:	68 a6 45 10 f0       	push   $0xf01045a6
f0102104:	68 24 03 00 00       	push   $0x324
f0102109:	68 80 45 10 f0       	push   $0xf0104580
f010210e:	e8 20 e0 ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 0);
f0102113:	68 d3 47 10 f0       	push   $0xf01047d3
f0102118:	68 a6 45 10 f0       	push   $0xf01045a6
f010211d:	68 25 03 00 00       	push   $0x325
f0102122:	68 80 45 10 f0       	push   $0xf0104580
f0102127:	e8 07 e0 ff ff       	call   f0100133 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010212c:	68 40 43 10 f0       	push   $0xf0104340
f0102131:	68 a6 45 10 f0       	push   $0xf01045a6
f0102136:	68 28 03 00 00       	push   $0x328
f010213b:	68 80 45 10 f0       	push   $0xf0104580
f0102140:	e8 ee df ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref);
f0102145:	68 e4 47 10 f0       	push   $0xf01047e4
f010214a:	68 a6 45 10 f0       	push   $0xf01045a6
f010214f:	68 29 03 00 00       	push   $0x329
f0102154:	68 80 45 10 f0       	push   $0xf0104580
f0102159:	e8 d5 df ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_link == NULL);
f010215e:	68 f0 47 10 f0       	push   $0xf01047f0
f0102163:	68 a6 45 10 f0       	push   $0xf01045a6
f0102168:	68 2a 03 00 00       	push   $0x32a
f010216d:	68 80 45 10 f0       	push   $0xf0104580
f0102172:	e8 bc df ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102177:	68 1c 43 10 f0       	push   $0xf010431c
f010217c:	68 a6 45 10 f0       	push   $0xf01045a6
f0102181:	68 2e 03 00 00       	push   $0x32e
f0102186:	68 80 45 10 f0       	push   $0xf0104580
f010218b:	e8 a3 df ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102190:	68 78 43 10 f0       	push   $0xf0104378
f0102195:	68 a6 45 10 f0       	push   $0xf01045a6
f010219a:	68 2f 03 00 00       	push   $0x32f
f010219f:	68 80 45 10 f0       	push   $0xf0104580
f01021a4:	e8 8a df ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 0);
f01021a9:	68 05 48 10 f0       	push   $0xf0104805
f01021ae:	68 a6 45 10 f0       	push   $0xf01045a6
f01021b3:	68 30 03 00 00       	push   $0x330
f01021b8:	68 80 45 10 f0       	push   $0xf0104580
f01021bd:	e8 71 df ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 0);
f01021c2:	68 d3 47 10 f0       	push   $0xf01047d3
f01021c7:	68 a6 45 10 f0       	push   $0xf01045a6
f01021cc:	68 31 03 00 00       	push   $0x331
f01021d1:	68 80 45 10 f0       	push   $0xf0104580
f01021d6:	e8 58 df ff ff       	call   f0100133 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f01021db:	68 a0 43 10 f0       	push   $0xf01043a0
f01021e0:	68 a6 45 10 f0       	push   $0xf01045a6
f01021e5:	68 34 03 00 00       	push   $0x334
f01021ea:	68 80 45 10 f0       	push   $0xf0104580
f01021ef:	e8 3f df ff ff       	call   f0100133 <_panic>
	assert(!page_alloc(0));
f01021f4:	68 27 47 10 f0       	push   $0xf0104727
f01021f9:	68 a6 45 10 f0       	push   $0xf01045a6
f01021fe:	68 37 03 00 00       	push   $0x337
f0102203:	68 80 45 10 f0       	push   $0xf0104580
f0102208:	e8 26 df ff ff       	call   f0100133 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010220d:	68 44 40 10 f0       	push   $0xf0104044
f0102212:	68 a6 45 10 f0       	push   $0xf01045a6
f0102217:	68 3a 03 00 00       	push   $0x33a
f010221c:	68 80 45 10 f0       	push   $0xf0104580
f0102221:	e8 0d df ff ff       	call   f0100133 <_panic>
	assert(pp0->pp_ref == 1);
f0102226:	68 8a 47 10 f0       	push   $0xf010478a
f010222b:	68 a6 45 10 f0       	push   $0xf01045a6
f0102230:	68 3c 03 00 00       	push   $0x33c
f0102235:	68 80 45 10 f0       	push   $0xf0104580
f010223a:	e8 f4 de ff ff       	call   f0100133 <_panic>
f010223f:	52                   	push   %edx
f0102240:	68 e0 3d 10 f0       	push   $0xf0103de0
f0102245:	68 43 03 00 00       	push   $0x343
f010224a:	68 80 45 10 f0       	push   $0xf0104580
f010224f:	e8 df de ff ff       	call   f0100133 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102254:	68 16 48 10 f0       	push   $0xf0104816
f0102259:	68 a6 45 10 f0       	push   $0xf01045a6
f010225e:	68 44 03 00 00       	push   $0x344
f0102263:	68 80 45 10 f0       	push   $0xf0104580
f0102268:	e8 c6 de ff ff       	call   f0100133 <_panic>
f010226d:	50                   	push   %eax
f010226e:	68 e0 3d 10 f0       	push   $0xf0103de0
f0102273:	6a 52                	push   $0x52
f0102275:	68 8c 45 10 f0       	push   $0xf010458c
f010227a:	e8 b4 de ff ff       	call   f0100133 <_panic>
f010227f:	52                   	push   %edx
f0102280:	68 e0 3d 10 f0       	push   $0xf0103de0
f0102285:	6a 52                	push   $0x52
f0102287:	68 8c 45 10 f0       	push   $0xf010458c
f010228c:	e8 a2 de ff ff       	call   f0100133 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102291:	68 2e 48 10 f0       	push   $0xf010482e
f0102296:	68 a6 45 10 f0       	push   $0xf01045a6
f010229b:	68 4e 03 00 00       	push   $0x34e
f01022a0:	68 80 45 10 f0       	push   $0xf0104580
f01022a5:	e8 89 de ff ff       	call   f0100133 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01022aa:	52                   	push   %edx
f01022ab:	68 ec 3e 10 f0       	push   $0xf0103eec
f01022b0:	68 8f 02 00 00       	push   $0x28f
f01022b5:	68 80 45 10 f0       	push   $0xf0104580
f01022ba:	e8 74 de ff ff       	call   f0100133 <_panic>
	for (i = 0; i < n; i += PGSIZE) {
f01022bf:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01022c5:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f01022c8:	76 5c                	jbe    f0102326 <mem_init+0x125f>
f01022ca:	8d be 00 00 00 ef    	lea    -0x11000000(%esi),%edi
		cprintf("check_va2pa(pgdir, UPAGES + %d) = %x", i, check_va2pa(pgdir, UPAGES + i));
f01022d0:	89 fa                	mov    %edi,%edx
f01022d2:	89 d8                	mov    %ebx,%eax
f01022d4:	e8 fc e6 ff ff       	call   f01009d5 <check_va2pa>
f01022d9:	83 ec 04             	sub    $0x4,%esp
f01022dc:	50                   	push   %eax
f01022dd:	56                   	push   %esi
f01022de:	68 c4 43 10 f0       	push   $0xf01043c4
f01022e3:	e8 c7 05 00 00       	call   f01028af <cprintf>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01022e8:	89 fa                	mov    %edi,%edx
f01022ea:	89 d8                	mov    %ebx,%eax
f01022ec:	e8 e4 e6 ff ff       	call   f01009d5 <check_va2pa>
f01022f1:	8b 15 6c 79 11 f0    	mov    0xf011796c,%edx
	if ((uint32_t)kva < KERNBASE)
f01022f7:	83 c4 10             	add    $0x10,%esp
f01022fa:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102300:	76 a8                	jbe    f01022aa <mem_init+0x11e3>
f0102302:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102309:	39 d0                	cmp    %edx,%eax
f010230b:	74 b2                	je     f01022bf <mem_init+0x11f8>
f010230d:	68 ec 43 10 f0       	push   $0xf01043ec
f0102312:	68 a6 45 10 f0       	push   $0xf01045a6
f0102317:	68 8f 02 00 00       	push   $0x28f
f010231c:	68 80 45 10 f0       	push   $0xf0104580
f0102321:	e8 0d de ff ff       	call   f0100133 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102326:	8b 3d 64 79 11 f0    	mov    0xf0117964,%edi
f010232c:	c1 e7 0c             	shl    $0xc,%edi
f010232f:	be 00 00 00 00       	mov    $0x0,%esi
f0102334:	eb 17                	jmp    f010234d <mem_init+0x1286>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102336:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f010233c:	89 d8                	mov    %ebx,%eax
f010233e:	e8 92 e6 ff ff       	call   f01009d5 <check_va2pa>
f0102343:	39 c6                	cmp    %eax,%esi
f0102345:	75 58                	jne    f010239f <mem_init+0x12d8>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102347:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010234d:	39 fe                	cmp    %edi,%esi
f010234f:	72 e5                	jb     f0102336 <mem_init+0x126f>
f0102351:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102356:	bf 00 d0 10 f0       	mov    $0xf010d000,%edi
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010235b:	89 f2                	mov    %esi,%edx
f010235d:	89 d8                	mov    %ebx,%eax
f010235f:	e8 71 e6 ff ff       	call   f01009d5 <check_va2pa>
f0102364:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f010236a:	76 4c                	jbe    f01023b8 <mem_init+0x12f1>
f010236c:	8d 96 00 50 11 10    	lea    0x10115000(%esi),%edx
f0102372:	39 d0                	cmp    %edx,%eax
f0102374:	75 5b                	jne    f01023d1 <mem_init+0x130a>
f0102376:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010237c:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0102382:	75 d7                	jne    f010235b <mem_init+0x1294>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102384:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102389:	89 d8                	mov    %ebx,%eax
f010238b:	e8 45 e6 ff ff       	call   f01009d5 <check_va2pa>
f0102390:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102393:	75 55                	jne    f01023ea <mem_init+0x1323>
	for (i = 0; i < NPDENTRIES; i++) {
f0102395:	b8 00 00 00 00       	mov    $0x0,%eax
f010239a:	e9 8b 00 00 00       	jmp    f010242a <mem_init+0x1363>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010239f:	68 20 44 10 f0       	push   $0xf0104420
f01023a4:	68 a6 45 10 f0       	push   $0xf01045a6
f01023a9:	68 95 02 00 00       	push   $0x295
f01023ae:	68 80 45 10 f0       	push   $0xf0104580
f01023b3:	e8 7b dd ff ff       	call   f0100133 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01023b8:	68 00 d0 10 f0       	push   $0xf010d000
f01023bd:	68 ec 3e 10 f0       	push   $0xf0103eec
f01023c2:	68 99 02 00 00       	push   $0x299
f01023c7:	68 80 45 10 f0       	push   $0xf0104580
f01023cc:	e8 62 dd ff ff       	call   f0100133 <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01023d1:	68 48 44 10 f0       	push   $0xf0104448
f01023d6:	68 a6 45 10 f0       	push   $0xf01045a6
f01023db:	68 99 02 00 00       	push   $0x299
f01023e0:	68 80 45 10 f0       	push   $0xf0104580
f01023e5:	e8 49 dd ff ff       	call   f0100133 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01023ea:	68 90 44 10 f0       	push   $0xf0104490
f01023ef:	68 a6 45 10 f0       	push   $0xf01045a6
f01023f4:	68 9a 02 00 00       	push   $0x29a
f01023f9:	68 80 45 10 f0       	push   $0xf0104580
f01023fe:	e8 30 dd ff ff       	call   f0100133 <_panic>
			assert(pgdir[i] & PTE_P);
f0102403:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102407:	74 47                	je     f0102450 <mem_init+0x1389>
	for (i = 0; i < NPDENTRIES; i++) {
f0102409:	40                   	inc    %eax
f010240a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f010240f:	0f 87 93 00 00 00    	ja     f01024a8 <mem_init+0x13e1>
		switch (i) {
f0102415:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f010241a:	72 0e                	jb     f010242a <mem_init+0x1363>
f010241c:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102421:	76 e0                	jbe    f0102403 <mem_init+0x133c>
f0102423:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102428:	74 d9                	je     f0102403 <mem_init+0x133c>
			if (i >= PDX(KERNBASE)) {
f010242a:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010242f:	77 38                	ja     f0102469 <mem_init+0x13a2>
				assert(pgdir[i] == 0);
f0102431:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102435:	74 d2                	je     f0102409 <mem_init+0x1342>
f0102437:	68 80 48 10 f0       	push   $0xf0104880
f010243c:	68 a6 45 10 f0       	push   $0xf01045a6
f0102441:	68 a9 02 00 00       	push   $0x2a9
f0102446:	68 80 45 10 f0       	push   $0xf0104580
f010244b:	e8 e3 dc ff ff       	call   f0100133 <_panic>
			assert(pgdir[i] & PTE_P);
f0102450:	68 5e 48 10 f0       	push   $0xf010485e
f0102455:	68 a6 45 10 f0       	push   $0xf01045a6
f010245a:	68 a2 02 00 00       	push   $0x2a2
f010245f:	68 80 45 10 f0       	push   $0xf0104580
f0102464:	e8 ca dc ff ff       	call   f0100133 <_panic>
				assert(pgdir[i] & PTE_P);
f0102469:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f010246c:	f6 c2 01             	test   $0x1,%dl
f010246f:	74 1e                	je     f010248f <mem_init+0x13c8>
				assert(pgdir[i] & PTE_W);
f0102471:	f6 c2 02             	test   $0x2,%dl
f0102474:	75 93                	jne    f0102409 <mem_init+0x1342>
f0102476:	68 6f 48 10 f0       	push   $0xf010486f
f010247b:	68 a6 45 10 f0       	push   $0xf01045a6
f0102480:	68 a7 02 00 00       	push   $0x2a7
f0102485:	68 80 45 10 f0       	push   $0xf0104580
f010248a:	e8 a4 dc ff ff       	call   f0100133 <_panic>
				assert(pgdir[i] & PTE_P);
f010248f:	68 5e 48 10 f0       	push   $0xf010485e
f0102494:	68 a6 45 10 f0       	push   $0xf01045a6
f0102499:	68 a6 02 00 00       	push   $0x2a6
f010249e:	68 80 45 10 f0       	push   $0xf0104580
f01024a3:	e8 8b dc ff ff       	call   f0100133 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f01024a8:	83 ec 0c             	sub    $0xc,%esp
f01024ab:	68 c0 44 10 f0       	push   $0xf01044c0
f01024b0:	e8 fa 03 00 00       	call   f01028af <cprintf>
	lcr3(PADDR(kern_pgdir));
f01024b5:	a1 68 79 11 f0       	mov    0xf0117968,%eax
	if ((uint32_t)kva < KERNBASE)
f01024ba:	83 c4 10             	add    $0x10,%esp
f01024bd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01024c2:	0f 86 fe 01 00 00    	jbe    f01026c6 <mem_init+0x15ff>
	return (physaddr_t)kva - KERNBASE;
f01024c8:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01024cd:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f01024d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01024d5:	e8 5a e5 ff ff       	call   f0100a34 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01024da:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01024dd:	83 e0 f3             	and    $0xfffffff3,%eax
f01024e0:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01024e5:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01024e8:	83 ec 0c             	sub    $0xc,%esp
f01024eb:	6a 00                	push   $0x0
f01024ed:	e8 c5 e8 ff ff       	call   f0100db7 <page_alloc>
f01024f2:	89 c3                	mov    %eax,%ebx
f01024f4:	83 c4 10             	add    $0x10,%esp
f01024f7:	85 c0                	test   %eax,%eax
f01024f9:	0f 84 dc 01 00 00    	je     f01026db <mem_init+0x1614>
	assert((pp1 = page_alloc(0)));
f01024ff:	83 ec 0c             	sub    $0xc,%esp
f0102502:	6a 00                	push   $0x0
f0102504:	e8 ae e8 ff ff       	call   f0100db7 <page_alloc>
f0102509:	89 c7                	mov    %eax,%edi
f010250b:	83 c4 10             	add    $0x10,%esp
f010250e:	85 c0                	test   %eax,%eax
f0102510:	0f 84 de 01 00 00    	je     f01026f4 <mem_init+0x162d>
	assert((pp2 = page_alloc(0)));
f0102516:	83 ec 0c             	sub    $0xc,%esp
f0102519:	6a 00                	push   $0x0
f010251b:	e8 97 e8 ff ff       	call   f0100db7 <page_alloc>
f0102520:	89 c6                	mov    %eax,%esi
f0102522:	83 c4 10             	add    $0x10,%esp
f0102525:	85 c0                	test   %eax,%eax
f0102527:	0f 84 e0 01 00 00    	je     f010270d <mem_init+0x1646>
	page_free(pp0);
f010252d:	83 ec 0c             	sub    $0xc,%esp
f0102530:	53                   	push   %ebx
f0102531:	e8 f3 e8 ff ff       	call   f0100e29 <page_free>
	return (pp - pages) << PGSHIFT;
f0102536:	89 f8                	mov    %edi,%eax
f0102538:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f010253e:	c1 f8 03             	sar    $0x3,%eax
f0102541:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102544:	89 c2                	mov    %eax,%edx
f0102546:	c1 ea 0c             	shr    $0xc,%edx
f0102549:	83 c4 10             	add    $0x10,%esp
f010254c:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0102552:	0f 83 ce 01 00 00    	jae    f0102726 <mem_init+0x165f>
	memset(page2kva(pp1), 1, PGSIZE);
f0102558:	83 ec 04             	sub    $0x4,%esp
f010255b:	68 00 10 00 00       	push   $0x1000
f0102560:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102562:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102567:	50                   	push   %eax
f0102568:	e8 71 0e 00 00       	call   f01033de <memset>
	return (pp - pages) << PGSHIFT;
f010256d:	89 f0                	mov    %esi,%eax
f010256f:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0102575:	c1 f8 03             	sar    $0x3,%eax
f0102578:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010257b:	89 c2                	mov    %eax,%edx
f010257d:	c1 ea 0c             	shr    $0xc,%edx
f0102580:	83 c4 10             	add    $0x10,%esp
f0102583:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0102589:	0f 83 a9 01 00 00    	jae    f0102738 <mem_init+0x1671>
	memset(page2kva(pp2), 2, PGSIZE);
f010258f:	83 ec 04             	sub    $0x4,%esp
f0102592:	68 00 10 00 00       	push   $0x1000
f0102597:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102599:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010259e:	50                   	push   %eax
f010259f:	e8 3a 0e 00 00       	call   f01033de <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01025a4:	6a 02                	push   $0x2
f01025a6:	68 00 10 00 00       	push   $0x1000
f01025ab:	57                   	push   %edi
f01025ac:	ff 35 68 79 11 f0    	pushl  0xf0117968
f01025b2:	e8 a9 ea ff ff       	call   f0101060 <page_insert>
	assert(pp1->pp_ref == 1);
f01025b7:	83 c4 20             	add    $0x20,%esp
f01025ba:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01025bf:	0f 85 85 01 00 00    	jne    f010274a <mem_init+0x1683>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01025c5:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01025cc:	01 01 01 
f01025cf:	0f 85 8e 01 00 00    	jne    f0102763 <mem_init+0x169c>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01025d5:	6a 02                	push   $0x2
f01025d7:	68 00 10 00 00       	push   $0x1000
f01025dc:	56                   	push   %esi
f01025dd:	ff 35 68 79 11 f0    	pushl  0xf0117968
f01025e3:	e8 78 ea ff ff       	call   f0101060 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01025e8:	83 c4 10             	add    $0x10,%esp
f01025eb:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01025f2:	02 02 02 
f01025f5:	0f 85 81 01 00 00    	jne    f010277c <mem_init+0x16b5>
	assert(pp2->pp_ref == 1);
f01025fb:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102600:	0f 85 8f 01 00 00    	jne    f0102795 <mem_init+0x16ce>
	assert(pp1->pp_ref == 0);
f0102606:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010260b:	0f 85 9d 01 00 00    	jne    f01027ae <mem_init+0x16e7>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102611:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102618:	03 03 03 
	return (pp - pages) << PGSHIFT;
f010261b:	89 f0                	mov    %esi,%eax
f010261d:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0102623:	c1 f8 03             	sar    $0x3,%eax
f0102626:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102629:	89 c2                	mov    %eax,%edx
f010262b:	c1 ea 0c             	shr    $0xc,%edx
f010262e:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0102634:	0f 83 8d 01 00 00    	jae    f01027c7 <mem_init+0x1700>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010263a:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102641:	03 03 03 
f0102644:	0f 85 8f 01 00 00    	jne    f01027d9 <mem_init+0x1712>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010264a:	83 ec 08             	sub    $0x8,%esp
f010264d:	68 00 10 00 00       	push   $0x1000
f0102652:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0102658:	e8 c3 e9 ff ff       	call   f0101020 <page_remove>
	assert(pp2->pp_ref == 0);
f010265d:	83 c4 10             	add    $0x10,%esp
f0102660:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102665:	0f 85 87 01 00 00    	jne    f01027f2 <mem_init+0x172b>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010266b:	8b 0d 68 79 11 f0    	mov    0xf0117968,%ecx
f0102671:	8b 11                	mov    (%ecx),%edx
f0102673:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102679:	89 d8                	mov    %ebx,%eax
f010267b:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0102681:	c1 f8 03             	sar    $0x3,%eax
f0102684:	c1 e0 0c             	shl    $0xc,%eax
f0102687:	39 c2                	cmp    %eax,%edx
f0102689:	0f 85 7c 01 00 00    	jne    f010280b <mem_init+0x1744>
	kern_pgdir[0] = 0;
f010268f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102695:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010269a:	0f 85 84 01 00 00    	jne    f0102824 <mem_init+0x175d>
	pp0->pp_ref = 0;
f01026a0:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f01026a6:	83 ec 0c             	sub    $0xc,%esp
f01026a9:	53                   	push   %ebx
f01026aa:	e8 7a e7 ff ff       	call   f0100e29 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01026af:	c7 04 24 54 45 10 f0 	movl   $0xf0104554,(%esp)
f01026b6:	e8 f4 01 00 00       	call   f01028af <cprintf>
}
f01026bb:	83 c4 10             	add    $0x10,%esp
f01026be:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01026c1:	5b                   	pop    %ebx
f01026c2:	5e                   	pop    %esi
f01026c3:	5f                   	pop    %edi
f01026c4:	5d                   	pop    %ebp
f01026c5:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026c6:	50                   	push   %eax
f01026c7:	68 ec 3e 10 f0       	push   $0xf0103eec
f01026cc:	68 d4 00 00 00       	push   $0xd4
f01026d1:	68 80 45 10 f0       	push   $0xf0104580
f01026d6:	e8 58 da ff ff       	call   f0100133 <_panic>
	assert((pp0 = page_alloc(0)));
f01026db:	68 7c 46 10 f0       	push   $0xf010467c
f01026e0:	68 a6 45 10 f0       	push   $0xf01045a6
f01026e5:	68 69 03 00 00       	push   $0x369
f01026ea:	68 80 45 10 f0       	push   $0xf0104580
f01026ef:	e8 3f da ff ff       	call   f0100133 <_panic>
	assert((pp1 = page_alloc(0)));
f01026f4:	68 92 46 10 f0       	push   $0xf0104692
f01026f9:	68 a6 45 10 f0       	push   $0xf01045a6
f01026fe:	68 6a 03 00 00       	push   $0x36a
f0102703:	68 80 45 10 f0       	push   $0xf0104580
f0102708:	e8 26 da ff ff       	call   f0100133 <_panic>
	assert((pp2 = page_alloc(0)));
f010270d:	68 a8 46 10 f0       	push   $0xf01046a8
f0102712:	68 a6 45 10 f0       	push   $0xf01045a6
f0102717:	68 6b 03 00 00       	push   $0x36b
f010271c:	68 80 45 10 f0       	push   $0xf0104580
f0102721:	e8 0d da ff ff       	call   f0100133 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102726:	50                   	push   %eax
f0102727:	68 e0 3d 10 f0       	push   $0xf0103de0
f010272c:	6a 52                	push   $0x52
f010272e:	68 8c 45 10 f0       	push   $0xf010458c
f0102733:	e8 fb d9 ff ff       	call   f0100133 <_panic>
f0102738:	50                   	push   %eax
f0102739:	68 e0 3d 10 f0       	push   $0xf0103de0
f010273e:	6a 52                	push   $0x52
f0102740:	68 8c 45 10 f0       	push   $0xf010458c
f0102745:	e8 e9 d9 ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 1);
f010274a:	68 79 47 10 f0       	push   $0xf0104779
f010274f:	68 a6 45 10 f0       	push   $0xf01045a6
f0102754:	68 70 03 00 00       	push   $0x370
f0102759:	68 80 45 10 f0       	push   $0xf0104580
f010275e:	e8 d0 d9 ff ff       	call   f0100133 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102763:	68 e0 44 10 f0       	push   $0xf01044e0
f0102768:	68 a6 45 10 f0       	push   $0xf01045a6
f010276d:	68 71 03 00 00       	push   $0x371
f0102772:	68 80 45 10 f0       	push   $0xf0104580
f0102777:	e8 b7 d9 ff ff       	call   f0100133 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010277c:	68 04 45 10 f0       	push   $0xf0104504
f0102781:	68 a6 45 10 f0       	push   $0xf01045a6
f0102786:	68 73 03 00 00       	push   $0x373
f010278b:	68 80 45 10 f0       	push   $0xf0104580
f0102790:	e8 9e d9 ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 1);
f0102795:	68 9b 47 10 f0       	push   $0xf010479b
f010279a:	68 a6 45 10 f0       	push   $0xf01045a6
f010279f:	68 74 03 00 00       	push   $0x374
f01027a4:	68 80 45 10 f0       	push   $0xf0104580
f01027a9:	e8 85 d9 ff ff       	call   f0100133 <_panic>
	assert(pp1->pp_ref == 0);
f01027ae:	68 05 48 10 f0       	push   $0xf0104805
f01027b3:	68 a6 45 10 f0       	push   $0xf01045a6
f01027b8:	68 75 03 00 00       	push   $0x375
f01027bd:	68 80 45 10 f0       	push   $0xf0104580
f01027c2:	e8 6c d9 ff ff       	call   f0100133 <_panic>
f01027c7:	50                   	push   %eax
f01027c8:	68 e0 3d 10 f0       	push   $0xf0103de0
f01027cd:	6a 52                	push   $0x52
f01027cf:	68 8c 45 10 f0       	push   $0xf010458c
f01027d4:	e8 5a d9 ff ff       	call   f0100133 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01027d9:	68 28 45 10 f0       	push   $0xf0104528
f01027de:	68 a6 45 10 f0       	push   $0xf01045a6
f01027e3:	68 77 03 00 00       	push   $0x377
f01027e8:	68 80 45 10 f0       	push   $0xf0104580
f01027ed:	e8 41 d9 ff ff       	call   f0100133 <_panic>
	assert(pp2->pp_ref == 0);
f01027f2:	68 d3 47 10 f0       	push   $0xf01047d3
f01027f7:	68 a6 45 10 f0       	push   $0xf01045a6
f01027fc:	68 79 03 00 00       	push   $0x379
f0102801:	68 80 45 10 f0       	push   $0xf0104580
f0102806:	e8 28 d9 ff ff       	call   f0100133 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010280b:	68 44 40 10 f0       	push   $0xf0104044
f0102810:	68 a6 45 10 f0       	push   $0xf01045a6
f0102815:	68 7c 03 00 00       	push   $0x37c
f010281a:	68 80 45 10 f0       	push   $0xf0104580
f010281f:	e8 0f d9 ff ff       	call   f0100133 <_panic>
	assert(pp0->pp_ref == 1);
f0102824:	68 8a 47 10 f0       	push   $0xf010478a
f0102829:	68 a6 45 10 f0       	push   $0xf01045a6
f010282e:	68 7e 03 00 00       	push   $0x37e
f0102833:	68 80 45 10 f0       	push   $0xf0104580
f0102838:	e8 f6 d8 ff ff       	call   f0100133 <_panic>

f010283d <tlb_invalidate>:
{
f010283d:	55                   	push   %ebp
f010283e:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102840:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102843:	0f 01 38             	invlpg (%eax)
}
f0102846:	5d                   	pop    %ebp
f0102847:	c3                   	ret    

f0102848 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102848:	55                   	push   %ebp
f0102849:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010284b:	8b 45 08             	mov    0x8(%ebp),%eax
f010284e:	ba 70 00 00 00       	mov    $0x70,%edx
f0102853:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102854:	ba 71 00 00 00       	mov    $0x71,%edx
f0102859:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010285a:	0f b6 c0             	movzbl %al,%eax
}
f010285d:	5d                   	pop    %ebp
f010285e:	c3                   	ret    

f010285f <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010285f:	55                   	push   %ebp
f0102860:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102862:	8b 45 08             	mov    0x8(%ebp),%eax
f0102865:	ba 70 00 00 00       	mov    $0x70,%edx
f010286a:	ee                   	out    %al,(%dx)
f010286b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010286e:	ba 71 00 00 00       	mov    $0x71,%edx
f0102873:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102874:	5d                   	pop    %ebp
f0102875:	c3                   	ret    

f0102876 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102876:	55                   	push   %ebp
f0102877:	89 e5                	mov    %esp,%ebp
f0102879:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010287c:	ff 75 08             	pushl  0x8(%ebp)
f010287f:	e8 02 de ff ff       	call   f0100686 <cputchar>
	*cnt++;
}
f0102884:	83 c4 10             	add    $0x10,%esp
f0102887:	c9                   	leave  
f0102888:	c3                   	ret    

f0102889 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102889:	55                   	push   %ebp
f010288a:	89 e5                	mov    %esp,%ebp
f010288c:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010288f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102896:	ff 75 0c             	pushl  0xc(%ebp)
f0102899:	ff 75 08             	pushl  0x8(%ebp)
f010289c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010289f:	50                   	push   %eax
f01028a0:	68 76 28 10 f0       	push   $0xf0102876
f01028a5:	e8 1b 04 00 00       	call   f0102cc5 <vprintfmt>
	return cnt;
}
f01028aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01028ad:	c9                   	leave  
f01028ae:	c3                   	ret    

f01028af <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01028af:	55                   	push   %ebp
f01028b0:	89 e5                	mov    %esp,%ebp
f01028b2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01028b5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01028b8:	50                   	push   %eax
f01028b9:	ff 75 08             	pushl  0x8(%ebp)
f01028bc:	e8 c8 ff ff ff       	call   f0102889 <vcprintf>
	va_end(ap);

	return cnt;
}
f01028c1:	c9                   	leave  
f01028c2:	c3                   	ret    

f01028c3 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01028c3:	55                   	push   %ebp
f01028c4:	89 e5                	mov    %esp,%ebp
f01028c6:	57                   	push   %edi
f01028c7:	56                   	push   %esi
f01028c8:	53                   	push   %ebx
f01028c9:	83 ec 14             	sub    $0x14,%esp
f01028cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01028cf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01028d2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01028d5:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01028d8:	8b 32                	mov    (%edx),%esi
f01028da:	8b 01                	mov    (%ecx),%eax
f01028dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01028df:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01028e6:	eb 2f                	jmp    f0102917 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f01028e8:	48                   	dec    %eax
		while (m >= l && stabs[m].n_type != type)
f01028e9:	39 c6                	cmp    %eax,%esi
f01028eb:	7f 4d                	jg     f010293a <stab_binsearch+0x77>
f01028ed:	0f b6 0a             	movzbl (%edx),%ecx
f01028f0:	83 ea 0c             	sub    $0xc,%edx
f01028f3:	39 f9                	cmp    %edi,%ecx
f01028f5:	75 f1                	jne    f01028e8 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01028f7:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01028fa:	01 c2                	add    %eax,%edx
f01028fc:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01028ff:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0102903:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102906:	73 37                	jae    f010293f <stab_binsearch+0x7c>
			*region_left = m;
f0102908:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010290b:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f010290d:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0102910:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0102917:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f010291a:	7f 4d                	jg     f0102969 <stab_binsearch+0xa6>
		int true_m = (l + r) / 2, m = true_m;
f010291c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010291f:	01 f0                	add    %esi,%eax
f0102921:	89 c3                	mov    %eax,%ebx
f0102923:	c1 eb 1f             	shr    $0x1f,%ebx
f0102926:	01 c3                	add    %eax,%ebx
f0102928:	d1 fb                	sar    %ebx
f010292a:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f010292d:	01 d8                	add    %ebx,%eax
f010292f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102932:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0102936:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0102938:	eb af                	jmp    f01028e9 <stab_binsearch+0x26>
			l = true_m + 1;
f010293a:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f010293d:	eb d8                	jmp    f0102917 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f010293f:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0102942:	76 12                	jbe    f0102956 <stab_binsearch+0x93>
			*region_right = m - 1;
f0102944:	48                   	dec    %eax
f0102945:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102948:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010294b:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f010294d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102954:	eb c1                	jmp    f0102917 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102956:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102959:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f010295b:	ff 45 0c             	incl   0xc(%ebp)
f010295e:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0102960:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102967:	eb ae                	jmp    f0102917 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0102969:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010296d:	74 18                	je     f0102987 <stab_binsearch+0xc4>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010296f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102972:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102974:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102977:	8b 0e                	mov    (%esi),%ecx
f0102979:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010297c:	01 c2                	add    %eax,%edx
f010297e:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0102981:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0102985:	eb 0e                	jmp    f0102995 <stab_binsearch+0xd2>
		*region_right = *region_left - 1;
f0102987:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010298a:	8b 00                	mov    (%eax),%eax
f010298c:	48                   	dec    %eax
f010298d:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0102990:	89 07                	mov    %eax,(%edi)
f0102992:	eb 14                	jmp    f01029a8 <stab_binsearch+0xe5>
		     l--)
f0102994:	48                   	dec    %eax
		for (l = *region_right;
f0102995:	39 c1                	cmp    %eax,%ecx
f0102997:	7d 0a                	jge    f01029a3 <stab_binsearch+0xe0>
		     l > *region_left && stabs[l].n_type != type;
f0102999:	0f b6 1a             	movzbl (%edx),%ebx
f010299c:	83 ea 0c             	sub    $0xc,%edx
f010299f:	39 fb                	cmp    %edi,%ebx
f01029a1:	75 f1                	jne    f0102994 <stab_binsearch+0xd1>
			/* do nothing */;
		*region_left = l;
f01029a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01029a6:	89 07                	mov    %eax,(%edi)
	}
}
f01029a8:	83 c4 14             	add    $0x14,%esp
f01029ab:	5b                   	pop    %ebx
f01029ac:	5e                   	pop    %esi
f01029ad:	5f                   	pop    %edi
f01029ae:	5d                   	pop    %ebp
f01029af:	c3                   	ret    

f01029b0 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01029b0:	55                   	push   %ebp
f01029b1:	89 e5                	mov    %esp,%ebp
f01029b3:	57                   	push   %edi
f01029b4:	56                   	push   %esi
f01029b5:	53                   	push   %ebx
f01029b6:	83 ec 3c             	sub    $0x3c,%esp
f01029b9:	8b 75 08             	mov    0x8(%ebp),%esi
f01029bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01029bf:	c7 03 8e 48 10 f0    	movl   $0xf010488e,(%ebx)
	info->eip_line = 0;
f01029c5:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01029cc:	c7 43 08 8e 48 10 f0 	movl   $0xf010488e,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01029d3:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01029da:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01029dd:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01029e4:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01029ea:	0f 86 31 01 00 00    	jbe    f0102b21 <debuginfo_eip+0x171>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01029f0:	b8 5d cf 10 f0       	mov    $0xf010cf5d,%eax
f01029f5:	3d 49 b1 10 f0       	cmp    $0xf010b149,%eax
f01029fa:	0f 86 b6 01 00 00    	jbe    f0102bb6 <debuginfo_eip+0x206>
f0102a00:	80 3d 5c cf 10 f0 00 	cmpb   $0x0,0xf010cf5c
f0102a07:	0f 85 b0 01 00 00    	jne    f0102bbd <debuginfo_eip+0x20d>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102a0d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102a14:	ba 48 b1 10 f0       	mov    $0xf010b148,%edx
f0102a19:	81 ea c4 4a 10 f0    	sub    $0xf0104ac4,%edx
f0102a1f:	c1 fa 02             	sar    $0x2,%edx
f0102a22:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0102a25:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0102a28:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0102a2b:	89 c1                	mov    %eax,%ecx
f0102a2d:	c1 e1 08             	shl    $0x8,%ecx
f0102a30:	01 c8                	add    %ecx,%eax
f0102a32:	89 c1                	mov    %eax,%ecx
f0102a34:	c1 e1 10             	shl    $0x10,%ecx
f0102a37:	01 c8                	add    %ecx,%eax
f0102a39:	01 c0                	add    %eax,%eax
f0102a3b:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
f0102a3f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102a42:	83 ec 08             	sub    $0x8,%esp
f0102a45:	56                   	push   %esi
f0102a46:	6a 64                	push   $0x64
f0102a48:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102a4b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102a4e:	b8 c4 4a 10 f0       	mov    $0xf0104ac4,%eax
f0102a53:	e8 6b fe ff ff       	call   f01028c3 <stab_binsearch>
	if (lfile == 0)
f0102a58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102a5b:	83 c4 10             	add    $0x10,%esp
f0102a5e:	85 c0                	test   %eax,%eax
f0102a60:	0f 84 5e 01 00 00    	je     f0102bc4 <debuginfo_eip+0x214>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102a66:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0102a69:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102a6c:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102a6f:	83 ec 08             	sub    $0x8,%esp
f0102a72:	56                   	push   %esi
f0102a73:	6a 24                	push   $0x24
f0102a75:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102a78:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102a7b:	b8 c4 4a 10 f0       	mov    $0xf0104ac4,%eax
f0102a80:	e8 3e fe ff ff       	call   f01028c3 <stab_binsearch>

	if (lfun <= rfun) {
f0102a85:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102a88:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102a8b:	83 c4 10             	add    $0x10,%esp
f0102a8e:	39 d0                	cmp    %edx,%eax
f0102a90:	0f 8f 9f 00 00 00    	jg     f0102b35 <debuginfo_eip+0x185>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102a96:	8d 0c 00             	lea    (%eax,%eax,1),%ecx
f0102a99:	01 c1                	add    %eax,%ecx
f0102a9b:	c1 e1 02             	shl    $0x2,%ecx
f0102a9e:	8d b9 c4 4a 10 f0    	lea    -0xfefb53c(%ecx),%edi
f0102aa4:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0102aa7:	8b 89 c4 4a 10 f0    	mov    -0xfefb53c(%ecx),%ecx
f0102aad:	bf 5d cf 10 f0       	mov    $0xf010cf5d,%edi
f0102ab2:	81 ef 49 b1 10 f0    	sub    $0xf010b149,%edi
f0102ab8:	39 f9                	cmp    %edi,%ecx
f0102aba:	73 09                	jae    f0102ac5 <debuginfo_eip+0x115>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102abc:	81 c1 49 b1 10 f0    	add    $0xf010b149,%ecx
f0102ac2:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102ac5:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0102ac8:	8b 4f 08             	mov    0x8(%edi),%ecx
f0102acb:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102ace:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0102ad0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0102ad3:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102ad6:	83 ec 08             	sub    $0x8,%esp
f0102ad9:	6a 3a                	push   $0x3a
f0102adb:	ff 73 08             	pushl  0x8(%ebx)
f0102ade:	e8 e3 08 00 00       	call   f01033c6 <strfind>
f0102ae3:	2b 43 08             	sub    0x8(%ebx),%eax
f0102ae6:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// N_SLINE represents text segment
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0102ae9:	83 c4 08             	add    $0x8,%esp
f0102aec:	56                   	push   %esi
f0102aed:	6a 44                	push   $0x44
f0102aef:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0102af2:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0102af5:	b8 c4 4a 10 f0       	mov    $0xf0104ac4,%eax
f0102afa:	e8 c4 fd ff ff       	call   f01028c3 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0102aff:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102b02:	8d 04 12             	lea    (%edx,%edx,1),%eax
f0102b05:	01 d0                	add    %edx,%eax
f0102b07:	c1 e0 02             	shl    $0x2,%eax
f0102b0a:	0f b7 88 ca 4a 10 f0 	movzwl -0xfefb536(%eax),%ecx
f0102b11:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102b14:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102b17:	05 c8 4a 10 f0       	add    $0xf0104ac8,%eax
f0102b1c:	83 c4 10             	add    $0x10,%esp
f0102b1f:	eb 29                	jmp    f0102b4a <debuginfo_eip+0x19a>
  	        panic("User address");
f0102b21:	83 ec 04             	sub    $0x4,%esp
f0102b24:	68 98 48 10 f0       	push   $0xf0104898
f0102b29:	6a 7f                	push   $0x7f
f0102b2b:	68 a5 48 10 f0       	push   $0xf01048a5
f0102b30:	e8 fe d5 ff ff       	call   f0100133 <_panic>
		info->eip_fn_addr = addr;
f0102b35:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102b38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102b3b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0102b3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102b41:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102b44:	eb 90                	jmp    f0102ad6 <debuginfo_eip+0x126>
f0102b46:	4a                   	dec    %edx
f0102b47:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0102b4a:	39 d6                	cmp    %edx,%esi
f0102b4c:	7f 34                	jg     f0102b82 <debuginfo_eip+0x1d2>
	       && stabs[lline].n_type != N_SOL
f0102b4e:	8a 08                	mov    (%eax),%cl
f0102b50:	80 f9 84             	cmp    $0x84,%cl
f0102b53:	74 0b                	je     f0102b60 <debuginfo_eip+0x1b0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102b55:	80 f9 64             	cmp    $0x64,%cl
f0102b58:	75 ec                	jne    f0102b46 <debuginfo_eip+0x196>
f0102b5a:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0102b5e:	74 e6                	je     f0102b46 <debuginfo_eip+0x196>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102b60:	8d 04 12             	lea    (%edx,%edx,1),%eax
f0102b63:	01 c2                	add    %eax,%edx
f0102b65:	8b 14 95 c4 4a 10 f0 	mov    -0xfefb53c(,%edx,4),%edx
f0102b6c:	b8 5d cf 10 f0       	mov    $0xf010cf5d,%eax
f0102b71:	2d 49 b1 10 f0       	sub    $0xf010b149,%eax
f0102b76:	39 c2                	cmp    %eax,%edx
f0102b78:	73 08                	jae    f0102b82 <debuginfo_eip+0x1d2>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102b7a:	81 c2 49 b1 10 f0    	add    $0xf010b149,%edx
f0102b80:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102b82:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102b85:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0102b88:	39 f2                	cmp    %esi,%edx
f0102b8a:	7d 3f                	jge    f0102bcb <debuginfo_eip+0x21b>
		for (lline = lfun + 1;
f0102b8c:	42                   	inc    %edx
f0102b8d:	89 d0                	mov    %edx,%eax
f0102b8f:	8d 0c 12             	lea    (%edx,%edx,1),%ecx
f0102b92:	01 ca                	add    %ecx,%edx
f0102b94:	8d 14 95 c8 4a 10 f0 	lea    -0xfefb538(,%edx,4),%edx
f0102b9b:	eb 03                	jmp    f0102ba0 <debuginfo_eip+0x1f0>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0102b9d:	ff 43 14             	incl   0x14(%ebx)
		for (lline = lfun + 1;
f0102ba0:	39 c6                	cmp    %eax,%esi
f0102ba2:	7e 34                	jle    f0102bd8 <debuginfo_eip+0x228>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102ba4:	8a 0a                	mov    (%edx),%cl
f0102ba6:	40                   	inc    %eax
f0102ba7:	83 c2 0c             	add    $0xc,%edx
f0102baa:	80 f9 a0             	cmp    $0xa0,%cl
f0102bad:	74 ee                	je     f0102b9d <debuginfo_eip+0x1ed>

	return 0;
f0102baf:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bb4:	eb 1a                	jmp    f0102bd0 <debuginfo_eip+0x220>
		return -1;
f0102bb6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102bbb:	eb 13                	jmp    f0102bd0 <debuginfo_eip+0x220>
f0102bbd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102bc2:	eb 0c                	jmp    f0102bd0 <debuginfo_eip+0x220>
		return -1;
f0102bc4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102bc9:	eb 05                	jmp    f0102bd0 <debuginfo_eip+0x220>
	return 0;
f0102bcb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102bd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102bd3:	5b                   	pop    %ebx
f0102bd4:	5e                   	pop    %esi
f0102bd5:	5f                   	pop    %edi
f0102bd6:	5d                   	pop    %ebp
f0102bd7:	c3                   	ret    
	return 0;
f0102bd8:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bdd:	eb f1                	jmp    f0102bd0 <debuginfo_eip+0x220>

f0102bdf <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102bdf:	55                   	push   %ebp
f0102be0:	89 e5                	mov    %esp,%ebp
f0102be2:	57                   	push   %edi
f0102be3:	56                   	push   %esi
f0102be4:	53                   	push   %ebx
f0102be5:	83 ec 1c             	sub    $0x1c,%esp
f0102be8:	89 c7                	mov    %eax,%edi
f0102bea:	89 d6                	mov    %edx,%esi
f0102bec:	8b 45 08             	mov    0x8(%ebp),%eax
f0102bef:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102bf2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102bf5:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102bf8:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0102bfb:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102c00:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102c03:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0102c06:	39 d3                	cmp    %edx,%ebx
f0102c08:	72 05                	jb     f0102c0f <printnum+0x30>
f0102c0a:	39 45 10             	cmp    %eax,0x10(%ebp)
f0102c0d:	77 78                	ja     f0102c87 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102c0f:	83 ec 0c             	sub    $0xc,%esp
f0102c12:	ff 75 18             	pushl  0x18(%ebp)
f0102c15:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c18:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0102c1b:	53                   	push   %ebx
f0102c1c:	ff 75 10             	pushl  0x10(%ebp)
f0102c1f:	83 ec 08             	sub    $0x8,%esp
f0102c22:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102c25:	ff 75 e0             	pushl  -0x20(%ebp)
f0102c28:	ff 75 dc             	pushl  -0x24(%ebp)
f0102c2b:	ff 75 d8             	pushl  -0x28(%ebp)
f0102c2e:	e8 8d 09 00 00       	call   f01035c0 <__udivdi3>
f0102c33:	83 c4 18             	add    $0x18,%esp
f0102c36:	52                   	push   %edx
f0102c37:	50                   	push   %eax
f0102c38:	89 f2                	mov    %esi,%edx
f0102c3a:	89 f8                	mov    %edi,%eax
f0102c3c:	e8 9e ff ff ff       	call   f0102bdf <printnum>
f0102c41:	83 c4 20             	add    $0x20,%esp
f0102c44:	eb 11                	jmp    f0102c57 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102c46:	83 ec 08             	sub    $0x8,%esp
f0102c49:	56                   	push   %esi
f0102c4a:	ff 75 18             	pushl  0x18(%ebp)
f0102c4d:	ff d7                	call   *%edi
f0102c4f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0102c52:	4b                   	dec    %ebx
f0102c53:	85 db                	test   %ebx,%ebx
f0102c55:	7f ef                	jg     f0102c46 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102c57:	83 ec 08             	sub    $0x8,%esp
f0102c5a:	56                   	push   %esi
f0102c5b:	83 ec 04             	sub    $0x4,%esp
f0102c5e:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102c61:	ff 75 e0             	pushl  -0x20(%ebp)
f0102c64:	ff 75 dc             	pushl  -0x24(%ebp)
f0102c67:	ff 75 d8             	pushl  -0x28(%ebp)
f0102c6a:	e8 51 0a 00 00       	call   f01036c0 <__umoddi3>
f0102c6f:	83 c4 14             	add    $0x14,%esp
f0102c72:	0f be 80 b3 48 10 f0 	movsbl -0xfefb74d(%eax),%eax
f0102c79:	50                   	push   %eax
f0102c7a:	ff d7                	call   *%edi
}
f0102c7c:	83 c4 10             	add    $0x10,%esp
f0102c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102c82:	5b                   	pop    %ebx
f0102c83:	5e                   	pop    %esi
f0102c84:	5f                   	pop    %edi
f0102c85:	5d                   	pop    %ebp
f0102c86:	c3                   	ret    
f0102c87:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0102c8a:	eb c6                	jmp    f0102c52 <printnum+0x73>

f0102c8c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102c8c:	55                   	push   %ebp
f0102c8d:	89 e5                	mov    %esp,%ebp
f0102c8f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102c92:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0102c95:	8b 10                	mov    (%eax),%edx
f0102c97:	3b 50 04             	cmp    0x4(%eax),%edx
f0102c9a:	73 0a                	jae    f0102ca6 <sprintputch+0x1a>
		*b->buf++ = ch;
f0102c9c:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102c9f:	89 08                	mov    %ecx,(%eax)
f0102ca1:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ca4:	88 02                	mov    %al,(%edx)
}
f0102ca6:	5d                   	pop    %ebp
f0102ca7:	c3                   	ret    

f0102ca8 <printfmt>:
{
f0102ca8:	55                   	push   %ebp
f0102ca9:	89 e5                	mov    %esp,%ebp
f0102cab:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0102cae:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102cb1:	50                   	push   %eax
f0102cb2:	ff 75 10             	pushl  0x10(%ebp)
f0102cb5:	ff 75 0c             	pushl  0xc(%ebp)
f0102cb8:	ff 75 08             	pushl  0x8(%ebp)
f0102cbb:	e8 05 00 00 00       	call   f0102cc5 <vprintfmt>
}
f0102cc0:	83 c4 10             	add    $0x10,%esp
f0102cc3:	c9                   	leave  
f0102cc4:	c3                   	ret    

f0102cc5 <vprintfmt>:
{
f0102cc5:	55                   	push   %ebp
f0102cc6:	89 e5                	mov    %esp,%ebp
f0102cc8:	57                   	push   %edi
f0102cc9:	56                   	push   %esi
f0102cca:	53                   	push   %ebx
f0102ccb:	83 ec 2c             	sub    $0x2c,%esp
f0102cce:	8b 75 08             	mov    0x8(%ebp),%esi
f0102cd1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102cd4:	8b 7d 10             	mov    0x10(%ebp),%edi
f0102cd7:	e9 ac 03 00 00       	jmp    f0103088 <vprintfmt+0x3c3>
		padc = ' ';
f0102cdc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0102ce0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0102ce7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f0102cee:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0102cf5:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0102cfa:	8d 47 01             	lea    0x1(%edi),%eax
f0102cfd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102d00:	8a 17                	mov    (%edi),%dl
f0102d02:	8d 42 dd             	lea    -0x23(%edx),%eax
f0102d05:	3c 55                	cmp    $0x55,%al
f0102d07:	0f 87 fc 03 00 00    	ja     f0103109 <vprintfmt+0x444>
f0102d0d:	0f b6 c0             	movzbl %al,%eax
f0102d10:	ff 24 85 40 49 10 f0 	jmp    *-0xfefb6c0(,%eax,4)
f0102d17:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0102d1a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0102d1e:	eb da                	jmp    f0102cfa <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0102d20:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0102d23:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0102d27:	eb d1                	jmp    f0102cfa <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0102d29:	0f b6 d2             	movzbl %dl,%edx
f0102d2c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0102d2f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d34:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0102d37:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102d3a:	01 c0                	add    %eax,%eax
f0102d3c:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
f0102d40:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0102d43:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0102d46:	83 f9 09             	cmp    $0x9,%ecx
f0102d49:	77 52                	ja     f0102d9d <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
f0102d4b:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
f0102d4c:	eb e9                	jmp    f0102d37 <vprintfmt+0x72>
			precision = va_arg(ap, int);
f0102d4e:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d51:	8b 00                	mov    (%eax),%eax
f0102d53:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102d56:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d59:	8d 40 04             	lea    0x4(%eax),%eax
f0102d5c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0102d5f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0102d62:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102d66:	79 92                	jns    f0102cfa <vprintfmt+0x35>
				width = precision, precision = -1;
f0102d68:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102d6b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102d6e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102d75:	eb 83                	jmp    f0102cfa <vprintfmt+0x35>
f0102d77:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102d7b:	78 08                	js     f0102d85 <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
f0102d7d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102d80:	e9 75 ff ff ff       	jmp    f0102cfa <vprintfmt+0x35>
f0102d85:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102d8c:	eb ef                	jmp    f0102d7d <vprintfmt+0xb8>
f0102d8e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0102d91:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0102d98:	e9 5d ff ff ff       	jmp    f0102cfa <vprintfmt+0x35>
f0102d9d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102da0:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102da3:	eb bd                	jmp    f0102d62 <vprintfmt+0x9d>
			lflag++;
f0102da5:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
f0102da6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0102da9:	e9 4c ff ff ff       	jmp    f0102cfa <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f0102dae:	8b 45 14             	mov    0x14(%ebp),%eax
f0102db1:	8d 78 04             	lea    0x4(%eax),%edi
f0102db4:	83 ec 08             	sub    $0x8,%esp
f0102db7:	53                   	push   %ebx
f0102db8:	ff 30                	pushl  (%eax)
f0102dba:	ff d6                	call   *%esi
			break;
f0102dbc:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0102dbf:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0102dc2:	e9 be 02 00 00       	jmp    f0103085 <vprintfmt+0x3c0>
			err = va_arg(ap, int);
f0102dc7:	8b 45 14             	mov    0x14(%ebp),%eax
f0102dca:	8d 78 04             	lea    0x4(%eax),%edi
f0102dcd:	8b 00                	mov    (%eax),%eax
f0102dcf:	85 c0                	test   %eax,%eax
f0102dd1:	78 2a                	js     f0102dfd <vprintfmt+0x138>
f0102dd3:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102dd5:	83 f8 06             	cmp    $0x6,%eax
f0102dd8:	7f 27                	jg     f0102e01 <vprintfmt+0x13c>
f0102dda:	8b 04 85 98 4a 10 f0 	mov    -0xfefb568(,%eax,4),%eax
f0102de1:	85 c0                	test   %eax,%eax
f0102de3:	74 1c                	je     f0102e01 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
f0102de5:	50                   	push   %eax
f0102de6:	68 b8 45 10 f0       	push   $0xf01045b8
f0102deb:	53                   	push   %ebx
f0102dec:	56                   	push   %esi
f0102ded:	e8 b6 fe ff ff       	call   f0102ca8 <printfmt>
f0102df2:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0102df5:	89 7d 14             	mov    %edi,0x14(%ebp)
f0102df8:	e9 88 02 00 00       	jmp    f0103085 <vprintfmt+0x3c0>
f0102dfd:	f7 d8                	neg    %eax
f0102dff:	eb d2                	jmp    f0102dd3 <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
f0102e01:	52                   	push   %edx
f0102e02:	68 cb 48 10 f0       	push   $0xf01048cb
f0102e07:	53                   	push   %ebx
f0102e08:	56                   	push   %esi
f0102e09:	e8 9a fe ff ff       	call   f0102ca8 <printfmt>
f0102e0e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0102e11:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0102e14:	e9 6c 02 00 00       	jmp    f0103085 <vprintfmt+0x3c0>
			if ((p = va_arg(ap, char *)) == NULL)
f0102e19:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e1c:	83 c0 04             	add    $0x4,%eax
f0102e1f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102e22:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e25:	8b 38                	mov    (%eax),%edi
f0102e27:	85 ff                	test   %edi,%edi
f0102e29:	74 18                	je     f0102e43 <vprintfmt+0x17e>
			if (width > 0 && padc != '-')
f0102e2b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102e2f:	0f 8e b7 00 00 00    	jle    f0102eec <vprintfmt+0x227>
f0102e35:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0102e39:	75 0f                	jne    f0102e4a <vprintfmt+0x185>
f0102e3b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102e3e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102e41:	eb 6e                	jmp    f0102eb1 <vprintfmt+0x1ec>
				p = "(null)";
f0102e43:	bf c4 48 10 f0       	mov    $0xf01048c4,%edi
f0102e48:	eb e1                	jmp    f0102e2b <vprintfmt+0x166>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102e4a:	83 ec 08             	sub    $0x8,%esp
f0102e4d:	ff 75 d0             	pushl  -0x30(%ebp)
f0102e50:	57                   	push   %edi
f0102e51:	e8 45 04 00 00       	call   f010329b <strnlen>
f0102e56:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102e59:	29 c1                	sub    %eax,%ecx
f0102e5b:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0102e5e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0102e61:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0102e65:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102e68:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102e6b:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0102e6d:	eb 0d                	jmp    f0102e7c <vprintfmt+0x1b7>
					putch(padc, putdat);
f0102e6f:	83 ec 08             	sub    $0x8,%esp
f0102e72:	53                   	push   %ebx
f0102e73:	ff 75 e0             	pushl  -0x20(%ebp)
f0102e76:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0102e78:	4f                   	dec    %edi
f0102e79:	83 c4 10             	add    $0x10,%esp
f0102e7c:	85 ff                	test   %edi,%edi
f0102e7e:	7f ef                	jg     f0102e6f <vprintfmt+0x1aa>
f0102e80:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102e83:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102e86:	89 c8                	mov    %ecx,%eax
f0102e88:	85 c9                	test   %ecx,%ecx
f0102e8a:	78 59                	js     f0102ee5 <vprintfmt+0x220>
f0102e8c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102e8f:	29 c1                	sub    %eax,%ecx
f0102e91:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102e94:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102e97:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102e9a:	eb 15                	jmp    f0102eb1 <vprintfmt+0x1ec>
				if (altflag && (ch < ' ' || ch > '~'))
f0102e9c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0102ea0:	75 29                	jne    f0102ecb <vprintfmt+0x206>
					putch(ch, putdat);
f0102ea2:	83 ec 08             	sub    $0x8,%esp
f0102ea5:	ff 75 0c             	pushl  0xc(%ebp)
f0102ea8:	50                   	push   %eax
f0102ea9:	ff d6                	call   *%esi
f0102eab:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102eae:	ff 4d e0             	decl   -0x20(%ebp)
f0102eb1:	47                   	inc    %edi
f0102eb2:	8a 57 ff             	mov    -0x1(%edi),%dl
f0102eb5:	0f be c2             	movsbl %dl,%eax
f0102eb8:	85 c0                	test   %eax,%eax
f0102eba:	74 53                	je     f0102f0f <vprintfmt+0x24a>
f0102ebc:	85 db                	test   %ebx,%ebx
f0102ebe:	78 dc                	js     f0102e9c <vprintfmt+0x1d7>
f0102ec0:	4b                   	dec    %ebx
f0102ec1:	79 d9                	jns    f0102e9c <vprintfmt+0x1d7>
f0102ec3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102ec6:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0102ec9:	eb 35                	jmp    f0102f00 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
f0102ecb:	0f be d2             	movsbl %dl,%edx
f0102ece:	83 ea 20             	sub    $0x20,%edx
f0102ed1:	83 fa 5e             	cmp    $0x5e,%edx
f0102ed4:	76 cc                	jbe    f0102ea2 <vprintfmt+0x1dd>
					putch('?', putdat);
f0102ed6:	83 ec 08             	sub    $0x8,%esp
f0102ed9:	ff 75 0c             	pushl  0xc(%ebp)
f0102edc:	6a 3f                	push   $0x3f
f0102ede:	ff d6                	call   *%esi
f0102ee0:	83 c4 10             	add    $0x10,%esp
f0102ee3:	eb c9                	jmp    f0102eae <vprintfmt+0x1e9>
f0102ee5:	b8 00 00 00 00       	mov    $0x0,%eax
f0102eea:	eb a0                	jmp    f0102e8c <vprintfmt+0x1c7>
f0102eec:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102eef:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102ef2:	eb bd                	jmp    f0102eb1 <vprintfmt+0x1ec>
				putch(' ', putdat);
f0102ef4:	83 ec 08             	sub    $0x8,%esp
f0102ef7:	53                   	push   %ebx
f0102ef8:	6a 20                	push   $0x20
f0102efa:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0102efc:	4f                   	dec    %edi
f0102efd:	83 c4 10             	add    $0x10,%esp
f0102f00:	85 ff                	test   %edi,%edi
f0102f02:	7f f0                	jg     f0102ef4 <vprintfmt+0x22f>
			if ((p = va_arg(ap, char *)) == NULL)
f0102f04:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102f07:	89 45 14             	mov    %eax,0x14(%ebp)
f0102f0a:	e9 76 01 00 00       	jmp    f0103085 <vprintfmt+0x3c0>
f0102f0f:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0102f12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102f15:	eb e9                	jmp    f0102f00 <vprintfmt+0x23b>
	if (lflag >= 2)
f0102f17:	83 f9 01             	cmp    $0x1,%ecx
f0102f1a:	7e 3f                	jle    f0102f5b <vprintfmt+0x296>
		return va_arg(*ap, long long);
f0102f1c:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f1f:	8b 50 04             	mov    0x4(%eax),%edx
f0102f22:	8b 00                	mov    (%eax),%eax
f0102f24:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102f27:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102f2a:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f2d:	8d 40 08             	lea    0x8(%eax),%eax
f0102f30:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0102f33:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0102f37:	79 5c                	jns    f0102f95 <vprintfmt+0x2d0>
				putch('-', putdat);
f0102f39:	83 ec 08             	sub    $0x8,%esp
f0102f3c:	53                   	push   %ebx
f0102f3d:	6a 2d                	push   $0x2d
f0102f3f:	ff d6                	call   *%esi
				num = -(long long) num;
f0102f41:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102f44:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0102f47:	f7 da                	neg    %edx
f0102f49:	83 d1 00             	adc    $0x0,%ecx
f0102f4c:	f7 d9                	neg    %ecx
f0102f4e:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0102f51:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102f56:	e9 10 01 00 00       	jmp    f010306b <vprintfmt+0x3a6>
	else if (lflag)
f0102f5b:	85 c9                	test   %ecx,%ecx
f0102f5d:	75 1b                	jne    f0102f7a <vprintfmt+0x2b5>
		return va_arg(*ap, int);
f0102f5f:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f62:	8b 00                	mov    (%eax),%eax
f0102f64:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102f67:	89 c1                	mov    %eax,%ecx
f0102f69:	c1 f9 1f             	sar    $0x1f,%ecx
f0102f6c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0102f6f:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f72:	8d 40 04             	lea    0x4(%eax),%eax
f0102f75:	89 45 14             	mov    %eax,0x14(%ebp)
f0102f78:	eb b9                	jmp    f0102f33 <vprintfmt+0x26e>
		return va_arg(*ap, long);
f0102f7a:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f7d:	8b 00                	mov    (%eax),%eax
f0102f7f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102f82:	89 c1                	mov    %eax,%ecx
f0102f84:	c1 f9 1f             	sar    $0x1f,%ecx
f0102f87:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0102f8a:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f8d:	8d 40 04             	lea    0x4(%eax),%eax
f0102f90:	89 45 14             	mov    %eax,0x14(%ebp)
f0102f93:	eb 9e                	jmp    f0102f33 <vprintfmt+0x26e>
			num = getint(&ap, lflag);
f0102f95:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102f98:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0102f9b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102fa0:	e9 c6 00 00 00       	jmp    f010306b <vprintfmt+0x3a6>
	if (lflag >= 2)
f0102fa5:	83 f9 01             	cmp    $0x1,%ecx
f0102fa8:	7e 18                	jle    f0102fc2 <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
f0102faa:	8b 45 14             	mov    0x14(%ebp),%eax
f0102fad:	8b 10                	mov    (%eax),%edx
f0102faf:	8b 48 04             	mov    0x4(%eax),%ecx
f0102fb2:	8d 40 08             	lea    0x8(%eax),%eax
f0102fb5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0102fb8:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102fbd:	e9 a9 00 00 00       	jmp    f010306b <vprintfmt+0x3a6>
	else if (lflag)
f0102fc2:	85 c9                	test   %ecx,%ecx
f0102fc4:	75 1a                	jne    f0102fe0 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned int);
f0102fc6:	8b 45 14             	mov    0x14(%ebp),%eax
f0102fc9:	8b 10                	mov    (%eax),%edx
f0102fcb:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102fd0:	8d 40 04             	lea    0x4(%eax),%eax
f0102fd3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0102fd6:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102fdb:	e9 8b 00 00 00       	jmp    f010306b <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0102fe0:	8b 45 14             	mov    0x14(%ebp),%eax
f0102fe3:	8b 10                	mov    (%eax),%edx
f0102fe5:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102fea:	8d 40 04             	lea    0x4(%eax),%eax
f0102fed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0102ff0:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102ff5:	eb 74                	jmp    f010306b <vprintfmt+0x3a6>
	if (lflag >= 2)
f0102ff7:	83 f9 01             	cmp    $0x1,%ecx
f0102ffa:	7e 15                	jle    f0103011 <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
f0102ffc:	8b 45 14             	mov    0x14(%ebp),%eax
f0102fff:	8b 10                	mov    (%eax),%edx
f0103001:	8b 48 04             	mov    0x4(%eax),%ecx
f0103004:	8d 40 08             	lea    0x8(%eax),%eax
f0103007:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010300a:	b8 08 00 00 00       	mov    $0x8,%eax
f010300f:	eb 5a                	jmp    f010306b <vprintfmt+0x3a6>
	else if (lflag)
f0103011:	85 c9                	test   %ecx,%ecx
f0103013:	75 17                	jne    f010302c <vprintfmt+0x367>
		return va_arg(*ap, unsigned int);
f0103015:	8b 45 14             	mov    0x14(%ebp),%eax
f0103018:	8b 10                	mov    (%eax),%edx
f010301a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010301f:	8d 40 04             	lea    0x4(%eax),%eax
f0103022:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0103025:	b8 08 00 00 00       	mov    $0x8,%eax
f010302a:	eb 3f                	jmp    f010306b <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f010302c:	8b 45 14             	mov    0x14(%ebp),%eax
f010302f:	8b 10                	mov    (%eax),%edx
f0103031:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103036:	8d 40 04             	lea    0x4(%eax),%eax
f0103039:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010303c:	b8 08 00 00 00       	mov    $0x8,%eax
f0103041:	eb 28                	jmp    f010306b <vprintfmt+0x3a6>
			putch('0', putdat);
f0103043:	83 ec 08             	sub    $0x8,%esp
f0103046:	53                   	push   %ebx
f0103047:	6a 30                	push   $0x30
f0103049:	ff d6                	call   *%esi
			putch('x', putdat);
f010304b:	83 c4 08             	add    $0x8,%esp
f010304e:	53                   	push   %ebx
f010304f:	6a 78                	push   $0x78
f0103051:	ff d6                	call   *%esi
			num = (unsigned long long)
f0103053:	8b 45 14             	mov    0x14(%ebp),%eax
f0103056:	8b 10                	mov    (%eax),%edx
f0103058:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010305d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0103060:	8d 40 04             	lea    0x4(%eax),%eax
f0103063:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103066:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f010306b:	83 ec 0c             	sub    $0xc,%esp
f010306e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0103072:	57                   	push   %edi
f0103073:	ff 75 e0             	pushl  -0x20(%ebp)
f0103076:	50                   	push   %eax
f0103077:	51                   	push   %ecx
f0103078:	52                   	push   %edx
f0103079:	89 da                	mov    %ebx,%edx
f010307b:	89 f0                	mov    %esi,%eax
f010307d:	e8 5d fb ff ff       	call   f0102bdf <printnum>
			break;
f0103082:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0103085:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103088:	47                   	inc    %edi
f0103089:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010308d:	83 f8 25             	cmp    $0x25,%eax
f0103090:	0f 84 46 fc ff ff    	je     f0102cdc <vprintfmt+0x17>
			if (ch == '\0')
f0103096:	85 c0                	test   %eax,%eax
f0103098:	0f 84 89 00 00 00    	je     f0103127 <vprintfmt+0x462>
			putch(ch, putdat);
f010309e:	83 ec 08             	sub    $0x8,%esp
f01030a1:	53                   	push   %ebx
f01030a2:	50                   	push   %eax
f01030a3:	ff d6                	call   *%esi
f01030a5:	83 c4 10             	add    $0x10,%esp
f01030a8:	eb de                	jmp    f0103088 <vprintfmt+0x3c3>
	if (lflag >= 2)
f01030aa:	83 f9 01             	cmp    $0x1,%ecx
f01030ad:	7e 15                	jle    f01030c4 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
f01030af:	8b 45 14             	mov    0x14(%ebp),%eax
f01030b2:	8b 10                	mov    (%eax),%edx
f01030b4:	8b 48 04             	mov    0x4(%eax),%ecx
f01030b7:	8d 40 08             	lea    0x8(%eax),%eax
f01030ba:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01030bd:	b8 10 00 00 00       	mov    $0x10,%eax
f01030c2:	eb a7                	jmp    f010306b <vprintfmt+0x3a6>
	else if (lflag)
f01030c4:	85 c9                	test   %ecx,%ecx
f01030c6:	75 17                	jne    f01030df <vprintfmt+0x41a>
		return va_arg(*ap, unsigned int);
f01030c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01030cb:	8b 10                	mov    (%eax),%edx
f01030cd:	b9 00 00 00 00       	mov    $0x0,%ecx
f01030d2:	8d 40 04             	lea    0x4(%eax),%eax
f01030d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01030d8:	b8 10 00 00 00       	mov    $0x10,%eax
f01030dd:	eb 8c                	jmp    f010306b <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f01030df:	8b 45 14             	mov    0x14(%ebp),%eax
f01030e2:	8b 10                	mov    (%eax),%edx
f01030e4:	b9 00 00 00 00       	mov    $0x0,%ecx
f01030e9:	8d 40 04             	lea    0x4(%eax),%eax
f01030ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01030ef:	b8 10 00 00 00       	mov    $0x10,%eax
f01030f4:	e9 72 ff ff ff       	jmp    f010306b <vprintfmt+0x3a6>
			putch(ch, putdat);
f01030f9:	83 ec 08             	sub    $0x8,%esp
f01030fc:	53                   	push   %ebx
f01030fd:	6a 25                	push   $0x25
f01030ff:	ff d6                	call   *%esi
			break;
f0103101:	83 c4 10             	add    $0x10,%esp
f0103104:	e9 7c ff ff ff       	jmp    f0103085 <vprintfmt+0x3c0>
			putch('%', putdat);
f0103109:	83 ec 08             	sub    $0x8,%esp
f010310c:	53                   	push   %ebx
f010310d:	6a 25                	push   $0x25
f010310f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103111:	83 c4 10             	add    $0x10,%esp
f0103114:	89 f8                	mov    %edi,%eax
f0103116:	eb 01                	jmp    f0103119 <vprintfmt+0x454>
f0103118:	48                   	dec    %eax
f0103119:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010311d:	75 f9                	jne    f0103118 <vprintfmt+0x453>
f010311f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103122:	e9 5e ff ff ff       	jmp    f0103085 <vprintfmt+0x3c0>
}
f0103127:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010312a:	5b                   	pop    %ebx
f010312b:	5e                   	pop    %esi
f010312c:	5f                   	pop    %edi
f010312d:	5d                   	pop    %ebp
f010312e:	c3                   	ret    

f010312f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010312f:	55                   	push   %ebp
f0103130:	89 e5                	mov    %esp,%ebp
f0103132:	83 ec 18             	sub    $0x18,%esp
f0103135:	8b 45 08             	mov    0x8(%ebp),%eax
f0103138:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010313b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010313e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103142:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103145:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010314c:	85 c0                	test   %eax,%eax
f010314e:	74 26                	je     f0103176 <vsnprintf+0x47>
f0103150:	85 d2                	test   %edx,%edx
f0103152:	7e 29                	jle    f010317d <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103154:	ff 75 14             	pushl  0x14(%ebp)
f0103157:	ff 75 10             	pushl  0x10(%ebp)
f010315a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010315d:	50                   	push   %eax
f010315e:	68 8c 2c 10 f0       	push   $0xf0102c8c
f0103163:	e8 5d fb ff ff       	call   f0102cc5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103168:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010316b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010316e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103171:	83 c4 10             	add    $0x10,%esp
}
f0103174:	c9                   	leave  
f0103175:	c3                   	ret    
		return -E_INVAL;
f0103176:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010317b:	eb f7                	jmp    f0103174 <vsnprintf+0x45>
f010317d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103182:	eb f0                	jmp    f0103174 <vsnprintf+0x45>

f0103184 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103184:	55                   	push   %ebp
f0103185:	89 e5                	mov    %esp,%ebp
f0103187:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010318a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010318d:	50                   	push   %eax
f010318e:	ff 75 10             	pushl  0x10(%ebp)
f0103191:	ff 75 0c             	pushl  0xc(%ebp)
f0103194:	ff 75 08             	pushl  0x8(%ebp)
f0103197:	e8 93 ff ff ff       	call   f010312f <vsnprintf>
	va_end(ap);

	return rc;
}
f010319c:	c9                   	leave  
f010319d:	c3                   	ret    

f010319e <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010319e:	55                   	push   %ebp
f010319f:	89 e5                	mov    %esp,%ebp
f01031a1:	57                   	push   %edi
f01031a2:	56                   	push   %esi
f01031a3:	53                   	push   %ebx
f01031a4:	83 ec 0c             	sub    $0xc,%esp
f01031a7:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01031aa:	85 c0                	test   %eax,%eax
f01031ac:	74 11                	je     f01031bf <readline+0x21>
		cprintf("%s", prompt);
f01031ae:	83 ec 08             	sub    $0x8,%esp
f01031b1:	50                   	push   %eax
f01031b2:	68 b8 45 10 f0       	push   $0xf01045b8
f01031b7:	e8 f3 f6 ff ff       	call   f01028af <cprintf>
f01031bc:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01031bf:	83 ec 0c             	sub    $0xc,%esp
f01031c2:	6a 00                	push   $0x0
f01031c4:	e8 de d4 ff ff       	call   f01006a7 <iscons>
f01031c9:	89 c7                	mov    %eax,%edi
f01031cb:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01031ce:	be 00 00 00 00       	mov    $0x0,%esi
f01031d3:	eb 6f                	jmp    f0103244 <readline+0xa6>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01031d5:	83 ec 08             	sub    $0x8,%esp
f01031d8:	50                   	push   %eax
f01031d9:	68 b4 4a 10 f0       	push   $0xf0104ab4
f01031de:	e8 cc f6 ff ff       	call   f01028af <cprintf>
			return NULL;
f01031e3:	83 c4 10             	add    $0x10,%esp
f01031e6:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01031eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01031ee:	5b                   	pop    %ebx
f01031ef:	5e                   	pop    %esi
f01031f0:	5f                   	pop    %edi
f01031f1:	5d                   	pop    %ebp
f01031f2:	c3                   	ret    
				cputchar('\b');
f01031f3:	83 ec 0c             	sub    $0xc,%esp
f01031f6:	6a 08                	push   $0x8
f01031f8:	e8 89 d4 ff ff       	call   f0100686 <cputchar>
f01031fd:	83 c4 10             	add    $0x10,%esp
f0103200:	eb 41                	jmp    f0103243 <readline+0xa5>
				cputchar(c);
f0103202:	83 ec 0c             	sub    $0xc,%esp
f0103205:	53                   	push   %ebx
f0103206:	e8 7b d4 ff ff       	call   f0100686 <cputchar>
f010320b:	83 c4 10             	add    $0x10,%esp
f010320e:	eb 5a                	jmp    f010326a <readline+0xcc>
		} else if (c == '\n' || c == '\r') {
f0103210:	83 fb 0a             	cmp    $0xa,%ebx
f0103213:	74 05                	je     f010321a <readline+0x7c>
f0103215:	83 fb 0d             	cmp    $0xd,%ebx
f0103218:	75 2a                	jne    f0103244 <readline+0xa6>
			if (echoing)
f010321a:	85 ff                	test   %edi,%edi
f010321c:	75 0e                	jne    f010322c <readline+0x8e>
			buf[i] = 0;
f010321e:	c6 86 60 75 11 f0 00 	movb   $0x0,-0xfee8aa0(%esi)
			return buf;
f0103225:	b8 60 75 11 f0       	mov    $0xf0117560,%eax
f010322a:	eb bf                	jmp    f01031eb <readline+0x4d>
				cputchar('\n');
f010322c:	83 ec 0c             	sub    $0xc,%esp
f010322f:	6a 0a                	push   $0xa
f0103231:	e8 50 d4 ff ff       	call   f0100686 <cputchar>
f0103236:	83 c4 10             	add    $0x10,%esp
f0103239:	eb e3                	jmp    f010321e <readline+0x80>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010323b:	85 f6                	test   %esi,%esi
f010323d:	7e 3c                	jle    f010327b <readline+0xdd>
			if (echoing)
f010323f:	85 ff                	test   %edi,%edi
f0103241:	75 b0                	jne    f01031f3 <readline+0x55>
			i--;
f0103243:	4e                   	dec    %esi
		c = getchar();
f0103244:	e8 4d d4 ff ff       	call   f0100696 <getchar>
f0103249:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010324b:	85 c0                	test   %eax,%eax
f010324d:	78 86                	js     f01031d5 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010324f:	83 f8 08             	cmp    $0x8,%eax
f0103252:	74 21                	je     f0103275 <readline+0xd7>
f0103254:	83 f8 7f             	cmp    $0x7f,%eax
f0103257:	74 e2                	je     f010323b <readline+0x9d>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103259:	83 f8 1f             	cmp    $0x1f,%eax
f010325c:	7e b2                	jle    f0103210 <readline+0x72>
f010325e:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103264:	7f aa                	jg     f0103210 <readline+0x72>
			if (echoing)
f0103266:	85 ff                	test   %edi,%edi
f0103268:	75 98                	jne    f0103202 <readline+0x64>
			buf[i++] = c;
f010326a:	88 9e 60 75 11 f0    	mov    %bl,-0xfee8aa0(%esi)
f0103270:	8d 76 01             	lea    0x1(%esi),%esi
f0103273:	eb cf                	jmp    f0103244 <readline+0xa6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103275:	85 f6                	test   %esi,%esi
f0103277:	7e cb                	jle    f0103244 <readline+0xa6>
f0103279:	eb c4                	jmp    f010323f <readline+0xa1>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010327b:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103281:	7e e3                	jle    f0103266 <readline+0xc8>
f0103283:	eb bf                	jmp    f0103244 <readline+0xa6>

f0103285 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103285:	55                   	push   %ebp
f0103286:	89 e5                	mov    %esp,%ebp
f0103288:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010328b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103290:	eb 01                	jmp    f0103293 <strlen+0xe>
		n++;
f0103292:	40                   	inc    %eax
	for (n = 0; *s != '\0'; s++)
f0103293:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103297:	75 f9                	jne    f0103292 <strlen+0xd>
	return n;
}
f0103299:	5d                   	pop    %ebp
f010329a:	c3                   	ret    

f010329b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010329b:	55                   	push   %ebp
f010329c:	89 e5                	mov    %esp,%ebp
f010329e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01032a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01032a4:	b8 00 00 00 00       	mov    $0x0,%eax
f01032a9:	eb 01                	jmp    f01032ac <strnlen+0x11>
		n++;
f01032ab:	40                   	inc    %eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01032ac:	39 d0                	cmp    %edx,%eax
f01032ae:	74 06                	je     f01032b6 <strnlen+0x1b>
f01032b0:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01032b4:	75 f5                	jne    f01032ab <strnlen+0x10>
	return n;
}
f01032b6:	5d                   	pop    %ebp
f01032b7:	c3                   	ret    

f01032b8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01032b8:	55                   	push   %ebp
f01032b9:	89 e5                	mov    %esp,%ebp
f01032bb:	53                   	push   %ebx
f01032bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01032bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01032c2:	89 c2                	mov    %eax,%edx
f01032c4:	41                   	inc    %ecx
f01032c5:	42                   	inc    %edx
f01032c6:	8a 59 ff             	mov    -0x1(%ecx),%bl
f01032c9:	88 5a ff             	mov    %bl,-0x1(%edx)
f01032cc:	84 db                	test   %bl,%bl
f01032ce:	75 f4                	jne    f01032c4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01032d0:	5b                   	pop    %ebx
f01032d1:	5d                   	pop    %ebp
f01032d2:	c3                   	ret    

f01032d3 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01032d3:	55                   	push   %ebp
f01032d4:	89 e5                	mov    %esp,%ebp
f01032d6:	53                   	push   %ebx
f01032d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01032da:	53                   	push   %ebx
f01032db:	e8 a5 ff ff ff       	call   f0103285 <strlen>
f01032e0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01032e3:	ff 75 0c             	pushl  0xc(%ebp)
f01032e6:	01 d8                	add    %ebx,%eax
f01032e8:	50                   	push   %eax
f01032e9:	e8 ca ff ff ff       	call   f01032b8 <strcpy>
	return dst;
}
f01032ee:	89 d8                	mov    %ebx,%eax
f01032f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01032f3:	c9                   	leave  
f01032f4:	c3                   	ret    

f01032f5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01032f5:	55                   	push   %ebp
f01032f6:	89 e5                	mov    %esp,%ebp
f01032f8:	56                   	push   %esi
f01032f9:	53                   	push   %ebx
f01032fa:	8b 75 08             	mov    0x8(%ebp),%esi
f01032fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103300:	89 f3                	mov    %esi,%ebx
f0103302:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103305:	89 f2                	mov    %esi,%edx
f0103307:	39 da                	cmp    %ebx,%edx
f0103309:	74 0e                	je     f0103319 <strncpy+0x24>
		*dst++ = *src;
f010330b:	42                   	inc    %edx
f010330c:	8a 01                	mov    (%ecx),%al
f010330e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f0103311:	80 39 00             	cmpb   $0x0,(%ecx)
f0103314:	74 f1                	je     f0103307 <strncpy+0x12>
			src++;
f0103316:	41                   	inc    %ecx
f0103317:	eb ee                	jmp    f0103307 <strncpy+0x12>
	}
	return ret;
}
f0103319:	89 f0                	mov    %esi,%eax
f010331b:	5b                   	pop    %ebx
f010331c:	5e                   	pop    %esi
f010331d:	5d                   	pop    %ebp
f010331e:	c3                   	ret    

f010331f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010331f:	55                   	push   %ebp
f0103320:	89 e5                	mov    %esp,%ebp
f0103322:	56                   	push   %esi
f0103323:	53                   	push   %ebx
f0103324:	8b 75 08             	mov    0x8(%ebp),%esi
f0103327:	8b 55 0c             	mov    0xc(%ebp),%edx
f010332a:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010332d:	85 c0                	test   %eax,%eax
f010332f:	74 20                	je     f0103351 <strlcpy+0x32>
f0103331:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
f0103335:	89 f0                	mov    %esi,%eax
f0103337:	eb 05                	jmp    f010333e <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103339:	42                   	inc    %edx
f010333a:	40                   	inc    %eax
f010333b:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f010333e:	39 d8                	cmp    %ebx,%eax
f0103340:	74 06                	je     f0103348 <strlcpy+0x29>
f0103342:	8a 0a                	mov    (%edx),%cl
f0103344:	84 c9                	test   %cl,%cl
f0103346:	75 f1                	jne    f0103339 <strlcpy+0x1a>
		*dst = '\0';
f0103348:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010334b:	29 f0                	sub    %esi,%eax
}
f010334d:	5b                   	pop    %ebx
f010334e:	5e                   	pop    %esi
f010334f:	5d                   	pop    %ebp
f0103350:	c3                   	ret    
f0103351:	89 f0                	mov    %esi,%eax
f0103353:	eb f6                	jmp    f010334b <strlcpy+0x2c>

f0103355 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103355:	55                   	push   %ebp
f0103356:	89 e5                	mov    %esp,%ebp
f0103358:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010335b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010335e:	eb 02                	jmp    f0103362 <strcmp+0xd>
		p++, q++;
f0103360:	41                   	inc    %ecx
f0103361:	42                   	inc    %edx
	while (*p && *p == *q)
f0103362:	8a 01                	mov    (%ecx),%al
f0103364:	84 c0                	test   %al,%al
f0103366:	74 04                	je     f010336c <strcmp+0x17>
f0103368:	3a 02                	cmp    (%edx),%al
f010336a:	74 f4                	je     f0103360 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010336c:	0f b6 c0             	movzbl %al,%eax
f010336f:	0f b6 12             	movzbl (%edx),%edx
f0103372:	29 d0                	sub    %edx,%eax
}
f0103374:	5d                   	pop    %ebp
f0103375:	c3                   	ret    

f0103376 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103376:	55                   	push   %ebp
f0103377:	89 e5                	mov    %esp,%ebp
f0103379:	53                   	push   %ebx
f010337a:	8b 45 08             	mov    0x8(%ebp),%eax
f010337d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103380:	89 c3                	mov    %eax,%ebx
f0103382:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103385:	eb 02                	jmp    f0103389 <strncmp+0x13>
		n--, p++, q++;
f0103387:	40                   	inc    %eax
f0103388:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
f0103389:	39 d8                	cmp    %ebx,%eax
f010338b:	74 15                	je     f01033a2 <strncmp+0x2c>
f010338d:	8a 08                	mov    (%eax),%cl
f010338f:	84 c9                	test   %cl,%cl
f0103391:	74 04                	je     f0103397 <strncmp+0x21>
f0103393:	3a 0a                	cmp    (%edx),%cl
f0103395:	74 f0                	je     f0103387 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103397:	0f b6 00             	movzbl (%eax),%eax
f010339a:	0f b6 12             	movzbl (%edx),%edx
f010339d:	29 d0                	sub    %edx,%eax
}
f010339f:	5b                   	pop    %ebx
f01033a0:	5d                   	pop    %ebp
f01033a1:	c3                   	ret    
		return 0;
f01033a2:	b8 00 00 00 00       	mov    $0x0,%eax
f01033a7:	eb f6                	jmp    f010339f <strncmp+0x29>

f01033a9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01033a9:	55                   	push   %ebp
f01033aa:	89 e5                	mov    %esp,%ebp
f01033ac:	8b 45 08             	mov    0x8(%ebp),%eax
f01033af:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01033b2:	8a 10                	mov    (%eax),%dl
f01033b4:	84 d2                	test   %dl,%dl
f01033b6:	74 07                	je     f01033bf <strchr+0x16>
		if (*s == c)
f01033b8:	38 ca                	cmp    %cl,%dl
f01033ba:	74 08                	je     f01033c4 <strchr+0x1b>
	for (; *s; s++)
f01033bc:	40                   	inc    %eax
f01033bd:	eb f3                	jmp    f01033b2 <strchr+0x9>
			return (char *) s;
	return 0;
f01033bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01033c4:	5d                   	pop    %ebp
f01033c5:	c3                   	ret    

f01033c6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01033c6:	55                   	push   %ebp
f01033c7:	89 e5                	mov    %esp,%ebp
f01033c9:	8b 45 08             	mov    0x8(%ebp),%eax
f01033cc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01033cf:	8a 10                	mov    (%eax),%dl
f01033d1:	84 d2                	test   %dl,%dl
f01033d3:	74 07                	je     f01033dc <strfind+0x16>
		if (*s == c)
f01033d5:	38 ca                	cmp    %cl,%dl
f01033d7:	74 03                	je     f01033dc <strfind+0x16>
	for (; *s; s++)
f01033d9:	40                   	inc    %eax
f01033da:	eb f3                	jmp    f01033cf <strfind+0x9>
			break;
	return (char *) s;
}
f01033dc:	5d                   	pop    %ebp
f01033dd:	c3                   	ret    

f01033de <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01033de:	55                   	push   %ebp
f01033df:	89 e5                	mov    %esp,%ebp
f01033e1:	57                   	push   %edi
f01033e2:	56                   	push   %esi
f01033e3:	53                   	push   %ebx
f01033e4:	8b 7d 08             	mov    0x8(%ebp),%edi
f01033e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01033ea:	85 c9                	test   %ecx,%ecx
f01033ec:	74 13                	je     f0103401 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01033ee:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01033f4:	75 05                	jne    f01033fb <memset+0x1d>
f01033f6:	f6 c1 03             	test   $0x3,%cl
f01033f9:	74 0d                	je     f0103408 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01033fb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01033fe:	fc                   	cld    
f01033ff:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103401:	89 f8                	mov    %edi,%eax
f0103403:	5b                   	pop    %ebx
f0103404:	5e                   	pop    %esi
f0103405:	5f                   	pop    %edi
f0103406:	5d                   	pop    %ebp
f0103407:	c3                   	ret    
		c &= 0xFF;
f0103408:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010340c:	89 d3                	mov    %edx,%ebx
f010340e:	c1 e3 08             	shl    $0x8,%ebx
f0103411:	89 d0                	mov    %edx,%eax
f0103413:	c1 e0 18             	shl    $0x18,%eax
f0103416:	89 d6                	mov    %edx,%esi
f0103418:	c1 e6 10             	shl    $0x10,%esi
f010341b:	09 f0                	or     %esi,%eax
f010341d:	09 c2                	or     %eax,%edx
f010341f:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0103421:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0103424:	89 d0                	mov    %edx,%eax
f0103426:	fc                   	cld    
f0103427:	f3 ab                	rep stos %eax,%es:(%edi)
f0103429:	eb d6                	jmp    f0103401 <memset+0x23>

f010342b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010342b:	55                   	push   %ebp
f010342c:	89 e5                	mov    %esp,%ebp
f010342e:	57                   	push   %edi
f010342f:	56                   	push   %esi
f0103430:	8b 45 08             	mov    0x8(%ebp),%eax
f0103433:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103436:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103439:	39 c6                	cmp    %eax,%esi
f010343b:	73 33                	jae    f0103470 <memmove+0x45>
f010343d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103440:	39 c2                	cmp    %eax,%edx
f0103442:	76 2c                	jbe    f0103470 <memmove+0x45>
		s += n;
		d += n;
f0103444:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103447:	89 d6                	mov    %edx,%esi
f0103449:	09 fe                	or     %edi,%esi
f010344b:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103451:	74 0a                	je     f010345d <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0103453:	4f                   	dec    %edi
f0103454:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0103457:	fd                   	std    
f0103458:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010345a:	fc                   	cld    
f010345b:	eb 21                	jmp    f010347e <memmove+0x53>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010345d:	f6 c1 03             	test   $0x3,%cl
f0103460:	75 f1                	jne    f0103453 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103462:	83 ef 04             	sub    $0x4,%edi
f0103465:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103468:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f010346b:	fd                   	std    
f010346c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010346e:	eb ea                	jmp    f010345a <memmove+0x2f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103470:	89 f2                	mov    %esi,%edx
f0103472:	09 c2                	or     %eax,%edx
f0103474:	f6 c2 03             	test   $0x3,%dl
f0103477:	74 09                	je     f0103482 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103479:	89 c7                	mov    %eax,%edi
f010347b:	fc                   	cld    
f010347c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010347e:	5e                   	pop    %esi
f010347f:	5f                   	pop    %edi
f0103480:	5d                   	pop    %ebp
f0103481:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103482:	f6 c1 03             	test   $0x3,%cl
f0103485:	75 f2                	jne    f0103479 <memmove+0x4e>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103487:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f010348a:	89 c7                	mov    %eax,%edi
f010348c:	fc                   	cld    
f010348d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010348f:	eb ed                	jmp    f010347e <memmove+0x53>

f0103491 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103491:	55                   	push   %ebp
f0103492:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0103494:	ff 75 10             	pushl  0x10(%ebp)
f0103497:	ff 75 0c             	pushl  0xc(%ebp)
f010349a:	ff 75 08             	pushl  0x8(%ebp)
f010349d:	e8 89 ff ff ff       	call   f010342b <memmove>
}
f01034a2:	c9                   	leave  
f01034a3:	c3                   	ret    

f01034a4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01034a4:	55                   	push   %ebp
f01034a5:	89 e5                	mov    %esp,%ebp
f01034a7:	56                   	push   %esi
f01034a8:	53                   	push   %ebx
f01034a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01034ac:	8b 55 0c             	mov    0xc(%ebp),%edx
f01034af:	89 c6                	mov    %eax,%esi
f01034b1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01034b4:	39 f0                	cmp    %esi,%eax
f01034b6:	74 16                	je     f01034ce <memcmp+0x2a>
		if (*s1 != *s2)
f01034b8:	8a 08                	mov    (%eax),%cl
f01034ba:	8a 1a                	mov    (%edx),%bl
f01034bc:	38 d9                	cmp    %bl,%cl
f01034be:	75 04                	jne    f01034c4 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01034c0:	40                   	inc    %eax
f01034c1:	42                   	inc    %edx
f01034c2:	eb f0                	jmp    f01034b4 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f01034c4:	0f b6 c1             	movzbl %cl,%eax
f01034c7:	0f b6 db             	movzbl %bl,%ebx
f01034ca:	29 d8                	sub    %ebx,%eax
f01034cc:	eb 05                	jmp    f01034d3 <memcmp+0x2f>
	}

	return 0;
f01034ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01034d3:	5b                   	pop    %ebx
f01034d4:	5e                   	pop    %esi
f01034d5:	5d                   	pop    %ebp
f01034d6:	c3                   	ret    

f01034d7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01034d7:	55                   	push   %ebp
f01034d8:	89 e5                	mov    %esp,%ebp
f01034da:	8b 45 08             	mov    0x8(%ebp),%eax
f01034dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01034e0:	89 c2                	mov    %eax,%edx
f01034e2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01034e5:	39 d0                	cmp    %edx,%eax
f01034e7:	73 07                	jae    f01034f0 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
f01034e9:	38 08                	cmp    %cl,(%eax)
f01034eb:	74 03                	je     f01034f0 <memfind+0x19>
	for (; s < ends; s++)
f01034ed:	40                   	inc    %eax
f01034ee:	eb f5                	jmp    f01034e5 <memfind+0xe>
			break;
	return (void *) s;
}
f01034f0:	5d                   	pop    %ebp
f01034f1:	c3                   	ret    

f01034f2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01034f2:	55                   	push   %ebp
f01034f3:	89 e5                	mov    %esp,%ebp
f01034f5:	57                   	push   %edi
f01034f6:	56                   	push   %esi
f01034f7:	53                   	push   %ebx
f01034f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01034fb:	eb 01                	jmp    f01034fe <strtol+0xc>
		s++;
f01034fd:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f01034fe:	8a 01                	mov    (%ecx),%al
f0103500:	3c 20                	cmp    $0x20,%al
f0103502:	74 f9                	je     f01034fd <strtol+0xb>
f0103504:	3c 09                	cmp    $0x9,%al
f0103506:	74 f5                	je     f01034fd <strtol+0xb>

	// plus/minus sign
	if (*s == '+')
f0103508:	3c 2b                	cmp    $0x2b,%al
f010350a:	74 2b                	je     f0103537 <strtol+0x45>
		s++;
	else if (*s == '-')
f010350c:	3c 2d                	cmp    $0x2d,%al
f010350e:	74 2f                	je     f010353f <strtol+0x4d>
	int neg = 0;
f0103510:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103515:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f010351c:	75 12                	jne    f0103530 <strtol+0x3e>
f010351e:	80 39 30             	cmpb   $0x30,(%ecx)
f0103521:	74 24                	je     f0103547 <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103523:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0103527:	75 07                	jne    f0103530 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103529:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f0103530:	b8 00 00 00 00       	mov    $0x0,%eax
f0103535:	eb 4e                	jmp    f0103585 <strtol+0x93>
		s++;
f0103537:	41                   	inc    %ecx
	int neg = 0;
f0103538:	bf 00 00 00 00       	mov    $0x0,%edi
f010353d:	eb d6                	jmp    f0103515 <strtol+0x23>
		s++, neg = 1;
f010353f:	41                   	inc    %ecx
f0103540:	bf 01 00 00 00       	mov    $0x1,%edi
f0103545:	eb ce                	jmp    f0103515 <strtol+0x23>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103547:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010354b:	74 10                	je     f010355d <strtol+0x6b>
	else if (base == 0 && s[0] == '0')
f010354d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0103551:	75 dd                	jne    f0103530 <strtol+0x3e>
		s++, base = 8;
f0103553:	41                   	inc    %ecx
f0103554:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f010355b:	eb d3                	jmp    f0103530 <strtol+0x3e>
		s += 2, base = 16;
f010355d:	83 c1 02             	add    $0x2,%ecx
f0103560:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f0103567:	eb c7                	jmp    f0103530 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0103569:	8d 72 9f             	lea    -0x61(%edx),%esi
f010356c:	89 f3                	mov    %esi,%ebx
f010356e:	80 fb 19             	cmp    $0x19,%bl
f0103571:	77 24                	ja     f0103597 <strtol+0xa5>
			dig = *s - 'a' + 10;
f0103573:	0f be d2             	movsbl %dl,%edx
f0103576:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0103579:	3b 55 10             	cmp    0x10(%ebp),%edx
f010357c:	7d 2b                	jge    f01035a9 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
f010357e:	41                   	inc    %ecx
f010357f:	0f af 45 10          	imul   0x10(%ebp),%eax
f0103583:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0103585:	8a 11                	mov    (%ecx),%dl
f0103587:	8d 5a d0             	lea    -0x30(%edx),%ebx
f010358a:	80 fb 09             	cmp    $0x9,%bl
f010358d:	77 da                	ja     f0103569 <strtol+0x77>
			dig = *s - '0';
f010358f:	0f be d2             	movsbl %dl,%edx
f0103592:	83 ea 30             	sub    $0x30,%edx
f0103595:	eb e2                	jmp    f0103579 <strtol+0x87>
		else if (*s >= 'A' && *s <= 'Z')
f0103597:	8d 72 bf             	lea    -0x41(%edx),%esi
f010359a:	89 f3                	mov    %esi,%ebx
f010359c:	80 fb 19             	cmp    $0x19,%bl
f010359f:	77 08                	ja     f01035a9 <strtol+0xb7>
			dig = *s - 'A' + 10;
f01035a1:	0f be d2             	movsbl %dl,%edx
f01035a4:	83 ea 37             	sub    $0x37,%edx
f01035a7:	eb d0                	jmp    f0103579 <strtol+0x87>
		// we don't properly detect overflow!
	}

	if (endptr)
f01035a9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01035ad:	74 05                	je     f01035b4 <strtol+0xc2>
		*endptr = (char *) s;
f01035af:	8b 75 0c             	mov    0xc(%ebp),%esi
f01035b2:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f01035b4:	85 ff                	test   %edi,%edi
f01035b6:	74 02                	je     f01035ba <strtol+0xc8>
f01035b8:	f7 d8                	neg    %eax
}
f01035ba:	5b                   	pop    %ebx
f01035bb:	5e                   	pop    %esi
f01035bc:	5f                   	pop    %edi
f01035bd:	5d                   	pop    %ebp
f01035be:	c3                   	ret    
f01035bf:	90                   	nop

f01035c0 <__udivdi3>:
f01035c0:	55                   	push   %ebp
f01035c1:	57                   	push   %edi
f01035c2:	56                   	push   %esi
f01035c3:	53                   	push   %ebx
f01035c4:	83 ec 1c             	sub    $0x1c,%esp
f01035c7:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01035cb:	8b 74 24 34          	mov    0x34(%esp),%esi
f01035cf:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01035d3:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01035d7:	85 d2                	test   %edx,%edx
f01035d9:	75 2d                	jne    f0103608 <__udivdi3+0x48>
f01035db:	39 f7                	cmp    %esi,%edi
f01035dd:	77 59                	ja     f0103638 <__udivdi3+0x78>
f01035df:	89 f9                	mov    %edi,%ecx
f01035e1:	85 ff                	test   %edi,%edi
f01035e3:	75 0b                	jne    f01035f0 <__udivdi3+0x30>
f01035e5:	b8 01 00 00 00       	mov    $0x1,%eax
f01035ea:	31 d2                	xor    %edx,%edx
f01035ec:	f7 f7                	div    %edi
f01035ee:	89 c1                	mov    %eax,%ecx
f01035f0:	31 d2                	xor    %edx,%edx
f01035f2:	89 f0                	mov    %esi,%eax
f01035f4:	f7 f1                	div    %ecx
f01035f6:	89 c3                	mov    %eax,%ebx
f01035f8:	89 e8                	mov    %ebp,%eax
f01035fa:	f7 f1                	div    %ecx
f01035fc:	89 da                	mov    %ebx,%edx
f01035fe:	83 c4 1c             	add    $0x1c,%esp
f0103601:	5b                   	pop    %ebx
f0103602:	5e                   	pop    %esi
f0103603:	5f                   	pop    %edi
f0103604:	5d                   	pop    %ebp
f0103605:	c3                   	ret    
f0103606:	66 90                	xchg   %ax,%ax
f0103608:	39 f2                	cmp    %esi,%edx
f010360a:	77 1c                	ja     f0103628 <__udivdi3+0x68>
f010360c:	0f bd da             	bsr    %edx,%ebx
f010360f:	83 f3 1f             	xor    $0x1f,%ebx
f0103612:	75 38                	jne    f010364c <__udivdi3+0x8c>
f0103614:	39 f2                	cmp    %esi,%edx
f0103616:	72 08                	jb     f0103620 <__udivdi3+0x60>
f0103618:	39 ef                	cmp    %ebp,%edi
f010361a:	0f 87 98 00 00 00    	ja     f01036b8 <__udivdi3+0xf8>
f0103620:	b8 01 00 00 00       	mov    $0x1,%eax
f0103625:	eb 05                	jmp    f010362c <__udivdi3+0x6c>
f0103627:	90                   	nop
f0103628:	31 db                	xor    %ebx,%ebx
f010362a:	31 c0                	xor    %eax,%eax
f010362c:	89 da                	mov    %ebx,%edx
f010362e:	83 c4 1c             	add    $0x1c,%esp
f0103631:	5b                   	pop    %ebx
f0103632:	5e                   	pop    %esi
f0103633:	5f                   	pop    %edi
f0103634:	5d                   	pop    %ebp
f0103635:	c3                   	ret    
f0103636:	66 90                	xchg   %ax,%ax
f0103638:	89 e8                	mov    %ebp,%eax
f010363a:	89 f2                	mov    %esi,%edx
f010363c:	f7 f7                	div    %edi
f010363e:	31 db                	xor    %ebx,%ebx
f0103640:	89 da                	mov    %ebx,%edx
f0103642:	83 c4 1c             	add    $0x1c,%esp
f0103645:	5b                   	pop    %ebx
f0103646:	5e                   	pop    %esi
f0103647:	5f                   	pop    %edi
f0103648:	5d                   	pop    %ebp
f0103649:	c3                   	ret    
f010364a:	66 90                	xchg   %ax,%ax
f010364c:	b8 20 00 00 00       	mov    $0x20,%eax
f0103651:	29 d8                	sub    %ebx,%eax
f0103653:	88 d9                	mov    %bl,%cl
f0103655:	d3 e2                	shl    %cl,%edx
f0103657:	89 54 24 08          	mov    %edx,0x8(%esp)
f010365b:	89 fa                	mov    %edi,%edx
f010365d:	88 c1                	mov    %al,%cl
f010365f:	d3 ea                	shr    %cl,%edx
f0103661:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0103665:	09 d1                	or     %edx,%ecx
f0103667:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010366b:	88 d9                	mov    %bl,%cl
f010366d:	d3 e7                	shl    %cl,%edi
f010366f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0103673:	89 f7                	mov    %esi,%edi
f0103675:	88 c1                	mov    %al,%cl
f0103677:	d3 ef                	shr    %cl,%edi
f0103679:	88 d9                	mov    %bl,%cl
f010367b:	d3 e6                	shl    %cl,%esi
f010367d:	89 ea                	mov    %ebp,%edx
f010367f:	88 c1                	mov    %al,%cl
f0103681:	d3 ea                	shr    %cl,%edx
f0103683:	09 d6                	or     %edx,%esi
f0103685:	89 f0                	mov    %esi,%eax
f0103687:	89 fa                	mov    %edi,%edx
f0103689:	f7 74 24 08          	divl   0x8(%esp)
f010368d:	89 d7                	mov    %edx,%edi
f010368f:	89 c6                	mov    %eax,%esi
f0103691:	f7 64 24 0c          	mull   0xc(%esp)
f0103695:	39 d7                	cmp    %edx,%edi
f0103697:	72 13                	jb     f01036ac <__udivdi3+0xec>
f0103699:	74 09                	je     f01036a4 <__udivdi3+0xe4>
f010369b:	89 f0                	mov    %esi,%eax
f010369d:	31 db                	xor    %ebx,%ebx
f010369f:	eb 8b                	jmp    f010362c <__udivdi3+0x6c>
f01036a1:	8d 76 00             	lea    0x0(%esi),%esi
f01036a4:	88 d9                	mov    %bl,%cl
f01036a6:	d3 e5                	shl    %cl,%ebp
f01036a8:	39 c5                	cmp    %eax,%ebp
f01036aa:	73 ef                	jae    f010369b <__udivdi3+0xdb>
f01036ac:	8d 46 ff             	lea    -0x1(%esi),%eax
f01036af:	31 db                	xor    %ebx,%ebx
f01036b1:	e9 76 ff ff ff       	jmp    f010362c <__udivdi3+0x6c>
f01036b6:	66 90                	xchg   %ax,%ax
f01036b8:	31 c0                	xor    %eax,%eax
f01036ba:	e9 6d ff ff ff       	jmp    f010362c <__udivdi3+0x6c>
f01036bf:	90                   	nop

f01036c0 <__umoddi3>:
f01036c0:	55                   	push   %ebp
f01036c1:	57                   	push   %edi
f01036c2:	56                   	push   %esi
f01036c3:	53                   	push   %ebx
f01036c4:	83 ec 1c             	sub    $0x1c,%esp
f01036c7:	8b 74 24 30          	mov    0x30(%esp),%esi
f01036cb:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01036cf:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01036d3:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f01036d7:	89 f0                	mov    %esi,%eax
f01036d9:	89 da                	mov    %ebx,%edx
f01036db:	85 ed                	test   %ebp,%ebp
f01036dd:	75 15                	jne    f01036f4 <__umoddi3+0x34>
f01036df:	39 df                	cmp    %ebx,%edi
f01036e1:	76 39                	jbe    f010371c <__umoddi3+0x5c>
f01036e3:	f7 f7                	div    %edi
f01036e5:	89 d0                	mov    %edx,%eax
f01036e7:	31 d2                	xor    %edx,%edx
f01036e9:	83 c4 1c             	add    $0x1c,%esp
f01036ec:	5b                   	pop    %ebx
f01036ed:	5e                   	pop    %esi
f01036ee:	5f                   	pop    %edi
f01036ef:	5d                   	pop    %ebp
f01036f0:	c3                   	ret    
f01036f1:	8d 76 00             	lea    0x0(%esi),%esi
f01036f4:	39 dd                	cmp    %ebx,%ebp
f01036f6:	77 f1                	ja     f01036e9 <__umoddi3+0x29>
f01036f8:	0f bd cd             	bsr    %ebp,%ecx
f01036fb:	83 f1 1f             	xor    $0x1f,%ecx
f01036fe:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103702:	75 38                	jne    f010373c <__umoddi3+0x7c>
f0103704:	39 dd                	cmp    %ebx,%ebp
f0103706:	72 04                	jb     f010370c <__umoddi3+0x4c>
f0103708:	39 f7                	cmp    %esi,%edi
f010370a:	77 dd                	ja     f01036e9 <__umoddi3+0x29>
f010370c:	89 da                	mov    %ebx,%edx
f010370e:	89 f0                	mov    %esi,%eax
f0103710:	29 f8                	sub    %edi,%eax
f0103712:	19 ea                	sbb    %ebp,%edx
f0103714:	83 c4 1c             	add    $0x1c,%esp
f0103717:	5b                   	pop    %ebx
f0103718:	5e                   	pop    %esi
f0103719:	5f                   	pop    %edi
f010371a:	5d                   	pop    %ebp
f010371b:	c3                   	ret    
f010371c:	89 f9                	mov    %edi,%ecx
f010371e:	85 ff                	test   %edi,%edi
f0103720:	75 0b                	jne    f010372d <__umoddi3+0x6d>
f0103722:	b8 01 00 00 00       	mov    $0x1,%eax
f0103727:	31 d2                	xor    %edx,%edx
f0103729:	f7 f7                	div    %edi
f010372b:	89 c1                	mov    %eax,%ecx
f010372d:	89 d8                	mov    %ebx,%eax
f010372f:	31 d2                	xor    %edx,%edx
f0103731:	f7 f1                	div    %ecx
f0103733:	89 f0                	mov    %esi,%eax
f0103735:	f7 f1                	div    %ecx
f0103737:	eb ac                	jmp    f01036e5 <__umoddi3+0x25>
f0103739:	8d 76 00             	lea    0x0(%esi),%esi
f010373c:	b8 20 00 00 00       	mov    $0x20,%eax
f0103741:	89 c2                	mov    %eax,%edx
f0103743:	8b 44 24 04          	mov    0x4(%esp),%eax
f0103747:	29 c2                	sub    %eax,%edx
f0103749:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010374d:	88 c1                	mov    %al,%cl
f010374f:	d3 e5                	shl    %cl,%ebp
f0103751:	89 f8                	mov    %edi,%eax
f0103753:	88 d1                	mov    %dl,%cl
f0103755:	d3 e8                	shr    %cl,%eax
f0103757:	09 c5                	or     %eax,%ebp
f0103759:	8b 44 24 04          	mov    0x4(%esp),%eax
f010375d:	88 c1                	mov    %al,%cl
f010375f:	d3 e7                	shl    %cl,%edi
f0103761:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0103765:	89 df                	mov    %ebx,%edi
f0103767:	88 d1                	mov    %dl,%cl
f0103769:	d3 ef                	shr    %cl,%edi
f010376b:	88 c1                	mov    %al,%cl
f010376d:	d3 e3                	shl    %cl,%ebx
f010376f:	89 f0                	mov    %esi,%eax
f0103771:	88 d1                	mov    %dl,%cl
f0103773:	d3 e8                	shr    %cl,%eax
f0103775:	09 d8                	or     %ebx,%eax
f0103777:	8a 4c 24 04          	mov    0x4(%esp),%cl
f010377b:	d3 e6                	shl    %cl,%esi
f010377d:	89 fa                	mov    %edi,%edx
f010377f:	f7 f5                	div    %ebp
f0103781:	89 d1                	mov    %edx,%ecx
f0103783:	f7 64 24 08          	mull   0x8(%esp)
f0103787:	89 c3                	mov    %eax,%ebx
f0103789:	89 d7                	mov    %edx,%edi
f010378b:	39 d1                	cmp    %edx,%ecx
f010378d:	72 29                	jb     f01037b8 <__umoddi3+0xf8>
f010378f:	74 23                	je     f01037b4 <__umoddi3+0xf4>
f0103791:	89 ca                	mov    %ecx,%edx
f0103793:	29 de                	sub    %ebx,%esi
f0103795:	19 fa                	sbb    %edi,%edx
f0103797:	89 d0                	mov    %edx,%eax
f0103799:	8a 4c 24 0c          	mov    0xc(%esp),%cl
f010379d:	d3 e0                	shl    %cl,%eax
f010379f:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f01037a3:	88 d9                	mov    %bl,%cl
f01037a5:	d3 ee                	shr    %cl,%esi
f01037a7:	09 f0                	or     %esi,%eax
f01037a9:	d3 ea                	shr    %cl,%edx
f01037ab:	83 c4 1c             	add    $0x1c,%esp
f01037ae:	5b                   	pop    %ebx
f01037af:	5e                   	pop    %esi
f01037b0:	5f                   	pop    %edi
f01037b1:	5d                   	pop    %ebp
f01037b2:	c3                   	ret    
f01037b3:	90                   	nop
f01037b4:	39 c6                	cmp    %eax,%esi
f01037b6:	73 d9                	jae    f0103791 <__umoddi3+0xd1>
f01037b8:	2b 44 24 08          	sub    0x8(%esp),%eax
f01037bc:	19 ea                	sbb    %ebp,%edx
f01037be:	89 d7                	mov    %edx,%edi
f01037c0:	89 c3                	mov    %eax,%ebx
f01037c2:	eb cd                	jmp    f0103791 <__umoddi3+0xd1>
