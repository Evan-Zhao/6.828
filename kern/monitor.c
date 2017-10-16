// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/pmap.h>		// for showmapping

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "showmap", "Display page mapping and permission bits in range", mon_showmap }, 
	{ "chmod", "Change permission for a given page or range", mon_chmod },  
	{ "dump", "Dump memory contents for a range", mon_dump }
};

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	cprintf("Stack backtrace:\n");
	uint32_t ebp = read_ebp(), prev_ebp, eip;
	while (ebp != 0) {
		prev_ebp = *(int*)ebp;
		eip = *((int*)ebp + 1);
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, 
				*((int*)ebp + 2), *((int*)ebp + 3), *((int*)ebp + 4), 
				*((int*)ebp + 5), *((int*)ebp + 6));
		struct Eipdebuginfo info;
		int code = debuginfo_eip((uintptr_t)eip, &info);
		cprintf("         %s:%d: ", info.eip_file, info.eip_line);
		for (int i = 0; i < info.eip_fn_namelen; i++)
			cprintf("%c", info.eip_fn_name[i]);
		cprintf("+%d\n", eip - info.eip_fn_addr);
		ebp = prev_ebp;
	}
	return 0;
}

int 
mon_showmap(int argc, char **argv, struct Trapframe *tf) {
	if (argc <= 2) {
		cprintf("Usage: showmap l r\n");
		return 0;
	}
	uintptr_t l = strtoul(argv[1], NULL, 0), 
		 	  r = strtoul(argv[2], NULL, 0); // In string.h
	if (l > r) {
		cprintf("Invalid range; aborting.\n");
		return 0;
	}
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
		pte_t* pte = pgdir_walk(kern_pgdir, (void*) sz, 0);
		if (pte == NULL || !*pte)
			cprintf("0x%08x -> ----------; perm = ---\n", sz);
		else 
			cprintf("0x%08x -> 0x%08x; perm = 0x%03x\n", 
					sz, PTE_ADDR(*pte), *pte & 0xFFF);
	}
	return 0;
}

int
mon_chmod(int argc, char **argv, struct Trapframe *tf) {
	if (argc <= 2) {
		cprintf("Usage: chmod mod l [r] [-v]\n");
		return 0;
	}
	uintptr_t mod = strtoul(argv[1], NULL, 0),  
			  l = strtoul(argv[2], NULL, 0), 
			  r = argc >= 4 ? strtoul(argv[3], NULL, 0) : l;
	int verbose = (argc >= 4 && !strcmp(argv[3], "-v"));
	if (mod > 0xFFF) {
		cprintf("Permission exceeds 0xfff; aborting.\n");
		return 0;
	}
	if (l > r) {
		cprintf("Invalid range; aborting.\n");
		return 0;
	}
	if (!(mod & PTE_P)) {
		cprintf("Warning: PTE_P flag is not provided; added automatically.");
		mod |= PTE_P;
	}
	for (uintptr_t sz = ROUNDUP(l, PGSIZE); sz <= ROUNDDOWN(r, PGSIZE); sz += PGSIZE) {
		pte_t* pte = pgdir_walk(kern_pgdir, (void*) sz, 0);
		if (pte == NULL || !*pte) {
			if (verbose)
				cprintf("Page va = 0x%08x is not mapped; skipping.\n", sz);
		}
		else {
			if (verbose) 
				cprintf("Page va = 0x%08x perm = 0x%03x changed to 0x%03x\n", 
						sz, *pte & 0xFFF, mod);
			*pte = PTE_ADDR(*pte) | mod;
		}
	}
	return 0;
}

int
mon_dump(int argc, char **argv, struct Trapframe *tf) {
	if (argc <= 2 || argc > 4) {
		cprintf("Usage: dump l r [-v/-p]\n");
		return 0;
	}
	unsigned long l = strtoul(argv[1], NULL, 0),
			  	  r = strtoul(argv[2], NULL, 0);
	int virtual;  // If 0 then physical
	if (argc <= 3)
		cprintf("Defaulting to virtual address.\n");
	else if (!strcmp(argv[3], "-p"))
		l = (unsigned long)KADDR(l), r = (unsigned long)KADDR(r);
	else if (strcmp(argv[3], "-v")) {
		cprintf("Unknown flag %s at position 3; aborting.\n", argv[3]);
		return 0;
	}
	uintptr_t ptr;
	for (ptr = ROUNDDOWN(l, 16); ptr <= r; ptr += 16) {
		cprintf("%08x  ", ptr);
		for (int i = 0; i < 16; i++) {
			if (ptr + i <= r)
				cprintf("%02x ", *(unsigned char*)(ptr + i));
			else 
				cprintf("   ");
		}
		cprintf(" |");
		for (int i = 0; i < 16; i++) {
			if (ptr + i <= r) {
				char ch = *(char*)(ptr + i);
				cprintf("%c", (ch >= ' ' && ch <= '~') ? ch : '.');
			}
			else 
				cprintf(" ");
		}
		cprintf("|\n");
	}
	if (ROUNDDOWN(r, 16) != r)
		cprintf("%08x  \n", r);
	return 0;
}

/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
