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
	void *addr = ROUNDDOWN((void *) utf->utf_fault_va, PGSIZE);
	uint32_t err = utf->utf_err;
	int r;

	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	pte_t* pte = (pte_t*)(
		(uintptr_t)uvpt | 
		(PDX(addr) << PGSHIFT) | 
		(PTX(addr) << 2)
	);
	if (!*pte)
		panic("pgtable entry is empty in pgfault handler; nothing to do!");
	if (!(*pte & PTE_W) && !(*pte & PTE_COW))
		panic("Page access violation: %p", addr);
	
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// addr must have been page aligned. Just use it.
	r = sys_page_alloc(0, PFTEMP, PTE_W);
	if (r)	
		panic("Pagefault process failed: %e", r);

	// Copy content
	memmove((void*)PFTEMP, addr, PGSIZE);

	// Remove old (remapped) page
	r = sys_page_unmap(0, addr);
	if (r)
		panic("Pagefault process failed: %e", r);

	// Finally, move temp page to dest.
	r = sys_page_map(0, PFTEMP, 0, addr, PTE_W);
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
	pde_t* pde = (pde_t*)(
		(uintptr_t)uvpd | (PDX(addr) << 2)
	);
	if (!*pde) // pgdir entry is empty; nothing to do.
		return 0;

	pte_t* pte = (pte_t*)(
		(uintptr_t)uvpt        |
		(PDX(addr) << PGSHIFT) |
		(PTX(addr) << 2)
	);
	if (!*pte) // Page table entry is empty; nothing to do.
		return 0;
	
	uint32_t src_perm = *pte & PTE_SYSCALL;

	if ((PTE_W & src_perm) || (PTE_COW & src_perm)) { // writable or copy-on-write
		// DO NOT make it writable, so we can have a pagefault.
		r = sys_page_map(0, addr, envid, addr, PTE_COW);
		// Remap self page onto self; remove the writable marker
		r = sys_page_map(0, addr, 0, addr, PTE_COW);
	}
	else { // Just read-only
		r = sys_page_map(0, addr, envid, addr, 0);
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
	set_pgfault_handler(pgfault);

	// Syscall fork
	envid_t id = sys_exofork();
	int i = 0;
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
	for (pn = 2 * NPTENTRIES; pn < (UTOP >> PGSHIFT) && !r; pn++) { // From TEXT to kernel `end`
		// DON'T map the exception stack page again.
		// I've spent alot of time here because of this.
		if (pn << PGSHIFT == UXSTACKTOP - PGSIZE)
			continue;
		r = duppage(id, pn);  // map one page each time.
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
