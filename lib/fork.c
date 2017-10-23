// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW		0x800

//
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;

	cprintf("We're %x, and we do have reached here.\n", sys_getenvid());
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	pte_t* pte = (pte_t*)(PDX(uvpt) << PTSHIFT | (PDX(addr) << PGSHIFT) | PTX(addr));
	if (!(*pte & PTE_W) && !(*pte & PTE_COW))
		panic("Page access violation: %p", addr);
	
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// addr must have been page aligned. Just use it.
	r = sys_page_alloc(0, PFTEMP, PTE_W | PTE_U);
	if (r)	
		panic("Pagefault process failed: %e", r);

	// Copy content
	memmove(addr, (void*)PFTEMP, PGSIZE);

	// Remove old (remapped) page
	r = sys_page_unmap(0, addr);
	if (r)	
	panic("Pagefault process failed: %e", r);

	// Finally, move temp page to dest.
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W | PTE_U);
	if (r)
		panic("Pagefault process failed: %e", r);
}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	void* addr = (void*)(pn*PGSIZE);
	
	// We used the trick at UVPT again; see instruction.
	pte_t* pte = (pte_t*)(PDX(uvpt) << PTSHIFT | (PDX(addr) << PGSHIFT) | PTX(addr));
	uint32_t src_perm = *pte & 0xFFF;
	
	if (!pte || !*pte) // No page, nothing to do
		return 0;

	if ((PTE_W & src_perm) || (PTE_COW & src_perm)) { // writable or copy-on-write
		// DO NOT make it writable, so we can have a pagefault.
		r = sys_page_map(0, addr, envid, addr, PTE_COW);
		cprintf("RW, r = %d, pn = %d\n", r, pn);
		// Remap self page onto self.
		r = sys_page_map(0, addr, 0, addr, PTE_COW);
		cprintf("RW, r = %d, pn = %d, src_perm = %x, *pte = %x\n", r, pn, src_perm, *pte);
	}
	else {// Just read-only
		r = sys_page_map(0, addr, envid, addr, src_perm);
		cprintf("RO, r = %d, pn = %d, *pte = %x\n", r, pn, *pte);
	}
	return r;
}

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use uvpd, uvpt, and duppage.
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
	// Installs pgfault as default handler.
	// set_pgfault_handler(pgfault);
	
	// Syscall fork
	envid_t id = sys_exofork();
	cprintf("Ok we got here as %d.\n",  id);
	if (id < 0) // Something happened.
		panic("sys_exofork: %e", id);
	if (id == 0) {
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	// We're the parent. Now we copy (remap) pages.
	int r = 0, pn;
	for (pn = 2 * NPTENTRIES; pn < (UTOP >> PGSHIFT) && !r; pn++)  {// From TEXT to kernel `end`
		r = duppage(id, pn);  // map one page each time.
		cprintf("Map pn = %d\n", pn);
	}
	if (r)	return r;

	// We really make a new page for exception stack.
	r = sys_page_alloc(id, (void*)UXSTACKTOP - PGSIZE, PTE_W | PTE_U);
	if (r)	return r;

	// Set usr page entrypoint for child
	r = sys_env_set_pgfault_upcall(id, envs[ENVX(sys_getenvid())].env_pgfault_upcall);
	if (r)	return r;

	// Ready to run! Mark runnable.
	r = sys_env_set_status(id, ENV_RUNNABLE);
	if (r)	return r;

	return id;
}

// Challenge!
int
sfork(void)
{
	panic("sfork not implemented");
	return -E_INVAL;
}
