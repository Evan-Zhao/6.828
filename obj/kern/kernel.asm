
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
f010004b:	68 a0 17 10 f0       	push   $0xf01017a0
f0100050:	e8 65 08 00 00       	call   f01008ba <cprintf>
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
f0100065:	e8 d2 06 00 00       	call   f010073c <mon_backtrace>
f010006a:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010006d:	83 ec 08             	sub    $0x8,%esp
f0100070:	53                   	push   %ebx
f0100071:	68 bc 17 10 f0       	push   $0xf01017bc
f0100076:	e8 3f 08 00 00       	call   f01008ba <cprintf>
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
f01000ac:	e8 f5 12 00 00       	call   f01013a6 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 8b 04 00 00       	call   f0100541 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 d7 17 10 f0       	push   $0xf01017d7
f01000c3:	e8 f2 07 00 00       	call   f01008ba <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000c8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000cf:	e8 6c ff ff ff       	call   f0100040 <test_backtrace>
f01000d4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000d7:	83 ec 0c             	sub    $0xc,%esp
f01000da:	6a 00                	push   $0x0
f01000dc:	e8 65 06 00 00       	call   f0100746 <monitor>
f01000e1:	83 c4 10             	add    $0x10,%esp
f01000e4:	eb f1                	jmp    f01000d7 <i386_init+0x43>

f01000e6 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000e6:	55                   	push   %ebp
f01000e7:	89 e5                	mov    %esp,%ebp
f01000e9:	56                   	push   %esi
f01000ea:	53                   	push   %ebx
f01000eb:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000ee:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f01000f5:	74 0f                	je     f0100106 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000f7:	83 ec 0c             	sub    $0xc,%esp
f01000fa:	6a 00                	push   $0x0
f01000fc:	e8 45 06 00 00       	call   f0100746 <monitor>
f0100101:	83 c4 10             	add    $0x10,%esp
f0100104:	eb f1                	jmp    f01000f7 <_panic+0x11>
	panicstr = fmt;
f0100106:	89 35 40 29 11 f0    	mov    %esi,0xf0112940
	asm volatile("cli; cld");
f010010c:	fa                   	cli    
f010010d:	fc                   	cld    
	va_start(ap, fmt);
f010010e:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100111:	83 ec 04             	sub    $0x4,%esp
f0100114:	ff 75 0c             	pushl  0xc(%ebp)
f0100117:	ff 75 08             	pushl  0x8(%ebp)
f010011a:	68 f2 17 10 f0       	push   $0xf01017f2
f010011f:	e8 96 07 00 00       	call   f01008ba <cprintf>
	vcprintf(fmt, ap);
f0100124:	83 c4 08             	add    $0x8,%esp
f0100127:	53                   	push   %ebx
f0100128:	56                   	push   %esi
f0100129:	e8 66 07 00 00       	call   f0100894 <vcprintf>
	cprintf("\n");
f010012e:	c7 04 24 2e 18 10 f0 	movl   $0xf010182e,(%esp)
f0100135:	e8 80 07 00 00       	call   f01008ba <cprintf>
f010013a:	83 c4 10             	add    $0x10,%esp
f010013d:	eb b8                	jmp    f01000f7 <_panic+0x11>

f010013f <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010013f:	55                   	push   %ebp
f0100140:	89 e5                	mov    %esp,%ebp
f0100142:	53                   	push   %ebx
f0100143:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100146:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100149:	ff 75 0c             	pushl  0xc(%ebp)
f010014c:	ff 75 08             	pushl  0x8(%ebp)
f010014f:	68 0a 18 10 f0       	push   $0xf010180a
f0100154:	e8 61 07 00 00       	call   f01008ba <cprintf>
	vcprintf(fmt, ap);
f0100159:	83 c4 08             	add    $0x8,%esp
f010015c:	53                   	push   %ebx
f010015d:	ff 75 10             	pushl  0x10(%ebp)
f0100160:	e8 2f 07 00 00       	call   f0100894 <vcprintf>
	cprintf("\n");
f0100165:	c7 04 24 2e 18 10 f0 	movl   $0xf010182e,(%esp)
f010016c:	e8 49 07 00 00       	call   f01008ba <cprintf>
	va_end(ap);
}
f0100171:	83 c4 10             	add    $0x10,%esp
f0100174:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100177:	c9                   	leave  
f0100178:	c3                   	ret    

f0100179 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100179:	55                   	push   %ebp
f010017a:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010017c:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100181:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100182:	a8 01                	test   $0x1,%al
f0100184:	74 0b                	je     f0100191 <serial_proc_data+0x18>
f0100186:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010018b:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010018c:	0f b6 c0             	movzbl %al,%eax
}
f010018f:	5d                   	pop    %ebp
f0100190:	c3                   	ret    
		return -1;
f0100191:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100196:	eb f7                	jmp    f010018f <serial_proc_data+0x16>

f0100198 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100198:	55                   	push   %ebp
f0100199:	89 e5                	mov    %esp,%ebp
f010019b:	53                   	push   %ebx
f010019c:	83 ec 04             	sub    $0x4,%esp
f010019f:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001a1:	ff d3                	call   *%ebx
f01001a3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001a6:	74 2d                	je     f01001d5 <cons_intr+0x3d>
		if (c == 0)
f01001a8:	85 c0                	test   %eax,%eax
f01001aa:	74 f5                	je     f01001a1 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f01001ac:	8b 0d 24 25 11 f0    	mov    0xf0112524,%ecx
f01001b2:	8d 51 01             	lea    0x1(%ecx),%edx
f01001b5:	89 15 24 25 11 f0    	mov    %edx,0xf0112524
f01001bb:	88 81 20 23 11 f0    	mov    %al,-0xfeedce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001c1:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001c7:	75 d8                	jne    f01001a1 <cons_intr+0x9>
			cons.wpos = 0;
f01001c9:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f01001d0:	00 00 00 
f01001d3:	eb cc                	jmp    f01001a1 <cons_intr+0x9>
	}
}
f01001d5:	83 c4 04             	add    $0x4,%esp
f01001d8:	5b                   	pop    %ebx
f01001d9:	5d                   	pop    %ebp
f01001da:	c3                   	ret    

f01001db <kbd_proc_data>:
{
f01001db:	55                   	push   %ebp
f01001dc:	89 e5                	mov    %esp,%ebp
f01001de:	53                   	push   %ebx
f01001df:	83 ec 04             	sub    $0x4,%esp
f01001e2:	ba 64 00 00 00       	mov    $0x64,%edx
f01001e7:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01001e8:	a8 01                	test   $0x1,%al
f01001ea:	0f 84 f1 00 00 00    	je     f01002e1 <kbd_proc_data+0x106>
	if (stat & KBS_TERR)
f01001f0:	a8 20                	test   $0x20,%al
f01001f2:	0f 85 f0 00 00 00    	jne    f01002e8 <kbd_proc_data+0x10d>
f01001f8:	ba 60 00 00 00       	mov    $0x60,%edx
f01001fd:	ec                   	in     (%dx),%al
f01001fe:	88 c2                	mov    %al,%dl
	if (data == 0xE0) {
f0100200:	3c e0                	cmp    $0xe0,%al
f0100202:	0f 84 8a 00 00 00    	je     f0100292 <kbd_proc_data+0xb7>
	} else if (data & 0x80) {
f0100208:	84 c0                	test   %al,%al
f010020a:	0f 88 95 00 00 00    	js     f01002a5 <kbd_proc_data+0xca>
	} else if (shift & E0ESC) {
f0100210:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100216:	f6 c1 40             	test   $0x40,%cl
f0100219:	74 0e                	je     f0100229 <kbd_proc_data+0x4e>
		data |= 0x80;
f010021b:	83 c8 80             	or     $0xffffff80,%eax
f010021e:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f0100220:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100223:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	shift |= shiftcode[data];
f0100229:	0f b6 d2             	movzbl %dl,%edx
f010022c:	0f b6 82 80 19 10 f0 	movzbl -0xfefe680(%edx),%eax
f0100233:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
	shift ^= togglecode[data];
f0100239:	0f b6 8a 80 18 10 f0 	movzbl -0xfefe780(%edx),%ecx
f0100240:	31 c8                	xor    %ecx,%eax
f0100242:	a3 00 23 11 f0       	mov    %eax,0xf0112300
	c = charcode[shift & (CTL | SHIFT)][data];
f0100247:	89 c1                	mov    %eax,%ecx
f0100249:	83 e1 03             	and    $0x3,%ecx
f010024c:	8b 0c 8d 60 18 10 f0 	mov    -0xfefe7a0(,%ecx,4),%ecx
f0100253:	8a 14 11             	mov    (%ecx,%edx,1),%dl
f0100256:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100259:	a8 08                	test   $0x8,%al
f010025b:	74 0d                	je     f010026a <kbd_proc_data+0x8f>
		if ('a' <= c && c <= 'z')
f010025d:	89 da                	mov    %ebx,%edx
f010025f:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100262:	83 f9 19             	cmp    $0x19,%ecx
f0100265:	77 6d                	ja     f01002d4 <kbd_proc_data+0xf9>
			c += 'A' - 'a';
f0100267:	83 eb 20             	sub    $0x20,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010026a:	f7 d0                	not    %eax
f010026c:	a8 06                	test   $0x6,%al
f010026e:	75 2e                	jne    f010029e <kbd_proc_data+0xc3>
f0100270:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100276:	75 26                	jne    f010029e <kbd_proc_data+0xc3>
		cprintf("Rebooting!\n");
f0100278:	83 ec 0c             	sub    $0xc,%esp
f010027b:	68 24 18 10 f0       	push   $0xf0101824
f0100280:	e8 35 06 00 00       	call   f01008ba <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100285:	b0 03                	mov    $0x3,%al
f0100287:	ba 92 00 00 00       	mov    $0x92,%edx
f010028c:	ee                   	out    %al,(%dx)
f010028d:	83 c4 10             	add    $0x10,%esp
f0100290:	eb 0c                	jmp    f010029e <kbd_proc_data+0xc3>
		shift |= E0ESC;
f0100292:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f0100299:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f010029e:	89 d8                	mov    %ebx,%eax
f01002a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002a3:	c9                   	leave  
f01002a4:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002a5:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f01002ab:	f6 c1 40             	test   $0x40,%cl
f01002ae:	75 05                	jne    f01002b5 <kbd_proc_data+0xda>
f01002b0:	83 e0 7f             	and    $0x7f,%eax
f01002b3:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f01002b5:	0f b6 d2             	movzbl %dl,%edx
f01002b8:	8a 82 80 19 10 f0    	mov    -0xfefe680(%edx),%al
f01002be:	83 c8 40             	or     $0x40,%eax
f01002c1:	0f b6 c0             	movzbl %al,%eax
f01002c4:	f7 d0                	not    %eax
f01002c6:	21 c8                	and    %ecx,%eax
f01002c8:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f01002cd:	bb 00 00 00 00       	mov    $0x0,%ebx
f01002d2:	eb ca                	jmp    f010029e <kbd_proc_data+0xc3>
		else if ('A' <= c && c <= 'Z')
f01002d4:	83 ea 41             	sub    $0x41,%edx
f01002d7:	83 fa 19             	cmp    $0x19,%edx
f01002da:	77 8e                	ja     f010026a <kbd_proc_data+0x8f>
			c += 'a' - 'A';
f01002dc:	83 c3 20             	add    $0x20,%ebx
f01002df:	eb 89                	jmp    f010026a <kbd_proc_data+0x8f>
		return -1;
f01002e1:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01002e6:	eb b6                	jmp    f010029e <kbd_proc_data+0xc3>
		return -1;
f01002e8:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01002ed:	eb af                	jmp    f010029e <kbd_proc_data+0xc3>

f01002ef <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002ef:	55                   	push   %ebp
f01002f0:	89 e5                	mov    %esp,%ebp
f01002f2:	57                   	push   %edi
f01002f3:	56                   	push   %esi
f01002f4:	53                   	push   %ebx
f01002f5:	83 ec 1c             	sub    $0x1c,%esp
f01002f8:	89 c7                	mov    %eax,%edi
f01002fa:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002ff:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100304:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100309:	eb 06                	jmp    f0100311 <cons_putc+0x22>
f010030b:	89 ca                	mov    %ecx,%edx
f010030d:	ec                   	in     (%dx),%al
f010030e:	ec                   	in     (%dx),%al
f010030f:	ec                   	in     (%dx),%al
f0100310:	ec                   	in     (%dx),%al
f0100311:	89 f2                	mov    %esi,%edx
f0100313:	ec                   	in     (%dx),%al
	for (i = 0;
f0100314:	a8 20                	test   $0x20,%al
f0100316:	75 03                	jne    f010031b <cons_putc+0x2c>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100318:	4b                   	dec    %ebx
f0100319:	75 f0                	jne    f010030b <cons_putc+0x1c>
	outb(COM1 + COM_TX, c);
f010031b:	89 f8                	mov    %edi,%eax
f010031d:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100320:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100325:	ee                   	out    %al,(%dx)
f0100326:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010032b:	be 79 03 00 00       	mov    $0x379,%esi
f0100330:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100335:	eb 06                	jmp    f010033d <cons_putc+0x4e>
f0100337:	89 ca                	mov    %ecx,%edx
f0100339:	ec                   	in     (%dx),%al
f010033a:	ec                   	in     (%dx),%al
f010033b:	ec                   	in     (%dx),%al
f010033c:	ec                   	in     (%dx),%al
f010033d:	89 f2                	mov    %esi,%edx
f010033f:	ec                   	in     (%dx),%al
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100340:	84 c0                	test   %al,%al
f0100342:	78 03                	js     f0100347 <cons_putc+0x58>
f0100344:	4b                   	dec    %ebx
f0100345:	75 f0                	jne    f0100337 <cons_putc+0x48>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100347:	ba 78 03 00 00       	mov    $0x378,%edx
f010034c:	8a 45 e7             	mov    -0x19(%ebp),%al
f010034f:	ee                   	out    %al,(%dx)
f0100350:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100355:	b0 0d                	mov    $0xd,%al
f0100357:	ee                   	out    %al,(%dx)
f0100358:	b0 08                	mov    $0x8,%al
f010035a:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f010035b:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100361:	75 06                	jne    f0100369 <cons_putc+0x7a>
		c |= 0x0700;
f0100363:	81 cf 00 07 00 00    	or     $0x700,%edi
	switch (c & 0xff) {
f0100369:	89 f8                	mov    %edi,%eax
f010036b:	0f b6 c0             	movzbl %al,%eax
f010036e:	83 f8 09             	cmp    $0x9,%eax
f0100371:	0f 84 b1 00 00 00    	je     f0100428 <cons_putc+0x139>
f0100377:	83 f8 09             	cmp    $0x9,%eax
f010037a:	7e 70                	jle    f01003ec <cons_putc+0xfd>
f010037c:	83 f8 0a             	cmp    $0xa,%eax
f010037f:	0f 84 96 00 00 00    	je     f010041b <cons_putc+0x12c>
f0100385:	83 f8 0d             	cmp    $0xd,%eax
f0100388:	0f 85 d1 00 00 00    	jne    f010045f <cons_putc+0x170>
		crt_pos -= (crt_pos % CRT_COLS);
f010038e:	66 8b 0d 28 25 11 f0 	mov    0xf0112528,%cx
f0100395:	bb 50 00 00 00       	mov    $0x50,%ebx
f010039a:	89 c8                	mov    %ecx,%eax
f010039c:	ba 00 00 00 00       	mov    $0x0,%edx
f01003a1:	66 f7 f3             	div    %bx
f01003a4:	29 d1                	sub    %edx,%ecx
f01003a6:	66 89 0d 28 25 11 f0 	mov    %cx,0xf0112528
	if (crt_pos >= CRT_SIZE) {
f01003ad:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f01003b4:	cf 07 
f01003b6:	0f 87 c5 00 00 00    	ja     f0100481 <cons_putc+0x192>
	outb(addr_6845, 14);
f01003bc:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f01003c2:	b0 0e                	mov    $0xe,%al
f01003c4:	89 ca                	mov    %ecx,%edx
f01003c6:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01003c7:	8d 59 01             	lea    0x1(%ecx),%ebx
f01003ca:	66 a1 28 25 11 f0    	mov    0xf0112528,%ax
f01003d0:	66 c1 e8 08          	shr    $0x8,%ax
f01003d4:	89 da                	mov    %ebx,%edx
f01003d6:	ee                   	out    %al,(%dx)
f01003d7:	b0 0f                	mov    $0xf,%al
f01003d9:	89 ca                	mov    %ecx,%edx
f01003db:	ee                   	out    %al,(%dx)
f01003dc:	a0 28 25 11 f0       	mov    0xf0112528,%al
f01003e1:	89 da                	mov    %ebx,%edx
f01003e3:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01003e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01003e7:	5b                   	pop    %ebx
f01003e8:	5e                   	pop    %esi
f01003e9:	5f                   	pop    %edi
f01003ea:	5d                   	pop    %ebp
f01003eb:	c3                   	ret    
	switch (c & 0xff) {
f01003ec:	83 f8 08             	cmp    $0x8,%eax
f01003ef:	75 6e                	jne    f010045f <cons_putc+0x170>
		if (crt_pos > 0) {
f01003f1:	66 a1 28 25 11 f0    	mov    0xf0112528,%ax
f01003f7:	66 85 c0             	test   %ax,%ax
f01003fa:	74 c0                	je     f01003bc <cons_putc+0xcd>
			crt_pos--;
f01003fc:	48                   	dec    %eax
f01003fd:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100403:	0f b7 c0             	movzwl %ax,%eax
f0100406:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f010040c:	83 cf 20             	or     $0x20,%edi
f010040f:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100415:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100419:	eb 92                	jmp    f01003ad <cons_putc+0xbe>
		crt_pos += CRT_COLS;
f010041b:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f0100422:	50 
f0100423:	e9 66 ff ff ff       	jmp    f010038e <cons_putc+0x9f>
		cons_putc(' ');
f0100428:	b8 20 00 00 00       	mov    $0x20,%eax
f010042d:	e8 bd fe ff ff       	call   f01002ef <cons_putc>
		cons_putc(' ');
f0100432:	b8 20 00 00 00       	mov    $0x20,%eax
f0100437:	e8 b3 fe ff ff       	call   f01002ef <cons_putc>
		cons_putc(' ');
f010043c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100441:	e8 a9 fe ff ff       	call   f01002ef <cons_putc>
		cons_putc(' ');
f0100446:	b8 20 00 00 00       	mov    $0x20,%eax
f010044b:	e8 9f fe ff ff       	call   f01002ef <cons_putc>
		cons_putc(' ');
f0100450:	b8 20 00 00 00       	mov    $0x20,%eax
f0100455:	e8 95 fe ff ff       	call   f01002ef <cons_putc>
f010045a:	e9 4e ff ff ff       	jmp    f01003ad <cons_putc+0xbe>
		crt_buf[crt_pos++] = c;		/* write the character */
f010045f:	66 a1 28 25 11 f0    	mov    0xf0112528,%ax
f0100465:	8d 50 01             	lea    0x1(%eax),%edx
f0100468:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f010046f:	0f b7 c0             	movzwl %ax,%eax
f0100472:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100478:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010047c:	e9 2c ff ff ff       	jmp    f01003ad <cons_putc+0xbe>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100481:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f0100486:	83 ec 04             	sub    $0x4,%esp
f0100489:	68 00 0f 00 00       	push   $0xf00
f010048e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100494:	52                   	push   %edx
f0100495:	50                   	push   %eax
f0100496:	e8 58 0f 00 00       	call   f01013f3 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010049b:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01004a1:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01004a7:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01004ad:	83 c4 10             	add    $0x10,%esp
f01004b0:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01004b5:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004b8:	39 d0                	cmp    %edx,%eax
f01004ba:	75 f4                	jne    f01004b0 <cons_putc+0x1c1>
		crt_pos -= CRT_COLS;
f01004bc:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f01004c3:	50 
f01004c4:	e9 f3 fe ff ff       	jmp    f01003bc <cons_putc+0xcd>

f01004c9 <serial_intr>:
	if (serial_exists)
f01004c9:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f01004d0:	75 01                	jne    f01004d3 <serial_intr+0xa>
f01004d2:	c3                   	ret    
{
f01004d3:	55                   	push   %ebp
f01004d4:	89 e5                	mov    %esp,%ebp
f01004d6:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01004d9:	b8 79 01 10 f0       	mov    $0xf0100179,%eax
f01004de:	e8 b5 fc ff ff       	call   f0100198 <cons_intr>
}
f01004e3:	c9                   	leave  
f01004e4:	c3                   	ret    

f01004e5 <kbd_intr>:
{
f01004e5:	55                   	push   %ebp
f01004e6:	89 e5                	mov    %esp,%ebp
f01004e8:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004eb:	b8 db 01 10 f0       	mov    $0xf01001db,%eax
f01004f0:	e8 a3 fc ff ff       	call   f0100198 <cons_intr>
}
f01004f5:	c9                   	leave  
f01004f6:	c3                   	ret    

f01004f7 <cons_getc>:
{
f01004f7:	55                   	push   %ebp
f01004f8:	89 e5                	mov    %esp,%ebp
f01004fa:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f01004fd:	e8 c7 ff ff ff       	call   f01004c9 <serial_intr>
	kbd_intr();
f0100502:	e8 de ff ff ff       	call   f01004e5 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100507:	a1 20 25 11 f0       	mov    0xf0112520,%eax
f010050c:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f0100512:	74 26                	je     f010053a <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100514:	8d 50 01             	lea    0x1(%eax),%edx
f0100517:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
f010051d:	0f b6 80 20 23 11 f0 	movzbl -0xfeedce0(%eax),%eax
		if (cons.rpos == CONSBUFSIZE)
f0100524:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010052a:	74 02                	je     f010052e <cons_getc+0x37>
}
f010052c:	c9                   	leave  
f010052d:	c3                   	ret    
			cons.rpos = 0;
f010052e:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f0100535:	00 00 00 
f0100538:	eb f2                	jmp    f010052c <cons_getc+0x35>
	return 0;
f010053a:	b8 00 00 00 00       	mov    $0x0,%eax
f010053f:	eb eb                	jmp    f010052c <cons_getc+0x35>

f0100541 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100541:	55                   	push   %ebp
f0100542:	89 e5                	mov    %esp,%ebp
f0100544:	57                   	push   %edi
f0100545:	56                   	push   %esi
f0100546:	53                   	push   %ebx
f0100547:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f010054a:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f0100551:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100558:	5a a5 
	if (*cp != 0xA55A) {
f010055a:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f0100560:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100564:	0f 84 a2 00 00 00    	je     f010060c <cons_init+0xcb>
		addr_6845 = MONO_BASE;
f010056a:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f0100571:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100574:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f0100579:	8b 3d 30 25 11 f0    	mov    0xf0112530,%edi
f010057f:	b0 0e                	mov    $0xe,%al
f0100581:	89 fa                	mov    %edi,%edx
f0100583:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100584:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100587:	89 ca                	mov    %ecx,%edx
f0100589:	ec                   	in     (%dx),%al
f010058a:	0f b6 c0             	movzbl %al,%eax
f010058d:	c1 e0 08             	shl    $0x8,%eax
f0100590:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100592:	b0 0f                	mov    $0xf,%al
f0100594:	89 fa                	mov    %edi,%edx
f0100596:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100597:	89 ca                	mov    %ecx,%edx
f0100599:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010059a:	89 35 2c 25 11 f0    	mov    %esi,0xf011252c
	pos |= inb(addr_6845 + 1);
f01005a0:	0f b6 c0             	movzbl %al,%eax
f01005a3:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01005a5:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005ab:	b1 00                	mov    $0x0,%cl
f01005ad:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01005b2:	88 c8                	mov    %cl,%al
f01005b4:	89 da                	mov    %ebx,%edx
f01005b6:	ee                   	out    %al,(%dx)
f01005b7:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01005bc:	b0 80                	mov    $0x80,%al
f01005be:	89 fa                	mov    %edi,%edx
f01005c0:	ee                   	out    %al,(%dx)
f01005c1:	b0 0c                	mov    $0xc,%al
f01005c3:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01005c8:	ee                   	out    %al,(%dx)
f01005c9:	be f9 03 00 00       	mov    $0x3f9,%esi
f01005ce:	88 c8                	mov    %cl,%al
f01005d0:	89 f2                	mov    %esi,%edx
f01005d2:	ee                   	out    %al,(%dx)
f01005d3:	b0 03                	mov    $0x3,%al
f01005d5:	89 fa                	mov    %edi,%edx
f01005d7:	ee                   	out    %al,(%dx)
f01005d8:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005dd:	88 c8                	mov    %cl,%al
f01005df:	ee                   	out    %al,(%dx)
f01005e0:	b0 01                	mov    $0x1,%al
f01005e2:	89 f2                	mov    %esi,%edx
f01005e4:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005e5:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005ea:	ec                   	in     (%dx),%al
f01005eb:	88 c1                	mov    %al,%cl
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005ed:	3c ff                	cmp    $0xff,%al
f01005ef:	0f 95 05 34 25 11 f0 	setne  0xf0112534
f01005f6:	89 da                	mov    %ebx,%edx
f01005f8:	ec                   	in     (%dx),%al
f01005f9:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01005fe:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005ff:	80 f9 ff             	cmp    $0xff,%cl
f0100602:	74 23                	je     f0100627 <cons_init+0xe6>
		cprintf("Serial port does not exist!\n");
}
f0100604:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100607:	5b                   	pop    %ebx
f0100608:	5e                   	pop    %esi
f0100609:	5f                   	pop    %edi
f010060a:	5d                   	pop    %ebp
f010060b:	c3                   	ret    
		*cp = was;
f010060c:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100613:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f010061a:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010061d:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f0100622:	e9 52 ff ff ff       	jmp    f0100579 <cons_init+0x38>
		cprintf("Serial port does not exist!\n");
f0100627:	83 ec 0c             	sub    $0xc,%esp
f010062a:	68 30 18 10 f0       	push   $0xf0101830
f010062f:	e8 86 02 00 00       	call   f01008ba <cprintf>
f0100634:	83 c4 10             	add    $0x10,%esp
}
f0100637:	eb cb                	jmp    f0100604 <cons_init+0xc3>

f0100639 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100639:	55                   	push   %ebp
f010063a:	89 e5                	mov    %esp,%ebp
f010063c:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010063f:	8b 45 08             	mov    0x8(%ebp),%eax
f0100642:	e8 a8 fc ff ff       	call   f01002ef <cons_putc>
}
f0100647:	c9                   	leave  
f0100648:	c3                   	ret    

f0100649 <getchar>:

int
getchar(void)
{
f0100649:	55                   	push   %ebp
f010064a:	89 e5                	mov    %esp,%ebp
f010064c:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010064f:	e8 a3 fe ff ff       	call   f01004f7 <cons_getc>
f0100654:	85 c0                	test   %eax,%eax
f0100656:	74 f7                	je     f010064f <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100658:	c9                   	leave  
f0100659:	c3                   	ret    

f010065a <iscons>:

int
iscons(int fdnum)
{
f010065a:	55                   	push   %ebp
f010065b:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010065d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100662:	5d                   	pop    %ebp
f0100663:	c3                   	ret    

f0100664 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100664:	55                   	push   %ebp
f0100665:	89 e5                	mov    %esp,%ebp
f0100667:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010066a:	68 80 1a 10 f0       	push   $0xf0101a80
f010066f:	68 9e 1a 10 f0       	push   $0xf0101a9e
f0100674:	68 a3 1a 10 f0       	push   $0xf0101aa3
f0100679:	e8 3c 02 00 00       	call   f01008ba <cprintf>
f010067e:	83 c4 0c             	add    $0xc,%esp
f0100681:	68 0c 1b 10 f0       	push   $0xf0101b0c
f0100686:	68 ac 1a 10 f0       	push   $0xf0101aac
f010068b:	68 a3 1a 10 f0       	push   $0xf0101aa3
f0100690:	e8 25 02 00 00       	call   f01008ba <cprintf>
	return 0;
}
f0100695:	b8 00 00 00 00       	mov    $0x0,%eax
f010069a:	c9                   	leave  
f010069b:	c3                   	ret    

f010069c <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010069c:	55                   	push   %ebp
f010069d:	89 e5                	mov    %esp,%ebp
f010069f:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006a2:	68 b5 1a 10 f0       	push   $0xf0101ab5
f01006a7:	e8 0e 02 00 00       	call   f01008ba <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006ac:	83 c4 08             	add    $0x8,%esp
f01006af:	68 0c 00 10 00       	push   $0x10000c
f01006b4:	68 34 1b 10 f0       	push   $0xf0101b34
f01006b9:	e8 fc 01 00 00       	call   f01008ba <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006be:	83 c4 0c             	add    $0xc,%esp
f01006c1:	68 0c 00 10 00       	push   $0x10000c
f01006c6:	68 0c 00 10 f0       	push   $0xf010000c
f01006cb:	68 5c 1b 10 f0       	push   $0xf0101b5c
f01006d0:	e8 e5 01 00 00       	call   f01008ba <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006d5:	83 c4 0c             	add    $0xc,%esp
f01006d8:	68 8c 17 10 00       	push   $0x10178c
f01006dd:	68 8c 17 10 f0       	push   $0xf010178c
f01006e2:	68 80 1b 10 f0       	push   $0xf0101b80
f01006e7:	e8 ce 01 00 00       	call   f01008ba <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006ec:	83 c4 0c             	add    $0xc,%esp
f01006ef:	68 00 23 11 00       	push   $0x112300
f01006f4:	68 00 23 11 f0       	push   $0xf0112300
f01006f9:	68 a4 1b 10 f0       	push   $0xf0101ba4
f01006fe:	e8 b7 01 00 00       	call   f01008ba <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100703:	83 c4 0c             	add    $0xc,%esp
f0100706:	68 44 29 11 00       	push   $0x112944
f010070b:	68 44 29 11 f0       	push   $0xf0112944
f0100710:	68 c8 1b 10 f0       	push   $0xf0101bc8
f0100715:	e8 a0 01 00 00       	call   f01008ba <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010071a:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010071d:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
f0100722:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100727:	c1 f8 0a             	sar    $0xa,%eax
f010072a:	50                   	push   %eax
f010072b:	68 ec 1b 10 f0       	push   $0xf0101bec
f0100730:	e8 85 01 00 00       	call   f01008ba <cprintf>
	return 0;
}
f0100735:	b8 00 00 00 00       	mov    $0x0,%eax
f010073a:	c9                   	leave  
f010073b:	c3                   	ret    

f010073c <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010073c:	55                   	push   %ebp
f010073d:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f010073f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100744:	5d                   	pop    %ebp
f0100745:	c3                   	ret    

f0100746 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100746:	55                   	push   %ebp
f0100747:	89 e5                	mov    %esp,%ebp
f0100749:	57                   	push   %edi
f010074a:	56                   	push   %esi
f010074b:	53                   	push   %ebx
f010074c:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010074f:	68 18 1c 10 f0       	push   $0xf0101c18
f0100754:	e8 61 01 00 00       	call   f01008ba <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100759:	c7 04 24 3c 1c 10 f0 	movl   $0xf0101c3c,(%esp)
f0100760:	e8 55 01 00 00       	call   f01008ba <cprintf>
f0100765:	83 c4 10             	add    $0x10,%esp
f0100768:	eb 47                	jmp    f01007b1 <monitor+0x6b>
		while (*buf && strchr(WHITESPACE, *buf))
f010076a:	83 ec 08             	sub    $0x8,%esp
f010076d:	0f be c0             	movsbl %al,%eax
f0100770:	50                   	push   %eax
f0100771:	68 d2 1a 10 f0       	push   $0xf0101ad2
f0100776:	e8 f6 0b 00 00       	call   f0101371 <strchr>
f010077b:	83 c4 10             	add    $0x10,%esp
f010077e:	85 c0                	test   %eax,%eax
f0100780:	74 0a                	je     f010078c <monitor+0x46>
			*buf++ = 0;
f0100782:	c6 03 00             	movb   $0x0,(%ebx)
f0100785:	89 f7                	mov    %esi,%edi
f0100787:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010078a:	eb 68                	jmp    f01007f4 <monitor+0xae>
		if (*buf == 0)
f010078c:	80 3b 00             	cmpb   $0x0,(%ebx)
f010078f:	74 6f                	je     f0100800 <monitor+0xba>
		if (argc == MAXARGS-1) {
f0100791:	83 fe 0f             	cmp    $0xf,%esi
f0100794:	74 09                	je     f010079f <monitor+0x59>
		argv[argc++] = buf;
f0100796:	8d 7e 01             	lea    0x1(%esi),%edi
f0100799:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010079d:	eb 37                	jmp    f01007d6 <monitor+0x90>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010079f:	83 ec 08             	sub    $0x8,%esp
f01007a2:	6a 10                	push   $0x10
f01007a4:	68 d7 1a 10 f0       	push   $0xf0101ad7
f01007a9:	e8 0c 01 00 00       	call   f01008ba <cprintf>
f01007ae:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01007b1:	83 ec 0c             	sub    $0xc,%esp
f01007b4:	68 ce 1a 10 f0       	push   $0xf0101ace
f01007b9:	e8 a8 09 00 00       	call   f0101166 <readline>
f01007be:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007c0:	83 c4 10             	add    $0x10,%esp
f01007c3:	85 c0                	test   %eax,%eax
f01007c5:	74 ea                	je     f01007b1 <monitor+0x6b>
	argv[argc] = 0;
f01007c7:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01007ce:	be 00 00 00 00       	mov    $0x0,%esi
f01007d3:	eb 21                	jmp    f01007f6 <monitor+0xb0>
			buf++;
f01007d5:	43                   	inc    %ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f01007d6:	8a 03                	mov    (%ebx),%al
f01007d8:	84 c0                	test   %al,%al
f01007da:	74 18                	je     f01007f4 <monitor+0xae>
f01007dc:	83 ec 08             	sub    $0x8,%esp
f01007df:	0f be c0             	movsbl %al,%eax
f01007e2:	50                   	push   %eax
f01007e3:	68 d2 1a 10 f0       	push   $0xf0101ad2
f01007e8:	e8 84 0b 00 00       	call   f0101371 <strchr>
f01007ed:	83 c4 10             	add    $0x10,%esp
f01007f0:	85 c0                	test   %eax,%eax
f01007f2:	74 e1                	je     f01007d5 <monitor+0x8f>
			*buf++ = 0;
f01007f4:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f01007f6:	8a 03                	mov    (%ebx),%al
f01007f8:	84 c0                	test   %al,%al
f01007fa:	0f 85 6a ff ff ff    	jne    f010076a <monitor+0x24>
	argv[argc] = 0;
f0100800:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100807:	00 
	if (argc == 0)
f0100808:	85 f6                	test   %esi,%esi
f010080a:	74 a5                	je     f01007b1 <monitor+0x6b>
		if (strcmp(argv[0], commands[i].name) == 0)
f010080c:	83 ec 08             	sub    $0x8,%esp
f010080f:	68 9e 1a 10 f0       	push   $0xf0101a9e
f0100814:	ff 75 a8             	pushl  -0x58(%ebp)
f0100817:	e8 01 0b 00 00       	call   f010131d <strcmp>
f010081c:	83 c4 10             	add    $0x10,%esp
f010081f:	85 c0                	test   %eax,%eax
f0100821:	74 34                	je     f0100857 <monitor+0x111>
f0100823:	83 ec 08             	sub    $0x8,%esp
f0100826:	68 ac 1a 10 f0       	push   $0xf0101aac
f010082b:	ff 75 a8             	pushl  -0x58(%ebp)
f010082e:	e8 ea 0a 00 00       	call   f010131d <strcmp>
f0100833:	83 c4 10             	add    $0x10,%esp
f0100836:	85 c0                	test   %eax,%eax
f0100838:	74 18                	je     f0100852 <monitor+0x10c>
	cprintf("Unknown command '%s'\n", argv[0]);
f010083a:	83 ec 08             	sub    $0x8,%esp
f010083d:	ff 75 a8             	pushl  -0x58(%ebp)
f0100840:	68 f4 1a 10 f0       	push   $0xf0101af4
f0100845:	e8 70 00 00 00       	call   f01008ba <cprintf>
f010084a:	83 c4 10             	add    $0x10,%esp
f010084d:	e9 5f ff ff ff       	jmp    f01007b1 <monitor+0x6b>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100852:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100857:	83 ec 04             	sub    $0x4,%esp
f010085a:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010085d:	01 d0                	add    %edx,%eax
f010085f:	ff 75 08             	pushl  0x8(%ebp)
f0100862:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100865:	51                   	push   %ecx
f0100866:	56                   	push   %esi
f0100867:	ff 14 85 6c 1c 10 f0 	call   *-0xfefe394(,%eax,4)
			if (runcmd(buf, tf) < 0)
f010086e:	83 c4 10             	add    $0x10,%esp
f0100871:	85 c0                	test   %eax,%eax
f0100873:	0f 89 38 ff ff ff    	jns    f01007b1 <monitor+0x6b>
				break;
	}
}
f0100879:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010087c:	5b                   	pop    %ebx
f010087d:	5e                   	pop    %esi
f010087e:	5f                   	pop    %edi
f010087f:	5d                   	pop    %ebp
f0100880:	c3                   	ret    

f0100881 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100881:	55                   	push   %ebp
f0100882:	89 e5                	mov    %esp,%ebp
f0100884:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0100887:	ff 75 08             	pushl  0x8(%ebp)
f010088a:	e8 aa fd ff ff       	call   f0100639 <cputchar>
	*cnt++;
}
f010088f:	83 c4 10             	add    $0x10,%esp
f0100892:	c9                   	leave  
f0100893:	c3                   	ret    

f0100894 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100894:	55                   	push   %ebp
f0100895:	89 e5                	mov    %esp,%ebp
f0100897:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010089a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01008a1:	ff 75 0c             	pushl  0xc(%ebp)
f01008a4:	ff 75 08             	pushl  0x8(%ebp)
f01008a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01008aa:	50                   	push   %eax
f01008ab:	68 81 08 10 f0       	push   $0xf0100881
f01008b0:	e8 d8 03 00 00       	call   f0100c8d <vprintfmt>
	return cnt;
}
f01008b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01008b8:	c9                   	leave  
f01008b9:	c3                   	ret    

f01008ba <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01008ba:	55                   	push   %ebp
f01008bb:	89 e5                	mov    %esp,%ebp
f01008bd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01008c0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01008c3:	50                   	push   %eax
f01008c4:	ff 75 08             	pushl  0x8(%ebp)
f01008c7:	e8 c8 ff ff ff       	call   f0100894 <vcprintf>
	va_end(ap);

	return cnt;
}
f01008cc:	c9                   	leave  
f01008cd:	c3                   	ret    

f01008ce <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01008ce:	55                   	push   %ebp
f01008cf:	89 e5                	mov    %esp,%ebp
f01008d1:	57                   	push   %edi
f01008d2:	56                   	push   %esi
f01008d3:	53                   	push   %ebx
f01008d4:	83 ec 14             	sub    $0x14,%esp
f01008d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01008da:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01008dd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01008e0:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01008e3:	8b 32                	mov    (%edx),%esi
f01008e5:	8b 01                	mov    (%ecx),%eax
f01008e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01008ea:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01008f1:	eb 2f                	jmp    f0100922 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f01008f3:	48                   	dec    %eax
		while (m >= l && stabs[m].n_type != type)
f01008f4:	39 c6                	cmp    %eax,%esi
f01008f6:	7f 4d                	jg     f0100945 <stab_binsearch+0x77>
f01008f8:	0f b6 0a             	movzbl (%edx),%ecx
f01008fb:	83 ea 0c             	sub    $0xc,%edx
f01008fe:	39 f9                	cmp    %edi,%ecx
f0100900:	75 f1                	jne    f01008f3 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100902:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100905:	01 c2                	add    %eax,%edx
f0100907:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010090a:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010090e:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100911:	73 37                	jae    f010094a <stab_binsearch+0x7c>
			*region_left = m;
f0100913:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100916:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0100918:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f010091b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100922:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0100925:	7f 4d                	jg     f0100974 <stab_binsearch+0xa6>
		int true_m = (l + r) / 2, m = true_m;
f0100927:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010092a:	01 f0                	add    %esi,%eax
f010092c:	89 c3                	mov    %eax,%ebx
f010092e:	c1 eb 1f             	shr    $0x1f,%ebx
f0100931:	01 c3                	add    %eax,%ebx
f0100933:	d1 fb                	sar    %ebx
f0100935:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100938:	01 d8                	add    %ebx,%eax
f010093a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010093d:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100941:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0100943:	eb af                	jmp    f01008f4 <stab_binsearch+0x26>
			l = true_m + 1;
f0100945:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0100948:	eb d8                	jmp    f0100922 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f010094a:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010094d:	76 12                	jbe    f0100961 <stab_binsearch+0x93>
			*region_right = m - 1;
f010094f:	48                   	dec    %eax
f0100950:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100953:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100956:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0100958:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010095f:	eb c1                	jmp    f0100922 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100961:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100964:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100966:	ff 45 0c             	incl   0xc(%ebp)
f0100969:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f010096b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100972:	eb ae                	jmp    f0100922 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0100974:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100978:	74 18                	je     f0100992 <stab_binsearch+0xc4>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010097a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010097d:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f010097f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100982:	8b 0e                	mov    (%esi),%ecx
f0100984:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100987:	01 c2                	add    %eax,%edx
f0100989:	8b 75 ec             	mov    -0x14(%ebp),%esi
f010098c:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0100990:	eb 0e                	jmp    f01009a0 <stab_binsearch+0xd2>
		*region_right = *region_left - 1;
f0100992:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100995:	8b 00                	mov    (%eax),%eax
f0100997:	48                   	dec    %eax
f0100998:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010099b:	89 07                	mov    %eax,(%edi)
f010099d:	eb 14                	jmp    f01009b3 <stab_binsearch+0xe5>
		     l--)
f010099f:	48                   	dec    %eax
		for (l = *region_right;
f01009a0:	39 c1                	cmp    %eax,%ecx
f01009a2:	7d 0a                	jge    f01009ae <stab_binsearch+0xe0>
		     l > *region_left && stabs[l].n_type != type;
f01009a4:	0f b6 1a             	movzbl (%edx),%ebx
f01009a7:	83 ea 0c             	sub    $0xc,%edx
f01009aa:	39 fb                	cmp    %edi,%ebx
f01009ac:	75 f1                	jne    f010099f <stab_binsearch+0xd1>
			/* do nothing */;
		*region_left = l;
f01009ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01009b1:	89 07                	mov    %eax,(%edi)
	}
}
f01009b3:	83 c4 14             	add    $0x14,%esp
f01009b6:	5b                   	pop    %ebx
f01009b7:	5e                   	pop    %esi
f01009b8:	5f                   	pop    %edi
f01009b9:	5d                   	pop    %ebp
f01009ba:	c3                   	ret    

f01009bb <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01009bb:	55                   	push   %ebp
f01009bc:	89 e5                	mov    %esp,%ebp
f01009be:	57                   	push   %edi
f01009bf:	56                   	push   %esi
f01009c0:	53                   	push   %ebx
f01009c1:	83 ec 1c             	sub    $0x1c,%esp
f01009c4:	8b 7d 08             	mov    0x8(%ebp),%edi
f01009c7:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01009ca:	c7 06 7c 1c 10 f0    	movl   $0xf0101c7c,(%esi)
	info->eip_line = 0;
f01009d0:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f01009d7:	c7 46 08 7c 1c 10 f0 	movl   $0xf0101c7c,0x8(%esi)
	info->eip_fn_namelen = 9;
f01009de:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f01009e5:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f01009e8:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01009ef:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f01009f5:	0f 86 f8 00 00 00    	jbe    f0100af3 <debuginfo_eip+0x138>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01009fb:	b8 7b 72 10 f0       	mov    $0xf010727b,%eax
f0100a00:	3d 59 59 10 f0       	cmp    $0xf0105959,%eax
f0100a05:	0f 86 73 01 00 00    	jbe    f0100b7e <debuginfo_eip+0x1c3>
f0100a0b:	80 3d 7a 72 10 f0 00 	cmpb   $0x0,0xf010727a
f0100a12:	0f 85 6d 01 00 00    	jne    f0100b85 <debuginfo_eip+0x1ca>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100a18:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100a1f:	ba 58 59 10 f0       	mov    $0xf0105958,%edx
f0100a24:	81 ea b4 1e 10 f0    	sub    $0xf0101eb4,%edx
f0100a2a:	c1 fa 02             	sar    $0x2,%edx
f0100a2d:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0100a30:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100a33:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0100a36:	89 c1                	mov    %eax,%ecx
f0100a38:	c1 e1 08             	shl    $0x8,%ecx
f0100a3b:	01 c8                	add    %ecx,%eax
f0100a3d:	89 c1                	mov    %eax,%ecx
f0100a3f:	c1 e1 10             	shl    $0x10,%ecx
f0100a42:	01 c8                	add    %ecx,%eax
f0100a44:	01 c0                	add    %eax,%eax
f0100a46:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
f0100a4a:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100a4d:	83 ec 08             	sub    $0x8,%esp
f0100a50:	57                   	push   %edi
f0100a51:	6a 64                	push   $0x64
f0100a53:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100a56:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100a59:	b8 b4 1e 10 f0       	mov    $0xf0101eb4,%eax
f0100a5e:	e8 6b fe ff ff       	call   f01008ce <stab_binsearch>
	if (lfile == 0)
f0100a63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a66:	83 c4 10             	add    $0x10,%esp
f0100a69:	85 c0                	test   %eax,%eax
f0100a6b:	0f 84 1b 01 00 00    	je     f0100b8c <debuginfo_eip+0x1d1>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100a71:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100a74:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a77:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100a7a:	83 ec 08             	sub    $0x8,%esp
f0100a7d:	57                   	push   %edi
f0100a7e:	6a 24                	push   $0x24
f0100a80:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100a83:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100a86:	b8 b4 1e 10 f0       	mov    $0xf0101eb4,%eax
f0100a8b:	e8 3e fe ff ff       	call   f01008ce <stab_binsearch>

	if (lfun <= rfun) {
f0100a90:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100a93:	83 c4 10             	add    $0x10,%esp
f0100a96:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0100a99:	7f 6c                	jg     f0100b07 <debuginfo_eip+0x14c>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100a9b:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100a9e:	01 d8                	add    %ebx,%eax
f0100aa0:	c1 e0 02             	shl    $0x2,%eax
f0100aa3:	8d 90 b4 1e 10 f0    	lea    -0xfefe14c(%eax),%edx
f0100aa9:	8b 88 b4 1e 10 f0    	mov    -0xfefe14c(%eax),%ecx
f0100aaf:	b8 7b 72 10 f0       	mov    $0xf010727b,%eax
f0100ab4:	2d 59 59 10 f0       	sub    $0xf0105959,%eax
f0100ab9:	39 c1                	cmp    %eax,%ecx
f0100abb:	73 09                	jae    f0100ac6 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100abd:	81 c1 59 59 10 f0    	add    $0xf0105959,%ecx
f0100ac3:	89 4e 08             	mov    %ecx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100ac6:	8b 42 08             	mov    0x8(%edx),%eax
f0100ac9:	89 46 10             	mov    %eax,0x10(%esi)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100acc:	83 ec 08             	sub    $0x8,%esp
f0100acf:	6a 3a                	push   $0x3a
f0100ad1:	ff 76 08             	pushl  0x8(%esi)
f0100ad4:	e8 b5 08 00 00       	call   f010138e <strfind>
f0100ad9:	2b 46 08             	sub    0x8(%esi),%eax
f0100adc:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100adf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100ae2:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100ae5:	01 d8                	add    %ebx,%eax
f0100ae7:	8d 04 85 b8 1e 10 f0 	lea    -0xfefe148(,%eax,4),%eax
f0100aee:	83 c4 10             	add    $0x10,%esp
f0100af1:	eb 20                	jmp    f0100b13 <debuginfo_eip+0x158>
  	        panic("User address");
f0100af3:	83 ec 04             	sub    $0x4,%esp
f0100af6:	68 86 1c 10 f0       	push   $0xf0101c86
f0100afb:	6a 7f                	push   $0x7f
f0100afd:	68 93 1c 10 f0       	push   $0xf0101c93
f0100b02:	e8 df f5 ff ff       	call   f01000e6 <_panic>
		info->eip_fn_addr = addr;
f0100b07:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100b0a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100b0d:	eb bd                	jmp    f0100acc <debuginfo_eip+0x111>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100b0f:	4b                   	dec    %ebx
f0100b10:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0100b13:	39 df                	cmp    %ebx,%edi
f0100b15:	7f 34                	jg     f0100b4b <debuginfo_eip+0x190>
	       && stabs[lline].n_type != N_SOL
f0100b17:	8a 10                	mov    (%eax),%dl
f0100b19:	80 fa 84             	cmp    $0x84,%dl
f0100b1c:	74 0b                	je     f0100b29 <debuginfo_eip+0x16e>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100b1e:	80 fa 64             	cmp    $0x64,%dl
f0100b21:	75 ec                	jne    f0100b0f <debuginfo_eip+0x154>
f0100b23:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100b27:	74 e6                	je     f0100b0f <debuginfo_eip+0x154>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100b29:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100b2c:	01 c3                	add    %eax,%ebx
f0100b2e:	8b 14 9d b4 1e 10 f0 	mov    -0xfefe14c(,%ebx,4),%edx
f0100b35:	b8 7b 72 10 f0       	mov    $0xf010727b,%eax
f0100b3a:	2d 59 59 10 f0       	sub    $0xf0105959,%eax
f0100b3f:	39 c2                	cmp    %eax,%edx
f0100b41:	73 08                	jae    f0100b4b <debuginfo_eip+0x190>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100b43:	81 c2 59 59 10 f0    	add    $0xf0105959,%edx
f0100b49:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100b4b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100b4e:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100b51:	39 c8                	cmp    %ecx,%eax
f0100b53:	7d 3e                	jge    f0100b93 <debuginfo_eip+0x1d8>
		for (lline = lfun + 1;
f0100b55:	8d 50 01             	lea    0x1(%eax),%edx
f0100b58:	8d 1c 00             	lea    (%eax,%eax,1),%ebx
f0100b5b:	01 d8                	add    %ebx,%eax
f0100b5d:	8d 04 85 c4 1e 10 f0 	lea    -0xfefe13c(,%eax,4),%eax
f0100b64:	eb 04                	jmp    f0100b6a <debuginfo_eip+0x1af>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100b66:	ff 46 14             	incl   0x14(%esi)
		     lline++)
f0100b69:	42                   	inc    %edx
		for (lline = lfun + 1;
f0100b6a:	39 d1                	cmp    %edx,%ecx
f0100b6c:	74 32                	je     f0100ba0 <debuginfo_eip+0x1e5>
f0100b6e:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100b71:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0100b75:	74 ef                	je     f0100b66 <debuginfo_eip+0x1ab>

	return 0;
f0100b77:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b7c:	eb 1a                	jmp    f0100b98 <debuginfo_eip+0x1dd>
		return -1;
f0100b7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100b83:	eb 13                	jmp    f0100b98 <debuginfo_eip+0x1dd>
f0100b85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100b8a:	eb 0c                	jmp    f0100b98 <debuginfo_eip+0x1dd>
		return -1;
f0100b8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100b91:	eb 05                	jmp    f0100b98 <debuginfo_eip+0x1dd>
	return 0;
f0100b93:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100b98:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b9b:	5b                   	pop    %ebx
f0100b9c:	5e                   	pop    %esi
f0100b9d:	5f                   	pop    %edi
f0100b9e:	5d                   	pop    %ebp
f0100b9f:	c3                   	ret    
	return 0;
f0100ba0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ba5:	eb f1                	jmp    f0100b98 <debuginfo_eip+0x1dd>

f0100ba7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100ba7:	55                   	push   %ebp
f0100ba8:	89 e5                	mov    %esp,%ebp
f0100baa:	57                   	push   %edi
f0100bab:	56                   	push   %esi
f0100bac:	53                   	push   %ebx
f0100bad:	83 ec 1c             	sub    $0x1c,%esp
f0100bb0:	89 c7                	mov    %eax,%edi
f0100bb2:	89 d6                	mov    %edx,%esi
f0100bb4:	8b 45 08             	mov    0x8(%ebp),%eax
f0100bb7:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100bba:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100bbd:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100bc0:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100bc3:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100bc8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100bcb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100bce:	39 d3                	cmp    %edx,%ebx
f0100bd0:	72 05                	jb     f0100bd7 <printnum+0x30>
f0100bd2:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100bd5:	77 78                	ja     f0100c4f <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100bd7:	83 ec 0c             	sub    $0xc,%esp
f0100bda:	ff 75 18             	pushl  0x18(%ebp)
f0100bdd:	8b 45 14             	mov    0x14(%ebp),%eax
f0100be0:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100be3:	53                   	push   %ebx
f0100be4:	ff 75 10             	pushl  0x10(%ebp)
f0100be7:	83 ec 08             	sub    $0x8,%esp
f0100bea:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100bed:	ff 75 e0             	pushl  -0x20(%ebp)
f0100bf0:	ff 75 dc             	pushl  -0x24(%ebp)
f0100bf3:	ff 75 d8             	pushl  -0x28(%ebp)
f0100bf6:	e8 8d 09 00 00       	call   f0101588 <__udivdi3>
f0100bfb:	83 c4 18             	add    $0x18,%esp
f0100bfe:	52                   	push   %edx
f0100bff:	50                   	push   %eax
f0100c00:	89 f2                	mov    %esi,%edx
f0100c02:	89 f8                	mov    %edi,%eax
f0100c04:	e8 9e ff ff ff       	call   f0100ba7 <printnum>
f0100c09:	83 c4 20             	add    $0x20,%esp
f0100c0c:	eb 11                	jmp    f0100c1f <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100c0e:	83 ec 08             	sub    $0x8,%esp
f0100c11:	56                   	push   %esi
f0100c12:	ff 75 18             	pushl  0x18(%ebp)
f0100c15:	ff d7                	call   *%edi
f0100c17:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100c1a:	4b                   	dec    %ebx
f0100c1b:	85 db                	test   %ebx,%ebx
f0100c1d:	7f ef                	jg     f0100c0e <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100c1f:	83 ec 08             	sub    $0x8,%esp
f0100c22:	56                   	push   %esi
f0100c23:	83 ec 04             	sub    $0x4,%esp
f0100c26:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100c29:	ff 75 e0             	pushl  -0x20(%ebp)
f0100c2c:	ff 75 dc             	pushl  -0x24(%ebp)
f0100c2f:	ff 75 d8             	pushl  -0x28(%ebp)
f0100c32:	e8 51 0a 00 00       	call   f0101688 <__umoddi3>
f0100c37:	83 c4 14             	add    $0x14,%esp
f0100c3a:	0f be 80 a1 1c 10 f0 	movsbl -0xfefe35f(%eax),%eax
f0100c41:	50                   	push   %eax
f0100c42:	ff d7                	call   *%edi
}
f0100c44:	83 c4 10             	add    $0x10,%esp
f0100c47:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c4a:	5b                   	pop    %ebx
f0100c4b:	5e                   	pop    %esi
f0100c4c:	5f                   	pop    %edi
f0100c4d:	5d                   	pop    %ebp
f0100c4e:	c3                   	ret    
f0100c4f:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100c52:	eb c6                	jmp    f0100c1a <printnum+0x73>

f0100c54 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100c54:	55                   	push   %ebp
f0100c55:	89 e5                	mov    %esp,%ebp
f0100c57:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100c5a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0100c5d:	8b 10                	mov    (%eax),%edx
f0100c5f:	3b 50 04             	cmp    0x4(%eax),%edx
f0100c62:	73 0a                	jae    f0100c6e <sprintputch+0x1a>
		*b->buf++ = ch;
f0100c64:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100c67:	89 08                	mov    %ecx,(%eax)
f0100c69:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c6c:	88 02                	mov    %al,(%edx)
}
f0100c6e:	5d                   	pop    %ebp
f0100c6f:	c3                   	ret    

f0100c70 <printfmt>:
{
f0100c70:	55                   	push   %ebp
f0100c71:	89 e5                	mov    %esp,%ebp
f0100c73:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100c76:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100c79:	50                   	push   %eax
f0100c7a:	ff 75 10             	pushl  0x10(%ebp)
f0100c7d:	ff 75 0c             	pushl  0xc(%ebp)
f0100c80:	ff 75 08             	pushl  0x8(%ebp)
f0100c83:	e8 05 00 00 00       	call   f0100c8d <vprintfmt>
}
f0100c88:	83 c4 10             	add    $0x10,%esp
f0100c8b:	c9                   	leave  
f0100c8c:	c3                   	ret    

f0100c8d <vprintfmt>:
{
f0100c8d:	55                   	push   %ebp
f0100c8e:	89 e5                	mov    %esp,%ebp
f0100c90:	57                   	push   %edi
f0100c91:	56                   	push   %esi
f0100c92:	53                   	push   %ebx
f0100c93:	83 ec 2c             	sub    $0x2c,%esp
f0100c96:	8b 75 08             	mov    0x8(%ebp),%esi
f0100c99:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100c9c:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100c9f:	e9 ac 03 00 00       	jmp    f0101050 <vprintfmt+0x3c3>
		padc = ' ';
f0100ca4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0100ca8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0100caf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f0100cb6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0100cbd:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0100cc2:	8d 47 01             	lea    0x1(%edi),%eax
f0100cc5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100cc8:	8a 17                	mov    (%edi),%dl
f0100cca:	8d 42 dd             	lea    -0x23(%edx),%eax
f0100ccd:	3c 55                	cmp    $0x55,%al
f0100ccf:	0f 87 fc 03 00 00    	ja     f01010d1 <vprintfmt+0x444>
f0100cd5:	0f b6 c0             	movzbl %al,%eax
f0100cd8:	ff 24 85 30 1d 10 f0 	jmp    *-0xfefe2d0(,%eax,4)
f0100cdf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0100ce2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0100ce6:	eb da                	jmp    f0100cc2 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0100ce8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0100ceb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100cef:	eb d1                	jmp    f0100cc2 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0100cf1:	0f b6 d2             	movzbl %dl,%edx
f0100cf4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0100cf7:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cfc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0100cff:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100d02:	01 c0                	add    %eax,%eax
f0100d04:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
f0100d08:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0100d0b:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0100d0e:	83 f9 09             	cmp    $0x9,%ecx
f0100d11:	77 52                	ja     f0100d65 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
f0100d13:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
f0100d14:	eb e9                	jmp    f0100cff <vprintfmt+0x72>
			precision = va_arg(ap, int);
f0100d16:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d19:	8b 00                	mov    (%eax),%eax
f0100d1b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100d1e:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d21:	8d 40 04             	lea    0x4(%eax),%eax
f0100d24:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100d27:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0100d2a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100d2e:	79 92                	jns    f0100cc2 <vprintfmt+0x35>
				width = precision, precision = -1;
f0100d30:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100d33:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100d36:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100d3d:	eb 83                	jmp    f0100cc2 <vprintfmt+0x35>
f0100d3f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100d43:	78 08                	js     f0100d4d <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
f0100d45:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100d48:	e9 75 ff ff ff       	jmp    f0100cc2 <vprintfmt+0x35>
f0100d4d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0100d54:	eb ef                	jmp    f0100d45 <vprintfmt+0xb8>
f0100d56:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0100d59:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100d60:	e9 5d ff ff ff       	jmp    f0100cc2 <vprintfmt+0x35>
f0100d65:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100d68:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100d6b:	eb bd                	jmp    f0100d2a <vprintfmt+0x9d>
			lflag++;
f0100d6d:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
f0100d6e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0100d71:	e9 4c ff ff ff       	jmp    f0100cc2 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f0100d76:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d79:	8d 78 04             	lea    0x4(%eax),%edi
f0100d7c:	83 ec 08             	sub    $0x8,%esp
f0100d7f:	53                   	push   %ebx
f0100d80:	ff 30                	pushl  (%eax)
f0100d82:	ff d6                	call   *%esi
			break;
f0100d84:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0100d87:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0100d8a:	e9 be 02 00 00       	jmp    f010104d <vprintfmt+0x3c0>
			err = va_arg(ap, int);
f0100d8f:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d92:	8d 78 04             	lea    0x4(%eax),%edi
f0100d95:	8b 00                	mov    (%eax),%eax
f0100d97:	85 c0                	test   %eax,%eax
f0100d99:	78 2a                	js     f0100dc5 <vprintfmt+0x138>
f0100d9b:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100d9d:	83 f8 06             	cmp    $0x6,%eax
f0100da0:	7f 27                	jg     f0100dc9 <vprintfmt+0x13c>
f0100da2:	8b 04 85 88 1e 10 f0 	mov    -0xfefe178(,%eax,4),%eax
f0100da9:	85 c0                	test   %eax,%eax
f0100dab:	74 1c                	je     f0100dc9 <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
f0100dad:	50                   	push   %eax
f0100dae:	68 c2 1c 10 f0       	push   $0xf0101cc2
f0100db3:	53                   	push   %ebx
f0100db4:	56                   	push   %esi
f0100db5:	e8 b6 fe ff ff       	call   f0100c70 <printfmt>
f0100dba:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100dbd:	89 7d 14             	mov    %edi,0x14(%ebp)
f0100dc0:	e9 88 02 00 00       	jmp    f010104d <vprintfmt+0x3c0>
f0100dc5:	f7 d8                	neg    %eax
f0100dc7:	eb d2                	jmp    f0100d9b <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
f0100dc9:	52                   	push   %edx
f0100dca:	68 b9 1c 10 f0       	push   $0xf0101cb9
f0100dcf:	53                   	push   %ebx
f0100dd0:	56                   	push   %esi
f0100dd1:	e8 9a fe ff ff       	call   f0100c70 <printfmt>
f0100dd6:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100dd9:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0100ddc:	e9 6c 02 00 00       	jmp    f010104d <vprintfmt+0x3c0>
			if ((p = va_arg(ap, char *)) == NULL)
f0100de1:	8b 45 14             	mov    0x14(%ebp),%eax
f0100de4:	83 c0 04             	add    $0x4,%eax
f0100de7:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100dea:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ded:	8b 38                	mov    (%eax),%edi
f0100def:	85 ff                	test   %edi,%edi
f0100df1:	74 18                	je     f0100e0b <vprintfmt+0x17e>
			if (width > 0 && padc != '-')
f0100df3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100df7:	0f 8e b7 00 00 00    	jle    f0100eb4 <vprintfmt+0x227>
f0100dfd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100e01:	75 0f                	jne    f0100e12 <vprintfmt+0x185>
f0100e03:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100e06:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100e09:	eb 6e                	jmp    f0100e79 <vprintfmt+0x1ec>
				p = "(null)";
f0100e0b:	bf b2 1c 10 f0       	mov    $0xf0101cb2,%edi
f0100e10:	eb e1                	jmp    f0100df3 <vprintfmt+0x166>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100e12:	83 ec 08             	sub    $0x8,%esp
f0100e15:	ff 75 d0             	pushl  -0x30(%ebp)
f0100e18:	57                   	push   %edi
f0100e19:	e8 45 04 00 00       	call   f0101263 <strnlen>
f0100e1e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100e21:	29 c1                	sub    %eax,%ecx
f0100e23:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0100e26:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0100e29:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0100e2d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100e30:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100e33:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0100e35:	eb 0d                	jmp    f0100e44 <vprintfmt+0x1b7>
					putch(padc, putdat);
f0100e37:	83 ec 08             	sub    $0x8,%esp
f0100e3a:	53                   	push   %ebx
f0100e3b:	ff 75 e0             	pushl  -0x20(%ebp)
f0100e3e:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0100e40:	4f                   	dec    %edi
f0100e41:	83 c4 10             	add    $0x10,%esp
f0100e44:	85 ff                	test   %edi,%edi
f0100e46:	7f ef                	jg     f0100e37 <vprintfmt+0x1aa>
f0100e48:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100e4b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0100e4e:	89 c8                	mov    %ecx,%eax
f0100e50:	85 c9                	test   %ecx,%ecx
f0100e52:	78 59                	js     f0100ead <vprintfmt+0x220>
f0100e54:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0100e57:	29 c1                	sub    %eax,%ecx
f0100e59:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100e5c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100e5f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100e62:	eb 15                	jmp    f0100e79 <vprintfmt+0x1ec>
				if (altflag && (ch < ' ' || ch > '~'))
f0100e64:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100e68:	75 29                	jne    f0100e93 <vprintfmt+0x206>
					putch(ch, putdat);
f0100e6a:	83 ec 08             	sub    $0x8,%esp
f0100e6d:	ff 75 0c             	pushl  0xc(%ebp)
f0100e70:	50                   	push   %eax
f0100e71:	ff d6                	call   *%esi
f0100e73:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100e76:	ff 4d e0             	decl   -0x20(%ebp)
f0100e79:	47                   	inc    %edi
f0100e7a:	8a 57 ff             	mov    -0x1(%edi),%dl
f0100e7d:	0f be c2             	movsbl %dl,%eax
f0100e80:	85 c0                	test   %eax,%eax
f0100e82:	74 53                	je     f0100ed7 <vprintfmt+0x24a>
f0100e84:	85 db                	test   %ebx,%ebx
f0100e86:	78 dc                	js     f0100e64 <vprintfmt+0x1d7>
f0100e88:	4b                   	dec    %ebx
f0100e89:	79 d9                	jns    f0100e64 <vprintfmt+0x1d7>
f0100e8b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100e8e:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100e91:	eb 35                	jmp    f0100ec8 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
f0100e93:	0f be d2             	movsbl %dl,%edx
f0100e96:	83 ea 20             	sub    $0x20,%edx
f0100e99:	83 fa 5e             	cmp    $0x5e,%edx
f0100e9c:	76 cc                	jbe    f0100e6a <vprintfmt+0x1dd>
					putch('?', putdat);
f0100e9e:	83 ec 08             	sub    $0x8,%esp
f0100ea1:	ff 75 0c             	pushl  0xc(%ebp)
f0100ea4:	6a 3f                	push   $0x3f
f0100ea6:	ff d6                	call   *%esi
f0100ea8:	83 c4 10             	add    $0x10,%esp
f0100eab:	eb c9                	jmp    f0100e76 <vprintfmt+0x1e9>
f0100ead:	b8 00 00 00 00       	mov    $0x0,%eax
f0100eb2:	eb a0                	jmp    f0100e54 <vprintfmt+0x1c7>
f0100eb4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100eb7:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100eba:	eb bd                	jmp    f0100e79 <vprintfmt+0x1ec>
				putch(' ', putdat);
f0100ebc:	83 ec 08             	sub    $0x8,%esp
f0100ebf:	53                   	push   %ebx
f0100ec0:	6a 20                	push   $0x20
f0100ec2:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0100ec4:	4f                   	dec    %edi
f0100ec5:	83 c4 10             	add    $0x10,%esp
f0100ec8:	85 ff                	test   %edi,%edi
f0100eca:	7f f0                	jg     f0100ebc <vprintfmt+0x22f>
			if ((p = va_arg(ap, char *)) == NULL)
f0100ecc:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0100ecf:	89 45 14             	mov    %eax,0x14(%ebp)
f0100ed2:	e9 76 01 00 00       	jmp    f010104d <vprintfmt+0x3c0>
f0100ed7:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100eda:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100edd:	eb e9                	jmp    f0100ec8 <vprintfmt+0x23b>
	if (lflag >= 2)
f0100edf:	83 f9 01             	cmp    $0x1,%ecx
f0100ee2:	7e 3f                	jle    f0100f23 <vprintfmt+0x296>
		return va_arg(*ap, long long);
f0100ee4:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ee7:	8b 50 04             	mov    0x4(%eax),%edx
f0100eea:	8b 00                	mov    (%eax),%eax
f0100eec:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100eef:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100ef2:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ef5:	8d 40 08             	lea    0x8(%eax),%eax
f0100ef8:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0100efb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100eff:	79 5c                	jns    f0100f5d <vprintfmt+0x2d0>
				putch('-', putdat);
f0100f01:	83 ec 08             	sub    $0x8,%esp
f0100f04:	53                   	push   %ebx
f0100f05:	6a 2d                	push   $0x2d
f0100f07:	ff d6                	call   *%esi
				num = -(long long) num;
f0100f09:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100f0c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100f0f:	f7 da                	neg    %edx
f0100f11:	83 d1 00             	adc    $0x0,%ecx
f0100f14:	f7 d9                	neg    %ecx
f0100f16:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0100f19:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100f1e:	e9 10 01 00 00       	jmp    f0101033 <vprintfmt+0x3a6>
	else if (lflag)
f0100f23:	85 c9                	test   %ecx,%ecx
f0100f25:	75 1b                	jne    f0100f42 <vprintfmt+0x2b5>
		return va_arg(*ap, int);
f0100f27:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f2a:	8b 00                	mov    (%eax),%eax
f0100f2c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f2f:	89 c1                	mov    %eax,%ecx
f0100f31:	c1 f9 1f             	sar    $0x1f,%ecx
f0100f34:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100f37:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f3a:	8d 40 04             	lea    0x4(%eax),%eax
f0100f3d:	89 45 14             	mov    %eax,0x14(%ebp)
f0100f40:	eb b9                	jmp    f0100efb <vprintfmt+0x26e>
		return va_arg(*ap, long);
f0100f42:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f45:	8b 00                	mov    (%eax),%eax
f0100f47:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f4a:	89 c1                	mov    %eax,%ecx
f0100f4c:	c1 f9 1f             	sar    $0x1f,%ecx
f0100f4f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100f52:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f55:	8d 40 04             	lea    0x4(%eax),%eax
f0100f58:	89 45 14             	mov    %eax,0x14(%ebp)
f0100f5b:	eb 9e                	jmp    f0100efb <vprintfmt+0x26e>
			num = getint(&ap, lflag);
f0100f5d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100f60:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0100f63:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100f68:	e9 c6 00 00 00       	jmp    f0101033 <vprintfmt+0x3a6>
	if (lflag >= 2)
f0100f6d:	83 f9 01             	cmp    $0x1,%ecx
f0100f70:	7e 18                	jle    f0100f8a <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
f0100f72:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f75:	8b 10                	mov    (%eax),%edx
f0100f77:	8b 48 04             	mov    0x4(%eax),%ecx
f0100f7a:	8d 40 08             	lea    0x8(%eax),%eax
f0100f7d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0100f80:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100f85:	e9 a9 00 00 00       	jmp    f0101033 <vprintfmt+0x3a6>
	else if (lflag)
f0100f8a:	85 c9                	test   %ecx,%ecx
f0100f8c:	75 1a                	jne    f0100fa8 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned int);
f0100f8e:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f91:	8b 10                	mov    (%eax),%edx
f0100f93:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100f98:	8d 40 04             	lea    0x4(%eax),%eax
f0100f9b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0100f9e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100fa3:	e9 8b 00 00 00       	jmp    f0101033 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0100fa8:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fab:	8b 10                	mov    (%eax),%edx
f0100fad:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100fb2:	8d 40 04             	lea    0x4(%eax),%eax
f0100fb5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0100fb8:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100fbd:	eb 74                	jmp    f0101033 <vprintfmt+0x3a6>
	if (lflag >= 2)
f0100fbf:	83 f9 01             	cmp    $0x1,%ecx
f0100fc2:	7e 15                	jle    f0100fd9 <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
f0100fc4:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fc7:	8b 10                	mov    (%eax),%edx
f0100fc9:	8b 48 04             	mov    0x4(%eax),%ecx
f0100fcc:	8d 40 08             	lea    0x8(%eax),%eax
f0100fcf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0100fd2:	b8 08 00 00 00       	mov    $0x8,%eax
f0100fd7:	eb 5a                	jmp    f0101033 <vprintfmt+0x3a6>
	else if (lflag)
f0100fd9:	85 c9                	test   %ecx,%ecx
f0100fdb:	75 17                	jne    f0100ff4 <vprintfmt+0x367>
		return va_arg(*ap, unsigned int);
f0100fdd:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fe0:	8b 10                	mov    (%eax),%edx
f0100fe2:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100fe7:	8d 40 04             	lea    0x4(%eax),%eax
f0100fea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0100fed:	b8 08 00 00 00       	mov    $0x8,%eax
f0100ff2:	eb 3f                	jmp    f0101033 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0100ff4:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ff7:	8b 10                	mov    (%eax),%edx
f0100ff9:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100ffe:	8d 40 04             	lea    0x4(%eax),%eax
f0101001:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101004:	b8 08 00 00 00       	mov    $0x8,%eax
f0101009:	eb 28                	jmp    f0101033 <vprintfmt+0x3a6>
			putch('0', putdat);
f010100b:	83 ec 08             	sub    $0x8,%esp
f010100e:	53                   	push   %ebx
f010100f:	6a 30                	push   $0x30
f0101011:	ff d6                	call   *%esi
			putch('x', putdat);
f0101013:	83 c4 08             	add    $0x8,%esp
f0101016:	53                   	push   %ebx
f0101017:	6a 78                	push   $0x78
f0101019:	ff d6                	call   *%esi
			num = (unsigned long long)
f010101b:	8b 45 14             	mov    0x14(%ebp),%eax
f010101e:	8b 10                	mov    (%eax),%edx
f0101020:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0101025:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0101028:	8d 40 04             	lea    0x4(%eax),%eax
f010102b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010102e:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0101033:	83 ec 0c             	sub    $0xc,%esp
f0101036:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f010103a:	57                   	push   %edi
f010103b:	ff 75 e0             	pushl  -0x20(%ebp)
f010103e:	50                   	push   %eax
f010103f:	51                   	push   %ecx
f0101040:	52                   	push   %edx
f0101041:	89 da                	mov    %ebx,%edx
f0101043:	89 f0                	mov    %esi,%eax
f0101045:	e8 5d fb ff ff       	call   f0100ba7 <printnum>
			break;
f010104a:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f010104d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101050:	47                   	inc    %edi
f0101051:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101055:	83 f8 25             	cmp    $0x25,%eax
f0101058:	0f 84 46 fc ff ff    	je     f0100ca4 <vprintfmt+0x17>
			if (ch == '\0')
f010105e:	85 c0                	test   %eax,%eax
f0101060:	0f 84 89 00 00 00    	je     f01010ef <vprintfmt+0x462>
			putch(ch, putdat);
f0101066:	83 ec 08             	sub    $0x8,%esp
f0101069:	53                   	push   %ebx
f010106a:	50                   	push   %eax
f010106b:	ff d6                	call   *%esi
f010106d:	83 c4 10             	add    $0x10,%esp
f0101070:	eb de                	jmp    f0101050 <vprintfmt+0x3c3>
	if (lflag >= 2)
f0101072:	83 f9 01             	cmp    $0x1,%ecx
f0101075:	7e 15                	jle    f010108c <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
f0101077:	8b 45 14             	mov    0x14(%ebp),%eax
f010107a:	8b 10                	mov    (%eax),%edx
f010107c:	8b 48 04             	mov    0x4(%eax),%ecx
f010107f:	8d 40 08             	lea    0x8(%eax),%eax
f0101082:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101085:	b8 10 00 00 00       	mov    $0x10,%eax
f010108a:	eb a7                	jmp    f0101033 <vprintfmt+0x3a6>
	else if (lflag)
f010108c:	85 c9                	test   %ecx,%ecx
f010108e:	75 17                	jne    f01010a7 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned int);
f0101090:	8b 45 14             	mov    0x14(%ebp),%eax
f0101093:	8b 10                	mov    (%eax),%edx
f0101095:	b9 00 00 00 00       	mov    $0x0,%ecx
f010109a:	8d 40 04             	lea    0x4(%eax),%eax
f010109d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01010a0:	b8 10 00 00 00       	mov    $0x10,%eax
f01010a5:	eb 8c                	jmp    f0101033 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f01010a7:	8b 45 14             	mov    0x14(%ebp),%eax
f01010aa:	8b 10                	mov    (%eax),%edx
f01010ac:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010b1:	8d 40 04             	lea    0x4(%eax),%eax
f01010b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01010b7:	b8 10 00 00 00       	mov    $0x10,%eax
f01010bc:	e9 72 ff ff ff       	jmp    f0101033 <vprintfmt+0x3a6>
			putch(ch, putdat);
f01010c1:	83 ec 08             	sub    $0x8,%esp
f01010c4:	53                   	push   %ebx
f01010c5:	6a 25                	push   $0x25
f01010c7:	ff d6                	call   *%esi
			break;
f01010c9:	83 c4 10             	add    $0x10,%esp
f01010cc:	e9 7c ff ff ff       	jmp    f010104d <vprintfmt+0x3c0>
			putch('%', putdat);
f01010d1:	83 ec 08             	sub    $0x8,%esp
f01010d4:	53                   	push   %ebx
f01010d5:	6a 25                	push   $0x25
f01010d7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01010d9:	83 c4 10             	add    $0x10,%esp
f01010dc:	89 f8                	mov    %edi,%eax
f01010de:	eb 01                	jmp    f01010e1 <vprintfmt+0x454>
f01010e0:	48                   	dec    %eax
f01010e1:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01010e5:	75 f9                	jne    f01010e0 <vprintfmt+0x453>
f01010e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01010ea:	e9 5e ff ff ff       	jmp    f010104d <vprintfmt+0x3c0>
}
f01010ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010f2:	5b                   	pop    %ebx
f01010f3:	5e                   	pop    %esi
f01010f4:	5f                   	pop    %edi
f01010f5:	5d                   	pop    %ebp
f01010f6:	c3                   	ret    

f01010f7 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01010f7:	55                   	push   %ebp
f01010f8:	89 e5                	mov    %esp,%ebp
f01010fa:	83 ec 18             	sub    $0x18,%esp
f01010fd:	8b 45 08             	mov    0x8(%ebp),%eax
f0101100:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101103:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101106:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010110a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010110d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101114:	85 c0                	test   %eax,%eax
f0101116:	74 26                	je     f010113e <vsnprintf+0x47>
f0101118:	85 d2                	test   %edx,%edx
f010111a:	7e 29                	jle    f0101145 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010111c:	ff 75 14             	pushl  0x14(%ebp)
f010111f:	ff 75 10             	pushl  0x10(%ebp)
f0101122:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101125:	50                   	push   %eax
f0101126:	68 54 0c 10 f0       	push   $0xf0100c54
f010112b:	e8 5d fb ff ff       	call   f0100c8d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101130:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101133:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101136:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101139:	83 c4 10             	add    $0x10,%esp
}
f010113c:	c9                   	leave  
f010113d:	c3                   	ret    
		return -E_INVAL;
f010113e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101143:	eb f7                	jmp    f010113c <vsnprintf+0x45>
f0101145:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010114a:	eb f0                	jmp    f010113c <vsnprintf+0x45>

f010114c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010114c:	55                   	push   %ebp
f010114d:	89 e5                	mov    %esp,%ebp
f010114f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101152:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101155:	50                   	push   %eax
f0101156:	ff 75 10             	pushl  0x10(%ebp)
f0101159:	ff 75 0c             	pushl  0xc(%ebp)
f010115c:	ff 75 08             	pushl  0x8(%ebp)
f010115f:	e8 93 ff ff ff       	call   f01010f7 <vsnprintf>
	va_end(ap);

	return rc;
}
f0101164:	c9                   	leave  
f0101165:	c3                   	ret    

f0101166 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101166:	55                   	push   %ebp
f0101167:	89 e5                	mov    %esp,%ebp
f0101169:	57                   	push   %edi
f010116a:	56                   	push   %esi
f010116b:	53                   	push   %ebx
f010116c:	83 ec 0c             	sub    $0xc,%esp
f010116f:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101172:	85 c0                	test   %eax,%eax
f0101174:	74 11                	je     f0101187 <readline+0x21>
		cprintf("%s", prompt);
f0101176:	83 ec 08             	sub    $0x8,%esp
f0101179:	50                   	push   %eax
f010117a:	68 c2 1c 10 f0       	push   $0xf0101cc2
f010117f:	e8 36 f7 ff ff       	call   f01008ba <cprintf>
f0101184:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101187:	83 ec 0c             	sub    $0xc,%esp
f010118a:	6a 00                	push   $0x0
f010118c:	e8 c9 f4 ff ff       	call   f010065a <iscons>
f0101191:	89 c7                	mov    %eax,%edi
f0101193:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0101196:	be 00 00 00 00       	mov    $0x0,%esi
f010119b:	eb 6f                	jmp    f010120c <readline+0xa6>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f010119d:	83 ec 08             	sub    $0x8,%esp
f01011a0:	50                   	push   %eax
f01011a1:	68 a4 1e 10 f0       	push   $0xf0101ea4
f01011a6:	e8 0f f7 ff ff       	call   f01008ba <cprintf>
			return NULL;
f01011ab:	83 c4 10             	add    $0x10,%esp
f01011ae:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01011b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011b6:	5b                   	pop    %ebx
f01011b7:	5e                   	pop    %esi
f01011b8:	5f                   	pop    %edi
f01011b9:	5d                   	pop    %ebp
f01011ba:	c3                   	ret    
				cputchar('\b');
f01011bb:	83 ec 0c             	sub    $0xc,%esp
f01011be:	6a 08                	push   $0x8
f01011c0:	e8 74 f4 ff ff       	call   f0100639 <cputchar>
f01011c5:	83 c4 10             	add    $0x10,%esp
f01011c8:	eb 41                	jmp    f010120b <readline+0xa5>
				cputchar(c);
f01011ca:	83 ec 0c             	sub    $0xc,%esp
f01011cd:	53                   	push   %ebx
f01011ce:	e8 66 f4 ff ff       	call   f0100639 <cputchar>
f01011d3:	83 c4 10             	add    $0x10,%esp
f01011d6:	eb 5a                	jmp    f0101232 <readline+0xcc>
		} else if (c == '\n' || c == '\r') {
f01011d8:	83 fb 0a             	cmp    $0xa,%ebx
f01011db:	74 05                	je     f01011e2 <readline+0x7c>
f01011dd:	83 fb 0d             	cmp    $0xd,%ebx
f01011e0:	75 2a                	jne    f010120c <readline+0xa6>
			if (echoing)
f01011e2:	85 ff                	test   %edi,%edi
f01011e4:	75 0e                	jne    f01011f4 <readline+0x8e>
			buf[i] = 0;
f01011e6:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f01011ed:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
f01011f2:	eb bf                	jmp    f01011b3 <readline+0x4d>
				cputchar('\n');
f01011f4:	83 ec 0c             	sub    $0xc,%esp
f01011f7:	6a 0a                	push   $0xa
f01011f9:	e8 3b f4 ff ff       	call   f0100639 <cputchar>
f01011fe:	83 c4 10             	add    $0x10,%esp
f0101201:	eb e3                	jmp    f01011e6 <readline+0x80>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101203:	85 f6                	test   %esi,%esi
f0101205:	7e 3c                	jle    f0101243 <readline+0xdd>
			if (echoing)
f0101207:	85 ff                	test   %edi,%edi
f0101209:	75 b0                	jne    f01011bb <readline+0x55>
			i--;
f010120b:	4e                   	dec    %esi
		c = getchar();
f010120c:	e8 38 f4 ff ff       	call   f0100649 <getchar>
f0101211:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0101213:	85 c0                	test   %eax,%eax
f0101215:	78 86                	js     f010119d <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101217:	83 f8 08             	cmp    $0x8,%eax
f010121a:	74 21                	je     f010123d <readline+0xd7>
f010121c:	83 f8 7f             	cmp    $0x7f,%eax
f010121f:	74 e2                	je     f0101203 <readline+0x9d>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101221:	83 f8 1f             	cmp    $0x1f,%eax
f0101224:	7e b2                	jle    f01011d8 <readline+0x72>
f0101226:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010122c:	7f aa                	jg     f01011d8 <readline+0x72>
			if (echoing)
f010122e:	85 ff                	test   %edi,%edi
f0101230:	75 98                	jne    f01011ca <readline+0x64>
			buf[i++] = c;
f0101232:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f0101238:	8d 76 01             	lea    0x1(%esi),%esi
f010123b:	eb cf                	jmp    f010120c <readline+0xa6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010123d:	85 f6                	test   %esi,%esi
f010123f:	7e cb                	jle    f010120c <readline+0xa6>
f0101241:	eb c4                	jmp    f0101207 <readline+0xa1>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101243:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101249:	7e e3                	jle    f010122e <readline+0xc8>
f010124b:	eb bf                	jmp    f010120c <readline+0xa6>

f010124d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010124d:	55                   	push   %ebp
f010124e:	89 e5                	mov    %esp,%ebp
f0101250:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101253:	b8 00 00 00 00       	mov    $0x0,%eax
f0101258:	eb 01                	jmp    f010125b <strlen+0xe>
		n++;
f010125a:	40                   	inc    %eax
	for (n = 0; *s != '\0'; s++)
f010125b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010125f:	75 f9                	jne    f010125a <strlen+0xd>
	return n;
}
f0101261:	5d                   	pop    %ebp
f0101262:	c3                   	ret    

f0101263 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101263:	55                   	push   %ebp
f0101264:	89 e5                	mov    %esp,%ebp
f0101266:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101269:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010126c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101271:	eb 01                	jmp    f0101274 <strnlen+0x11>
		n++;
f0101273:	40                   	inc    %eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101274:	39 d0                	cmp    %edx,%eax
f0101276:	74 06                	je     f010127e <strnlen+0x1b>
f0101278:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010127c:	75 f5                	jne    f0101273 <strnlen+0x10>
	return n;
}
f010127e:	5d                   	pop    %ebp
f010127f:	c3                   	ret    

f0101280 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101280:	55                   	push   %ebp
f0101281:	89 e5                	mov    %esp,%ebp
f0101283:	53                   	push   %ebx
f0101284:	8b 45 08             	mov    0x8(%ebp),%eax
f0101287:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010128a:	89 c2                	mov    %eax,%edx
f010128c:	41                   	inc    %ecx
f010128d:	42                   	inc    %edx
f010128e:	8a 59 ff             	mov    -0x1(%ecx),%bl
f0101291:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101294:	84 db                	test   %bl,%bl
f0101296:	75 f4                	jne    f010128c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101298:	5b                   	pop    %ebx
f0101299:	5d                   	pop    %ebp
f010129a:	c3                   	ret    

f010129b <strcat>:

char *
strcat(char *dst, const char *src)
{
f010129b:	55                   	push   %ebp
f010129c:	89 e5                	mov    %esp,%ebp
f010129e:	53                   	push   %ebx
f010129f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01012a2:	53                   	push   %ebx
f01012a3:	e8 a5 ff ff ff       	call   f010124d <strlen>
f01012a8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01012ab:	ff 75 0c             	pushl  0xc(%ebp)
f01012ae:	01 d8                	add    %ebx,%eax
f01012b0:	50                   	push   %eax
f01012b1:	e8 ca ff ff ff       	call   f0101280 <strcpy>
	return dst;
}
f01012b6:	89 d8                	mov    %ebx,%eax
f01012b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01012bb:	c9                   	leave  
f01012bc:	c3                   	ret    

f01012bd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01012bd:	55                   	push   %ebp
f01012be:	89 e5                	mov    %esp,%ebp
f01012c0:	56                   	push   %esi
f01012c1:	53                   	push   %ebx
f01012c2:	8b 75 08             	mov    0x8(%ebp),%esi
f01012c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01012c8:	89 f3                	mov    %esi,%ebx
f01012ca:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01012cd:	89 f2                	mov    %esi,%edx
f01012cf:	39 da                	cmp    %ebx,%edx
f01012d1:	74 0e                	je     f01012e1 <strncpy+0x24>
		*dst++ = *src;
f01012d3:	42                   	inc    %edx
f01012d4:	8a 01                	mov    (%ecx),%al
f01012d6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f01012d9:	80 39 00             	cmpb   $0x0,(%ecx)
f01012dc:	74 f1                	je     f01012cf <strncpy+0x12>
			src++;
f01012de:	41                   	inc    %ecx
f01012df:	eb ee                	jmp    f01012cf <strncpy+0x12>
	}
	return ret;
}
f01012e1:	89 f0                	mov    %esi,%eax
f01012e3:	5b                   	pop    %ebx
f01012e4:	5e                   	pop    %esi
f01012e5:	5d                   	pop    %ebp
f01012e6:	c3                   	ret    

f01012e7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01012e7:	55                   	push   %ebp
f01012e8:	89 e5                	mov    %esp,%ebp
f01012ea:	56                   	push   %esi
f01012eb:	53                   	push   %ebx
f01012ec:	8b 75 08             	mov    0x8(%ebp),%esi
f01012ef:	8b 55 0c             	mov    0xc(%ebp),%edx
f01012f2:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01012f5:	85 c0                	test   %eax,%eax
f01012f7:	74 20                	je     f0101319 <strlcpy+0x32>
f01012f9:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
f01012fd:	89 f0                	mov    %esi,%eax
f01012ff:	eb 05                	jmp    f0101306 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101301:	42                   	inc    %edx
f0101302:	40                   	inc    %eax
f0101303:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0101306:	39 d8                	cmp    %ebx,%eax
f0101308:	74 06                	je     f0101310 <strlcpy+0x29>
f010130a:	8a 0a                	mov    (%edx),%cl
f010130c:	84 c9                	test   %cl,%cl
f010130e:	75 f1                	jne    f0101301 <strlcpy+0x1a>
		*dst = '\0';
f0101310:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101313:	29 f0                	sub    %esi,%eax
}
f0101315:	5b                   	pop    %ebx
f0101316:	5e                   	pop    %esi
f0101317:	5d                   	pop    %ebp
f0101318:	c3                   	ret    
f0101319:	89 f0                	mov    %esi,%eax
f010131b:	eb f6                	jmp    f0101313 <strlcpy+0x2c>

f010131d <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010131d:	55                   	push   %ebp
f010131e:	89 e5                	mov    %esp,%ebp
f0101320:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101323:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101326:	eb 02                	jmp    f010132a <strcmp+0xd>
		p++, q++;
f0101328:	41                   	inc    %ecx
f0101329:	42                   	inc    %edx
	while (*p && *p == *q)
f010132a:	8a 01                	mov    (%ecx),%al
f010132c:	84 c0                	test   %al,%al
f010132e:	74 04                	je     f0101334 <strcmp+0x17>
f0101330:	3a 02                	cmp    (%edx),%al
f0101332:	74 f4                	je     f0101328 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101334:	0f b6 c0             	movzbl %al,%eax
f0101337:	0f b6 12             	movzbl (%edx),%edx
f010133a:	29 d0                	sub    %edx,%eax
}
f010133c:	5d                   	pop    %ebp
f010133d:	c3                   	ret    

f010133e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010133e:	55                   	push   %ebp
f010133f:	89 e5                	mov    %esp,%ebp
f0101341:	53                   	push   %ebx
f0101342:	8b 45 08             	mov    0x8(%ebp),%eax
f0101345:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101348:	89 c3                	mov    %eax,%ebx
f010134a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010134d:	eb 02                	jmp    f0101351 <strncmp+0x13>
		n--, p++, q++;
f010134f:	40                   	inc    %eax
f0101350:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
f0101351:	39 d8                	cmp    %ebx,%eax
f0101353:	74 15                	je     f010136a <strncmp+0x2c>
f0101355:	8a 08                	mov    (%eax),%cl
f0101357:	84 c9                	test   %cl,%cl
f0101359:	74 04                	je     f010135f <strncmp+0x21>
f010135b:	3a 0a                	cmp    (%edx),%cl
f010135d:	74 f0                	je     f010134f <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010135f:	0f b6 00             	movzbl (%eax),%eax
f0101362:	0f b6 12             	movzbl (%edx),%edx
f0101365:	29 d0                	sub    %edx,%eax
}
f0101367:	5b                   	pop    %ebx
f0101368:	5d                   	pop    %ebp
f0101369:	c3                   	ret    
		return 0;
f010136a:	b8 00 00 00 00       	mov    $0x0,%eax
f010136f:	eb f6                	jmp    f0101367 <strncmp+0x29>

f0101371 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101371:	55                   	push   %ebp
f0101372:	89 e5                	mov    %esp,%ebp
f0101374:	8b 45 08             	mov    0x8(%ebp),%eax
f0101377:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f010137a:	8a 10                	mov    (%eax),%dl
f010137c:	84 d2                	test   %dl,%dl
f010137e:	74 07                	je     f0101387 <strchr+0x16>
		if (*s == c)
f0101380:	38 ca                	cmp    %cl,%dl
f0101382:	74 08                	je     f010138c <strchr+0x1b>
	for (; *s; s++)
f0101384:	40                   	inc    %eax
f0101385:	eb f3                	jmp    f010137a <strchr+0x9>
			return (char *) s;
	return 0;
f0101387:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010138c:	5d                   	pop    %ebp
f010138d:	c3                   	ret    

f010138e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010138e:	55                   	push   %ebp
f010138f:	89 e5                	mov    %esp,%ebp
f0101391:	8b 45 08             	mov    0x8(%ebp),%eax
f0101394:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0101397:	8a 10                	mov    (%eax),%dl
f0101399:	84 d2                	test   %dl,%dl
f010139b:	74 07                	je     f01013a4 <strfind+0x16>
		if (*s == c)
f010139d:	38 ca                	cmp    %cl,%dl
f010139f:	74 03                	je     f01013a4 <strfind+0x16>
	for (; *s; s++)
f01013a1:	40                   	inc    %eax
f01013a2:	eb f3                	jmp    f0101397 <strfind+0x9>
			break;
	return (char *) s;
}
f01013a4:	5d                   	pop    %ebp
f01013a5:	c3                   	ret    

f01013a6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01013a6:	55                   	push   %ebp
f01013a7:	89 e5                	mov    %esp,%ebp
f01013a9:	57                   	push   %edi
f01013aa:	56                   	push   %esi
f01013ab:	53                   	push   %ebx
f01013ac:	8b 7d 08             	mov    0x8(%ebp),%edi
f01013af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01013b2:	85 c9                	test   %ecx,%ecx
f01013b4:	74 13                	je     f01013c9 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01013b6:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01013bc:	75 05                	jne    f01013c3 <memset+0x1d>
f01013be:	f6 c1 03             	test   $0x3,%cl
f01013c1:	74 0d                	je     f01013d0 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01013c3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01013c6:	fc                   	cld    
f01013c7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01013c9:	89 f8                	mov    %edi,%eax
f01013cb:	5b                   	pop    %ebx
f01013cc:	5e                   	pop    %esi
f01013cd:	5f                   	pop    %edi
f01013ce:	5d                   	pop    %ebp
f01013cf:	c3                   	ret    
		c &= 0xFF;
f01013d0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01013d4:	89 d3                	mov    %edx,%ebx
f01013d6:	c1 e3 08             	shl    $0x8,%ebx
f01013d9:	89 d0                	mov    %edx,%eax
f01013db:	c1 e0 18             	shl    $0x18,%eax
f01013de:	89 d6                	mov    %edx,%esi
f01013e0:	c1 e6 10             	shl    $0x10,%esi
f01013e3:	09 f0                	or     %esi,%eax
f01013e5:	09 c2                	or     %eax,%edx
f01013e7:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f01013e9:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01013ec:	89 d0                	mov    %edx,%eax
f01013ee:	fc                   	cld    
f01013ef:	f3 ab                	rep stos %eax,%es:(%edi)
f01013f1:	eb d6                	jmp    f01013c9 <memset+0x23>

f01013f3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01013f3:	55                   	push   %ebp
f01013f4:	89 e5                	mov    %esp,%ebp
f01013f6:	57                   	push   %edi
f01013f7:	56                   	push   %esi
f01013f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01013fb:	8b 75 0c             	mov    0xc(%ebp),%esi
f01013fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101401:	39 c6                	cmp    %eax,%esi
f0101403:	73 33                	jae    f0101438 <memmove+0x45>
f0101405:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101408:	39 c2                	cmp    %eax,%edx
f010140a:	76 2c                	jbe    f0101438 <memmove+0x45>
		s += n;
		d += n;
f010140c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010140f:	89 d6                	mov    %edx,%esi
f0101411:	09 fe                	or     %edi,%esi
f0101413:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101419:	74 0a                	je     f0101425 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010141b:	4f                   	dec    %edi
f010141c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f010141f:	fd                   	std    
f0101420:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101422:	fc                   	cld    
f0101423:	eb 21                	jmp    f0101446 <memmove+0x53>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101425:	f6 c1 03             	test   $0x3,%cl
f0101428:	75 f1                	jne    f010141b <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010142a:	83 ef 04             	sub    $0x4,%edi
f010142d:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101430:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0101433:	fd                   	std    
f0101434:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101436:	eb ea                	jmp    f0101422 <memmove+0x2f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101438:	89 f2                	mov    %esi,%edx
f010143a:	09 c2                	or     %eax,%edx
f010143c:	f6 c2 03             	test   $0x3,%dl
f010143f:	74 09                	je     f010144a <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101441:	89 c7                	mov    %eax,%edi
f0101443:	fc                   	cld    
f0101444:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101446:	5e                   	pop    %esi
f0101447:	5f                   	pop    %edi
f0101448:	5d                   	pop    %ebp
f0101449:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010144a:	f6 c1 03             	test   $0x3,%cl
f010144d:	75 f2                	jne    f0101441 <memmove+0x4e>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010144f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0101452:	89 c7                	mov    %eax,%edi
f0101454:	fc                   	cld    
f0101455:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101457:	eb ed                	jmp    f0101446 <memmove+0x53>

f0101459 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101459:	55                   	push   %ebp
f010145a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010145c:	ff 75 10             	pushl  0x10(%ebp)
f010145f:	ff 75 0c             	pushl  0xc(%ebp)
f0101462:	ff 75 08             	pushl  0x8(%ebp)
f0101465:	e8 89 ff ff ff       	call   f01013f3 <memmove>
}
f010146a:	c9                   	leave  
f010146b:	c3                   	ret    

f010146c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010146c:	55                   	push   %ebp
f010146d:	89 e5                	mov    %esp,%ebp
f010146f:	56                   	push   %esi
f0101470:	53                   	push   %ebx
f0101471:	8b 45 08             	mov    0x8(%ebp),%eax
f0101474:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101477:	89 c6                	mov    %eax,%esi
f0101479:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010147c:	39 f0                	cmp    %esi,%eax
f010147e:	74 16                	je     f0101496 <memcmp+0x2a>
		if (*s1 != *s2)
f0101480:	8a 08                	mov    (%eax),%cl
f0101482:	8a 1a                	mov    (%edx),%bl
f0101484:	38 d9                	cmp    %bl,%cl
f0101486:	75 04                	jne    f010148c <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0101488:	40                   	inc    %eax
f0101489:	42                   	inc    %edx
f010148a:	eb f0                	jmp    f010147c <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f010148c:	0f b6 c1             	movzbl %cl,%eax
f010148f:	0f b6 db             	movzbl %bl,%ebx
f0101492:	29 d8                	sub    %ebx,%eax
f0101494:	eb 05                	jmp    f010149b <memcmp+0x2f>
	}

	return 0;
f0101496:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010149b:	5b                   	pop    %ebx
f010149c:	5e                   	pop    %esi
f010149d:	5d                   	pop    %ebp
f010149e:	c3                   	ret    

f010149f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010149f:	55                   	push   %ebp
f01014a0:	89 e5                	mov    %esp,%ebp
f01014a2:	8b 45 08             	mov    0x8(%ebp),%eax
f01014a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01014a8:	89 c2                	mov    %eax,%edx
f01014aa:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01014ad:	39 d0                	cmp    %edx,%eax
f01014af:	73 07                	jae    f01014b8 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
f01014b1:	38 08                	cmp    %cl,(%eax)
f01014b3:	74 03                	je     f01014b8 <memfind+0x19>
	for (; s < ends; s++)
f01014b5:	40                   	inc    %eax
f01014b6:	eb f5                	jmp    f01014ad <memfind+0xe>
			break;
	return (void *) s;
}
f01014b8:	5d                   	pop    %ebp
f01014b9:	c3                   	ret    

f01014ba <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01014ba:	55                   	push   %ebp
f01014bb:	89 e5                	mov    %esp,%ebp
f01014bd:	57                   	push   %edi
f01014be:	56                   	push   %esi
f01014bf:	53                   	push   %ebx
f01014c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01014c3:	eb 01                	jmp    f01014c6 <strtol+0xc>
		s++;
f01014c5:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f01014c6:	8a 01                	mov    (%ecx),%al
f01014c8:	3c 20                	cmp    $0x20,%al
f01014ca:	74 f9                	je     f01014c5 <strtol+0xb>
f01014cc:	3c 09                	cmp    $0x9,%al
f01014ce:	74 f5                	je     f01014c5 <strtol+0xb>

	// plus/minus sign
	if (*s == '+')
f01014d0:	3c 2b                	cmp    $0x2b,%al
f01014d2:	74 2b                	je     f01014ff <strtol+0x45>
		s++;
	else if (*s == '-')
f01014d4:	3c 2d                	cmp    $0x2d,%al
f01014d6:	74 2f                	je     f0101507 <strtol+0x4d>
	int neg = 0;
f01014d8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01014dd:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f01014e4:	75 12                	jne    f01014f8 <strtol+0x3e>
f01014e6:	80 39 30             	cmpb   $0x30,(%ecx)
f01014e9:	74 24                	je     f010150f <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01014eb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01014ef:	75 07                	jne    f01014f8 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01014f1:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f01014f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01014fd:	eb 4e                	jmp    f010154d <strtol+0x93>
		s++;
f01014ff:	41                   	inc    %ecx
	int neg = 0;
f0101500:	bf 00 00 00 00       	mov    $0x0,%edi
f0101505:	eb d6                	jmp    f01014dd <strtol+0x23>
		s++, neg = 1;
f0101507:	41                   	inc    %ecx
f0101508:	bf 01 00 00 00       	mov    $0x1,%edi
f010150d:	eb ce                	jmp    f01014dd <strtol+0x23>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010150f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101513:	74 10                	je     f0101525 <strtol+0x6b>
	else if (base == 0 && s[0] == '0')
f0101515:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101519:	75 dd                	jne    f01014f8 <strtol+0x3e>
		s++, base = 8;
f010151b:	41                   	inc    %ecx
f010151c:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f0101523:	eb d3                	jmp    f01014f8 <strtol+0x3e>
		s += 2, base = 16;
f0101525:	83 c1 02             	add    $0x2,%ecx
f0101528:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f010152f:	eb c7                	jmp    f01014f8 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0101531:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101534:	89 f3                	mov    %esi,%ebx
f0101536:	80 fb 19             	cmp    $0x19,%bl
f0101539:	77 24                	ja     f010155f <strtol+0xa5>
			dig = *s - 'a' + 10;
f010153b:	0f be d2             	movsbl %dl,%edx
f010153e:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101541:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101544:	7d 2b                	jge    f0101571 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
f0101546:	41                   	inc    %ecx
f0101547:	0f af 45 10          	imul   0x10(%ebp),%eax
f010154b:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f010154d:	8a 11                	mov    (%ecx),%dl
f010154f:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0101552:	80 fb 09             	cmp    $0x9,%bl
f0101555:	77 da                	ja     f0101531 <strtol+0x77>
			dig = *s - '0';
f0101557:	0f be d2             	movsbl %dl,%edx
f010155a:	83 ea 30             	sub    $0x30,%edx
f010155d:	eb e2                	jmp    f0101541 <strtol+0x87>
		else if (*s >= 'A' && *s <= 'Z')
f010155f:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101562:	89 f3                	mov    %esi,%ebx
f0101564:	80 fb 19             	cmp    $0x19,%bl
f0101567:	77 08                	ja     f0101571 <strtol+0xb7>
			dig = *s - 'A' + 10;
f0101569:	0f be d2             	movsbl %dl,%edx
f010156c:	83 ea 37             	sub    $0x37,%edx
f010156f:	eb d0                	jmp    f0101541 <strtol+0x87>
		// we don't properly detect overflow!
	}

	if (endptr)
f0101571:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101575:	74 05                	je     f010157c <strtol+0xc2>
		*endptr = (char *) s;
f0101577:	8b 75 0c             	mov    0xc(%ebp),%esi
f010157a:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f010157c:	85 ff                	test   %edi,%edi
f010157e:	74 02                	je     f0101582 <strtol+0xc8>
f0101580:	f7 d8                	neg    %eax
}
f0101582:	5b                   	pop    %ebx
f0101583:	5e                   	pop    %esi
f0101584:	5f                   	pop    %edi
f0101585:	5d                   	pop    %ebp
f0101586:	c3                   	ret    
f0101587:	90                   	nop

f0101588 <__udivdi3>:
f0101588:	55                   	push   %ebp
f0101589:	57                   	push   %edi
f010158a:	56                   	push   %esi
f010158b:	53                   	push   %ebx
f010158c:	83 ec 1c             	sub    $0x1c,%esp
f010158f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0101593:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101597:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010159b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010159f:	85 d2                	test   %edx,%edx
f01015a1:	75 2d                	jne    f01015d0 <__udivdi3+0x48>
f01015a3:	39 f7                	cmp    %esi,%edi
f01015a5:	77 59                	ja     f0101600 <__udivdi3+0x78>
f01015a7:	89 f9                	mov    %edi,%ecx
f01015a9:	85 ff                	test   %edi,%edi
f01015ab:	75 0b                	jne    f01015b8 <__udivdi3+0x30>
f01015ad:	b8 01 00 00 00       	mov    $0x1,%eax
f01015b2:	31 d2                	xor    %edx,%edx
f01015b4:	f7 f7                	div    %edi
f01015b6:	89 c1                	mov    %eax,%ecx
f01015b8:	31 d2                	xor    %edx,%edx
f01015ba:	89 f0                	mov    %esi,%eax
f01015bc:	f7 f1                	div    %ecx
f01015be:	89 c3                	mov    %eax,%ebx
f01015c0:	89 e8                	mov    %ebp,%eax
f01015c2:	f7 f1                	div    %ecx
f01015c4:	89 da                	mov    %ebx,%edx
f01015c6:	83 c4 1c             	add    $0x1c,%esp
f01015c9:	5b                   	pop    %ebx
f01015ca:	5e                   	pop    %esi
f01015cb:	5f                   	pop    %edi
f01015cc:	5d                   	pop    %ebp
f01015cd:	c3                   	ret    
f01015ce:	66 90                	xchg   %ax,%ax
f01015d0:	39 f2                	cmp    %esi,%edx
f01015d2:	77 1c                	ja     f01015f0 <__udivdi3+0x68>
f01015d4:	0f bd da             	bsr    %edx,%ebx
f01015d7:	83 f3 1f             	xor    $0x1f,%ebx
f01015da:	75 38                	jne    f0101614 <__udivdi3+0x8c>
f01015dc:	39 f2                	cmp    %esi,%edx
f01015de:	72 08                	jb     f01015e8 <__udivdi3+0x60>
f01015e0:	39 ef                	cmp    %ebp,%edi
f01015e2:	0f 87 98 00 00 00    	ja     f0101680 <__udivdi3+0xf8>
f01015e8:	b8 01 00 00 00       	mov    $0x1,%eax
f01015ed:	eb 05                	jmp    f01015f4 <__udivdi3+0x6c>
f01015ef:	90                   	nop
f01015f0:	31 db                	xor    %ebx,%ebx
f01015f2:	31 c0                	xor    %eax,%eax
f01015f4:	89 da                	mov    %ebx,%edx
f01015f6:	83 c4 1c             	add    $0x1c,%esp
f01015f9:	5b                   	pop    %ebx
f01015fa:	5e                   	pop    %esi
f01015fb:	5f                   	pop    %edi
f01015fc:	5d                   	pop    %ebp
f01015fd:	c3                   	ret    
f01015fe:	66 90                	xchg   %ax,%ax
f0101600:	89 e8                	mov    %ebp,%eax
f0101602:	89 f2                	mov    %esi,%edx
f0101604:	f7 f7                	div    %edi
f0101606:	31 db                	xor    %ebx,%ebx
f0101608:	89 da                	mov    %ebx,%edx
f010160a:	83 c4 1c             	add    $0x1c,%esp
f010160d:	5b                   	pop    %ebx
f010160e:	5e                   	pop    %esi
f010160f:	5f                   	pop    %edi
f0101610:	5d                   	pop    %ebp
f0101611:	c3                   	ret    
f0101612:	66 90                	xchg   %ax,%ax
f0101614:	b8 20 00 00 00       	mov    $0x20,%eax
f0101619:	29 d8                	sub    %ebx,%eax
f010161b:	88 d9                	mov    %bl,%cl
f010161d:	d3 e2                	shl    %cl,%edx
f010161f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101623:	89 fa                	mov    %edi,%edx
f0101625:	88 c1                	mov    %al,%cl
f0101627:	d3 ea                	shr    %cl,%edx
f0101629:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f010162d:	09 d1                	or     %edx,%ecx
f010162f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101633:	88 d9                	mov    %bl,%cl
f0101635:	d3 e7                	shl    %cl,%edi
f0101637:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010163b:	89 f7                	mov    %esi,%edi
f010163d:	88 c1                	mov    %al,%cl
f010163f:	d3 ef                	shr    %cl,%edi
f0101641:	88 d9                	mov    %bl,%cl
f0101643:	d3 e6                	shl    %cl,%esi
f0101645:	89 ea                	mov    %ebp,%edx
f0101647:	88 c1                	mov    %al,%cl
f0101649:	d3 ea                	shr    %cl,%edx
f010164b:	09 d6                	or     %edx,%esi
f010164d:	89 f0                	mov    %esi,%eax
f010164f:	89 fa                	mov    %edi,%edx
f0101651:	f7 74 24 08          	divl   0x8(%esp)
f0101655:	89 d7                	mov    %edx,%edi
f0101657:	89 c6                	mov    %eax,%esi
f0101659:	f7 64 24 0c          	mull   0xc(%esp)
f010165d:	39 d7                	cmp    %edx,%edi
f010165f:	72 13                	jb     f0101674 <__udivdi3+0xec>
f0101661:	74 09                	je     f010166c <__udivdi3+0xe4>
f0101663:	89 f0                	mov    %esi,%eax
f0101665:	31 db                	xor    %ebx,%ebx
f0101667:	eb 8b                	jmp    f01015f4 <__udivdi3+0x6c>
f0101669:	8d 76 00             	lea    0x0(%esi),%esi
f010166c:	88 d9                	mov    %bl,%cl
f010166e:	d3 e5                	shl    %cl,%ebp
f0101670:	39 c5                	cmp    %eax,%ebp
f0101672:	73 ef                	jae    f0101663 <__udivdi3+0xdb>
f0101674:	8d 46 ff             	lea    -0x1(%esi),%eax
f0101677:	31 db                	xor    %ebx,%ebx
f0101679:	e9 76 ff ff ff       	jmp    f01015f4 <__udivdi3+0x6c>
f010167e:	66 90                	xchg   %ax,%ax
f0101680:	31 c0                	xor    %eax,%eax
f0101682:	e9 6d ff ff ff       	jmp    f01015f4 <__udivdi3+0x6c>
f0101687:	90                   	nop

f0101688 <__umoddi3>:
f0101688:	55                   	push   %ebp
f0101689:	57                   	push   %edi
f010168a:	56                   	push   %esi
f010168b:	53                   	push   %ebx
f010168c:	83 ec 1c             	sub    $0x1c,%esp
f010168f:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101693:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101697:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010169b:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f010169f:	89 f0                	mov    %esi,%eax
f01016a1:	89 da                	mov    %ebx,%edx
f01016a3:	85 ed                	test   %ebp,%ebp
f01016a5:	75 15                	jne    f01016bc <__umoddi3+0x34>
f01016a7:	39 df                	cmp    %ebx,%edi
f01016a9:	76 39                	jbe    f01016e4 <__umoddi3+0x5c>
f01016ab:	f7 f7                	div    %edi
f01016ad:	89 d0                	mov    %edx,%eax
f01016af:	31 d2                	xor    %edx,%edx
f01016b1:	83 c4 1c             	add    $0x1c,%esp
f01016b4:	5b                   	pop    %ebx
f01016b5:	5e                   	pop    %esi
f01016b6:	5f                   	pop    %edi
f01016b7:	5d                   	pop    %ebp
f01016b8:	c3                   	ret    
f01016b9:	8d 76 00             	lea    0x0(%esi),%esi
f01016bc:	39 dd                	cmp    %ebx,%ebp
f01016be:	77 f1                	ja     f01016b1 <__umoddi3+0x29>
f01016c0:	0f bd cd             	bsr    %ebp,%ecx
f01016c3:	83 f1 1f             	xor    $0x1f,%ecx
f01016c6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01016ca:	75 38                	jne    f0101704 <__umoddi3+0x7c>
f01016cc:	39 dd                	cmp    %ebx,%ebp
f01016ce:	72 04                	jb     f01016d4 <__umoddi3+0x4c>
f01016d0:	39 f7                	cmp    %esi,%edi
f01016d2:	77 dd                	ja     f01016b1 <__umoddi3+0x29>
f01016d4:	89 da                	mov    %ebx,%edx
f01016d6:	89 f0                	mov    %esi,%eax
f01016d8:	29 f8                	sub    %edi,%eax
f01016da:	19 ea                	sbb    %ebp,%edx
f01016dc:	83 c4 1c             	add    $0x1c,%esp
f01016df:	5b                   	pop    %ebx
f01016e0:	5e                   	pop    %esi
f01016e1:	5f                   	pop    %edi
f01016e2:	5d                   	pop    %ebp
f01016e3:	c3                   	ret    
f01016e4:	89 f9                	mov    %edi,%ecx
f01016e6:	85 ff                	test   %edi,%edi
f01016e8:	75 0b                	jne    f01016f5 <__umoddi3+0x6d>
f01016ea:	b8 01 00 00 00       	mov    $0x1,%eax
f01016ef:	31 d2                	xor    %edx,%edx
f01016f1:	f7 f7                	div    %edi
f01016f3:	89 c1                	mov    %eax,%ecx
f01016f5:	89 d8                	mov    %ebx,%eax
f01016f7:	31 d2                	xor    %edx,%edx
f01016f9:	f7 f1                	div    %ecx
f01016fb:	89 f0                	mov    %esi,%eax
f01016fd:	f7 f1                	div    %ecx
f01016ff:	eb ac                	jmp    f01016ad <__umoddi3+0x25>
f0101701:	8d 76 00             	lea    0x0(%esi),%esi
f0101704:	b8 20 00 00 00       	mov    $0x20,%eax
f0101709:	89 c2                	mov    %eax,%edx
f010170b:	8b 44 24 04          	mov    0x4(%esp),%eax
f010170f:	29 c2                	sub    %eax,%edx
f0101711:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101715:	88 c1                	mov    %al,%cl
f0101717:	d3 e5                	shl    %cl,%ebp
f0101719:	89 f8                	mov    %edi,%eax
f010171b:	88 d1                	mov    %dl,%cl
f010171d:	d3 e8                	shr    %cl,%eax
f010171f:	09 c5                	or     %eax,%ebp
f0101721:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101725:	88 c1                	mov    %al,%cl
f0101727:	d3 e7                	shl    %cl,%edi
f0101729:	89 7c 24 08          	mov    %edi,0x8(%esp)
f010172d:	89 df                	mov    %ebx,%edi
f010172f:	88 d1                	mov    %dl,%cl
f0101731:	d3 ef                	shr    %cl,%edi
f0101733:	88 c1                	mov    %al,%cl
f0101735:	d3 e3                	shl    %cl,%ebx
f0101737:	89 f0                	mov    %esi,%eax
f0101739:	88 d1                	mov    %dl,%cl
f010173b:	d3 e8                	shr    %cl,%eax
f010173d:	09 d8                	or     %ebx,%eax
f010173f:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0101743:	d3 e6                	shl    %cl,%esi
f0101745:	89 fa                	mov    %edi,%edx
f0101747:	f7 f5                	div    %ebp
f0101749:	89 d1                	mov    %edx,%ecx
f010174b:	f7 64 24 08          	mull   0x8(%esp)
f010174f:	89 c3                	mov    %eax,%ebx
f0101751:	89 d7                	mov    %edx,%edi
f0101753:	39 d1                	cmp    %edx,%ecx
f0101755:	72 29                	jb     f0101780 <__umoddi3+0xf8>
f0101757:	74 23                	je     f010177c <__umoddi3+0xf4>
f0101759:	89 ca                	mov    %ecx,%edx
f010175b:	29 de                	sub    %ebx,%esi
f010175d:	19 fa                	sbb    %edi,%edx
f010175f:	89 d0                	mov    %edx,%eax
f0101761:	8a 4c 24 0c          	mov    0xc(%esp),%cl
f0101765:	d3 e0                	shl    %cl,%eax
f0101767:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f010176b:	88 d9                	mov    %bl,%cl
f010176d:	d3 ee                	shr    %cl,%esi
f010176f:	09 f0                	or     %esi,%eax
f0101771:	d3 ea                	shr    %cl,%edx
f0101773:	83 c4 1c             	add    $0x1c,%esp
f0101776:	5b                   	pop    %ebx
f0101777:	5e                   	pop    %esi
f0101778:	5f                   	pop    %edi
f0101779:	5d                   	pop    %ebp
f010177a:	c3                   	ret    
f010177b:	90                   	nop
f010177c:	39 c6                	cmp    %eax,%esi
f010177e:	73 d9                	jae    f0101759 <__umoddi3+0xd1>
f0101780:	2b 44 24 08          	sub    0x8(%esp),%eax
f0101784:	19 ea                	sbb    %ebp,%edx
f0101786:	89 d7                	mov    %edx,%edi
f0101788:	89 c3                	mov    %eax,%ebx
f010178a:	eb cd                	jmp    f0101759 <__umoddi3+0xd1>
