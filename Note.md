# 6.828 Note & Answer to Questions

## Lab 1

### Q: Boot Loader
* At what point does the processor start executing 32-bit code? What exactly causes the switch from 16- to 32-bit mode?
* What is the last instruction of the boot loader executed, and what is the first instruction of the kernel it just loaded?
* Where is the first instruction of the kernel?
* How does the boot loader decide how many sectors it must read in order to fetch the entire kernel from disk? Where does it find this information?

1. At the long jump `ljmp    $PROT_MODE_CSEG, $protcseg`, in boot.S. The GDB says that `The target architecture is assumed to be i386`.

1. The line of code calling kernel is `jae    7d6b <bootmain+0x56>`, according to boot.asm. The C code is `((void (*)(void)) (ELFHDR->e_entry))();`. 
    
   It then jumps to addr 0x10000c, which is a line `movw   $0x1234,0x472`. The disassemblier says that's a "warm boot".

1. As said, the first line is at 0x10000c, which is after 1MB part of the memory in (x86 virtual mode).

1. This can be seen from the following code:

    ```[C]
    ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
    eph = ph + ELFHDR->e_phnum;
    ```
   
   So the information really comes from the elf header.


### Paging
x86 processors has control registers CR0, CR1, ..., CR7. PG (bit 31) on CR0 controls whether to use paging.

Once paging is turned on, CR3 is enabled and will contain the address to the page directory and page table (in memory).

### Q: Stack Pointer (Exercise 9)
Determine where the kernel initializes its stack, and exactly where in memory its stack is located. How does the kernel reserve space for its stack? And at which "end" of this reserved area is the stack pointer initialized to point to?

1. At command `movl	$(bootstacktop),%esp` in `entry.S`, the address of `bootstacktop` is moved into stack pointer. Therefore, the stack starts at that label (which is in data segment of `entry.S`).

1. The kernel entry `entry.S` has two labels in its data segment: `bootstack` and `bootstacktop`. Between them is a directive `.space		KSTKSIZE`, which reserve that much of space for kernel's stack.

1. The SP is initialized to the higher end (as address) of the stack. Then, the stack grows downward. 

## Lab 2

### Q: Kernel Addr Space (Exercise 5)
* What entries (rows) in the page directory have been filled in at this point? What addresses do they map and where do they point? In other words, fill out this table as much as possible:

    |Entry	|Base Virtual Address	|Points to (logically):                 |
    |-------|-----------------------|---------------------------------------|
    |1023	|?	                    |Page table for top 4MB of phys memory  |
    |1022	|?	                    |?                                      |
    |.	    |?	                    |?                                      |
    |.	    |?	                    |?                                      |
    |.	    |?	                    |?                                      |
    |2	    |0x00800000	            |?                                      |
    |1	    |0x00400000	            |?                                      |
    |0	    |0x00000000	            |[see next question]                    |

* We have placed the kernel and user environment in the same address space. Why will user programs not be able to read or write the kernel's memory? What specific mechanisms protect the kernel memory?
What is the maximum amount of physical memory that this operating system can support? Why?

* How much space overhead is there for managing memory, if we actually had the maximum amount of physical memory? How is this overhead broken down?

* Revisit the page table setup in kern/entry.S and kern/entrypgdir.c. Immediately after we turn on paging, EIP is still a low number (a little over 1MB). At what point do we transition to running at an EIP above KERNBASE? What makes it possible for us to continue executing at a low EIP between when we enable paging and when we begin running at an EIP above KERNBASE? Why is this transition necessary?

1. We haven't even touched virtual addresses below UPAGES in Lab2, hence these page directory entries should all maintain 0. 
   UPAGES itself corresponds to page dir entry 956. UVPT is done by the code given (line 145, pmap.c), at entry 957. 958 is empty (MMIO), and 959 is for kernel stacks. 960 is already above KERNBASE.

    |Entry	|Base Virtual Address	|Points to (logically):                 |
    |-------|-----------------------|---------------------------------------|
    |1023	|0xFFC00000             |Page table for top 4MB of phys memory  |
    |...	|...                    |...                                    |
    |960    |0xF0000000             |Page table at the base of KERNBASE     |
    |959    |0xEFC00000             |Page table for kernel stack            |
    |958    |-                      |-                                      |
    |957    |0xEF400000             |Page table for UVPT                    |
    |956    |0xEF000000	            |Page table for UPAGES                  |

1. The user program cannot read kernel memory because we have permission mechanism, and (in addition) no one can directly access memory from physical address (this is why the virtual-address mode is called protected mode).
   The maximal memory will be 4GB because we only have that much virtual address.

1. Space overhead consists of 3 parts:

    * Page directory. Up to now, there is only one page dir and occupies only one page (4k).

    * `PageInfo`s, which is stored in `pages`. If we have maximal memory 4GB, we'll have 1048576 pages of memory, each assigned a `PageInfo` which sums to 8MB.

    * Page table. One page table is a page and menages 4MB memory, so we'll have 1024 page tables which needs 1024 pages, or 4MB.
   
   In sum, space overhead for memory management is ~12MB if we have 4GB memory.

1. We manually jumped (using `jmp`) to high linear address after the simple linear table has been set up. We have some instructions continue executing at a low EIP after we enable paging, because the simple table mapped `[KERNBASE, KERNBASE+4MB)` *and* `[0, 4MB)` both to physical `[0, 4MB)`. 
