
obj/boot/boot.out:     file format elf32-i386


Disassembly of section .text:

00007c00 <start>:
.set CR0_PE_ON,      0x1         # protected mode enable flag

.globl start
start:
  .code16                     # Assemble for 16-bit mode
  cli                         # Disable interrupts
    7c00:	fa                   	cli    
  cld                         # String operations increment
    7c01:	fc                   	cld    

  # Set up the important data segment registers (DS, ES, SS).
  xorw    %ax,%ax             # Segment number zero
    7c02:	31 c0                	xor    %eax,%eax
  movw    %ax,%ds             # -> Data Segment
    7c04:	8e d8                	mov    %eax,%ds
  movw    %ax,%es             # -> Extra Segment
    7c06:	8e c0                	mov    %eax,%es
  movw    %ax,%ss             # -> Stack Segment
    7c08:	8e d0                	mov    %eax,%ss

00007c0a <seta20.1>:
  # Enable A20:
  #   For backwards compatibility with the earliest PCs, physical
  #   address line 20 is tied low, so that addresses higher than
  #   1MB wrap around to zero by default.  This code undoes this.
seta20.1:
  inb     $0x64,%al               # Wait for not busy
    7c0a:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    7c0c:	a8 02                	test   $0x2,%al
  jnz     seta20.1
    7c0e:	75 fa                	jne    7c0a <seta20.1>

  movb    $0xd1,%al               # 0xd1 -> port 0x64
    7c10:	b0 d1                	mov    $0xd1,%al
  outb    %al,$0x64
    7c12:	e6 64                	out    %al,$0x64

00007c14 <seta20.2>:

seta20.2:
  inb     $0x64,%al               # Wait for not busy
    7c14:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    7c16:	a8 02                	test   $0x2,%al
  jnz     seta20.2
    7c18:	75 fa                	jne    7c14 <seta20.2>

  movb    $0xdf,%al               # 0xdf -> port 0x60
    7c1a:	b0 df                	mov    $0xdf,%al
  outb    %al,$0x60
    7c1c:	e6 60                	out    %al,$0x60

  # Switch from real to protected mode, using a bootstrap GDT
  # and segment translation that makes virtual addresses 
  # identical to their physical addresses, so that the 
  # effective memory map does not change during the switch.
  lgdt    gdtdesc
    7c1e:	0f 01 16             	lgdtl  (%esi)
    7c21:	64 7c 0f             	fs jl  7c33 <protcseg+0x1>
  movl    %cr0, %eax
    7c24:	20 c0                	and    %al,%al
  orl     $CR0_PE_ON, %eax
    7c26:	66 83 c8 01          	or     $0x1,%ax
  movl    %eax, %cr0
    7c2a:	0f 22 c0             	mov    %eax,%cr0
  
  # Jump to next instruction, but in 32-bit code segment.
  # Switches processor into 32-bit mode.
  ljmp    $PROT_MODE_CSEG, $protcseg
    7c2d:	ea                   	.byte 0xea
    7c2e:	32 7c 08 00          	xor    0x0(%eax,%ecx,1),%bh

00007c32 <protcseg>:

  .code32                     # Assemble for 32-bit mode
protcseg:
  # Set up the protected-mode data segment registers
  movw    $PROT_MODE_DSEG, %ax    # Our data segment selector
    7c32:	66 b8 10 00          	mov    $0x10,%ax
  movw    %ax, %ds                # -> DS: Data Segment
    7c36:	8e d8                	mov    %eax,%ds
  movw    %ax, %es                # -> ES: Extra Segment
    7c38:	8e c0                	mov    %eax,%es
  movw    %ax, %fs                # -> FS
    7c3a:	8e e0                	mov    %eax,%fs
  movw    %ax, %gs                # -> GS
    7c3c:	8e e8                	mov    %eax,%gs
  movw    %ax, %ss                # -> SS: Stack Segment
    7c3e:	8e d0                	mov    %eax,%ss
  
  # Set up the stack pointer and call into C.
  movl    $start, %esp
    7c40:	bc 00 7c 00 00       	mov    $0x7c00,%esp
  call bootmain
    7c45:	e8 cb 00 00 00       	call   7d15 <bootmain>

00007c4a <spin>:

  # If bootmain returns (it shouldn't), loop.
spin:
  jmp spin
    7c4a:	eb fe                	jmp    7c4a <spin>

00007c4c <gdt>:
	...
    7c54:	ff                   	(bad)  
    7c55:	ff 00                	incl   (%eax)
    7c57:	00 00                	add    %al,(%eax)
    7c59:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    7c60:	00                   	.byte 0x0
    7c61:	92                   	xchg   %eax,%edx
    7c62:	cf                   	iret   
	...

00007c64 <gdtdesc>:
    7c64:	17                   	pop    %ss
    7c65:	00 4c 7c 00          	add    %cl,0x0(%esp,%edi,2)
	...

00007c6a <waitdisk>:
	}
}

void
waitdisk(void)
{
    7c6a:	55                   	push   %ebp
    7c6b:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
    7c6d:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7c72:	ec                   	in     (%dx),%al
	// wait for disk reaady
	while ((inb(0x1F7) & 0xC0) != 0x40)
    7c73:	83 e0 c0             	and    $0xffffffc0,%eax
    7c76:	3c 40                	cmp    $0x40,%al
    7c78:	75 f8                	jne    7c72 <waitdisk+0x8>
		/* do nothing */;
}
    7c7a:	5d                   	pop    %ebp
    7c7b:	c3                   	ret    

00007c7c <readsect>:

void
readsect(void *dst, uint32_t offset)
{
    7c7c:	55                   	push   %ebp
    7c7d:	89 e5                	mov    %esp,%ebp
    7c7f:	57                   	push   %edi
    7c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// wait for disk to be ready
	waitdisk();
    7c83:	e8 e2 ff ff ff       	call   7c6a <waitdisk>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
    7c88:	b0 01                	mov    $0x1,%al
    7c8a:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7c8f:	ee                   	out    %al,(%dx)
    7c90:	ba f3 01 00 00       	mov    $0x1f3,%edx
    7c95:	88 c8                	mov    %cl,%al
    7c97:	ee                   	out    %al,(%dx)

	outb(0x1F2, 1);		// count = 1
	outb(0x1F3, offset);
	outb(0x1F4, offset >> 8);
    7c98:	89 c8                	mov    %ecx,%eax
    7c9a:	c1 e8 08             	shr    $0x8,%eax
    7c9d:	ba f4 01 00 00       	mov    $0x1f4,%edx
    7ca2:	ee                   	out    %al,(%dx)
	outb(0x1F5, offset >> 16);
    7ca3:	89 c8                	mov    %ecx,%eax
    7ca5:	c1 e8 10             	shr    $0x10,%eax
    7ca8:	ba f5 01 00 00       	mov    $0x1f5,%edx
    7cad:	ee                   	out    %al,(%dx)
	outb(0x1F6, (offset >> 24) | 0xE0);
    7cae:	89 c8                	mov    %ecx,%eax
    7cb0:	c1 e8 18             	shr    $0x18,%eax
    7cb3:	83 c8 e0             	or     $0xffffffe0,%eax
    7cb6:	ba f6 01 00 00       	mov    $0x1f6,%edx
    7cbb:	ee                   	out    %al,(%dx)
    7cbc:	b0 20                	mov    $0x20,%al
    7cbe:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7cc3:	ee                   	out    %al,(%dx)
	outb(0x1F7, 0x20);	// cmd 0x20 - read sectors

	// wait for disk to be ready
	waitdisk();
    7cc4:	e8 a1 ff ff ff       	call   7c6a <waitdisk>
	asm volatile("cld\n\trepne\n\tinsl"
    7cc9:	8b 7d 08             	mov    0x8(%ebp),%edi
    7ccc:	b9 80 00 00 00       	mov    $0x80,%ecx
    7cd1:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7cd6:	fc                   	cld    
    7cd7:	f2 6d                	repnz insl (%dx),%es:(%edi)

	// read a sector
	insl(0x1F0, dst, SECTSIZE/4);
}
    7cd9:	5f                   	pop    %edi
    7cda:	5d                   	pop    %ebp
    7cdb:	c3                   	ret    

00007cdc <readseg>:
{
    7cdc:	55                   	push   %ebp
    7cdd:	89 e5                	mov    %esp,%ebp
    7cdf:	57                   	push   %edi
    7ce0:	56                   	push   %esi
    7ce1:	53                   	push   %ebx
    7ce2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	end_pa = pa + count;
    7ce5:	8b 75 0c             	mov    0xc(%ebp),%esi
    7ce8:	01 de                	add    %ebx,%esi
	pa &= ~(SECTSIZE - 1);
    7cea:	81 e3 00 fe ff ff    	and    $0xfffffe00,%ebx
	offset = (offset / SECTSIZE) + 1;
    7cf0:	8b 7d 10             	mov    0x10(%ebp),%edi
    7cf3:	c1 ef 09             	shr    $0x9,%edi
    7cf6:	47                   	inc    %edi
	while (pa < end_pa) {
    7cf7:	39 f3                	cmp    %esi,%ebx
    7cf9:	73 12                	jae    7d0d <readseg+0x31>
		readsect((uint8_t*) pa, offset);
    7cfb:	57                   	push   %edi
    7cfc:	53                   	push   %ebx
    7cfd:	e8 7a ff ff ff       	call   7c7c <readsect>
		pa += SECTSIZE;
    7d02:	81 c3 00 02 00 00    	add    $0x200,%ebx
		offset++;
    7d08:	47                   	inc    %edi
    7d09:	58                   	pop    %eax
    7d0a:	5a                   	pop    %edx
    7d0b:	eb ea                	jmp    7cf7 <readseg+0x1b>
}
    7d0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
    7d10:	5b                   	pop    %ebx
    7d11:	5e                   	pop    %esi
    7d12:	5f                   	pop    %edi
    7d13:	5d                   	pop    %ebp
    7d14:	c3                   	ret    

00007d15 <bootmain>:
{
    7d15:	55                   	push   %ebp
    7d16:	89 e5                	mov    %esp,%ebp
    7d18:	56                   	push   %esi
    7d19:	53                   	push   %ebx
	readseg((uint32_t) ELFHDR, SECTSIZE*8, 0);
    7d1a:	6a 00                	push   $0x0
    7d1c:	68 00 10 00 00       	push   $0x1000
    7d21:	68 00 00 01 00       	push   $0x10000
    7d26:	e8 b1 ff ff ff       	call   7cdc <readseg>
	if (ELFHDR->e_magic != ELF_MAGIC)
    7d2b:	83 c4 0c             	add    $0xc,%esp
    7d2e:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7d35:	45 4c 46 
    7d38:	75 37                	jne    7d71 <bootmain+0x5c>
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
    7d3a:	a1 1c 00 01 00       	mov    0x1001c,%eax
    7d3f:	8d 98 00 00 01 00    	lea    0x10000(%eax),%ebx
	eph = ph + ELFHDR->e_phnum;
    7d45:	0f b7 35 2c 00 01 00 	movzwl 0x1002c,%esi
    7d4c:	c1 e6 05             	shl    $0x5,%esi
    7d4f:	01 de                	add    %ebx,%esi
	for (; ph < eph; ph++)
    7d51:	39 f3                	cmp    %esi,%ebx
    7d53:	73 16                	jae    7d6b <bootmain+0x56>
		readseg(ph->p_pa, ph->p_memsz, ph->p_offset);
    7d55:	ff 73 04             	pushl  0x4(%ebx)
    7d58:	ff 73 14             	pushl  0x14(%ebx)
    7d5b:	ff 73 0c             	pushl  0xc(%ebx)
    7d5e:	e8 79 ff ff ff       	call   7cdc <readseg>
	for (; ph < eph; ph++)
    7d63:	83 c3 20             	add    $0x20,%ebx
    7d66:	83 c4 0c             	add    $0xc,%esp
    7d69:	eb e6                	jmp    7d51 <bootmain+0x3c>
	((void (*)(void)) (ELFHDR->e_entry))();
    7d6b:	ff 15 18 00 01 00    	call   *0x10018
}

static inline void
outw(int port, uint16_t data)
{
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
    7d71:	ba 00 8a 00 00       	mov    $0x8a00,%edx
    7d76:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
    7d7b:	66 ef                	out    %ax,(%dx)
    7d7d:	b8 00 8e ff ff       	mov    $0xffff8e00,%eax
    7d82:	66 ef                	out    %ax,(%dx)
    7d84:	eb fe                	jmp    7d84 <bootmain+0x6f>
