
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
#include <kern/console.h>

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
f0100050:	e8 94 08 00 00       	call   f01008e9 <cprintf>
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
f0100065:	e8 0d 07 00 00       	call   f0100777 <mon_backtrace>
f010006a:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010006d:	83 ec 08             	sub    $0x8,%esp
f0100070:	53                   	push   %ebx
f0100071:	68 fc 17 10 f0       	push   $0xf01017fc
f0100076:	e8 6e 08 00 00       	call   f01008e9 <cprintf>
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
f01000ac:	e8 3c 13 00 00       	call   f01013ed <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 98 04 00 00       	call   f010054e <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 17 18 10 f0       	push   $0xf0101817
f01000c3:	e8 21 08 00 00       	call   f01008e9 <cprintf>

	int x = 1, y = 3, z = 4;
	cprintf("x %d, y %x, z %d\n",  x, y, z);
f01000c8:	6a 04                	push   $0x4
f01000ca:	6a 03                	push   $0x3
f01000cc:	6a 01                	push   $0x1
f01000ce:	68 32 18 10 f0       	push   $0xf0101832
f01000d3:	e8 11 08 00 00       	call   f01008e9 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000d8:	83 c4 14             	add    $0x14,%esp
f01000db:	6a 05                	push   $0x5
f01000dd:	e8 5e ff ff ff       	call   f0100040 <test_backtrace>

	// Drop into the kernel monitor.
	//while (1)
		monitor(NULL);
f01000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000e9:	e8 93 06 00 00       	call   f0100781 <monitor>
}
f01000ee:	83 c4 10             	add    $0x10,%esp
f01000f1:	c9                   	leave  
f01000f2:	c3                   	ret    

f01000f3 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000f3:	55                   	push   %ebp
f01000f4:	89 e5                	mov    %esp,%ebp
f01000f6:	56                   	push   %esi
f01000f7:	53                   	push   %ebx
f01000f8:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000fb:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f0100102:	74 0f                	je     f0100113 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100104:	83 ec 0c             	sub    $0xc,%esp
f0100107:	6a 00                	push   $0x0
f0100109:	e8 73 06 00 00       	call   f0100781 <monitor>
f010010e:	83 c4 10             	add    $0x10,%esp
f0100111:	eb f1                	jmp    f0100104 <_panic+0x11>
	panicstr = fmt;
f0100113:	89 35 40 29 11 f0    	mov    %esi,0xf0112940
	asm volatile("cli; cld");
f0100119:	fa                   	cli    
f010011a:	fc                   	cld    
	va_start(ap, fmt);
f010011b:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f010011e:	83 ec 04             	sub    $0x4,%esp
f0100121:	ff 75 0c             	pushl  0xc(%ebp)
f0100124:	ff 75 08             	pushl  0x8(%ebp)
f0100127:	68 44 18 10 f0       	push   $0xf0101844
f010012c:	e8 b8 07 00 00       	call   f01008e9 <cprintf>
	vcprintf(fmt, ap);
f0100131:	83 c4 08             	add    $0x8,%esp
f0100134:	53                   	push   %ebx
f0100135:	56                   	push   %esi
f0100136:	e8 88 07 00 00       	call   f01008c3 <vcprintf>
	cprintf("\n");
f010013b:	c7 04 24 80 18 10 f0 	movl   $0xf0101880,(%esp)
f0100142:	e8 a2 07 00 00       	call   f01008e9 <cprintf>
f0100147:	83 c4 10             	add    $0x10,%esp
f010014a:	eb b8                	jmp    f0100104 <_panic+0x11>

f010014c <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010014c:	55                   	push   %ebp
f010014d:	89 e5                	mov    %esp,%ebp
f010014f:	53                   	push   %ebx
f0100150:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100153:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100156:	ff 75 0c             	pushl  0xc(%ebp)
f0100159:	ff 75 08             	pushl  0x8(%ebp)
f010015c:	68 5c 18 10 f0       	push   $0xf010185c
f0100161:	e8 83 07 00 00       	call   f01008e9 <cprintf>
	vcprintf(fmt, ap);
f0100166:	83 c4 08             	add    $0x8,%esp
f0100169:	53                   	push   %ebx
f010016a:	ff 75 10             	pushl  0x10(%ebp)
f010016d:	e8 51 07 00 00       	call   f01008c3 <vcprintf>
	cprintf("\n");
f0100172:	c7 04 24 80 18 10 f0 	movl   $0xf0101880,(%esp)
f0100179:	e8 6b 07 00 00       	call   f01008e9 <cprintf>
	va_end(ap);
}
f010017e:	83 c4 10             	add    $0x10,%esp
f0100181:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100184:	c9                   	leave  
f0100185:	c3                   	ret    

f0100186 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100186:	55                   	push   %ebp
f0100187:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100189:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010018e:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010018f:	a8 01                	test   $0x1,%al
f0100191:	74 0b                	je     f010019e <serial_proc_data+0x18>
f0100193:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100198:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100199:	0f b6 c0             	movzbl %al,%eax
}
f010019c:	5d                   	pop    %ebp
f010019d:	c3                   	ret    
		return -1;
f010019e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001a3:	eb f7                	jmp    f010019c <serial_proc_data+0x16>

f01001a5 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001a5:	55                   	push   %ebp
f01001a6:	89 e5                	mov    %esp,%ebp
f01001a8:	53                   	push   %ebx
f01001a9:	83 ec 04             	sub    $0x4,%esp
f01001ac:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001ae:	ff d3                	call   *%ebx
f01001b0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001b3:	74 2d                	je     f01001e2 <cons_intr+0x3d>
		if (c == 0)
f01001b5:	85 c0                	test   %eax,%eax
f01001b7:	74 f5                	je     f01001ae <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f01001b9:	8b 0d 24 25 11 f0    	mov    0xf0112524,%ecx
f01001bf:	8d 51 01             	lea    0x1(%ecx),%edx
f01001c2:	89 15 24 25 11 f0    	mov    %edx,0xf0112524
f01001c8:	88 81 20 23 11 f0    	mov    %al,-0xfeedce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001ce:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001d4:	75 d8                	jne    f01001ae <cons_intr+0x9>
			cons.wpos = 0;
f01001d6:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f01001dd:	00 00 00 
f01001e0:	eb cc                	jmp    f01001ae <cons_intr+0x9>
	}
}
f01001e2:	83 c4 04             	add    $0x4,%esp
f01001e5:	5b                   	pop    %ebx
f01001e6:	5d                   	pop    %ebp
f01001e7:	c3                   	ret    

f01001e8 <kbd_proc_data>:
{
f01001e8:	55                   	push   %ebp
f01001e9:	89 e5                	mov    %esp,%ebp
f01001eb:	53                   	push   %ebx
f01001ec:	83 ec 04             	sub    $0x4,%esp
f01001ef:	ba 64 00 00 00       	mov    $0x64,%edx
f01001f4:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01001f5:	a8 01                	test   $0x1,%al
f01001f7:	0f 84 f1 00 00 00    	je     f01002ee <kbd_proc_data+0x106>
	if (stat & KBS_TERR)
f01001fd:	a8 20                	test   $0x20,%al
f01001ff:	0f 85 f0 00 00 00    	jne    f01002f5 <kbd_proc_data+0x10d>
f0100205:	ba 60 00 00 00       	mov    $0x60,%edx
f010020a:	ec                   	in     (%dx),%al
f010020b:	88 c2                	mov    %al,%dl
	if (data == 0xE0) {
f010020d:	3c e0                	cmp    $0xe0,%al
f010020f:	0f 84 8a 00 00 00    	je     f010029f <kbd_proc_data+0xb7>
	} else if (data & 0x80) {
f0100215:	84 c0                	test   %al,%al
f0100217:	0f 88 95 00 00 00    	js     f01002b2 <kbd_proc_data+0xca>
	} else if (shift & E0ESC) {
f010021d:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100223:	f6 c1 40             	test   $0x40,%cl
f0100226:	74 0e                	je     f0100236 <kbd_proc_data+0x4e>
		data |= 0x80;
f0100228:	83 c8 80             	or     $0xffffff80,%eax
f010022b:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f010022d:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100230:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	shift |= shiftcode[data];
f0100236:	0f b6 d2             	movzbl %dl,%edx
f0100239:	0f b6 82 c0 19 10 f0 	movzbl -0xfefe640(%edx),%eax
f0100240:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
	shift ^= togglecode[data];
f0100246:	0f b6 8a c0 18 10 f0 	movzbl -0xfefe740(%edx),%ecx
f010024d:	31 c8                	xor    %ecx,%eax
f010024f:	a3 00 23 11 f0       	mov    %eax,0xf0112300
	c = charcode[shift & (CTL | SHIFT)][data];
f0100254:	89 c1                	mov    %eax,%ecx
f0100256:	83 e1 03             	and    $0x3,%ecx
f0100259:	8b 0c 8d a0 18 10 f0 	mov    -0xfefe760(,%ecx,4),%ecx
f0100260:	8a 14 11             	mov    (%ecx,%edx,1),%dl
f0100263:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100266:	a8 08                	test   $0x8,%al
f0100268:	74 0d                	je     f0100277 <kbd_proc_data+0x8f>
		if ('a' <= c && c <= 'z')
f010026a:	89 da                	mov    %ebx,%edx
f010026c:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010026f:	83 f9 19             	cmp    $0x19,%ecx
f0100272:	77 6d                	ja     f01002e1 <kbd_proc_data+0xf9>
			c += 'A' - 'a';
f0100274:	83 eb 20             	sub    $0x20,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100277:	f7 d0                	not    %eax
f0100279:	a8 06                	test   $0x6,%al
f010027b:	75 2e                	jne    f01002ab <kbd_proc_data+0xc3>
f010027d:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100283:	75 26                	jne    f01002ab <kbd_proc_data+0xc3>
		cprintf("Rebooting!\n");
f0100285:	83 ec 0c             	sub    $0xc,%esp
f0100288:	68 76 18 10 f0       	push   $0xf0101876
f010028d:	e8 57 06 00 00       	call   f01008e9 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100292:	b0 03                	mov    $0x3,%al
f0100294:	ba 92 00 00 00       	mov    $0x92,%edx
f0100299:	ee                   	out    %al,(%dx)
f010029a:	83 c4 10             	add    $0x10,%esp
f010029d:	eb 0c                	jmp    f01002ab <kbd_proc_data+0xc3>
		shift |= E0ESC;
f010029f:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f01002a6:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f01002ab:	89 d8                	mov    %ebx,%eax
f01002ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002b0:	c9                   	leave  
f01002b1:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002b2:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f01002b8:	f6 c1 40             	test   $0x40,%cl
f01002bb:	75 05                	jne    f01002c2 <kbd_proc_data+0xda>
f01002bd:	83 e0 7f             	and    $0x7f,%eax
f01002c0:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f01002c2:	0f b6 d2             	movzbl %dl,%edx
f01002c5:	8a 82 c0 19 10 f0    	mov    -0xfefe640(%edx),%al
f01002cb:	83 c8 40             	or     $0x40,%eax
f01002ce:	0f b6 c0             	movzbl %al,%eax
f01002d1:	f7 d0                	not    %eax
f01002d3:	21 c8                	and    %ecx,%eax
f01002d5:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f01002da:	bb 00 00 00 00       	mov    $0x0,%ebx
f01002df:	eb ca                	jmp    f01002ab <kbd_proc_data+0xc3>
		else if ('A' <= c && c <= 'Z')
f01002e1:	83 ea 41             	sub    $0x41,%edx
f01002e4:	83 fa 19             	cmp    $0x19,%edx
f01002e7:	77 8e                	ja     f0100277 <kbd_proc_data+0x8f>
			c += 'a' - 'A';
f01002e9:	83 c3 20             	add    $0x20,%ebx
f01002ec:	eb 89                	jmp    f0100277 <kbd_proc_data+0x8f>
		return -1;
f01002ee:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01002f3:	eb b6                	jmp    f01002ab <kbd_proc_data+0xc3>
		return -1;
f01002f5:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01002fa:	eb af                	jmp    f01002ab <kbd_proc_data+0xc3>

f01002fc <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002fc:	55                   	push   %ebp
f01002fd:	89 e5                	mov    %esp,%ebp
f01002ff:	57                   	push   %edi
f0100300:	56                   	push   %esi
f0100301:	53                   	push   %ebx
f0100302:	83 ec 1c             	sub    $0x1c,%esp
f0100305:	89 c7                	mov    %eax,%edi
f0100307:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010030c:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100311:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100316:	eb 06                	jmp    f010031e <cons_putc+0x22>
f0100318:	89 ca                	mov    %ecx,%edx
f010031a:	ec                   	in     (%dx),%al
f010031b:	ec                   	in     (%dx),%al
f010031c:	ec                   	in     (%dx),%al
f010031d:	ec                   	in     (%dx),%al
f010031e:	89 f2                	mov    %esi,%edx
f0100320:	ec                   	in     (%dx),%al
	for (i = 0;
f0100321:	a8 20                	test   $0x20,%al
f0100323:	75 03                	jne    f0100328 <cons_putc+0x2c>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100325:	4b                   	dec    %ebx
f0100326:	75 f0                	jne    f0100318 <cons_putc+0x1c>
	outb(COM1 + COM_TX, c);
f0100328:	89 f8                	mov    %edi,%eax
f010032a:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010032d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100332:	ee                   	out    %al,(%dx)
f0100333:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100338:	be 79 03 00 00       	mov    $0x379,%esi
f010033d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100342:	eb 06                	jmp    f010034a <cons_putc+0x4e>
f0100344:	89 ca                	mov    %ecx,%edx
f0100346:	ec                   	in     (%dx),%al
f0100347:	ec                   	in     (%dx),%al
f0100348:	ec                   	in     (%dx),%al
f0100349:	ec                   	in     (%dx),%al
f010034a:	89 f2                	mov    %esi,%edx
f010034c:	ec                   	in     (%dx),%al
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010034d:	84 c0                	test   %al,%al
f010034f:	78 03                	js     f0100354 <cons_putc+0x58>
f0100351:	4b                   	dec    %ebx
f0100352:	75 f0                	jne    f0100344 <cons_putc+0x48>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100354:	ba 78 03 00 00       	mov    $0x378,%edx
f0100359:	8a 45 e7             	mov    -0x19(%ebp),%al
f010035c:	ee                   	out    %al,(%dx)
f010035d:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100362:	b0 0d                	mov    $0xd,%al
f0100364:	ee                   	out    %al,(%dx)
f0100365:	b0 08                	mov    $0x8,%al
f0100367:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f0100368:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f010036e:	75 06                	jne    f0100376 <cons_putc+0x7a>
		c |= 0x0700;
f0100370:	81 cf 00 07 00 00    	or     $0x700,%edi
	switch (c & 0xff) {
f0100376:	89 f8                	mov    %edi,%eax
f0100378:	0f b6 c0             	movzbl %al,%eax
f010037b:	83 f8 09             	cmp    $0x9,%eax
f010037e:	0f 84 b1 00 00 00    	je     f0100435 <cons_putc+0x139>
f0100384:	83 f8 09             	cmp    $0x9,%eax
f0100387:	7e 70                	jle    f01003f9 <cons_putc+0xfd>
f0100389:	83 f8 0a             	cmp    $0xa,%eax
f010038c:	0f 84 96 00 00 00    	je     f0100428 <cons_putc+0x12c>
f0100392:	83 f8 0d             	cmp    $0xd,%eax
f0100395:	0f 85 d1 00 00 00    	jne    f010046c <cons_putc+0x170>
		crt_pos -= (crt_pos % CRT_COLS);
f010039b:	66 8b 0d 28 25 11 f0 	mov    0xf0112528,%cx
f01003a2:	bb 50 00 00 00       	mov    $0x50,%ebx
f01003a7:	89 c8                	mov    %ecx,%eax
f01003a9:	ba 00 00 00 00       	mov    $0x0,%edx
f01003ae:	66 f7 f3             	div    %bx
f01003b1:	29 d1                	sub    %edx,%ecx
f01003b3:	66 89 0d 28 25 11 f0 	mov    %cx,0xf0112528
	if (crt_pos >= CRT_SIZE) {
f01003ba:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f01003c1:	cf 07 
f01003c3:	0f 87 c5 00 00 00    	ja     f010048e <cons_putc+0x192>
	outb(addr_6845, 14);
f01003c9:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f01003cf:	b0 0e                	mov    $0xe,%al
f01003d1:	89 ca                	mov    %ecx,%edx
f01003d3:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01003d4:	8d 59 01             	lea    0x1(%ecx),%ebx
f01003d7:	66 a1 28 25 11 f0    	mov    0xf0112528,%ax
f01003dd:	66 c1 e8 08          	shr    $0x8,%ax
f01003e1:	89 da                	mov    %ebx,%edx
f01003e3:	ee                   	out    %al,(%dx)
f01003e4:	b0 0f                	mov    $0xf,%al
f01003e6:	89 ca                	mov    %ecx,%edx
f01003e8:	ee                   	out    %al,(%dx)
f01003e9:	a0 28 25 11 f0       	mov    0xf0112528,%al
f01003ee:	89 da                	mov    %ebx,%edx
f01003f0:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01003f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01003f4:	5b                   	pop    %ebx
f01003f5:	5e                   	pop    %esi
f01003f6:	5f                   	pop    %edi
f01003f7:	5d                   	pop    %ebp
f01003f8:	c3                   	ret    
	switch (c & 0xff) {
f01003f9:	83 f8 08             	cmp    $0x8,%eax
f01003fc:	75 6e                	jne    f010046c <cons_putc+0x170>
		if (crt_pos > 0) {
f01003fe:	66 a1 28 25 11 f0    	mov    0xf0112528,%ax
f0100404:	66 85 c0             	test   %ax,%ax
f0100407:	74 c0                	je     f01003c9 <cons_putc+0xcd>
			crt_pos--;
f0100409:	48                   	dec    %eax
f010040a:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100410:	0f b7 c0             	movzwl %ax,%eax
f0100413:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f0100419:	83 cf 20             	or     $0x20,%edi
f010041c:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100422:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100426:	eb 92                	jmp    f01003ba <cons_putc+0xbe>
		crt_pos += CRT_COLS;
f0100428:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f010042f:	50 
f0100430:	e9 66 ff ff ff       	jmp    f010039b <cons_putc+0x9f>
		cons_putc(' ');
f0100435:	b8 20 00 00 00       	mov    $0x20,%eax
f010043a:	e8 bd fe ff ff       	call   f01002fc <cons_putc>
		cons_putc(' ');
f010043f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100444:	e8 b3 fe ff ff       	call   f01002fc <cons_putc>
		cons_putc(' ');
f0100449:	b8 20 00 00 00       	mov    $0x20,%eax
f010044e:	e8 a9 fe ff ff       	call   f01002fc <cons_putc>
		cons_putc(' ');
f0100453:	b8 20 00 00 00       	mov    $0x20,%eax
f0100458:	e8 9f fe ff ff       	call   f01002fc <cons_putc>
		cons_putc(' ');
f010045d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100462:	e8 95 fe ff ff       	call   f01002fc <cons_putc>
f0100467:	e9 4e ff ff ff       	jmp    f01003ba <cons_putc+0xbe>
		crt_buf[crt_pos++] = c;		/* write the character */
f010046c:	66 a1 28 25 11 f0    	mov    0xf0112528,%ax
f0100472:	8d 50 01             	lea    0x1(%eax),%edx
f0100475:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f010047c:	0f b7 c0             	movzwl %ax,%eax
f010047f:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100485:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100489:	e9 2c ff ff ff       	jmp    f01003ba <cons_putc+0xbe>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010048e:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f0100493:	83 ec 04             	sub    $0x4,%esp
f0100496:	68 00 0f 00 00       	push   $0xf00
f010049b:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004a1:	52                   	push   %edx
f01004a2:	50                   	push   %eax
f01004a3:	e8 92 0f 00 00       	call   f010143a <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01004a8:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01004ae:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01004b4:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01004ba:	83 c4 10             	add    $0x10,%esp
f01004bd:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01004c2:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004c5:	39 d0                	cmp    %edx,%eax
f01004c7:	75 f4                	jne    f01004bd <cons_putc+0x1c1>
		crt_pos -= CRT_COLS;
f01004c9:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f01004d0:	50 
f01004d1:	e9 f3 fe ff ff       	jmp    f01003c9 <cons_putc+0xcd>

f01004d6 <serial_intr>:
	if (serial_exists)
f01004d6:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f01004dd:	75 01                	jne    f01004e0 <serial_intr+0xa>
f01004df:	c3                   	ret    
{
f01004e0:	55                   	push   %ebp
f01004e1:	89 e5                	mov    %esp,%ebp
f01004e3:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01004e6:	b8 86 01 10 f0       	mov    $0xf0100186,%eax
f01004eb:	e8 b5 fc ff ff       	call   f01001a5 <cons_intr>
}
f01004f0:	c9                   	leave  
f01004f1:	c3                   	ret    

f01004f2 <kbd_intr>:
{
f01004f2:	55                   	push   %ebp
f01004f3:	89 e5                	mov    %esp,%ebp
f01004f5:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004f8:	b8 e8 01 10 f0       	mov    $0xf01001e8,%eax
f01004fd:	e8 a3 fc ff ff       	call   f01001a5 <cons_intr>
}
f0100502:	c9                   	leave  
f0100503:	c3                   	ret    

f0100504 <cons_getc>:
{
f0100504:	55                   	push   %ebp
f0100505:	89 e5                	mov    %esp,%ebp
f0100507:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f010050a:	e8 c7 ff ff ff       	call   f01004d6 <serial_intr>
	kbd_intr();
f010050f:	e8 de ff ff ff       	call   f01004f2 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100514:	a1 20 25 11 f0       	mov    0xf0112520,%eax
f0100519:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f010051f:	74 26                	je     f0100547 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100521:	8d 50 01             	lea    0x1(%eax),%edx
f0100524:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
f010052a:	0f b6 80 20 23 11 f0 	movzbl -0xfeedce0(%eax),%eax
		if (cons.rpos == CONSBUFSIZE)
f0100531:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100537:	74 02                	je     f010053b <cons_getc+0x37>
}
f0100539:	c9                   	leave  
f010053a:	c3                   	ret    
			cons.rpos = 0;
f010053b:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f0100542:	00 00 00 
f0100545:	eb f2                	jmp    f0100539 <cons_getc+0x35>
	return 0;
f0100547:	b8 00 00 00 00       	mov    $0x0,%eax
f010054c:	eb eb                	jmp    f0100539 <cons_getc+0x35>

f010054e <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f010054e:	55                   	push   %ebp
f010054f:	89 e5                	mov    %esp,%ebp
f0100551:	57                   	push   %edi
f0100552:	56                   	push   %esi
f0100553:	53                   	push   %ebx
f0100554:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f0100557:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f010055e:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100565:	5a a5 
	if (*cp != 0xA55A) {
f0100567:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f010056d:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100571:	0f 84 a2 00 00 00    	je     f0100619 <cons_init+0xcb>
		addr_6845 = MONO_BASE;
f0100577:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f010057e:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100581:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f0100586:	8b 3d 30 25 11 f0    	mov    0xf0112530,%edi
f010058c:	b0 0e                	mov    $0xe,%al
f010058e:	89 fa                	mov    %edi,%edx
f0100590:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100591:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100594:	89 ca                	mov    %ecx,%edx
f0100596:	ec                   	in     (%dx),%al
f0100597:	0f b6 c0             	movzbl %al,%eax
f010059a:	c1 e0 08             	shl    $0x8,%eax
f010059d:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010059f:	b0 0f                	mov    $0xf,%al
f01005a1:	89 fa                	mov    %edi,%edx
f01005a3:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005a4:	89 ca                	mov    %ecx,%edx
f01005a6:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01005a7:	89 35 2c 25 11 f0    	mov    %esi,0xf011252c
	pos |= inb(addr_6845 + 1);
f01005ad:	0f b6 c0             	movzbl %al,%eax
f01005b0:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01005b2:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005b8:	b1 00                	mov    $0x0,%cl
f01005ba:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01005bf:	88 c8                	mov    %cl,%al
f01005c1:	89 da                	mov    %ebx,%edx
f01005c3:	ee                   	out    %al,(%dx)
f01005c4:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01005c9:	b0 80                	mov    $0x80,%al
f01005cb:	89 fa                	mov    %edi,%edx
f01005cd:	ee                   	out    %al,(%dx)
f01005ce:	b0 0c                	mov    $0xc,%al
f01005d0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01005d5:	ee                   	out    %al,(%dx)
f01005d6:	be f9 03 00 00       	mov    $0x3f9,%esi
f01005db:	88 c8                	mov    %cl,%al
f01005dd:	89 f2                	mov    %esi,%edx
f01005df:	ee                   	out    %al,(%dx)
f01005e0:	b0 03                	mov    $0x3,%al
f01005e2:	89 fa                	mov    %edi,%edx
f01005e4:	ee                   	out    %al,(%dx)
f01005e5:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005ea:	88 c8                	mov    %cl,%al
f01005ec:	ee                   	out    %al,(%dx)
f01005ed:	b0 01                	mov    $0x1,%al
f01005ef:	89 f2                	mov    %esi,%edx
f01005f1:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005f2:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005f7:	ec                   	in     (%dx),%al
f01005f8:	88 c1                	mov    %al,%cl
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005fa:	3c ff                	cmp    $0xff,%al
f01005fc:	0f 95 05 34 25 11 f0 	setne  0xf0112534
f0100603:	89 da                	mov    %ebx,%edx
f0100605:	ec                   	in     (%dx),%al
f0100606:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010060b:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010060c:	80 f9 ff             	cmp    $0xff,%cl
f010060f:	74 23                	je     f0100634 <cons_init+0xe6>
		cprintf("Serial port does not exist!\n");
}
f0100611:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100614:	5b                   	pop    %ebx
f0100615:	5e                   	pop    %esi
f0100616:	5f                   	pop    %edi
f0100617:	5d                   	pop    %ebp
f0100618:	c3                   	ret    
		*cp = was;
f0100619:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100620:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f0100627:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010062a:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f010062f:	e9 52 ff ff ff       	jmp    f0100586 <cons_init+0x38>
		cprintf("Serial port does not exist!\n");
f0100634:	83 ec 0c             	sub    $0xc,%esp
f0100637:	68 82 18 10 f0       	push   $0xf0101882
f010063c:	e8 a8 02 00 00       	call   f01008e9 <cprintf>
f0100641:	83 c4 10             	add    $0x10,%esp
}
f0100644:	eb cb                	jmp    f0100611 <cons_init+0xc3>

f0100646 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100646:	55                   	push   %ebp
f0100647:	89 e5                	mov    %esp,%ebp
f0100649:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010064c:	8b 45 08             	mov    0x8(%ebp),%eax
f010064f:	e8 a8 fc ff ff       	call   f01002fc <cons_putc>
}
f0100654:	c9                   	leave  
f0100655:	c3                   	ret    

f0100656 <getchar>:

int
getchar(void)
{
f0100656:	55                   	push   %ebp
f0100657:	89 e5                	mov    %esp,%ebp
f0100659:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010065c:	e8 a3 fe ff ff       	call   f0100504 <cons_getc>
f0100661:	85 c0                	test   %eax,%eax
f0100663:	74 f7                	je     f010065c <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100665:	c9                   	leave  
f0100666:	c3                   	ret    

f0100667 <iscons>:

int
iscons(int fdnum)
{
f0100667:	55                   	push   %ebp
f0100668:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010066a:	b8 01 00 00 00       	mov    $0x1,%eax
f010066f:	5d                   	pop    %ebp
f0100670:	c3                   	ret    

f0100671 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100671:	55                   	push   %ebp
f0100672:	89 e5                	mov    %esp,%ebp
f0100674:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100677:	68 c0 1a 10 f0       	push   $0xf0101ac0
f010067c:	68 de 1a 10 f0       	push   $0xf0101ade
f0100681:	68 e3 1a 10 f0       	push   $0xf0101ae3
f0100686:	e8 5e 02 00 00       	call   f01008e9 <cprintf>
f010068b:	83 c4 0c             	add    $0xc,%esp
f010068e:	68 70 1b 10 f0       	push   $0xf0101b70
f0100693:	68 ec 1a 10 f0       	push   $0xf0101aec
f0100698:	68 e3 1a 10 f0       	push   $0xf0101ae3
f010069d:	e8 47 02 00 00       	call   f01008e9 <cprintf>
f01006a2:	83 c4 0c             	add    $0xc,%esp
f01006a5:	68 f5 1a 10 f0       	push   $0xf0101af5
f01006aa:	68 04 1b 10 f0       	push   $0xf0101b04
f01006af:	68 e3 1a 10 f0       	push   $0xf0101ae3
f01006b4:	e8 30 02 00 00       	call   f01008e9 <cprintf>
	return 0;
}
f01006b9:	b8 00 00 00 00       	mov    $0x0,%eax
f01006be:	c9                   	leave  
f01006bf:	c3                   	ret    

f01006c0 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006c0:	55                   	push   %ebp
f01006c1:	89 e5                	mov    %esp,%ebp
f01006c3:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006c6:	68 09 1b 10 f0       	push   $0xf0101b09
f01006cb:	e8 19 02 00 00       	call   f01008e9 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006d0:	83 c4 08             	add    $0x8,%esp
f01006d3:	68 0c 00 10 00       	push   $0x10000c
f01006d8:	68 98 1b 10 f0       	push   $0xf0101b98
f01006dd:	e8 07 02 00 00       	call   f01008e9 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006e2:	83 c4 0c             	add    $0xc,%esp
f01006e5:	68 0c 00 10 00       	push   $0x10000c
f01006ea:	68 0c 00 10 f0       	push   $0xf010000c
f01006ef:	68 c0 1b 10 f0       	push   $0xf0101bc0
f01006f4:	e8 f0 01 00 00       	call   f01008e9 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006f9:	83 c4 0c             	add    $0xc,%esp
f01006fc:	68 d4 17 10 00       	push   $0x1017d4
f0100701:	68 d4 17 10 f0       	push   $0xf01017d4
f0100706:	68 e4 1b 10 f0       	push   $0xf0101be4
f010070b:	e8 d9 01 00 00       	call   f01008e9 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100710:	83 c4 0c             	add    $0xc,%esp
f0100713:	68 00 23 11 00       	push   $0x112300
f0100718:	68 00 23 11 f0       	push   $0xf0112300
f010071d:	68 08 1c 10 f0       	push   $0xf0101c08
f0100722:	e8 c2 01 00 00       	call   f01008e9 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100727:	83 c4 0c             	add    $0xc,%esp
f010072a:	68 44 29 11 00       	push   $0x112944
f010072f:	68 44 29 11 f0       	push   $0xf0112944
f0100734:	68 2c 1c 10 f0       	push   $0xf0101c2c
f0100739:	e8 ab 01 00 00       	call   f01008e9 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010073e:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100741:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
f0100746:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f010074b:	c1 f8 0a             	sar    $0xa,%eax
f010074e:	50                   	push   %eax
f010074f:	68 50 1c 10 f0       	push   $0xf0101c50
f0100754:	e8 90 01 00 00       	call   f01008e9 <cprintf>
	return 0;
}
f0100759:	b8 00 00 00 00       	mov    $0x0,%eax
f010075e:	c9                   	leave  
f010075f:	c3                   	ret    

f0100760 <mon_quit>:

int 
mon_quit(int argc, char **argv, struct Trapframe *tf) 
{
f0100760:	55                   	push   %ebp
f0100761:	89 e5                	mov    %esp,%ebp
f0100763:	83 ec 14             	sub    $0x14,%esp
	cprintf("Quitting......\n");
f0100766:	68 22 1b 10 f0       	push   $0xf0101b22
f010076b:	e8 79 01 00 00       	call   f01008e9 <cprintf>
	return -1;
}
f0100770:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100775:	c9                   	leave  
f0100776:	c3                   	ret    

f0100777 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100777:	55                   	push   %ebp
f0100778:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f010077a:	b8 00 00 00 00       	mov    $0x0,%eax
f010077f:	5d                   	pop    %ebp
f0100780:	c3                   	ret    

f0100781 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100781:	55                   	push   %ebp
f0100782:	89 e5                	mov    %esp,%ebp
f0100784:	57                   	push   %edi
f0100785:	56                   	push   %esi
f0100786:	53                   	push   %ebx
f0100787:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010078a:	68 7c 1c 10 f0       	push   $0xf0101c7c
f010078f:	e8 55 01 00 00       	call   f01008e9 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100794:	c7 04 24 a0 1c 10 f0 	movl   $0xf0101ca0,(%esp)
f010079b:	e8 49 01 00 00       	call   f01008e9 <cprintf>
f01007a0:	83 c4 10             	add    $0x10,%esp
f01007a3:	eb 47                	jmp    f01007ec <monitor+0x6b>
		while (*buf && strchr(WHITESPACE, *buf))
f01007a5:	83 ec 08             	sub    $0x8,%esp
f01007a8:	0f be c0             	movsbl %al,%eax
f01007ab:	50                   	push   %eax
f01007ac:	68 36 1b 10 f0       	push   $0xf0101b36
f01007b1:	e8 02 0c 00 00       	call   f01013b8 <strchr>
f01007b6:	83 c4 10             	add    $0x10,%esp
f01007b9:	85 c0                	test   %eax,%eax
f01007bb:	74 0a                	je     f01007c7 <monitor+0x46>
			*buf++ = 0;
f01007bd:	c6 03 00             	movb   $0x0,(%ebx)
f01007c0:	89 fe                	mov    %edi,%esi
f01007c2:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01007c5:	eb 68                	jmp    f010082f <monitor+0xae>
		if (*buf == 0)
f01007c7:	80 3b 00             	cmpb   $0x0,(%ebx)
f01007ca:	74 6f                	je     f010083b <monitor+0xba>
		if (argc == MAXARGS-1) {
f01007cc:	83 ff 0f             	cmp    $0xf,%edi
f01007cf:	74 09                	je     f01007da <monitor+0x59>
		argv[argc++] = buf;
f01007d1:	8d 77 01             	lea    0x1(%edi),%esi
f01007d4:	89 5c bd a8          	mov    %ebx,-0x58(%ebp,%edi,4)
f01007d8:	eb 37                	jmp    f0100811 <monitor+0x90>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01007da:	83 ec 08             	sub    $0x8,%esp
f01007dd:	6a 10                	push   $0x10
f01007df:	68 3b 1b 10 f0       	push   $0xf0101b3b
f01007e4:	e8 00 01 00 00       	call   f01008e9 <cprintf>
f01007e9:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01007ec:	83 ec 0c             	sub    $0xc,%esp
f01007ef:	68 32 1b 10 f0       	push   $0xf0101b32
f01007f4:	e8 b4 09 00 00       	call   f01011ad <readline>
f01007f9:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007fb:	83 c4 10             	add    $0x10,%esp
f01007fe:	85 c0                	test   %eax,%eax
f0100800:	74 ea                	je     f01007ec <monitor+0x6b>
	argv[argc] = 0;
f0100802:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100809:	bf 00 00 00 00       	mov    $0x0,%edi
f010080e:	eb 21                	jmp    f0100831 <monitor+0xb0>
			buf++;
f0100810:	43                   	inc    %ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100811:	8a 03                	mov    (%ebx),%al
f0100813:	84 c0                	test   %al,%al
f0100815:	74 18                	je     f010082f <monitor+0xae>
f0100817:	83 ec 08             	sub    $0x8,%esp
f010081a:	0f be c0             	movsbl %al,%eax
f010081d:	50                   	push   %eax
f010081e:	68 36 1b 10 f0       	push   $0xf0101b36
f0100823:	e8 90 0b 00 00       	call   f01013b8 <strchr>
f0100828:	83 c4 10             	add    $0x10,%esp
f010082b:	85 c0                	test   %eax,%eax
f010082d:	74 e1                	je     f0100810 <monitor+0x8f>
			*buf++ = 0;
f010082f:	89 f7                	mov    %esi,%edi
		while (*buf && strchr(WHITESPACE, *buf))
f0100831:	8a 03                	mov    (%ebx),%al
f0100833:	84 c0                	test   %al,%al
f0100835:	0f 85 6a ff ff ff    	jne    f01007a5 <monitor+0x24>
	argv[argc] = 0;
f010083b:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
f0100842:	00 
	if (argc == 0)
f0100843:	85 ff                	test   %edi,%edi
f0100845:	74 a5                	je     f01007ec <monitor+0x6b>
f0100847:	be e0 1c 10 f0       	mov    $0xf0101ce0,%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f010084c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f0100851:	83 ec 08             	sub    $0x8,%esp
f0100854:	ff 36                	pushl  (%esi)
f0100856:	ff 75 a8             	pushl  -0x58(%ebp)
f0100859:	e8 06 0b 00 00       	call   f0101364 <strcmp>
f010085e:	83 c4 10             	add    $0x10,%esp
f0100861:	85 c0                	test   %eax,%eax
f0100863:	74 21                	je     f0100886 <monitor+0x105>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100865:	43                   	inc    %ebx
f0100866:	83 c6 0c             	add    $0xc,%esi
f0100869:	83 fb 03             	cmp    $0x3,%ebx
f010086c:	75 e3                	jne    f0100851 <monitor+0xd0>
	cprintf("Unknown command '%s'\n", argv[0]);
f010086e:	83 ec 08             	sub    $0x8,%esp
f0100871:	ff 75 a8             	pushl  -0x58(%ebp)
f0100874:	68 58 1b 10 f0       	push   $0xf0101b58
f0100879:	e8 6b 00 00 00       	call   f01008e9 <cprintf>
f010087e:	83 c4 10             	add    $0x10,%esp
f0100881:	e9 66 ff ff ff       	jmp    f01007ec <monitor+0x6b>
			return commands[i].func(argc, argv, tf);
f0100886:	83 ec 04             	sub    $0x4,%esp
f0100889:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f010088c:	01 c3                	add    %eax,%ebx
f010088e:	ff 75 08             	pushl  0x8(%ebp)
f0100891:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100894:	50                   	push   %eax
f0100895:	57                   	push   %edi
f0100896:	ff 14 9d e8 1c 10 f0 	call   *-0xfefe318(,%ebx,4)
			if (runcmd(buf, tf) < 0)
f010089d:	83 c4 10             	add    $0x10,%esp
f01008a0:	85 c0                	test   %eax,%eax
f01008a2:	0f 89 44 ff ff ff    	jns    f01007ec <monitor+0x6b>
				break;
	}
}
f01008a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008ab:	5b                   	pop    %ebx
f01008ac:	5e                   	pop    %esi
f01008ad:	5f                   	pop    %edi
f01008ae:	5d                   	pop    %ebp
f01008af:	c3                   	ret    

f01008b0 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01008b0:	55                   	push   %ebp
f01008b1:	89 e5                	mov    %esp,%ebp
f01008b3:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01008b6:	ff 75 08             	pushl  0x8(%ebp)
f01008b9:	e8 88 fd ff ff       	call   f0100646 <cputchar>
	*cnt++;
}
f01008be:	83 c4 10             	add    $0x10,%esp
f01008c1:	c9                   	leave  
f01008c2:	c3                   	ret    

f01008c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01008c3:	55                   	push   %ebp
f01008c4:	89 e5                	mov    %esp,%ebp
f01008c6:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01008c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01008d0:	ff 75 0c             	pushl  0xc(%ebp)
f01008d3:	ff 75 08             	pushl  0x8(%ebp)
f01008d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01008d9:	50                   	push   %eax
f01008da:	68 b0 08 10 f0       	push   $0xf01008b0
f01008df:	e8 d8 03 00 00       	call   f0100cbc <vprintfmt>
	return cnt;
}
f01008e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01008e7:	c9                   	leave  
f01008e8:	c3                   	ret    

f01008e9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01008e9:	55                   	push   %ebp
f01008ea:	89 e5                	mov    %esp,%ebp
f01008ec:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01008ef:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01008f2:	50                   	push   %eax
f01008f3:	ff 75 08             	pushl  0x8(%ebp)
f01008f6:	e8 c8 ff ff ff       	call   f01008c3 <vcprintf>
	va_end(ap);

	return cnt;
}
f01008fb:	c9                   	leave  
f01008fc:	c3                   	ret    

f01008fd <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01008fd:	55                   	push   %ebp
f01008fe:	89 e5                	mov    %esp,%ebp
f0100900:	57                   	push   %edi
f0100901:	56                   	push   %esi
f0100902:	53                   	push   %ebx
f0100903:	83 ec 14             	sub    $0x14,%esp
f0100906:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100909:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010090c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010090f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100912:	8b 32                	mov    (%edx),%esi
f0100914:	8b 01                	mov    (%ecx),%eax
f0100916:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100919:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100920:	eb 2f                	jmp    f0100951 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100922:	48                   	dec    %eax
		while (m >= l && stabs[m].n_type != type)
f0100923:	39 c6                	cmp    %eax,%esi
f0100925:	7f 4d                	jg     f0100974 <stab_binsearch+0x77>
f0100927:	0f b6 0a             	movzbl (%edx),%ecx
f010092a:	83 ea 0c             	sub    $0xc,%edx
f010092d:	39 f9                	cmp    %edi,%ecx
f010092f:	75 f1                	jne    f0100922 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100931:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100934:	01 c2                	add    %eax,%edx
f0100936:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100939:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010093d:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100940:	73 37                	jae    f0100979 <stab_binsearch+0x7c>
			*region_left = m;
f0100942:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100945:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0100947:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f010094a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100951:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0100954:	7f 4d                	jg     f01009a3 <stab_binsearch+0xa6>
		int true_m = (l + r) / 2, m = true_m;
f0100956:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100959:	01 f0                	add    %esi,%eax
f010095b:	89 c3                	mov    %eax,%ebx
f010095d:	c1 eb 1f             	shr    $0x1f,%ebx
f0100960:	01 c3                	add    %eax,%ebx
f0100962:	d1 fb                	sar    %ebx
f0100964:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100967:	01 d8                	add    %ebx,%eax
f0100969:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010096c:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100970:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0100972:	eb af                	jmp    f0100923 <stab_binsearch+0x26>
			l = true_m + 1;
f0100974:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0100977:	eb d8                	jmp    f0100951 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100979:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010097c:	76 12                	jbe    f0100990 <stab_binsearch+0x93>
			*region_right = m - 1;
f010097e:	48                   	dec    %eax
f010097f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100982:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100985:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0100987:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010098e:	eb c1                	jmp    f0100951 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100990:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100993:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100995:	ff 45 0c             	incl   0xc(%ebp)
f0100998:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f010099a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01009a1:	eb ae                	jmp    f0100951 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f01009a3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01009a7:	74 18                	je     f01009c1 <stab_binsearch+0xc4>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01009a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01009ac:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01009ae:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01009b1:	8b 0e                	mov    (%esi),%ecx
f01009b3:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01009b6:	01 c2                	add    %eax,%edx
f01009b8:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01009bb:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f01009bf:	eb 0e                	jmp    f01009cf <stab_binsearch+0xd2>
		*region_right = *region_left - 1;
f01009c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009c4:	8b 00                	mov    (%eax),%eax
f01009c6:	48                   	dec    %eax
f01009c7:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01009ca:	89 07                	mov    %eax,(%edi)
f01009cc:	eb 14                	jmp    f01009e2 <stab_binsearch+0xe5>
		     l--)
f01009ce:	48                   	dec    %eax
		for (l = *region_right;
f01009cf:	39 c1                	cmp    %eax,%ecx
f01009d1:	7d 0a                	jge    f01009dd <stab_binsearch+0xe0>
		     l > *region_left && stabs[l].n_type != type;
f01009d3:	0f b6 1a             	movzbl (%edx),%ebx
f01009d6:	83 ea 0c             	sub    $0xc,%edx
f01009d9:	39 fb                	cmp    %edi,%ebx
f01009db:	75 f1                	jne    f01009ce <stab_binsearch+0xd1>
			/* do nothing */;
		*region_left = l;
f01009dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01009e0:	89 07                	mov    %eax,(%edi)
	}
}
f01009e2:	83 c4 14             	add    $0x14,%esp
f01009e5:	5b                   	pop    %ebx
f01009e6:	5e                   	pop    %esi
f01009e7:	5f                   	pop    %edi
f01009e8:	5d                   	pop    %ebp
f01009e9:	c3                   	ret    

f01009ea <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01009ea:	55                   	push   %ebp
f01009eb:	89 e5                	mov    %esp,%ebp
f01009ed:	57                   	push   %edi
f01009ee:	56                   	push   %esi
f01009ef:	53                   	push   %ebx
f01009f0:	83 ec 1c             	sub    $0x1c,%esp
f01009f3:	8b 7d 08             	mov    0x8(%ebp),%edi
f01009f6:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01009f9:	c7 06 04 1d 10 f0    	movl   $0xf0101d04,(%esi)
	info->eip_line = 0;
f01009ff:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100a06:	c7 46 08 04 1d 10 f0 	movl   $0xf0101d04,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100a0d:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100a14:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100a17:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100a1e:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100a24:	0f 86 f8 00 00 00    	jbe    f0100b22 <debuginfo_eip+0x138>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100a2a:	b8 7f 73 10 f0       	mov    $0xf010737f,%eax
f0100a2f:	3d 4d 5a 10 f0       	cmp    $0xf0105a4d,%eax
f0100a34:	0f 86 73 01 00 00    	jbe    f0100bad <debuginfo_eip+0x1c3>
f0100a3a:	80 3d 7e 73 10 f0 00 	cmpb   $0x0,0xf010737e
f0100a41:	0f 85 6d 01 00 00    	jne    f0100bb4 <debuginfo_eip+0x1ca>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100a47:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100a4e:	ba 4c 5a 10 f0       	mov    $0xf0105a4c,%edx
f0100a53:	81 ea 3c 1f 10 f0    	sub    $0xf0101f3c,%edx
f0100a59:	c1 fa 02             	sar    $0x2,%edx
f0100a5c:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0100a5f:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100a62:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100a65:	89 c1                	mov    %eax,%ecx
f0100a67:	c1 e1 08             	shl    $0x8,%ecx
f0100a6a:	01 c8                	add    %ecx,%eax
f0100a6c:	89 c1                	mov    %eax,%ecx
f0100a6e:	c1 e1 10             	shl    $0x10,%ecx
f0100a71:	01 c8                	add    %ecx,%eax
f0100a73:	01 c0                	add    %eax,%eax
f0100a75:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
f0100a79:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100a7c:	83 ec 08             	sub    $0x8,%esp
f0100a7f:	57                   	push   %edi
f0100a80:	6a 64                	push   $0x64
f0100a82:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100a85:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100a88:	b8 3c 1f 10 f0       	mov    $0xf0101f3c,%eax
f0100a8d:	e8 6b fe ff ff       	call   f01008fd <stab_binsearch>
	if (lfile == 0)
f0100a92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a95:	83 c4 10             	add    $0x10,%esp
f0100a98:	85 c0                	test   %eax,%eax
f0100a9a:	0f 84 1b 01 00 00    	je     f0100bbb <debuginfo_eip+0x1d1>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100aa0:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100aa3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100aa6:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100aa9:	83 ec 08             	sub    $0x8,%esp
f0100aac:	57                   	push   %edi
f0100aad:	6a 24                	push   $0x24
f0100aaf:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100ab2:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ab5:	b8 3c 1f 10 f0       	mov    $0xf0101f3c,%eax
f0100aba:	e8 3e fe ff ff       	call   f01008fd <stab_binsearch>

	if (lfun <= rfun) {
f0100abf:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100ac2:	83 c4 10             	add    $0x10,%esp
f0100ac5:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0100ac8:	7f 6c                	jg     f0100b36 <debuginfo_eip+0x14c>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100aca:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100acd:	01 d8                	add    %ebx,%eax
f0100acf:	c1 e0 02             	shl    $0x2,%eax
f0100ad2:	8d 90 3c 1f 10 f0    	lea    -0xfefe0c4(%eax),%edx
f0100ad8:	8b 88 3c 1f 10 f0    	mov    -0xfefe0c4(%eax),%ecx
f0100ade:	b8 7f 73 10 f0       	mov    $0xf010737f,%eax
f0100ae3:	2d 4d 5a 10 f0       	sub    $0xf0105a4d,%eax
f0100ae8:	39 c1                	cmp    %eax,%ecx
f0100aea:	73 09                	jae    f0100af5 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100aec:	81 c1 4d 5a 10 f0    	add    $0xf0105a4d,%ecx
f0100af2:	89 4e 08             	mov    %ecx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100af5:	8b 42 08             	mov    0x8(%edx),%eax
f0100af8:	89 46 10             	mov    %eax,0x10(%esi)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100afb:	83 ec 08             	sub    $0x8,%esp
f0100afe:	6a 3a                	push   $0x3a
f0100b00:	ff 76 08             	pushl  0x8(%esi)
f0100b03:	e8 cd 08 00 00       	call   f01013d5 <strfind>
f0100b08:	2b 46 08             	sub    0x8(%esi),%eax
f0100b0b:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100b0e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100b11:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100b14:	01 d8                	add    %ebx,%eax
f0100b16:	8d 04 85 40 1f 10 f0 	lea    -0xfefe0c0(,%eax,4),%eax
f0100b1d:	83 c4 10             	add    $0x10,%esp
f0100b20:	eb 20                	jmp    f0100b42 <debuginfo_eip+0x158>
  	        panic("User address");
f0100b22:	83 ec 04             	sub    $0x4,%esp
f0100b25:	68 0e 1d 10 f0       	push   $0xf0101d0e
f0100b2a:	6a 7f                	push   $0x7f
f0100b2c:	68 1b 1d 10 f0       	push   $0xf0101d1b
f0100b31:	e8 bd f5 ff ff       	call   f01000f3 <_panic>
		info->eip_fn_addr = addr;
f0100b36:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100b39:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100b3c:	eb bd                	jmp    f0100afb <debuginfo_eip+0x111>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100b3e:	4b                   	dec    %ebx
f0100b3f:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0100b42:	39 df                	cmp    %ebx,%edi
f0100b44:	7f 34                	jg     f0100b7a <debuginfo_eip+0x190>
	       && stabs[lline].n_type != N_SOL
f0100b46:	8a 10                	mov    (%eax),%dl
f0100b48:	80 fa 84             	cmp    $0x84,%dl
f0100b4b:	74 0b                	je     f0100b58 <debuginfo_eip+0x16e>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100b4d:	80 fa 64             	cmp    $0x64,%dl
f0100b50:	75 ec                	jne    f0100b3e <debuginfo_eip+0x154>
f0100b52:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100b56:	74 e6                	je     f0100b3e <debuginfo_eip+0x154>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100b58:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100b5b:	01 c3                	add    %eax,%ebx
f0100b5d:	8b 14 9d 3c 1f 10 f0 	mov    -0xfefe0c4(,%ebx,4),%edx
f0100b64:	b8 7f 73 10 f0       	mov    $0xf010737f,%eax
f0100b69:	2d 4d 5a 10 f0       	sub    $0xf0105a4d,%eax
f0100b6e:	39 c2                	cmp    %eax,%edx
f0100b70:	73 08                	jae    f0100b7a <debuginfo_eip+0x190>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100b72:	81 c2 4d 5a 10 f0    	add    $0xf0105a4d,%edx
f0100b78:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100b7a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100b7d:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100b80:	39 c8                	cmp    %ecx,%eax
f0100b82:	7d 3e                	jge    f0100bc2 <debuginfo_eip+0x1d8>
		for (lline = lfun + 1;
f0100b84:	8d 50 01             	lea    0x1(%eax),%edx
f0100b87:	8d 1c 00             	lea    (%eax,%eax,1),%ebx
f0100b8a:	01 d8                	add    %ebx,%eax
f0100b8c:	8d 04 85 4c 1f 10 f0 	lea    -0xfefe0b4(,%eax,4),%eax
f0100b93:	eb 04                	jmp    f0100b99 <debuginfo_eip+0x1af>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100b95:	ff 46 14             	incl   0x14(%esi)
		     lline++)
f0100b98:	42                   	inc    %edx
		for (lline = lfun + 1;
f0100b99:	39 d1                	cmp    %edx,%ecx
f0100b9b:	74 32                	je     f0100bcf <debuginfo_eip+0x1e5>
f0100b9d:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100ba0:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0100ba4:	74 ef                	je     f0100b95 <debuginfo_eip+0x1ab>

	return 0;
f0100ba6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bab:	eb 1a                	jmp    f0100bc7 <debuginfo_eip+0x1dd>
		return -1;
f0100bad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100bb2:	eb 13                	jmp    f0100bc7 <debuginfo_eip+0x1dd>
f0100bb4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100bb9:	eb 0c                	jmp    f0100bc7 <debuginfo_eip+0x1dd>
		return -1;
f0100bbb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100bc0:	eb 05                	jmp    f0100bc7 <debuginfo_eip+0x1dd>
	return 0;
f0100bc2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100bc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100bca:	5b                   	pop    %ebx
f0100bcb:	5e                   	pop    %esi
f0100bcc:	5f                   	pop    %edi
f0100bcd:	5d                   	pop    %ebp
f0100bce:	c3                   	ret    
	return 0;
f0100bcf:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bd4:	eb f1                	jmp    f0100bc7 <debuginfo_eip+0x1dd>

f0100bd6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100bd6:	55                   	push   %ebp
f0100bd7:	89 e5                	mov    %esp,%ebp
f0100bd9:	57                   	push   %edi
f0100bda:	56                   	push   %esi
f0100bdb:	53                   	push   %ebx
f0100bdc:	83 ec 1c             	sub    $0x1c,%esp
f0100bdf:	89 c7                	mov    %eax,%edi
f0100be1:	89 d6                	mov    %edx,%esi
f0100be3:	8b 45 08             	mov    0x8(%ebp),%eax
f0100be6:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100be9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100bec:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100bef:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100bf2:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100bf7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100bfa:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100bfd:	39 d3                	cmp    %edx,%ebx
f0100bff:	72 05                	jb     f0100c06 <printnum+0x30>
f0100c01:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100c04:	77 78                	ja     f0100c7e <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100c06:	83 ec 0c             	sub    $0xc,%esp
f0100c09:	ff 75 18             	pushl  0x18(%ebp)
f0100c0c:	8b 45 14             	mov    0x14(%ebp),%eax
f0100c0f:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100c12:	53                   	push   %ebx
f0100c13:	ff 75 10             	pushl  0x10(%ebp)
f0100c16:	83 ec 08             	sub    $0x8,%esp
f0100c19:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100c1c:	ff 75 e0             	pushl  -0x20(%ebp)
f0100c1f:	ff 75 dc             	pushl  -0x24(%ebp)
f0100c22:	ff 75 d8             	pushl  -0x28(%ebp)
f0100c25:	e8 a6 09 00 00       	call   f01015d0 <__udivdi3>
f0100c2a:	83 c4 18             	add    $0x18,%esp
f0100c2d:	52                   	push   %edx
f0100c2e:	50                   	push   %eax
f0100c2f:	89 f2                	mov    %esi,%edx
f0100c31:	89 f8                	mov    %edi,%eax
f0100c33:	e8 9e ff ff ff       	call   f0100bd6 <printnum>
f0100c38:	83 c4 20             	add    $0x20,%esp
f0100c3b:	eb 11                	jmp    f0100c4e <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100c3d:	83 ec 08             	sub    $0x8,%esp
f0100c40:	56                   	push   %esi
f0100c41:	ff 75 18             	pushl  0x18(%ebp)
f0100c44:	ff d7                	call   *%edi
f0100c46:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100c49:	4b                   	dec    %ebx
f0100c4a:	85 db                	test   %ebx,%ebx
f0100c4c:	7f ef                	jg     f0100c3d <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100c4e:	83 ec 08             	sub    $0x8,%esp
f0100c51:	56                   	push   %esi
f0100c52:	83 ec 04             	sub    $0x4,%esp
f0100c55:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100c58:	ff 75 e0             	pushl  -0x20(%ebp)
f0100c5b:	ff 75 dc             	pushl  -0x24(%ebp)
f0100c5e:	ff 75 d8             	pushl  -0x28(%ebp)
f0100c61:	e8 6a 0a 00 00       	call   f01016d0 <__umoddi3>
f0100c66:	83 c4 14             	add    $0x14,%esp
f0100c69:	0f be 80 29 1d 10 f0 	movsbl -0xfefe2d7(%eax),%eax
f0100c70:	50                   	push   %eax
f0100c71:	ff d7                	call   *%edi
}
f0100c73:	83 c4 10             	add    $0x10,%esp
f0100c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c79:	5b                   	pop    %ebx
f0100c7a:	5e                   	pop    %esi
f0100c7b:	5f                   	pop    %edi
f0100c7c:	5d                   	pop    %ebp
f0100c7d:	c3                   	ret    
f0100c7e:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100c81:	eb c6                	jmp    f0100c49 <printnum+0x73>

f0100c83 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100c83:	55                   	push   %ebp
f0100c84:	89 e5                	mov    %esp,%ebp
f0100c86:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100c89:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0100c8c:	8b 10                	mov    (%eax),%edx
f0100c8e:	3b 50 04             	cmp    0x4(%eax),%edx
f0100c91:	73 0a                	jae    f0100c9d <sprintputch+0x1a>
		*b->buf++ = ch;
f0100c93:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100c96:	89 08                	mov    %ecx,(%eax)
f0100c98:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c9b:	88 02                	mov    %al,(%edx)
}
f0100c9d:	5d                   	pop    %ebp
f0100c9e:	c3                   	ret    

f0100c9f <printfmt>:
{
f0100c9f:	55                   	push   %ebp
f0100ca0:	89 e5                	mov    %esp,%ebp
f0100ca2:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100ca5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100ca8:	50                   	push   %eax
f0100ca9:	ff 75 10             	pushl  0x10(%ebp)
f0100cac:	ff 75 0c             	pushl  0xc(%ebp)
f0100caf:	ff 75 08             	pushl  0x8(%ebp)
f0100cb2:	e8 05 00 00 00       	call   f0100cbc <vprintfmt>
}
f0100cb7:	83 c4 10             	add    $0x10,%esp
f0100cba:	c9                   	leave  
f0100cbb:	c3                   	ret    

f0100cbc <vprintfmt>:
{
f0100cbc:	55                   	push   %ebp
f0100cbd:	89 e5                	mov    %esp,%ebp
f0100cbf:	57                   	push   %edi
f0100cc0:	56                   	push   %esi
f0100cc1:	53                   	push   %ebx
f0100cc2:	83 ec 2c             	sub    $0x2c,%esp
f0100cc5:	8b 75 08             	mov    0x8(%ebp),%esi
f0100cc8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100ccb:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100cce:	e9 c4 03 00 00       	jmp    f0101097 <vprintfmt+0x3db>
		padc = ' ';
f0100cd3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0100cd7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0100cde:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f0100ce5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0100cec:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0100cf1:	8d 47 01             	lea    0x1(%edi),%eax
f0100cf4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100cf7:	8a 17                	mov    (%edi),%dl
f0100cf9:	8d 42 dd             	lea    -0x23(%edx),%eax
f0100cfc:	3c 55                	cmp    $0x55,%al
f0100cfe:	0f 87 14 04 00 00    	ja     f0101118 <vprintfmt+0x45c>
f0100d04:	0f b6 c0             	movzbl %al,%eax
f0100d07:	ff 24 85 b8 1d 10 f0 	jmp    *-0xfefe248(,%eax,4)
f0100d0e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0100d11:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0100d15:	eb da                	jmp    f0100cf1 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0100d17:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0100d1a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100d1e:	eb d1                	jmp    f0100cf1 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0100d20:	0f b6 d2             	movzbl %dl,%edx
f0100d23:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0100d26:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d2b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0100d2e:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100d31:	01 c0                	add    %eax,%eax
f0100d33:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
f0100d37:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0100d3a:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0100d3d:	83 f9 09             	cmp    $0x9,%ecx
f0100d40:	77 52                	ja     f0100d94 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
f0100d42:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
f0100d43:	eb e9                	jmp    f0100d2e <vprintfmt+0x72>
			precision = va_arg(ap, int);
f0100d45:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d48:	8b 00                	mov    (%eax),%eax
f0100d4a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100d4d:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d50:	8d 40 04             	lea    0x4(%eax),%eax
f0100d53:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100d56:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0100d59:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100d5d:	79 92                	jns    f0100cf1 <vprintfmt+0x35>
				width = precision, precision = -1;
f0100d5f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100d62:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100d65:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100d6c:	eb 83                	jmp    f0100cf1 <vprintfmt+0x35>
f0100d6e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100d72:	78 08                	js     f0100d7c <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
f0100d74:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100d77:	e9 75 ff ff ff       	jmp    f0100cf1 <vprintfmt+0x35>
f0100d7c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0100d83:	eb ef                	jmp    f0100d74 <vprintfmt+0xb8>
f0100d85:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0100d88:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100d8f:	e9 5d ff ff ff       	jmp    f0100cf1 <vprintfmt+0x35>
f0100d94:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100d97:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100d9a:	eb bd                	jmp    f0100d59 <vprintfmt+0x9d>
			lflag++;
f0100d9c:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
f0100d9d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0100da0:	e9 4c ff ff ff       	jmp    f0100cf1 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f0100da5:	8b 45 14             	mov    0x14(%ebp),%eax
f0100da8:	8d 78 04             	lea    0x4(%eax),%edi
f0100dab:	83 ec 08             	sub    $0x8,%esp
f0100dae:	53                   	push   %ebx
f0100daf:	ff 30                	pushl  (%eax)
f0100db1:	ff d6                	call   *%esi
			break;
f0100db3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0100db6:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0100db9:	e9 d6 02 00 00       	jmp    f0101094 <vprintfmt+0x3d8>
			err = va_arg(ap, int);
f0100dbe:	8b 45 14             	mov    0x14(%ebp),%eax
f0100dc1:	8d 78 04             	lea    0x4(%eax),%edi
f0100dc4:	8b 00                	mov    (%eax),%eax
f0100dc6:	85 c0                	test   %eax,%eax
f0100dc8:	78 2a                	js     f0100df4 <vprintfmt+0x138>
f0100dca:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100dcc:	83 f8 06             	cmp    $0x6,%eax
f0100dcf:	7f 27                	jg     f0100df8 <vprintfmt+0x13c>
f0100dd1:	8b 04 85 10 1f 10 f0 	mov    -0xfefe0f0(,%eax,4),%eax
f0100dd8:	85 c0                	test   %eax,%eax
f0100dda:	74 1c                	je     f0100df8 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
f0100ddc:	50                   	push   %eax
f0100ddd:	68 4a 1d 10 f0       	push   $0xf0101d4a
f0100de2:	53                   	push   %ebx
f0100de3:	56                   	push   %esi
f0100de4:	e8 b6 fe ff ff       	call   f0100c9f <printfmt>
f0100de9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100dec:	89 7d 14             	mov    %edi,0x14(%ebp)
f0100def:	e9 a0 02 00 00       	jmp    f0101094 <vprintfmt+0x3d8>
f0100df4:	f7 d8                	neg    %eax
f0100df6:	eb d2                	jmp    f0100dca <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
f0100df8:	52                   	push   %edx
f0100df9:	68 41 1d 10 f0       	push   $0xf0101d41
f0100dfe:	53                   	push   %ebx
f0100dff:	56                   	push   %esi
f0100e00:	e8 9a fe ff ff       	call   f0100c9f <printfmt>
f0100e05:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100e08:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0100e0b:	e9 84 02 00 00       	jmp    f0101094 <vprintfmt+0x3d8>
			if ((p = va_arg(ap, char *)) == NULL)
f0100e10:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e13:	83 c0 04             	add    $0x4,%eax
f0100e16:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100e19:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e1c:	8b 38                	mov    (%eax),%edi
f0100e1e:	85 ff                	test   %edi,%edi
f0100e20:	74 18                	je     f0100e3a <vprintfmt+0x17e>
			if (width > 0 && padc != '-')
f0100e22:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100e26:	0f 8e b7 00 00 00    	jle    f0100ee3 <vprintfmt+0x227>
f0100e2c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100e30:	75 0f                	jne    f0100e41 <vprintfmt+0x185>
f0100e32:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100e35:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100e38:	eb 6e                	jmp    f0100ea8 <vprintfmt+0x1ec>
				p = "(null)";
f0100e3a:	bf 3a 1d 10 f0       	mov    $0xf0101d3a,%edi
f0100e3f:	eb e1                	jmp    f0100e22 <vprintfmt+0x166>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100e41:	83 ec 08             	sub    $0x8,%esp
f0100e44:	ff 75 d0             	pushl  -0x30(%ebp)
f0100e47:	57                   	push   %edi
f0100e48:	e8 5d 04 00 00       	call   f01012aa <strnlen>
f0100e4d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100e50:	29 c1                	sub    %eax,%ecx
f0100e52:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0100e55:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0100e58:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0100e5c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100e5f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100e62:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0100e64:	eb 0d                	jmp    f0100e73 <vprintfmt+0x1b7>
					putch(padc, putdat);
f0100e66:	83 ec 08             	sub    $0x8,%esp
f0100e69:	53                   	push   %ebx
f0100e6a:	ff 75 e0             	pushl  -0x20(%ebp)
f0100e6d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0100e6f:	4f                   	dec    %edi
f0100e70:	83 c4 10             	add    $0x10,%esp
f0100e73:	85 ff                	test   %edi,%edi
f0100e75:	7f ef                	jg     f0100e66 <vprintfmt+0x1aa>
f0100e77:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100e7a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0100e7d:	89 c8                	mov    %ecx,%eax
f0100e7f:	85 c9                	test   %ecx,%ecx
f0100e81:	78 59                	js     f0100edc <vprintfmt+0x220>
f0100e83:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0100e86:	29 c1                	sub    %eax,%ecx
f0100e88:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100e8b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100e8e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100e91:	eb 15                	jmp    f0100ea8 <vprintfmt+0x1ec>
				if (altflag && (ch < ' ' || ch > '~'))
f0100e93:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100e97:	75 29                	jne    f0100ec2 <vprintfmt+0x206>
					putch(ch, putdat);
f0100e99:	83 ec 08             	sub    $0x8,%esp
f0100e9c:	ff 75 0c             	pushl  0xc(%ebp)
f0100e9f:	50                   	push   %eax
f0100ea0:	ff d6                	call   *%esi
f0100ea2:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100ea5:	ff 4d e0             	decl   -0x20(%ebp)
f0100ea8:	47                   	inc    %edi
f0100ea9:	8a 57 ff             	mov    -0x1(%edi),%dl
f0100eac:	0f be c2             	movsbl %dl,%eax
f0100eaf:	85 c0                	test   %eax,%eax
f0100eb1:	74 53                	je     f0100f06 <vprintfmt+0x24a>
f0100eb3:	85 db                	test   %ebx,%ebx
f0100eb5:	78 dc                	js     f0100e93 <vprintfmt+0x1d7>
f0100eb7:	4b                   	dec    %ebx
f0100eb8:	79 d9                	jns    f0100e93 <vprintfmt+0x1d7>
f0100eba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100ebd:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100ec0:	eb 35                	jmp    f0100ef7 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
f0100ec2:	0f be d2             	movsbl %dl,%edx
f0100ec5:	83 ea 20             	sub    $0x20,%edx
f0100ec8:	83 fa 5e             	cmp    $0x5e,%edx
f0100ecb:	76 cc                	jbe    f0100e99 <vprintfmt+0x1dd>
					putch('?', putdat);
f0100ecd:	83 ec 08             	sub    $0x8,%esp
f0100ed0:	ff 75 0c             	pushl  0xc(%ebp)
f0100ed3:	6a 3f                	push   $0x3f
f0100ed5:	ff d6                	call   *%esi
f0100ed7:	83 c4 10             	add    $0x10,%esp
f0100eda:	eb c9                	jmp    f0100ea5 <vprintfmt+0x1e9>
f0100edc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ee1:	eb a0                	jmp    f0100e83 <vprintfmt+0x1c7>
f0100ee3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100ee6:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100ee9:	eb bd                	jmp    f0100ea8 <vprintfmt+0x1ec>
				putch(' ', putdat);
f0100eeb:	83 ec 08             	sub    $0x8,%esp
f0100eee:	53                   	push   %ebx
f0100eef:	6a 20                	push   $0x20
f0100ef1:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0100ef3:	4f                   	dec    %edi
f0100ef4:	83 c4 10             	add    $0x10,%esp
f0100ef7:	85 ff                	test   %edi,%edi
f0100ef9:	7f f0                	jg     f0100eeb <vprintfmt+0x22f>
			if ((p = va_arg(ap, char *)) == NULL)
f0100efb:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0100efe:	89 45 14             	mov    %eax,0x14(%ebp)
f0100f01:	e9 8e 01 00 00       	jmp    f0101094 <vprintfmt+0x3d8>
f0100f06:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100f09:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100f0c:	eb e9                	jmp    f0100ef7 <vprintfmt+0x23b>
	if (lflag >= 2)
f0100f0e:	83 f9 01             	cmp    $0x1,%ecx
f0100f11:	7e 3f                	jle    f0100f52 <vprintfmt+0x296>
		return va_arg(*ap, long long);
f0100f13:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f16:	8b 50 04             	mov    0x4(%eax),%edx
f0100f19:	8b 00                	mov    (%eax),%eax
f0100f1b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f1e:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100f21:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f24:	8d 40 08             	lea    0x8(%eax),%eax
f0100f27:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0100f2a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100f2e:	79 5c                	jns    f0100f8c <vprintfmt+0x2d0>
				putch('-', putdat);
f0100f30:	83 ec 08             	sub    $0x8,%esp
f0100f33:	53                   	push   %ebx
f0100f34:	6a 2d                	push   $0x2d
f0100f36:	ff d6                	call   *%esi
				num = -(long long) num;
f0100f38:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100f3b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100f3e:	f7 da                	neg    %edx
f0100f40:	83 d1 00             	adc    $0x0,%ecx
f0100f43:	f7 d9                	neg    %ecx
f0100f45:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0100f48:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100f4d:	e9 28 01 00 00       	jmp    f010107a <vprintfmt+0x3be>
	else if (lflag)
f0100f52:	85 c9                	test   %ecx,%ecx
f0100f54:	75 1b                	jne    f0100f71 <vprintfmt+0x2b5>
		return va_arg(*ap, int);
f0100f56:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f59:	8b 00                	mov    (%eax),%eax
f0100f5b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f5e:	89 c1                	mov    %eax,%ecx
f0100f60:	c1 f9 1f             	sar    $0x1f,%ecx
f0100f63:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100f66:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f69:	8d 40 04             	lea    0x4(%eax),%eax
f0100f6c:	89 45 14             	mov    %eax,0x14(%ebp)
f0100f6f:	eb b9                	jmp    f0100f2a <vprintfmt+0x26e>
		return va_arg(*ap, long);
f0100f71:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f74:	8b 00                	mov    (%eax),%eax
f0100f76:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f79:	89 c1                	mov    %eax,%ecx
f0100f7b:	c1 f9 1f             	sar    $0x1f,%ecx
f0100f7e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100f81:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f84:	8d 40 04             	lea    0x4(%eax),%eax
f0100f87:	89 45 14             	mov    %eax,0x14(%ebp)
f0100f8a:	eb 9e                	jmp    f0100f2a <vprintfmt+0x26e>
			num = getint(&ap, lflag);
f0100f8c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100f8f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0100f92:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100f97:	e9 de 00 00 00       	jmp    f010107a <vprintfmt+0x3be>
	if (lflag >= 2)
f0100f9c:	83 f9 01             	cmp    $0x1,%ecx
f0100f9f:	7e 18                	jle    f0100fb9 <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
f0100fa1:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fa4:	8b 10                	mov    (%eax),%edx
f0100fa6:	8b 48 04             	mov    0x4(%eax),%ecx
f0100fa9:	8d 40 08             	lea    0x8(%eax),%eax
f0100fac:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0100faf:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100fb4:	e9 c1 00 00 00       	jmp    f010107a <vprintfmt+0x3be>
	else if (lflag)
f0100fb9:	85 c9                	test   %ecx,%ecx
f0100fbb:	75 1a                	jne    f0100fd7 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned int);
f0100fbd:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fc0:	8b 10                	mov    (%eax),%edx
f0100fc2:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100fc7:	8d 40 04             	lea    0x4(%eax),%eax
f0100fca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0100fcd:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100fd2:	e9 a3 00 00 00       	jmp    f010107a <vprintfmt+0x3be>
		return va_arg(*ap, unsigned long);
f0100fd7:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fda:	8b 10                	mov    (%eax),%edx
f0100fdc:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100fe1:	8d 40 04             	lea    0x4(%eax),%eax
f0100fe4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0100fe7:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100fec:	e9 89 00 00 00       	jmp    f010107a <vprintfmt+0x3be>
	if (lflag >= 2)
f0100ff1:	83 f9 01             	cmp    $0x1,%ecx
f0100ff4:	7e 2e                	jle    f0101024 <vprintfmt+0x368>
		return va_arg(*ap, unsigned long long);
f0100ff6:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ff9:	8b 50 04             	mov    0x4(%eax),%edx
f0100ffc:	8b 00                	mov    (%eax),%eax
f0100ffe:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0101001:	8d 49 08             	lea    0x8(%ecx),%ecx
f0101004:	89 4d 14             	mov    %ecx,0x14(%ebp)
			printnum(putch, putdat, num, base, width, padc);
f0101007:	83 ec 0c             	sub    $0xc,%esp
f010100a:	0f be 4d d4          	movsbl -0x2c(%ebp),%ecx
f010100e:	51                   	push   %ecx
f010100f:	ff 75 e0             	pushl  -0x20(%ebp)
f0101012:	6a 08                	push   $0x8
f0101014:	52                   	push   %edx
f0101015:	50                   	push   %eax
f0101016:	89 da                	mov    %ebx,%edx
f0101018:	89 f0                	mov    %esi,%eax
f010101a:	e8 b7 fb ff ff       	call   f0100bd6 <printnum>
			break;
f010101f:	83 c4 20             	add    $0x20,%esp
f0101022:	eb 70                	jmp    f0101094 <vprintfmt+0x3d8>
	else if (lflag)
f0101024:	85 c9                	test   %ecx,%ecx
f0101026:	75 15                	jne    f010103d <vprintfmt+0x381>
		return va_arg(*ap, unsigned int);
f0101028:	8b 45 14             	mov    0x14(%ebp),%eax
f010102b:	8b 00                	mov    (%eax),%eax
f010102d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101032:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0101035:	8d 49 04             	lea    0x4(%ecx),%ecx
f0101038:	89 4d 14             	mov    %ecx,0x14(%ebp)
f010103b:	eb ca                	jmp    f0101007 <vprintfmt+0x34b>
		return va_arg(*ap, unsigned long);
f010103d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101040:	8b 00                	mov    (%eax),%eax
f0101042:	ba 00 00 00 00       	mov    $0x0,%edx
f0101047:	8b 4d 14             	mov    0x14(%ebp),%ecx
f010104a:	8d 49 04             	lea    0x4(%ecx),%ecx
f010104d:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0101050:	eb b5                	jmp    f0101007 <vprintfmt+0x34b>
			putch('0', putdat);
f0101052:	83 ec 08             	sub    $0x8,%esp
f0101055:	53                   	push   %ebx
f0101056:	6a 30                	push   $0x30
f0101058:	ff d6                	call   *%esi
			putch('x', putdat);
f010105a:	83 c4 08             	add    $0x8,%esp
f010105d:	53                   	push   %ebx
f010105e:	6a 78                	push   $0x78
f0101060:	ff d6                	call   *%esi
			num = (unsigned long long)
f0101062:	8b 45 14             	mov    0x14(%ebp),%eax
f0101065:	8b 10                	mov    (%eax),%edx
f0101067:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010106c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010106f:	8d 40 04             	lea    0x4(%eax),%eax
f0101072:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101075:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f010107a:	83 ec 0c             	sub    $0xc,%esp
f010107d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0101081:	57                   	push   %edi
f0101082:	ff 75 e0             	pushl  -0x20(%ebp)
f0101085:	50                   	push   %eax
f0101086:	51                   	push   %ecx
f0101087:	52                   	push   %edx
f0101088:	89 da                	mov    %ebx,%edx
f010108a:	89 f0                	mov    %esi,%eax
f010108c:	e8 45 fb ff ff       	call   f0100bd6 <printnum>
			break;
f0101091:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0101094:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101097:	47                   	inc    %edi
f0101098:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010109c:	83 f8 25             	cmp    $0x25,%eax
f010109f:	0f 84 2e fc ff ff    	je     f0100cd3 <vprintfmt+0x17>
			if (ch == '\0')
f01010a5:	85 c0                	test   %eax,%eax
f01010a7:	0f 84 89 00 00 00    	je     f0101136 <vprintfmt+0x47a>
			putch(ch, putdat);
f01010ad:	83 ec 08             	sub    $0x8,%esp
f01010b0:	53                   	push   %ebx
f01010b1:	50                   	push   %eax
f01010b2:	ff d6                	call   *%esi
f01010b4:	83 c4 10             	add    $0x10,%esp
f01010b7:	eb de                	jmp    f0101097 <vprintfmt+0x3db>
	if (lflag >= 2)
f01010b9:	83 f9 01             	cmp    $0x1,%ecx
f01010bc:	7e 15                	jle    f01010d3 <vprintfmt+0x417>
		return va_arg(*ap, unsigned long long);
f01010be:	8b 45 14             	mov    0x14(%ebp),%eax
f01010c1:	8b 10                	mov    (%eax),%edx
f01010c3:	8b 48 04             	mov    0x4(%eax),%ecx
f01010c6:	8d 40 08             	lea    0x8(%eax),%eax
f01010c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01010cc:	b8 10 00 00 00       	mov    $0x10,%eax
f01010d1:	eb a7                	jmp    f010107a <vprintfmt+0x3be>
	else if (lflag)
f01010d3:	85 c9                	test   %ecx,%ecx
f01010d5:	75 17                	jne    f01010ee <vprintfmt+0x432>
		return va_arg(*ap, unsigned int);
f01010d7:	8b 45 14             	mov    0x14(%ebp),%eax
f01010da:	8b 10                	mov    (%eax),%edx
f01010dc:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010e1:	8d 40 04             	lea    0x4(%eax),%eax
f01010e4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01010e7:	b8 10 00 00 00       	mov    $0x10,%eax
f01010ec:	eb 8c                	jmp    f010107a <vprintfmt+0x3be>
		return va_arg(*ap, unsigned long);
f01010ee:	8b 45 14             	mov    0x14(%ebp),%eax
f01010f1:	8b 10                	mov    (%eax),%edx
f01010f3:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010f8:	8d 40 04             	lea    0x4(%eax),%eax
f01010fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01010fe:	b8 10 00 00 00       	mov    $0x10,%eax
f0101103:	e9 72 ff ff ff       	jmp    f010107a <vprintfmt+0x3be>
			putch(ch, putdat);
f0101108:	83 ec 08             	sub    $0x8,%esp
f010110b:	53                   	push   %ebx
f010110c:	6a 25                	push   $0x25
f010110e:	ff d6                	call   *%esi
			break;
f0101110:	83 c4 10             	add    $0x10,%esp
f0101113:	e9 7c ff ff ff       	jmp    f0101094 <vprintfmt+0x3d8>
			putch('%', putdat);
f0101118:	83 ec 08             	sub    $0x8,%esp
f010111b:	53                   	push   %ebx
f010111c:	6a 25                	push   $0x25
f010111e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101120:	83 c4 10             	add    $0x10,%esp
f0101123:	89 f8                	mov    %edi,%eax
f0101125:	eb 01                	jmp    f0101128 <vprintfmt+0x46c>
f0101127:	48                   	dec    %eax
f0101128:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010112c:	75 f9                	jne    f0101127 <vprintfmt+0x46b>
f010112e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101131:	e9 5e ff ff ff       	jmp    f0101094 <vprintfmt+0x3d8>
}
f0101136:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101139:	5b                   	pop    %ebx
f010113a:	5e                   	pop    %esi
f010113b:	5f                   	pop    %edi
f010113c:	5d                   	pop    %ebp
f010113d:	c3                   	ret    

f010113e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010113e:	55                   	push   %ebp
f010113f:	89 e5                	mov    %esp,%ebp
f0101141:	83 ec 18             	sub    $0x18,%esp
f0101144:	8b 45 08             	mov    0x8(%ebp),%eax
f0101147:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010114a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010114d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101151:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101154:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010115b:	85 c0                	test   %eax,%eax
f010115d:	74 26                	je     f0101185 <vsnprintf+0x47>
f010115f:	85 d2                	test   %edx,%edx
f0101161:	7e 29                	jle    f010118c <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101163:	ff 75 14             	pushl  0x14(%ebp)
f0101166:	ff 75 10             	pushl  0x10(%ebp)
f0101169:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010116c:	50                   	push   %eax
f010116d:	68 83 0c 10 f0       	push   $0xf0100c83
f0101172:	e8 45 fb ff ff       	call   f0100cbc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101177:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010117a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010117d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101180:	83 c4 10             	add    $0x10,%esp
}
f0101183:	c9                   	leave  
f0101184:	c3                   	ret    
		return -E_INVAL;
f0101185:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010118a:	eb f7                	jmp    f0101183 <vsnprintf+0x45>
f010118c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101191:	eb f0                	jmp    f0101183 <vsnprintf+0x45>

f0101193 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101193:	55                   	push   %ebp
f0101194:	89 e5                	mov    %esp,%ebp
f0101196:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101199:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010119c:	50                   	push   %eax
f010119d:	ff 75 10             	pushl  0x10(%ebp)
f01011a0:	ff 75 0c             	pushl  0xc(%ebp)
f01011a3:	ff 75 08             	pushl  0x8(%ebp)
f01011a6:	e8 93 ff ff ff       	call   f010113e <vsnprintf>
	va_end(ap);

	return rc;
}
f01011ab:	c9                   	leave  
f01011ac:	c3                   	ret    

f01011ad <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01011ad:	55                   	push   %ebp
f01011ae:	89 e5                	mov    %esp,%ebp
f01011b0:	57                   	push   %edi
f01011b1:	56                   	push   %esi
f01011b2:	53                   	push   %ebx
f01011b3:	83 ec 0c             	sub    $0xc,%esp
f01011b6:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01011b9:	85 c0                	test   %eax,%eax
f01011bb:	74 11                	je     f01011ce <readline+0x21>
		cprintf("%s", prompt);
f01011bd:	83 ec 08             	sub    $0x8,%esp
f01011c0:	50                   	push   %eax
f01011c1:	68 4a 1d 10 f0       	push   $0xf0101d4a
f01011c6:	e8 1e f7 ff ff       	call   f01008e9 <cprintf>
f01011cb:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01011ce:	83 ec 0c             	sub    $0xc,%esp
f01011d1:	6a 00                	push   $0x0
f01011d3:	e8 8f f4 ff ff       	call   f0100667 <iscons>
f01011d8:	89 c7                	mov    %eax,%edi
f01011da:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01011dd:	be 00 00 00 00       	mov    $0x0,%esi
f01011e2:	eb 6f                	jmp    f0101253 <readline+0xa6>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01011e4:	83 ec 08             	sub    $0x8,%esp
f01011e7:	50                   	push   %eax
f01011e8:	68 2c 1f 10 f0       	push   $0xf0101f2c
f01011ed:	e8 f7 f6 ff ff       	call   f01008e9 <cprintf>
			return NULL;
f01011f2:	83 c4 10             	add    $0x10,%esp
f01011f5:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01011fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011fd:	5b                   	pop    %ebx
f01011fe:	5e                   	pop    %esi
f01011ff:	5f                   	pop    %edi
f0101200:	5d                   	pop    %ebp
f0101201:	c3                   	ret    
				cputchar('\b');
f0101202:	83 ec 0c             	sub    $0xc,%esp
f0101205:	6a 08                	push   $0x8
f0101207:	e8 3a f4 ff ff       	call   f0100646 <cputchar>
f010120c:	83 c4 10             	add    $0x10,%esp
f010120f:	eb 41                	jmp    f0101252 <readline+0xa5>
				cputchar(c);
f0101211:	83 ec 0c             	sub    $0xc,%esp
f0101214:	53                   	push   %ebx
f0101215:	e8 2c f4 ff ff       	call   f0100646 <cputchar>
f010121a:	83 c4 10             	add    $0x10,%esp
f010121d:	eb 5a                	jmp    f0101279 <readline+0xcc>
		} else if (c == '\n' || c == '\r') {
f010121f:	83 fb 0a             	cmp    $0xa,%ebx
f0101222:	74 05                	je     f0101229 <readline+0x7c>
f0101224:	83 fb 0d             	cmp    $0xd,%ebx
f0101227:	75 2a                	jne    f0101253 <readline+0xa6>
			if (echoing)
f0101229:	85 ff                	test   %edi,%edi
f010122b:	75 0e                	jne    f010123b <readline+0x8e>
			buf[i] = 0;
f010122d:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f0101234:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
f0101239:	eb bf                	jmp    f01011fa <readline+0x4d>
				cputchar('\n');
f010123b:	83 ec 0c             	sub    $0xc,%esp
f010123e:	6a 0a                	push   $0xa
f0101240:	e8 01 f4 ff ff       	call   f0100646 <cputchar>
f0101245:	83 c4 10             	add    $0x10,%esp
f0101248:	eb e3                	jmp    f010122d <readline+0x80>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010124a:	85 f6                	test   %esi,%esi
f010124c:	7e 3c                	jle    f010128a <readline+0xdd>
			if (echoing)
f010124e:	85 ff                	test   %edi,%edi
f0101250:	75 b0                	jne    f0101202 <readline+0x55>
			i--;
f0101252:	4e                   	dec    %esi
		c = getchar();
f0101253:	e8 fe f3 ff ff       	call   f0100656 <getchar>
f0101258:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010125a:	85 c0                	test   %eax,%eax
f010125c:	78 86                	js     f01011e4 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010125e:	83 f8 08             	cmp    $0x8,%eax
f0101261:	74 21                	je     f0101284 <readline+0xd7>
f0101263:	83 f8 7f             	cmp    $0x7f,%eax
f0101266:	74 e2                	je     f010124a <readline+0x9d>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101268:	83 f8 1f             	cmp    $0x1f,%eax
f010126b:	7e b2                	jle    f010121f <readline+0x72>
f010126d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101273:	7f aa                	jg     f010121f <readline+0x72>
			if (echoing)
f0101275:	85 ff                	test   %edi,%edi
f0101277:	75 98                	jne    f0101211 <readline+0x64>
			buf[i++] = c;
f0101279:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f010127f:	8d 76 01             	lea    0x1(%esi),%esi
f0101282:	eb cf                	jmp    f0101253 <readline+0xa6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101284:	85 f6                	test   %esi,%esi
f0101286:	7e cb                	jle    f0101253 <readline+0xa6>
f0101288:	eb c4                	jmp    f010124e <readline+0xa1>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010128a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101290:	7e e3                	jle    f0101275 <readline+0xc8>
f0101292:	eb bf                	jmp    f0101253 <readline+0xa6>

f0101294 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101294:	55                   	push   %ebp
f0101295:	89 e5                	mov    %esp,%ebp
f0101297:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010129a:	b8 00 00 00 00       	mov    $0x0,%eax
f010129f:	eb 01                	jmp    f01012a2 <strlen+0xe>
		n++;
f01012a1:	40                   	inc    %eax
	for (n = 0; *s != '\0'; s++)
f01012a2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01012a6:	75 f9                	jne    f01012a1 <strlen+0xd>
	return n;
}
f01012a8:	5d                   	pop    %ebp
f01012a9:	c3                   	ret    

f01012aa <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01012aa:	55                   	push   %ebp
f01012ab:	89 e5                	mov    %esp,%ebp
f01012ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01012b0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012b3:	b8 00 00 00 00       	mov    $0x0,%eax
f01012b8:	eb 01                	jmp    f01012bb <strnlen+0x11>
		n++;
f01012ba:	40                   	inc    %eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012bb:	39 d0                	cmp    %edx,%eax
f01012bd:	74 06                	je     f01012c5 <strnlen+0x1b>
f01012bf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01012c3:	75 f5                	jne    f01012ba <strnlen+0x10>
	return n;
}
f01012c5:	5d                   	pop    %ebp
f01012c6:	c3                   	ret    

f01012c7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01012c7:	55                   	push   %ebp
f01012c8:	89 e5                	mov    %esp,%ebp
f01012ca:	53                   	push   %ebx
f01012cb:	8b 45 08             	mov    0x8(%ebp),%eax
f01012ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01012d1:	89 c2                	mov    %eax,%edx
f01012d3:	41                   	inc    %ecx
f01012d4:	42                   	inc    %edx
f01012d5:	8a 59 ff             	mov    -0x1(%ecx),%bl
f01012d8:	88 5a ff             	mov    %bl,-0x1(%edx)
f01012db:	84 db                	test   %bl,%bl
f01012dd:	75 f4                	jne    f01012d3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01012df:	5b                   	pop    %ebx
f01012e0:	5d                   	pop    %ebp
f01012e1:	c3                   	ret    

f01012e2 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01012e2:	55                   	push   %ebp
f01012e3:	89 e5                	mov    %esp,%ebp
f01012e5:	53                   	push   %ebx
f01012e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01012e9:	53                   	push   %ebx
f01012ea:	e8 a5 ff ff ff       	call   f0101294 <strlen>
f01012ef:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01012f2:	ff 75 0c             	pushl  0xc(%ebp)
f01012f5:	01 d8                	add    %ebx,%eax
f01012f7:	50                   	push   %eax
f01012f8:	e8 ca ff ff ff       	call   f01012c7 <strcpy>
	return dst;
}
f01012fd:	89 d8                	mov    %ebx,%eax
f01012ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101302:	c9                   	leave  
f0101303:	c3                   	ret    

f0101304 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101304:	55                   	push   %ebp
f0101305:	89 e5                	mov    %esp,%ebp
f0101307:	56                   	push   %esi
f0101308:	53                   	push   %ebx
f0101309:	8b 75 08             	mov    0x8(%ebp),%esi
f010130c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010130f:	89 f3                	mov    %esi,%ebx
f0101311:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101314:	89 f2                	mov    %esi,%edx
f0101316:	39 da                	cmp    %ebx,%edx
f0101318:	74 0e                	je     f0101328 <strncpy+0x24>
		*dst++ = *src;
f010131a:	42                   	inc    %edx
f010131b:	8a 01                	mov    (%ecx),%al
f010131d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f0101320:	80 39 00             	cmpb   $0x0,(%ecx)
f0101323:	74 f1                	je     f0101316 <strncpy+0x12>
			src++;
f0101325:	41                   	inc    %ecx
f0101326:	eb ee                	jmp    f0101316 <strncpy+0x12>
	}
	return ret;
}
f0101328:	89 f0                	mov    %esi,%eax
f010132a:	5b                   	pop    %ebx
f010132b:	5e                   	pop    %esi
f010132c:	5d                   	pop    %ebp
f010132d:	c3                   	ret    

f010132e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010132e:	55                   	push   %ebp
f010132f:	89 e5                	mov    %esp,%ebp
f0101331:	56                   	push   %esi
f0101332:	53                   	push   %ebx
f0101333:	8b 75 08             	mov    0x8(%ebp),%esi
f0101336:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101339:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010133c:	85 c0                	test   %eax,%eax
f010133e:	74 20                	je     f0101360 <strlcpy+0x32>
f0101340:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
f0101344:	89 f0                	mov    %esi,%eax
f0101346:	eb 05                	jmp    f010134d <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101348:	42                   	inc    %edx
f0101349:	40                   	inc    %eax
f010134a:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f010134d:	39 d8                	cmp    %ebx,%eax
f010134f:	74 06                	je     f0101357 <strlcpy+0x29>
f0101351:	8a 0a                	mov    (%edx),%cl
f0101353:	84 c9                	test   %cl,%cl
f0101355:	75 f1                	jne    f0101348 <strlcpy+0x1a>
		*dst = '\0';
f0101357:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010135a:	29 f0                	sub    %esi,%eax
}
f010135c:	5b                   	pop    %ebx
f010135d:	5e                   	pop    %esi
f010135e:	5d                   	pop    %ebp
f010135f:	c3                   	ret    
f0101360:	89 f0                	mov    %esi,%eax
f0101362:	eb f6                	jmp    f010135a <strlcpy+0x2c>

f0101364 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101364:	55                   	push   %ebp
f0101365:	89 e5                	mov    %esp,%ebp
f0101367:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010136a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010136d:	eb 02                	jmp    f0101371 <strcmp+0xd>
		p++, q++;
f010136f:	41                   	inc    %ecx
f0101370:	42                   	inc    %edx
	while (*p && *p == *q)
f0101371:	8a 01                	mov    (%ecx),%al
f0101373:	84 c0                	test   %al,%al
f0101375:	74 04                	je     f010137b <strcmp+0x17>
f0101377:	3a 02                	cmp    (%edx),%al
f0101379:	74 f4                	je     f010136f <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010137b:	0f b6 c0             	movzbl %al,%eax
f010137e:	0f b6 12             	movzbl (%edx),%edx
f0101381:	29 d0                	sub    %edx,%eax
}
f0101383:	5d                   	pop    %ebp
f0101384:	c3                   	ret    

f0101385 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101385:	55                   	push   %ebp
f0101386:	89 e5                	mov    %esp,%ebp
f0101388:	53                   	push   %ebx
f0101389:	8b 45 08             	mov    0x8(%ebp),%eax
f010138c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010138f:	89 c3                	mov    %eax,%ebx
f0101391:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101394:	eb 02                	jmp    f0101398 <strncmp+0x13>
		n--, p++, q++;
f0101396:	40                   	inc    %eax
f0101397:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
f0101398:	39 d8                	cmp    %ebx,%eax
f010139a:	74 15                	je     f01013b1 <strncmp+0x2c>
f010139c:	8a 08                	mov    (%eax),%cl
f010139e:	84 c9                	test   %cl,%cl
f01013a0:	74 04                	je     f01013a6 <strncmp+0x21>
f01013a2:	3a 0a                	cmp    (%edx),%cl
f01013a4:	74 f0                	je     f0101396 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01013a6:	0f b6 00             	movzbl (%eax),%eax
f01013a9:	0f b6 12             	movzbl (%edx),%edx
f01013ac:	29 d0                	sub    %edx,%eax
}
f01013ae:	5b                   	pop    %ebx
f01013af:	5d                   	pop    %ebp
f01013b0:	c3                   	ret    
		return 0;
f01013b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01013b6:	eb f6                	jmp    f01013ae <strncmp+0x29>

f01013b8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01013b8:	55                   	push   %ebp
f01013b9:	89 e5                	mov    %esp,%ebp
f01013bb:	8b 45 08             	mov    0x8(%ebp),%eax
f01013be:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01013c1:	8a 10                	mov    (%eax),%dl
f01013c3:	84 d2                	test   %dl,%dl
f01013c5:	74 07                	je     f01013ce <strchr+0x16>
		if (*s == c)
f01013c7:	38 ca                	cmp    %cl,%dl
f01013c9:	74 08                	je     f01013d3 <strchr+0x1b>
	for (; *s; s++)
f01013cb:	40                   	inc    %eax
f01013cc:	eb f3                	jmp    f01013c1 <strchr+0x9>
			return (char *) s;
	return 0;
f01013ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01013d3:	5d                   	pop    %ebp
f01013d4:	c3                   	ret    

f01013d5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01013d5:	55                   	push   %ebp
f01013d6:	89 e5                	mov    %esp,%ebp
f01013d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01013db:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01013de:	8a 10                	mov    (%eax),%dl
f01013e0:	84 d2                	test   %dl,%dl
f01013e2:	74 07                	je     f01013eb <strfind+0x16>
		if (*s == c)
f01013e4:	38 ca                	cmp    %cl,%dl
f01013e6:	74 03                	je     f01013eb <strfind+0x16>
	for (; *s; s++)
f01013e8:	40                   	inc    %eax
f01013e9:	eb f3                	jmp    f01013de <strfind+0x9>
			break;
	return (char *) s;
}
f01013eb:	5d                   	pop    %ebp
f01013ec:	c3                   	ret    

f01013ed <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01013ed:	55                   	push   %ebp
f01013ee:	89 e5                	mov    %esp,%ebp
f01013f0:	57                   	push   %edi
f01013f1:	56                   	push   %esi
f01013f2:	53                   	push   %ebx
f01013f3:	8b 7d 08             	mov    0x8(%ebp),%edi
f01013f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01013f9:	85 c9                	test   %ecx,%ecx
f01013fb:	74 13                	je     f0101410 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01013fd:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101403:	75 05                	jne    f010140a <memset+0x1d>
f0101405:	f6 c1 03             	test   $0x3,%cl
f0101408:	74 0d                	je     f0101417 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010140a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010140d:	fc                   	cld    
f010140e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101410:	89 f8                	mov    %edi,%eax
f0101412:	5b                   	pop    %ebx
f0101413:	5e                   	pop    %esi
f0101414:	5f                   	pop    %edi
f0101415:	5d                   	pop    %ebp
f0101416:	c3                   	ret    
		c &= 0xFF;
f0101417:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010141b:	89 d3                	mov    %edx,%ebx
f010141d:	c1 e3 08             	shl    $0x8,%ebx
f0101420:	89 d0                	mov    %edx,%eax
f0101422:	c1 e0 18             	shl    $0x18,%eax
f0101425:	89 d6                	mov    %edx,%esi
f0101427:	c1 e6 10             	shl    $0x10,%esi
f010142a:	09 f0                	or     %esi,%eax
f010142c:	09 c2                	or     %eax,%edx
f010142e:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0101430:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0101433:	89 d0                	mov    %edx,%eax
f0101435:	fc                   	cld    
f0101436:	f3 ab                	rep stos %eax,%es:(%edi)
f0101438:	eb d6                	jmp    f0101410 <memset+0x23>

f010143a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010143a:	55                   	push   %ebp
f010143b:	89 e5                	mov    %esp,%ebp
f010143d:	57                   	push   %edi
f010143e:	56                   	push   %esi
f010143f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101442:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101445:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101448:	39 c6                	cmp    %eax,%esi
f010144a:	73 33                	jae    f010147f <memmove+0x45>
f010144c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010144f:	39 c2                	cmp    %eax,%edx
f0101451:	76 2c                	jbe    f010147f <memmove+0x45>
		s += n;
		d += n;
f0101453:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101456:	89 d6                	mov    %edx,%esi
f0101458:	09 fe                	or     %edi,%esi
f010145a:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101460:	74 0a                	je     f010146c <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101462:	4f                   	dec    %edi
f0101463:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0101466:	fd                   	std    
f0101467:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101469:	fc                   	cld    
f010146a:	eb 21                	jmp    f010148d <memmove+0x53>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010146c:	f6 c1 03             	test   $0x3,%cl
f010146f:	75 f1                	jne    f0101462 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101471:	83 ef 04             	sub    $0x4,%edi
f0101474:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101477:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f010147a:	fd                   	std    
f010147b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010147d:	eb ea                	jmp    f0101469 <memmove+0x2f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010147f:	89 f2                	mov    %esi,%edx
f0101481:	09 c2                	or     %eax,%edx
f0101483:	f6 c2 03             	test   $0x3,%dl
f0101486:	74 09                	je     f0101491 <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101488:	89 c7                	mov    %eax,%edi
f010148a:	fc                   	cld    
f010148b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010148d:	5e                   	pop    %esi
f010148e:	5f                   	pop    %edi
f010148f:	5d                   	pop    %ebp
f0101490:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101491:	f6 c1 03             	test   $0x3,%cl
f0101494:	75 f2                	jne    f0101488 <memmove+0x4e>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101496:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0101499:	89 c7                	mov    %eax,%edi
f010149b:	fc                   	cld    
f010149c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010149e:	eb ed                	jmp    f010148d <memmove+0x53>

f01014a0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01014a0:	55                   	push   %ebp
f01014a1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01014a3:	ff 75 10             	pushl  0x10(%ebp)
f01014a6:	ff 75 0c             	pushl  0xc(%ebp)
f01014a9:	ff 75 08             	pushl  0x8(%ebp)
f01014ac:	e8 89 ff ff ff       	call   f010143a <memmove>
}
f01014b1:	c9                   	leave  
f01014b2:	c3                   	ret    

f01014b3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01014b3:	55                   	push   %ebp
f01014b4:	89 e5                	mov    %esp,%ebp
f01014b6:	56                   	push   %esi
f01014b7:	53                   	push   %ebx
f01014b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01014bb:	8b 55 0c             	mov    0xc(%ebp),%edx
f01014be:	89 c6                	mov    %eax,%esi
f01014c0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01014c3:	39 f0                	cmp    %esi,%eax
f01014c5:	74 16                	je     f01014dd <memcmp+0x2a>
		if (*s1 != *s2)
f01014c7:	8a 08                	mov    (%eax),%cl
f01014c9:	8a 1a                	mov    (%edx),%bl
f01014cb:	38 d9                	cmp    %bl,%cl
f01014cd:	75 04                	jne    f01014d3 <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01014cf:	40                   	inc    %eax
f01014d0:	42                   	inc    %edx
f01014d1:	eb f0                	jmp    f01014c3 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f01014d3:	0f b6 c1             	movzbl %cl,%eax
f01014d6:	0f b6 db             	movzbl %bl,%ebx
f01014d9:	29 d8                	sub    %ebx,%eax
f01014db:	eb 05                	jmp    f01014e2 <memcmp+0x2f>
	}

	return 0;
f01014dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01014e2:	5b                   	pop    %ebx
f01014e3:	5e                   	pop    %esi
f01014e4:	5d                   	pop    %ebp
f01014e5:	c3                   	ret    

f01014e6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01014e6:	55                   	push   %ebp
f01014e7:	89 e5                	mov    %esp,%ebp
f01014e9:	8b 45 08             	mov    0x8(%ebp),%eax
f01014ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01014ef:	89 c2                	mov    %eax,%edx
f01014f1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01014f4:	39 d0                	cmp    %edx,%eax
f01014f6:	73 07                	jae    f01014ff <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
f01014f8:	38 08                	cmp    %cl,(%eax)
f01014fa:	74 03                	je     f01014ff <memfind+0x19>
	for (; s < ends; s++)
f01014fc:	40                   	inc    %eax
f01014fd:	eb f5                	jmp    f01014f4 <memfind+0xe>
			break;
	return (void *) s;
}
f01014ff:	5d                   	pop    %ebp
f0101500:	c3                   	ret    

f0101501 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101501:	55                   	push   %ebp
f0101502:	89 e5                	mov    %esp,%ebp
f0101504:	57                   	push   %edi
f0101505:	56                   	push   %esi
f0101506:	53                   	push   %ebx
f0101507:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010150a:	eb 01                	jmp    f010150d <strtol+0xc>
		s++;
f010150c:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f010150d:	8a 01                	mov    (%ecx),%al
f010150f:	3c 20                	cmp    $0x20,%al
f0101511:	74 f9                	je     f010150c <strtol+0xb>
f0101513:	3c 09                	cmp    $0x9,%al
f0101515:	74 f5                	je     f010150c <strtol+0xb>

	// plus/minus sign
	if (*s == '+')
f0101517:	3c 2b                	cmp    $0x2b,%al
f0101519:	74 2b                	je     f0101546 <strtol+0x45>
		s++;
	else if (*s == '-')
f010151b:	3c 2d                	cmp    $0x2d,%al
f010151d:	74 2f                	je     f010154e <strtol+0x4d>
	int neg = 0;
f010151f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101524:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f010152b:	75 12                	jne    f010153f <strtol+0x3e>
f010152d:	80 39 30             	cmpb   $0x30,(%ecx)
f0101530:	74 24                	je     f0101556 <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101532:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101536:	75 07                	jne    f010153f <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101538:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f010153f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101544:	eb 4e                	jmp    f0101594 <strtol+0x93>
		s++;
f0101546:	41                   	inc    %ecx
	int neg = 0;
f0101547:	bf 00 00 00 00       	mov    $0x0,%edi
f010154c:	eb d6                	jmp    f0101524 <strtol+0x23>
		s++, neg = 1;
f010154e:	41                   	inc    %ecx
f010154f:	bf 01 00 00 00       	mov    $0x1,%edi
f0101554:	eb ce                	jmp    f0101524 <strtol+0x23>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101556:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010155a:	74 10                	je     f010156c <strtol+0x6b>
	else if (base == 0 && s[0] == '0')
f010155c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101560:	75 dd                	jne    f010153f <strtol+0x3e>
		s++, base = 8;
f0101562:	41                   	inc    %ecx
f0101563:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f010156a:	eb d3                	jmp    f010153f <strtol+0x3e>
		s += 2, base = 16;
f010156c:	83 c1 02             	add    $0x2,%ecx
f010156f:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f0101576:	eb c7                	jmp    f010153f <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0101578:	8d 72 9f             	lea    -0x61(%edx),%esi
f010157b:	89 f3                	mov    %esi,%ebx
f010157d:	80 fb 19             	cmp    $0x19,%bl
f0101580:	77 24                	ja     f01015a6 <strtol+0xa5>
			dig = *s - 'a' + 10;
f0101582:	0f be d2             	movsbl %dl,%edx
f0101585:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101588:	3b 55 10             	cmp    0x10(%ebp),%edx
f010158b:	7d 2b                	jge    f01015b8 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
f010158d:	41                   	inc    %ecx
f010158e:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101592:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0101594:	8a 11                	mov    (%ecx),%dl
f0101596:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0101599:	80 fb 09             	cmp    $0x9,%bl
f010159c:	77 da                	ja     f0101578 <strtol+0x77>
			dig = *s - '0';
f010159e:	0f be d2             	movsbl %dl,%edx
f01015a1:	83 ea 30             	sub    $0x30,%edx
f01015a4:	eb e2                	jmp    f0101588 <strtol+0x87>
		else if (*s >= 'A' && *s <= 'Z')
f01015a6:	8d 72 bf             	lea    -0x41(%edx),%esi
f01015a9:	89 f3                	mov    %esi,%ebx
f01015ab:	80 fb 19             	cmp    $0x19,%bl
f01015ae:	77 08                	ja     f01015b8 <strtol+0xb7>
			dig = *s - 'A' + 10;
f01015b0:	0f be d2             	movsbl %dl,%edx
f01015b3:	83 ea 37             	sub    $0x37,%edx
f01015b6:	eb d0                	jmp    f0101588 <strtol+0x87>
		// we don't properly detect overflow!
	}

	if (endptr)
f01015b8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01015bc:	74 05                	je     f01015c3 <strtol+0xc2>
		*endptr = (char *) s;
f01015be:	8b 75 0c             	mov    0xc(%ebp),%esi
f01015c1:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f01015c3:	85 ff                	test   %edi,%edi
f01015c5:	74 02                	je     f01015c9 <strtol+0xc8>
f01015c7:	f7 d8                	neg    %eax
}
f01015c9:	5b                   	pop    %ebx
f01015ca:	5e                   	pop    %esi
f01015cb:	5f                   	pop    %edi
f01015cc:	5d                   	pop    %ebp
f01015cd:	c3                   	ret    
f01015ce:	66 90                	xchg   %ax,%ax

f01015d0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
f01015d0:	55                   	push   %ebp
f01015d1:	57                   	push   %edi
f01015d2:	56                   	push   %esi
f01015d3:	53                   	push   %ebx
f01015d4:	83 ec 1c             	sub    $0x1c,%esp
f01015d7:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01015db:	8b 74 24 34          	mov    0x34(%esp),%esi
f01015df:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01015e3:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  if (d1 == 0)
f01015e7:	85 d2                	test   %edx,%edx
f01015e9:	75 2d                	jne    f0101618 <__udivdi3+0x48>
      if (d0 > n1)
f01015eb:	39 f7                	cmp    %esi,%edi
f01015ed:	77 59                	ja     f0101648 <__udivdi3+0x78>
f01015ef:	89 f9                	mov    %edi,%ecx
	  if (d0 == 0)
f01015f1:	85 ff                	test   %edi,%edi
f01015f3:	75 0b                	jne    f0101600 <__udivdi3+0x30>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f01015f5:	b8 01 00 00 00       	mov    $0x1,%eax
f01015fa:	31 d2                	xor    %edx,%edx
f01015fc:	f7 f7                	div    %edi
f01015fe:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q1, n1, 0, n1, d0);
f0101600:	31 d2                	xor    %edx,%edx
f0101602:	89 f0                	mov    %esi,%eax
f0101604:	f7 f1                	div    %ecx
f0101606:	89 c3                	mov    %eax,%ebx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0101608:	89 e8                	mov    %ebp,%eax
f010160a:	f7 f1                	div    %ecx
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
f010160c:	89 da                	mov    %ebx,%edx
f010160e:	83 c4 1c             	add    $0x1c,%esp
f0101611:	5b                   	pop    %ebx
f0101612:	5e                   	pop    %esi
f0101613:	5f                   	pop    %edi
f0101614:	5d                   	pop    %ebp
f0101615:	c3                   	ret    
f0101616:	66 90                	xchg   %ax,%ax
      if (d1 > n1)
f0101618:	39 f2                	cmp    %esi,%edx
f010161a:	77 1c                	ja     f0101638 <__udivdi3+0x68>
	  count_leading_zeros (bm, d1);
f010161c:	0f bd da             	bsr    %edx,%ebx
	  if (bm == 0)
f010161f:	83 f3 1f             	xor    $0x1f,%ebx
f0101622:	75 38                	jne    f010165c <__udivdi3+0x8c>
	      if (n1 > d1 || n0 >= d0)
f0101624:	39 f2                	cmp    %esi,%edx
f0101626:	72 08                	jb     f0101630 <__udivdi3+0x60>
f0101628:	39 ef                	cmp    %ebp,%edi
f010162a:	0f 87 98 00 00 00    	ja     f01016c8 <__udivdi3+0xf8>
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f0101630:	b8 01 00 00 00       	mov    $0x1,%eax
f0101635:	eb 05                	jmp    f010163c <__udivdi3+0x6c>
f0101637:	90                   	nop
      if (d1 > n1)
f0101638:	31 db                	xor    %ebx,%ebx
f010163a:	31 c0                	xor    %eax,%eax
}
f010163c:	89 da                	mov    %ebx,%edx
f010163e:	83 c4 1c             	add    $0x1c,%esp
f0101641:	5b                   	pop    %ebx
f0101642:	5e                   	pop    %esi
f0101643:	5f                   	pop    %edi
f0101644:	5d                   	pop    %ebp
f0101645:	c3                   	ret    
f0101646:	66 90                	xchg   %ax,%ax
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0101648:	89 e8                	mov    %ebp,%eax
f010164a:	89 f2                	mov    %esi,%edx
f010164c:	f7 f7                	div    %edi
f010164e:	31 db                	xor    %ebx,%ebx
}
f0101650:	89 da                	mov    %ebx,%edx
f0101652:	83 c4 1c             	add    $0x1c,%esp
f0101655:	5b                   	pop    %ebx
f0101656:	5e                   	pop    %esi
f0101657:	5f                   	pop    %edi
f0101658:	5d                   	pop    %ebp
f0101659:	c3                   	ret    
f010165a:	66 90                	xchg   %ax,%ax
	      b = W_TYPE_SIZE - bm;
f010165c:	b8 20 00 00 00       	mov    $0x20,%eax
f0101661:	29 d8                	sub    %ebx,%eax
	      d1 = (d1 << bm) | (d0 >> b);
f0101663:	88 d9                	mov    %bl,%cl
f0101665:	d3 e2                	shl    %cl,%edx
f0101667:	89 54 24 08          	mov    %edx,0x8(%esp)
f010166b:	89 fa                	mov    %edi,%edx
f010166d:	88 c1                	mov    %al,%cl
f010166f:	d3 ea                	shr    %cl,%edx
f0101671:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101675:	09 d1                	or     %edx,%ecx
f0101677:	89 4c 24 08          	mov    %ecx,0x8(%esp)
	      d0 = d0 << bm;
f010167b:	88 d9                	mov    %bl,%cl
f010167d:	d3 e7                	shl    %cl,%edi
f010167f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
	      n2 = n1 >> b;
f0101683:	89 f7                	mov    %esi,%edi
f0101685:	88 c1                	mov    %al,%cl
f0101687:	d3 ef                	shr    %cl,%edi
	      n1 = (n1 << bm) | (n0 >> b);
f0101689:	88 d9                	mov    %bl,%cl
f010168b:	d3 e6                	shl    %cl,%esi
f010168d:	89 ea                	mov    %ebp,%edx
f010168f:	88 c1                	mov    %al,%cl
f0101691:	d3 ea                	shr    %cl,%edx
f0101693:	09 d6                	or     %edx,%esi
	      udiv_qrnnd (q0, n1, n2, n1, d1);
f0101695:	89 f0                	mov    %esi,%eax
f0101697:	89 fa                	mov    %edi,%edx
f0101699:	f7 74 24 08          	divl   0x8(%esp)
f010169d:	89 d7                	mov    %edx,%edi
f010169f:	89 c6                	mov    %eax,%esi
	      umul_ppmm (m1, m0, q0, d0);
f01016a1:	f7 64 24 0c          	mull   0xc(%esp)
	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01016a5:	39 d7                	cmp    %edx,%edi
f01016a7:	72 13                	jb     f01016bc <__udivdi3+0xec>
f01016a9:	74 09                	je     f01016b4 <__udivdi3+0xe4>
f01016ab:	89 f0                	mov    %esi,%eax
f01016ad:	31 db                	xor    %ebx,%ebx
f01016af:	eb 8b                	jmp    f010163c <__udivdi3+0x6c>
f01016b1:	8d 76 00             	lea    0x0(%esi),%esi
	      n0 = n0 << bm;
f01016b4:	88 d9                	mov    %bl,%cl
f01016b6:	d3 e5                	shl    %cl,%ebp
	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01016b8:	39 c5                	cmp    %eax,%ebp
f01016ba:	73 ef                	jae    f01016ab <__udivdi3+0xdb>
		  q0--;
f01016bc:	8d 46 ff             	lea    -0x1(%esi),%eax
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01016bf:	31 db                	xor    %ebx,%ebx
f01016c1:	e9 76 ff ff ff       	jmp    f010163c <__udivdi3+0x6c>
f01016c6:	66 90                	xchg   %ax,%ax
	      if (n1 > d1 || n0 >= d0)
f01016c8:	31 c0                	xor    %eax,%eax
f01016ca:	e9 6d ff ff ff       	jmp    f010163c <__udivdi3+0x6c>
f01016cf:	90                   	nop

f01016d0 <__umoddi3>:
{
f01016d0:	55                   	push   %ebp
f01016d1:	57                   	push   %edi
f01016d2:	56                   	push   %esi
f01016d3:	53                   	push   %ebx
f01016d4:	83 ec 1c             	sub    $0x1c,%esp
f01016d7:	8b 74 24 30          	mov    0x30(%esp),%esi
f01016db:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01016df:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01016e3:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  n0 = nn.s.low;
f01016e7:	89 f0                	mov    %esi,%eax
  n1 = nn.s.high;
f01016e9:	89 da                	mov    %ebx,%edx
  if (d1 == 0)
f01016eb:	85 ed                	test   %ebp,%ebp
f01016ed:	75 15                	jne    f0101704 <__umoddi3+0x34>
      if (d0 > n1)
f01016ef:	39 df                	cmp    %ebx,%edi
f01016f1:	76 39                	jbe    f010172c <__umoddi3+0x5c>
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f01016f3:	f7 f7                	div    %edi
	  *rp = rr.ll;
f01016f5:	89 d0                	mov    %edx,%eax
f01016f7:	31 d2                	xor    %edx,%edx
}
f01016f9:	83 c4 1c             	add    $0x1c,%esp
f01016fc:	5b                   	pop    %ebx
f01016fd:	5e                   	pop    %esi
f01016fe:	5f                   	pop    %edi
f01016ff:	5d                   	pop    %ebp
f0101700:	c3                   	ret    
f0101701:	8d 76 00             	lea    0x0(%esi),%esi
      if (d1 > n1)
f0101704:	39 dd                	cmp    %ebx,%ebp
f0101706:	77 f1                	ja     f01016f9 <__umoddi3+0x29>
	  count_leading_zeros (bm, d1);
f0101708:	0f bd cd             	bsr    %ebp,%ecx
	  if (bm == 0)
f010170b:	83 f1 1f             	xor    $0x1f,%ecx
f010170e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101712:	75 38                	jne    f010174c <__umoddi3+0x7c>
	      if (n1 > d1 || n0 >= d0)
f0101714:	39 dd                	cmp    %ebx,%ebp
f0101716:	72 04                	jb     f010171c <__umoddi3+0x4c>
f0101718:	39 f7                	cmp    %esi,%edi
f010171a:	77 dd                	ja     f01016f9 <__umoddi3+0x29>
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
f010171c:	89 da                	mov    %ebx,%edx
f010171e:	89 f0                	mov    %esi,%eax
f0101720:	29 f8                	sub    %edi,%eax
f0101722:	19 ea                	sbb    %ebp,%edx
}
f0101724:	83 c4 1c             	add    $0x1c,%esp
f0101727:	5b                   	pop    %ebx
f0101728:	5e                   	pop    %esi
f0101729:	5f                   	pop    %edi
f010172a:	5d                   	pop    %ebp
f010172b:	c3                   	ret    
f010172c:	89 f9                	mov    %edi,%ecx
	  if (d0 == 0)
f010172e:	85 ff                	test   %edi,%edi
f0101730:	75 0b                	jne    f010173d <__umoddi3+0x6d>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
f0101732:	b8 01 00 00 00       	mov    $0x1,%eax
f0101737:	31 d2                	xor    %edx,%edx
f0101739:	f7 f7                	div    %edi
f010173b:	89 c1                	mov    %eax,%ecx
	  udiv_qrnnd (q1, n1, 0, n1, d0);
f010173d:	89 d8                	mov    %ebx,%eax
f010173f:	31 d2                	xor    %edx,%edx
f0101741:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
f0101743:	89 f0                	mov    %esi,%eax
f0101745:	f7 f1                	div    %ecx
f0101747:	eb ac                	jmp    f01016f5 <__umoddi3+0x25>
f0101749:	8d 76 00             	lea    0x0(%esi),%esi
	      b = W_TYPE_SIZE - bm;
f010174c:	b8 20 00 00 00       	mov    $0x20,%eax
f0101751:	89 c2                	mov    %eax,%edx
f0101753:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101757:	29 c2                	sub    %eax,%edx
f0101759:	89 54 24 0c          	mov    %edx,0xc(%esp)
	      d1 = (d1 << bm) | (d0 >> b);
f010175d:	88 c1                	mov    %al,%cl
f010175f:	d3 e5                	shl    %cl,%ebp
f0101761:	89 f8                	mov    %edi,%eax
f0101763:	88 d1                	mov    %dl,%cl
f0101765:	d3 e8                	shr    %cl,%eax
f0101767:	09 c5                	or     %eax,%ebp
	      d0 = d0 << bm;
f0101769:	8b 44 24 04          	mov    0x4(%esp),%eax
f010176d:	88 c1                	mov    %al,%cl
f010176f:	d3 e7                	shl    %cl,%edi
f0101771:	89 7c 24 08          	mov    %edi,0x8(%esp)
	      n2 = n1 >> b;
f0101775:	89 df                	mov    %ebx,%edi
f0101777:	88 d1                	mov    %dl,%cl
f0101779:	d3 ef                	shr    %cl,%edi
	      n1 = (n1 << bm) | (n0 >> b);
f010177b:	88 c1                	mov    %al,%cl
f010177d:	d3 e3                	shl    %cl,%ebx
f010177f:	89 f0                	mov    %esi,%eax
f0101781:	88 d1                	mov    %dl,%cl
f0101783:	d3 e8                	shr    %cl,%eax
f0101785:	09 d8                	or     %ebx,%eax
	      n0 = n0 << bm;
f0101787:	8a 4c 24 04          	mov    0x4(%esp),%cl
f010178b:	d3 e6                	shl    %cl,%esi
	      udiv_qrnnd (q0, n1, n2, n1, d1);
f010178d:	89 fa                	mov    %edi,%edx
f010178f:	f7 f5                	div    %ebp
f0101791:	89 d1                	mov    %edx,%ecx
	      umul_ppmm (m1, m0, q0, d0);
f0101793:	f7 64 24 08          	mull   0x8(%esp)
f0101797:	89 c3                	mov    %eax,%ebx
f0101799:	89 d7                	mov    %edx,%edi
	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f010179b:	39 d1                	cmp    %edx,%ecx
f010179d:	72 29                	jb     f01017c8 <__umoddi3+0xf8>
f010179f:	74 23                	je     f01017c4 <__umoddi3+0xf4>
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
f01017a1:	89 ca                	mov    %ecx,%edx
f01017a3:	29 de                	sub    %ebx,%esi
f01017a5:	19 fa                	sbb    %edi,%edx
		  rr.s.low = (n1 << b) | (n0 >> bm);
f01017a7:	89 d0                	mov    %edx,%eax
f01017a9:	8a 4c 24 0c          	mov    0xc(%esp),%cl
f01017ad:	d3 e0                	shl    %cl,%eax
f01017af:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f01017b3:	88 d9                	mov    %bl,%cl
f01017b5:	d3 ee                	shr    %cl,%esi
		  *rp = rr.ll;
f01017b7:	09 f0                	or     %esi,%eax
f01017b9:	d3 ea                	shr    %cl,%edx
}
f01017bb:	83 c4 1c             	add    $0x1c,%esp
f01017be:	5b                   	pop    %ebx
f01017bf:	5e                   	pop    %esi
f01017c0:	5f                   	pop    %edi
f01017c1:	5d                   	pop    %ebp
f01017c2:	c3                   	ret    
f01017c3:	90                   	nop
	      if (m1 > n1 || (m1 == n1 && m0 > n0))
f01017c4:	39 c6                	cmp    %eax,%esi
f01017c6:	73 d9                	jae    f01017a1 <__umoddi3+0xd1>
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
f01017c8:	2b 44 24 08          	sub    0x8(%esp),%eax
f01017cc:	19 ea                	sbb    %ebp,%edx
f01017ce:	89 d7                	mov    %edx,%edi
f01017d0:	89 c3                	mov    %eax,%ebx
f01017d2:	eb cd                	jmp    f01017a1 <__umoddi3+0xd1>
