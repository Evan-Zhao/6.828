
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
f0100015:	b8 00 a0 11 00       	mov    $0x11a000,%eax
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
f0100034:	bc 00 a0 11 f0       	mov    $0xf011a000,%esp

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
f010004b:	68 e0 49 10 f0       	push   $0xf01049e0
f0100050:	e8 9e 35 00 00       	call   f01035f3 <cprintf>
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
f0100065:	e8 75 0b 00 00       	call   f0100bdf <mon_backtrace>
f010006a:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010006d:	83 ec 08             	sub    $0x8,%esp
f0100070:	53                   	push   %ebx
f0100071:	68 fc 49 10 f0       	push   $0xf01049fc
f0100076:	e8 78 35 00 00       	call   f01035f3 <cprintf>
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
f010009a:	b8 f0 5d 1b f0       	mov    $0xf01b5df0,%eax
f010009f:	2d c6 4e 1b f0       	sub    $0xf01b4ec6,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 c6 4e 1b f0       	push   $0xf01b4ec6
f01000ac:	e8 66 44 00 00       	call   f0104517 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 ed 04 00 00       	call   f01005a3 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 17 4a 10 f0       	push   $0xf0104a17
f01000c3:	e8 2b 35 00 00       	call   f01035f3 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000c8:	e8 90 14 00 00       	call   f010155d <mem_init>
	cprintf(ANSI_COLOR_RED     "This text is RED!"     ANSI_COLOR_RESET "\n");
f01000cd:	c7 04 24 32 4a 10 f0 	movl   $0xf0104a32,(%esp)
f01000d4:	e8 1a 35 00 00       	call   f01035f3 <cprintf>
	cprintf(ANSI_COLOR_GREEN   "This text is GREEN!"   ANSI_COLOR_RESET "\n");
f01000d9:	c7 04 24 4e 4a 10 f0 	movl   $0xf0104a4e,(%esp)
f01000e0:	e8 0e 35 00 00       	call   f01035f3 <cprintf>
	cprintf(ANSI_COLOR_YELLOW  "This text is YELLOW!"  ANSI_COLOR_RESET "\n");
f01000e5:	c7 04 24 d8 4a 10 f0 	movl   $0xf0104ad8,(%esp)
f01000ec:	e8 02 35 00 00       	call   f01035f3 <cprintf>
	cprintf(ANSI_COLOR_BLUE    "This text is BLUE!"    ANSI_COLOR_RESET "\n");
f01000f1:	c7 04 24 6c 4a 10 f0 	movl   $0xf0104a6c,(%esp)
f01000f8:	e8 f6 34 00 00       	call   f01035f3 <cprintf>
	cprintf(ANSI_COLOR_MAGENTA "This text is MAGENTA!" ANSI_COLOR_RESET "\n");
f01000fd:	c7 04 24 f8 4a 10 f0 	movl   $0xf0104af8,(%esp)
f0100104:	e8 ea 34 00 00       	call   f01035f3 <cprintf>
	cprintf(ANSI_COLOR_CYAN    "This text is CYAN!"    ANSI_COLOR_RESET "\n");
f0100109:	c7 04 24 89 4a 10 f0 	movl   $0xf0104a89,(%esp)
f0100110:	e8 de 34 00 00       	call   f01035f3 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f0100115:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f010011c:	e8 1f ff ff ff       	call   f0100040 <test_backtrace>

	// Lab 3 user environment initialization functions
	env_init();
f0100121:	e8 e6 2d 00 00       	call   f0102f0c <env_init>
	trap_init();
f0100126:	e8 42 35 00 00       	call   f010366d <trap_init>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
f010012b:	83 c4 08             	add    $0x8,%esp
f010012e:	6a 00                	push   $0x0
f0100130:	68 56 c3 11 f0       	push   $0xf011c356
f0100135:	e8 a1 2f 00 00       	call   f01030db <env_create>
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f010013a:	83 c4 04             	add    $0x4,%esp
f010013d:	ff 35 28 51 1b f0    	pushl  0xf01b5128
f0100143:	e8 e1 33 00 00       	call   f0103529 <env_run>

f0100148 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100148:	55                   	push   %ebp
f0100149:	89 e5                	mov    %esp,%ebp
f010014b:	56                   	push   %esi
f010014c:	53                   	push   %ebx
f010014d:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100150:	83 3d e0 5d 1b f0 00 	cmpl   $0x0,0xf01b5de0
f0100157:	74 0f                	je     f0100168 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100159:	83 ec 0c             	sub    $0xc,%esp
f010015c:	6a 00                	push   $0x0
f010015e:	e8 20 0b 00 00       	call   f0100c83 <monitor>
f0100163:	83 c4 10             	add    $0x10,%esp
f0100166:	eb f1                	jmp    f0100159 <_panic+0x11>
	panicstr = fmt;
f0100168:	89 35 e0 5d 1b f0    	mov    %esi,0xf01b5de0
	asm volatile("cli; cld");
f010016e:	fa                   	cli    
f010016f:	fc                   	cld    
	va_start(ap, fmt);
f0100170:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100173:	83 ec 04             	sub    $0x4,%esp
f0100176:	ff 75 0c             	pushl  0xc(%ebp)
f0100179:	ff 75 08             	pushl  0x8(%ebp)
f010017c:	68 a6 4a 10 f0       	push   $0xf0104aa6
f0100181:	e8 6d 34 00 00       	call   f01035f3 <cprintf>
	vcprintf(fmt, ap);
f0100186:	83 c4 08             	add    $0x8,%esp
f0100189:	53                   	push   %ebx
f010018a:	56                   	push   %esi
f010018b:	e8 3d 34 00 00       	call   f01035cd <vcprintf>
	cprintf("\n");
f0100190:	c7 04 24 3b 4e 10 f0 	movl   $0xf0104e3b,(%esp)
f0100197:	e8 57 34 00 00       	call   f01035f3 <cprintf>
f010019c:	83 c4 10             	add    $0x10,%esp
f010019f:	eb b8                	jmp    f0100159 <_panic+0x11>

f01001a1 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01001a1:	55                   	push   %ebp
f01001a2:	89 e5                	mov    %esp,%ebp
f01001a4:	53                   	push   %ebx
f01001a5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01001a8:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01001ab:	ff 75 0c             	pushl  0xc(%ebp)
f01001ae:	ff 75 08             	pushl  0x8(%ebp)
f01001b1:	68 be 4a 10 f0       	push   $0xf0104abe
f01001b6:	e8 38 34 00 00       	call   f01035f3 <cprintf>
	vcprintf(fmt, ap);
f01001bb:	83 c4 08             	add    $0x8,%esp
f01001be:	53                   	push   %ebx
f01001bf:	ff 75 10             	pushl  0x10(%ebp)
f01001c2:	e8 06 34 00 00       	call   f01035cd <vcprintf>
	cprintf("\n");
f01001c7:	c7 04 24 3b 4e 10 f0 	movl   $0xf0104e3b,(%esp)
f01001ce:	e8 20 34 00 00       	call   f01035f3 <cprintf>
	va_end(ap);
}
f01001d3:	83 c4 10             	add    $0x10,%esp
f01001d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01001d9:	c9                   	leave  
f01001da:	c3                   	ret    

f01001db <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001db:	55                   	push   %ebp
f01001dc:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001de:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001e3:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001e4:	a8 01                	test   $0x1,%al
f01001e6:	74 0b                	je     f01001f3 <serial_proc_data+0x18>
f01001e8:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001ed:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001ee:	0f b6 c0             	movzbl %al,%eax
}
f01001f1:	5d                   	pop    %ebp
f01001f2:	c3                   	ret    
		return -1;
f01001f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001f8:	eb f7                	jmp    f01001f1 <serial_proc_data+0x16>

f01001fa <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001fa:	55                   	push   %ebp
f01001fb:	89 e5                	mov    %esp,%ebp
f01001fd:	53                   	push   %ebx
f01001fe:	83 ec 04             	sub    $0x4,%esp
f0100201:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100203:	ff d3                	call   *%ebx
f0100205:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100208:	74 2d                	je     f0100237 <cons_intr+0x3d>
		if (c == 0)
f010020a:	85 c0                	test   %eax,%eax
f010020c:	74 f5                	je     f0100203 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f010020e:	8b 0d 04 51 1b f0    	mov    0xf01b5104,%ecx
f0100214:	8d 51 01             	lea    0x1(%ecx),%edx
f0100217:	89 15 04 51 1b f0    	mov    %edx,0xf01b5104
f010021d:	88 81 00 4f 1b f0    	mov    %al,-0xfe4b100(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100223:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100229:	75 d8                	jne    f0100203 <cons_intr+0x9>
			cons.wpos = 0;
f010022b:	c7 05 04 51 1b f0 00 	movl   $0x0,0xf01b5104
f0100232:	00 00 00 
f0100235:	eb cc                	jmp    f0100203 <cons_intr+0x9>
	}
}
f0100237:	83 c4 04             	add    $0x4,%esp
f010023a:	5b                   	pop    %ebx
f010023b:	5d                   	pop    %ebp
f010023c:	c3                   	ret    

f010023d <kbd_proc_data>:
{
f010023d:	55                   	push   %ebp
f010023e:	89 e5                	mov    %esp,%ebp
f0100240:	53                   	push   %ebx
f0100241:	83 ec 04             	sub    $0x4,%esp
f0100244:	ba 64 00 00 00       	mov    $0x64,%edx
f0100249:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f010024a:	a8 01                	test   $0x1,%al
f010024c:	0f 84 f1 00 00 00    	je     f0100343 <kbd_proc_data+0x106>
	if (stat & KBS_TERR)
f0100252:	a8 20                	test   $0x20,%al
f0100254:	0f 85 f0 00 00 00    	jne    f010034a <kbd_proc_data+0x10d>
f010025a:	ba 60 00 00 00       	mov    $0x60,%edx
f010025f:	ec                   	in     (%dx),%al
f0100260:	88 c2                	mov    %al,%dl
	if (data == 0xE0) {
f0100262:	3c e0                	cmp    $0xe0,%al
f0100264:	0f 84 8a 00 00 00    	je     f01002f4 <kbd_proc_data+0xb7>
	} else if (data & 0x80) {
f010026a:	84 c0                	test   %al,%al
f010026c:	0f 88 95 00 00 00    	js     f0100307 <kbd_proc_data+0xca>
	} else if (shift & E0ESC) {
f0100272:	8b 0d e0 4e 1b f0    	mov    0xf01b4ee0,%ecx
f0100278:	f6 c1 40             	test   $0x40,%cl
f010027b:	74 0e                	je     f010028b <kbd_proc_data+0x4e>
		data |= 0x80;
f010027d:	83 c8 80             	or     $0xffffff80,%eax
f0100280:	88 c2                	mov    %al,%dl
		shift &= ~E0ESC;
f0100282:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100285:	89 0d e0 4e 1b f0    	mov    %ecx,0xf01b4ee0
	shift |= shiftcode[data];
f010028b:	0f b6 d2             	movzbl %dl,%edx
f010028e:	0f b6 82 80 4c 10 f0 	movzbl -0xfefb380(%edx),%eax
f0100295:	0b 05 e0 4e 1b f0    	or     0xf01b4ee0,%eax
	shift ^= togglecode[data];
f010029b:	0f b6 8a 80 4b 10 f0 	movzbl -0xfefb480(%edx),%ecx
f01002a2:	31 c8                	xor    %ecx,%eax
f01002a4:	a3 e0 4e 1b f0       	mov    %eax,0xf01b4ee0
	c = charcode[shift & (CTL | SHIFT)][data];
f01002a9:	89 c1                	mov    %eax,%ecx
f01002ab:	83 e1 03             	and    $0x3,%ecx
f01002ae:	8b 0c 8d 60 4b 10 f0 	mov    -0xfefb4a0(,%ecx,4),%ecx
f01002b5:	8a 14 11             	mov    (%ecx,%edx,1),%dl
f01002b8:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01002bb:	a8 08                	test   $0x8,%al
f01002bd:	74 0d                	je     f01002cc <kbd_proc_data+0x8f>
		if ('a' <= c && c <= 'z')
f01002bf:	89 da                	mov    %ebx,%edx
f01002c1:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01002c4:	83 f9 19             	cmp    $0x19,%ecx
f01002c7:	77 6d                	ja     f0100336 <kbd_proc_data+0xf9>
			c += 'A' - 'a';
f01002c9:	83 eb 20             	sub    $0x20,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002cc:	f7 d0                	not    %eax
f01002ce:	a8 06                	test   $0x6,%al
f01002d0:	75 2e                	jne    f0100300 <kbd_proc_data+0xc3>
f01002d2:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002d8:	75 26                	jne    f0100300 <kbd_proc_data+0xc3>
		cprintf("Rebooting!\n");
f01002da:	83 ec 0c             	sub    $0xc,%esp
f01002dd:	68 18 4b 10 f0       	push   $0xf0104b18
f01002e2:	e8 0c 33 00 00       	call   f01035f3 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002e7:	b0 03                	mov    $0x3,%al
f01002e9:	ba 92 00 00 00       	mov    $0x92,%edx
f01002ee:	ee                   	out    %al,(%dx)
f01002ef:	83 c4 10             	add    $0x10,%esp
f01002f2:	eb 0c                	jmp    f0100300 <kbd_proc_data+0xc3>
		shift |= E0ESC;
f01002f4:	83 0d e0 4e 1b f0 40 	orl    $0x40,0xf01b4ee0
		return 0;
f01002fb:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100300:	89 d8                	mov    %ebx,%eax
f0100302:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100305:	c9                   	leave  
f0100306:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100307:	8b 0d e0 4e 1b f0    	mov    0xf01b4ee0,%ecx
f010030d:	f6 c1 40             	test   $0x40,%cl
f0100310:	75 05                	jne    f0100317 <kbd_proc_data+0xda>
f0100312:	83 e0 7f             	and    $0x7f,%eax
f0100315:	88 c2                	mov    %al,%dl
		shift &= ~(shiftcode[data] | E0ESC);
f0100317:	0f b6 d2             	movzbl %dl,%edx
f010031a:	8a 82 80 4c 10 f0    	mov    -0xfefb380(%edx),%al
f0100320:	83 c8 40             	or     $0x40,%eax
f0100323:	0f b6 c0             	movzbl %al,%eax
f0100326:	f7 d0                	not    %eax
f0100328:	21 c8                	and    %ecx,%eax
f010032a:	a3 e0 4e 1b f0       	mov    %eax,0xf01b4ee0
		return 0;
f010032f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100334:	eb ca                	jmp    f0100300 <kbd_proc_data+0xc3>
		else if ('A' <= c && c <= 'Z')
f0100336:	83 ea 41             	sub    $0x41,%edx
f0100339:	83 fa 19             	cmp    $0x19,%edx
f010033c:	77 8e                	ja     f01002cc <kbd_proc_data+0x8f>
			c += 'a' - 'A';
f010033e:	83 c3 20             	add    $0x20,%ebx
f0100341:	eb 89                	jmp    f01002cc <kbd_proc_data+0x8f>
		return -1;
f0100343:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0100348:	eb b6                	jmp    f0100300 <kbd_proc_data+0xc3>
		return -1;
f010034a:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010034f:	eb af                	jmp    f0100300 <kbd_proc_data+0xc3>

f0100351 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100351:	55                   	push   %ebp
f0100352:	89 e5                	mov    %esp,%ebp
f0100354:	57                   	push   %edi
f0100355:	56                   	push   %esi
f0100356:	53                   	push   %ebx
f0100357:	83 ec 1c             	sub    $0x1c,%esp
f010035a:	89 c7                	mov    %eax,%edi
f010035c:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100361:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100366:	b9 84 00 00 00       	mov    $0x84,%ecx
f010036b:	eb 06                	jmp    f0100373 <cons_putc+0x22>
f010036d:	89 ca                	mov    %ecx,%edx
f010036f:	ec                   	in     (%dx),%al
f0100370:	ec                   	in     (%dx),%al
f0100371:	ec                   	in     (%dx),%al
f0100372:	ec                   	in     (%dx),%al
f0100373:	89 f2                	mov    %esi,%edx
f0100375:	ec                   	in     (%dx),%al
	for (i = 0;
f0100376:	a8 20                	test   $0x20,%al
f0100378:	75 03                	jne    f010037d <cons_putc+0x2c>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010037a:	4b                   	dec    %ebx
f010037b:	75 f0                	jne    f010036d <cons_putc+0x1c>
	outb(COM1 + COM_TX, c);
f010037d:	89 f8                	mov    %edi,%eax
f010037f:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100382:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100387:	ee                   	out    %al,(%dx)
f0100388:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010038d:	be 79 03 00 00       	mov    $0x379,%esi
f0100392:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100397:	eb 06                	jmp    f010039f <cons_putc+0x4e>
f0100399:	89 ca                	mov    %ecx,%edx
f010039b:	ec                   	in     (%dx),%al
f010039c:	ec                   	in     (%dx),%al
f010039d:	ec                   	in     (%dx),%al
f010039e:	ec                   	in     (%dx),%al
f010039f:	89 f2                	mov    %esi,%edx
f01003a1:	ec                   	in     (%dx),%al
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003a2:	84 c0                	test   %al,%al
f01003a4:	78 03                	js     f01003a9 <cons_putc+0x58>
f01003a6:	4b                   	dec    %ebx
f01003a7:	75 f0                	jne    f0100399 <cons_putc+0x48>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003a9:	ba 78 03 00 00       	mov    $0x378,%edx
f01003ae:	8a 45 e7             	mov    -0x19(%ebp),%al
f01003b1:	ee                   	out    %al,(%dx)
f01003b2:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003b7:	b0 0d                	mov    $0xd,%al
f01003b9:	ee                   	out    %al,(%dx)
f01003ba:	b0 08                	mov    $0x8,%al
f01003bc:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01003bd:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f01003c3:	75 06                	jne    f01003cb <cons_putc+0x7a>
		c |= 0x0700;
f01003c5:	81 cf 00 07 00 00    	or     $0x700,%edi
	switch (c & 0xff) {
f01003cb:	89 f8                	mov    %edi,%eax
f01003cd:	0f b6 c0             	movzbl %al,%eax
f01003d0:	83 f8 09             	cmp    $0x9,%eax
f01003d3:	0f 84 b1 00 00 00    	je     f010048a <cons_putc+0x139>
f01003d9:	83 f8 09             	cmp    $0x9,%eax
f01003dc:	7e 70                	jle    f010044e <cons_putc+0xfd>
f01003de:	83 f8 0a             	cmp    $0xa,%eax
f01003e1:	0f 84 96 00 00 00    	je     f010047d <cons_putc+0x12c>
f01003e7:	83 f8 0d             	cmp    $0xd,%eax
f01003ea:	0f 85 d1 00 00 00    	jne    f01004c1 <cons_putc+0x170>
		crt_pos -= (crt_pos % CRT_COLS);
f01003f0:	66 8b 0d 08 51 1b f0 	mov    0xf01b5108,%cx
f01003f7:	bb 50 00 00 00       	mov    $0x50,%ebx
f01003fc:	89 c8                	mov    %ecx,%eax
f01003fe:	ba 00 00 00 00       	mov    $0x0,%edx
f0100403:	66 f7 f3             	div    %bx
f0100406:	29 d1                	sub    %edx,%ecx
f0100408:	66 89 0d 08 51 1b f0 	mov    %cx,0xf01b5108
	if (crt_pos >= CRT_SIZE) {
f010040f:	66 81 3d 08 51 1b f0 	cmpw   $0x7cf,0xf01b5108
f0100416:	cf 07 
f0100418:	0f 87 c5 00 00 00    	ja     f01004e3 <cons_putc+0x192>
	outb(addr_6845, 14);
f010041e:	8b 0d 10 51 1b f0    	mov    0xf01b5110,%ecx
f0100424:	b0 0e                	mov    $0xe,%al
f0100426:	89 ca                	mov    %ecx,%edx
f0100428:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100429:	8d 59 01             	lea    0x1(%ecx),%ebx
f010042c:	66 a1 08 51 1b f0    	mov    0xf01b5108,%ax
f0100432:	66 c1 e8 08          	shr    $0x8,%ax
f0100436:	89 da                	mov    %ebx,%edx
f0100438:	ee                   	out    %al,(%dx)
f0100439:	b0 0f                	mov    $0xf,%al
f010043b:	89 ca                	mov    %ecx,%edx
f010043d:	ee                   	out    %al,(%dx)
f010043e:	a0 08 51 1b f0       	mov    0xf01b5108,%al
f0100443:	89 da                	mov    %ebx,%edx
f0100445:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100446:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100449:	5b                   	pop    %ebx
f010044a:	5e                   	pop    %esi
f010044b:	5f                   	pop    %edi
f010044c:	5d                   	pop    %ebp
f010044d:	c3                   	ret    
	switch (c & 0xff) {
f010044e:	83 f8 08             	cmp    $0x8,%eax
f0100451:	75 6e                	jne    f01004c1 <cons_putc+0x170>
		if (crt_pos > 0) {
f0100453:	66 a1 08 51 1b f0    	mov    0xf01b5108,%ax
f0100459:	66 85 c0             	test   %ax,%ax
f010045c:	74 c0                	je     f010041e <cons_putc+0xcd>
			crt_pos--;
f010045e:	48                   	dec    %eax
f010045f:	66 a3 08 51 1b f0    	mov    %ax,0xf01b5108
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100465:	0f b7 c0             	movzwl %ax,%eax
f0100468:	81 e7 00 ff ff ff    	and    $0xffffff00,%edi
f010046e:	83 cf 20             	or     $0x20,%edi
f0100471:	8b 15 0c 51 1b f0    	mov    0xf01b510c,%edx
f0100477:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010047b:	eb 92                	jmp    f010040f <cons_putc+0xbe>
		crt_pos += CRT_COLS;
f010047d:	66 83 05 08 51 1b f0 	addw   $0x50,0xf01b5108
f0100484:	50 
f0100485:	e9 66 ff ff ff       	jmp    f01003f0 <cons_putc+0x9f>
		cons_putc(' ');
f010048a:	b8 20 00 00 00       	mov    $0x20,%eax
f010048f:	e8 bd fe ff ff       	call   f0100351 <cons_putc>
		cons_putc(' ');
f0100494:	b8 20 00 00 00       	mov    $0x20,%eax
f0100499:	e8 b3 fe ff ff       	call   f0100351 <cons_putc>
		cons_putc(' ');
f010049e:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a3:	e8 a9 fe ff ff       	call   f0100351 <cons_putc>
		cons_putc(' ');
f01004a8:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ad:	e8 9f fe ff ff       	call   f0100351 <cons_putc>
		cons_putc(' ');
f01004b2:	b8 20 00 00 00       	mov    $0x20,%eax
f01004b7:	e8 95 fe ff ff       	call   f0100351 <cons_putc>
f01004bc:	e9 4e ff ff ff       	jmp    f010040f <cons_putc+0xbe>
		crt_buf[crt_pos++] = c;		/* write the character */
f01004c1:	66 a1 08 51 1b f0    	mov    0xf01b5108,%ax
f01004c7:	8d 50 01             	lea    0x1(%eax),%edx
f01004ca:	66 89 15 08 51 1b f0 	mov    %dx,0xf01b5108
f01004d1:	0f b7 c0             	movzwl %ax,%eax
f01004d4:	8b 15 0c 51 1b f0    	mov    0xf01b510c,%edx
f01004da:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004de:	e9 2c ff ff ff       	jmp    f010040f <cons_putc+0xbe>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004e3:	a1 0c 51 1b f0       	mov    0xf01b510c,%eax
f01004e8:	83 ec 04             	sub    $0x4,%esp
f01004eb:	68 00 0f 00 00       	push   $0xf00
f01004f0:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004f6:	52                   	push   %edx
f01004f7:	50                   	push   %eax
f01004f8:	e8 67 40 00 00       	call   f0104564 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01004fd:	8b 15 0c 51 1b f0    	mov    0xf01b510c,%edx
f0100503:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100509:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010050f:	83 c4 10             	add    $0x10,%esp
f0100512:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100517:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010051a:	39 d0                	cmp    %edx,%eax
f010051c:	75 f4                	jne    f0100512 <cons_putc+0x1c1>
		crt_pos -= CRT_COLS;
f010051e:	66 83 2d 08 51 1b f0 	subw   $0x50,0xf01b5108
f0100525:	50 
f0100526:	e9 f3 fe ff ff       	jmp    f010041e <cons_putc+0xcd>

f010052b <serial_intr>:
	if (serial_exists)
f010052b:	80 3d 14 51 1b f0 00 	cmpb   $0x0,0xf01b5114
f0100532:	75 01                	jne    f0100535 <serial_intr+0xa>
f0100534:	c3                   	ret    
{
f0100535:	55                   	push   %ebp
f0100536:	89 e5                	mov    %esp,%ebp
f0100538:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010053b:	b8 db 01 10 f0       	mov    $0xf01001db,%eax
f0100540:	e8 b5 fc ff ff       	call   f01001fa <cons_intr>
}
f0100545:	c9                   	leave  
f0100546:	c3                   	ret    

f0100547 <kbd_intr>:
{
f0100547:	55                   	push   %ebp
f0100548:	89 e5                	mov    %esp,%ebp
f010054a:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010054d:	b8 3d 02 10 f0       	mov    $0xf010023d,%eax
f0100552:	e8 a3 fc ff ff       	call   f01001fa <cons_intr>
}
f0100557:	c9                   	leave  
f0100558:	c3                   	ret    

f0100559 <cons_getc>:
{
f0100559:	55                   	push   %ebp
f010055a:	89 e5                	mov    %esp,%ebp
f010055c:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f010055f:	e8 c7 ff ff ff       	call   f010052b <serial_intr>
	kbd_intr();
f0100564:	e8 de ff ff ff       	call   f0100547 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100569:	a1 00 51 1b f0       	mov    0xf01b5100,%eax
f010056e:	3b 05 04 51 1b f0    	cmp    0xf01b5104,%eax
f0100574:	74 26                	je     f010059c <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100576:	8d 50 01             	lea    0x1(%eax),%edx
f0100579:	89 15 00 51 1b f0    	mov    %edx,0xf01b5100
f010057f:	0f b6 80 00 4f 1b f0 	movzbl -0xfe4b100(%eax),%eax
		if (cons.rpos == CONSBUFSIZE)
f0100586:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010058c:	74 02                	je     f0100590 <cons_getc+0x37>
}
f010058e:	c9                   	leave  
f010058f:	c3                   	ret    
			cons.rpos = 0;
f0100590:	c7 05 00 51 1b f0 00 	movl   $0x0,0xf01b5100
f0100597:	00 00 00 
f010059a:	eb f2                	jmp    f010058e <cons_getc+0x35>
	return 0;
f010059c:	b8 00 00 00 00       	mov    $0x0,%eax
f01005a1:	eb eb                	jmp    f010058e <cons_getc+0x35>

f01005a3 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01005a3:	55                   	push   %ebp
f01005a4:	89 e5                	mov    %esp,%ebp
f01005a6:	57                   	push   %edi
f01005a7:	56                   	push   %esi
f01005a8:	53                   	push   %ebx
f01005a9:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f01005ac:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f01005b3:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01005ba:	5a a5 
	if (*cp != 0xA55A) {
f01005bc:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f01005c2:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005c6:	0f 84 a2 00 00 00    	je     f010066e <cons_init+0xcb>
		addr_6845 = MONO_BASE;
f01005cc:	c7 05 10 51 1b f0 b4 	movl   $0x3b4,0xf01b5110
f01005d3:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005d6:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f01005db:	8b 3d 10 51 1b f0    	mov    0xf01b5110,%edi
f01005e1:	b0 0e                	mov    $0xe,%al
f01005e3:	89 fa                	mov    %edi,%edx
f01005e5:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005e6:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005e9:	89 ca                	mov    %ecx,%edx
f01005eb:	ec                   	in     (%dx),%al
f01005ec:	0f b6 c0             	movzbl %al,%eax
f01005ef:	c1 e0 08             	shl    $0x8,%eax
f01005f2:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005f4:	b0 0f                	mov    $0xf,%al
f01005f6:	89 fa                	mov    %edi,%edx
f01005f8:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005f9:	89 ca                	mov    %ecx,%edx
f01005fb:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01005fc:	89 35 0c 51 1b f0    	mov    %esi,0xf01b510c
	pos |= inb(addr_6845 + 1);
f0100602:	0f b6 c0             	movzbl %al,%eax
f0100605:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f0100607:	66 a3 08 51 1b f0    	mov    %ax,0xf01b5108
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010060d:	b1 00                	mov    $0x0,%cl
f010060f:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100614:	88 c8                	mov    %cl,%al
f0100616:	89 da                	mov    %ebx,%edx
f0100618:	ee                   	out    %al,(%dx)
f0100619:	bf fb 03 00 00       	mov    $0x3fb,%edi
f010061e:	b0 80                	mov    $0x80,%al
f0100620:	89 fa                	mov    %edi,%edx
f0100622:	ee                   	out    %al,(%dx)
f0100623:	b0 0c                	mov    $0xc,%al
f0100625:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010062a:	ee                   	out    %al,(%dx)
f010062b:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100630:	88 c8                	mov    %cl,%al
f0100632:	89 f2                	mov    %esi,%edx
f0100634:	ee                   	out    %al,(%dx)
f0100635:	b0 03                	mov    $0x3,%al
f0100637:	89 fa                	mov    %edi,%edx
f0100639:	ee                   	out    %al,(%dx)
f010063a:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010063f:	88 c8                	mov    %cl,%al
f0100641:	ee                   	out    %al,(%dx)
f0100642:	b0 01                	mov    $0x1,%al
f0100644:	89 f2                	mov    %esi,%edx
f0100646:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100647:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010064c:	ec                   	in     (%dx),%al
f010064d:	88 c1                	mov    %al,%cl
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010064f:	3c ff                	cmp    $0xff,%al
f0100651:	0f 95 05 14 51 1b f0 	setne  0xf01b5114
f0100658:	89 da                	mov    %ebx,%edx
f010065a:	ec                   	in     (%dx),%al
f010065b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100660:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100661:	80 f9 ff             	cmp    $0xff,%cl
f0100664:	74 23                	je     f0100689 <cons_init+0xe6>
		cprintf("Serial port does not exist!\n");
}
f0100666:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100669:	5b                   	pop    %ebx
f010066a:	5e                   	pop    %esi
f010066b:	5f                   	pop    %edi
f010066c:	5d                   	pop    %ebp
f010066d:	c3                   	ret    
		*cp = was;
f010066e:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100675:	c7 05 10 51 1b f0 d4 	movl   $0x3d4,0xf01b5110
f010067c:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010067f:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f0100684:	e9 52 ff ff ff       	jmp    f01005db <cons_init+0x38>
		cprintf("Serial port does not exist!\n");
f0100689:	83 ec 0c             	sub    $0xc,%esp
f010068c:	68 24 4b 10 f0       	push   $0xf0104b24
f0100691:	e8 5d 2f 00 00       	call   f01035f3 <cprintf>
f0100696:	83 c4 10             	add    $0x10,%esp
}
f0100699:	eb cb                	jmp    f0100666 <cons_init+0xc3>

f010069b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010069b:	55                   	push   %ebp
f010069c:	89 e5                	mov    %esp,%ebp
f010069e:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01006a1:	8b 45 08             	mov    0x8(%ebp),%eax
f01006a4:	e8 a8 fc ff ff       	call   f0100351 <cons_putc>
}
f01006a9:	c9                   	leave  
f01006aa:	c3                   	ret    

f01006ab <getchar>:

int
getchar(void)
{
f01006ab:	55                   	push   %ebp
f01006ac:	89 e5                	mov    %esp,%ebp
f01006ae:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01006b1:	e8 a3 fe ff ff       	call   f0100559 <cons_getc>
f01006b6:	85 c0                	test   %eax,%eax
f01006b8:	74 f7                	je     f01006b1 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01006ba:	c9                   	leave  
f01006bb:	c3                   	ret    

f01006bc <iscons>:

int
iscons(int fdnum)
{
f01006bc:	55                   	push   %ebp
f01006bd:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01006bf:	b8 01 00 00 00       	mov    $0x1,%eax
f01006c4:	5d                   	pop    %ebp
f01006c5:	c3                   	ret    

f01006c6 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006c6:	55                   	push   %ebp
f01006c7:	89 e5                	mov    %esp,%ebp
f01006c9:	53                   	push   %ebx
f01006ca:	83 ec 04             	sub    $0x4,%esp
f01006cd:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006d2:	83 ec 04             	sub    $0x4,%esp
f01006d5:	ff b3 84 52 10 f0    	pushl  -0xfefad7c(%ebx)
f01006db:	ff b3 80 52 10 f0    	pushl  -0xfefad80(%ebx)
f01006e1:	68 80 4d 10 f0       	push   $0xf0104d80
f01006e6:	e8 08 2f 00 00       	call   f01035f3 <cprintf>
f01006eb:	83 c3 0c             	add    $0xc,%ebx
	for (i = 0; i < ARRAY_SIZE(commands); i++)
f01006ee:	83 c4 10             	add    $0x10,%esp
f01006f1:	83 fb 3c             	cmp    $0x3c,%ebx
f01006f4:	75 dc                	jne    f01006d2 <mon_help+0xc>
	return 0;
}
f01006f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01006fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
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
f0100706:	68 89 4d 10 f0       	push   $0xf0104d89
f010070b:	e8 e3 2e 00 00       	call   f01035f3 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100710:	83 c4 08             	add    $0x8,%esp
f0100713:	68 0c 00 10 00       	push   $0x10000c
f0100718:	68 e0 4e 10 f0       	push   $0xf0104ee0
f010071d:	e8 d1 2e 00 00       	call   f01035f3 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100722:	83 c4 0c             	add    $0xc,%esp
f0100725:	68 0c 00 10 00       	push   $0x10000c
f010072a:	68 0c 00 10 f0       	push   $0xf010000c
f010072f:	68 08 4f 10 f0       	push   $0xf0104f08
f0100734:	e8 ba 2e 00 00       	call   f01035f3 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100739:	83 c4 0c             	add    $0xc,%esp
f010073c:	68 cc 49 10 00       	push   $0x1049cc
f0100741:	68 cc 49 10 f0       	push   $0xf01049cc
f0100746:	68 2c 4f 10 f0       	push   $0xf0104f2c
f010074b:	e8 a3 2e 00 00       	call   f01035f3 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100750:	83 c4 0c             	add    $0xc,%esp
f0100753:	68 c6 4e 1b 00       	push   $0x1b4ec6
f0100758:	68 c6 4e 1b f0       	push   $0xf01b4ec6
f010075d:	68 50 4f 10 f0       	push   $0xf0104f50
f0100762:	e8 8c 2e 00 00       	call   f01035f3 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100767:	83 c4 0c             	add    $0xc,%esp
f010076a:	68 f0 5d 1b 00       	push   $0x1b5df0
f010076f:	68 f0 5d 1b f0       	push   $0xf01b5df0
f0100774:	68 74 4f 10 f0       	push   $0xf0104f74
f0100779:	e8 75 2e 00 00       	call   f01035f3 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010077e:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100781:	b8 ef 61 1b f0       	mov    $0xf01b61ef,%eax
f0100786:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f010078b:	c1 f8 0a             	sar    $0xa,%eax
f010078e:	50                   	push   %eax
f010078f:	68 98 4f 10 f0       	push   $0xf0104f98
f0100794:	e8 5a 2e 00 00       	call   f01035f3 <cprintf>
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
		cprintf("Usage: showmap l r\n");
		return 0;
	}
	uintptr_t l = strtoul(argv[1], NULL, 0), 
f01007ae:	83 ec 04             	sub    $0x4,%esp
f01007b1:	6a 00                	push   $0x0
f01007b3:	6a 00                	push   $0x0
f01007b5:	ff 76 04             	pushl  0x4(%esi)
f01007b8:	e8 3b 3f 00 00       	call   f01046f8 <strtoul>
f01007bd:	89 c3                	mov    %eax,%ebx
		 	  r = strtoul(argv[2], NULL, 0); // In string.h
f01007bf:	83 c4 0c             	add    $0xc,%esp
f01007c2:	6a 00                	push   $0x0
f01007c4:	6a 00                	push   $0x0
f01007c6:	ff 76 08             	pushl  0x8(%esi)
f01007c9:	e8 2a 3f 00 00       	call   f01046f8 <strtoul>
	if (l > r) {
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
		cprintf("Usage: showmap l r\n");
f01007ea:	83 ec 0c             	sub    $0xc,%esp
f01007ed:	68 a2 4d 10 f0       	push   $0xf0104da2
f01007f2:	e8 fc 2d 00 00       	call   f01035f3 <cprintf>
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
f0100809:	68 b6 4d 10 f0       	push   $0xf0104db6
f010080e:	e8 e0 2d 00 00       	call   f01035f3 <cprintf>
		return 0;
f0100813:	83 c4 10             	add    $0x10,%esp
f0100816:	eb e2                	jmp    f01007fa <mon_showmap+0x5a>
			cprintf("0x%08x -> ----------; perm = ---\n", sz);
f0100818:	83 ec 08             	sub    $0x8,%esp
f010081b:	53                   	push   %ebx
f010081c:	68 c4 4f 10 f0       	push   $0xf0104fc4
f0100821:	e8 cd 2d 00 00       	call   f01035f3 <cprintf>
f0100826:	83 c4 10             	add    $0x10,%esp
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f0100829:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010082f:	39 f3                	cmp    %esi,%ebx
f0100831:	77 c7                	ja     f01007fa <mon_showmap+0x5a>
		pte_t* pte = pgdir_walk(kern_pgdir, (void*) sz, 0);
f0100833:	83 ec 04             	sub    $0x4,%esp
f0100836:	6a 00                	push   $0x0
f0100838:	53                   	push   %ebx
f0100839:	ff 35 e8 5d 1b f0    	pushl  0xf01b5de8
f010083f:	e8 9e 0a 00 00       	call   f01012e2 <pgdir_walk>
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
f0100861:	68 e8 4f 10 f0       	push   $0xf0104fe8
f0100866:	e8 88 2d 00 00       	call   f01035f3 <cprintf>
f010086b:	83 c4 10             	add    $0x10,%esp
f010086e:	eb b9                	jmp    f0100829 <mon_showmap+0x89>

f0100870 <mon_chmod>:

int
mon_chmod(int argc, char **argv, struct Trapframe *tf) {
f0100870:	55                   	push   %ebp
f0100871:	89 e5                	mov    %esp,%ebp
f0100873:	57                   	push   %edi
f0100874:	56                   	push   %esi
f0100875:	53                   	push   %ebx
f0100876:	83 ec 1c             	sub    $0x1c,%esp
f0100879:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc <= 2) {
f010087c:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100880:	7e 67                	jle    f01008e9 <mon_chmod+0x79>
		cprintf("Usage: chmod mod l [r] [-v]\n");
		return 0;
	}
	uintptr_t mod = strtoul(argv[1], NULL, 0),  
f0100882:	83 ec 04             	sub    $0x4,%esp
f0100885:	6a 00                	push   $0x0
f0100887:	6a 00                	push   $0x0
f0100889:	ff 76 04             	pushl  0x4(%esi)
f010088c:	e8 67 3e 00 00       	call   f01046f8 <strtoul>
f0100891:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			  l = strtoul(argv[2], NULL, 0), 
f0100894:	83 c4 0c             	add    $0xc,%esp
f0100897:	6a 00                	push   $0x0
f0100899:	6a 00                	push   $0x0
f010089b:	ff 76 08             	pushl  0x8(%esi)
f010089e:	e8 55 3e 00 00       	call   f01046f8 <strtoul>
f01008a3:	89 c3                	mov    %eax,%ebx
			  r = argc >= 4 ? strtoul(argv[3], NULL, 0) : l;
f01008a5:	83 c4 10             	add    $0x10,%esp
f01008a8:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f01008ac:	7f 58                	jg     f0100906 <mon_chmod+0x96>
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
	if (mod > 0xFFF) {
f01008ae:	81 7d e4 ff 0f 00 00 	cmpl   $0xfff,-0x1c(%ebp)
f01008b5:	0f 87 9a 00 00 00    	ja     f0100955 <mon_chmod+0xe5>
			  r = argc >= 4 ? strtoul(argv[3], NULL, 0) : l;
f01008bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
f01008be:	bf 00 00 00 00       	mov    $0x0,%edi
	}
	if (l > r) {
		cprintf("Invalid range; aborting.\n");
		return 0;
	}
	if (!(mod & PTE_P)) {
f01008c3:	f6 45 e4 01          	testb  $0x1,-0x1c(%ebp)
f01008c7:	0f 84 9a 00 00 00    	je     f0100967 <mon_chmod+0xf7>
		cprintf("Warning: PTE_P flag is not provided; added automatically.");
		mod |= PTE_P;
	}
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f01008cd:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f01008d3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f01008d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01008dc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01008e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01008e4:	e9 a1 00 00 00       	jmp    f010098a <mon_chmod+0x11a>
		cprintf("Usage: chmod mod l [r] [-v]\n");
f01008e9:	83 ec 0c             	sub    $0xc,%esp
f01008ec:	68 d0 4d 10 f0       	push   $0xf0104dd0
f01008f1:	e8 fd 2c 00 00       	call   f01035f3 <cprintf>
		return 0;
f01008f6:	83 c4 10             	add    $0x10,%esp
						sz, *pte & 0xFFF, mod);
			*pte = PTE_ADDR(*pte) | mod;
		}
	}
	return 0;
}
f01008f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01008fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100901:	5b                   	pop    %ebx
f0100902:	5e                   	pop    %esi
f0100903:	5f                   	pop    %edi
f0100904:	5d                   	pop    %ebp
f0100905:	c3                   	ret    
			  r = argc >= 4 ? strtoul(argv[3], NULL, 0) : l;
f0100906:	83 ec 04             	sub    $0x4,%esp
f0100909:	6a 00                	push   $0x0
f010090b:	6a 00                	push   $0x0
f010090d:	ff 76 0c             	pushl  0xc(%esi)
f0100910:	e8 e3 3d 00 00       	call   f01046f8 <strtoul>
f0100915:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
f0100918:	83 c4 08             	add    $0x8,%esp
f010091b:	68 ed 4d 10 f0       	push   $0xf0104ded
f0100920:	ff 76 0c             	pushl  0xc(%esi)
f0100923:	e8 66 3b 00 00       	call   f010448e <strcmp>
f0100928:	83 c4 10             	add    $0x10,%esp
f010092b:	85 c0                	test   %eax,%eax
f010092d:	0f 94 c0             	sete   %al
f0100930:	0f b6 c0             	movzbl %al,%eax
f0100933:	89 c7                	mov    %eax,%edi
	if (mod > 0xFFF) {
f0100935:	81 7d e4 ff 0f 00 00 	cmpl   $0xfff,-0x1c(%ebp)
f010093c:	77 17                	ja     f0100955 <mon_chmod+0xe5>
	if (l > r) {
f010093e:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0100941:	76 80                	jbe    f01008c3 <mon_chmod+0x53>
		cprintf("Invalid range; aborting.\n");
f0100943:	83 ec 0c             	sub    $0xc,%esp
f0100946:	68 b6 4d 10 f0       	push   $0xf0104db6
f010094b:	e8 a3 2c 00 00       	call   f01035f3 <cprintf>
		return 0;
f0100950:	83 c4 10             	add    $0x10,%esp
f0100953:	eb a4                	jmp    f01008f9 <mon_chmod+0x89>
		cprintf("Permission exceeds 0xfff; aborting.\n");
f0100955:	83 ec 0c             	sub    $0xc,%esp
f0100958:	68 0c 50 10 f0       	push   $0xf010500c
f010095d:	e8 91 2c 00 00       	call   f01035f3 <cprintf>
		return 0;
f0100962:	83 c4 10             	add    $0x10,%esp
f0100965:	eb 92                	jmp    f01008f9 <mon_chmod+0x89>
		cprintf("Warning: PTE_P flag is not provided; added automatically.");
f0100967:	83 ec 0c             	sub    $0xc,%esp
f010096a:	68 34 50 10 f0       	push   $0xf0105034
f010096f:	e8 7f 2c 00 00       	call   f01035f3 <cprintf>
		mod |= PTE_P;
f0100974:	83 4d e4 01          	orl    $0x1,-0x1c(%ebp)
f0100978:	83 c4 10             	add    $0x10,%esp
f010097b:	e9 4d ff ff ff       	jmp    f01008cd <mon_chmod+0x5d>
			if (verbose)
f0100980:	85 ff                	test   %edi,%edi
f0100982:	75 41                	jne    f01009c5 <mon_chmod+0x155>
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
f0100984:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010098a:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f010098d:	0f 87 66 ff ff ff    	ja     f01008f9 <mon_chmod+0x89>
		pte_t* pte = pgdir_walk(kern_pgdir, (void*) sz, 0);
f0100993:	83 ec 04             	sub    $0x4,%esp
f0100996:	6a 00                	push   $0x0
f0100998:	53                   	push   %ebx
f0100999:	ff 35 e8 5d 1b f0    	pushl  0xf01b5de8
f010099f:	e8 3e 09 00 00       	call   f01012e2 <pgdir_walk>
f01009a4:	89 c6                	mov    %eax,%esi
		if (pte == NULL || !*pte) {
f01009a6:	83 c4 10             	add    $0x10,%esp
f01009a9:	85 c0                	test   %eax,%eax
f01009ab:	74 d3                	je     f0100980 <mon_chmod+0x110>
f01009ad:	8b 00                	mov    (%eax),%eax
f01009af:	85 c0                	test   %eax,%eax
f01009b1:	74 cd                	je     f0100980 <mon_chmod+0x110>
			if (verbose) 
f01009b3:	85 ff                	test   %edi,%edi
f01009b5:	75 21                	jne    f01009d8 <mon_chmod+0x168>
			*pte = PTE_ADDR(*pte) | mod;
f01009b7:	8b 06                	mov    (%esi),%eax
f01009b9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009be:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01009c1:	89 06                	mov    %eax,(%esi)
f01009c3:	eb bf                	jmp    f0100984 <mon_chmod+0x114>
				cprintf("Page va = 0x%08x is not mapped; skipping.\n", sz);
f01009c5:	83 ec 08             	sub    $0x8,%esp
f01009c8:	53                   	push   %ebx
f01009c9:	68 70 50 10 f0       	push   $0xf0105070
f01009ce:	e8 20 2c 00 00       	call   f01035f3 <cprintf>
f01009d3:	83 c4 10             	add    $0x10,%esp
f01009d6:	eb ac                	jmp    f0100984 <mon_chmod+0x114>
				cprintf("Page va = 0x%08x perm = 0x%03x changed to 0x%03x\n", 
f01009d8:	ff 75 e4             	pushl  -0x1c(%ebp)
f01009db:	25 ff 0f 00 00       	and    $0xfff,%eax
f01009e0:	50                   	push   %eax
f01009e1:	53                   	push   %ebx
f01009e2:	68 9c 50 10 f0       	push   $0xf010509c
f01009e7:	e8 07 2c 00 00       	call   f01035f3 <cprintf>
f01009ec:	83 c4 10             	add    $0x10,%esp
f01009ef:	eb c6                	jmp    f01009b7 <mon_chmod+0x147>

f01009f1 <mon_dump>:

int
mon_dump(int argc, char **argv, struct Trapframe *tf) {
f01009f1:	55                   	push   %ebp
f01009f2:	89 e5                	mov    %esp,%ebp
f01009f4:	57                   	push   %edi
f01009f5:	56                   	push   %esi
f01009f6:	53                   	push   %ebx
f01009f7:	83 ec 1c             	sub    $0x1c,%esp
f01009fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (argc <= 2 || argc > 4) {
f01009fd:	8d 43 fd             	lea    -0x3(%ebx),%eax
f0100a00:	83 f8 01             	cmp    $0x1,%eax
f0100a03:	76 1d                	jbe    f0100a22 <mon_dump+0x31>
		cprintf("Usage: dump l r [-v/-p]\n");
f0100a05:	83 ec 0c             	sub    $0xc,%esp
f0100a08:	68 f0 4d 10 f0       	push   $0xf0104df0
f0100a0d:	e8 e1 2b 00 00       	call   f01035f3 <cprintf>
		return 0;
f0100a12:	83 c4 10             	add    $0x10,%esp
		cprintf("|\n");
	}
	if (ROUNDDOWN(r, 16) != r)
		cprintf("%08x  \n", r);
	return 0;
}
f0100a15:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a1d:	5b                   	pop    %ebx
f0100a1e:	5e                   	pop    %esi
f0100a1f:	5f                   	pop    %edi
f0100a20:	5d                   	pop    %ebp
f0100a21:	c3                   	ret    
	unsigned long l = strtoul(argv[1], NULL, 0),
f0100a22:	83 ec 04             	sub    $0x4,%esp
f0100a25:	6a 00                	push   $0x0
f0100a27:	6a 00                	push   $0x0
f0100a29:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a2c:	ff 70 04             	pushl  0x4(%eax)
f0100a2f:	e8 c4 3c 00 00       	call   f01046f8 <strtoul>
f0100a34:	89 c6                	mov    %eax,%esi
			  	  r = strtoul(argv[2], NULL, 0);
f0100a36:	83 c4 0c             	add    $0xc,%esp
f0100a39:	6a 00                	push   $0x0
f0100a3b:	6a 00                	push   $0x0
f0100a3d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a40:	ff 70 08             	pushl  0x8(%eax)
f0100a43:	e8 b0 3c 00 00       	call   f01046f8 <strtoul>
f0100a48:	89 c7                	mov    %eax,%edi
	if (argc <= 3)
f0100a4a:	83 c4 10             	add    $0x10,%esp
f0100a4d:	83 fb 03             	cmp    $0x3,%ebx
f0100a50:	7f 18                	jg     f0100a6a <mon_dump+0x79>
		cprintf("Defaulting to virtual address.\n");
f0100a52:	83 ec 0c             	sub    $0xc,%esp
f0100a55:	68 d0 50 10 f0       	push   $0xf01050d0
f0100a5a:	e8 94 2b 00 00       	call   f01035f3 <cprintf>
f0100a5f:	83 c4 10             	add    $0x10,%esp
	for (ptr = ROUNDDOWN(l, 16); ptr <= r; ptr += 16) {
f0100a62:	83 e6 f0             	and    $0xfffffff0,%esi
f0100a65:	e9 31 01 00 00       	jmp    f0100b9b <mon_dump+0x1aa>
	else if (!strcmp(argv[3], "-p"))
f0100a6a:	83 ec 08             	sub    $0x8,%esp
f0100a6d:	68 09 4e 10 f0       	push   $0xf0104e09
f0100a72:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100a75:	ff 70 0c             	pushl  0xc(%eax)
f0100a78:	e8 11 3a 00 00       	call   f010448e <strcmp>
f0100a7d:	83 c4 10             	add    $0x10,%esp
f0100a80:	85 c0                	test   %eax,%eax
f0100a82:	75 4f                	jne    f0100ad3 <mon_dump+0xe2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a84:	a1 e4 5d 1b f0       	mov    0xf01b5de4,%eax
f0100a89:	89 f2                	mov    %esi,%edx
f0100a8b:	c1 ea 0c             	shr    $0xc,%edx
f0100a8e:	39 c2                	cmp    %eax,%edx
f0100a90:	73 17                	jae    f0100aa9 <mon_dump+0xb8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
f0100a92:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
	if (PGNUM(pa) >= npages)
f0100a98:	89 fa                	mov    %edi,%edx
f0100a9a:	c1 ea 0c             	shr    $0xc,%edx
f0100a9d:	39 c2                	cmp    %eax,%edx
f0100a9f:	73 1d                	jae    f0100abe <mon_dump+0xcd>
	return (void *)(pa + KERNBASE);
f0100aa1:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
f0100aa7:	eb b9                	jmp    f0100a62 <mon_dump+0x71>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100aa9:	56                   	push   %esi
f0100aaa:	68 f0 50 10 f0       	push   $0xf01050f0
f0100aaf:	68 9d 00 00 00       	push   $0x9d
f0100ab4:	68 0c 4e 10 f0       	push   $0xf0104e0c
f0100ab9:	e8 8a f6 ff ff       	call   f0100148 <_panic>
f0100abe:	57                   	push   %edi
f0100abf:	68 f0 50 10 f0       	push   $0xf01050f0
f0100ac4:	68 9d 00 00 00       	push   $0x9d
f0100ac9:	68 0c 4e 10 f0       	push   $0xf0104e0c
f0100ace:	e8 75 f6 ff ff       	call   f0100148 <_panic>
	else if (strcmp(argv[3], "-v")) {
f0100ad3:	83 ec 08             	sub    $0x8,%esp
f0100ad6:	68 ed 4d 10 f0       	push   $0xf0104ded
f0100adb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100ade:	ff 70 0c             	pushl  0xc(%eax)
f0100ae1:	e8 a8 39 00 00       	call   f010448e <strcmp>
f0100ae6:	83 c4 10             	add    $0x10,%esp
f0100ae9:	85 c0                	test   %eax,%eax
f0100aeb:	0f 84 71 ff ff ff    	je     f0100a62 <mon_dump+0x71>
		cprintf("Unknown flag %s at position 3; aborting.\n", argv[3]);
f0100af1:	83 ec 08             	sub    $0x8,%esp
f0100af4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100af7:	ff 70 0c             	pushl  0xc(%eax)
f0100afa:	68 14 51 10 f0       	push   $0xf0105114
f0100aff:	e8 ef 2a 00 00       	call   f01035f3 <cprintf>
		return 0;
f0100b04:	83 c4 10             	add    $0x10,%esp
f0100b07:	e9 09 ff ff ff       	jmp    f0100a15 <mon_dump+0x24>
				cprintf("   ");
f0100b0c:	83 ec 0c             	sub    $0xc,%esp
f0100b0f:	68 28 4e 10 f0       	push   $0xf0104e28
f0100b14:	e8 da 2a 00 00       	call   f01035f3 <cprintf>
f0100b19:	83 c4 10             	add    $0x10,%esp
f0100b1c:	43                   	inc    %ebx
		for (int i = 0; i < 16; i++) {
f0100b1d:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0100b20:	74 1a                	je     f0100b3c <mon_dump+0x14b>
			if (ptr + i <= r)
f0100b22:	39 df                	cmp    %ebx,%edi
f0100b24:	72 e6                	jb     f0100b0c <mon_dump+0x11b>
				cprintf("%02x ", *(unsigned char*)(ptr + i));
f0100b26:	83 ec 08             	sub    $0x8,%esp
f0100b29:	0f b6 03             	movzbl (%ebx),%eax
f0100b2c:	50                   	push   %eax
f0100b2d:	68 22 4e 10 f0       	push   $0xf0104e22
f0100b32:	e8 bc 2a 00 00       	call   f01035f3 <cprintf>
f0100b37:	83 c4 10             	add    $0x10,%esp
f0100b3a:	eb e0                	jmp    f0100b1c <mon_dump+0x12b>
		cprintf(" |");
f0100b3c:	83 ec 0c             	sub    $0xc,%esp
f0100b3f:	68 2c 4e 10 f0       	push   $0xf0104e2c
f0100b44:	e8 aa 2a 00 00       	call   f01035f3 <cprintf>
f0100b49:	83 c4 10             	add    $0x10,%esp
f0100b4c:	eb 19                	jmp    f0100b67 <mon_dump+0x176>
				cprintf("%c", (ch >= ' ' && ch <= '~') ? ch : '.');
f0100b4e:	83 ec 08             	sub    $0x8,%esp
f0100b51:	0f be c0             	movsbl %al,%eax
f0100b54:	50                   	push   %eax
f0100b55:	68 2f 4e 10 f0       	push   $0xf0104e2f
f0100b5a:	e8 94 2a 00 00       	call   f01035f3 <cprintf>
f0100b5f:	83 c4 10             	add    $0x10,%esp
f0100b62:	46                   	inc    %esi
		for (int i = 0; i < 16; i++) {
f0100b63:	39 de                	cmp    %ebx,%esi
f0100b65:	74 24                	je     f0100b8b <mon_dump+0x19a>
			if (ptr + i <= r) {
f0100b67:	39 f7                	cmp    %esi,%edi
f0100b69:	72 0e                	jb     f0100b79 <mon_dump+0x188>
				char ch = *(char*)(ptr + i);
f0100b6b:	8a 06                	mov    (%esi),%al
				cprintf("%c", (ch >= ' ' && ch <= '~') ? ch : '.');
f0100b6d:	8d 50 e0             	lea    -0x20(%eax),%edx
f0100b70:	80 fa 5e             	cmp    $0x5e,%dl
f0100b73:	76 d9                	jbe    f0100b4e <mon_dump+0x15d>
f0100b75:	b0 2e                	mov    $0x2e,%al
f0100b77:	eb d5                	jmp    f0100b4e <mon_dump+0x15d>
				cprintf(" ");
f0100b79:	83 ec 0c             	sub    $0xc,%esp
f0100b7c:	68 6c 4e 10 f0       	push   $0xf0104e6c
f0100b81:	e8 6d 2a 00 00       	call   f01035f3 <cprintf>
f0100b86:	83 c4 10             	add    $0x10,%esp
f0100b89:	eb d7                	jmp    f0100b62 <mon_dump+0x171>
		cprintf("|\n");
f0100b8b:	83 ec 0c             	sub    $0xc,%esp
f0100b8e:	68 32 4e 10 f0       	push   $0xf0104e32
f0100b93:	e8 5b 2a 00 00       	call   f01035f3 <cprintf>
	for (ptr = ROUNDDOWN(l, 16); ptr <= r; ptr += 16) {
f0100b98:	83 c4 10             	add    $0x10,%esp
f0100b9b:	39 f7                	cmp    %esi,%edi
f0100b9d:	72 1e                	jb     f0100bbd <mon_dump+0x1cc>
		cprintf("%08x  ", ptr);
f0100b9f:	83 ec 08             	sub    $0x8,%esp
f0100ba2:	56                   	push   %esi
f0100ba3:	68 1b 4e 10 f0       	push   $0xf0104e1b
f0100ba8:	e8 46 2a 00 00       	call   f01035f3 <cprintf>
f0100bad:	8d 46 10             	lea    0x10(%esi),%eax
f0100bb0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100bb3:	83 c4 10             	add    $0x10,%esp
f0100bb6:	89 f3                	mov    %esi,%ebx
f0100bb8:	e9 65 ff ff ff       	jmp    f0100b22 <mon_dump+0x131>
	if (ROUNDDOWN(r, 16) != r)
f0100bbd:	f7 c7 0f 00 00 00    	test   $0xf,%edi
f0100bc3:	0f 84 4c fe ff ff    	je     f0100a15 <mon_dump+0x24>
		cprintf("%08x  \n", r);
f0100bc9:	83 ec 08             	sub    $0x8,%esp
f0100bcc:	57                   	push   %edi
f0100bcd:	68 35 4e 10 f0       	push   $0xf0104e35
f0100bd2:	e8 1c 2a 00 00       	call   f01035f3 <cprintf>
f0100bd7:	83 c4 10             	add    $0x10,%esp
f0100bda:	e9 36 fe ff ff       	jmp    f0100a15 <mon_dump+0x24>

f0100bdf <mon_backtrace>:
{
f0100bdf:	55                   	push   %ebp
f0100be0:	89 e5                	mov    %esp,%ebp
f0100be2:	57                   	push   %edi
f0100be3:	56                   	push   %esi
f0100be4:	53                   	push   %ebx
f0100be5:	83 ec 38             	sub    $0x38,%esp
	cprintf("Stack backtrace:\n");
f0100be8:	68 3d 4e 10 f0       	push   $0xf0104e3d
f0100bed:	e8 01 2a 00 00       	call   f01035f3 <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100bf2:	89 e8                	mov    %ebp,%eax
	while (ebp != 0) {
f0100bf4:	83 c4 10             	add    $0x10,%esp
f0100bf7:	eb 34                	jmp    f0100c2d <mon_backtrace+0x4e>
			cprintf("%c", info.eip_fn_name[i]);
f0100bf9:	83 ec 08             	sub    $0x8,%esp
f0100bfc:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100bff:	0f be 04 18          	movsbl (%eax,%ebx,1),%eax
f0100c03:	50                   	push   %eax
f0100c04:	68 2f 4e 10 f0       	push   $0xf0104e2f
f0100c09:	e8 e5 29 00 00       	call   f01035f3 <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f0100c0e:	43                   	inc    %ebx
f0100c0f:	83 c4 10             	add    $0x10,%esp
f0100c12:	39 5d dc             	cmp    %ebx,-0x24(%ebp)
f0100c15:	7f e2                	jg     f0100bf9 <mon_backtrace+0x1a>
		cprintf("+%d\n", eip - info.eip_fn_addr);
f0100c17:	83 ec 08             	sub    $0x8,%esp
f0100c1a:	2b 75 e0             	sub    -0x20(%ebp),%esi
f0100c1d:	56                   	push   %esi
f0100c1e:	68 60 4e 10 f0       	push   $0xf0104e60
f0100c23:	e8 cb 29 00 00       	call   f01035f3 <cprintf>
		ebp = prev_ebp;
f0100c28:	83 c4 10             	add    $0x10,%esp
f0100c2b:	89 f8                	mov    %edi,%eax
	while (ebp != 0) {
f0100c2d:	85 c0                	test   %eax,%eax
f0100c2f:	74 4a                	je     f0100c7b <mon_backtrace+0x9c>
		prev_ebp = *(int*)ebp;
f0100c31:	8b 38                	mov    (%eax),%edi
		eip = *((int*)ebp + 1);
f0100c33:	8b 70 04             	mov    0x4(%eax),%esi
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, 
f0100c36:	ff 70 18             	pushl  0x18(%eax)
f0100c39:	ff 70 14             	pushl  0x14(%eax)
f0100c3c:	ff 70 10             	pushl  0x10(%eax)
f0100c3f:	ff 70 0c             	pushl  0xc(%eax)
f0100c42:	ff 70 08             	pushl  0x8(%eax)
f0100c45:	56                   	push   %esi
f0100c46:	50                   	push   %eax
f0100c47:	68 40 51 10 f0       	push   $0xf0105140
f0100c4c:	e8 a2 29 00 00       	call   f01035f3 <cprintf>
		int code = debuginfo_eip((uintptr_t)eip, &info);
f0100c51:	83 c4 18             	add    $0x18,%esp
f0100c54:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100c57:	50                   	push   %eax
f0100c58:	56                   	push   %esi
f0100c59:	e8 78 2e 00 00       	call   f0103ad6 <debuginfo_eip>
		cprintf("         %s:%d: ", info.eip_file, info.eip_line);
f0100c5e:	83 c4 0c             	add    $0xc,%esp
f0100c61:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100c64:	ff 75 d0             	pushl  -0x30(%ebp)
f0100c67:	68 4f 4e 10 f0       	push   $0xf0104e4f
f0100c6c:	e8 82 29 00 00       	call   f01035f3 <cprintf>
		for (int i = 0; i < info.eip_fn_namelen; i++)
f0100c71:	83 c4 10             	add    $0x10,%esp
f0100c74:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100c79:	eb 97                	jmp    f0100c12 <mon_backtrace+0x33>
}
f0100c7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c7e:	5b                   	pop    %ebx
f0100c7f:	5e                   	pop    %esi
f0100c80:	5f                   	pop    %edi
f0100c81:	5d                   	pop    %ebp
f0100c82:	c3                   	ret    

f0100c83 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100c83:	55                   	push   %ebp
f0100c84:	89 e5                	mov    %esp,%ebp
f0100c86:	57                   	push   %edi
f0100c87:	56                   	push   %esi
f0100c88:	53                   	push   %ebx
f0100c89:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100c8c:	68 78 51 10 f0       	push   $0xf0105178
f0100c91:	e8 5d 29 00 00       	call   f01035f3 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100c96:	c7 04 24 9c 51 10 f0 	movl   $0xf010519c,(%esp)
f0100c9d:	e8 51 29 00 00       	call   f01035f3 <cprintf>

	if (tf != NULL)
f0100ca2:	83 c4 10             	add    $0x10,%esp
f0100ca5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100ca9:	74 57                	je     f0100d02 <monitor+0x7f>
		print_trapframe(tf);
f0100cab:	83 ec 0c             	sub    $0xc,%esp
f0100cae:	ff 75 08             	pushl  0x8(%ebp)
f0100cb1:	e8 4f 2a 00 00       	call   f0103705 <print_trapframe>
f0100cb6:	83 c4 10             	add    $0x10,%esp
f0100cb9:	eb 47                	jmp    f0100d02 <monitor+0x7f>
		while (*buf && strchr(WHITESPACE, *buf))
f0100cbb:	83 ec 08             	sub    $0x8,%esp
f0100cbe:	0f be c0             	movsbl %al,%eax
f0100cc1:	50                   	push   %eax
f0100cc2:	68 69 4e 10 f0       	push   $0xf0104e69
f0100cc7:	e8 16 38 00 00       	call   f01044e2 <strchr>
f0100ccc:	83 c4 10             	add    $0x10,%esp
f0100ccf:	85 c0                	test   %eax,%eax
f0100cd1:	74 0a                	je     f0100cdd <monitor+0x5a>
			*buf++ = 0;
f0100cd3:	c6 03 00             	movb   $0x0,(%ebx)
f0100cd6:	89 f7                	mov    %esi,%edi
f0100cd8:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100cdb:	eb 68                	jmp    f0100d45 <monitor+0xc2>
		if (*buf == 0)
f0100cdd:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100ce0:	74 6f                	je     f0100d51 <monitor+0xce>
		if (argc == MAXARGS-1) {
f0100ce2:	83 fe 0f             	cmp    $0xf,%esi
f0100ce5:	74 09                	je     f0100cf0 <monitor+0x6d>
		argv[argc++] = buf;
f0100ce7:	8d 7e 01             	lea    0x1(%esi),%edi
f0100cea:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100cee:	eb 37                	jmp    f0100d27 <monitor+0xa4>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100cf0:	83 ec 08             	sub    $0x8,%esp
f0100cf3:	6a 10                	push   $0x10
f0100cf5:	68 6e 4e 10 f0       	push   $0xf0104e6e
f0100cfa:	e8 f4 28 00 00       	call   f01035f3 <cprintf>
f0100cff:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100d02:	83 ec 0c             	sub    $0xc,%esp
f0100d05:	68 65 4e 10 f0       	push   $0xf0104e65
f0100d0a:	e8 c8 35 00 00       	call   f01042d7 <readline>
f0100d0f:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100d11:	83 c4 10             	add    $0x10,%esp
f0100d14:	85 c0                	test   %eax,%eax
f0100d16:	74 ea                	je     f0100d02 <monitor+0x7f>
	argv[argc] = 0;
f0100d18:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100d1f:	be 00 00 00 00       	mov    $0x0,%esi
f0100d24:	eb 21                	jmp    f0100d47 <monitor+0xc4>
			buf++;
f0100d26:	43                   	inc    %ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100d27:	8a 03                	mov    (%ebx),%al
f0100d29:	84 c0                	test   %al,%al
f0100d2b:	74 18                	je     f0100d45 <monitor+0xc2>
f0100d2d:	83 ec 08             	sub    $0x8,%esp
f0100d30:	0f be c0             	movsbl %al,%eax
f0100d33:	50                   	push   %eax
f0100d34:	68 69 4e 10 f0       	push   $0xf0104e69
f0100d39:	e8 a4 37 00 00       	call   f01044e2 <strchr>
f0100d3e:	83 c4 10             	add    $0x10,%esp
f0100d41:	85 c0                	test   %eax,%eax
f0100d43:	74 e1                	je     f0100d26 <monitor+0xa3>
			*buf++ = 0;
f0100d45:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100d47:	8a 03                	mov    (%ebx),%al
f0100d49:	84 c0                	test   %al,%al
f0100d4b:	0f 85 6a ff ff ff    	jne    f0100cbb <monitor+0x38>
	argv[argc] = 0;
f0100d51:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100d58:	00 
	if (argc == 0)
f0100d59:	85 f6                	test   %esi,%esi
f0100d5b:	74 a5                	je     f0100d02 <monitor+0x7f>
f0100d5d:	bf 80 52 10 f0       	mov    $0xf0105280,%edi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100d62:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f0100d67:	83 ec 08             	sub    $0x8,%esp
f0100d6a:	ff 37                	pushl  (%edi)
f0100d6c:	ff 75 a8             	pushl  -0x58(%ebp)
f0100d6f:	e8 1a 37 00 00       	call   f010448e <strcmp>
f0100d74:	83 c4 10             	add    $0x10,%esp
f0100d77:	85 c0                	test   %eax,%eax
f0100d79:	74 21                	je     f0100d9c <monitor+0x119>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100d7b:	43                   	inc    %ebx
f0100d7c:	83 c7 0c             	add    $0xc,%edi
f0100d7f:	83 fb 05             	cmp    $0x5,%ebx
f0100d82:	75 e3                	jne    f0100d67 <monitor+0xe4>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100d84:	83 ec 08             	sub    $0x8,%esp
f0100d87:	ff 75 a8             	pushl  -0x58(%ebp)
f0100d8a:	68 8b 4e 10 f0       	push   $0xf0104e8b
f0100d8f:	e8 5f 28 00 00       	call   f01035f3 <cprintf>
f0100d94:	83 c4 10             	add    $0x10,%esp
f0100d97:	e9 66 ff ff ff       	jmp    f0100d02 <monitor+0x7f>
			return commands[i].func(argc, argv, tf);
f0100d9c:	83 ec 04             	sub    $0x4,%esp
f0100d9f:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0100da2:	01 c3                	add    %eax,%ebx
f0100da4:	ff 75 08             	pushl  0x8(%ebp)
f0100da7:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100daa:	50                   	push   %eax
f0100dab:	56                   	push   %esi
f0100dac:	ff 14 9d 88 52 10 f0 	call   *-0xfefad78(,%ebx,4)
			if (runcmd(buf, tf) < 0)
f0100db3:	83 c4 10             	add    $0x10,%esp
f0100db6:	85 c0                	test   %eax,%eax
f0100db8:	0f 89 44 ff ff ff    	jns    f0100d02 <monitor+0x7f>
				break;
	}
}
f0100dbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100dc1:	5b                   	pop    %ebx
f0100dc2:	5e                   	pop    %esi
f0100dc3:	5f                   	pop    %edi
f0100dc4:	5d                   	pop    %ebp
f0100dc5:	c3                   	ret    

f0100dc6 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100dc6:	55                   	push   %ebp
f0100dc7:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100dc9:	83 3d 18 51 1b f0 00 	cmpl   $0x0,0xf01b5118
f0100dd0:	74 1f                	je     f0100df1 <boot_alloc+0x2b>
	}

	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	if (!n)
f0100dd2:	85 c0                	test   %eax,%eax
f0100dd4:	74 2e                	je     f0100e04 <boot_alloc+0x3e>
		return (void*)nextfree;
	else {
		result = nextfree;
f0100dd6:	8b 15 18 51 1b f0    	mov    0xf01b5118,%edx
		nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100ddc:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100de3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100de8:	a3 18 51 1b f0       	mov    %eax,0xf01b5118
		return (void*)result;
	}
}
f0100ded:	89 d0                	mov    %edx,%eax
f0100def:	5d                   	pop    %ebp
f0100df0:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100df1:	ba ef 6d 1b f0       	mov    $0xf01b6def,%edx
f0100df6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100dfc:	89 15 18 51 1b f0    	mov    %edx,0xf01b5118
f0100e02:	eb ce                	jmp    f0100dd2 <boot_alloc+0xc>
		return (void*)nextfree;
f0100e04:	8b 15 18 51 1b f0    	mov    0xf01b5118,%edx
f0100e0a:	eb e1                	jmp    f0100ded <boot_alloc+0x27>

f0100e0c <nvram_read>:
{
f0100e0c:	55                   	push   %ebp
f0100e0d:	89 e5                	mov    %esp,%ebp
f0100e0f:	56                   	push   %esi
f0100e10:	53                   	push   %ebx
f0100e11:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100e13:	83 ec 0c             	sub    $0xc,%esp
f0100e16:	50                   	push   %eax
f0100e17:	e8 70 27 00 00       	call   f010358c <mc146818_read>
f0100e1c:	89 c3                	mov    %eax,%ebx
f0100e1e:	46                   	inc    %esi
f0100e1f:	89 34 24             	mov    %esi,(%esp)
f0100e22:	e8 65 27 00 00       	call   f010358c <mc146818_read>
f0100e27:	c1 e0 08             	shl    $0x8,%eax
f0100e2a:	09 d8                	or     %ebx,%eax
}
f0100e2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100e2f:	5b                   	pop    %ebx
f0100e30:	5e                   	pop    %esi
f0100e31:	5d                   	pop    %ebp
f0100e32:	c3                   	ret    

f0100e33 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100e33:	89 d1                	mov    %edx,%ecx
f0100e35:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100e38:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100e3b:	a8 01                	test   $0x1,%al
f0100e3d:	74 47                	je     f0100e86 <check_va2pa+0x53>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100e3f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100e44:	89 c1                	mov    %eax,%ecx
f0100e46:	c1 e9 0c             	shr    $0xc,%ecx
f0100e49:	3b 0d e4 5d 1b f0    	cmp    0xf01b5de4,%ecx
f0100e4f:	73 1a                	jae    f0100e6b <check_va2pa+0x38>
	if (!(p[PTX(va)] & PTE_P))
f0100e51:	c1 ea 0c             	shr    $0xc,%edx
f0100e54:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100e5a:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100e61:	a8 01                	test   $0x1,%al
f0100e63:	74 27                	je     f0100e8c <check_va2pa+0x59>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100e65:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100e6a:	c3                   	ret    
{
f0100e6b:	55                   	push   %ebp
f0100e6c:	89 e5                	mov    %esp,%ebp
f0100e6e:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e71:	50                   	push   %eax
f0100e72:	68 f0 50 10 f0       	push   $0xf01050f0
f0100e77:	68 ff 02 00 00       	push   $0x2ff
f0100e7c:	68 41 5a 10 f0       	push   $0xf0105a41
f0100e81:	e8 c2 f2 ff ff       	call   f0100148 <_panic>
		return ~0;
f0100e86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e8b:	c3                   	ret    
		return ~0;
f0100e8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100e91:	c3                   	ret    

f0100e92 <check_page_free_list>:
{
f0100e92:	55                   	push   %ebp
f0100e93:	89 e5                	mov    %esp,%ebp
f0100e95:	57                   	push   %edi
f0100e96:	56                   	push   %esi
f0100e97:	53                   	push   %ebx
f0100e98:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e9b:	84 c0                	test   %al,%al
f0100e9d:	0f 85 50 02 00 00    	jne    f01010f3 <check_page_free_list+0x261>
	if (!page_free_list)
f0100ea3:	83 3d 1c 51 1b f0 00 	cmpl   $0x0,0xf01b511c
f0100eaa:	74 0a                	je     f0100eb6 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100eac:	be 00 04 00 00       	mov    $0x400,%esi
f0100eb1:	e9 98 02 00 00       	jmp    f010114e <check_page_free_list+0x2bc>
		panic("'page_free_list' is a null pointer!");
f0100eb6:	83 ec 04             	sub    $0x4,%esp
f0100eb9:	68 bc 52 10 f0       	push   $0xf01052bc
f0100ebe:	68 3a 02 00 00       	push   $0x23a
f0100ec3:	68 41 5a 10 f0       	push   $0xf0105a41
f0100ec8:	e8 7b f2 ff ff       	call   f0100148 <_panic>
f0100ecd:	50                   	push   %eax
f0100ece:	68 f0 50 10 f0       	push   $0xf01050f0
f0100ed3:	6a 56                	push   $0x56
f0100ed5:	68 4d 5a 10 f0       	push   $0xf0105a4d
f0100eda:	e8 69 f2 ff ff       	call   f0100148 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100edf:	8b 1b                	mov    (%ebx),%ebx
f0100ee1:	85 db                	test   %ebx,%ebx
f0100ee3:	74 41                	je     f0100f26 <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ee5:	89 d8                	mov    %ebx,%eax
f0100ee7:	2b 05 ec 5d 1b f0    	sub    0xf01b5dec,%eax
f0100eed:	c1 f8 03             	sar    $0x3,%eax
f0100ef0:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100ef3:	89 c2                	mov    %eax,%edx
f0100ef5:	c1 ea 16             	shr    $0x16,%edx
f0100ef8:	39 f2                	cmp    %esi,%edx
f0100efa:	73 e3                	jae    f0100edf <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100efc:	89 c2                	mov    %eax,%edx
f0100efe:	c1 ea 0c             	shr    $0xc,%edx
f0100f01:	3b 15 e4 5d 1b f0    	cmp    0xf01b5de4,%edx
f0100f07:	73 c4                	jae    f0100ecd <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100f09:	83 ec 04             	sub    $0x4,%esp
f0100f0c:	68 80 00 00 00       	push   $0x80
f0100f11:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100f16:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f1b:	50                   	push   %eax
f0100f1c:	e8 f6 35 00 00       	call   f0104517 <memset>
f0100f21:	83 c4 10             	add    $0x10,%esp
f0100f24:	eb b9                	jmp    f0100edf <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100f26:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f2b:	e8 96 fe ff ff       	call   f0100dc6 <boot_alloc>
f0100f30:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f33:	8b 15 1c 51 1b f0    	mov    0xf01b511c,%edx
		assert(pp >= pages);
f0100f39:	8b 0d ec 5d 1b f0    	mov    0xf01b5dec,%ecx
		assert(pp < pages + npages);
f0100f3f:	a1 e4 5d 1b f0       	mov    0xf01b5de4,%eax
f0100f44:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100f47:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100f4a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0100f4d:	be 00 00 00 00       	mov    $0x0,%esi
f0100f52:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f55:	e9 c8 00 00 00       	jmp    f0101022 <check_page_free_list+0x190>
		assert(pp >= pages);
f0100f5a:	68 5b 5a 10 f0       	push   $0xf0105a5b
f0100f5f:	68 67 5a 10 f0       	push   $0xf0105a67
f0100f64:	68 54 02 00 00       	push   $0x254
f0100f69:	68 41 5a 10 f0       	push   $0xf0105a41
f0100f6e:	e8 d5 f1 ff ff       	call   f0100148 <_panic>
		assert(pp < pages + npages);
f0100f73:	68 7c 5a 10 f0       	push   $0xf0105a7c
f0100f78:	68 67 5a 10 f0       	push   $0xf0105a67
f0100f7d:	68 55 02 00 00       	push   $0x255
f0100f82:	68 41 5a 10 f0       	push   $0xf0105a41
f0100f87:	e8 bc f1 ff ff       	call   f0100148 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100f8c:	68 e0 52 10 f0       	push   $0xf01052e0
f0100f91:	68 67 5a 10 f0       	push   $0xf0105a67
f0100f96:	68 56 02 00 00       	push   $0x256
f0100f9b:	68 41 5a 10 f0       	push   $0xf0105a41
f0100fa0:	e8 a3 f1 ff ff       	call   f0100148 <_panic>
		assert(page2pa(pp) != 0);
f0100fa5:	68 90 5a 10 f0       	push   $0xf0105a90
f0100faa:	68 67 5a 10 f0       	push   $0xf0105a67
f0100faf:	68 59 02 00 00       	push   $0x259
f0100fb4:	68 41 5a 10 f0       	push   $0xf0105a41
f0100fb9:	e8 8a f1 ff ff       	call   f0100148 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100fbe:	68 a1 5a 10 f0       	push   $0xf0105aa1
f0100fc3:	68 67 5a 10 f0       	push   $0xf0105a67
f0100fc8:	68 5a 02 00 00       	push   $0x25a
f0100fcd:	68 41 5a 10 f0       	push   $0xf0105a41
f0100fd2:	e8 71 f1 ff ff       	call   f0100148 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100fd7:	68 14 53 10 f0       	push   $0xf0105314
f0100fdc:	68 67 5a 10 f0       	push   $0xf0105a67
f0100fe1:	68 5b 02 00 00       	push   $0x25b
f0100fe6:	68 41 5a 10 f0       	push   $0xf0105a41
f0100feb:	e8 58 f1 ff ff       	call   f0100148 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100ff0:	68 ba 5a 10 f0       	push   $0xf0105aba
f0100ff5:	68 67 5a 10 f0       	push   $0xf0105a67
f0100ffa:	68 5c 02 00 00       	push   $0x25c
f0100fff:	68 41 5a 10 f0       	push   $0xf0105a41
f0101004:	e8 3f f1 ff ff       	call   f0100148 <_panic>
	if (PGNUM(pa) >= npages)
f0101009:	89 c3                	mov    %eax,%ebx
f010100b:	c1 eb 0c             	shr    $0xc,%ebx
f010100e:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f0101011:	76 63                	jbe    f0101076 <check_page_free_list+0x1e4>
	return (void *)(pa + KERNBASE);
f0101013:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101018:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f010101b:	77 6b                	ja     f0101088 <check_page_free_list+0x1f6>
			++nfree_extmem;
f010101d:	ff 45 d0             	incl   -0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101020:	8b 12                	mov    (%edx),%edx
f0101022:	85 d2                	test   %edx,%edx
f0101024:	74 7b                	je     f01010a1 <check_page_free_list+0x20f>
		assert(pp >= pages);
f0101026:	39 d1                	cmp    %edx,%ecx
f0101028:	0f 87 2c ff ff ff    	ja     f0100f5a <check_page_free_list+0xc8>
		assert(pp < pages + npages);
f010102e:	39 d7                	cmp    %edx,%edi
f0101030:	0f 86 3d ff ff ff    	jbe    f0100f73 <check_page_free_list+0xe1>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101036:	89 d0                	mov    %edx,%eax
f0101038:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f010103b:	a8 07                	test   $0x7,%al
f010103d:	0f 85 49 ff ff ff    	jne    f0100f8c <check_page_free_list+0xfa>
	return (pp - pages) << PGSHIFT;
f0101043:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0101046:	c1 e0 0c             	shl    $0xc,%eax
f0101049:	0f 84 56 ff ff ff    	je     f0100fa5 <check_page_free_list+0x113>
		assert(page2pa(pp) != IOPHYSMEM);
f010104f:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101054:	0f 84 64 ff ff ff    	je     f0100fbe <check_page_free_list+0x12c>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010105a:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f010105f:	0f 84 72 ff ff ff    	je     f0100fd7 <check_page_free_list+0x145>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101065:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010106a:	74 84                	je     f0100ff0 <check_page_free_list+0x15e>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010106c:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101071:	77 96                	ja     f0101009 <check_page_free_list+0x177>
			++nfree_basemem;
f0101073:	46                   	inc    %esi
f0101074:	eb aa                	jmp    f0101020 <check_page_free_list+0x18e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101076:	50                   	push   %eax
f0101077:	68 f0 50 10 f0       	push   $0xf01050f0
f010107c:	6a 56                	push   $0x56
f010107e:	68 4d 5a 10 f0       	push   $0xf0105a4d
f0101083:	e8 c0 f0 ff ff       	call   f0100148 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101088:	68 38 53 10 f0       	push   $0xf0105338
f010108d:	68 67 5a 10 f0       	push   $0xf0105a67
f0101092:	68 5d 02 00 00       	push   $0x25d
f0101097:	68 41 5a 10 f0       	push   $0xf0105a41
f010109c:	e8 a7 f0 ff ff       	call   f0100148 <_panic>
f01010a1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
	assert(nfree_basemem > 0);
f01010a4:	85 f6                	test   %esi,%esi
f01010a6:	7e 19                	jle    f01010c1 <check_page_free_list+0x22f>
	assert(nfree_extmem > 0);
f01010a8:	85 db                	test   %ebx,%ebx
f01010aa:	7e 2e                	jle    f01010da <check_page_free_list+0x248>
	cprintf("check_page_free_list() succeeded!\n");
f01010ac:	83 ec 0c             	sub    $0xc,%esp
f01010af:	68 80 53 10 f0       	push   $0xf0105380
f01010b4:	e8 3a 25 00 00       	call   f01035f3 <cprintf>
}
f01010b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010bc:	5b                   	pop    %ebx
f01010bd:	5e                   	pop    %esi
f01010be:	5f                   	pop    %edi
f01010bf:	5d                   	pop    %ebp
f01010c0:	c3                   	ret    
	assert(nfree_basemem > 0);
f01010c1:	68 d4 5a 10 f0       	push   $0xf0105ad4
f01010c6:	68 67 5a 10 f0       	push   $0xf0105a67
f01010cb:	68 65 02 00 00       	push   $0x265
f01010d0:	68 41 5a 10 f0       	push   $0xf0105a41
f01010d5:	e8 6e f0 ff ff       	call   f0100148 <_panic>
	assert(nfree_extmem > 0);
f01010da:	68 e6 5a 10 f0       	push   $0xf0105ae6
f01010df:	68 67 5a 10 f0       	push   $0xf0105a67
f01010e4:	68 66 02 00 00       	push   $0x266
f01010e9:	68 41 5a 10 f0       	push   $0xf0105a41
f01010ee:	e8 55 f0 ff ff       	call   f0100148 <_panic>
	if (!page_free_list)
f01010f3:	a1 1c 51 1b f0       	mov    0xf01b511c,%eax
f01010f8:	85 c0                	test   %eax,%eax
f01010fa:	0f 84 b6 fd ff ff    	je     f0100eb6 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0101100:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0101103:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101106:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0101109:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f010110c:	89 c2                	mov    %eax,%edx
f010110e:	2b 15 ec 5d 1b f0    	sub    0xf01b5dec,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit; 
f0101114:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f010111a:	0f 95 c2             	setne  %dl
f010111d:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0101120:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0101124:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0101126:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f010112a:	8b 00                	mov    (%eax),%eax
f010112c:	85 c0                	test   %eax,%eax
f010112e:	75 dc                	jne    f010110c <check_page_free_list+0x27a>
		*tp[1] = 0;
f0101130:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101133:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101139:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010113c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010113f:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101141:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101144:	a3 1c 51 1b f0       	mov    %eax,0xf01b511c
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101149:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010114e:	8b 1d 1c 51 1b f0    	mov    0xf01b511c,%ebx
f0101154:	e9 88 fd ff ff       	jmp    f0100ee1 <check_page_free_list+0x4f>

f0101159 <page_init>:
{
f0101159:	55                   	push   %ebp
f010115a:	89 e5                	mov    %esp,%ebp
f010115c:	57                   	push   %edi
f010115d:	56                   	push   %esi
f010115e:	53                   	push   %ebx
f010115f:	83 ec 1c             	sub    $0x1c,%esp
	physaddr_t free = (physaddr_t) PADDR(boot_alloc(0));
f0101162:	b8 00 00 00 00       	mov    $0x0,%eax
f0101167:	e8 5a fc ff ff       	call   f0100dc6 <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f010116c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101171:	76 22                	jbe    f0101195 <page_init+0x3c>
	return (physaddr_t)kva - KERNBASE;
f0101173:	05 00 00 00 10       	add    $0x10000000,%eax
f0101178:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if (i >= npages_basemem && i * PGSIZE < free)
f010117b:	8b 35 20 51 1b f0    	mov    0xf01b5120,%esi
f0101181:	8b 1d 1c 51 1b f0    	mov    0xf01b511c,%ebx
	for (i = 1; i < npages; i++) {
f0101187:	b2 00                	mov    $0x0,%dl
f0101189:	b8 01 00 00 00       	mov    $0x1,%eax
		page_free_list = &pages[i];
f010118e:	bf 01 00 00 00       	mov    $0x1,%edi
	for (i = 1; i < npages; i++) {
f0101193:	eb 37                	jmp    f01011cc <page_init+0x73>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101195:	50                   	push   %eax
f0101196:	68 a4 53 10 f0       	push   $0xf01053a4
f010119b:	68 18 01 00 00       	push   $0x118
f01011a0:	68 41 5a 10 f0       	push   $0xf0105a41
f01011a5:	e8 9e ef ff ff       	call   f0100148 <_panic>
		pages[i].pp_ref = 0;
f01011aa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01011b1:	89 d1                	mov    %edx,%ecx
f01011b3:	03 0d ec 5d 1b f0    	add    0xf01b5dec,%ecx
f01011b9:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f01011bf:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f01011c1:	89 d3                	mov    %edx,%ebx
f01011c3:	03 1d ec 5d 1b f0    	add    0xf01b5dec,%ebx
f01011c9:	89 fa                	mov    %edi,%edx
	for (i = 1; i < npages; i++) {
f01011cb:	40                   	inc    %eax
f01011cc:	39 05 e4 5d 1b f0    	cmp    %eax,0xf01b5de4
f01011d2:	76 10                	jbe    f01011e4 <page_init+0x8b>
		if (i >= npages_basemem && i * PGSIZE < free)
f01011d4:	39 c6                	cmp    %eax,%esi
f01011d6:	77 d2                	ja     f01011aa <page_init+0x51>
f01011d8:	89 c1                	mov    %eax,%ecx
f01011da:	c1 e1 0c             	shl    $0xc,%ecx
f01011dd:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
f01011e0:	76 c8                	jbe    f01011aa <page_init+0x51>
f01011e2:	eb e7                	jmp    f01011cb <page_init+0x72>
f01011e4:	84 d2                	test   %dl,%dl
f01011e6:	75 08                	jne    f01011f0 <page_init+0x97>
}
f01011e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011eb:	5b                   	pop    %ebx
f01011ec:	5e                   	pop    %esi
f01011ed:	5f                   	pop    %edi
f01011ee:	5d                   	pop    %ebp
f01011ef:	c3                   	ret    
f01011f0:	89 1d 1c 51 1b f0    	mov    %ebx,0xf01b511c
f01011f6:	eb f0                	jmp    f01011e8 <page_init+0x8f>

f01011f8 <page_alloc>:
{
f01011f8:	55                   	push   %ebp
f01011f9:	89 e5                	mov    %esp,%ebp
f01011fb:	53                   	push   %ebx
f01011fc:	83 ec 04             	sub    $0x4,%esp
	struct PageInfo* next = page_free_list;
f01011ff:	8b 1d 1c 51 1b f0    	mov    0xf01b511c,%ebx
	if (!next)
f0101205:	85 db                	test   %ebx,%ebx
f0101207:	74 13                	je     f010121c <page_alloc+0x24>
	page_free_list = page_free_list->pp_link;
f0101209:	8b 03                	mov    (%ebx),%eax
f010120b:	a3 1c 51 1b f0       	mov    %eax,0xf01b511c
	next->pp_link = NULL;
f0101210:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f0101216:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010121a:	75 07                	jne    f0101223 <page_alloc+0x2b>
}
f010121c:	89 d8                	mov    %ebx,%eax
f010121e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101221:	c9                   	leave  
f0101222:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0101223:	89 d8                	mov    %ebx,%eax
f0101225:	2b 05 ec 5d 1b f0    	sub    0xf01b5dec,%eax
f010122b:	c1 f8 03             	sar    $0x3,%eax
f010122e:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101231:	89 c2                	mov    %eax,%edx
f0101233:	c1 ea 0c             	shr    $0xc,%edx
f0101236:	3b 15 e4 5d 1b f0    	cmp    0xf01b5de4,%edx
f010123c:	73 1a                	jae    f0101258 <page_alloc+0x60>
		memset(content, 0, PGSIZE);
f010123e:	83 ec 04             	sub    $0x4,%esp
f0101241:	68 00 10 00 00       	push   $0x1000
f0101246:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0101248:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010124d:	50                   	push   %eax
f010124e:	e8 c4 32 00 00       	call   f0104517 <memset>
f0101253:	83 c4 10             	add    $0x10,%esp
f0101256:	eb c4                	jmp    f010121c <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101258:	50                   	push   %eax
f0101259:	68 f0 50 10 f0       	push   $0xf01050f0
f010125e:	6a 56                	push   $0x56
f0101260:	68 4d 5a 10 f0       	push   $0xf0105a4d
f0101265:	e8 de ee ff ff       	call   f0100148 <_panic>

f010126a <page_free>:
{
f010126a:	55                   	push   %ebp
f010126b:	89 e5                	mov    %esp,%ebp
f010126d:	83 ec 08             	sub    $0x8,%esp
f0101270:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref)
f0101273:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101278:	75 14                	jne    f010128e <page_free+0x24>
	if (pp->pp_link)
f010127a:	83 38 00             	cmpl   $0x0,(%eax)
f010127d:	75 26                	jne    f01012a5 <page_free+0x3b>
	pp->pp_link = page_free_list;
f010127f:	8b 15 1c 51 1b f0    	mov    0xf01b511c,%edx
f0101285:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101287:	a3 1c 51 1b f0       	mov    %eax,0xf01b511c
}
f010128c:	c9                   	leave  
f010128d:	c3                   	ret    
		panic("Ref count is non-zero");
f010128e:	83 ec 04             	sub    $0x4,%esp
f0101291:	68 f7 5a 10 f0       	push   $0xf0105af7
f0101296:	68 45 01 00 00       	push   $0x145
f010129b:	68 41 5a 10 f0       	push   $0xf0105a41
f01012a0:	e8 a3 ee ff ff       	call   f0100148 <_panic>
		panic("Page is double-freed");
f01012a5:	83 ec 04             	sub    $0x4,%esp
f01012a8:	68 0d 5b 10 f0       	push   $0xf0105b0d
f01012ad:	68 47 01 00 00       	push   $0x147
f01012b2:	68 41 5a 10 f0       	push   $0xf0105a41
f01012b7:	e8 8c ee ff ff       	call   f0100148 <_panic>

f01012bc <page_decref>:
{
f01012bc:	55                   	push   %ebp
f01012bd:	89 e5                	mov    %esp,%ebp
f01012bf:	83 ec 08             	sub    $0x8,%esp
f01012c2:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01012c5:	8b 42 04             	mov    0x4(%edx),%eax
f01012c8:	48                   	dec    %eax
f01012c9:	66 89 42 04          	mov    %ax,0x4(%edx)
f01012cd:	66 85 c0             	test   %ax,%ax
f01012d0:	74 02                	je     f01012d4 <page_decref+0x18>
}
f01012d2:	c9                   	leave  
f01012d3:	c3                   	ret    
		page_free(pp);
f01012d4:	83 ec 0c             	sub    $0xc,%esp
f01012d7:	52                   	push   %edx
f01012d8:	e8 8d ff ff ff       	call   f010126a <page_free>
f01012dd:	83 c4 10             	add    $0x10,%esp
}
f01012e0:	eb f0                	jmp    f01012d2 <page_decref+0x16>

f01012e2 <pgdir_walk>:
{
f01012e2:	55                   	push   %ebp
f01012e3:	89 e5                	mov    %esp,%ebp
f01012e5:	57                   	push   %edi
f01012e6:	56                   	push   %esi
f01012e7:	53                   	push   %ebx
f01012e8:	83 ec 1c             	sub    $0x1c,%esp
	pde_t pd_entry = (pde_t)pgdir[PDX(va)];
f01012eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01012ee:	c1 eb 16             	shr    $0x16,%ebx
f01012f1:	c1 e3 02             	shl    $0x2,%ebx
f01012f4:	03 5d 08             	add    0x8(%ebp),%ebx
f01012f7:	8b 03                	mov    (%ebx),%eax
	if (pd_entry) {
f01012f9:	85 c0                	test   %eax,%eax
f01012fb:	74 42                	je     f010133f <pgdir_walk+0x5d>
		pte_t* pt_base = KADDR(PTE_ADDR(pd_entry));
f01012fd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101302:	89 c2                	mov    %eax,%edx
f0101304:	c1 ea 0c             	shr    $0xc,%edx
f0101307:	39 15 e4 5d 1b f0    	cmp    %edx,0xf01b5de4
f010130d:	76 1b                	jbe    f010132a <pgdir_walk+0x48>
		return pt_base + PTX(va);
f010130f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101312:	c1 ea 0a             	shr    $0xa,%edx
f0101315:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f010131b:	8d 84 10 00 00 00 f0 	lea    -0x10000000(%eax,%edx,1),%eax
}
f0101322:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101325:	5b                   	pop    %ebx
f0101326:	5e                   	pop    %esi
f0101327:	5f                   	pop    %edi
f0101328:	5d                   	pop    %ebp
f0101329:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010132a:	50                   	push   %eax
f010132b:	68 f0 50 10 f0       	push   $0xf01050f0
f0101330:	68 72 01 00 00       	push   $0x172
f0101335:	68 41 5a 10 f0       	push   $0xf0105a41
f010133a:	e8 09 ee ff ff       	call   f0100148 <_panic>
	else if (create) {
f010133f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101343:	0f 84 9c 00 00 00    	je     f01013e5 <pgdir_walk+0x103>
		struct PageInfo *new_pt = page_alloc(0);
f0101349:	83 ec 0c             	sub    $0xc,%esp
f010134c:	6a 00                	push   $0x0
f010134e:	e8 a5 fe ff ff       	call   f01011f8 <page_alloc>
f0101353:	89 c7                	mov    %eax,%edi
		if (new_pt) {
f0101355:	83 c4 10             	add    $0x10,%esp
f0101358:	85 c0                	test   %eax,%eax
f010135a:	0f 84 8f 00 00 00    	je     f01013ef <pgdir_walk+0x10d>
	return (pp - pages) << PGSHIFT;
f0101360:	2b 05 ec 5d 1b f0    	sub    0xf01b5dec,%eax
f0101366:	c1 f8 03             	sar    $0x3,%eax
f0101369:	c1 e0 0c             	shl    $0xc,%eax
f010136c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (PGNUM(pa) >= npages)
f010136f:	c1 e8 0c             	shr    $0xc,%eax
f0101372:	3b 05 e4 5d 1b f0    	cmp    0xf01b5de4,%eax
f0101378:	73 42                	jae    f01013bc <pgdir_walk+0xda>
	return (void *)(pa + KERNBASE);
f010137a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010137d:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
			memset(content, 0, PGSIZE);
f0101383:	83 ec 04             	sub    $0x4,%esp
f0101386:	68 00 10 00 00       	push   $0x1000
f010138b:	6a 00                	push   $0x0
f010138d:	56                   	push   %esi
f010138e:	e8 84 31 00 00       	call   f0104517 <memset>
			new_pt->pp_ref++;
f0101393:	66 ff 47 04          	incw   0x4(%edi)
	if ((uint32_t)kva < KERNBASE)
f0101397:	83 c4 10             	add    $0x10,%esp
f010139a:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01013a0:	76 2e                	jbe    f01013d0 <pgdir_walk+0xee>
			pgdir[PDX(va)] = PADDR(content) | 0xF; // Set all permissions.
f01013a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01013a5:	83 c8 0f             	or     $0xf,%eax
f01013a8:	89 03                	mov    %eax,(%ebx)
			return (pte_t*) content + PTX(va);
f01013aa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01013ad:	c1 e8 0a             	shr    $0xa,%eax
f01013b0:	25 fc 0f 00 00       	and    $0xffc,%eax
f01013b5:	01 f0                	add    %esi,%eax
f01013b7:	e9 66 ff ff ff       	jmp    f0101322 <pgdir_walk+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013bc:	ff 75 e4             	pushl  -0x1c(%ebp)
f01013bf:	68 f0 50 10 f0       	push   $0xf01050f0
f01013c4:	6a 56                	push   $0x56
f01013c6:	68 4d 5a 10 f0       	push   $0xf0105a4d
f01013cb:	e8 78 ed ff ff       	call   f0100148 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013d0:	56                   	push   %esi
f01013d1:	68 a4 53 10 f0       	push   $0xf01053a4
f01013d6:	68 7b 01 00 00       	push   $0x17b
f01013db:	68 41 5a 10 f0       	push   $0xf0105a41
f01013e0:	e8 63 ed ff ff       	call   f0100148 <_panic>
	return NULL;
f01013e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01013ea:	e9 33 ff ff ff       	jmp    f0101322 <pgdir_walk+0x40>
f01013ef:	b8 00 00 00 00       	mov    $0x0,%eax
f01013f4:	e9 29 ff ff ff       	jmp    f0101322 <pgdir_walk+0x40>

f01013f9 <boot_map_region>:
{
f01013f9:	55                   	push   %ebp
f01013fa:	89 e5                	mov    %esp,%ebp
f01013fc:	57                   	push   %edi
f01013fd:	56                   	push   %esi
f01013fe:	53                   	push   %ebx
f01013ff:	83 ec 1c             	sub    $0x1c,%esp
f0101402:	89 c7                	mov    %eax,%edi
f0101404:	89 d6                	mov    %edx,%esi
f0101406:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f0101409:	bb 00 00 00 00       	mov    $0x0,%ebx
		*page_entry = (pa + size0) | perm | PTE_P;
f010140e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101411:	83 c8 01             	or     $0x1,%eax
f0101414:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f0101417:	eb 22                	jmp    f010143b <boot_map_region+0x42>
		pte_t *page_entry = pgdir_walk(pgdir, (void*) va + size0, 1);
f0101419:	83 ec 04             	sub    $0x4,%esp
f010141c:	6a 01                	push   $0x1
f010141e:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f0101421:	50                   	push   %eax
f0101422:	57                   	push   %edi
f0101423:	e8 ba fe ff ff       	call   f01012e2 <pgdir_walk>
		*page_entry = (pa + size0) | perm | PTE_P;
f0101428:	89 da                	mov    %ebx,%edx
f010142a:	03 55 08             	add    0x8(%ebp),%edx
f010142d:	0b 55 e0             	or     -0x20(%ebp),%edx
f0101430:	89 10                	mov    %edx,(%eax)
	for (i = 0, size0 = 0; size0 < size; i++, size0 = i * PGSIZE) {
f0101432:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101438:	83 c4 10             	add    $0x10,%esp
f010143b:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010143e:	72 d9                	jb     f0101419 <boot_map_region+0x20>
}
f0101440:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101443:	5b                   	pop    %ebx
f0101444:	5e                   	pop    %esi
f0101445:	5f                   	pop    %edi
f0101446:	5d                   	pop    %ebp
f0101447:	c3                   	ret    

f0101448 <page_lookup>:
{
f0101448:	55                   	push   %ebp
f0101449:	89 e5                	mov    %esp,%ebp
f010144b:	53                   	push   %ebx
f010144c:	83 ec 08             	sub    $0x8,%esp
f010144f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *page_entry = pgdir_walk(pgdir, (void*) va, 0);
f0101452:	6a 00                	push   $0x0
f0101454:	ff 75 0c             	pushl  0xc(%ebp)
f0101457:	ff 75 08             	pushl  0x8(%ebp)
f010145a:	e8 83 fe ff ff       	call   f01012e2 <pgdir_walk>
	if (!page_entry || !*page_entry)
f010145f:	83 c4 10             	add    $0x10,%esp
f0101462:	85 c0                	test   %eax,%eax
f0101464:	74 3a                	je     f01014a0 <page_lookup+0x58>
f0101466:	83 38 00             	cmpl   $0x0,(%eax)
f0101469:	74 3c                	je     f01014a7 <page_lookup+0x5f>
	if (pte_store)
f010146b:	85 db                	test   %ebx,%ebx
f010146d:	74 02                	je     f0101471 <page_lookup+0x29>
		*pte_store = page_entry;
f010146f:	89 03                	mov    %eax,(%ebx)
f0101471:	8b 00                	mov    (%eax),%eax
f0101473:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101476:	39 05 e4 5d 1b f0    	cmp    %eax,0xf01b5de4
f010147c:	76 0e                	jbe    f010148c <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f010147e:	8b 15 ec 5d 1b f0    	mov    0xf01b5dec,%edx
f0101484:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0101487:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010148a:	c9                   	leave  
f010148b:	c3                   	ret    
		panic("pa2page called with invalid pa");
f010148c:	83 ec 04             	sub    $0x4,%esp
f010148f:	68 c8 53 10 f0       	push   $0xf01053c8
f0101494:	6a 4f                	push   $0x4f
f0101496:	68 4d 5a 10 f0       	push   $0xf0105a4d
f010149b:	e8 a8 ec ff ff       	call   f0100148 <_panic>
		return NULL;
f01014a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01014a5:	eb e0                	jmp    f0101487 <page_lookup+0x3f>
f01014a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01014ac:	eb d9                	jmp    f0101487 <page_lookup+0x3f>

f01014ae <page_remove>:
{
f01014ae:	55                   	push   %ebp
f01014af:	89 e5                	mov    %esp,%ebp
f01014b1:	53                   	push   %ebx
f01014b2:	83 ec 18             	sub    $0x18,%esp
f01014b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo *pp = page_lookup(pgdir, va, &pte_store);
f01014b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01014bb:	50                   	push   %eax
f01014bc:	53                   	push   %ebx
f01014bd:	ff 75 08             	pushl  0x8(%ebp)
f01014c0:	e8 83 ff ff ff       	call   f0101448 <page_lookup>
	if (!pp)
f01014c5:	83 c4 10             	add    $0x10,%esp
f01014c8:	85 c0                	test   %eax,%eax
f01014ca:	74 17                	je     f01014e3 <page_remove+0x35>
	pp->pp_ref--;
f01014cc:	66 ff 48 04          	decw   0x4(%eax)
	*pte_store = 0;
f01014d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01014d3:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01014d9:	0f 01 3b             	invlpg (%ebx)
	if (!pp->pp_ref)
f01014dc:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01014e1:	74 05                	je     f01014e8 <page_remove+0x3a>
}
f01014e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01014e6:	c9                   	leave  
f01014e7:	c3                   	ret    
		page_free(pp);
f01014e8:	83 ec 0c             	sub    $0xc,%esp
f01014eb:	50                   	push   %eax
f01014ec:	e8 79 fd ff ff       	call   f010126a <page_free>
f01014f1:	83 c4 10             	add    $0x10,%esp
f01014f4:	eb ed                	jmp    f01014e3 <page_remove+0x35>

f01014f6 <page_insert>:
{
f01014f6:	55                   	push   %ebp
f01014f7:	89 e5                	mov    %esp,%ebp
f01014f9:	57                   	push   %edi
f01014fa:	56                   	push   %esi
f01014fb:	53                   	push   %ebx
f01014fc:	83 ec 10             	sub    $0x10,%esp
f01014ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101502:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *page_entry = pgdir_walk(pgdir, (void*) va, 1);
f0101505:	6a 01                	push   $0x1
f0101507:	57                   	push   %edi
f0101508:	ff 75 08             	pushl  0x8(%ebp)
f010150b:	e8 d2 fd ff ff       	call   f01012e2 <pgdir_walk>
	if (!page_entry)
f0101510:	83 c4 10             	add    $0x10,%esp
f0101513:	85 c0                	test   %eax,%eax
f0101515:	74 3f                	je     f0101556 <page_insert+0x60>
f0101517:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f0101519:	66 ff 43 04          	incw   0x4(%ebx)
	if (*page_entry) 
f010151d:	83 38 00             	cmpl   $0x0,(%eax)
f0101520:	75 23                	jne    f0101545 <page_insert+0x4f>
	return (pp - pages) << PGSHIFT;
f0101522:	2b 1d ec 5d 1b f0    	sub    0xf01b5dec,%ebx
f0101528:	c1 fb 03             	sar    $0x3,%ebx
f010152b:	c1 e3 0c             	shl    $0xc,%ebx
	*page_entry = page2pa(pp) | perm | PTE_P;
f010152e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101531:	83 c8 01             	or     $0x1,%eax
f0101534:	09 c3                	or     %eax,%ebx
f0101536:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0101538:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010153d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101540:	5b                   	pop    %ebx
f0101541:	5e                   	pop    %esi
f0101542:	5f                   	pop    %edi
f0101543:	5d                   	pop    %ebp
f0101544:	c3                   	ret    
		page_remove(pgdir, va);
f0101545:	83 ec 08             	sub    $0x8,%esp
f0101548:	57                   	push   %edi
f0101549:	ff 75 08             	pushl  0x8(%ebp)
f010154c:	e8 5d ff ff ff       	call   f01014ae <page_remove>
f0101551:	83 c4 10             	add    $0x10,%esp
f0101554:	eb cc                	jmp    f0101522 <page_insert+0x2c>
		return -E_NO_MEM;  // Has no page table AND cannot be allocated
f0101556:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010155b:	eb e0                	jmp    f010153d <page_insert+0x47>

f010155d <mem_init>:
{
f010155d:	55                   	push   %ebp
f010155e:	89 e5                	mov    %esp,%ebp
f0101560:	57                   	push   %edi
f0101561:	56                   	push   %esi
f0101562:	53                   	push   %ebx
f0101563:	83 ec 2c             	sub    $0x2c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0101566:	b8 15 00 00 00       	mov    $0x15,%eax
f010156b:	e8 9c f8 ff ff       	call   f0100e0c <nvram_read>
f0101570:	89 c6                	mov    %eax,%esi
	extmem = nvram_read(NVRAM_EXTLO);
f0101572:	b8 17 00 00 00       	mov    $0x17,%eax
f0101577:	e8 90 f8 ff ff       	call   f0100e0c <nvram_read>
f010157c:	89 c3                	mov    %eax,%ebx
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010157e:	b8 34 00 00 00       	mov    $0x34,%eax
f0101583:	e8 84 f8 ff ff       	call   f0100e0c <nvram_read>
	if (ext16mem)
f0101588:	c1 e0 06             	shl    $0x6,%eax
f010158b:	75 10                	jne    f010159d <mem_init+0x40>
	else if (extmem)
f010158d:	85 db                	test   %ebx,%ebx
f010158f:	0f 84 e6 00 00 00    	je     f010167b <mem_init+0x11e>
		totalmem = 1 * 1024 + extmem;
f0101595:	8d 83 00 04 00 00    	lea    0x400(%ebx),%eax
f010159b:	eb 05                	jmp    f01015a2 <mem_init+0x45>
		totalmem = 16 * 1024 + ext16mem;
f010159d:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f01015a2:	89 c2                	mov    %eax,%edx
f01015a4:	c1 ea 02             	shr    $0x2,%edx
f01015a7:	89 15 e4 5d 1b f0    	mov    %edx,0xf01b5de4
	npages_basemem = basemem / (PGSIZE / 1024);
f01015ad:	89 f2                	mov    %esi,%edx
f01015af:	c1 ea 02             	shr    $0x2,%edx
f01015b2:	89 15 20 51 1b f0    	mov    %edx,0xf01b5120
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01015b8:	89 c2                	mov    %eax,%edx
f01015ba:	29 f2                	sub    %esi,%edx
f01015bc:	52                   	push   %edx
f01015bd:	56                   	push   %esi
f01015be:	50                   	push   %eax
f01015bf:	68 e8 53 10 f0       	push   $0xf01053e8
f01015c4:	e8 2a 20 00 00       	call   f01035f3 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01015c9:	b8 00 10 00 00       	mov    $0x1000,%eax
f01015ce:	e8 f3 f7 ff ff       	call   f0100dc6 <boot_alloc>
f01015d3:	a3 e8 5d 1b f0       	mov    %eax,0xf01b5de8
	memset(kern_pgdir, 0, PGSIZE);
f01015d8:	83 c4 0c             	add    $0xc,%esp
f01015db:	68 00 10 00 00       	push   $0x1000
f01015e0:	6a 00                	push   $0x0
f01015e2:	50                   	push   %eax
f01015e3:	e8 2f 2f 00 00       	call   f0104517 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01015e8:	a1 e8 5d 1b f0       	mov    0xf01b5de8,%eax
	if ((uint32_t)kva < KERNBASE)
f01015ed:	83 c4 10             	add    $0x10,%esp
f01015f0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01015f5:	0f 86 87 00 00 00    	jbe    f0101682 <mem_init+0x125>
	return (physaddr_t)kva - KERNBASE;
f01015fb:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101601:	83 ca 05             	or     $0x5,%edx
f0101604:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo)*npages);
f010160a:	a1 e4 5d 1b f0       	mov    0xf01b5de4,%eax
f010160f:	c1 e0 03             	shl    $0x3,%eax
f0101612:	e8 af f7 ff ff       	call   f0100dc6 <boot_alloc>
f0101617:	a3 ec 5d 1b f0       	mov    %eax,0xf01b5dec
	memset(pages, 0, sizeof(struct PageInfo)*npages);
f010161c:	83 ec 04             	sub    $0x4,%esp
f010161f:	8b 3d e4 5d 1b f0    	mov    0xf01b5de4,%edi
f0101625:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f010162c:	52                   	push   %edx
f010162d:	6a 00                	push   $0x0
f010162f:	50                   	push   %eax
f0101630:	e8 e2 2e 00 00       	call   f0104517 <memset>
	envs = (struct Env *) boot_alloc(sizeof(struct Env)*NENV);
f0101635:	b8 00 80 01 00       	mov    $0x18000,%eax
f010163a:	e8 87 f7 ff ff       	call   f0100dc6 <boot_alloc>
f010163f:	a3 28 51 1b f0       	mov    %eax,0xf01b5128
	memset(envs, 0, sizeof(struct Env)*NENV);
f0101644:	83 c4 0c             	add    $0xc,%esp
f0101647:	68 00 80 01 00       	push   $0x18000
f010164c:	6a 00                	push   $0x0
f010164e:	50                   	push   %eax
f010164f:	e8 c3 2e 00 00       	call   f0104517 <memset>
	page_init();
f0101654:	e8 00 fb ff ff       	call   f0101159 <page_init>
	check_page_free_list(1);
f0101659:	b8 01 00 00 00       	mov    $0x1,%eax
f010165e:	e8 2f f8 ff ff       	call   f0100e92 <check_page_free_list>
	if (!pages)
f0101663:	83 c4 10             	add    $0x10,%esp
f0101666:	83 3d ec 5d 1b f0 00 	cmpl   $0x0,0xf01b5dec
f010166d:	74 28                	je     f0101697 <mem_init+0x13a>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010166f:	a1 1c 51 1b f0       	mov    0xf01b511c,%eax
f0101674:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101679:	eb 36                	jmp    f01016b1 <mem_init+0x154>
		totalmem = basemem;
f010167b:	89 f0                	mov    %esi,%eax
f010167d:	e9 20 ff ff ff       	jmp    f01015a2 <mem_init+0x45>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101682:	50                   	push   %eax
f0101683:	68 a4 53 10 f0       	push   $0xf01053a4
f0101688:	68 92 00 00 00       	push   $0x92
f010168d:	68 41 5a 10 f0       	push   $0xf0105a41
f0101692:	e8 b1 ea ff ff       	call   f0100148 <_panic>
		panic("'pages' is a null pointer!");
f0101697:	83 ec 04             	sub    $0x4,%esp
f010169a:	68 22 5b 10 f0       	push   $0xf0105b22
f010169f:	68 79 02 00 00       	push   $0x279
f01016a4:	68 41 5a 10 f0       	push   $0xf0105a41
f01016a9:	e8 9a ea ff ff       	call   f0100148 <_panic>
		++nfree;
f01016ae:	43                   	inc    %ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01016af:	8b 00                	mov    (%eax),%eax
f01016b1:	85 c0                	test   %eax,%eax
f01016b3:	75 f9                	jne    f01016ae <mem_init+0x151>
	assert((pp0 = page_alloc(0)));
f01016b5:	83 ec 0c             	sub    $0xc,%esp
f01016b8:	6a 00                	push   $0x0
f01016ba:	e8 39 fb ff ff       	call   f01011f8 <page_alloc>
f01016bf:	89 c7                	mov    %eax,%edi
f01016c1:	83 c4 10             	add    $0x10,%esp
f01016c4:	85 c0                	test   %eax,%eax
f01016c6:	0f 84 10 02 00 00    	je     f01018dc <mem_init+0x37f>
	assert((pp1 = page_alloc(0)));
f01016cc:	83 ec 0c             	sub    $0xc,%esp
f01016cf:	6a 00                	push   $0x0
f01016d1:	e8 22 fb ff ff       	call   f01011f8 <page_alloc>
f01016d6:	89 c6                	mov    %eax,%esi
f01016d8:	83 c4 10             	add    $0x10,%esp
f01016db:	85 c0                	test   %eax,%eax
f01016dd:	0f 84 12 02 00 00    	je     f01018f5 <mem_init+0x398>
	assert((pp2 = page_alloc(0)));
f01016e3:	83 ec 0c             	sub    $0xc,%esp
f01016e6:	6a 00                	push   $0x0
f01016e8:	e8 0b fb ff ff       	call   f01011f8 <page_alloc>
f01016ed:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01016f0:	83 c4 10             	add    $0x10,%esp
f01016f3:	85 c0                	test   %eax,%eax
f01016f5:	0f 84 13 02 00 00    	je     f010190e <mem_init+0x3b1>
	assert(pp1 && pp1 != pp0);
f01016fb:	39 f7                	cmp    %esi,%edi
f01016fd:	0f 84 24 02 00 00    	je     f0101927 <mem_init+0x3ca>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101703:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101706:	39 c6                	cmp    %eax,%esi
f0101708:	0f 84 32 02 00 00    	je     f0101940 <mem_init+0x3e3>
f010170e:	39 c7                	cmp    %eax,%edi
f0101710:	0f 84 2a 02 00 00    	je     f0101940 <mem_init+0x3e3>
	return (pp - pages) << PGSHIFT;
f0101716:	8b 0d ec 5d 1b f0    	mov    0xf01b5dec,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010171c:	8b 15 e4 5d 1b f0    	mov    0xf01b5de4,%edx
f0101722:	c1 e2 0c             	shl    $0xc,%edx
f0101725:	89 f8                	mov    %edi,%eax
f0101727:	29 c8                	sub    %ecx,%eax
f0101729:	c1 f8 03             	sar    $0x3,%eax
f010172c:	c1 e0 0c             	shl    $0xc,%eax
f010172f:	39 d0                	cmp    %edx,%eax
f0101731:	0f 83 22 02 00 00    	jae    f0101959 <mem_init+0x3fc>
f0101737:	89 f0                	mov    %esi,%eax
f0101739:	29 c8                	sub    %ecx,%eax
f010173b:	c1 f8 03             	sar    $0x3,%eax
f010173e:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101741:	39 c2                	cmp    %eax,%edx
f0101743:	0f 86 29 02 00 00    	jbe    f0101972 <mem_init+0x415>
f0101749:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010174c:	29 c8                	sub    %ecx,%eax
f010174e:	c1 f8 03             	sar    $0x3,%eax
f0101751:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101754:	39 c2                	cmp    %eax,%edx
f0101756:	0f 86 2f 02 00 00    	jbe    f010198b <mem_init+0x42e>
	fl = page_free_list;
f010175c:	a1 1c 51 1b f0       	mov    0xf01b511c,%eax
f0101761:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101764:	c7 05 1c 51 1b f0 00 	movl   $0x0,0xf01b511c
f010176b:	00 00 00 
	assert(!page_alloc(0));
f010176e:	83 ec 0c             	sub    $0xc,%esp
f0101771:	6a 00                	push   $0x0
f0101773:	e8 80 fa ff ff       	call   f01011f8 <page_alloc>
f0101778:	83 c4 10             	add    $0x10,%esp
f010177b:	85 c0                	test   %eax,%eax
f010177d:	0f 85 21 02 00 00    	jne    f01019a4 <mem_init+0x447>
	page_free(pp0);
f0101783:	83 ec 0c             	sub    $0xc,%esp
f0101786:	57                   	push   %edi
f0101787:	e8 de fa ff ff       	call   f010126a <page_free>
	page_free(pp1);
f010178c:	89 34 24             	mov    %esi,(%esp)
f010178f:	e8 d6 fa ff ff       	call   f010126a <page_free>
	page_free(pp2);
f0101794:	83 c4 04             	add    $0x4,%esp
f0101797:	ff 75 d4             	pushl  -0x2c(%ebp)
f010179a:	e8 cb fa ff ff       	call   f010126a <page_free>
	assert((pp0 = page_alloc(0)));
f010179f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017a6:	e8 4d fa ff ff       	call   f01011f8 <page_alloc>
f01017ab:	89 c6                	mov    %eax,%esi
f01017ad:	83 c4 10             	add    $0x10,%esp
f01017b0:	85 c0                	test   %eax,%eax
f01017b2:	0f 84 05 02 00 00    	je     f01019bd <mem_init+0x460>
	assert((pp1 = page_alloc(0)));
f01017b8:	83 ec 0c             	sub    $0xc,%esp
f01017bb:	6a 00                	push   $0x0
f01017bd:	e8 36 fa ff ff       	call   f01011f8 <page_alloc>
f01017c2:	89 c7                	mov    %eax,%edi
f01017c4:	83 c4 10             	add    $0x10,%esp
f01017c7:	85 c0                	test   %eax,%eax
f01017c9:	0f 84 07 02 00 00    	je     f01019d6 <mem_init+0x479>
	assert((pp2 = page_alloc(0)));
f01017cf:	83 ec 0c             	sub    $0xc,%esp
f01017d2:	6a 00                	push   $0x0
f01017d4:	e8 1f fa ff ff       	call   f01011f8 <page_alloc>
f01017d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017dc:	83 c4 10             	add    $0x10,%esp
f01017df:	85 c0                	test   %eax,%eax
f01017e1:	0f 84 08 02 00 00    	je     f01019ef <mem_init+0x492>
	assert(pp1 && pp1 != pp0);
f01017e7:	39 fe                	cmp    %edi,%esi
f01017e9:	0f 84 19 02 00 00    	je     f0101a08 <mem_init+0x4ab>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017f2:	39 c7                	cmp    %eax,%edi
f01017f4:	0f 84 27 02 00 00    	je     f0101a21 <mem_init+0x4c4>
f01017fa:	39 c6                	cmp    %eax,%esi
f01017fc:	0f 84 1f 02 00 00    	je     f0101a21 <mem_init+0x4c4>
	assert(!page_alloc(0));
f0101802:	83 ec 0c             	sub    $0xc,%esp
f0101805:	6a 00                	push   $0x0
f0101807:	e8 ec f9 ff ff       	call   f01011f8 <page_alloc>
f010180c:	83 c4 10             	add    $0x10,%esp
f010180f:	85 c0                	test   %eax,%eax
f0101811:	0f 85 23 02 00 00    	jne    f0101a3a <mem_init+0x4dd>
f0101817:	89 f0                	mov    %esi,%eax
f0101819:	2b 05 ec 5d 1b f0    	sub    0xf01b5dec,%eax
f010181f:	c1 f8 03             	sar    $0x3,%eax
f0101822:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101825:	89 c2                	mov    %eax,%edx
f0101827:	c1 ea 0c             	shr    $0xc,%edx
f010182a:	3b 15 e4 5d 1b f0    	cmp    0xf01b5de4,%edx
f0101830:	0f 83 1d 02 00 00    	jae    f0101a53 <mem_init+0x4f6>
	memset(page2kva(pp0), 1, PGSIZE);
f0101836:	83 ec 04             	sub    $0x4,%esp
f0101839:	68 00 10 00 00       	push   $0x1000
f010183e:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101840:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101845:	50                   	push   %eax
f0101846:	e8 cc 2c 00 00       	call   f0104517 <memset>
	page_free(pp0);
f010184b:	89 34 24             	mov    %esi,(%esp)
f010184e:	e8 17 fa ff ff       	call   f010126a <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101853:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010185a:	e8 99 f9 ff ff       	call   f01011f8 <page_alloc>
f010185f:	83 c4 10             	add    $0x10,%esp
f0101862:	85 c0                	test   %eax,%eax
f0101864:	0f 84 fb 01 00 00    	je     f0101a65 <mem_init+0x508>
	assert(pp && pp0 == pp);
f010186a:	39 c6                	cmp    %eax,%esi
f010186c:	0f 85 0c 02 00 00    	jne    f0101a7e <mem_init+0x521>
	return (pp - pages) << PGSHIFT;
f0101872:	89 f2                	mov    %esi,%edx
f0101874:	2b 15 ec 5d 1b f0    	sub    0xf01b5dec,%edx
f010187a:	c1 fa 03             	sar    $0x3,%edx
f010187d:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101880:	89 d0                	mov    %edx,%eax
f0101882:	c1 e8 0c             	shr    $0xc,%eax
f0101885:	3b 05 e4 5d 1b f0    	cmp    0xf01b5de4,%eax
f010188b:	0f 83 06 02 00 00    	jae    f0101a97 <mem_init+0x53a>
	return (void *)(pa + KERNBASE);
f0101891:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101897:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f010189d:	80 38 00             	cmpb   $0x0,(%eax)
f01018a0:	0f 85 03 02 00 00    	jne    f0101aa9 <mem_init+0x54c>
f01018a6:	40                   	inc    %eax
	for (i = 0; i < PGSIZE; i++)
f01018a7:	39 d0                	cmp    %edx,%eax
f01018a9:	75 f2                	jne    f010189d <mem_init+0x340>
	page_free_list = fl;
f01018ab:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01018ae:	a3 1c 51 1b f0       	mov    %eax,0xf01b511c
	page_free(pp0);
f01018b3:	83 ec 0c             	sub    $0xc,%esp
f01018b6:	56                   	push   %esi
f01018b7:	e8 ae f9 ff ff       	call   f010126a <page_free>
	page_free(pp1);
f01018bc:	89 3c 24             	mov    %edi,(%esp)
f01018bf:	e8 a6 f9 ff ff       	call   f010126a <page_free>
	page_free(pp2);
f01018c4:	83 c4 04             	add    $0x4,%esp
f01018c7:	ff 75 d4             	pushl  -0x2c(%ebp)
f01018ca:	e8 9b f9 ff ff       	call   f010126a <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01018cf:	a1 1c 51 1b f0       	mov    0xf01b511c,%eax
f01018d4:	83 c4 10             	add    $0x10,%esp
f01018d7:	e9 e9 01 00 00       	jmp    f0101ac5 <mem_init+0x568>
	assert((pp0 = page_alloc(0)));
f01018dc:	68 3d 5b 10 f0       	push   $0xf0105b3d
f01018e1:	68 67 5a 10 f0       	push   $0xf0105a67
f01018e6:	68 81 02 00 00       	push   $0x281
f01018eb:	68 41 5a 10 f0       	push   $0xf0105a41
f01018f0:	e8 53 e8 ff ff       	call   f0100148 <_panic>
	assert((pp1 = page_alloc(0)));
f01018f5:	68 53 5b 10 f0       	push   $0xf0105b53
f01018fa:	68 67 5a 10 f0       	push   $0xf0105a67
f01018ff:	68 82 02 00 00       	push   $0x282
f0101904:	68 41 5a 10 f0       	push   $0xf0105a41
f0101909:	e8 3a e8 ff ff       	call   f0100148 <_panic>
	assert((pp2 = page_alloc(0)));
f010190e:	68 69 5b 10 f0       	push   $0xf0105b69
f0101913:	68 67 5a 10 f0       	push   $0xf0105a67
f0101918:	68 83 02 00 00       	push   $0x283
f010191d:	68 41 5a 10 f0       	push   $0xf0105a41
f0101922:	e8 21 e8 ff ff       	call   f0100148 <_panic>
	assert(pp1 && pp1 != pp0);
f0101927:	68 7f 5b 10 f0       	push   $0xf0105b7f
f010192c:	68 67 5a 10 f0       	push   $0xf0105a67
f0101931:	68 86 02 00 00       	push   $0x286
f0101936:	68 41 5a 10 f0       	push   $0xf0105a41
f010193b:	e8 08 e8 ff ff       	call   f0100148 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101940:	68 24 54 10 f0       	push   $0xf0105424
f0101945:	68 67 5a 10 f0       	push   $0xf0105a67
f010194a:	68 87 02 00 00       	push   $0x287
f010194f:	68 41 5a 10 f0       	push   $0xf0105a41
f0101954:	e8 ef e7 ff ff       	call   f0100148 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101959:	68 91 5b 10 f0       	push   $0xf0105b91
f010195e:	68 67 5a 10 f0       	push   $0xf0105a67
f0101963:	68 88 02 00 00       	push   $0x288
f0101968:	68 41 5a 10 f0       	push   $0xf0105a41
f010196d:	e8 d6 e7 ff ff       	call   f0100148 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101972:	68 ae 5b 10 f0       	push   $0xf0105bae
f0101977:	68 67 5a 10 f0       	push   $0xf0105a67
f010197c:	68 89 02 00 00       	push   $0x289
f0101981:	68 41 5a 10 f0       	push   $0xf0105a41
f0101986:	e8 bd e7 ff ff       	call   f0100148 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010198b:	68 cb 5b 10 f0       	push   $0xf0105bcb
f0101990:	68 67 5a 10 f0       	push   $0xf0105a67
f0101995:	68 8a 02 00 00       	push   $0x28a
f010199a:	68 41 5a 10 f0       	push   $0xf0105a41
f010199f:	e8 a4 e7 ff ff       	call   f0100148 <_panic>
	assert(!page_alloc(0));
f01019a4:	68 e8 5b 10 f0       	push   $0xf0105be8
f01019a9:	68 67 5a 10 f0       	push   $0xf0105a67
f01019ae:	68 91 02 00 00       	push   $0x291
f01019b3:	68 41 5a 10 f0       	push   $0xf0105a41
f01019b8:	e8 8b e7 ff ff       	call   f0100148 <_panic>
	assert((pp0 = page_alloc(0)));
f01019bd:	68 3d 5b 10 f0       	push   $0xf0105b3d
f01019c2:	68 67 5a 10 f0       	push   $0xf0105a67
f01019c7:	68 98 02 00 00       	push   $0x298
f01019cc:	68 41 5a 10 f0       	push   $0xf0105a41
f01019d1:	e8 72 e7 ff ff       	call   f0100148 <_panic>
	assert((pp1 = page_alloc(0)));
f01019d6:	68 53 5b 10 f0       	push   $0xf0105b53
f01019db:	68 67 5a 10 f0       	push   $0xf0105a67
f01019e0:	68 99 02 00 00       	push   $0x299
f01019e5:	68 41 5a 10 f0       	push   $0xf0105a41
f01019ea:	e8 59 e7 ff ff       	call   f0100148 <_panic>
	assert((pp2 = page_alloc(0)));
f01019ef:	68 69 5b 10 f0       	push   $0xf0105b69
f01019f4:	68 67 5a 10 f0       	push   $0xf0105a67
f01019f9:	68 9a 02 00 00       	push   $0x29a
f01019fe:	68 41 5a 10 f0       	push   $0xf0105a41
f0101a03:	e8 40 e7 ff ff       	call   f0100148 <_panic>
	assert(pp1 && pp1 != pp0);
f0101a08:	68 7f 5b 10 f0       	push   $0xf0105b7f
f0101a0d:	68 67 5a 10 f0       	push   $0xf0105a67
f0101a12:	68 9c 02 00 00       	push   $0x29c
f0101a17:	68 41 5a 10 f0       	push   $0xf0105a41
f0101a1c:	e8 27 e7 ff ff       	call   f0100148 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a21:	68 24 54 10 f0       	push   $0xf0105424
f0101a26:	68 67 5a 10 f0       	push   $0xf0105a67
f0101a2b:	68 9d 02 00 00       	push   $0x29d
f0101a30:	68 41 5a 10 f0       	push   $0xf0105a41
f0101a35:	e8 0e e7 ff ff       	call   f0100148 <_panic>
	assert(!page_alloc(0));
f0101a3a:	68 e8 5b 10 f0       	push   $0xf0105be8
f0101a3f:	68 67 5a 10 f0       	push   $0xf0105a67
f0101a44:	68 9e 02 00 00       	push   $0x29e
f0101a49:	68 41 5a 10 f0       	push   $0xf0105a41
f0101a4e:	e8 f5 e6 ff ff       	call   f0100148 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a53:	50                   	push   %eax
f0101a54:	68 f0 50 10 f0       	push   $0xf01050f0
f0101a59:	6a 56                	push   $0x56
f0101a5b:	68 4d 5a 10 f0       	push   $0xf0105a4d
f0101a60:	e8 e3 e6 ff ff       	call   f0100148 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101a65:	68 f7 5b 10 f0       	push   $0xf0105bf7
f0101a6a:	68 67 5a 10 f0       	push   $0xf0105a67
f0101a6f:	68 a3 02 00 00       	push   $0x2a3
f0101a74:	68 41 5a 10 f0       	push   $0xf0105a41
f0101a79:	e8 ca e6 ff ff       	call   f0100148 <_panic>
	assert(pp && pp0 == pp);
f0101a7e:	68 15 5c 10 f0       	push   $0xf0105c15
f0101a83:	68 67 5a 10 f0       	push   $0xf0105a67
f0101a88:	68 a4 02 00 00       	push   $0x2a4
f0101a8d:	68 41 5a 10 f0       	push   $0xf0105a41
f0101a92:	e8 b1 e6 ff ff       	call   f0100148 <_panic>
f0101a97:	52                   	push   %edx
f0101a98:	68 f0 50 10 f0       	push   $0xf01050f0
f0101a9d:	6a 56                	push   $0x56
f0101a9f:	68 4d 5a 10 f0       	push   $0xf0105a4d
f0101aa4:	e8 9f e6 ff ff       	call   f0100148 <_panic>
		assert(c[i] == 0);
f0101aa9:	68 25 5c 10 f0       	push   $0xf0105c25
f0101aae:	68 67 5a 10 f0       	push   $0xf0105a67
f0101ab3:	68 a7 02 00 00       	push   $0x2a7
f0101ab8:	68 41 5a 10 f0       	push   $0xf0105a41
f0101abd:	e8 86 e6 ff ff       	call   f0100148 <_panic>
		--nfree;
f0101ac2:	4b                   	dec    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101ac3:	8b 00                	mov    (%eax),%eax
f0101ac5:	85 c0                	test   %eax,%eax
f0101ac7:	75 f9                	jne    f0101ac2 <mem_init+0x565>
	assert(nfree == 0);
f0101ac9:	85 db                	test   %ebx,%ebx
f0101acb:	0f 85 b1 07 00 00    	jne    f0102282 <mem_init+0xd25>
	cprintf("check_page_alloc() succeeded!\n");
f0101ad1:	83 ec 0c             	sub    $0xc,%esp
f0101ad4:	68 44 54 10 f0       	push   $0xf0105444
f0101ad9:	e8 15 1b 00 00       	call   f01035f3 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101ade:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ae5:	e8 0e f7 ff ff       	call   f01011f8 <page_alloc>
f0101aea:	89 c7                	mov    %eax,%edi
f0101aec:	83 c4 10             	add    $0x10,%esp
f0101aef:	85 c0                	test   %eax,%eax
f0101af1:	0f 84 a4 07 00 00    	je     f010229b <mem_init+0xd3e>
	assert((pp1 = page_alloc(0)));
f0101af7:	83 ec 0c             	sub    $0xc,%esp
f0101afa:	6a 00                	push   $0x0
f0101afc:	e8 f7 f6 ff ff       	call   f01011f8 <page_alloc>
f0101b01:	89 c3                	mov    %eax,%ebx
f0101b03:	83 c4 10             	add    $0x10,%esp
f0101b06:	85 c0                	test   %eax,%eax
f0101b08:	0f 84 a6 07 00 00    	je     f01022b4 <mem_init+0xd57>
	assert((pp2 = page_alloc(0)));
f0101b0e:	83 ec 0c             	sub    $0xc,%esp
f0101b11:	6a 00                	push   $0x0
f0101b13:	e8 e0 f6 ff ff       	call   f01011f8 <page_alloc>
f0101b18:	89 c6                	mov    %eax,%esi
f0101b1a:	83 c4 10             	add    $0x10,%esp
f0101b1d:	85 c0                	test   %eax,%eax
f0101b1f:	0f 84 a8 07 00 00    	je     f01022cd <mem_init+0xd70>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b25:	39 df                	cmp    %ebx,%edi
f0101b27:	0f 84 b9 07 00 00    	je     f01022e6 <mem_init+0xd89>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b2d:	39 c3                	cmp    %eax,%ebx
f0101b2f:	0f 84 ca 07 00 00    	je     f01022ff <mem_init+0xda2>
f0101b35:	39 c7                	cmp    %eax,%edi
f0101b37:	0f 84 c2 07 00 00    	je     f01022ff <mem_init+0xda2>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101b3d:	a1 1c 51 1b f0       	mov    0xf01b511c,%eax
f0101b42:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f0101b45:	c7 05 1c 51 1b f0 00 	movl   $0x0,0xf01b511c
f0101b4c:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101b4f:	83 ec 0c             	sub    $0xc,%esp
f0101b52:	6a 00                	push   $0x0
f0101b54:	e8 9f f6 ff ff       	call   f01011f8 <page_alloc>
f0101b59:	83 c4 10             	add    $0x10,%esp
f0101b5c:	85 c0                	test   %eax,%eax
f0101b5e:	0f 85 b4 07 00 00    	jne    f0102318 <mem_init+0xdbb>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101b64:	83 ec 04             	sub    $0x4,%esp
f0101b67:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101b6a:	50                   	push   %eax
f0101b6b:	6a 00                	push   $0x0
f0101b6d:	ff 35 e8 5d 1b f0    	pushl  0xf01b5de8
f0101b73:	e8 d0 f8 ff ff       	call   f0101448 <page_lookup>
f0101b78:	83 c4 10             	add    $0x10,%esp
f0101b7b:	85 c0                	test   %eax,%eax
f0101b7d:	0f 85 ae 07 00 00    	jne    f0102331 <mem_init+0xdd4>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101b83:	6a 02                	push   $0x2
f0101b85:	6a 00                	push   $0x0
f0101b87:	53                   	push   %ebx
f0101b88:	ff 35 e8 5d 1b f0    	pushl  0xf01b5de8
f0101b8e:	e8 63 f9 ff ff       	call   f01014f6 <page_insert>
f0101b93:	83 c4 10             	add    $0x10,%esp
f0101b96:	85 c0                	test   %eax,%eax
f0101b98:	0f 89 ac 07 00 00    	jns    f010234a <mem_init+0xded>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101b9e:	83 ec 0c             	sub    $0xc,%esp
f0101ba1:	57                   	push   %edi
f0101ba2:	e8 c3 f6 ff ff       	call   f010126a <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101ba7:	6a 02                	push   $0x2
f0101ba9:	6a 00                	push   $0x0
f0101bab:	53                   	push   %ebx
f0101bac:	ff 35 e8 5d 1b f0    	pushl  0xf01b5de8
f0101bb2:	e8 3f f9 ff ff       	call   f01014f6 <page_insert>
f0101bb7:	83 c4 20             	add    $0x20,%esp
f0101bba:	85 c0                	test   %eax,%eax
f0101bbc:	0f 85 a1 07 00 00    	jne    f0102363 <mem_init+0xe06>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101bc2:	a1 e8 5d 1b f0       	mov    0xf01b5de8,%eax
f0101bc7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	return (pp - pages) << PGSHIFT;
f0101bca:	8b 0d ec 5d 1b f0    	mov    0xf01b5dec,%ecx
f0101bd0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101bd3:	8b 00                	mov    (%eax),%eax
f0101bd5:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101bd8:	89 c2                	mov    %eax,%edx
f0101bda:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101be0:	89 f8                	mov    %edi,%eax
f0101be2:	29 c8                	sub    %ecx,%eax
f0101be4:	c1 f8 03             	sar    $0x3,%eax
f0101be7:	c1 e0 0c             	shl    $0xc,%eax
f0101bea:	39 c2                	cmp    %eax,%edx
f0101bec:	0f 85 8a 07 00 00    	jne    f010237c <mem_init+0xe1f>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101bf2:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bf7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bfa:	e8 34 f2 ff ff       	call   f0100e33 <check_va2pa>
f0101bff:	89 da                	mov    %ebx,%edx
f0101c01:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101c04:	c1 fa 03             	sar    $0x3,%edx
f0101c07:	c1 e2 0c             	shl    $0xc,%edx
f0101c0a:	39 d0                	cmp    %edx,%eax
f0101c0c:	0f 85 83 07 00 00    	jne    f0102395 <mem_init+0xe38>
	assert(pp1->pp_ref == 1);
f0101c12:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101c17:	0f 85 91 07 00 00    	jne    f01023ae <mem_init+0xe51>
	assert(pp0->pp_ref == 1);
f0101c1d:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101c22:	0f 85 9f 07 00 00    	jne    f01023c7 <mem_init+0xe6a>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c28:	6a 02                	push   $0x2
f0101c2a:	68 00 10 00 00       	push   $0x1000
f0101c2f:	56                   	push   %esi
f0101c30:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c33:	e8 be f8 ff ff       	call   f01014f6 <page_insert>
f0101c38:	83 c4 10             	add    $0x10,%esp
f0101c3b:	85 c0                	test   %eax,%eax
f0101c3d:	0f 85 9d 07 00 00    	jne    f01023e0 <mem_init+0xe83>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c43:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c48:	a1 e8 5d 1b f0       	mov    0xf01b5de8,%eax
f0101c4d:	e8 e1 f1 ff ff       	call   f0100e33 <check_va2pa>
f0101c52:	89 f2                	mov    %esi,%edx
f0101c54:	2b 15 ec 5d 1b f0    	sub    0xf01b5dec,%edx
f0101c5a:	c1 fa 03             	sar    $0x3,%edx
f0101c5d:	c1 e2 0c             	shl    $0xc,%edx
f0101c60:	39 d0                	cmp    %edx,%eax
f0101c62:	0f 85 91 07 00 00    	jne    f01023f9 <mem_init+0xe9c>
	assert(pp2->pp_ref == 1);
f0101c68:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c6d:	0f 85 9f 07 00 00    	jne    f0102412 <mem_init+0xeb5>

	// should be no free memory
	assert(!page_alloc(0));
f0101c73:	83 ec 0c             	sub    $0xc,%esp
f0101c76:	6a 00                	push   $0x0
f0101c78:	e8 7b f5 ff ff       	call   f01011f8 <page_alloc>
f0101c7d:	83 c4 10             	add    $0x10,%esp
f0101c80:	85 c0                	test   %eax,%eax
f0101c82:	0f 85 a3 07 00 00    	jne    f010242b <mem_init+0xece>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c88:	6a 02                	push   $0x2
f0101c8a:	68 00 10 00 00       	push   $0x1000
f0101c8f:	56                   	push   %esi
f0101c90:	ff 35 e8 5d 1b f0    	pushl  0xf01b5de8
f0101c96:	e8 5b f8 ff ff       	call   f01014f6 <page_insert>
f0101c9b:	83 c4 10             	add    $0x10,%esp
f0101c9e:	85 c0                	test   %eax,%eax
f0101ca0:	0f 85 9e 07 00 00    	jne    f0102444 <mem_init+0xee7>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ca6:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cab:	a1 e8 5d 1b f0       	mov    0xf01b5de8,%eax
f0101cb0:	e8 7e f1 ff ff       	call   f0100e33 <check_va2pa>
f0101cb5:	89 f2                	mov    %esi,%edx
f0101cb7:	2b 15 ec 5d 1b f0    	sub    0xf01b5dec,%edx
f0101cbd:	c1 fa 03             	sar    $0x3,%edx
f0101cc0:	c1 e2 0c             	shl    $0xc,%edx
f0101cc3:	39 d0                	cmp    %edx,%eax
f0101cc5:	0f 85 92 07 00 00    	jne    f010245d <mem_init+0xf00>
	assert(pp2->pp_ref == 1);
f0101ccb:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101cd0:	0f 85 a0 07 00 00    	jne    f0102476 <mem_init+0xf19>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101cd6:	83 ec 0c             	sub    $0xc,%esp
f0101cd9:	6a 00                	push   $0x0
f0101cdb:	e8 18 f5 ff ff       	call   f01011f8 <page_alloc>
f0101ce0:	83 c4 10             	add    $0x10,%esp
f0101ce3:	85 c0                	test   %eax,%eax
f0101ce5:	0f 85 a4 07 00 00    	jne    f010248f <mem_init+0xf32>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101ceb:	8b 15 e8 5d 1b f0    	mov    0xf01b5de8,%edx
f0101cf1:	8b 02                	mov    (%edx),%eax
f0101cf3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101cf8:	89 c1                	mov    %eax,%ecx
f0101cfa:	c1 e9 0c             	shr    $0xc,%ecx
f0101cfd:	3b 0d e4 5d 1b f0    	cmp    0xf01b5de4,%ecx
f0101d03:	0f 83 9f 07 00 00    	jae    f01024a8 <mem_init+0xf4b>
	return (void *)(pa + KERNBASE);
f0101d09:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101d0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101d11:	83 ec 04             	sub    $0x4,%esp
f0101d14:	6a 00                	push   $0x0
f0101d16:	68 00 10 00 00       	push   $0x1000
f0101d1b:	52                   	push   %edx
f0101d1c:	e8 c1 f5 ff ff       	call   f01012e2 <pgdir_walk>
f0101d21:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101d24:	8d 51 04             	lea    0x4(%ecx),%edx
f0101d27:	83 c4 10             	add    $0x10,%esp
f0101d2a:	39 d0                	cmp    %edx,%eax
f0101d2c:	0f 85 8b 07 00 00    	jne    f01024bd <mem_init+0xf60>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101d32:	6a 06                	push   $0x6
f0101d34:	68 00 10 00 00       	push   $0x1000
f0101d39:	56                   	push   %esi
f0101d3a:	ff 35 e8 5d 1b f0    	pushl  0xf01b5de8
f0101d40:	e8 b1 f7 ff ff       	call   f01014f6 <page_insert>
f0101d45:	83 c4 10             	add    $0x10,%esp
f0101d48:	85 c0                	test   %eax,%eax
f0101d4a:	0f 85 86 07 00 00    	jne    f01024d6 <mem_init+0xf79>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d50:	a1 e8 5d 1b f0       	mov    0xf01b5de8,%eax
f0101d55:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101d58:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d5d:	e8 d1 f0 ff ff       	call   f0100e33 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101d62:	89 f2                	mov    %esi,%edx
f0101d64:	2b 15 ec 5d 1b f0    	sub    0xf01b5dec,%edx
f0101d6a:	c1 fa 03             	sar    $0x3,%edx
f0101d6d:	c1 e2 0c             	shl    $0xc,%edx
f0101d70:	39 d0                	cmp    %edx,%eax
f0101d72:	0f 85 77 07 00 00    	jne    f01024ef <mem_init+0xf92>
	assert(pp2->pp_ref == 1);
f0101d78:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d7d:	0f 85 85 07 00 00    	jne    f0102508 <mem_init+0xfab>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101d83:	83 ec 04             	sub    $0x4,%esp
f0101d86:	6a 00                	push   $0x0
f0101d88:	68 00 10 00 00       	push   $0x1000
f0101d8d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101d90:	e8 4d f5 ff ff       	call   f01012e2 <pgdir_walk>
f0101d95:	83 c4 10             	add    $0x10,%esp
f0101d98:	f6 00 04             	testb  $0x4,(%eax)
f0101d9b:	0f 84 80 07 00 00    	je     f0102521 <mem_init+0xfc4>
	assert(kern_pgdir[0] & PTE_U);
f0101da1:	a1 e8 5d 1b f0       	mov    0xf01b5de8,%eax
f0101da6:	f6 00 04             	testb  $0x4,(%eax)
f0101da9:	0f 84 8b 07 00 00    	je     f010253a <mem_init+0xfdd>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101daf:	6a 02                	push   $0x2
f0101db1:	68 00 10 00 00       	push   $0x1000
f0101db6:	56                   	push   %esi
f0101db7:	50                   	push   %eax
f0101db8:	e8 39 f7 ff ff       	call   f01014f6 <page_insert>
f0101dbd:	83 c4 10             	add    $0x10,%esp
f0101dc0:	85 c0                	test   %eax,%eax
f0101dc2:	0f 85 8b 07 00 00    	jne    f0102553 <mem_init+0xff6>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101dc8:	83 ec 04             	sub    $0x4,%esp
f0101dcb:	6a 00                	push   $0x0
f0101dcd:	68 00 10 00 00       	push   $0x1000
f0101dd2:	ff 35 e8 5d 1b f0    	pushl  0xf01b5de8
f0101dd8:	e8 05 f5 ff ff       	call   f01012e2 <pgdir_walk>
f0101ddd:	83 c4 10             	add    $0x10,%esp
f0101de0:	f6 00 02             	testb  $0x2,(%eax)
f0101de3:	0f 84 83 07 00 00    	je     f010256c <mem_init+0x100f>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101de9:	83 ec 04             	sub    $0x4,%esp
f0101dec:	6a 00                	push   $0x0
f0101dee:	68 00 10 00 00       	push   $0x1000
f0101df3:	ff 35 e8 5d 1b f0    	pushl  0xf01b5de8
f0101df9:	e8 e4 f4 ff ff       	call   f01012e2 <pgdir_walk>
f0101dfe:	83 c4 10             	add    $0x10,%esp
f0101e01:	f6 00 04             	testb  $0x4,(%eax)
f0101e04:	0f 85 7b 07 00 00    	jne    f0102585 <mem_init+0x1028>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101e0a:	6a 02                	push   $0x2
f0101e0c:	68 00 00 40 00       	push   $0x400000
f0101e11:	57                   	push   %edi
f0101e12:	ff 35 e8 5d 1b f0    	pushl  0xf01b5de8
f0101e18:	e8 d9 f6 ff ff       	call   f01014f6 <page_insert>
f0101e1d:	83 c4 10             	add    $0x10,%esp
f0101e20:	85 c0                	test   %eax,%eax
f0101e22:	0f 89 76 07 00 00    	jns    f010259e <mem_init+0x1041>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101e28:	6a 02                	push   $0x2
f0101e2a:	68 00 10 00 00       	push   $0x1000
f0101e2f:	53                   	push   %ebx
f0101e30:	ff 35 e8 5d 1b f0    	pushl  0xf01b5de8
f0101e36:	e8 bb f6 ff ff       	call   f01014f6 <page_insert>
f0101e3b:	83 c4 10             	add    $0x10,%esp
f0101e3e:	85 c0                	test   %eax,%eax
f0101e40:	0f 85 71 07 00 00    	jne    f01025b7 <mem_init+0x105a>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e46:	83 ec 04             	sub    $0x4,%esp
f0101e49:	6a 00                	push   $0x0
f0101e4b:	68 00 10 00 00       	push   $0x1000
f0101e50:	ff 35 e8 5d 1b f0    	pushl  0xf01b5de8
f0101e56:	e8 87 f4 ff ff       	call   f01012e2 <pgdir_walk>
f0101e5b:	83 c4 10             	add    $0x10,%esp
f0101e5e:	f6 00 04             	testb  $0x4,(%eax)
f0101e61:	0f 85 69 07 00 00    	jne    f01025d0 <mem_init+0x1073>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101e67:	a1 e8 5d 1b f0       	mov    0xf01b5de8,%eax
f0101e6c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101e6f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e74:	e8 ba ef ff ff       	call   f0100e33 <check_va2pa>
f0101e79:	89 c1                	mov    %eax,%ecx
f0101e7b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101e7e:	89 d8                	mov    %ebx,%eax
f0101e80:	2b 05 ec 5d 1b f0    	sub    0xf01b5dec,%eax
f0101e86:	c1 f8 03             	sar    $0x3,%eax
f0101e89:	c1 e0 0c             	shl    $0xc,%eax
f0101e8c:	39 c1                	cmp    %eax,%ecx
f0101e8e:	0f 85 55 07 00 00    	jne    f01025e9 <mem_init+0x108c>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e94:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e99:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e9c:	e8 92 ef ff ff       	call   f0100e33 <check_va2pa>
f0101ea1:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101ea4:	0f 85 58 07 00 00    	jne    f0102602 <mem_init+0x10a5>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101eaa:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101eaf:	0f 85 66 07 00 00    	jne    f010261b <mem_init+0x10be>
	assert(pp2->pp_ref == 0);
f0101eb5:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101eba:	0f 85 74 07 00 00    	jne    f0102634 <mem_init+0x10d7>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101ec0:	83 ec 0c             	sub    $0xc,%esp
f0101ec3:	6a 00                	push   $0x0
f0101ec5:	e8 2e f3 ff ff       	call   f01011f8 <page_alloc>
f0101eca:	83 c4 10             	add    $0x10,%esp
f0101ecd:	85 c0                	test   %eax,%eax
f0101ecf:	0f 84 78 07 00 00    	je     f010264d <mem_init+0x10f0>
f0101ed5:	39 c6                	cmp    %eax,%esi
f0101ed7:	0f 85 70 07 00 00    	jne    f010264d <mem_init+0x10f0>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101edd:	83 ec 08             	sub    $0x8,%esp
f0101ee0:	6a 00                	push   $0x0
f0101ee2:	ff 35 e8 5d 1b f0    	pushl  0xf01b5de8
f0101ee8:	e8 c1 f5 ff ff       	call   f01014ae <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101eed:	a1 e8 5d 1b f0       	mov    0xf01b5de8,%eax
f0101ef2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101ef5:	ba 00 00 00 00       	mov    $0x0,%edx
f0101efa:	e8 34 ef ff ff       	call   f0100e33 <check_va2pa>
f0101eff:	83 c4 10             	add    $0x10,%esp
f0101f02:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f05:	0f 85 5b 07 00 00    	jne    f0102666 <mem_init+0x1109>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f0b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f10:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f13:	e8 1b ef ff ff       	call   f0100e33 <check_va2pa>
f0101f18:	89 da                	mov    %ebx,%edx
f0101f1a:	2b 15 ec 5d 1b f0    	sub    0xf01b5dec,%edx
f0101f20:	c1 fa 03             	sar    $0x3,%edx
f0101f23:	c1 e2 0c             	shl    $0xc,%edx
f0101f26:	39 d0                	cmp    %edx,%eax
f0101f28:	0f 85 51 07 00 00    	jne    f010267f <mem_init+0x1122>
	assert(pp1->pp_ref == 1);
f0101f2e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f33:	0f 85 5f 07 00 00    	jne    f0102698 <mem_init+0x113b>
	assert(pp2->pp_ref == 0);
f0101f39:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f3e:	0f 85 6d 07 00 00    	jne    f01026b1 <mem_init+0x1154>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101f44:	6a 00                	push   $0x0
f0101f46:	68 00 10 00 00       	push   $0x1000
f0101f4b:	53                   	push   %ebx
f0101f4c:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f4f:	e8 a2 f5 ff ff       	call   f01014f6 <page_insert>
f0101f54:	83 c4 10             	add    $0x10,%esp
f0101f57:	85 c0                	test   %eax,%eax
f0101f59:	0f 85 6b 07 00 00    	jne    f01026ca <mem_init+0x116d>
	assert(pp1->pp_ref);
f0101f5f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101f64:	0f 84 79 07 00 00    	je     f01026e3 <mem_init+0x1186>
	assert(pp1->pp_link == NULL);
f0101f6a:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101f6d:	0f 85 89 07 00 00    	jne    f01026fc <mem_init+0x119f>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101f73:	83 ec 08             	sub    $0x8,%esp
f0101f76:	68 00 10 00 00       	push   $0x1000
f0101f7b:	ff 35 e8 5d 1b f0    	pushl  0xf01b5de8
f0101f81:	e8 28 f5 ff ff       	call   f01014ae <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f86:	a1 e8 5d 1b f0       	mov    0xf01b5de8,%eax
f0101f8b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f8e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f93:	e8 9b ee ff ff       	call   f0100e33 <check_va2pa>
f0101f98:	83 c4 10             	add    $0x10,%esp
f0101f9b:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f9e:	0f 85 71 07 00 00    	jne    f0102715 <mem_init+0x11b8>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101fa4:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fa9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fac:	e8 82 ee ff ff       	call   f0100e33 <check_va2pa>
f0101fb1:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fb4:	0f 85 74 07 00 00    	jne    f010272e <mem_init+0x11d1>
	assert(pp1->pp_ref == 0);
f0101fba:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101fbf:	0f 85 82 07 00 00    	jne    f0102747 <mem_init+0x11ea>
	assert(pp2->pp_ref == 0);
f0101fc5:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101fca:	0f 85 90 07 00 00    	jne    f0102760 <mem_init+0x1203>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101fd0:	83 ec 0c             	sub    $0xc,%esp
f0101fd3:	6a 00                	push   $0x0
f0101fd5:	e8 1e f2 ff ff       	call   f01011f8 <page_alloc>
f0101fda:	83 c4 10             	add    $0x10,%esp
f0101fdd:	85 c0                	test   %eax,%eax
f0101fdf:	0f 84 94 07 00 00    	je     f0102779 <mem_init+0x121c>
f0101fe5:	39 c3                	cmp    %eax,%ebx
f0101fe7:	0f 85 8c 07 00 00    	jne    f0102779 <mem_init+0x121c>

	// should be no free memory
	assert(!page_alloc(0));
f0101fed:	83 ec 0c             	sub    $0xc,%esp
f0101ff0:	6a 00                	push   $0x0
f0101ff2:	e8 01 f2 ff ff       	call   f01011f8 <page_alloc>
f0101ff7:	83 c4 10             	add    $0x10,%esp
f0101ffa:	85 c0                	test   %eax,%eax
f0101ffc:	0f 85 90 07 00 00    	jne    f0102792 <mem_init+0x1235>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102002:	8b 0d e8 5d 1b f0    	mov    0xf01b5de8,%ecx
f0102008:	8b 11                	mov    (%ecx),%edx
f010200a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102010:	89 f8                	mov    %edi,%eax
f0102012:	2b 05 ec 5d 1b f0    	sub    0xf01b5dec,%eax
f0102018:	c1 f8 03             	sar    $0x3,%eax
f010201b:	c1 e0 0c             	shl    $0xc,%eax
f010201e:	39 c2                	cmp    %eax,%edx
f0102020:	0f 85 85 07 00 00    	jne    f01027ab <mem_init+0x124e>
	kern_pgdir[0] = 0;
f0102026:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010202c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102031:	0f 85 8d 07 00 00    	jne    f01027c4 <mem_init+0x1267>
	pp0->pp_ref = 0;
f0102037:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010203d:	83 ec 0c             	sub    $0xc,%esp
f0102040:	57                   	push   %edi
f0102041:	e8 24 f2 ff ff       	call   f010126a <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102046:	83 c4 0c             	add    $0xc,%esp
f0102049:	6a 01                	push   $0x1
f010204b:	68 00 10 40 00       	push   $0x401000
f0102050:	ff 35 e8 5d 1b f0    	pushl  0xf01b5de8
f0102056:	e8 87 f2 ff ff       	call   f01012e2 <pgdir_walk>
f010205b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010205e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102061:	a1 e8 5d 1b f0       	mov    0xf01b5de8,%eax
f0102066:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102069:	8b 50 04             	mov    0x4(%eax),%edx
f010206c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0102072:	a1 e4 5d 1b f0       	mov    0xf01b5de4,%eax
f0102077:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010207a:	89 d1                	mov    %edx,%ecx
f010207c:	c1 e9 0c             	shr    $0xc,%ecx
f010207f:	83 c4 10             	add    $0x10,%esp
f0102082:	39 c1                	cmp    %eax,%ecx
f0102084:	0f 83 53 07 00 00    	jae    f01027dd <mem_init+0x1280>
	assert(ptep == ptep1 + PTX(va));
f010208a:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102090:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0102093:	0f 85 59 07 00 00    	jne    f01027f2 <mem_init+0x1295>
	kern_pgdir[PDX(va)] = 0;
f0102099:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010209c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f01020a3:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
	return (pp - pages) << PGSHIFT;
f01020a9:	89 f8                	mov    %edi,%eax
f01020ab:	2b 05 ec 5d 1b f0    	sub    0xf01b5dec,%eax
f01020b1:	c1 f8 03             	sar    $0x3,%eax
f01020b4:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01020b7:	89 c2                	mov    %eax,%edx
f01020b9:	c1 ea 0c             	shr    $0xc,%edx
f01020bc:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f01020bf:	0f 86 46 07 00 00    	jbe    f010280b <mem_init+0x12ae>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01020c5:	83 ec 04             	sub    $0x4,%esp
f01020c8:	68 00 10 00 00       	push   $0x1000
f01020cd:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01020d2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01020d7:	50                   	push   %eax
f01020d8:	e8 3a 24 00 00       	call   f0104517 <memset>
	page_free(pp0);
f01020dd:	89 3c 24             	mov    %edi,(%esp)
f01020e0:	e8 85 f1 ff ff       	call   f010126a <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01020e5:	83 c4 0c             	add    $0xc,%esp
f01020e8:	6a 01                	push   $0x1
f01020ea:	6a 00                	push   $0x0
f01020ec:	ff 35 e8 5d 1b f0    	pushl  0xf01b5de8
f01020f2:	e8 eb f1 ff ff       	call   f01012e2 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f01020f7:	89 fa                	mov    %edi,%edx
f01020f9:	2b 15 ec 5d 1b f0    	sub    0xf01b5dec,%edx
f01020ff:	c1 fa 03             	sar    $0x3,%edx
f0102102:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102105:	89 d0                	mov    %edx,%eax
f0102107:	c1 e8 0c             	shr    $0xc,%eax
f010210a:	83 c4 10             	add    $0x10,%esp
f010210d:	3b 05 e4 5d 1b f0    	cmp    0xf01b5de4,%eax
f0102113:	0f 83 04 07 00 00    	jae    f010281d <mem_init+0x12c0>
	return (void *)(pa + KERNBASE);
f0102119:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010211f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102122:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102128:	f6 00 01             	testb  $0x1,(%eax)
f010212b:	0f 85 fe 06 00 00    	jne    f010282f <mem_init+0x12d2>
f0102131:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0102134:	39 d0                	cmp    %edx,%eax
f0102136:	75 f0                	jne    f0102128 <mem_init+0xbcb>
	kern_pgdir[0] = 0;
f0102138:	a1 e8 5d 1b f0       	mov    0xf01b5de8,%eax
f010213d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102143:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102149:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010214c:	a3 1c 51 1b f0       	mov    %eax,0xf01b511c

	// free the pages we took
	page_free(pp0);
f0102151:	83 ec 0c             	sub    $0xc,%esp
f0102154:	57                   	push   %edi
f0102155:	e8 10 f1 ff ff       	call   f010126a <page_free>
	page_free(pp1);
f010215a:	89 1c 24             	mov    %ebx,(%esp)
f010215d:	e8 08 f1 ff ff       	call   f010126a <page_free>
	page_free(pp2);
f0102162:	89 34 24             	mov    %esi,(%esp)
f0102165:	e8 00 f1 ff ff       	call   f010126a <page_free>

	cprintf("check_page() succeeded!\n");
f010216a:	c7 04 24 06 5d 10 f0 	movl   $0xf0105d06,(%esp)
f0102171:	e8 7d 14 00 00       	call   f01035f3 <cprintf>
	pginfo_sz = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102176:	a1 e4 5d 1b f0       	mov    0xf01b5de4,%eax
f010217b:	8d 0c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ecx
f0102182:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_region(kern_pgdir, UPAGES, pginfo_sz, PADDR(pages), PTE_U | PTE_P);
f0102188:	a1 ec 5d 1b f0       	mov    0xf01b5dec,%eax
	if ((uint32_t)kva < KERNBASE)
f010218d:	83 c4 10             	add    $0x10,%esp
f0102190:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102195:	0f 86 ad 06 00 00    	jbe    f0102848 <mem_init+0x12eb>
f010219b:	83 ec 08             	sub    $0x8,%esp
f010219e:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01021a0:	05 00 00 00 10       	add    $0x10000000,%eax
f01021a5:	50                   	push   %eax
f01021a6:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01021ab:	a1 e8 5d 1b f0       	mov    0xf01b5de8,%eax
f01021b0:	e8 44 f2 ff ff       	call   f01013f9 <boot_map_region>
	env_sz = ROUNDUP(npages*sizeof(struct Env), PGSIZE);
f01021b5:	a1 e4 5d 1b f0       	mov    0xf01b5de4,%eax
f01021ba:	8d 0c 00             	lea    (%eax,%eax,1),%ecx
f01021bd:	01 c1                	add    %eax,%ecx
f01021bf:	c1 e1 05             	shl    $0x5,%ecx
f01021c2:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f01021c8:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_region(kern_pgdir, UENVS, env_sz, PADDR(envs), PTE_U | PTE_P);
f01021ce:	a1 28 51 1b f0       	mov    0xf01b5128,%eax
	if ((uint32_t)kva < KERNBASE)
f01021d3:	83 c4 10             	add    $0x10,%esp
f01021d6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021db:	0f 86 7c 06 00 00    	jbe    f010285d <mem_init+0x1300>
f01021e1:	83 ec 08             	sub    $0x8,%esp
f01021e4:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01021e6:	05 00 00 00 10       	add    $0x10000000,%eax
f01021eb:	50                   	push   %eax
f01021ec:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01021f1:	a1 e8 5d 1b f0       	mov    0xf01b5de8,%eax
f01021f6:	e8 fe f1 ff ff       	call   f01013f9 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01021fb:	83 c4 10             	add    $0x10,%esp
f01021fe:	b8 00 20 11 f0       	mov    $0xf0112000,%eax
f0102203:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102208:	0f 86 64 06 00 00    	jbe    f0102872 <mem_init+0x1315>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, 
f010220e:	83 ec 08             	sub    $0x8,%esp
f0102211:	6a 03                	push   $0x3
f0102213:	68 00 20 11 00       	push   $0x112000
f0102218:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010221d:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102222:	a1 e8 5d 1b f0       	mov    0xf01b5de8,%eax
f0102227:	e8 cd f1 ff ff       	call   f01013f9 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 1 << 28, // 2^32 - 0xf0000000
f010222c:	83 c4 08             	add    $0x8,%esp
f010222f:	6a 03                	push   $0x3
f0102231:	6a 00                	push   $0x0
f0102233:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102238:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010223d:	a1 e8 5d 1b f0       	mov    0xf01b5de8,%eax
f0102242:	e8 b2 f1 ff ff       	call   f01013f9 <boot_map_region>
	pgdir = kern_pgdir;
f0102247:	8b 1d e8 5d 1b f0    	mov    0xf01b5de8,%ebx
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010224d:	a1 e4 5d 1b f0       	mov    0xf01b5de4,%eax
f0102252:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102255:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010225c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102261:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102264:	a1 ec 5d 1b f0       	mov    0xf01b5dec,%eax
f0102269:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010226c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	return (physaddr_t)kva - KERNBASE;
f010226f:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f0102275:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i += PGSIZE) 
f0102278:	be 00 00 00 00       	mov    $0x0,%esi
f010227d:	e9 22 06 00 00       	jmp    f01028a4 <mem_init+0x1347>
	assert(nfree == 0);
f0102282:	68 2f 5c 10 f0       	push   $0xf0105c2f
f0102287:	68 67 5a 10 f0       	push   $0xf0105a67
f010228c:	68 b4 02 00 00       	push   $0x2b4
f0102291:	68 41 5a 10 f0       	push   $0xf0105a41
f0102296:	e8 ad de ff ff       	call   f0100148 <_panic>
	assert((pp0 = page_alloc(0)));
f010229b:	68 3d 5b 10 f0       	push   $0xf0105b3d
f01022a0:	68 67 5a 10 f0       	push   $0xf0105a67
f01022a5:	68 13 03 00 00       	push   $0x313
f01022aa:	68 41 5a 10 f0       	push   $0xf0105a41
f01022af:	e8 94 de ff ff       	call   f0100148 <_panic>
	assert((pp1 = page_alloc(0)));
f01022b4:	68 53 5b 10 f0       	push   $0xf0105b53
f01022b9:	68 67 5a 10 f0       	push   $0xf0105a67
f01022be:	68 14 03 00 00       	push   $0x314
f01022c3:	68 41 5a 10 f0       	push   $0xf0105a41
f01022c8:	e8 7b de ff ff       	call   f0100148 <_panic>
	assert((pp2 = page_alloc(0)));
f01022cd:	68 69 5b 10 f0       	push   $0xf0105b69
f01022d2:	68 67 5a 10 f0       	push   $0xf0105a67
f01022d7:	68 15 03 00 00       	push   $0x315
f01022dc:	68 41 5a 10 f0       	push   $0xf0105a41
f01022e1:	e8 62 de ff ff       	call   f0100148 <_panic>
	assert(pp1 && pp1 != pp0);
f01022e6:	68 7f 5b 10 f0       	push   $0xf0105b7f
f01022eb:	68 67 5a 10 f0       	push   $0xf0105a67
f01022f0:	68 18 03 00 00       	push   $0x318
f01022f5:	68 41 5a 10 f0       	push   $0xf0105a41
f01022fa:	e8 49 de ff ff       	call   f0100148 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01022ff:	68 24 54 10 f0       	push   $0xf0105424
f0102304:	68 67 5a 10 f0       	push   $0xf0105a67
f0102309:	68 19 03 00 00       	push   $0x319
f010230e:	68 41 5a 10 f0       	push   $0xf0105a41
f0102313:	e8 30 de ff ff       	call   f0100148 <_panic>
	assert(!page_alloc(0));
f0102318:	68 e8 5b 10 f0       	push   $0xf0105be8
f010231d:	68 67 5a 10 f0       	push   $0xf0105a67
f0102322:	68 20 03 00 00       	push   $0x320
f0102327:	68 41 5a 10 f0       	push   $0xf0105a41
f010232c:	e8 17 de ff ff       	call   f0100148 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102331:	68 64 54 10 f0       	push   $0xf0105464
f0102336:	68 67 5a 10 f0       	push   $0xf0105a67
f010233b:	68 23 03 00 00       	push   $0x323
f0102340:	68 41 5a 10 f0       	push   $0xf0105a41
f0102345:	e8 fe dd ff ff       	call   f0100148 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010234a:	68 9c 54 10 f0       	push   $0xf010549c
f010234f:	68 67 5a 10 f0       	push   $0xf0105a67
f0102354:	68 26 03 00 00       	push   $0x326
f0102359:	68 41 5a 10 f0       	push   $0xf0105a41
f010235e:	e8 e5 dd ff ff       	call   f0100148 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102363:	68 cc 54 10 f0       	push   $0xf01054cc
f0102368:	68 67 5a 10 f0       	push   $0xf0105a67
f010236d:	68 2a 03 00 00       	push   $0x32a
f0102372:	68 41 5a 10 f0       	push   $0xf0105a41
f0102377:	e8 cc dd ff ff       	call   f0100148 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010237c:	68 fc 54 10 f0       	push   $0xf01054fc
f0102381:	68 67 5a 10 f0       	push   $0xf0105a67
f0102386:	68 2b 03 00 00       	push   $0x32b
f010238b:	68 41 5a 10 f0       	push   $0xf0105a41
f0102390:	e8 b3 dd ff ff       	call   f0100148 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102395:	68 24 55 10 f0       	push   $0xf0105524
f010239a:	68 67 5a 10 f0       	push   $0xf0105a67
f010239f:	68 2c 03 00 00       	push   $0x32c
f01023a4:	68 41 5a 10 f0       	push   $0xf0105a41
f01023a9:	e8 9a dd ff ff       	call   f0100148 <_panic>
	assert(pp1->pp_ref == 1);
f01023ae:	68 3a 5c 10 f0       	push   $0xf0105c3a
f01023b3:	68 67 5a 10 f0       	push   $0xf0105a67
f01023b8:	68 2d 03 00 00       	push   $0x32d
f01023bd:	68 41 5a 10 f0       	push   $0xf0105a41
f01023c2:	e8 81 dd ff ff       	call   f0100148 <_panic>
	assert(pp0->pp_ref == 1);
f01023c7:	68 4b 5c 10 f0       	push   $0xf0105c4b
f01023cc:	68 67 5a 10 f0       	push   $0xf0105a67
f01023d1:	68 2e 03 00 00       	push   $0x32e
f01023d6:	68 41 5a 10 f0       	push   $0xf0105a41
f01023db:	e8 68 dd ff ff       	call   f0100148 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01023e0:	68 54 55 10 f0       	push   $0xf0105554
f01023e5:	68 67 5a 10 f0       	push   $0xf0105a67
f01023ea:	68 31 03 00 00       	push   $0x331
f01023ef:	68 41 5a 10 f0       	push   $0xf0105a41
f01023f4:	e8 4f dd ff ff       	call   f0100148 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023f9:	68 90 55 10 f0       	push   $0xf0105590
f01023fe:	68 67 5a 10 f0       	push   $0xf0105a67
f0102403:	68 32 03 00 00       	push   $0x332
f0102408:	68 41 5a 10 f0       	push   $0xf0105a41
f010240d:	e8 36 dd ff ff       	call   f0100148 <_panic>
	assert(pp2->pp_ref == 1);
f0102412:	68 5c 5c 10 f0       	push   $0xf0105c5c
f0102417:	68 67 5a 10 f0       	push   $0xf0105a67
f010241c:	68 33 03 00 00       	push   $0x333
f0102421:	68 41 5a 10 f0       	push   $0xf0105a41
f0102426:	e8 1d dd ff ff       	call   f0100148 <_panic>
	assert(!page_alloc(0));
f010242b:	68 e8 5b 10 f0       	push   $0xf0105be8
f0102430:	68 67 5a 10 f0       	push   $0xf0105a67
f0102435:	68 36 03 00 00       	push   $0x336
f010243a:	68 41 5a 10 f0       	push   $0xf0105a41
f010243f:	e8 04 dd ff ff       	call   f0100148 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102444:	68 54 55 10 f0       	push   $0xf0105554
f0102449:	68 67 5a 10 f0       	push   $0xf0105a67
f010244e:	68 39 03 00 00       	push   $0x339
f0102453:	68 41 5a 10 f0       	push   $0xf0105a41
f0102458:	e8 eb dc ff ff       	call   f0100148 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010245d:	68 90 55 10 f0       	push   $0xf0105590
f0102462:	68 67 5a 10 f0       	push   $0xf0105a67
f0102467:	68 3a 03 00 00       	push   $0x33a
f010246c:	68 41 5a 10 f0       	push   $0xf0105a41
f0102471:	e8 d2 dc ff ff       	call   f0100148 <_panic>
	assert(pp2->pp_ref == 1);
f0102476:	68 5c 5c 10 f0       	push   $0xf0105c5c
f010247b:	68 67 5a 10 f0       	push   $0xf0105a67
f0102480:	68 3b 03 00 00       	push   $0x33b
f0102485:	68 41 5a 10 f0       	push   $0xf0105a41
f010248a:	e8 b9 dc ff ff       	call   f0100148 <_panic>
	assert(!page_alloc(0));
f010248f:	68 e8 5b 10 f0       	push   $0xf0105be8
f0102494:	68 67 5a 10 f0       	push   $0xf0105a67
f0102499:	68 3f 03 00 00       	push   $0x33f
f010249e:	68 41 5a 10 f0       	push   $0xf0105a41
f01024a3:	e8 a0 dc ff ff       	call   f0100148 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024a8:	50                   	push   %eax
f01024a9:	68 f0 50 10 f0       	push   $0xf01050f0
f01024ae:	68 42 03 00 00       	push   $0x342
f01024b3:	68 41 5a 10 f0       	push   $0xf0105a41
f01024b8:	e8 8b dc ff ff       	call   f0100148 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01024bd:	68 c0 55 10 f0       	push   $0xf01055c0
f01024c2:	68 67 5a 10 f0       	push   $0xf0105a67
f01024c7:	68 43 03 00 00       	push   $0x343
f01024cc:	68 41 5a 10 f0       	push   $0xf0105a41
f01024d1:	e8 72 dc ff ff       	call   f0100148 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01024d6:	68 00 56 10 f0       	push   $0xf0105600
f01024db:	68 67 5a 10 f0       	push   $0xf0105a67
f01024e0:	68 46 03 00 00       	push   $0x346
f01024e5:	68 41 5a 10 f0       	push   $0xf0105a41
f01024ea:	e8 59 dc ff ff       	call   f0100148 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024ef:	68 90 55 10 f0       	push   $0xf0105590
f01024f4:	68 67 5a 10 f0       	push   $0xf0105a67
f01024f9:	68 47 03 00 00       	push   $0x347
f01024fe:	68 41 5a 10 f0       	push   $0xf0105a41
f0102503:	e8 40 dc ff ff       	call   f0100148 <_panic>
	assert(pp2->pp_ref == 1);
f0102508:	68 5c 5c 10 f0       	push   $0xf0105c5c
f010250d:	68 67 5a 10 f0       	push   $0xf0105a67
f0102512:	68 48 03 00 00       	push   $0x348
f0102517:	68 41 5a 10 f0       	push   $0xf0105a41
f010251c:	e8 27 dc ff ff       	call   f0100148 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102521:	68 40 56 10 f0       	push   $0xf0105640
f0102526:	68 67 5a 10 f0       	push   $0xf0105a67
f010252b:	68 49 03 00 00       	push   $0x349
f0102530:	68 41 5a 10 f0       	push   $0xf0105a41
f0102535:	e8 0e dc ff ff       	call   f0100148 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010253a:	68 6d 5c 10 f0       	push   $0xf0105c6d
f010253f:	68 67 5a 10 f0       	push   $0xf0105a67
f0102544:	68 4a 03 00 00       	push   $0x34a
f0102549:	68 41 5a 10 f0       	push   $0xf0105a41
f010254e:	e8 f5 db ff ff       	call   f0100148 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102553:	68 54 55 10 f0       	push   $0xf0105554
f0102558:	68 67 5a 10 f0       	push   $0xf0105a67
f010255d:	68 4d 03 00 00       	push   $0x34d
f0102562:	68 41 5a 10 f0       	push   $0xf0105a41
f0102567:	e8 dc db ff ff       	call   f0100148 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010256c:	68 74 56 10 f0       	push   $0xf0105674
f0102571:	68 67 5a 10 f0       	push   $0xf0105a67
f0102576:	68 4e 03 00 00       	push   $0x34e
f010257b:	68 41 5a 10 f0       	push   $0xf0105a41
f0102580:	e8 c3 db ff ff       	call   f0100148 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102585:	68 a8 56 10 f0       	push   $0xf01056a8
f010258a:	68 67 5a 10 f0       	push   $0xf0105a67
f010258f:	68 4f 03 00 00       	push   $0x34f
f0102594:	68 41 5a 10 f0       	push   $0xf0105a41
f0102599:	e8 aa db ff ff       	call   f0100148 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010259e:	68 e0 56 10 f0       	push   $0xf01056e0
f01025a3:	68 67 5a 10 f0       	push   $0xf0105a67
f01025a8:	68 52 03 00 00       	push   $0x352
f01025ad:	68 41 5a 10 f0       	push   $0xf0105a41
f01025b2:	e8 91 db ff ff       	call   f0100148 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01025b7:	68 18 57 10 f0       	push   $0xf0105718
f01025bc:	68 67 5a 10 f0       	push   $0xf0105a67
f01025c1:	68 55 03 00 00       	push   $0x355
f01025c6:	68 41 5a 10 f0       	push   $0xf0105a41
f01025cb:	e8 78 db ff ff       	call   f0100148 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01025d0:	68 a8 56 10 f0       	push   $0xf01056a8
f01025d5:	68 67 5a 10 f0       	push   $0xf0105a67
f01025da:	68 56 03 00 00       	push   $0x356
f01025df:	68 41 5a 10 f0       	push   $0xf0105a41
f01025e4:	e8 5f db ff ff       	call   f0100148 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01025e9:	68 54 57 10 f0       	push   $0xf0105754
f01025ee:	68 67 5a 10 f0       	push   $0xf0105a67
f01025f3:	68 59 03 00 00       	push   $0x359
f01025f8:	68 41 5a 10 f0       	push   $0xf0105a41
f01025fd:	e8 46 db ff ff       	call   f0100148 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102602:	68 80 57 10 f0       	push   $0xf0105780
f0102607:	68 67 5a 10 f0       	push   $0xf0105a67
f010260c:	68 5a 03 00 00       	push   $0x35a
f0102611:	68 41 5a 10 f0       	push   $0xf0105a41
f0102616:	e8 2d db ff ff       	call   f0100148 <_panic>
	assert(pp1->pp_ref == 2);
f010261b:	68 83 5c 10 f0       	push   $0xf0105c83
f0102620:	68 67 5a 10 f0       	push   $0xf0105a67
f0102625:	68 5c 03 00 00       	push   $0x35c
f010262a:	68 41 5a 10 f0       	push   $0xf0105a41
f010262f:	e8 14 db ff ff       	call   f0100148 <_panic>
	assert(pp2->pp_ref == 0);
f0102634:	68 94 5c 10 f0       	push   $0xf0105c94
f0102639:	68 67 5a 10 f0       	push   $0xf0105a67
f010263e:	68 5d 03 00 00       	push   $0x35d
f0102643:	68 41 5a 10 f0       	push   $0xf0105a41
f0102648:	e8 fb da ff ff       	call   f0100148 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f010264d:	68 b0 57 10 f0       	push   $0xf01057b0
f0102652:	68 67 5a 10 f0       	push   $0xf0105a67
f0102657:	68 60 03 00 00       	push   $0x360
f010265c:	68 41 5a 10 f0       	push   $0xf0105a41
f0102661:	e8 e2 da ff ff       	call   f0100148 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102666:	68 d4 57 10 f0       	push   $0xf01057d4
f010266b:	68 67 5a 10 f0       	push   $0xf0105a67
f0102670:	68 64 03 00 00       	push   $0x364
f0102675:	68 41 5a 10 f0       	push   $0xf0105a41
f010267a:	e8 c9 da ff ff       	call   f0100148 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010267f:	68 80 57 10 f0       	push   $0xf0105780
f0102684:	68 67 5a 10 f0       	push   $0xf0105a67
f0102689:	68 65 03 00 00       	push   $0x365
f010268e:	68 41 5a 10 f0       	push   $0xf0105a41
f0102693:	e8 b0 da ff ff       	call   f0100148 <_panic>
	assert(pp1->pp_ref == 1);
f0102698:	68 3a 5c 10 f0       	push   $0xf0105c3a
f010269d:	68 67 5a 10 f0       	push   $0xf0105a67
f01026a2:	68 66 03 00 00       	push   $0x366
f01026a7:	68 41 5a 10 f0       	push   $0xf0105a41
f01026ac:	e8 97 da ff ff       	call   f0100148 <_panic>
	assert(pp2->pp_ref == 0);
f01026b1:	68 94 5c 10 f0       	push   $0xf0105c94
f01026b6:	68 67 5a 10 f0       	push   $0xf0105a67
f01026bb:	68 67 03 00 00       	push   $0x367
f01026c0:	68 41 5a 10 f0       	push   $0xf0105a41
f01026c5:	e8 7e da ff ff       	call   f0100148 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01026ca:	68 f8 57 10 f0       	push   $0xf01057f8
f01026cf:	68 67 5a 10 f0       	push   $0xf0105a67
f01026d4:	68 6a 03 00 00       	push   $0x36a
f01026d9:	68 41 5a 10 f0       	push   $0xf0105a41
f01026de:	e8 65 da ff ff       	call   f0100148 <_panic>
	assert(pp1->pp_ref);
f01026e3:	68 a5 5c 10 f0       	push   $0xf0105ca5
f01026e8:	68 67 5a 10 f0       	push   $0xf0105a67
f01026ed:	68 6b 03 00 00       	push   $0x36b
f01026f2:	68 41 5a 10 f0       	push   $0xf0105a41
f01026f7:	e8 4c da ff ff       	call   f0100148 <_panic>
	assert(pp1->pp_link == NULL);
f01026fc:	68 b1 5c 10 f0       	push   $0xf0105cb1
f0102701:	68 67 5a 10 f0       	push   $0xf0105a67
f0102706:	68 6c 03 00 00       	push   $0x36c
f010270b:	68 41 5a 10 f0       	push   $0xf0105a41
f0102710:	e8 33 da ff ff       	call   f0100148 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102715:	68 d4 57 10 f0       	push   $0xf01057d4
f010271a:	68 67 5a 10 f0       	push   $0xf0105a67
f010271f:	68 70 03 00 00       	push   $0x370
f0102724:	68 41 5a 10 f0       	push   $0xf0105a41
f0102729:	e8 1a da ff ff       	call   f0100148 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010272e:	68 30 58 10 f0       	push   $0xf0105830
f0102733:	68 67 5a 10 f0       	push   $0xf0105a67
f0102738:	68 71 03 00 00       	push   $0x371
f010273d:	68 41 5a 10 f0       	push   $0xf0105a41
f0102742:	e8 01 da ff ff       	call   f0100148 <_panic>
	assert(pp1->pp_ref == 0);
f0102747:	68 c6 5c 10 f0       	push   $0xf0105cc6
f010274c:	68 67 5a 10 f0       	push   $0xf0105a67
f0102751:	68 72 03 00 00       	push   $0x372
f0102756:	68 41 5a 10 f0       	push   $0xf0105a41
f010275b:	e8 e8 d9 ff ff       	call   f0100148 <_panic>
	assert(pp2->pp_ref == 0);
f0102760:	68 94 5c 10 f0       	push   $0xf0105c94
f0102765:	68 67 5a 10 f0       	push   $0xf0105a67
f010276a:	68 73 03 00 00       	push   $0x373
f010276f:	68 41 5a 10 f0       	push   $0xf0105a41
f0102774:	e8 cf d9 ff ff       	call   f0100148 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102779:	68 58 58 10 f0       	push   $0xf0105858
f010277e:	68 67 5a 10 f0       	push   $0xf0105a67
f0102783:	68 76 03 00 00       	push   $0x376
f0102788:	68 41 5a 10 f0       	push   $0xf0105a41
f010278d:	e8 b6 d9 ff ff       	call   f0100148 <_panic>
	assert(!page_alloc(0));
f0102792:	68 e8 5b 10 f0       	push   $0xf0105be8
f0102797:	68 67 5a 10 f0       	push   $0xf0105a67
f010279c:	68 79 03 00 00       	push   $0x379
f01027a1:	68 41 5a 10 f0       	push   $0xf0105a41
f01027a6:	e8 9d d9 ff ff       	call   f0100148 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01027ab:	68 fc 54 10 f0       	push   $0xf01054fc
f01027b0:	68 67 5a 10 f0       	push   $0xf0105a67
f01027b5:	68 7c 03 00 00       	push   $0x37c
f01027ba:	68 41 5a 10 f0       	push   $0xf0105a41
f01027bf:	e8 84 d9 ff ff       	call   f0100148 <_panic>
	assert(pp0->pp_ref == 1);
f01027c4:	68 4b 5c 10 f0       	push   $0xf0105c4b
f01027c9:	68 67 5a 10 f0       	push   $0xf0105a67
f01027ce:	68 7e 03 00 00       	push   $0x37e
f01027d3:	68 41 5a 10 f0       	push   $0xf0105a41
f01027d8:	e8 6b d9 ff ff       	call   f0100148 <_panic>
f01027dd:	52                   	push   %edx
f01027de:	68 f0 50 10 f0       	push   $0xf01050f0
f01027e3:	68 85 03 00 00       	push   $0x385
f01027e8:	68 41 5a 10 f0       	push   $0xf0105a41
f01027ed:	e8 56 d9 ff ff       	call   f0100148 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01027f2:	68 d7 5c 10 f0       	push   $0xf0105cd7
f01027f7:	68 67 5a 10 f0       	push   $0xf0105a67
f01027fc:	68 86 03 00 00       	push   $0x386
f0102801:	68 41 5a 10 f0       	push   $0xf0105a41
f0102806:	e8 3d d9 ff ff       	call   f0100148 <_panic>
f010280b:	50                   	push   %eax
f010280c:	68 f0 50 10 f0       	push   $0xf01050f0
f0102811:	6a 56                	push   $0x56
f0102813:	68 4d 5a 10 f0       	push   $0xf0105a4d
f0102818:	e8 2b d9 ff ff       	call   f0100148 <_panic>
f010281d:	52                   	push   %edx
f010281e:	68 f0 50 10 f0       	push   $0xf01050f0
f0102823:	6a 56                	push   $0x56
f0102825:	68 4d 5a 10 f0       	push   $0xf0105a4d
f010282a:	e8 19 d9 ff ff       	call   f0100148 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f010282f:	68 ef 5c 10 f0       	push   $0xf0105cef
f0102834:	68 67 5a 10 f0       	push   $0xf0105a67
f0102839:	68 90 03 00 00       	push   $0x390
f010283e:	68 41 5a 10 f0       	push   $0xf0105a41
f0102843:	e8 00 d9 ff ff       	call   f0100148 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102848:	50                   	push   %eax
f0102849:	68 a4 53 10 f0       	push   $0xf01053a4
f010284e:	68 bb 00 00 00       	push   $0xbb
f0102853:	68 41 5a 10 f0       	push   $0xf0105a41
f0102858:	e8 eb d8 ff ff       	call   f0100148 <_panic>
f010285d:	50                   	push   %eax
f010285e:	68 a4 53 10 f0       	push   $0xf01053a4
f0102863:	68 c5 00 00 00       	push   $0xc5
f0102868:	68 41 5a 10 f0       	push   $0xf0105a41
f010286d:	e8 d6 d8 ff ff       	call   f0100148 <_panic>
f0102872:	50                   	push   %eax
f0102873:	68 a4 53 10 f0       	push   $0xf01053a4
f0102878:	68 d2 00 00 00       	push   $0xd2
f010287d:	68 41 5a 10 f0       	push   $0xf0105a41
f0102882:	e8 c1 d8 ff ff       	call   f0100148 <_panic>
f0102887:	ff 75 c8             	pushl  -0x38(%ebp)
f010288a:	68 a4 53 10 f0       	push   $0xf01053a4
f010288f:	68 cc 02 00 00       	push   $0x2cc
f0102894:	68 41 5a 10 f0       	push   $0xf0105a41
f0102899:	e8 aa d8 ff ff       	call   f0100148 <_panic>
	for (i = 0; i < n; i += PGSIZE) 
f010289e:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01028a4:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f01028a7:	76 36                	jbe    f01028df <mem_init+0x1382>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01028a9:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f01028af:	89 d8                	mov    %ebx,%eax
f01028b1:	e8 7d e5 ff ff       	call   f0100e33 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01028b6:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01028bd:	76 c8                	jbe    f0102887 <mem_init+0x132a>
f01028bf:	8d 14 3e             	lea    (%esi,%edi,1),%edx
f01028c2:	39 c2                	cmp    %eax,%edx
f01028c4:	74 d8                	je     f010289e <mem_init+0x1341>
f01028c6:	68 7c 58 10 f0       	push   $0xf010587c
f01028cb:	68 67 5a 10 f0       	push   $0xf0105a67
f01028d0:	68 cc 02 00 00       	push   $0x2cc
f01028d5:	68 41 5a 10 f0       	push   $0xf0105a41
f01028da:	e8 69 d8 ff ff       	call   f0100148 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01028df:	a1 28 51 1b f0       	mov    0xf01b5128,%eax
f01028e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01028e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01028ea:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f01028ef:	8d b8 00 00 40 21    	lea    0x21400000(%eax),%edi
f01028f5:	89 f2                	mov    %esi,%edx
f01028f7:	89 d8                	mov    %ebx,%eax
f01028f9:	e8 35 e5 ff ff       	call   f0100e33 <check_va2pa>
f01028fe:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102905:	76 3d                	jbe    f0102944 <mem_init+0x13e7>
f0102907:	8d 14 37             	lea    (%edi,%esi,1),%edx
f010290a:	39 c2                	cmp    %eax,%edx
f010290c:	75 4d                	jne    f010295b <mem_init+0x13fe>
f010290e:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < n; i += PGSIZE)
f0102914:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f010291a:	75 d9                	jne    f01028f5 <mem_init+0x1398>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010291c:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010291f:	c1 e7 0c             	shl    $0xc,%edi
f0102922:	be 00 00 00 00       	mov    $0x0,%esi
f0102927:	39 fe                	cmp    %edi,%esi
f0102929:	73 62                	jae    f010298d <mem_init+0x1430>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010292b:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102931:	89 d8                	mov    %ebx,%eax
f0102933:	e8 fb e4 ff ff       	call   f0100e33 <check_va2pa>
f0102938:	39 c6                	cmp    %eax,%esi
f010293a:	75 38                	jne    f0102974 <mem_init+0x1417>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010293c:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102942:	eb e3                	jmp    f0102927 <mem_init+0x13ca>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102944:	ff 75 d0             	pushl  -0x30(%ebp)
f0102947:	68 a4 53 10 f0       	push   $0xf01053a4
f010294c:	68 d1 02 00 00       	push   $0x2d1
f0102951:	68 41 5a 10 f0       	push   $0xf0105a41
f0102956:	e8 ed d7 ff ff       	call   f0100148 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010295b:	68 b0 58 10 f0       	push   $0xf01058b0
f0102960:	68 67 5a 10 f0       	push   $0xf0105a67
f0102965:	68 d1 02 00 00       	push   $0x2d1
f010296a:	68 41 5a 10 f0       	push   $0xf0105a41
f010296f:	e8 d4 d7 ff ff       	call   f0100148 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102974:	68 e4 58 10 f0       	push   $0xf01058e4
f0102979:	68 67 5a 10 f0       	push   $0xf0105a67
f010297e:	68 d5 02 00 00       	push   $0x2d5
f0102983:	68 41 5a 10 f0       	push   $0xf0105a41
f0102988:	e8 bb d7 ff ff       	call   f0100148 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010298d:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102992:	b8 00 20 11 f0       	mov    $0xf0112000,%eax
f0102997:	8d b8 00 80 00 20    	lea    0x20008000(%eax),%edi
f010299d:	89 f2                	mov    %esi,%edx
f010299f:	89 d8                	mov    %ebx,%eax
f01029a1:	e8 8d e4 ff ff       	call   f0100e33 <check_va2pa>
f01029a6:	8d 14 37             	lea    (%edi,%esi,1),%edx
f01029a9:	39 d0                	cmp    %edx,%eax
f01029ab:	75 26                	jne    f01029d3 <mem_init+0x1476>
f01029ad:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < KSTKSIZE; i += PGSIZE) {
f01029b3:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01029b9:	75 e2                	jne    f010299d <mem_init+0x1440>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01029bb:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01029c0:	89 d8                	mov    %ebx,%eax
f01029c2:	e8 6c e4 ff ff       	call   f0100e33 <check_va2pa>
f01029c7:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029ca:	75 20                	jne    f01029ec <mem_init+0x148f>
	for (i = 0; i < NPDENTRIES; i++) {
f01029cc:	b8 00 00 00 00       	mov    $0x0,%eax
f01029d1:	eb 59                	jmp    f0102a2c <mem_init+0x14cf>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01029d3:	68 0c 59 10 f0       	push   $0xf010590c
f01029d8:	68 67 5a 10 f0       	push   $0xf0105a67
f01029dd:	68 d9 02 00 00       	push   $0x2d9
f01029e2:	68 41 5a 10 f0       	push   $0xf0105a41
f01029e7:	e8 5c d7 ff ff       	call   f0100148 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01029ec:	68 54 59 10 f0       	push   $0xf0105954
f01029f1:	68 67 5a 10 f0       	push   $0xf0105a67
f01029f6:	68 db 02 00 00       	push   $0x2db
f01029fb:	68 41 5a 10 f0       	push   $0xf0105a41
f0102a00:	e8 43 d7 ff ff       	call   f0100148 <_panic>
			assert(pgdir[i] & PTE_P);
f0102a05:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102a09:	74 47                	je     f0102a52 <mem_init+0x14f5>
	for (i = 0; i < NPDENTRIES; i++) {
f0102a0b:	40                   	inc    %eax
f0102a0c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102a11:	0f 87 93 00 00 00    	ja     f0102aaa <mem_init+0x154d>
		switch (i) {
f0102a17:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102a1c:	72 0e                	jb     f0102a2c <mem_init+0x14cf>
f0102a1e:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102a23:	76 e0                	jbe    f0102a05 <mem_init+0x14a8>
f0102a25:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102a2a:	74 d9                	je     f0102a05 <mem_init+0x14a8>
			if (i >= PDX(KERNBASE)) {
f0102a2c:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102a31:	77 38                	ja     f0102a6b <mem_init+0x150e>
				assert(pgdir[i] == 0);
f0102a33:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102a37:	74 d2                	je     f0102a0b <mem_init+0x14ae>
f0102a39:	68 41 5d 10 f0       	push   $0xf0105d41
f0102a3e:	68 67 5a 10 f0       	push   $0xf0105a67
f0102a43:	68 eb 02 00 00       	push   $0x2eb
f0102a48:	68 41 5a 10 f0       	push   $0xf0105a41
f0102a4d:	e8 f6 d6 ff ff       	call   f0100148 <_panic>
			assert(pgdir[i] & PTE_P);
f0102a52:	68 1f 5d 10 f0       	push   $0xf0105d1f
f0102a57:	68 67 5a 10 f0       	push   $0xf0105a67
f0102a5c:	68 e4 02 00 00       	push   $0x2e4
f0102a61:	68 41 5a 10 f0       	push   $0xf0105a41
f0102a66:	e8 dd d6 ff ff       	call   f0100148 <_panic>
				assert(pgdir[i] & PTE_P);
f0102a6b:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102a6e:	f6 c2 01             	test   $0x1,%dl
f0102a71:	74 1e                	je     f0102a91 <mem_init+0x1534>
				assert(pgdir[i] & PTE_W);
f0102a73:	f6 c2 02             	test   $0x2,%dl
f0102a76:	75 93                	jne    f0102a0b <mem_init+0x14ae>
f0102a78:	68 30 5d 10 f0       	push   $0xf0105d30
f0102a7d:	68 67 5a 10 f0       	push   $0xf0105a67
f0102a82:	68 e9 02 00 00       	push   $0x2e9
f0102a87:	68 41 5a 10 f0       	push   $0xf0105a41
f0102a8c:	e8 b7 d6 ff ff       	call   f0100148 <_panic>
				assert(pgdir[i] & PTE_P);
f0102a91:	68 1f 5d 10 f0       	push   $0xf0105d1f
f0102a96:	68 67 5a 10 f0       	push   $0xf0105a67
f0102a9b:	68 e8 02 00 00       	push   $0x2e8
f0102aa0:	68 41 5a 10 f0       	push   $0xf0105a41
f0102aa5:	e8 9e d6 ff ff       	call   f0100148 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102aaa:	83 ec 0c             	sub    $0xc,%esp
f0102aad:	68 84 59 10 f0       	push   $0xf0105984
f0102ab2:	e8 3c 0b 00 00       	call   f01035f3 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102ab7:	a1 e8 5d 1b f0       	mov    0xf01b5de8,%eax
	if ((uint32_t)kva < KERNBASE)
f0102abc:	83 c4 10             	add    $0x10,%esp
f0102abf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ac4:	0f 86 fe 01 00 00    	jbe    f0102cc8 <mem_init+0x176b>
	return (physaddr_t)kva - KERNBASE;
f0102aca:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102acf:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102ad2:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ad7:	e8 b6 e3 ff ff       	call   f0100e92 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102adc:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102adf:	83 e0 f3             	and    $0xfffffff3,%eax
f0102ae2:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102ae7:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102aea:	83 ec 0c             	sub    $0xc,%esp
f0102aed:	6a 00                	push   $0x0
f0102aef:	e8 04 e7 ff ff       	call   f01011f8 <page_alloc>
f0102af4:	89 c3                	mov    %eax,%ebx
f0102af6:	83 c4 10             	add    $0x10,%esp
f0102af9:	85 c0                	test   %eax,%eax
f0102afb:	0f 84 dc 01 00 00    	je     f0102cdd <mem_init+0x1780>
	assert((pp1 = page_alloc(0)));
f0102b01:	83 ec 0c             	sub    $0xc,%esp
f0102b04:	6a 00                	push   $0x0
f0102b06:	e8 ed e6 ff ff       	call   f01011f8 <page_alloc>
f0102b0b:	89 c7                	mov    %eax,%edi
f0102b0d:	83 c4 10             	add    $0x10,%esp
f0102b10:	85 c0                	test   %eax,%eax
f0102b12:	0f 84 de 01 00 00    	je     f0102cf6 <mem_init+0x1799>
	assert((pp2 = page_alloc(0)));
f0102b18:	83 ec 0c             	sub    $0xc,%esp
f0102b1b:	6a 00                	push   $0x0
f0102b1d:	e8 d6 e6 ff ff       	call   f01011f8 <page_alloc>
f0102b22:	89 c6                	mov    %eax,%esi
f0102b24:	83 c4 10             	add    $0x10,%esp
f0102b27:	85 c0                	test   %eax,%eax
f0102b29:	0f 84 e0 01 00 00    	je     f0102d0f <mem_init+0x17b2>
	page_free(pp0);
f0102b2f:	83 ec 0c             	sub    $0xc,%esp
f0102b32:	53                   	push   %ebx
f0102b33:	e8 32 e7 ff ff       	call   f010126a <page_free>
	return (pp - pages) << PGSHIFT;
f0102b38:	89 f8                	mov    %edi,%eax
f0102b3a:	2b 05 ec 5d 1b f0    	sub    0xf01b5dec,%eax
f0102b40:	c1 f8 03             	sar    $0x3,%eax
f0102b43:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102b46:	89 c2                	mov    %eax,%edx
f0102b48:	c1 ea 0c             	shr    $0xc,%edx
f0102b4b:	83 c4 10             	add    $0x10,%esp
f0102b4e:	3b 15 e4 5d 1b f0    	cmp    0xf01b5de4,%edx
f0102b54:	0f 83 ce 01 00 00    	jae    f0102d28 <mem_init+0x17cb>
	memset(page2kva(pp1), 1, PGSIZE);
f0102b5a:	83 ec 04             	sub    $0x4,%esp
f0102b5d:	68 00 10 00 00       	push   $0x1000
f0102b62:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102b64:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b69:	50                   	push   %eax
f0102b6a:	e8 a8 19 00 00       	call   f0104517 <memset>
	return (pp - pages) << PGSHIFT;
f0102b6f:	89 f0                	mov    %esi,%eax
f0102b71:	2b 05 ec 5d 1b f0    	sub    0xf01b5dec,%eax
f0102b77:	c1 f8 03             	sar    $0x3,%eax
f0102b7a:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102b7d:	89 c2                	mov    %eax,%edx
f0102b7f:	c1 ea 0c             	shr    $0xc,%edx
f0102b82:	83 c4 10             	add    $0x10,%esp
f0102b85:	3b 15 e4 5d 1b f0    	cmp    0xf01b5de4,%edx
f0102b8b:	0f 83 a9 01 00 00    	jae    f0102d3a <mem_init+0x17dd>
	memset(page2kva(pp2), 2, PGSIZE);
f0102b91:	83 ec 04             	sub    $0x4,%esp
f0102b94:	68 00 10 00 00       	push   $0x1000
f0102b99:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102b9b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102ba0:	50                   	push   %eax
f0102ba1:	e8 71 19 00 00       	call   f0104517 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102ba6:	6a 02                	push   $0x2
f0102ba8:	68 00 10 00 00       	push   $0x1000
f0102bad:	57                   	push   %edi
f0102bae:	ff 35 e8 5d 1b f0    	pushl  0xf01b5de8
f0102bb4:	e8 3d e9 ff ff       	call   f01014f6 <page_insert>
	assert(pp1->pp_ref == 1);
f0102bb9:	83 c4 20             	add    $0x20,%esp
f0102bbc:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102bc1:	0f 85 85 01 00 00    	jne    f0102d4c <mem_init+0x17ef>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102bc7:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102bce:	01 01 01 
f0102bd1:	0f 85 8e 01 00 00    	jne    f0102d65 <mem_init+0x1808>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102bd7:	6a 02                	push   $0x2
f0102bd9:	68 00 10 00 00       	push   $0x1000
f0102bde:	56                   	push   %esi
f0102bdf:	ff 35 e8 5d 1b f0    	pushl  0xf01b5de8
f0102be5:	e8 0c e9 ff ff       	call   f01014f6 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102bea:	83 c4 10             	add    $0x10,%esp
f0102bed:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102bf4:	02 02 02 
f0102bf7:	0f 85 81 01 00 00    	jne    f0102d7e <mem_init+0x1821>
	assert(pp2->pp_ref == 1);
f0102bfd:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102c02:	0f 85 8f 01 00 00    	jne    f0102d97 <mem_init+0x183a>
	assert(pp1->pp_ref == 0);
f0102c08:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102c0d:	0f 85 9d 01 00 00    	jne    f0102db0 <mem_init+0x1853>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102c13:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102c1a:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102c1d:	89 f0                	mov    %esi,%eax
f0102c1f:	2b 05 ec 5d 1b f0    	sub    0xf01b5dec,%eax
f0102c25:	c1 f8 03             	sar    $0x3,%eax
f0102c28:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102c2b:	89 c2                	mov    %eax,%edx
f0102c2d:	c1 ea 0c             	shr    $0xc,%edx
f0102c30:	3b 15 e4 5d 1b f0    	cmp    0xf01b5de4,%edx
f0102c36:	0f 83 8d 01 00 00    	jae    f0102dc9 <mem_init+0x186c>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c3c:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102c43:	03 03 03 
f0102c46:	0f 85 8f 01 00 00    	jne    f0102ddb <mem_init+0x187e>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c4c:	83 ec 08             	sub    $0x8,%esp
f0102c4f:	68 00 10 00 00       	push   $0x1000
f0102c54:	ff 35 e8 5d 1b f0    	pushl  0xf01b5de8
f0102c5a:	e8 4f e8 ff ff       	call   f01014ae <page_remove>
	assert(pp2->pp_ref == 0);
f0102c5f:	83 c4 10             	add    $0x10,%esp
f0102c62:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102c67:	0f 85 87 01 00 00    	jne    f0102df4 <mem_init+0x1897>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c6d:	8b 0d e8 5d 1b f0    	mov    0xf01b5de8,%ecx
f0102c73:	8b 11                	mov    (%ecx),%edx
f0102c75:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102c7b:	89 d8                	mov    %ebx,%eax
f0102c7d:	2b 05 ec 5d 1b f0    	sub    0xf01b5dec,%eax
f0102c83:	c1 f8 03             	sar    $0x3,%eax
f0102c86:	c1 e0 0c             	shl    $0xc,%eax
f0102c89:	39 c2                	cmp    %eax,%edx
f0102c8b:	0f 85 7c 01 00 00    	jne    f0102e0d <mem_init+0x18b0>
	kern_pgdir[0] = 0;
f0102c91:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102c97:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102c9c:	0f 85 84 01 00 00    	jne    f0102e26 <mem_init+0x18c9>
	pp0->pp_ref = 0;
f0102ca2:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102ca8:	83 ec 0c             	sub    $0xc,%esp
f0102cab:	53                   	push   %ebx
f0102cac:	e8 b9 e5 ff ff       	call   f010126a <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102cb1:	c7 04 24 18 5a 10 f0 	movl   $0xf0105a18,(%esp)
f0102cb8:	e8 36 09 00 00       	call   f01035f3 <cprintf>
}
f0102cbd:	83 c4 10             	add    $0x10,%esp
f0102cc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102cc3:	5b                   	pop    %ebx
f0102cc4:	5e                   	pop    %esi
f0102cc5:	5f                   	pop    %edi
f0102cc6:	5d                   	pop    %ebp
f0102cc7:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cc8:	50                   	push   %eax
f0102cc9:	68 a4 53 10 f0       	push   $0xf01053a4
f0102cce:	68 e8 00 00 00       	push   $0xe8
f0102cd3:	68 41 5a 10 f0       	push   $0xf0105a41
f0102cd8:	e8 6b d4 ff ff       	call   f0100148 <_panic>
	assert((pp0 = page_alloc(0)));
f0102cdd:	68 3d 5b 10 f0       	push   $0xf0105b3d
f0102ce2:	68 67 5a 10 f0       	push   $0xf0105a67
f0102ce7:	68 ab 03 00 00       	push   $0x3ab
f0102cec:	68 41 5a 10 f0       	push   $0xf0105a41
f0102cf1:	e8 52 d4 ff ff       	call   f0100148 <_panic>
	assert((pp1 = page_alloc(0)));
f0102cf6:	68 53 5b 10 f0       	push   $0xf0105b53
f0102cfb:	68 67 5a 10 f0       	push   $0xf0105a67
f0102d00:	68 ac 03 00 00       	push   $0x3ac
f0102d05:	68 41 5a 10 f0       	push   $0xf0105a41
f0102d0a:	e8 39 d4 ff ff       	call   f0100148 <_panic>
	assert((pp2 = page_alloc(0)));
f0102d0f:	68 69 5b 10 f0       	push   $0xf0105b69
f0102d14:	68 67 5a 10 f0       	push   $0xf0105a67
f0102d19:	68 ad 03 00 00       	push   $0x3ad
f0102d1e:	68 41 5a 10 f0       	push   $0xf0105a41
f0102d23:	e8 20 d4 ff ff       	call   f0100148 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d28:	50                   	push   %eax
f0102d29:	68 f0 50 10 f0       	push   $0xf01050f0
f0102d2e:	6a 56                	push   $0x56
f0102d30:	68 4d 5a 10 f0       	push   $0xf0105a4d
f0102d35:	e8 0e d4 ff ff       	call   f0100148 <_panic>
f0102d3a:	50                   	push   %eax
f0102d3b:	68 f0 50 10 f0       	push   $0xf01050f0
f0102d40:	6a 56                	push   $0x56
f0102d42:	68 4d 5a 10 f0       	push   $0xf0105a4d
f0102d47:	e8 fc d3 ff ff       	call   f0100148 <_panic>
	assert(pp1->pp_ref == 1);
f0102d4c:	68 3a 5c 10 f0       	push   $0xf0105c3a
f0102d51:	68 67 5a 10 f0       	push   $0xf0105a67
f0102d56:	68 b2 03 00 00       	push   $0x3b2
f0102d5b:	68 41 5a 10 f0       	push   $0xf0105a41
f0102d60:	e8 e3 d3 ff ff       	call   f0100148 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102d65:	68 a4 59 10 f0       	push   $0xf01059a4
f0102d6a:	68 67 5a 10 f0       	push   $0xf0105a67
f0102d6f:	68 b3 03 00 00       	push   $0x3b3
f0102d74:	68 41 5a 10 f0       	push   $0xf0105a41
f0102d79:	e8 ca d3 ff ff       	call   f0100148 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102d7e:	68 c8 59 10 f0       	push   $0xf01059c8
f0102d83:	68 67 5a 10 f0       	push   $0xf0105a67
f0102d88:	68 b5 03 00 00       	push   $0x3b5
f0102d8d:	68 41 5a 10 f0       	push   $0xf0105a41
f0102d92:	e8 b1 d3 ff ff       	call   f0100148 <_panic>
	assert(pp2->pp_ref == 1);
f0102d97:	68 5c 5c 10 f0       	push   $0xf0105c5c
f0102d9c:	68 67 5a 10 f0       	push   $0xf0105a67
f0102da1:	68 b6 03 00 00       	push   $0x3b6
f0102da6:	68 41 5a 10 f0       	push   $0xf0105a41
f0102dab:	e8 98 d3 ff ff       	call   f0100148 <_panic>
	assert(pp1->pp_ref == 0);
f0102db0:	68 c6 5c 10 f0       	push   $0xf0105cc6
f0102db5:	68 67 5a 10 f0       	push   $0xf0105a67
f0102dba:	68 b7 03 00 00       	push   $0x3b7
f0102dbf:	68 41 5a 10 f0       	push   $0xf0105a41
f0102dc4:	e8 7f d3 ff ff       	call   f0100148 <_panic>
f0102dc9:	50                   	push   %eax
f0102dca:	68 f0 50 10 f0       	push   $0xf01050f0
f0102dcf:	6a 56                	push   $0x56
f0102dd1:	68 4d 5a 10 f0       	push   $0xf0105a4d
f0102dd6:	e8 6d d3 ff ff       	call   f0100148 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102ddb:	68 ec 59 10 f0       	push   $0xf01059ec
f0102de0:	68 67 5a 10 f0       	push   $0xf0105a67
f0102de5:	68 b9 03 00 00       	push   $0x3b9
f0102dea:	68 41 5a 10 f0       	push   $0xf0105a41
f0102def:	e8 54 d3 ff ff       	call   f0100148 <_panic>
	assert(pp2->pp_ref == 0);
f0102df4:	68 94 5c 10 f0       	push   $0xf0105c94
f0102df9:	68 67 5a 10 f0       	push   $0xf0105a67
f0102dfe:	68 bb 03 00 00       	push   $0x3bb
f0102e03:	68 41 5a 10 f0       	push   $0xf0105a41
f0102e08:	e8 3b d3 ff ff       	call   f0100148 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e0d:	68 fc 54 10 f0       	push   $0xf01054fc
f0102e12:	68 67 5a 10 f0       	push   $0xf0105a67
f0102e17:	68 be 03 00 00       	push   $0x3be
f0102e1c:	68 41 5a 10 f0       	push   $0xf0105a41
f0102e21:	e8 22 d3 ff ff       	call   f0100148 <_panic>
	assert(pp0->pp_ref == 1);
f0102e26:	68 4b 5c 10 f0       	push   $0xf0105c4b
f0102e2b:	68 67 5a 10 f0       	push   $0xf0105a67
f0102e30:	68 c0 03 00 00       	push   $0x3c0
f0102e35:	68 41 5a 10 f0       	push   $0xf0105a41
f0102e3a:	e8 09 d3 ff ff       	call   f0100148 <_panic>

f0102e3f <tlb_invalidate>:
{
f0102e3f:	55                   	push   %ebp
f0102e40:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102e42:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e45:	0f 01 38             	invlpg (%eax)
}
f0102e48:	5d                   	pop    %ebp
f0102e49:	c3                   	ret    

f0102e4a <user_mem_check>:
{
f0102e4a:	55                   	push   %ebp
f0102e4b:	89 e5                	mov    %esp,%ebp
}
f0102e4d:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e52:	5d                   	pop    %ebp
f0102e53:	c3                   	ret    

f0102e54 <user_mem_assert>:
{
f0102e54:	55                   	push   %ebp
f0102e55:	89 e5                	mov    %esp,%ebp
}
f0102e57:	5d                   	pop    %ebp
f0102e58:	c3                   	ret    

f0102e59 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102e59:	55                   	push   %ebp
f0102e5a:	89 e5                	mov    %esp,%ebp
f0102e5c:	53                   	push   %ebx
f0102e5d:	8b 55 08             	mov    0x8(%ebp),%edx
f0102e60:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102e63:	85 d2                	test   %edx,%edx
f0102e65:	74 44                	je     f0102eab <envid2env+0x52>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102e67:	89 d3                	mov    %edx,%ebx
f0102e69:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102e6f:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0102e72:	01 d8                	add    %ebx,%eax
f0102e74:	c1 e0 05             	shl    $0x5,%eax
f0102e77:	03 05 28 51 1b f0    	add    0xf01b5128,%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102e7d:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f0102e81:	74 39                	je     f0102ebc <envid2env+0x63>
f0102e83:	39 50 48             	cmp    %edx,0x48(%eax)
f0102e86:	75 34                	jne    f0102ebc <envid2env+0x63>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102e88:	84 c9                	test   %cl,%cl
f0102e8a:	74 12                	je     f0102e9e <envid2env+0x45>
f0102e8c:	8b 15 24 51 1b f0    	mov    0xf01b5124,%edx
f0102e92:	39 c2                	cmp    %eax,%edx
f0102e94:	74 08                	je     f0102e9e <envid2env+0x45>
f0102e96:	8b 5a 48             	mov    0x48(%edx),%ebx
f0102e99:	39 58 4c             	cmp    %ebx,0x4c(%eax)
f0102e9c:	75 2e                	jne    f0102ecc <envid2env+0x73>
		*env_store = 0;
		return -E_BAD_ENV;
	}

	*env_store = e;
f0102e9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102ea1:	89 01                	mov    %eax,(%ecx)
	return 0;
f0102ea3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102ea8:	5b                   	pop    %ebx
f0102ea9:	5d                   	pop    %ebp
f0102eaa:	c3                   	ret    
		*env_store = curenv;
f0102eab:	a1 24 51 1b f0       	mov    0xf01b5124,%eax
f0102eb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102eb3:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102eb5:	b8 00 00 00 00       	mov    $0x0,%eax
f0102eba:	eb ec                	jmp    f0102ea8 <envid2env+0x4f>
		*env_store = 0;
f0102ebc:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ebf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102ec5:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102eca:	eb dc                	jmp    f0102ea8 <envid2env+0x4f>
		*env_store = 0;
f0102ecc:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ecf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102ed5:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102eda:	eb cc                	jmp    f0102ea8 <envid2env+0x4f>

f0102edc <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102edc:	55                   	push   %ebp
f0102edd:	89 e5                	mov    %esp,%ebp
	asm volatile("lgdt (%0)" : : "r" (p));
f0102edf:	b8 00 c3 11 f0       	mov    $0xf011c300,%eax
f0102ee4:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0102ee7:	b8 23 00 00 00       	mov    $0x23,%eax
f0102eec:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0102eee:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0102ef0:	b8 10 00 00 00       	mov    $0x10,%eax
f0102ef5:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0102ef7:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0102ef9:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0102efb:	ea 02 2f 10 f0 08 00 	ljmp   $0x8,$0xf0102f02
	asm volatile("lldt %0" : : "r" (sel));
f0102f02:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f07:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102f0a:	5d                   	pop    %ebp
f0102f0b:	c3                   	ret    

f0102f0c <env_init>:
{
f0102f0c:	55                   	push   %ebp
f0102f0d:	89 e5                	mov    %esp,%ebp
f0102f0f:	56                   	push   %esi
f0102f10:	53                   	push   %ebx
		envs[i].env_link = env_free_list;
f0102f11:	8b 35 28 51 1b f0    	mov    0xf01b5128,%esi
f0102f17:	8b 15 2c 51 1b f0    	mov    0xf01b512c,%edx
f0102f1d:	8d 86 a0 7f 01 00    	lea    0x17fa0(%esi),%eax
f0102f23:	8d 5e a0             	lea    -0x60(%esi),%ebx
f0102f26:	89 c1                	mov    %eax,%ecx
f0102f28:	89 50 44             	mov    %edx,0x44(%eax)
f0102f2b:	83 e8 60             	sub    $0x60,%eax
		env_free_list = &envs[i];
f0102f2e:	89 ca                	mov    %ecx,%edx
	for (int i = NENV - 1; i >= 0; i--) { // Be sure not to use size_t
f0102f30:	39 d8                	cmp    %ebx,%eax
f0102f32:	75 f2                	jne    f0102f26 <env_init+0x1a>
f0102f34:	89 35 2c 51 1b f0    	mov    %esi,0xf01b512c
	env_init_percpu();
f0102f3a:	e8 9d ff ff ff       	call   f0102edc <env_init_percpu>
}
f0102f3f:	5b                   	pop    %ebx
f0102f40:	5e                   	pop    %esi
f0102f41:	5d                   	pop    %ebp
f0102f42:	c3                   	ret    

f0102f43 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102f43:	55                   	push   %ebp
f0102f44:	89 e5                	mov    %esp,%ebp
f0102f46:	56                   	push   %esi
f0102f47:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;
	// cprintf("newenv_store = %p\n", newenv_store);
	if (!(e = env_free_list))
f0102f48:	8b 1d 2c 51 1b f0    	mov    0xf01b512c,%ebx
f0102f4e:	85 db                	test   %ebx,%ebx
f0102f50:	0f 84 77 01 00 00    	je     f01030cd <env_alloc+0x18a>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102f56:	83 ec 0c             	sub    $0xc,%esp
f0102f59:	6a 01                	push   $0x1
f0102f5b:	e8 98 e2 ff ff       	call   f01011f8 <page_alloc>
f0102f60:	83 c4 10             	add    $0x10,%esp
f0102f63:	85 c0                	test   %eax,%eax
f0102f65:	0f 84 69 01 00 00    	je     f01030d4 <env_alloc+0x191>
	p->pp_ref++;
f0102f6b:	66 ff 40 04          	incw   0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0102f6f:	2b 05 ec 5d 1b f0    	sub    0xf01b5dec,%eax
f0102f75:	c1 f8 03             	sar    $0x3,%eax
f0102f78:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102f7b:	89 c2                	mov    %eax,%edx
f0102f7d:	c1 ea 0c             	shr    $0xc,%edx
f0102f80:	3b 15 e4 5d 1b f0    	cmp    0xf01b5de4,%edx
f0102f86:	0f 83 09 01 00 00    	jae    f0103095 <env_alloc+0x152>
	return (void *)(pa + KERNBASE);
f0102f8c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102f91:	89 43 5c             	mov    %eax,0x5c(%ebx)
	e->env_pgdir = page2kva(p);
f0102f94:	b8 ec 0e 00 00       	mov    $0xeec,%eax
		e->env_pgdir[pgt] = kern_pgdir[pgt];
f0102f99:	8b 15 e8 5d 1b f0    	mov    0xf01b5de8,%edx
f0102f9f:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0102fa2:	8b 53 5c             	mov    0x5c(%ebx),%edx
f0102fa5:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0102fa8:	83 c0 04             	add    $0x4,%eax
	for (size_t pgt = PDX(UTOP); pgt < PGSIZE / sizeof(pde_t); pgt++) {
f0102fab:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102fb0:	75 e7                	jne    f0102f99 <env_alloc+0x56>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102fb2:	8b 43 5c             	mov    0x5c(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0102fb5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102fba:	0f 86 e7 00 00 00    	jbe    f01030a7 <env_alloc+0x164>
	return (physaddr_t)kva - KERNBASE;
f0102fc0:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102fc6:	83 ca 05             	or     $0x5,%edx
f0102fc9:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102fcf:	8b 43 48             	mov    0x48(%ebx),%eax
f0102fd2:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102fd7:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0102fdc:	89 c2                	mov    %eax,%edx
f0102fde:	0f 8e d8 00 00 00    	jle    f01030bc <env_alloc+0x179>
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f0102fe4:	89 d8                	mov    %ebx,%eax
f0102fe6:	2b 05 28 51 1b f0    	sub    0xf01b5128,%eax
f0102fec:	c1 f8 05             	sar    $0x5,%eax
f0102fef:	89 c1                	mov    %eax,%ecx
f0102ff1:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102ff4:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0102ff7:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0102ffa:	89 c6                	mov    %eax,%esi
f0102ffc:	c1 e6 08             	shl    $0x8,%esi
f0102fff:	01 f0                	add    %esi,%eax
f0103001:	89 c6                	mov    %eax,%esi
f0103003:	c1 e6 10             	shl    $0x10,%esi
f0103006:	01 f0                	add    %esi,%eax
f0103008:	01 c0                	add    %eax,%eax
f010300a:	01 c8                	add    %ecx,%eax
f010300c:	09 d0                	or     %edx,%eax
f010300e:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103011:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103014:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103017:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010301e:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103025:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010302c:	83 ec 04             	sub    $0x4,%esp
f010302f:	6a 44                	push   $0x44
f0103031:	6a 00                	push   $0x0
f0103033:	53                   	push   %ebx
f0103034:	e8 de 14 00 00       	call   f0104517 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103039:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010303f:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103045:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010304b:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103052:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0103058:	8b 43 44             	mov    0x44(%ebx),%eax
f010305b:	a3 2c 51 1b f0       	mov    %eax,0xf01b512c
	*newenv_store = e;
f0103060:	8b 45 08             	mov    0x8(%ebp),%eax
f0103063:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103065:	8b 53 48             	mov    0x48(%ebx),%edx
f0103068:	a1 24 51 1b f0       	mov    0xf01b5124,%eax
f010306d:	83 c4 10             	add    $0x10,%esp
f0103070:	85 c0                	test   %eax,%eax
f0103072:	74 52                	je     f01030c6 <env_alloc+0x183>
f0103074:	8b 40 48             	mov    0x48(%eax),%eax
f0103077:	83 ec 04             	sub    $0x4,%esp
f010307a:	52                   	push   %edx
f010307b:	50                   	push   %eax
f010307c:	68 d9 5d 10 f0       	push   $0xf0105dd9
f0103081:	e8 6d 05 00 00       	call   f01035f3 <cprintf>
	return 0;
f0103086:	83 c4 10             	add    $0x10,%esp
f0103089:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010308e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103091:	5b                   	pop    %ebx
f0103092:	5e                   	pop    %esi
f0103093:	5d                   	pop    %ebp
f0103094:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103095:	50                   	push   %eax
f0103096:	68 f0 50 10 f0       	push   $0xf01050f0
f010309b:	6a 56                	push   $0x56
f010309d:	68 4d 5a 10 f0       	push   $0xf0105a4d
f01030a2:	e8 a1 d0 ff ff       	call   f0100148 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030a7:	50                   	push   %eax
f01030a8:	68 a4 53 10 f0       	push   $0xf01053a4
f01030ad:	68 c6 00 00 00       	push   $0xc6
f01030b2:	68 ce 5d 10 f0       	push   $0xf0105dce
f01030b7:	e8 8c d0 ff ff       	call   f0100148 <_panic>
		generation = 1 << ENVGENSHIFT;
f01030bc:	ba 00 10 00 00       	mov    $0x1000,%edx
f01030c1:	e9 1e ff ff ff       	jmp    f0102fe4 <env_alloc+0xa1>
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01030c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01030cb:	eb aa                	jmp    f0103077 <env_alloc+0x134>
		return -E_NO_FREE_ENV;
f01030cd:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01030d2:	eb ba                	jmp    f010308e <env_alloc+0x14b>
		return -E_NO_MEM;
f01030d4:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01030d9:	eb b3                	jmp    f010308e <env_alloc+0x14b>

f01030db <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01030db:	55                   	push   %ebp
f01030dc:	89 e5                	mov    %esp,%ebp
f01030de:	57                   	push   %edi
f01030df:	56                   	push   %esi
f01030e0:	53                   	push   %ebx
f01030e1:	83 ec 34             	sub    $0x34,%esp
	struct Env* newenv;
	// cprintf("&newenv = %p\n", &newenv);
	// cprintf("env_free_list = %p\n", env_free_list);
	int r = env_alloc(&newenv, 0);
f01030e4:	6a 00                	push   $0x0
f01030e6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01030e9:	50                   	push   %eax
f01030ea:	e8 54 fe ff ff       	call   f0102f43 <env_alloc>
	// cprintf("newenv = %p, envs[0] = %p\n", newenv, envs);
	if (r)
f01030ef:	83 c4 10             	add    $0x10,%esp
f01030f2:	85 c0                	test   %eax,%eax
f01030f4:	75 47                	jne    f010313d <env_create+0x62>
		panic("Environment allocation faulted: %e", r);
	load_icode(newenv, binary);
f01030f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	if (elf->e_magic != ELF_MAGIC)
f01030f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01030fc:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f0103102:	75 4e                	jne    f0103152 <env_create+0x77>
	struct Proghdr *ph = (struct Proghdr *) (binary + elf->e_phoff), 
f0103104:	8b 45 08             	mov    0x8(%ebp),%eax
f0103107:	89 c6                	mov    %eax,%esi
f0103109:	03 70 1c             	add    0x1c(%eax),%esi
				   *eph = ph + elf->e_phnum;
f010310c:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
f0103110:	c1 e0 05             	shl    $0x5,%eax
f0103113:	01 f0                	add    %esi,%eax
f0103115:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	pte_t pgdir_pte = *pgdir_walk(kern_pgdir, e->env_pgdir, 0);
f0103118:	83 ec 04             	sub    $0x4,%esp
f010311b:	6a 00                	push   $0x0
f010311d:	ff 77 5c             	pushl  0x5c(%edi)
f0103120:	ff 35 e8 5d 1b f0    	pushl  0xf01b5de8
f0103126:	e8 b7 e1 ff ff       	call   f01012e2 <pgdir_walk>
	physaddr_t pgdir_phy = PTE_ADDR(pgdir_pte);
f010312b:	8b 00                	mov    (%eax),%eax
f010312d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103132:	0f 22 d8             	mov    %eax,%cr3
f0103135:	83 c4 10             	add    $0x10,%esp
f0103138:	e9 df 00 00 00       	jmp    f010321c <env_create+0x141>
		panic("Environment allocation faulted: %e", r);
f010313d:	50                   	push   %eax
f010313e:	68 50 5d 10 f0       	push   $0xf0105d50
f0103143:	68 99 01 00 00       	push   $0x199
f0103148:	68 ce 5d 10 f0       	push   $0xf0105dce
f010314d:	e8 f6 cf ff ff       	call   f0100148 <_panic>
		panic("Not a valid elf binary!");
f0103152:	83 ec 04             	sub    $0x4,%esp
f0103155:	68 ee 5d 10 f0       	push   $0xf0105dee
f010315a:	68 5b 01 00 00       	push   $0x15b
f010315f:	68 ce 5d 10 f0       	push   $0xf0105dce
f0103164:	e8 df cf ff ff       	call   f0100148 <_panic>
			region_alloc(e, (void*)ph0->p_va, ph0->p_memsz);
f0103169:	8b 46 08             	mov    0x8(%esi),%eax
	uintptr_t l = ROUNDDOWN((uintptr_t)va, PGSIZE), 
f010316c:	89 c3                	mov    %eax,%ebx
f010316e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
			  r = ROUNDUP((uintptr_t)(va + len), PGSIZE);
f0103174:	03 46 14             	add    0x14(%esi),%eax
f0103177:	05 ff 0f 00 00       	add    $0xfff,%eax
f010317c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103181:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0103184:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0103187:	89 c6                	mov    %eax,%esi
	for (uintptr_t ptr = l; ptr <= r; ptr += PGSIZE) {
f0103189:	39 de                	cmp    %ebx,%esi
f010318b:	72 5a                	jb     f01031e7 <env_create+0x10c>
		struct PageInfo *pg = page_alloc(0);
f010318d:	83 ec 0c             	sub    $0xc,%esp
f0103190:	6a 00                	push   $0x0
f0103192:	e8 61 e0 ff ff       	call   f01011f8 <page_alloc>
		if (!pg)
f0103197:	83 c4 10             	add    $0x10,%esp
f010319a:	85 c0                	test   %eax,%eax
f010319c:	74 1b                	je     f01031b9 <env_create+0xde>
		int res = page_insert(e->env_pgdir, pg, (void*)ptr, PTE_U | PTE_W);
f010319e:	6a 06                	push   $0x6
f01031a0:	53                   	push   %ebx
f01031a1:	50                   	push   %eax
f01031a2:	ff 77 5c             	pushl  0x5c(%edi)
f01031a5:	e8 4c e3 ff ff       	call   f01014f6 <page_insert>
		if (res)
f01031aa:	83 c4 10             	add    $0x10,%esp
f01031ad:	85 c0                	test   %eax,%eax
f01031af:	75 1f                	jne    f01031d0 <env_create+0xf5>
	for (uintptr_t ptr = l; ptr <= r; ptr += PGSIZE) {
f01031b1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01031b7:	eb d0                	jmp    f0103189 <env_create+0xae>
			panic("No free page for allocation.");
f01031b9:	83 ec 04             	sub    $0x4,%esp
f01031bc:	68 06 5e 10 f0       	push   $0xf0105e06
f01031c1:	68 19 01 00 00       	push   $0x119
f01031c6:	68 ce 5d 10 f0       	push   $0xf0105dce
f01031cb:	e8 78 cf ff ff       	call   f0100148 <_panic>
			panic("Page insertion result: %e", r);
f01031d0:	ff 75 cc             	pushl  -0x34(%ebp)
f01031d3:	68 23 5e 10 f0       	push   $0xf0105e23
f01031d8:	68 1c 01 00 00       	push   $0x11c
f01031dd:	68 ce 5d 10 f0       	push   $0xf0105dce
f01031e2:	e8 61 cf ff ff       	call   f0100148 <_panic>
f01031e7:	8b 75 d0             	mov    -0x30(%ebp),%esi
			memcpy((void*)ph0->p_va, binary + ph0->p_offset, ph0->p_filesz);
f01031ea:	83 ec 04             	sub    $0x4,%esp
f01031ed:	ff 76 10             	pushl  0x10(%esi)
f01031f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01031f3:	03 46 04             	add    0x4(%esi),%eax
f01031f6:	50                   	push   %eax
f01031f7:	ff 76 08             	pushl  0x8(%esi)
f01031fa:	e8 cb 13 00 00       	call   f01045ca <memcpy>
					ph0->p_memsz - ph0->p_filesz);
f01031ff:	8b 46 10             	mov    0x10(%esi),%eax
			memset((void*)ph0->p_va + ph0->p_filesz, 0, 
f0103202:	83 c4 0c             	add    $0xc,%esp
f0103205:	8b 56 14             	mov    0x14(%esi),%edx
f0103208:	29 c2                	sub    %eax,%edx
f010320a:	52                   	push   %edx
f010320b:	6a 00                	push   $0x0
f010320d:	03 46 08             	add    0x8(%esi),%eax
f0103210:	50                   	push   %eax
f0103211:	e8 01 13 00 00       	call   f0104517 <memset>
f0103216:	83 c4 10             	add    $0x10,%esp
	for (struct Proghdr* ph0 = ph; ph0 < eph; ph0++) {
f0103219:	83 c6 20             	add    $0x20,%esi
f010321c:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f010321f:	76 1e                	jbe    f010323f <env_create+0x164>
		if (ph0->p_type == ELF_PROG_LOAD) {
f0103221:	83 3e 01             	cmpl   $0x1,(%esi)
f0103224:	0f 84 3f ff ff ff    	je     f0103169 <env_create+0x8e>
			cprintf("Found a ph with type %d; skipping\n", ph0->p_filesz);
f010322a:	83 ec 08             	sub    $0x8,%esp
f010322d:	ff 76 10             	pushl  0x10(%esi)
f0103230:	68 74 5d 10 f0       	push   $0xf0105d74
f0103235:	e8 b9 03 00 00       	call   f01035f3 <cprintf>
f010323a:	83 c4 10             	add    $0x10,%esp
f010323d:	eb da                	jmp    f0103219 <env_create+0x13e>
	e->env_tf.tf_eip = elf->e_entry;
f010323f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103242:	8b 40 18             	mov    0x18(%eax),%eax
f0103245:	89 47 30             	mov    %eax,0x30(%edi)
	e->env_tf.tf_eflags = 0;
f0103248:	c7 47 38 00 00 00 00 	movl   $0x0,0x38(%edi)
	lcr3(PADDR(kern_pgdir));
f010324f:	a1 e8 5d 1b f0       	mov    0xf01b5de8,%eax
	if ((uint32_t)kva < KERNBASE)
f0103254:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103259:	76 38                	jbe    f0103293 <env_create+0x1b8>
	return (physaddr_t)kva - KERNBASE;
f010325b:	05 00 00 00 10       	add    $0x10000000,%eax
f0103260:	0f 22 d8             	mov    %eax,%cr3
	struct PageInfo *stack_page = page_alloc(ALLOC_ZERO);
f0103263:	83 ec 0c             	sub    $0xc,%esp
f0103266:	6a 01                	push   $0x1
f0103268:	e8 8b df ff ff       	call   f01011f8 <page_alloc>
	if (!stack_page)
f010326d:	83 c4 10             	add    $0x10,%esp
f0103270:	85 c0                	test   %eax,%eax
f0103272:	74 34                	je     f01032a8 <env_create+0x1cd>
	int r = page_insert(e->env_pgdir, stack_page, (void*)USTACKTOP - PGSIZE, PTE_U | PTE_W);
f0103274:	6a 06                	push   $0x6
f0103276:	68 00 d0 bf ee       	push   $0xeebfd000
f010327b:	50                   	push   %eax
f010327c:	ff 77 5c             	pushl  0x5c(%edi)
f010327f:	e8 72 e2 ff ff       	call   f01014f6 <page_insert>
	if (r)
f0103284:	83 c4 10             	add    $0x10,%esp
f0103287:	85 c0                	test   %eax,%eax
f0103289:	75 34                	jne    f01032bf <env_create+0x1e4>
}
f010328b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010328e:	5b                   	pop    %ebx
f010328f:	5e                   	pop    %esi
f0103290:	5f                   	pop    %edi
f0103291:	5d                   	pop    %ebp
f0103292:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103293:	50                   	push   %eax
f0103294:	68 a4 53 10 f0       	push   $0xf01053a4
f0103299:	68 7b 01 00 00       	push   $0x17b
f010329e:	68 ce 5d 10 f0       	push   $0xf0105dce
f01032a3:	e8 a0 ce ff ff       	call   f0100148 <_panic>
		panic("No free page for allocation.");
f01032a8:	83 ec 04             	sub    $0x4,%esp
f01032ab:	68 06 5e 10 f0       	push   $0xf0105e06
f01032b0:	68 83 01 00 00       	push   $0x183
f01032b5:	68 ce 5d 10 f0       	push   $0xf0105dce
f01032ba:	e8 89 ce ff ff       	call   f0100148 <_panic>
		panic("Page insertion result: %e", r);
f01032bf:	50                   	push   %eax
f01032c0:	68 23 5e 10 f0       	push   $0xf0105e23
f01032c5:	68 86 01 00 00       	push   $0x186
f01032ca:	68 ce 5d 10 f0       	push   $0xf0105dce
f01032cf:	e8 74 ce ff ff       	call   f0100148 <_panic>

f01032d4 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01032d4:	55                   	push   %ebp
f01032d5:	89 e5                	mov    %esp,%ebp
f01032d7:	57                   	push   %edi
f01032d8:	56                   	push   %esi
f01032d9:	53                   	push   %ebx
f01032da:	83 ec 1c             	sub    $0x1c,%esp
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01032dd:	8b 15 24 51 1b f0    	mov    0xf01b5124,%edx
f01032e3:	3b 55 08             	cmp    0x8(%ebp),%edx
f01032e6:	75 14                	jne    f01032fc <env_free+0x28>
		lcr3(PADDR(kern_pgdir));
f01032e8:	a1 e8 5d 1b f0       	mov    0xf01b5de8,%eax
	if ((uint32_t)kva < KERNBASE)
f01032ed:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032f2:	76 36                	jbe    f010332a <env_free+0x56>
	return (physaddr_t)kva - KERNBASE;
f01032f4:	05 00 00 00 10       	add    $0x10000000,%eax
f01032f9:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01032fc:	8b 45 08             	mov    0x8(%ebp),%eax
f01032ff:	8b 48 48             	mov    0x48(%eax),%ecx
f0103302:	85 d2                	test   %edx,%edx
f0103304:	74 39                	je     f010333f <env_free+0x6b>
f0103306:	8b 42 48             	mov    0x48(%edx),%eax
f0103309:	83 ec 04             	sub    $0x4,%esp
f010330c:	51                   	push   %ecx
f010330d:	50                   	push   %eax
f010330e:	68 3d 5e 10 f0       	push   $0xf0105e3d
f0103313:	e8 db 02 00 00       	call   f01035f3 <cprintf>
f0103318:	83 c4 10             	add    $0x10,%esp
f010331b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0103322:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103325:	e9 96 00 00 00       	jmp    f01033c0 <env_free+0xec>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010332a:	50                   	push   %eax
f010332b:	68 a4 53 10 f0       	push   $0xf01053a4
f0103330:	68 ab 01 00 00       	push   $0x1ab
f0103335:	68 ce 5d 10 f0       	push   $0xf0105dce
f010333a:	e8 09 ce ff ff       	call   f0100148 <_panic>
f010333f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103344:	eb c3                	jmp    f0103309 <env_free+0x35>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103346:	50                   	push   %eax
f0103347:	68 f0 50 10 f0       	push   $0xf01050f0
f010334c:	68 ba 01 00 00       	push   $0x1ba
f0103351:	68 ce 5d 10 f0       	push   $0xf0105dce
f0103356:	e8 ed cd ff ff       	call   f0100148 <_panic>
f010335b:	83 c3 04             	add    $0x4,%ebx
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010335e:	39 f3                	cmp    %esi,%ebx
f0103360:	74 21                	je     f0103383 <env_free+0xaf>
			if (pt[pteno] & PTE_P)
f0103362:	f6 03 01             	testb  $0x1,(%ebx)
f0103365:	74 f4                	je     f010335b <env_free+0x87>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103367:	83 ec 08             	sub    $0x8,%esp
f010336a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010336d:	01 d8                	add    %ebx,%eax
f010336f:	c1 e0 0a             	shl    $0xa,%eax
f0103372:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103375:	50                   	push   %eax
f0103376:	ff 77 5c             	pushl  0x5c(%edi)
f0103379:	e8 30 e1 ff ff       	call   f01014ae <page_remove>
f010337e:	83 c4 10             	add    $0x10,%esp
f0103381:	eb d8                	jmp    f010335b <env_free+0x87>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103383:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103386:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103389:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103390:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103393:	3b 05 e4 5d 1b f0    	cmp    0xf01b5de4,%eax
f0103399:	73 6a                	jae    f0103405 <env_free+0x131>
		page_decref(pa2page(pa));
f010339b:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010339e:	a1 ec 5d 1b f0       	mov    0xf01b5dec,%eax
f01033a3:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01033a6:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01033a9:	50                   	push   %eax
f01033aa:	e8 0d df ff ff       	call   f01012bc <page_decref>
f01033af:	83 c4 10             	add    $0x10,%esp
f01033b2:	83 45 dc 04          	addl   $0x4,-0x24(%ebp)
f01033b6:	8b 45 dc             	mov    -0x24(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01033b9:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01033be:	74 59                	je     f0103419 <env_free+0x145>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01033c0:	8b 47 5c             	mov    0x5c(%edi),%eax
f01033c3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01033c6:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01033c9:	a8 01                	test   $0x1,%al
f01033cb:	74 e5                	je     f01033b2 <env_free+0xde>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01033cd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01033d2:	89 c2                	mov    %eax,%edx
f01033d4:	c1 ea 0c             	shr    $0xc,%edx
f01033d7:	89 55 d8             	mov    %edx,-0x28(%ebp)
f01033da:	39 15 e4 5d 1b f0    	cmp    %edx,0xf01b5de4
f01033e0:	0f 86 60 ff ff ff    	jbe    f0103346 <env_free+0x72>
	return (void *)(pa + KERNBASE);
f01033e6:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01033ec:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01033ef:	c1 e2 14             	shl    $0x14,%edx
f01033f2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01033f5:	8d b0 00 10 00 f0    	lea    -0xffff000(%eax),%esi
f01033fb:	f7 d8                	neg    %eax
f01033fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103400:	e9 5d ff ff ff       	jmp    f0103362 <env_free+0x8e>
		panic("pa2page called with invalid pa");
f0103405:	83 ec 04             	sub    $0x4,%esp
f0103408:	68 c8 53 10 f0       	push   $0xf01053c8
f010340d:	6a 4f                	push   $0x4f
f010340f:	68 4d 5a 10 f0       	push   $0xf0105a4d
f0103414:	e8 2f cd ff ff       	call   f0100148 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103419:	8b 45 08             	mov    0x8(%ebp),%eax
f010341c:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010341f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103424:	76 52                	jbe    f0103478 <env_free+0x1a4>
	e->env_pgdir = 0;
f0103426:	8b 55 08             	mov    0x8(%ebp),%edx
f0103429:	c7 42 5c 00 00 00 00 	movl   $0x0,0x5c(%edx)
	return (physaddr_t)kva - KERNBASE;
f0103430:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103435:	c1 e8 0c             	shr    $0xc,%eax
f0103438:	3b 05 e4 5d 1b f0    	cmp    0xf01b5de4,%eax
f010343e:	73 4d                	jae    f010348d <env_free+0x1b9>
	page_decref(pa2page(pa));
f0103440:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103443:	8b 15 ec 5d 1b f0    	mov    0xf01b5dec,%edx
f0103449:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010344c:	50                   	push   %eax
f010344d:	e8 6a de ff ff       	call   f01012bc <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103452:	8b 45 08             	mov    0x8(%ebp),%eax
f0103455:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f010345c:	a1 2c 51 1b f0       	mov    0xf01b512c,%eax
f0103461:	8b 55 08             	mov    0x8(%ebp),%edx
f0103464:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f0103467:	89 15 2c 51 1b f0    	mov    %edx,0xf01b512c
}
f010346d:	83 c4 10             	add    $0x10,%esp
f0103470:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103473:	5b                   	pop    %ebx
f0103474:	5e                   	pop    %esi
f0103475:	5f                   	pop    %edi
f0103476:	5d                   	pop    %ebp
f0103477:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103478:	50                   	push   %eax
f0103479:	68 a4 53 10 f0       	push   $0xf01053a4
f010347e:	68 c8 01 00 00       	push   $0x1c8
f0103483:	68 ce 5d 10 f0       	push   $0xf0105dce
f0103488:	e8 bb cc ff ff       	call   f0100148 <_panic>
		panic("pa2page called with invalid pa");
f010348d:	83 ec 04             	sub    $0x4,%esp
f0103490:	68 c8 53 10 f0       	push   $0xf01053c8
f0103495:	6a 4f                	push   $0x4f
f0103497:	68 4d 5a 10 f0       	push   $0xf0105a4d
f010349c:	e8 a7 cc ff ff       	call   f0100148 <_panic>

f01034a1 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f01034a1:	55                   	push   %ebp
f01034a2:	89 e5                	mov    %esp,%ebp
f01034a4:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f01034a7:	ff 75 08             	pushl  0x8(%ebp)
f01034aa:	e8 25 fe ff ff       	call   f01032d4 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01034af:	c7 04 24 98 5d 10 f0 	movl   $0xf0105d98,(%esp)
f01034b6:	e8 38 01 00 00       	call   f01035f3 <cprintf>
f01034bb:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f01034be:	83 ec 0c             	sub    $0xc,%esp
f01034c1:	6a 00                	push   $0x0
f01034c3:	e8 bb d7 ff ff       	call   f0100c83 <monitor>
f01034c8:	83 c4 10             	add    $0x10,%esp
f01034cb:	eb f1                	jmp    f01034be <env_destroy+0x1d>

f01034cd <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01034cd:	55                   	push   %ebp
f01034ce:	89 e5                	mov    %esp,%ebp
f01034d0:	53                   	push   %ebx
f01034d1:	83 ec 0c             	sub    $0xc,%esp
f01034d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("tf->tf_eip = %x\n", tf->tf_eip);
f01034d7:	ff 73 30             	pushl  0x30(%ebx)
f01034da:	68 53 5e 10 f0       	push   $0xf0105e53
f01034df:	e8 0f 01 00 00       	call   f01035f3 <cprintf>
	cprintf("tf->tf_cs = %x\n", tf->tf_cs);
f01034e4:	83 c4 08             	add    $0x8,%esp
f01034e7:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01034eb:	50                   	push   %eax
f01034ec:	68 64 5e 10 f0       	push   $0xf0105e64
f01034f1:	e8 fd 00 00 00       	call   f01035f3 <cprintf>
	cprintf("First line = %x\n", *(int*)(0x800020));
f01034f6:	83 c4 08             	add    $0x8,%esp
f01034f9:	ff 35 20 00 80 00    	pushl  0x800020
f01034ff:	68 74 5e 10 f0       	push   $0xf0105e74
f0103504:	e8 ea 00 00 00       	call   f01035f3 <cprintf>
	asm volatile(
f0103509:	89 dc                	mov    %ebx,%esp
f010350b:	61                   	popa   
f010350c:	07                   	pop    %es
f010350d:	1f                   	pop    %ds
f010350e:	83 c4 08             	add    $0x8,%esp
f0103511:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103512:	83 c4 0c             	add    $0xc,%esp
f0103515:	68 85 5e 10 f0       	push   $0xf0105e85
f010351a:	68 f4 01 00 00       	push   $0x1f4
f010351f:	68 ce 5d 10 f0       	push   $0xf0105dce
f0103524:	e8 1f cc ff ff       	call   f0100148 <_panic>

f0103529 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103529:	55                   	push   %ebp
f010352a:	89 e5                	mov    %esp,%ebp
f010352c:	83 ec 08             	sub    $0x8,%esp
f010352f:	8b 45 08             	mov    0x8(%ebp),%eax
	// Hint: This function loads the new environment's state from
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	if (curenv && curenv->env_status == ENV_RUNNING) {
f0103532:	8b 15 24 51 1b f0    	mov    0xf01b5124,%edx
f0103538:	85 d2                	test   %edx,%edx
f010353a:	74 06                	je     f0103542 <env_run+0x19>
f010353c:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0103540:	74 2f                	je     f0103571 <env_run+0x48>
		curenv->env_status = ENV_RUNNABLE;
	}
	// mon_backtrace(0, 0, 0);
	curenv = e;
f0103542:	a3 24 51 1b f0       	mov    %eax,0xf01b5124
	curenv->env_status = ENV_RUNNING;
f0103547:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f010354e:	ff 40 58             	incl   0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f0103551:	8b 50 5c             	mov    0x5c(%eax),%edx
	if ((uint32_t)kva < KERNBASE)
f0103554:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010355a:	77 1e                	ja     f010357a <env_run+0x51>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010355c:	52                   	push   %edx
f010355d:	68 a4 53 10 f0       	push   $0xf01053a4
f0103562:	68 18 02 00 00       	push   $0x218
f0103567:	68 ce 5d 10 f0       	push   $0xf0105dce
f010356c:	e8 d7 cb ff ff       	call   f0100148 <_panic>
		curenv->env_status = ENV_RUNNABLE;
f0103571:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
f0103578:	eb c8                	jmp    f0103542 <env_run+0x19>
	return (physaddr_t)kva - KERNBASE;
f010357a:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103580:	0f 22 da             	mov    %edx,%cr3
	env_pop_tf(&curenv->env_tf);  // Does not return.
f0103583:	83 ec 0c             	sub    $0xc,%esp
f0103586:	50                   	push   %eax
f0103587:	e8 41 ff ff ff       	call   f01034cd <env_pop_tf>

f010358c <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010358c:	55                   	push   %ebp
f010358d:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010358f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103592:	ba 70 00 00 00       	mov    $0x70,%edx
f0103597:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103598:	ba 71 00 00 00       	mov    $0x71,%edx
f010359d:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010359e:	0f b6 c0             	movzbl %al,%eax
}
f01035a1:	5d                   	pop    %ebp
f01035a2:	c3                   	ret    

f01035a3 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01035a3:	55                   	push   %ebp
f01035a4:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01035a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01035a9:	ba 70 00 00 00       	mov    $0x70,%edx
f01035ae:	ee                   	out    %al,(%dx)
f01035af:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035b2:	ba 71 00 00 00       	mov    $0x71,%edx
f01035b7:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01035b8:	5d                   	pop    %ebp
f01035b9:	c3                   	ret    

f01035ba <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01035ba:	55                   	push   %ebp
f01035bb:	89 e5                	mov    %esp,%ebp
f01035bd:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01035c0:	ff 75 08             	pushl  0x8(%ebp)
f01035c3:	e8 d3 d0 ff ff       	call   f010069b <cputchar>
	*cnt++;
}
f01035c8:	83 c4 10             	add    $0x10,%esp
f01035cb:	c9                   	leave  
f01035cc:	c3                   	ret    

f01035cd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01035cd:	55                   	push   %ebp
f01035ce:	89 e5                	mov    %esp,%ebp
f01035d0:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01035d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01035da:	ff 75 0c             	pushl  0xc(%ebp)
f01035dd:	ff 75 08             	pushl  0x8(%ebp)
f01035e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01035e3:	50                   	push   %eax
f01035e4:	68 ba 35 10 f0       	push   $0xf01035ba
f01035e9:	e8 10 08 00 00       	call   f0103dfe <vprintfmt>
	return cnt;
}
f01035ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01035f1:	c9                   	leave  
f01035f2:	c3                   	ret    

f01035f3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01035f3:	55                   	push   %ebp
f01035f4:	89 e5                	mov    %esp,%ebp
f01035f6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01035f9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01035fc:	50                   	push   %eax
f01035fd:	ff 75 08             	pushl  0x8(%ebp)
f0103600:	e8 c8 ff ff ff       	call   f01035cd <vcprintf>
	va_end(ap);

	return cnt;
}
f0103605:	c9                   	leave  
f0103606:	c3                   	ret    

f0103607 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103607:	55                   	push   %ebp
f0103608:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f010360a:	b8 60 59 1b f0       	mov    $0xf01b5960,%eax
f010360f:	c7 05 64 59 1b f0 00 	movl   $0xf0000000,0xf01b5964
f0103616:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103619:	66 c7 05 68 59 1b f0 	movw   $0x10,0xf01b5968
f0103620:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f0103622:	66 c7 05 c6 59 1b f0 	movw   $0x68,0xf01b59c6
f0103629:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f010362b:	66 c7 05 48 c3 11 f0 	movw   $0x67,0xf011c348
f0103632:	67 00 
f0103634:	66 a3 4a c3 11 f0    	mov    %ax,0xf011c34a
f010363a:	89 c2                	mov    %eax,%edx
f010363c:	c1 ea 10             	shr    $0x10,%edx
f010363f:	88 15 4c c3 11 f0    	mov    %dl,0xf011c34c
f0103645:	c6 05 4e c3 11 f0 40 	movb   $0x40,0xf011c34e
f010364c:	c1 e8 18             	shr    $0x18,%eax
f010364f:	a2 4f c3 11 f0       	mov    %al,0xf011c34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103654:	c6 05 4d c3 11 f0 89 	movb   $0x89,0xf011c34d
	asm volatile("ltr %0" : : "r" (sel));
f010365b:	b8 28 00 00 00       	mov    $0x28,%eax
f0103660:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f0103663:	b8 50 c3 11 f0       	mov    $0xf011c350,%eax
f0103668:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f010366b:	5d                   	pop    %ebp
f010366c:	c3                   	ret    

f010366d <trap_init>:
{
f010366d:	55                   	push   %ebp
f010366e:	89 e5                	mov    %esp,%ebp
	trap_init_percpu();
f0103670:	e8 92 ff ff ff       	call   f0103607 <trap_init_percpu>
}
f0103675:	5d                   	pop    %ebp
f0103676:	c3                   	ret    

f0103677 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103677:	55                   	push   %ebp
f0103678:	89 e5                	mov    %esp,%ebp
f010367a:	53                   	push   %ebx
f010367b:	83 ec 0c             	sub    $0xc,%esp
f010367e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103681:	ff 33                	pushl  (%ebx)
f0103683:	68 91 5e 10 f0       	push   $0xf0105e91
f0103688:	e8 66 ff ff ff       	call   f01035f3 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010368d:	83 c4 08             	add    $0x8,%esp
f0103690:	ff 73 04             	pushl  0x4(%ebx)
f0103693:	68 a0 5e 10 f0       	push   $0xf0105ea0
f0103698:	e8 56 ff ff ff       	call   f01035f3 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010369d:	83 c4 08             	add    $0x8,%esp
f01036a0:	ff 73 08             	pushl  0x8(%ebx)
f01036a3:	68 af 5e 10 f0       	push   $0xf0105eaf
f01036a8:	e8 46 ff ff ff       	call   f01035f3 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01036ad:	83 c4 08             	add    $0x8,%esp
f01036b0:	ff 73 0c             	pushl  0xc(%ebx)
f01036b3:	68 be 5e 10 f0       	push   $0xf0105ebe
f01036b8:	e8 36 ff ff ff       	call   f01035f3 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01036bd:	83 c4 08             	add    $0x8,%esp
f01036c0:	ff 73 10             	pushl  0x10(%ebx)
f01036c3:	68 cd 5e 10 f0       	push   $0xf0105ecd
f01036c8:	e8 26 ff ff ff       	call   f01035f3 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01036cd:	83 c4 08             	add    $0x8,%esp
f01036d0:	ff 73 14             	pushl  0x14(%ebx)
f01036d3:	68 dc 5e 10 f0       	push   $0xf0105edc
f01036d8:	e8 16 ff ff ff       	call   f01035f3 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01036dd:	83 c4 08             	add    $0x8,%esp
f01036e0:	ff 73 18             	pushl  0x18(%ebx)
f01036e3:	68 eb 5e 10 f0       	push   $0xf0105eeb
f01036e8:	e8 06 ff ff ff       	call   f01035f3 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01036ed:	83 c4 08             	add    $0x8,%esp
f01036f0:	ff 73 1c             	pushl  0x1c(%ebx)
f01036f3:	68 fa 5e 10 f0       	push   $0xf0105efa
f01036f8:	e8 f6 fe ff ff       	call   f01035f3 <cprintf>
}
f01036fd:	83 c4 10             	add    $0x10,%esp
f0103700:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103703:	c9                   	leave  
f0103704:	c3                   	ret    

f0103705 <print_trapframe>:
{
f0103705:	55                   	push   %ebp
f0103706:	89 e5                	mov    %esp,%ebp
f0103708:	53                   	push   %ebx
f0103709:	83 ec 0c             	sub    $0xc,%esp
f010370c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f010370f:	53                   	push   %ebx
f0103710:	68 30 60 10 f0       	push   $0xf0106030
f0103715:	e8 d9 fe ff ff       	call   f01035f3 <cprintf>
	print_regs(&tf->tf_regs);
f010371a:	89 1c 24             	mov    %ebx,(%esp)
f010371d:	e8 55 ff ff ff       	call   f0103677 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103722:	83 c4 08             	add    $0x8,%esp
f0103725:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103729:	50                   	push   %eax
f010372a:	68 4b 5f 10 f0       	push   $0xf0105f4b
f010372f:	e8 bf fe ff ff       	call   f01035f3 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103734:	83 c4 08             	add    $0x8,%esp
f0103737:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010373b:	50                   	push   %eax
f010373c:	68 5e 5f 10 f0       	push   $0xf0105f5e
f0103741:	e8 ad fe ff ff       	call   f01035f3 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103746:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0103749:	83 c4 10             	add    $0x10,%esp
f010374c:	83 f8 13             	cmp    $0x13,%eax
f010374f:	76 10                	jbe    f0103761 <print_trapframe+0x5c>
	if (trapno == T_SYSCALL)
f0103751:	83 f8 30             	cmp    $0x30,%eax
f0103754:	0f 84 c3 00 00 00    	je     f010381d <print_trapframe+0x118>
	return "(unknown trap)";
f010375a:	ba 15 5f 10 f0       	mov    $0xf0105f15,%edx
f010375f:	eb 07                	jmp    f0103768 <print_trapframe+0x63>
		return excnames[trapno];
f0103761:	8b 14 85 00 62 10 f0 	mov    -0xfef9e00(,%eax,4),%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103768:	83 ec 04             	sub    $0x4,%esp
f010376b:	52                   	push   %edx
f010376c:	50                   	push   %eax
f010376d:	68 71 5f 10 f0       	push   $0xf0105f71
f0103772:	e8 7c fe ff ff       	call   f01035f3 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103777:	83 c4 10             	add    $0x10,%esp
f010377a:	39 1d 40 59 1b f0    	cmp    %ebx,0xf01b5940
f0103780:	0f 84 a1 00 00 00    	je     f0103827 <print_trapframe+0x122>
	cprintf("  err  0x%08x", tf->tf_err);
f0103786:	83 ec 08             	sub    $0x8,%esp
f0103789:	ff 73 2c             	pushl  0x2c(%ebx)
f010378c:	68 92 5f 10 f0       	push   $0xf0105f92
f0103791:	e8 5d fe ff ff       	call   f01035f3 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103796:	83 c4 10             	add    $0x10,%esp
f0103799:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010379d:	0f 85 c5 00 00 00    	jne    f0103868 <print_trapframe+0x163>
			tf->tf_err & 1 ? "protection" : "not-present");
f01037a3:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f01037a6:	a8 01                	test   $0x1,%al
f01037a8:	0f 85 9c 00 00 00    	jne    f010384a <print_trapframe+0x145>
f01037ae:	b9 2f 5f 10 f0       	mov    $0xf0105f2f,%ecx
f01037b3:	a8 02                	test   $0x2,%al
f01037b5:	0f 85 99 00 00 00    	jne    f0103854 <print_trapframe+0x14f>
f01037bb:	ba 41 5f 10 f0       	mov    $0xf0105f41,%edx
f01037c0:	a8 04                	test   $0x4,%al
f01037c2:	0f 85 96 00 00 00    	jne    f010385e <print_trapframe+0x159>
f01037c8:	b8 5b 60 10 f0       	mov    $0xf010605b,%eax
f01037cd:	51                   	push   %ecx
f01037ce:	52                   	push   %edx
f01037cf:	50                   	push   %eax
f01037d0:	68 a0 5f 10 f0       	push   $0xf0105fa0
f01037d5:	e8 19 fe ff ff       	call   f01035f3 <cprintf>
f01037da:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01037dd:	83 ec 08             	sub    $0x8,%esp
f01037e0:	ff 73 30             	pushl  0x30(%ebx)
f01037e3:	68 af 5f 10 f0       	push   $0xf0105faf
f01037e8:	e8 06 fe ff ff       	call   f01035f3 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01037ed:	83 c4 08             	add    $0x8,%esp
f01037f0:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01037f4:	50                   	push   %eax
f01037f5:	68 be 5f 10 f0       	push   $0xf0105fbe
f01037fa:	e8 f4 fd ff ff       	call   f01035f3 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01037ff:	83 c4 08             	add    $0x8,%esp
f0103802:	ff 73 38             	pushl  0x38(%ebx)
f0103805:	68 d1 5f 10 f0       	push   $0xf0105fd1
f010380a:	e8 e4 fd ff ff       	call   f01035f3 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010380f:	83 c4 10             	add    $0x10,%esp
f0103812:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103816:	75 65                	jne    f010387d <print_trapframe+0x178>
}
f0103818:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010381b:	c9                   	leave  
f010381c:	c3                   	ret    
		return "System call";
f010381d:	ba 09 5f 10 f0       	mov    $0xf0105f09,%edx
f0103822:	e9 41 ff ff ff       	jmp    f0103768 <print_trapframe+0x63>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103827:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010382b:	0f 85 55 ff ff ff    	jne    f0103786 <print_trapframe+0x81>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103831:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103834:	83 ec 08             	sub    $0x8,%esp
f0103837:	50                   	push   %eax
f0103838:	68 83 5f 10 f0       	push   $0xf0105f83
f010383d:	e8 b1 fd ff ff       	call   f01035f3 <cprintf>
f0103842:	83 c4 10             	add    $0x10,%esp
f0103845:	e9 3c ff ff ff       	jmp    f0103786 <print_trapframe+0x81>
		cprintf(" [%s, %s, %s]\n",
f010384a:	b9 24 5f 10 f0       	mov    $0xf0105f24,%ecx
f010384f:	e9 5f ff ff ff       	jmp    f01037b3 <print_trapframe+0xae>
f0103854:	ba 3b 5f 10 f0       	mov    $0xf0105f3b,%edx
f0103859:	e9 62 ff ff ff       	jmp    f01037c0 <print_trapframe+0xbb>
f010385e:	b8 46 5f 10 f0       	mov    $0xf0105f46,%eax
f0103863:	e9 65 ff ff ff       	jmp    f01037cd <print_trapframe+0xc8>
		cprintf("\n");
f0103868:	83 ec 0c             	sub    $0xc,%esp
f010386b:	68 3b 4e 10 f0       	push   $0xf0104e3b
f0103870:	e8 7e fd ff ff       	call   f01035f3 <cprintf>
f0103875:	83 c4 10             	add    $0x10,%esp
f0103878:	e9 60 ff ff ff       	jmp    f01037dd <print_trapframe+0xd8>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010387d:	83 ec 08             	sub    $0x8,%esp
f0103880:	ff 73 3c             	pushl  0x3c(%ebx)
f0103883:	68 e0 5f 10 f0       	push   $0xf0105fe0
f0103888:	e8 66 fd ff ff       	call   f01035f3 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010388d:	83 c4 08             	add    $0x8,%esp
f0103890:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103894:	50                   	push   %eax
f0103895:	68 ef 5f 10 f0       	push   $0xf0105fef
f010389a:	e8 54 fd ff ff       	call   f01035f3 <cprintf>
f010389f:	83 c4 10             	add    $0x10,%esp
}
f01038a2:	e9 71 ff ff ff       	jmp    f0103818 <print_trapframe+0x113>

f01038a7 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01038a7:	55                   	push   %ebp
f01038a8:	89 e5                	mov    %esp,%ebp
f01038aa:	57                   	push   %edi
f01038ab:	56                   	push   %esi
f01038ac:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01038af:	fc                   	cld    
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01038b0:	9c                   	pushf  
f01038b1:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01038b2:	f6 c4 02             	test   $0x2,%ah
f01038b5:	74 19                	je     f01038d0 <trap+0x29>
f01038b7:	68 02 60 10 f0       	push   $0xf0106002
f01038bc:	68 67 5a 10 f0       	push   $0xf0105a67
f01038c1:	68 a8 00 00 00       	push   $0xa8
f01038c6:	68 1b 60 10 f0       	push   $0xf010601b
f01038cb:	e8 78 c8 ff ff       	call   f0100148 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f01038d0:	83 ec 08             	sub    $0x8,%esp
f01038d3:	56                   	push   %esi
f01038d4:	68 27 60 10 f0       	push   $0xf0106027
f01038d9:	e8 15 fd ff ff       	call   f01035f3 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f01038de:	66 8b 46 34          	mov    0x34(%esi),%ax
f01038e2:	83 e0 03             	and    $0x3,%eax
f01038e5:	83 c4 10             	add    $0x10,%esp
f01038e8:	66 83 f8 03          	cmp    $0x3,%ax
f01038ec:	75 18                	jne    f0103906 <trap+0x5f>
		// Trapped from user mode.
		assert(curenv);
f01038ee:	a1 24 51 1b f0       	mov    0xf01b5124,%eax
f01038f3:	85 c0                	test   %eax,%eax
f01038f5:	74 61                	je     f0103958 <trap+0xb1>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01038f7:	b9 11 00 00 00       	mov    $0x11,%ecx
f01038fc:	89 c7                	mov    %eax,%edi
f01038fe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103900:	8b 35 24 51 1b f0    	mov    0xf01b5124,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103906:	89 35 40 59 1b f0    	mov    %esi,0xf01b5940
	print_trapframe(tf);
f010390c:	83 ec 0c             	sub    $0xc,%esp
f010390f:	56                   	push   %esi
f0103910:	e8 f0 fd ff ff       	call   f0103705 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103915:	83 c4 10             	add    $0x10,%esp
f0103918:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010391d:	74 52                	je     f0103971 <trap+0xca>
		env_destroy(curenv);
f010391f:	83 ec 0c             	sub    $0xc,%esp
f0103922:	ff 35 24 51 1b f0    	pushl  0xf01b5124
f0103928:	e8 74 fb ff ff       	call   f01034a1 <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f010392d:	a1 24 51 1b f0       	mov    0xf01b5124,%eax
f0103932:	83 c4 10             	add    $0x10,%esp
f0103935:	85 c0                	test   %eax,%eax
f0103937:	74 06                	je     f010393f <trap+0x98>
f0103939:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010393d:	74 49                	je     f0103988 <trap+0xe1>
f010393f:	68 a8 61 10 f0       	push   $0xf01061a8
f0103944:	68 67 5a 10 f0       	push   $0xf0105a67
f0103949:	68 c0 00 00 00       	push   $0xc0
f010394e:	68 1b 60 10 f0       	push   $0xf010601b
f0103953:	e8 f0 c7 ff ff       	call   f0100148 <_panic>
		assert(curenv);
f0103958:	68 42 60 10 f0       	push   $0xf0106042
f010395d:	68 67 5a 10 f0       	push   $0xf0105a67
f0103962:	68 ae 00 00 00       	push   $0xae
f0103967:	68 1b 60 10 f0       	push   $0xf010601b
f010396c:	e8 d7 c7 ff ff       	call   f0100148 <_panic>
		panic("unhandled trap in kernel");
f0103971:	83 ec 04             	sub    $0x4,%esp
f0103974:	68 49 60 10 f0       	push   $0xf0106049
f0103979:	68 97 00 00 00       	push   $0x97
f010397e:	68 1b 60 10 f0       	push   $0xf010601b
f0103983:	e8 c0 c7 ff ff       	call   f0100148 <_panic>
	env_run(curenv);
f0103988:	83 ec 0c             	sub    $0xc,%esp
f010398b:	50                   	push   %eax
f010398c:	e8 98 fb ff ff       	call   f0103529 <env_run>

f0103991 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103991:	55                   	push   %ebp
f0103992:	89 e5                	mov    %esp,%ebp
f0103994:	53                   	push   %ebx
f0103995:	83 ec 04             	sub    $0x4,%esp
f0103998:	8b 5d 08             	mov    0x8(%ebp),%ebx
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010399b:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010399e:	ff 73 30             	pushl  0x30(%ebx)
f01039a1:	50                   	push   %eax
f01039a2:	a1 24 51 1b f0       	mov    0xf01b5124,%eax
f01039a7:	ff 70 48             	pushl  0x48(%eax)
f01039aa:	68 d4 61 10 f0       	push   $0xf01061d4
f01039af:	e8 3f fc ff ff       	call   f01035f3 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01039b4:	89 1c 24             	mov    %ebx,(%esp)
f01039b7:	e8 49 fd ff ff       	call   f0103705 <print_trapframe>
	env_destroy(curenv);
f01039bc:	83 c4 04             	add    $0x4,%esp
f01039bf:	ff 35 24 51 1b f0    	pushl  0xf01b5124
f01039c5:	e8 d7 fa ff ff       	call   f01034a1 <env_destroy>
}
f01039ca:	83 c4 10             	add    $0x10,%esp
f01039cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01039d0:	c9                   	leave  
f01039d1:	c3                   	ret    

f01039d2 <syscall>:
f01039d2:	55                   	push   %ebp
f01039d3:	89 e5                	mov    %esp,%ebp
f01039d5:	83 ec 0c             	sub    $0xc,%esp
f01039d8:	68 50 62 10 f0       	push   $0xf0106250
f01039dd:	6a 49                	push   $0x49
f01039df:	68 68 62 10 f0       	push   $0xf0106268
f01039e4:	e8 5f c7 ff ff       	call   f0100148 <_panic>

f01039e9 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01039e9:	55                   	push   %ebp
f01039ea:	89 e5                	mov    %esp,%ebp
f01039ec:	57                   	push   %edi
f01039ed:	56                   	push   %esi
f01039ee:	53                   	push   %ebx
f01039ef:	83 ec 14             	sub    $0x14,%esp
f01039f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01039f5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01039f8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01039fb:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01039fe:	8b 32                	mov    (%edx),%esi
f0103a00:	8b 01                	mov    (%ecx),%eax
f0103a02:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103a05:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103a0c:	eb 2f                	jmp    f0103a3d <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0103a0e:	48                   	dec    %eax
		while (m >= l && stabs[m].n_type != type)
f0103a0f:	39 c6                	cmp    %eax,%esi
f0103a11:	7f 4d                	jg     f0103a60 <stab_binsearch+0x77>
f0103a13:	0f b6 0a             	movzbl (%edx),%ecx
f0103a16:	83 ea 0c             	sub    $0xc,%edx
f0103a19:	39 f9                	cmp    %edi,%ecx
f0103a1b:	75 f1                	jne    f0103a0e <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103a1d:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103a20:	01 c2                	add    %eax,%edx
f0103a22:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103a25:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103a29:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103a2c:	73 37                	jae    f0103a65 <stab_binsearch+0x7c>
			*region_left = m;
f0103a2e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103a31:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0103a33:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0103a36:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0103a3d:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0103a40:	7f 4d                	jg     f0103a8f <stab_binsearch+0xa6>
		int true_m = (l + r) / 2, m = true_m;
f0103a42:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103a45:	01 f0                	add    %esi,%eax
f0103a47:	89 c3                	mov    %eax,%ebx
f0103a49:	c1 eb 1f             	shr    $0x1f,%ebx
f0103a4c:	01 c3                	add    %eax,%ebx
f0103a4e:	d1 fb                	sar    %ebx
f0103a50:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
f0103a53:	01 d8                	add    %ebx,%eax
f0103a55:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103a58:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0103a5c:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0103a5e:	eb af                	jmp    f0103a0f <stab_binsearch+0x26>
			l = true_m + 1;
f0103a60:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0103a63:	eb d8                	jmp    f0103a3d <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0103a65:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103a68:	76 12                	jbe    f0103a7c <stab_binsearch+0x93>
			*region_right = m - 1;
f0103a6a:	48                   	dec    %eax
f0103a6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103a6e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103a71:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0103a73:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103a7a:	eb c1                	jmp    f0103a3d <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103a7c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103a7f:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0103a81:	ff 45 0c             	incl   0xc(%ebp)
f0103a84:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0103a86:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103a8d:	eb ae                	jmp    f0103a3d <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0103a8f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103a93:	74 18                	je     f0103aad <stab_binsearch+0xc4>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103a95:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103a98:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103a9a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103a9d:	8b 0e                	mov    (%esi),%ecx
f0103a9f:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103aa2:	01 c2                	add    %eax,%edx
f0103aa4:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0103aa7:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0103aab:	eb 0e                	jmp    f0103abb <stab_binsearch+0xd2>
		*region_right = *region_left - 1;
f0103aad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103ab0:	8b 00                	mov    (%eax),%eax
f0103ab2:	48                   	dec    %eax
f0103ab3:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103ab6:	89 07                	mov    %eax,(%edi)
f0103ab8:	eb 14                	jmp    f0103ace <stab_binsearch+0xe5>
		     l--)
f0103aba:	48                   	dec    %eax
		for (l = *region_right;
f0103abb:	39 c1                	cmp    %eax,%ecx
f0103abd:	7d 0a                	jge    f0103ac9 <stab_binsearch+0xe0>
		     l > *region_left && stabs[l].n_type != type;
f0103abf:	0f b6 1a             	movzbl (%edx),%ebx
f0103ac2:	83 ea 0c             	sub    $0xc,%edx
f0103ac5:	39 fb                	cmp    %edi,%ebx
f0103ac7:	75 f1                	jne    f0103aba <stab_binsearch+0xd1>
			/* do nothing */;
		*region_left = l;
f0103ac9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103acc:	89 07                	mov    %eax,(%edi)
	}
}
f0103ace:	83 c4 14             	add    $0x14,%esp
f0103ad1:	5b                   	pop    %ebx
f0103ad2:	5e                   	pop    %esi
f0103ad3:	5f                   	pop    %edi
f0103ad4:	5d                   	pop    %ebp
f0103ad5:	c3                   	ret    

f0103ad6 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103ad6:	55                   	push   %ebp
f0103ad7:	89 e5                	mov    %esp,%ebp
f0103ad9:	57                   	push   %edi
f0103ada:	56                   	push   %esi
f0103adb:	53                   	push   %ebx
f0103adc:	83 ec 4c             	sub    $0x4c,%esp
f0103adf:	8b 75 08             	mov    0x8(%ebp),%esi
f0103ae2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103ae5:	c7 03 77 62 10 f0    	movl   $0xf0106277,(%ebx)
	info->eip_line = 0;
f0103aeb:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103af2:	c7 43 08 77 62 10 f0 	movl   $0xf0106277,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103af9:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103b00:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103b03:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103b0a:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103b10:	77 1e                	ja     f0103b30 <debuginfo_eip+0x5a>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0103b12:	8b 3d 00 00 20 00    	mov    0x200000,%edi
		stab_end = usd->stab_end;
f0103b18:	8b 15 04 00 20 00    	mov    0x200004,%edx
		stabstr = usd->stabstr;
f0103b1e:	a1 08 00 20 00       	mov    0x200008,%eax
f0103b23:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0103b26:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0103b2b:	89 45 b8             	mov    %eax,-0x48(%ebp)
f0103b2e:	eb 18                	jmp    f0103b48 <debuginfo_eip+0x72>
		stabstr_end = __STABSTR_END__;
f0103b30:	c7 45 b8 3b 1f 11 f0 	movl   $0xf0111f3b,-0x48(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0103b37:	c7 45 b4 b9 f3 10 f0 	movl   $0xf010f3b9,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0103b3e:	ba b8 f3 10 f0       	mov    $0xf010f3b8,%edx
		stabs = __STAB_BEGIN__;
f0103b43:	bf 90 64 10 f0       	mov    $0xf0106490,%edi
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103b48:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0103b4b:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
f0103b4e:	0f 83 9b 01 00 00    	jae    f0103cef <debuginfo_eip+0x219>
f0103b54:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0103b58:	0f 85 98 01 00 00    	jne    f0103cf6 <debuginfo_eip+0x220>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103b5e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103b65:	29 fa                	sub    %edi,%edx
f0103b67:	c1 fa 02             	sar    $0x2,%edx
f0103b6a:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0103b6d:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0103b70:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0103b73:	89 c1                	mov    %eax,%ecx
f0103b75:	c1 e1 08             	shl    $0x8,%ecx
f0103b78:	01 c8                	add    %ecx,%eax
f0103b7a:	89 c1                	mov    %eax,%ecx
f0103b7c:	c1 e1 10             	shl    $0x10,%ecx
f0103b7f:	01 c8                	add    %ecx,%eax
f0103b81:	01 c0                	add    %eax,%eax
f0103b83:	8d 44 02 ff          	lea    -0x1(%edx,%eax,1),%eax
f0103b87:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103b8a:	56                   	push   %esi
f0103b8b:	6a 64                	push   $0x64
f0103b8d:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103b90:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103b93:	89 f8                	mov    %edi,%eax
f0103b95:	e8 4f fe ff ff       	call   f01039e9 <stab_binsearch>
	if (lfile == 0)
f0103b9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b9d:	83 c4 08             	add    $0x8,%esp
f0103ba0:	85 c0                	test   %eax,%eax
f0103ba2:	0f 84 55 01 00 00    	je     f0103cfd <debuginfo_eip+0x227>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103ba8:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103bab:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103bae:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103bb1:	56                   	push   %esi
f0103bb2:	6a 24                	push   $0x24
f0103bb4:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103bb7:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103bba:	89 f8                	mov    %edi,%eax
f0103bbc:	e8 28 fe ff ff       	call   f01039e9 <stab_binsearch>

	if (lfun <= rfun) {
f0103bc1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103bc4:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0103bc7:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0103bca:	83 c4 08             	add    $0x8,%esp
f0103bcd:	39 c8                	cmp    %ecx,%eax
f0103bcf:	0f 8f 80 00 00 00    	jg     f0103c55 <debuginfo_eip+0x17f>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103bd5:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103bd8:	01 c2                	add    %eax,%edx
f0103bda:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103bdd:	89 55 c0             	mov    %edx,-0x40(%ebp)
f0103be0:	8b 0a                	mov    (%edx),%ecx
f0103be2:	89 4d bc             	mov    %ecx,-0x44(%ebp)
f0103be5:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0103be8:	2b 55 b4             	sub    -0x4c(%ebp),%edx
f0103beb:	39 d1                	cmp    %edx,%ecx
f0103bed:	73 06                	jae    f0103bf5 <debuginfo_eip+0x11f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103bef:	03 4d b4             	add    -0x4c(%ebp),%ecx
f0103bf2:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103bf5:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0103bf8:	8b 51 08             	mov    0x8(%ecx),%edx
f0103bfb:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103bfe:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0103c00:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103c03:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103c06:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103c09:	83 ec 08             	sub    $0x8,%esp
f0103c0c:	6a 3a                	push   $0x3a
f0103c0e:	ff 73 08             	pushl  0x8(%ebx)
f0103c11:	e8 e9 08 00 00       	call   f01044ff <strfind>
f0103c16:	2b 43 08             	sub    0x8(%ebx),%eax
f0103c19:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// N_SLINE represents text segment
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103c1c:	83 c4 08             	add    $0x8,%esp
f0103c1f:	56                   	push   %esi
f0103c20:	6a 44                	push   $0x44
f0103c22:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103c25:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103c28:	89 f8                	mov    %edi,%eax
f0103c2a:	e8 ba fd ff ff       	call   f01039e9 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0103c2f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103c32:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103c35:	01 c2                	add    %eax,%edx
f0103c37:	c1 e2 02             	shl    $0x2,%edx
f0103c3a:	0f b7 4c 17 06       	movzwl 0x6(%edi,%edx,1),%ecx
f0103c3f:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103c42:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103c45:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0103c48:	8d 54 17 04          	lea    0x4(%edi,%edx,1),%edx
f0103c4c:	83 c4 10             	add    $0x10,%esp
f0103c4f:	c6 45 c0 00          	movb   $0x0,-0x40(%ebp)
f0103c53:	eb 19                	jmp    f0103c6e <debuginfo_eip+0x198>
		info->eip_fn_addr = addr;
f0103c55:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0103c58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103c5b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103c5e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103c61:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103c64:	eb a3                	jmp    f0103c09 <debuginfo_eip+0x133>
f0103c66:	48                   	dec    %eax
f0103c67:	83 ea 0c             	sub    $0xc,%edx
f0103c6a:	c6 45 c0 01          	movb   $0x1,-0x40(%ebp)
f0103c6e:	89 45 bc             	mov    %eax,-0x44(%ebp)
	while (lline >= lfile
f0103c71:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0103c74:	7f 40                	jg     f0103cb6 <debuginfo_eip+0x1e0>
	       && stabs[lline].n_type != N_SOL
f0103c76:	8a 0a                	mov    (%edx),%cl
f0103c78:	80 f9 84             	cmp    $0x84,%cl
f0103c7b:	74 19                	je     f0103c96 <debuginfo_eip+0x1c0>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103c7d:	80 f9 64             	cmp    $0x64,%cl
f0103c80:	75 e4                	jne    f0103c66 <debuginfo_eip+0x190>
f0103c82:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0103c86:	74 de                	je     f0103c66 <debuginfo_eip+0x190>
f0103c88:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f0103c8c:	74 0e                	je     f0103c9c <debuginfo_eip+0x1c6>
f0103c8e:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0103c91:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0103c94:	eb 06                	jmp    f0103c9c <debuginfo_eip+0x1c6>
f0103c96:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f0103c9a:	75 35                	jne    f0103cd1 <debuginfo_eip+0x1fb>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103c9c:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103c9f:	01 d0                	add    %edx,%eax
f0103ca1:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103ca4:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0103ca7:	8b 75 b4             	mov    -0x4c(%ebp),%esi
f0103caa:	29 f0                	sub    %esi,%eax
f0103cac:	39 c2                	cmp    %eax,%edx
f0103cae:	73 06                	jae    f0103cb6 <debuginfo_eip+0x1e0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103cb0:	89 f0                	mov    %esi,%eax
f0103cb2:	01 d0                	add    %edx,%eax
f0103cb4:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103cb6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103cb9:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0103cbc:	39 f2                	cmp    %esi,%edx
f0103cbe:	7d 44                	jge    f0103d04 <debuginfo_eip+0x22e>
		for (lline = lfun + 1;
f0103cc0:	42                   	inc    %edx
f0103cc1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103cc4:	89 d0                	mov    %edx,%eax
f0103cc6:	8d 0c 12             	lea    (%edx,%edx,1),%ecx
f0103cc9:	01 ca                	add    %ecx,%edx
f0103ccb:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0103ccf:	eb 08                	jmp    f0103cd9 <debuginfo_eip+0x203>
f0103cd1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103cd4:	eb c6                	jmp    f0103c9c <debuginfo_eip+0x1c6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103cd6:	ff 43 14             	incl   0x14(%ebx)
		for (lline = lfun + 1;
f0103cd9:	39 c6                	cmp    %eax,%esi
f0103cdb:	7e 34                	jle    f0103d11 <debuginfo_eip+0x23b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103cdd:	8a 0a                	mov    (%edx),%cl
f0103cdf:	40                   	inc    %eax
f0103ce0:	83 c2 0c             	add    $0xc,%edx
f0103ce3:	80 f9 a0             	cmp    $0xa0,%cl
f0103ce6:	74 ee                	je     f0103cd6 <debuginfo_eip+0x200>

	return 0;
f0103ce8:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ced:	eb 1a                	jmp    f0103d09 <debuginfo_eip+0x233>
		return -1;
f0103cef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103cf4:	eb 13                	jmp    f0103d09 <debuginfo_eip+0x233>
f0103cf6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103cfb:	eb 0c                	jmp    f0103d09 <debuginfo_eip+0x233>
		return -1;
f0103cfd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103d02:	eb 05                	jmp    f0103d09 <debuginfo_eip+0x233>
	return 0;
f0103d04:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103d09:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103d0c:	5b                   	pop    %ebx
f0103d0d:	5e                   	pop    %esi
f0103d0e:	5f                   	pop    %edi
f0103d0f:	5d                   	pop    %ebp
f0103d10:	c3                   	ret    
	return 0;
f0103d11:	b8 00 00 00 00       	mov    $0x0,%eax
f0103d16:	eb f1                	jmp    f0103d09 <debuginfo_eip+0x233>

f0103d18 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103d18:	55                   	push   %ebp
f0103d19:	89 e5                	mov    %esp,%ebp
f0103d1b:	57                   	push   %edi
f0103d1c:	56                   	push   %esi
f0103d1d:	53                   	push   %ebx
f0103d1e:	83 ec 1c             	sub    $0x1c,%esp
f0103d21:	89 c7                	mov    %eax,%edi
f0103d23:	89 d6                	mov    %edx,%esi
f0103d25:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d28:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103d2b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103d2e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103d31:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0103d34:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103d39:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103d3c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103d3f:	39 d3                	cmp    %edx,%ebx
f0103d41:	72 05                	jb     f0103d48 <printnum+0x30>
f0103d43:	39 45 10             	cmp    %eax,0x10(%ebp)
f0103d46:	77 78                	ja     f0103dc0 <printnum+0xa8>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103d48:	83 ec 0c             	sub    $0xc,%esp
f0103d4b:	ff 75 18             	pushl  0x18(%ebp)
f0103d4e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d51:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0103d54:	53                   	push   %ebx
f0103d55:	ff 75 10             	pushl  0x10(%ebp)
f0103d58:	83 ec 08             	sub    $0x8,%esp
f0103d5b:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103d5e:	ff 75 e0             	pushl  -0x20(%ebp)
f0103d61:	ff 75 dc             	pushl  -0x24(%ebp)
f0103d64:	ff 75 d8             	pushl  -0x28(%ebp)
f0103d67:	e8 5c 0a 00 00       	call   f01047c8 <__udivdi3>
f0103d6c:	83 c4 18             	add    $0x18,%esp
f0103d6f:	52                   	push   %edx
f0103d70:	50                   	push   %eax
f0103d71:	89 f2                	mov    %esi,%edx
f0103d73:	89 f8                	mov    %edi,%eax
f0103d75:	e8 9e ff ff ff       	call   f0103d18 <printnum>
f0103d7a:	83 c4 20             	add    $0x20,%esp
f0103d7d:	eb 11                	jmp    f0103d90 <printnum+0x78>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103d7f:	83 ec 08             	sub    $0x8,%esp
f0103d82:	56                   	push   %esi
f0103d83:	ff 75 18             	pushl  0x18(%ebp)
f0103d86:	ff d7                	call   *%edi
f0103d88:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0103d8b:	4b                   	dec    %ebx
f0103d8c:	85 db                	test   %ebx,%ebx
f0103d8e:	7f ef                	jg     f0103d7f <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103d90:	83 ec 08             	sub    $0x8,%esp
f0103d93:	56                   	push   %esi
f0103d94:	83 ec 04             	sub    $0x4,%esp
f0103d97:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103d9a:	ff 75 e0             	pushl  -0x20(%ebp)
f0103d9d:	ff 75 dc             	pushl  -0x24(%ebp)
f0103da0:	ff 75 d8             	pushl  -0x28(%ebp)
f0103da3:	e8 20 0b 00 00       	call   f01048c8 <__umoddi3>
f0103da8:	83 c4 14             	add    $0x14,%esp
f0103dab:	0f be 80 81 62 10 f0 	movsbl -0xfef9d7f(%eax),%eax
f0103db2:	50                   	push   %eax
f0103db3:	ff d7                	call   *%edi
}
f0103db5:	83 c4 10             	add    $0x10,%esp
f0103db8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103dbb:	5b                   	pop    %ebx
f0103dbc:	5e                   	pop    %esi
f0103dbd:	5f                   	pop    %edi
f0103dbe:	5d                   	pop    %ebp
f0103dbf:	c3                   	ret    
f0103dc0:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0103dc3:	eb c6                	jmp    f0103d8b <printnum+0x73>

f0103dc5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103dc5:	55                   	push   %ebp
f0103dc6:	89 e5                	mov    %esp,%ebp
f0103dc8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103dcb:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0103dce:	8b 10                	mov    (%eax),%edx
f0103dd0:	3b 50 04             	cmp    0x4(%eax),%edx
f0103dd3:	73 0a                	jae    f0103ddf <sprintputch+0x1a>
		*b->buf++ = ch;
f0103dd5:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103dd8:	89 08                	mov    %ecx,(%eax)
f0103dda:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ddd:	88 02                	mov    %al,(%edx)
}
f0103ddf:	5d                   	pop    %ebp
f0103de0:	c3                   	ret    

f0103de1 <printfmt>:
{
f0103de1:	55                   	push   %ebp
f0103de2:	89 e5                	mov    %esp,%ebp
f0103de4:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0103de7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103dea:	50                   	push   %eax
f0103deb:	ff 75 10             	pushl  0x10(%ebp)
f0103dee:	ff 75 0c             	pushl  0xc(%ebp)
f0103df1:	ff 75 08             	pushl  0x8(%ebp)
f0103df4:	e8 05 00 00 00       	call   f0103dfe <vprintfmt>
}
f0103df9:	83 c4 10             	add    $0x10,%esp
f0103dfc:	c9                   	leave  
f0103dfd:	c3                   	ret    

f0103dfe <vprintfmt>:
{
f0103dfe:	55                   	push   %ebp
f0103dff:	89 e5                	mov    %esp,%ebp
f0103e01:	57                   	push   %edi
f0103e02:	56                   	push   %esi
f0103e03:	53                   	push   %ebx
f0103e04:	83 ec 2c             	sub    $0x2c,%esp
f0103e07:	8b 75 08             	mov    0x8(%ebp),%esi
f0103e0a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103e0d:	8b 7d 10             	mov    0x10(%ebp),%edi
f0103e10:	e9 ac 03 00 00       	jmp    f01041c1 <vprintfmt+0x3c3>
		padc = ' ';
f0103e15:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0103e19:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0103e20:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f0103e27:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0103e2e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0103e33:	8d 47 01             	lea    0x1(%edi),%eax
f0103e36:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103e39:	8a 17                	mov    (%edi),%dl
f0103e3b:	8d 42 dd             	lea    -0x23(%edx),%eax
f0103e3e:	3c 55                	cmp    $0x55,%al
f0103e40:	0f 87 fc 03 00 00    	ja     f0104242 <vprintfmt+0x444>
f0103e46:	0f b6 c0             	movzbl %al,%eax
f0103e49:	ff 24 85 0c 63 10 f0 	jmp    *-0xfef9cf4(,%eax,4)
f0103e50:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0103e53:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0103e57:	eb da                	jmp    f0103e33 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0103e59:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0103e5c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0103e60:	eb d1                	jmp    f0103e33 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0103e62:	0f b6 d2             	movzbl %dl,%edx
f0103e65:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0103e68:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e6d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0103e70:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0103e73:	01 c0                	add    %eax,%eax
f0103e75:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
				ch = *fmt;
f0103e79:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0103e7c:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0103e7f:	83 f9 09             	cmp    $0x9,%ecx
f0103e82:	77 52                	ja     f0103ed6 <vprintfmt+0xd8>
			for (precision = 0; ; ++fmt) {
f0103e84:	47                   	inc    %edi
				precision = precision * 10 + ch - '0';
f0103e85:	eb e9                	jmp    f0103e70 <vprintfmt+0x72>
			precision = va_arg(ap, int);
f0103e87:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e8a:	8b 00                	mov    (%eax),%eax
f0103e8c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103e8f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e92:	8d 40 04             	lea    0x4(%eax),%eax
f0103e95:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103e98:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0103e9b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103e9f:	79 92                	jns    f0103e33 <vprintfmt+0x35>
				width = precision, precision = -1;
f0103ea1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103ea4:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103ea7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103eae:	eb 83                	jmp    f0103e33 <vprintfmt+0x35>
f0103eb0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103eb4:	78 08                	js     f0103ebe <vprintfmt+0xc0>
		switch (ch = *(unsigned char *) fmt++) {
f0103eb6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103eb9:	e9 75 ff ff ff       	jmp    f0103e33 <vprintfmt+0x35>
f0103ebe:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103ec5:	eb ef                	jmp    f0103eb6 <vprintfmt+0xb8>
f0103ec7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0103eca:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0103ed1:	e9 5d ff ff ff       	jmp    f0103e33 <vprintfmt+0x35>
f0103ed6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103ed9:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103edc:	eb bd                	jmp    f0103e9b <vprintfmt+0x9d>
			lflag++;
f0103ede:	41                   	inc    %ecx
		switch (ch = *(unsigned char *) fmt++) {
f0103edf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0103ee2:	e9 4c ff ff ff       	jmp    f0103e33 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f0103ee7:	8b 45 14             	mov    0x14(%ebp),%eax
f0103eea:	8d 78 04             	lea    0x4(%eax),%edi
f0103eed:	83 ec 08             	sub    $0x8,%esp
f0103ef0:	53                   	push   %ebx
f0103ef1:	ff 30                	pushl  (%eax)
f0103ef3:	ff d6                	call   *%esi
			break;
f0103ef5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0103ef8:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0103efb:	e9 be 02 00 00       	jmp    f01041be <vprintfmt+0x3c0>
			err = va_arg(ap, int);
f0103f00:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f03:	8d 78 04             	lea    0x4(%eax),%edi
f0103f06:	8b 00                	mov    (%eax),%eax
f0103f08:	85 c0                	test   %eax,%eax
f0103f0a:	78 2a                	js     f0103f36 <vprintfmt+0x138>
f0103f0c:	89 c2                	mov    %eax,%edx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103f0e:	83 f8 06             	cmp    $0x6,%eax
f0103f11:	7f 27                	jg     f0103f3a <vprintfmt+0x13c>
f0103f13:	8b 04 85 64 64 10 f0 	mov    -0xfef9b9c(,%eax,4),%eax
f0103f1a:	85 c0                	test   %eax,%eax
f0103f1c:	74 1c                	je     f0103f3a <vprintfmt+0x13c>
				printfmt(putch, putdat, "%s", p);
f0103f1e:	50                   	push   %eax
f0103f1f:	68 79 5a 10 f0       	push   $0xf0105a79
f0103f24:	53                   	push   %ebx
f0103f25:	56                   	push   %esi
f0103f26:	e8 b6 fe ff ff       	call   f0103de1 <printfmt>
f0103f2b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103f2e:	89 7d 14             	mov    %edi,0x14(%ebp)
f0103f31:	e9 88 02 00 00       	jmp    f01041be <vprintfmt+0x3c0>
f0103f36:	f7 d8                	neg    %eax
f0103f38:	eb d2                	jmp    f0103f0c <vprintfmt+0x10e>
				printfmt(putch, putdat, "error %d", err);
f0103f3a:	52                   	push   %edx
f0103f3b:	68 99 62 10 f0       	push   $0xf0106299
f0103f40:	53                   	push   %ebx
f0103f41:	56                   	push   %esi
f0103f42:	e8 9a fe ff ff       	call   f0103de1 <printfmt>
f0103f47:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103f4a:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0103f4d:	e9 6c 02 00 00       	jmp    f01041be <vprintfmt+0x3c0>
			if ((p = va_arg(ap, char *)) == NULL)
f0103f52:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f55:	83 c0 04             	add    $0x4,%eax
f0103f58:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0103f5b:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f5e:	8b 38                	mov    (%eax),%edi
f0103f60:	85 ff                	test   %edi,%edi
f0103f62:	74 18                	je     f0103f7c <vprintfmt+0x17e>
			if (width > 0 && padc != '-')
f0103f64:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103f68:	0f 8e b7 00 00 00    	jle    f0104025 <vprintfmt+0x227>
f0103f6e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0103f72:	75 0f                	jne    f0103f83 <vprintfmt+0x185>
f0103f74:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103f77:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103f7a:	eb 6e                	jmp    f0103fea <vprintfmt+0x1ec>
				p = "(null)";
f0103f7c:	bf 92 62 10 f0       	mov    $0xf0106292,%edi
f0103f81:	eb e1                	jmp    f0103f64 <vprintfmt+0x166>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103f83:	83 ec 08             	sub    $0x8,%esp
f0103f86:	ff 75 d0             	pushl  -0x30(%ebp)
f0103f89:	57                   	push   %edi
f0103f8a:	e8 45 04 00 00       	call   f01043d4 <strnlen>
f0103f8f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103f92:	29 c1                	sub    %eax,%ecx
f0103f94:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0103f97:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0103f9a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0103f9e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103fa1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103fa4:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0103fa6:	eb 0d                	jmp    f0103fb5 <vprintfmt+0x1b7>
					putch(padc, putdat);
f0103fa8:	83 ec 08             	sub    $0x8,%esp
f0103fab:	53                   	push   %ebx
f0103fac:	ff 75 e0             	pushl  -0x20(%ebp)
f0103faf:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0103fb1:	4f                   	dec    %edi
f0103fb2:	83 c4 10             	add    $0x10,%esp
f0103fb5:	85 ff                	test   %edi,%edi
f0103fb7:	7f ef                	jg     f0103fa8 <vprintfmt+0x1aa>
f0103fb9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103fbc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103fbf:	89 c8                	mov    %ecx,%eax
f0103fc1:	85 c9                	test   %ecx,%ecx
f0103fc3:	78 59                	js     f010401e <vprintfmt+0x220>
f0103fc5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103fc8:	29 c1                	sub    %eax,%ecx
f0103fca:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103fcd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103fd0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103fd3:	eb 15                	jmp    f0103fea <vprintfmt+0x1ec>
				if (altflag && (ch < ' ' || ch > '~'))
f0103fd5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103fd9:	75 29                	jne    f0104004 <vprintfmt+0x206>
					putch(ch, putdat);
f0103fdb:	83 ec 08             	sub    $0x8,%esp
f0103fde:	ff 75 0c             	pushl  0xc(%ebp)
f0103fe1:	50                   	push   %eax
f0103fe2:	ff d6                	call   *%esi
f0103fe4:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103fe7:	ff 4d e0             	decl   -0x20(%ebp)
f0103fea:	47                   	inc    %edi
f0103feb:	8a 57 ff             	mov    -0x1(%edi),%dl
f0103fee:	0f be c2             	movsbl %dl,%eax
f0103ff1:	85 c0                	test   %eax,%eax
f0103ff3:	74 53                	je     f0104048 <vprintfmt+0x24a>
f0103ff5:	85 db                	test   %ebx,%ebx
f0103ff7:	78 dc                	js     f0103fd5 <vprintfmt+0x1d7>
f0103ff9:	4b                   	dec    %ebx
f0103ffa:	79 d9                	jns    f0103fd5 <vprintfmt+0x1d7>
f0103ffc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103fff:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104002:	eb 35                	jmp    f0104039 <vprintfmt+0x23b>
				if (altflag && (ch < ' ' || ch > '~'))
f0104004:	0f be d2             	movsbl %dl,%edx
f0104007:	83 ea 20             	sub    $0x20,%edx
f010400a:	83 fa 5e             	cmp    $0x5e,%edx
f010400d:	76 cc                	jbe    f0103fdb <vprintfmt+0x1dd>
					putch('?', putdat);
f010400f:	83 ec 08             	sub    $0x8,%esp
f0104012:	ff 75 0c             	pushl  0xc(%ebp)
f0104015:	6a 3f                	push   $0x3f
f0104017:	ff d6                	call   *%esi
f0104019:	83 c4 10             	add    $0x10,%esp
f010401c:	eb c9                	jmp    f0103fe7 <vprintfmt+0x1e9>
f010401e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104023:	eb a0                	jmp    f0103fc5 <vprintfmt+0x1c7>
f0104025:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104028:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010402b:	eb bd                	jmp    f0103fea <vprintfmt+0x1ec>
				putch(' ', putdat);
f010402d:	83 ec 08             	sub    $0x8,%esp
f0104030:	53                   	push   %ebx
f0104031:	6a 20                	push   $0x20
f0104033:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0104035:	4f                   	dec    %edi
f0104036:	83 c4 10             	add    $0x10,%esp
f0104039:	85 ff                	test   %edi,%edi
f010403b:	7f f0                	jg     f010402d <vprintfmt+0x22f>
			if ((p = va_arg(ap, char *)) == NULL)
f010403d:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104040:	89 45 14             	mov    %eax,0x14(%ebp)
f0104043:	e9 76 01 00 00       	jmp    f01041be <vprintfmt+0x3c0>
f0104048:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010404b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010404e:	eb e9                	jmp    f0104039 <vprintfmt+0x23b>
	if (lflag >= 2)
f0104050:	83 f9 01             	cmp    $0x1,%ecx
f0104053:	7e 3f                	jle    f0104094 <vprintfmt+0x296>
		return va_arg(*ap, long long);
f0104055:	8b 45 14             	mov    0x14(%ebp),%eax
f0104058:	8b 50 04             	mov    0x4(%eax),%edx
f010405b:	8b 00                	mov    (%eax),%eax
f010405d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104060:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104063:	8b 45 14             	mov    0x14(%ebp),%eax
f0104066:	8d 40 08             	lea    0x8(%eax),%eax
f0104069:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f010406c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104070:	79 5c                	jns    f01040ce <vprintfmt+0x2d0>
				putch('-', putdat);
f0104072:	83 ec 08             	sub    $0x8,%esp
f0104075:	53                   	push   %ebx
f0104076:	6a 2d                	push   $0x2d
f0104078:	ff d6                	call   *%esi
				num = -(long long) num;
f010407a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010407d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104080:	f7 da                	neg    %edx
f0104082:	83 d1 00             	adc    $0x0,%ecx
f0104085:	f7 d9                	neg    %ecx
f0104087:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010408a:	b8 0a 00 00 00       	mov    $0xa,%eax
f010408f:	e9 10 01 00 00       	jmp    f01041a4 <vprintfmt+0x3a6>
	else if (lflag)
f0104094:	85 c9                	test   %ecx,%ecx
f0104096:	75 1b                	jne    f01040b3 <vprintfmt+0x2b5>
		return va_arg(*ap, int);
f0104098:	8b 45 14             	mov    0x14(%ebp),%eax
f010409b:	8b 00                	mov    (%eax),%eax
f010409d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01040a0:	89 c1                	mov    %eax,%ecx
f01040a2:	c1 f9 1f             	sar    $0x1f,%ecx
f01040a5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01040a8:	8b 45 14             	mov    0x14(%ebp),%eax
f01040ab:	8d 40 04             	lea    0x4(%eax),%eax
f01040ae:	89 45 14             	mov    %eax,0x14(%ebp)
f01040b1:	eb b9                	jmp    f010406c <vprintfmt+0x26e>
		return va_arg(*ap, long);
f01040b3:	8b 45 14             	mov    0x14(%ebp),%eax
f01040b6:	8b 00                	mov    (%eax),%eax
f01040b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01040bb:	89 c1                	mov    %eax,%ecx
f01040bd:	c1 f9 1f             	sar    $0x1f,%ecx
f01040c0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01040c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01040c6:	8d 40 04             	lea    0x4(%eax),%eax
f01040c9:	89 45 14             	mov    %eax,0x14(%ebp)
f01040cc:	eb 9e                	jmp    f010406c <vprintfmt+0x26e>
			num = getint(&ap, lflag);
f01040ce:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01040d1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01040d4:	b8 0a 00 00 00       	mov    $0xa,%eax
f01040d9:	e9 c6 00 00 00       	jmp    f01041a4 <vprintfmt+0x3a6>
	if (lflag >= 2)
f01040de:	83 f9 01             	cmp    $0x1,%ecx
f01040e1:	7e 18                	jle    f01040fb <vprintfmt+0x2fd>
		return va_arg(*ap, unsigned long long);
f01040e3:	8b 45 14             	mov    0x14(%ebp),%eax
f01040e6:	8b 10                	mov    (%eax),%edx
f01040e8:	8b 48 04             	mov    0x4(%eax),%ecx
f01040eb:	8d 40 08             	lea    0x8(%eax),%eax
f01040ee:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01040f1:	b8 0a 00 00 00       	mov    $0xa,%eax
f01040f6:	e9 a9 00 00 00       	jmp    f01041a4 <vprintfmt+0x3a6>
	else if (lflag)
f01040fb:	85 c9                	test   %ecx,%ecx
f01040fd:	75 1a                	jne    f0104119 <vprintfmt+0x31b>
		return va_arg(*ap, unsigned int);
f01040ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0104102:	8b 10                	mov    (%eax),%edx
f0104104:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104109:	8d 40 04             	lea    0x4(%eax),%eax
f010410c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010410f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104114:	e9 8b 00 00 00       	jmp    f01041a4 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0104119:	8b 45 14             	mov    0x14(%ebp),%eax
f010411c:	8b 10                	mov    (%eax),%edx
f010411e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104123:	8d 40 04             	lea    0x4(%eax),%eax
f0104126:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104129:	b8 0a 00 00 00       	mov    $0xa,%eax
f010412e:	eb 74                	jmp    f01041a4 <vprintfmt+0x3a6>
	if (lflag >= 2)
f0104130:	83 f9 01             	cmp    $0x1,%ecx
f0104133:	7e 15                	jle    f010414a <vprintfmt+0x34c>
		return va_arg(*ap, unsigned long long);
f0104135:	8b 45 14             	mov    0x14(%ebp),%eax
f0104138:	8b 10                	mov    (%eax),%edx
f010413a:	8b 48 04             	mov    0x4(%eax),%ecx
f010413d:	8d 40 08             	lea    0x8(%eax),%eax
f0104140:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104143:	b8 08 00 00 00       	mov    $0x8,%eax
f0104148:	eb 5a                	jmp    f01041a4 <vprintfmt+0x3a6>
	else if (lflag)
f010414a:	85 c9                	test   %ecx,%ecx
f010414c:	75 17                	jne    f0104165 <vprintfmt+0x367>
		return va_arg(*ap, unsigned int);
f010414e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104151:	8b 10                	mov    (%eax),%edx
f0104153:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104158:	8d 40 04             	lea    0x4(%eax),%eax
f010415b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010415e:	b8 08 00 00 00       	mov    $0x8,%eax
f0104163:	eb 3f                	jmp    f01041a4 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0104165:	8b 45 14             	mov    0x14(%ebp),%eax
f0104168:	8b 10                	mov    (%eax),%edx
f010416a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010416f:	8d 40 04             	lea    0x4(%eax),%eax
f0104172:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104175:	b8 08 00 00 00       	mov    $0x8,%eax
f010417a:	eb 28                	jmp    f01041a4 <vprintfmt+0x3a6>
			putch('0', putdat);
f010417c:	83 ec 08             	sub    $0x8,%esp
f010417f:	53                   	push   %ebx
f0104180:	6a 30                	push   $0x30
f0104182:	ff d6                	call   *%esi
			putch('x', putdat);
f0104184:	83 c4 08             	add    $0x8,%esp
f0104187:	53                   	push   %ebx
f0104188:	6a 78                	push   $0x78
f010418a:	ff d6                	call   *%esi
			num = (unsigned long long)
f010418c:	8b 45 14             	mov    0x14(%ebp),%eax
f010418f:	8b 10                	mov    (%eax),%edx
f0104191:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0104196:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0104199:	8d 40 04             	lea    0x4(%eax),%eax
f010419c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010419f:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01041a4:	83 ec 0c             	sub    $0xc,%esp
f01041a7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01041ab:	57                   	push   %edi
f01041ac:	ff 75 e0             	pushl  -0x20(%ebp)
f01041af:	50                   	push   %eax
f01041b0:	51                   	push   %ecx
f01041b1:	52                   	push   %edx
f01041b2:	89 da                	mov    %ebx,%edx
f01041b4:	89 f0                	mov    %esi,%eax
f01041b6:	e8 5d fb ff ff       	call   f0103d18 <printnum>
			break;
f01041bb:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f01041be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01041c1:	47                   	inc    %edi
f01041c2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01041c6:	83 f8 25             	cmp    $0x25,%eax
f01041c9:	0f 84 46 fc ff ff    	je     f0103e15 <vprintfmt+0x17>
			if (ch == '\0')
f01041cf:	85 c0                	test   %eax,%eax
f01041d1:	0f 84 89 00 00 00    	je     f0104260 <vprintfmt+0x462>
			putch(ch, putdat);
f01041d7:	83 ec 08             	sub    $0x8,%esp
f01041da:	53                   	push   %ebx
f01041db:	50                   	push   %eax
f01041dc:	ff d6                	call   *%esi
f01041de:	83 c4 10             	add    $0x10,%esp
f01041e1:	eb de                	jmp    f01041c1 <vprintfmt+0x3c3>
	if (lflag >= 2)
f01041e3:	83 f9 01             	cmp    $0x1,%ecx
f01041e6:	7e 15                	jle    f01041fd <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long long);
f01041e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01041eb:	8b 10                	mov    (%eax),%edx
f01041ed:	8b 48 04             	mov    0x4(%eax),%ecx
f01041f0:	8d 40 08             	lea    0x8(%eax),%eax
f01041f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01041f6:	b8 10 00 00 00       	mov    $0x10,%eax
f01041fb:	eb a7                	jmp    f01041a4 <vprintfmt+0x3a6>
	else if (lflag)
f01041fd:	85 c9                	test   %ecx,%ecx
f01041ff:	75 17                	jne    f0104218 <vprintfmt+0x41a>
		return va_arg(*ap, unsigned int);
f0104201:	8b 45 14             	mov    0x14(%ebp),%eax
f0104204:	8b 10                	mov    (%eax),%edx
f0104206:	b9 00 00 00 00       	mov    $0x0,%ecx
f010420b:	8d 40 04             	lea    0x4(%eax),%eax
f010420e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104211:	b8 10 00 00 00       	mov    $0x10,%eax
f0104216:	eb 8c                	jmp    f01041a4 <vprintfmt+0x3a6>
		return va_arg(*ap, unsigned long);
f0104218:	8b 45 14             	mov    0x14(%ebp),%eax
f010421b:	8b 10                	mov    (%eax),%edx
f010421d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104222:	8d 40 04             	lea    0x4(%eax),%eax
f0104225:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104228:	b8 10 00 00 00       	mov    $0x10,%eax
f010422d:	e9 72 ff ff ff       	jmp    f01041a4 <vprintfmt+0x3a6>
			putch(ch, putdat);
f0104232:	83 ec 08             	sub    $0x8,%esp
f0104235:	53                   	push   %ebx
f0104236:	6a 25                	push   $0x25
f0104238:	ff d6                	call   *%esi
			break;
f010423a:	83 c4 10             	add    $0x10,%esp
f010423d:	e9 7c ff ff ff       	jmp    f01041be <vprintfmt+0x3c0>
			putch('%', putdat);
f0104242:	83 ec 08             	sub    $0x8,%esp
f0104245:	53                   	push   %ebx
f0104246:	6a 25                	push   $0x25
f0104248:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010424a:	83 c4 10             	add    $0x10,%esp
f010424d:	89 f8                	mov    %edi,%eax
f010424f:	eb 01                	jmp    f0104252 <vprintfmt+0x454>
f0104251:	48                   	dec    %eax
f0104252:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0104256:	75 f9                	jne    f0104251 <vprintfmt+0x453>
f0104258:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010425b:	e9 5e ff ff ff       	jmp    f01041be <vprintfmt+0x3c0>
}
f0104260:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104263:	5b                   	pop    %ebx
f0104264:	5e                   	pop    %esi
f0104265:	5f                   	pop    %edi
f0104266:	5d                   	pop    %ebp
f0104267:	c3                   	ret    

f0104268 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104268:	55                   	push   %ebp
f0104269:	89 e5                	mov    %esp,%ebp
f010426b:	83 ec 18             	sub    $0x18,%esp
f010426e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104271:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104274:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104277:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010427b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010427e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104285:	85 c0                	test   %eax,%eax
f0104287:	74 26                	je     f01042af <vsnprintf+0x47>
f0104289:	85 d2                	test   %edx,%edx
f010428b:	7e 29                	jle    f01042b6 <vsnprintf+0x4e>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010428d:	ff 75 14             	pushl  0x14(%ebp)
f0104290:	ff 75 10             	pushl  0x10(%ebp)
f0104293:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104296:	50                   	push   %eax
f0104297:	68 c5 3d 10 f0       	push   $0xf0103dc5
f010429c:	e8 5d fb ff ff       	call   f0103dfe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01042a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01042a4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01042a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01042aa:	83 c4 10             	add    $0x10,%esp
}
f01042ad:	c9                   	leave  
f01042ae:	c3                   	ret    
		return -E_INVAL;
f01042af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01042b4:	eb f7                	jmp    f01042ad <vsnprintf+0x45>
f01042b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01042bb:	eb f0                	jmp    f01042ad <vsnprintf+0x45>

f01042bd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01042bd:	55                   	push   %ebp
f01042be:	89 e5                	mov    %esp,%ebp
f01042c0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01042c3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01042c6:	50                   	push   %eax
f01042c7:	ff 75 10             	pushl  0x10(%ebp)
f01042ca:	ff 75 0c             	pushl  0xc(%ebp)
f01042cd:	ff 75 08             	pushl  0x8(%ebp)
f01042d0:	e8 93 ff ff ff       	call   f0104268 <vsnprintf>
	va_end(ap);

	return rc;
}
f01042d5:	c9                   	leave  
f01042d6:	c3                   	ret    

f01042d7 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01042d7:	55                   	push   %ebp
f01042d8:	89 e5                	mov    %esp,%ebp
f01042da:	57                   	push   %edi
f01042db:	56                   	push   %esi
f01042dc:	53                   	push   %ebx
f01042dd:	83 ec 0c             	sub    $0xc,%esp
f01042e0:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01042e3:	85 c0                	test   %eax,%eax
f01042e5:	74 11                	je     f01042f8 <readline+0x21>
		cprintf("%s", prompt);
f01042e7:	83 ec 08             	sub    $0x8,%esp
f01042ea:	50                   	push   %eax
f01042eb:	68 79 5a 10 f0       	push   $0xf0105a79
f01042f0:	e8 fe f2 ff ff       	call   f01035f3 <cprintf>
f01042f5:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01042f8:	83 ec 0c             	sub    $0xc,%esp
f01042fb:	6a 00                	push   $0x0
f01042fd:	e8 ba c3 ff ff       	call   f01006bc <iscons>
f0104302:	89 c7                	mov    %eax,%edi
f0104304:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0104307:	be 00 00 00 00       	mov    $0x0,%esi
f010430c:	eb 6f                	jmp    f010437d <readline+0xa6>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f010430e:	83 ec 08             	sub    $0x8,%esp
f0104311:	50                   	push   %eax
f0104312:	68 80 64 10 f0       	push   $0xf0106480
f0104317:	e8 d7 f2 ff ff       	call   f01035f3 <cprintf>
			return NULL;
f010431c:	83 c4 10             	add    $0x10,%esp
f010431f:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0104324:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104327:	5b                   	pop    %ebx
f0104328:	5e                   	pop    %esi
f0104329:	5f                   	pop    %edi
f010432a:	5d                   	pop    %ebp
f010432b:	c3                   	ret    
				cputchar('\b');
f010432c:	83 ec 0c             	sub    $0xc,%esp
f010432f:	6a 08                	push   $0x8
f0104331:	e8 65 c3 ff ff       	call   f010069b <cputchar>
f0104336:	83 c4 10             	add    $0x10,%esp
f0104339:	eb 41                	jmp    f010437c <readline+0xa5>
				cputchar(c);
f010433b:	83 ec 0c             	sub    $0xc,%esp
f010433e:	53                   	push   %ebx
f010433f:	e8 57 c3 ff ff       	call   f010069b <cputchar>
f0104344:	83 c4 10             	add    $0x10,%esp
f0104347:	eb 5a                	jmp    f01043a3 <readline+0xcc>
		} else if (c == '\n' || c == '\r') {
f0104349:	83 fb 0a             	cmp    $0xa,%ebx
f010434c:	74 05                	je     f0104353 <readline+0x7c>
f010434e:	83 fb 0d             	cmp    $0xd,%ebx
f0104351:	75 2a                	jne    f010437d <readline+0xa6>
			if (echoing)
f0104353:	85 ff                	test   %edi,%edi
f0104355:	75 0e                	jne    f0104365 <readline+0x8e>
			buf[i] = 0;
f0104357:	c6 86 e0 59 1b f0 00 	movb   $0x0,-0xfe4a620(%esi)
			return buf;
f010435e:	b8 e0 59 1b f0       	mov    $0xf01b59e0,%eax
f0104363:	eb bf                	jmp    f0104324 <readline+0x4d>
				cputchar('\n');
f0104365:	83 ec 0c             	sub    $0xc,%esp
f0104368:	6a 0a                	push   $0xa
f010436a:	e8 2c c3 ff ff       	call   f010069b <cputchar>
f010436f:	83 c4 10             	add    $0x10,%esp
f0104372:	eb e3                	jmp    f0104357 <readline+0x80>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104374:	85 f6                	test   %esi,%esi
f0104376:	7e 3c                	jle    f01043b4 <readline+0xdd>
			if (echoing)
f0104378:	85 ff                	test   %edi,%edi
f010437a:	75 b0                	jne    f010432c <readline+0x55>
			i--;
f010437c:	4e                   	dec    %esi
		c = getchar();
f010437d:	e8 29 c3 ff ff       	call   f01006ab <getchar>
f0104382:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104384:	85 c0                	test   %eax,%eax
f0104386:	78 86                	js     f010430e <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104388:	83 f8 08             	cmp    $0x8,%eax
f010438b:	74 21                	je     f01043ae <readline+0xd7>
f010438d:	83 f8 7f             	cmp    $0x7f,%eax
f0104390:	74 e2                	je     f0104374 <readline+0x9d>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104392:	83 f8 1f             	cmp    $0x1f,%eax
f0104395:	7e b2                	jle    f0104349 <readline+0x72>
f0104397:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010439d:	7f aa                	jg     f0104349 <readline+0x72>
			if (echoing)
f010439f:	85 ff                	test   %edi,%edi
f01043a1:	75 98                	jne    f010433b <readline+0x64>
			buf[i++] = c;
f01043a3:	88 9e e0 59 1b f0    	mov    %bl,-0xfe4a620(%esi)
f01043a9:	8d 76 01             	lea    0x1(%esi),%esi
f01043ac:	eb cf                	jmp    f010437d <readline+0xa6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01043ae:	85 f6                	test   %esi,%esi
f01043b0:	7e cb                	jle    f010437d <readline+0xa6>
f01043b2:	eb c4                	jmp    f0104378 <readline+0xa1>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01043b4:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01043ba:	7e e3                	jle    f010439f <readline+0xc8>
f01043bc:	eb bf                	jmp    f010437d <readline+0xa6>

f01043be <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01043be:	55                   	push   %ebp
f01043bf:	89 e5                	mov    %esp,%ebp
f01043c1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01043c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01043c9:	eb 01                	jmp    f01043cc <strlen+0xe>
		n++;
f01043cb:	40                   	inc    %eax
	for (n = 0; *s != '\0'; s++)
f01043cc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01043d0:	75 f9                	jne    f01043cb <strlen+0xd>
	return n;
}
f01043d2:	5d                   	pop    %ebp
f01043d3:	c3                   	ret    

f01043d4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01043d4:	55                   	push   %ebp
f01043d5:	89 e5                	mov    %esp,%ebp
f01043d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01043da:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01043dd:	b8 00 00 00 00       	mov    $0x0,%eax
f01043e2:	eb 01                	jmp    f01043e5 <strnlen+0x11>
		n++;
f01043e4:	40                   	inc    %eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01043e5:	39 d0                	cmp    %edx,%eax
f01043e7:	74 06                	je     f01043ef <strnlen+0x1b>
f01043e9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01043ed:	75 f5                	jne    f01043e4 <strnlen+0x10>
	return n;
}
f01043ef:	5d                   	pop    %ebp
f01043f0:	c3                   	ret    

f01043f1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01043f1:	55                   	push   %ebp
f01043f2:	89 e5                	mov    %esp,%ebp
f01043f4:	53                   	push   %ebx
f01043f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01043f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01043fb:	89 c2                	mov    %eax,%edx
f01043fd:	41                   	inc    %ecx
f01043fe:	42                   	inc    %edx
f01043ff:	8a 59 ff             	mov    -0x1(%ecx),%bl
f0104402:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104405:	84 db                	test   %bl,%bl
f0104407:	75 f4                	jne    f01043fd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104409:	5b                   	pop    %ebx
f010440a:	5d                   	pop    %ebp
f010440b:	c3                   	ret    

f010440c <strcat>:

char *
strcat(char *dst, const char *src)
{
f010440c:	55                   	push   %ebp
f010440d:	89 e5                	mov    %esp,%ebp
f010440f:	53                   	push   %ebx
f0104410:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104413:	53                   	push   %ebx
f0104414:	e8 a5 ff ff ff       	call   f01043be <strlen>
f0104419:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010441c:	ff 75 0c             	pushl  0xc(%ebp)
f010441f:	01 d8                	add    %ebx,%eax
f0104421:	50                   	push   %eax
f0104422:	e8 ca ff ff ff       	call   f01043f1 <strcpy>
	return dst;
}
f0104427:	89 d8                	mov    %ebx,%eax
f0104429:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010442c:	c9                   	leave  
f010442d:	c3                   	ret    

f010442e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010442e:	55                   	push   %ebp
f010442f:	89 e5                	mov    %esp,%ebp
f0104431:	56                   	push   %esi
f0104432:	53                   	push   %ebx
f0104433:	8b 75 08             	mov    0x8(%ebp),%esi
f0104436:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104439:	89 f3                	mov    %esi,%ebx
f010443b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010443e:	89 f2                	mov    %esi,%edx
f0104440:	39 da                	cmp    %ebx,%edx
f0104442:	74 0e                	je     f0104452 <strncpy+0x24>
		*dst++ = *src;
f0104444:	42                   	inc    %edx
f0104445:	8a 01                	mov    (%ecx),%al
f0104447:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f010444a:	80 39 00             	cmpb   $0x0,(%ecx)
f010444d:	74 f1                	je     f0104440 <strncpy+0x12>
			src++;
f010444f:	41                   	inc    %ecx
f0104450:	eb ee                	jmp    f0104440 <strncpy+0x12>
	}
	return ret;
}
f0104452:	89 f0                	mov    %esi,%eax
f0104454:	5b                   	pop    %ebx
f0104455:	5e                   	pop    %esi
f0104456:	5d                   	pop    %ebp
f0104457:	c3                   	ret    

f0104458 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104458:	55                   	push   %ebp
f0104459:	89 e5                	mov    %esp,%ebp
f010445b:	56                   	push   %esi
f010445c:	53                   	push   %ebx
f010445d:	8b 75 08             	mov    0x8(%ebp),%esi
f0104460:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104463:	8b 45 10             	mov    0x10(%ebp),%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104466:	85 c0                	test   %eax,%eax
f0104468:	74 20                	je     f010448a <strlcpy+0x32>
f010446a:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
f010446e:	89 f0                	mov    %esi,%eax
f0104470:	eb 05                	jmp    f0104477 <strlcpy+0x1f>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104472:	42                   	inc    %edx
f0104473:	40                   	inc    %eax
f0104474:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0104477:	39 d8                	cmp    %ebx,%eax
f0104479:	74 06                	je     f0104481 <strlcpy+0x29>
f010447b:	8a 0a                	mov    (%edx),%cl
f010447d:	84 c9                	test   %cl,%cl
f010447f:	75 f1                	jne    f0104472 <strlcpy+0x1a>
		*dst = '\0';
f0104481:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104484:	29 f0                	sub    %esi,%eax
}
f0104486:	5b                   	pop    %ebx
f0104487:	5e                   	pop    %esi
f0104488:	5d                   	pop    %ebp
f0104489:	c3                   	ret    
f010448a:	89 f0                	mov    %esi,%eax
f010448c:	eb f6                	jmp    f0104484 <strlcpy+0x2c>

f010448e <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010448e:	55                   	push   %ebp
f010448f:	89 e5                	mov    %esp,%ebp
f0104491:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104494:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104497:	eb 02                	jmp    f010449b <strcmp+0xd>
		p++, q++;
f0104499:	41                   	inc    %ecx
f010449a:	42                   	inc    %edx
	while (*p && *p == *q)
f010449b:	8a 01                	mov    (%ecx),%al
f010449d:	84 c0                	test   %al,%al
f010449f:	74 04                	je     f01044a5 <strcmp+0x17>
f01044a1:	3a 02                	cmp    (%edx),%al
f01044a3:	74 f4                	je     f0104499 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01044a5:	0f b6 c0             	movzbl %al,%eax
f01044a8:	0f b6 12             	movzbl (%edx),%edx
f01044ab:	29 d0                	sub    %edx,%eax
}
f01044ad:	5d                   	pop    %ebp
f01044ae:	c3                   	ret    

f01044af <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01044af:	55                   	push   %ebp
f01044b0:	89 e5                	mov    %esp,%ebp
f01044b2:	53                   	push   %ebx
f01044b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01044b6:	8b 55 0c             	mov    0xc(%ebp),%edx
f01044b9:	89 c3                	mov    %eax,%ebx
f01044bb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01044be:	eb 02                	jmp    f01044c2 <strncmp+0x13>
		n--, p++, q++;
f01044c0:	40                   	inc    %eax
f01044c1:	42                   	inc    %edx
	while (n > 0 && *p && *p == *q)
f01044c2:	39 d8                	cmp    %ebx,%eax
f01044c4:	74 15                	je     f01044db <strncmp+0x2c>
f01044c6:	8a 08                	mov    (%eax),%cl
f01044c8:	84 c9                	test   %cl,%cl
f01044ca:	74 04                	je     f01044d0 <strncmp+0x21>
f01044cc:	3a 0a                	cmp    (%edx),%cl
f01044ce:	74 f0                	je     f01044c0 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01044d0:	0f b6 00             	movzbl (%eax),%eax
f01044d3:	0f b6 12             	movzbl (%edx),%edx
f01044d6:	29 d0                	sub    %edx,%eax
}
f01044d8:	5b                   	pop    %ebx
f01044d9:	5d                   	pop    %ebp
f01044da:	c3                   	ret    
		return 0;
f01044db:	b8 00 00 00 00       	mov    $0x0,%eax
f01044e0:	eb f6                	jmp    f01044d8 <strncmp+0x29>

f01044e2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01044e2:	55                   	push   %ebp
f01044e3:	89 e5                	mov    %esp,%ebp
f01044e5:	8b 45 08             	mov    0x8(%ebp),%eax
f01044e8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01044eb:	8a 10                	mov    (%eax),%dl
f01044ed:	84 d2                	test   %dl,%dl
f01044ef:	74 07                	je     f01044f8 <strchr+0x16>
		if (*s == c)
f01044f1:	38 ca                	cmp    %cl,%dl
f01044f3:	74 08                	je     f01044fd <strchr+0x1b>
	for (; *s; s++)
f01044f5:	40                   	inc    %eax
f01044f6:	eb f3                	jmp    f01044eb <strchr+0x9>
			return (char *) s;
	return 0;
f01044f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01044fd:	5d                   	pop    %ebp
f01044fe:	c3                   	ret    

f01044ff <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01044ff:	55                   	push   %ebp
f0104500:	89 e5                	mov    %esp,%ebp
f0104502:	8b 45 08             	mov    0x8(%ebp),%eax
f0104505:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0104508:	8a 10                	mov    (%eax),%dl
f010450a:	84 d2                	test   %dl,%dl
f010450c:	74 07                	je     f0104515 <strfind+0x16>
		if (*s == c)
f010450e:	38 ca                	cmp    %cl,%dl
f0104510:	74 03                	je     f0104515 <strfind+0x16>
	for (; *s; s++)
f0104512:	40                   	inc    %eax
f0104513:	eb f3                	jmp    f0104508 <strfind+0x9>
			break;
	return (char *) s;
}
f0104515:	5d                   	pop    %ebp
f0104516:	c3                   	ret    

f0104517 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104517:	55                   	push   %ebp
f0104518:	89 e5                	mov    %esp,%ebp
f010451a:	57                   	push   %edi
f010451b:	56                   	push   %esi
f010451c:	53                   	push   %ebx
f010451d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104520:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104523:	85 c9                	test   %ecx,%ecx
f0104525:	74 13                	je     f010453a <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104527:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010452d:	75 05                	jne    f0104534 <memset+0x1d>
f010452f:	f6 c1 03             	test   $0x3,%cl
f0104532:	74 0d                	je     f0104541 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104534:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104537:	fc                   	cld    
f0104538:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010453a:	89 f8                	mov    %edi,%eax
f010453c:	5b                   	pop    %ebx
f010453d:	5e                   	pop    %esi
f010453e:	5f                   	pop    %edi
f010453f:	5d                   	pop    %ebp
f0104540:	c3                   	ret    
		c &= 0xFF;
f0104541:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104545:	89 d3                	mov    %edx,%ebx
f0104547:	c1 e3 08             	shl    $0x8,%ebx
f010454a:	89 d0                	mov    %edx,%eax
f010454c:	c1 e0 18             	shl    $0x18,%eax
f010454f:	89 d6                	mov    %edx,%esi
f0104551:	c1 e6 10             	shl    $0x10,%esi
f0104554:	09 f0                	or     %esi,%eax
f0104556:	09 c2                	or     %eax,%edx
f0104558:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f010455a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010455d:	89 d0                	mov    %edx,%eax
f010455f:	fc                   	cld    
f0104560:	f3 ab                	rep stos %eax,%es:(%edi)
f0104562:	eb d6                	jmp    f010453a <memset+0x23>

f0104564 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104564:	55                   	push   %ebp
f0104565:	89 e5                	mov    %esp,%ebp
f0104567:	57                   	push   %edi
f0104568:	56                   	push   %esi
f0104569:	8b 45 08             	mov    0x8(%ebp),%eax
f010456c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010456f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104572:	39 c6                	cmp    %eax,%esi
f0104574:	73 33                	jae    f01045a9 <memmove+0x45>
f0104576:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104579:	39 c2                	cmp    %eax,%edx
f010457b:	76 2c                	jbe    f01045a9 <memmove+0x45>
		s += n;
		d += n;
f010457d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104580:	89 d6                	mov    %edx,%esi
f0104582:	09 fe                	or     %edi,%esi
f0104584:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010458a:	74 0a                	je     f0104596 <memmove+0x32>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010458c:	4f                   	dec    %edi
f010458d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0104590:	fd                   	std    
f0104591:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104593:	fc                   	cld    
f0104594:	eb 21                	jmp    f01045b7 <memmove+0x53>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104596:	f6 c1 03             	test   $0x3,%cl
f0104599:	75 f1                	jne    f010458c <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010459b:	83 ef 04             	sub    $0x4,%edi
f010459e:	8d 72 fc             	lea    -0x4(%edx),%esi
f01045a1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01045a4:	fd                   	std    
f01045a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01045a7:	eb ea                	jmp    f0104593 <memmove+0x2f>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01045a9:	89 f2                	mov    %esi,%edx
f01045ab:	09 c2                	or     %eax,%edx
f01045ad:	f6 c2 03             	test   $0x3,%dl
f01045b0:	74 09                	je     f01045bb <memmove+0x57>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01045b2:	89 c7                	mov    %eax,%edi
f01045b4:	fc                   	cld    
f01045b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01045b7:	5e                   	pop    %esi
f01045b8:	5f                   	pop    %edi
f01045b9:	5d                   	pop    %ebp
f01045ba:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01045bb:	f6 c1 03             	test   $0x3,%cl
f01045be:	75 f2                	jne    f01045b2 <memmove+0x4e>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01045c0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01045c3:	89 c7                	mov    %eax,%edi
f01045c5:	fc                   	cld    
f01045c6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01045c8:	eb ed                	jmp    f01045b7 <memmove+0x53>

f01045ca <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01045ca:	55                   	push   %ebp
f01045cb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01045cd:	ff 75 10             	pushl  0x10(%ebp)
f01045d0:	ff 75 0c             	pushl  0xc(%ebp)
f01045d3:	ff 75 08             	pushl  0x8(%ebp)
f01045d6:	e8 89 ff ff ff       	call   f0104564 <memmove>
}
f01045db:	c9                   	leave  
f01045dc:	c3                   	ret    

f01045dd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01045dd:	55                   	push   %ebp
f01045de:	89 e5                	mov    %esp,%ebp
f01045e0:	56                   	push   %esi
f01045e1:	53                   	push   %ebx
f01045e2:	8b 45 08             	mov    0x8(%ebp),%eax
f01045e5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01045e8:	89 c6                	mov    %eax,%esi
f01045ea:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01045ed:	39 f0                	cmp    %esi,%eax
f01045ef:	74 16                	je     f0104607 <memcmp+0x2a>
		if (*s1 != *s2)
f01045f1:	8a 08                	mov    (%eax),%cl
f01045f3:	8a 1a                	mov    (%edx),%bl
f01045f5:	38 d9                	cmp    %bl,%cl
f01045f7:	75 04                	jne    f01045fd <memcmp+0x20>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01045f9:	40                   	inc    %eax
f01045fa:	42                   	inc    %edx
f01045fb:	eb f0                	jmp    f01045ed <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f01045fd:	0f b6 c1             	movzbl %cl,%eax
f0104600:	0f b6 db             	movzbl %bl,%ebx
f0104603:	29 d8                	sub    %ebx,%eax
f0104605:	eb 05                	jmp    f010460c <memcmp+0x2f>
	}

	return 0;
f0104607:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010460c:	5b                   	pop    %ebx
f010460d:	5e                   	pop    %esi
f010460e:	5d                   	pop    %ebp
f010460f:	c3                   	ret    

f0104610 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104610:	55                   	push   %ebp
f0104611:	89 e5                	mov    %esp,%ebp
f0104613:	8b 45 08             	mov    0x8(%ebp),%eax
f0104616:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0104619:	89 c2                	mov    %eax,%edx
f010461b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010461e:	39 d0                	cmp    %edx,%eax
f0104620:	73 07                	jae    f0104629 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104622:	38 08                	cmp    %cl,(%eax)
f0104624:	74 03                	je     f0104629 <memfind+0x19>
	for (; s < ends; s++)
f0104626:	40                   	inc    %eax
f0104627:	eb f5                	jmp    f010461e <memfind+0xe>
			break;
	return (void *) s;
}
f0104629:	5d                   	pop    %ebp
f010462a:	c3                   	ret    

f010462b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010462b:	55                   	push   %ebp
f010462c:	89 e5                	mov    %esp,%ebp
f010462e:	57                   	push   %edi
f010462f:	56                   	push   %esi
f0104630:	53                   	push   %ebx
f0104631:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104634:	eb 01                	jmp    f0104637 <strtol+0xc>
		s++;
f0104636:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f0104637:	8a 01                	mov    (%ecx),%al
f0104639:	3c 20                	cmp    $0x20,%al
f010463b:	74 f9                	je     f0104636 <strtol+0xb>
f010463d:	3c 09                	cmp    $0x9,%al
f010463f:	74 f5                	je     f0104636 <strtol+0xb>

	// plus/minus sign
	if (*s == '+')
f0104641:	3c 2b                	cmp    $0x2b,%al
f0104643:	74 2b                	je     f0104670 <strtol+0x45>
		s++;
	else if (*s == '-')
f0104645:	3c 2d                	cmp    $0x2d,%al
f0104647:	74 2f                	je     f0104678 <strtol+0x4d>
	int neg = 0;
f0104649:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010464e:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f0104655:	75 12                	jne    f0104669 <strtol+0x3e>
f0104657:	80 39 30             	cmpb   $0x30,(%ecx)
f010465a:	74 24                	je     f0104680 <strtol+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010465c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0104660:	75 07                	jne    f0104669 <strtol+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104662:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f0104669:	b8 00 00 00 00       	mov    $0x0,%eax
f010466e:	eb 4e                	jmp    f01046be <strtol+0x93>
		s++;
f0104670:	41                   	inc    %ecx
	int neg = 0;
f0104671:	bf 00 00 00 00       	mov    $0x0,%edi
f0104676:	eb d6                	jmp    f010464e <strtol+0x23>
		s++, neg = 1;
f0104678:	41                   	inc    %ecx
f0104679:	bf 01 00 00 00       	mov    $0x1,%edi
f010467e:	eb ce                	jmp    f010464e <strtol+0x23>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104680:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0104684:	74 10                	je     f0104696 <strtol+0x6b>
	else if (base == 0 && s[0] == '0')
f0104686:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010468a:	75 dd                	jne    f0104669 <strtol+0x3e>
		s++, base = 8;
f010468c:	41                   	inc    %ecx
f010468d:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f0104694:	eb d3                	jmp    f0104669 <strtol+0x3e>
		s += 2, base = 16;
f0104696:	83 c1 02             	add    $0x2,%ecx
f0104699:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f01046a0:	eb c7                	jmp    f0104669 <strtol+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01046a2:	8d 72 9f             	lea    -0x61(%edx),%esi
f01046a5:	89 f3                	mov    %esi,%ebx
f01046a7:	80 fb 19             	cmp    $0x19,%bl
f01046aa:	77 24                	ja     f01046d0 <strtol+0xa5>
			dig = *s - 'a' + 10;
f01046ac:	0f be d2             	movsbl %dl,%edx
f01046af:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01046b2:	3b 55 10             	cmp    0x10(%ebp),%edx
f01046b5:	7d 2b                	jge    f01046e2 <strtol+0xb7>
			break;
		s++, val = (val * base) + dig;
f01046b7:	41                   	inc    %ecx
f01046b8:	0f af 45 10          	imul   0x10(%ebp),%eax
f01046bc:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01046be:	8a 11                	mov    (%ecx),%dl
f01046c0:	8d 5a d0             	lea    -0x30(%edx),%ebx
f01046c3:	80 fb 09             	cmp    $0x9,%bl
f01046c6:	77 da                	ja     f01046a2 <strtol+0x77>
			dig = *s - '0';
f01046c8:	0f be d2             	movsbl %dl,%edx
f01046cb:	83 ea 30             	sub    $0x30,%edx
f01046ce:	eb e2                	jmp    f01046b2 <strtol+0x87>
		else if (*s >= 'A' && *s <= 'Z')
f01046d0:	8d 72 bf             	lea    -0x41(%edx),%esi
f01046d3:	89 f3                	mov    %esi,%ebx
f01046d5:	80 fb 19             	cmp    $0x19,%bl
f01046d8:	77 08                	ja     f01046e2 <strtol+0xb7>
			dig = *s - 'A' + 10;
f01046da:	0f be d2             	movsbl %dl,%edx
f01046dd:	83 ea 37             	sub    $0x37,%edx
f01046e0:	eb d0                	jmp    f01046b2 <strtol+0x87>
		// we don't properly detect overflow!
	}

	if (endptr)
f01046e2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01046e6:	74 05                	je     f01046ed <strtol+0xc2>
		*endptr = (char *) s;
f01046e8:	8b 75 0c             	mov    0xc(%ebp),%esi
f01046eb:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f01046ed:	85 ff                	test   %edi,%edi
f01046ef:	74 02                	je     f01046f3 <strtol+0xc8>
f01046f1:	f7 d8                	neg    %eax
}
f01046f3:	5b                   	pop    %ebx
f01046f4:	5e                   	pop    %esi
f01046f5:	5f                   	pop    %edi
f01046f6:	5d                   	pop    %ebp
f01046f7:	c3                   	ret    

f01046f8 <strtoul>:

unsigned long
strtoul(const char *s, char **endptr, int base)
{
f01046f8:	55                   	push   %ebp
f01046f9:	89 e5                	mov    %esp,%ebp
f01046fb:	57                   	push   %edi
f01046fc:	56                   	push   %esi
f01046fd:	53                   	push   %ebx
f01046fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int neg = 0;
	unsigned long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104701:	eb 01                	jmp    f0104704 <strtoul+0xc>
		s++;
f0104703:	41                   	inc    %ecx
	while (*s == ' ' || *s == '\t')
f0104704:	8a 01                	mov    (%ecx),%al
f0104706:	3c 20                	cmp    $0x20,%al
f0104708:	74 f9                	je     f0104703 <strtoul+0xb>
f010470a:	3c 09                	cmp    $0x9,%al
f010470c:	74 f5                	je     f0104703 <strtoul+0xb>

	// plus/minus sign
	if (*s == '+')
f010470e:	3c 2b                	cmp    $0x2b,%al
f0104710:	74 2b                	je     f010473d <strtoul+0x45>
		s++;
	else if (*s == '-')
f0104712:	3c 2d                	cmp    $0x2d,%al
f0104714:	74 2f                	je     f0104745 <strtoul+0x4d>
	int neg = 0;
f0104716:	bf 00 00 00 00       	mov    $0x0,%edi
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010471b:	f7 45 10 ef ff ff ff 	testl  $0xffffffef,0x10(%ebp)
f0104722:	75 12                	jne    f0104736 <strtoul+0x3e>
f0104724:	80 39 30             	cmpb   $0x30,(%ecx)
f0104727:	74 24                	je     f010474d <strtoul+0x55>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104729:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010472d:	75 07                	jne    f0104736 <strtoul+0x3e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010472f:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)
f0104736:	b8 00 00 00 00       	mov    $0x0,%eax
f010473b:	eb 4e                	jmp    f010478b <strtoul+0x93>
		s++;
f010473d:	41                   	inc    %ecx
	int neg = 0;
f010473e:	bf 00 00 00 00       	mov    $0x0,%edi
f0104743:	eb d6                	jmp    f010471b <strtoul+0x23>
		s++, neg = 1;
f0104745:	41                   	inc    %ecx
f0104746:	bf 01 00 00 00       	mov    $0x1,%edi
f010474b:	eb ce                	jmp    f010471b <strtoul+0x23>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010474d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0104751:	74 10                	je     f0104763 <strtoul+0x6b>
	else if (base == 0 && s[0] == '0')
f0104753:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0104757:	75 dd                	jne    f0104736 <strtoul+0x3e>
		s++, base = 8;
f0104759:	41                   	inc    %ecx
f010475a:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f0104761:	eb d3                	jmp    f0104736 <strtoul+0x3e>
		s += 2, base = 16;
f0104763:	83 c1 02             	add    $0x2,%ecx
f0104766:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f010476d:	eb c7                	jmp    f0104736 <strtoul+0x3e>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f010476f:	8d 72 9f             	lea    -0x61(%edx),%esi
f0104772:	89 f3                	mov    %esi,%ebx
f0104774:	80 fb 19             	cmp    $0x19,%bl
f0104777:	77 24                	ja     f010479d <strtoul+0xa5>
			dig = *s - 'a' + 10;
f0104779:	0f be d2             	movsbl %dl,%edx
f010477c:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010477f:	3b 55 10             	cmp    0x10(%ebp),%edx
f0104782:	7d 2b                	jge    f01047af <strtoul+0xb7>
			break;
		s++, val = (val * base) + dig;
f0104784:	41                   	inc    %ecx
f0104785:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104789:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f010478b:	8a 11                	mov    (%ecx),%dl
f010478d:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0104790:	80 fb 09             	cmp    $0x9,%bl
f0104793:	77 da                	ja     f010476f <strtoul+0x77>
			dig = *s - '0';
f0104795:	0f be d2             	movsbl %dl,%edx
f0104798:	83 ea 30             	sub    $0x30,%edx
f010479b:	eb e2                	jmp    f010477f <strtoul+0x87>
		else if (*s >= 'A' && *s <= 'Z')
f010479d:	8d 72 bf             	lea    -0x41(%edx),%esi
f01047a0:	89 f3                	mov    %esi,%ebx
f01047a2:	80 fb 19             	cmp    $0x19,%bl
f01047a5:	77 08                	ja     f01047af <strtoul+0xb7>
			dig = *s - 'A' + 10;
f01047a7:	0f be d2             	movsbl %dl,%edx
f01047aa:	83 ea 37             	sub    $0x37,%edx
f01047ad:	eb d0                	jmp    f010477f <strtoul+0x87>
		// we don't properly detect overflow!
	}

	if (endptr)
f01047af:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01047b3:	74 05                	je     f01047ba <strtoul+0xc2>
		*endptr = (char *) s;
f01047b5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01047b8:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f01047ba:	85 ff                	test   %edi,%edi
f01047bc:	74 02                	je     f01047c0 <strtoul+0xc8>
f01047be:	f7 d8                	neg    %eax
}
f01047c0:	5b                   	pop    %ebx
f01047c1:	5e                   	pop    %esi
f01047c2:	5f                   	pop    %edi
f01047c3:	5d                   	pop    %ebp
f01047c4:	c3                   	ret    
f01047c5:	66 90                	xchg   %ax,%ax
f01047c7:	90                   	nop

f01047c8 <__udivdi3>:
f01047c8:	55                   	push   %ebp
f01047c9:	57                   	push   %edi
f01047ca:	56                   	push   %esi
f01047cb:	53                   	push   %ebx
f01047cc:	83 ec 1c             	sub    $0x1c,%esp
f01047cf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01047d3:	8b 74 24 34          	mov    0x34(%esp),%esi
f01047d7:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01047db:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01047df:	85 d2                	test   %edx,%edx
f01047e1:	75 2d                	jne    f0104810 <__udivdi3+0x48>
f01047e3:	39 f7                	cmp    %esi,%edi
f01047e5:	77 59                	ja     f0104840 <__udivdi3+0x78>
f01047e7:	89 f9                	mov    %edi,%ecx
f01047e9:	85 ff                	test   %edi,%edi
f01047eb:	75 0b                	jne    f01047f8 <__udivdi3+0x30>
f01047ed:	b8 01 00 00 00       	mov    $0x1,%eax
f01047f2:	31 d2                	xor    %edx,%edx
f01047f4:	f7 f7                	div    %edi
f01047f6:	89 c1                	mov    %eax,%ecx
f01047f8:	31 d2                	xor    %edx,%edx
f01047fa:	89 f0                	mov    %esi,%eax
f01047fc:	f7 f1                	div    %ecx
f01047fe:	89 c3                	mov    %eax,%ebx
f0104800:	89 e8                	mov    %ebp,%eax
f0104802:	f7 f1                	div    %ecx
f0104804:	89 da                	mov    %ebx,%edx
f0104806:	83 c4 1c             	add    $0x1c,%esp
f0104809:	5b                   	pop    %ebx
f010480a:	5e                   	pop    %esi
f010480b:	5f                   	pop    %edi
f010480c:	5d                   	pop    %ebp
f010480d:	c3                   	ret    
f010480e:	66 90                	xchg   %ax,%ax
f0104810:	39 f2                	cmp    %esi,%edx
f0104812:	77 1c                	ja     f0104830 <__udivdi3+0x68>
f0104814:	0f bd da             	bsr    %edx,%ebx
f0104817:	83 f3 1f             	xor    $0x1f,%ebx
f010481a:	75 38                	jne    f0104854 <__udivdi3+0x8c>
f010481c:	39 f2                	cmp    %esi,%edx
f010481e:	72 08                	jb     f0104828 <__udivdi3+0x60>
f0104820:	39 ef                	cmp    %ebp,%edi
f0104822:	0f 87 98 00 00 00    	ja     f01048c0 <__udivdi3+0xf8>
f0104828:	b8 01 00 00 00       	mov    $0x1,%eax
f010482d:	eb 05                	jmp    f0104834 <__udivdi3+0x6c>
f010482f:	90                   	nop
f0104830:	31 db                	xor    %ebx,%ebx
f0104832:	31 c0                	xor    %eax,%eax
f0104834:	89 da                	mov    %ebx,%edx
f0104836:	83 c4 1c             	add    $0x1c,%esp
f0104839:	5b                   	pop    %ebx
f010483a:	5e                   	pop    %esi
f010483b:	5f                   	pop    %edi
f010483c:	5d                   	pop    %ebp
f010483d:	c3                   	ret    
f010483e:	66 90                	xchg   %ax,%ax
f0104840:	89 e8                	mov    %ebp,%eax
f0104842:	89 f2                	mov    %esi,%edx
f0104844:	f7 f7                	div    %edi
f0104846:	31 db                	xor    %ebx,%ebx
f0104848:	89 da                	mov    %ebx,%edx
f010484a:	83 c4 1c             	add    $0x1c,%esp
f010484d:	5b                   	pop    %ebx
f010484e:	5e                   	pop    %esi
f010484f:	5f                   	pop    %edi
f0104850:	5d                   	pop    %ebp
f0104851:	c3                   	ret    
f0104852:	66 90                	xchg   %ax,%ax
f0104854:	b8 20 00 00 00       	mov    $0x20,%eax
f0104859:	29 d8                	sub    %ebx,%eax
f010485b:	88 d9                	mov    %bl,%cl
f010485d:	d3 e2                	shl    %cl,%edx
f010485f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104863:	89 fa                	mov    %edi,%edx
f0104865:	88 c1                	mov    %al,%cl
f0104867:	d3 ea                	shr    %cl,%edx
f0104869:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f010486d:	09 d1                	or     %edx,%ecx
f010486f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104873:	88 d9                	mov    %bl,%cl
f0104875:	d3 e7                	shl    %cl,%edi
f0104877:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010487b:	89 f7                	mov    %esi,%edi
f010487d:	88 c1                	mov    %al,%cl
f010487f:	d3 ef                	shr    %cl,%edi
f0104881:	88 d9                	mov    %bl,%cl
f0104883:	d3 e6                	shl    %cl,%esi
f0104885:	89 ea                	mov    %ebp,%edx
f0104887:	88 c1                	mov    %al,%cl
f0104889:	d3 ea                	shr    %cl,%edx
f010488b:	09 d6                	or     %edx,%esi
f010488d:	89 f0                	mov    %esi,%eax
f010488f:	89 fa                	mov    %edi,%edx
f0104891:	f7 74 24 08          	divl   0x8(%esp)
f0104895:	89 d7                	mov    %edx,%edi
f0104897:	89 c6                	mov    %eax,%esi
f0104899:	f7 64 24 0c          	mull   0xc(%esp)
f010489d:	39 d7                	cmp    %edx,%edi
f010489f:	72 13                	jb     f01048b4 <__udivdi3+0xec>
f01048a1:	74 09                	je     f01048ac <__udivdi3+0xe4>
f01048a3:	89 f0                	mov    %esi,%eax
f01048a5:	31 db                	xor    %ebx,%ebx
f01048a7:	eb 8b                	jmp    f0104834 <__udivdi3+0x6c>
f01048a9:	8d 76 00             	lea    0x0(%esi),%esi
f01048ac:	88 d9                	mov    %bl,%cl
f01048ae:	d3 e5                	shl    %cl,%ebp
f01048b0:	39 c5                	cmp    %eax,%ebp
f01048b2:	73 ef                	jae    f01048a3 <__udivdi3+0xdb>
f01048b4:	8d 46 ff             	lea    -0x1(%esi),%eax
f01048b7:	31 db                	xor    %ebx,%ebx
f01048b9:	e9 76 ff ff ff       	jmp    f0104834 <__udivdi3+0x6c>
f01048be:	66 90                	xchg   %ax,%ax
f01048c0:	31 c0                	xor    %eax,%eax
f01048c2:	e9 6d ff ff ff       	jmp    f0104834 <__udivdi3+0x6c>
f01048c7:	90                   	nop

f01048c8 <__umoddi3>:
f01048c8:	55                   	push   %ebp
f01048c9:	57                   	push   %edi
f01048ca:	56                   	push   %esi
f01048cb:	53                   	push   %ebx
f01048cc:	83 ec 1c             	sub    $0x1c,%esp
f01048cf:	8b 74 24 30          	mov    0x30(%esp),%esi
f01048d3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01048d7:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01048db:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f01048df:	89 f0                	mov    %esi,%eax
f01048e1:	89 da                	mov    %ebx,%edx
f01048e3:	85 ed                	test   %ebp,%ebp
f01048e5:	75 15                	jne    f01048fc <__umoddi3+0x34>
f01048e7:	39 df                	cmp    %ebx,%edi
f01048e9:	76 39                	jbe    f0104924 <__umoddi3+0x5c>
f01048eb:	f7 f7                	div    %edi
f01048ed:	89 d0                	mov    %edx,%eax
f01048ef:	31 d2                	xor    %edx,%edx
f01048f1:	83 c4 1c             	add    $0x1c,%esp
f01048f4:	5b                   	pop    %ebx
f01048f5:	5e                   	pop    %esi
f01048f6:	5f                   	pop    %edi
f01048f7:	5d                   	pop    %ebp
f01048f8:	c3                   	ret    
f01048f9:	8d 76 00             	lea    0x0(%esi),%esi
f01048fc:	39 dd                	cmp    %ebx,%ebp
f01048fe:	77 f1                	ja     f01048f1 <__umoddi3+0x29>
f0104900:	0f bd cd             	bsr    %ebp,%ecx
f0104903:	83 f1 1f             	xor    $0x1f,%ecx
f0104906:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010490a:	75 38                	jne    f0104944 <__umoddi3+0x7c>
f010490c:	39 dd                	cmp    %ebx,%ebp
f010490e:	72 04                	jb     f0104914 <__umoddi3+0x4c>
f0104910:	39 f7                	cmp    %esi,%edi
f0104912:	77 dd                	ja     f01048f1 <__umoddi3+0x29>
f0104914:	89 da                	mov    %ebx,%edx
f0104916:	89 f0                	mov    %esi,%eax
f0104918:	29 f8                	sub    %edi,%eax
f010491a:	19 ea                	sbb    %ebp,%edx
f010491c:	83 c4 1c             	add    $0x1c,%esp
f010491f:	5b                   	pop    %ebx
f0104920:	5e                   	pop    %esi
f0104921:	5f                   	pop    %edi
f0104922:	5d                   	pop    %ebp
f0104923:	c3                   	ret    
f0104924:	89 f9                	mov    %edi,%ecx
f0104926:	85 ff                	test   %edi,%edi
f0104928:	75 0b                	jne    f0104935 <__umoddi3+0x6d>
f010492a:	b8 01 00 00 00       	mov    $0x1,%eax
f010492f:	31 d2                	xor    %edx,%edx
f0104931:	f7 f7                	div    %edi
f0104933:	89 c1                	mov    %eax,%ecx
f0104935:	89 d8                	mov    %ebx,%eax
f0104937:	31 d2                	xor    %edx,%edx
f0104939:	f7 f1                	div    %ecx
f010493b:	89 f0                	mov    %esi,%eax
f010493d:	f7 f1                	div    %ecx
f010493f:	eb ac                	jmp    f01048ed <__umoddi3+0x25>
f0104941:	8d 76 00             	lea    0x0(%esi),%esi
f0104944:	b8 20 00 00 00       	mov    $0x20,%eax
f0104949:	89 c2                	mov    %eax,%edx
f010494b:	8b 44 24 04          	mov    0x4(%esp),%eax
f010494f:	29 c2                	sub    %eax,%edx
f0104951:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104955:	88 c1                	mov    %al,%cl
f0104957:	d3 e5                	shl    %cl,%ebp
f0104959:	89 f8                	mov    %edi,%eax
f010495b:	88 d1                	mov    %dl,%cl
f010495d:	d3 e8                	shr    %cl,%eax
f010495f:	09 c5                	or     %eax,%ebp
f0104961:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104965:	88 c1                	mov    %al,%cl
f0104967:	d3 e7                	shl    %cl,%edi
f0104969:	89 7c 24 08          	mov    %edi,0x8(%esp)
f010496d:	89 df                	mov    %ebx,%edi
f010496f:	88 d1                	mov    %dl,%cl
f0104971:	d3 ef                	shr    %cl,%edi
f0104973:	88 c1                	mov    %al,%cl
f0104975:	d3 e3                	shl    %cl,%ebx
f0104977:	89 f0                	mov    %esi,%eax
f0104979:	88 d1                	mov    %dl,%cl
f010497b:	d3 e8                	shr    %cl,%eax
f010497d:	09 d8                	or     %ebx,%eax
f010497f:	8a 4c 24 04          	mov    0x4(%esp),%cl
f0104983:	d3 e6                	shl    %cl,%esi
f0104985:	89 fa                	mov    %edi,%edx
f0104987:	f7 f5                	div    %ebp
f0104989:	89 d1                	mov    %edx,%ecx
f010498b:	f7 64 24 08          	mull   0x8(%esp)
f010498f:	89 c3                	mov    %eax,%ebx
f0104991:	89 d7                	mov    %edx,%edi
f0104993:	39 d1                	cmp    %edx,%ecx
f0104995:	72 29                	jb     f01049c0 <__umoddi3+0xf8>
f0104997:	74 23                	je     f01049bc <__umoddi3+0xf4>
f0104999:	89 ca                	mov    %ecx,%edx
f010499b:	29 de                	sub    %ebx,%esi
f010499d:	19 fa                	sbb    %edi,%edx
f010499f:	89 d0                	mov    %edx,%eax
f01049a1:	8a 4c 24 0c          	mov    0xc(%esp),%cl
f01049a5:	d3 e0                	shl    %cl,%eax
f01049a7:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f01049ab:	88 d9                	mov    %bl,%cl
f01049ad:	d3 ee                	shr    %cl,%esi
f01049af:	09 f0                	or     %esi,%eax
f01049b1:	d3 ea                	shr    %cl,%edx
f01049b3:	83 c4 1c             	add    $0x1c,%esp
f01049b6:	5b                   	pop    %ebx
f01049b7:	5e                   	pop    %esi
f01049b8:	5f                   	pop    %edi
f01049b9:	5d                   	pop    %ebp
f01049ba:	c3                   	ret    
f01049bb:	90                   	nop
f01049bc:	39 c6                	cmp    %eax,%esi
f01049be:	73 d9                	jae    f0104999 <__umoddi3+0xd1>
f01049c0:	2b 44 24 08          	sub    0x8(%esp),%eax
f01049c4:	19 ea                	sbb    %ebp,%edx
f01049c6:	89 d7                	mov    %edx,%edi
f01049c8:	89 c3                	mov    %eax,%ebx
f01049ca:	eb cd                	jmp    f0104999 <__umoddi3+0xd1>
