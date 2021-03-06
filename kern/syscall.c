/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>

#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/syscall.h>
#include <kern/console.h>
#include <kern/sched.h>

// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void
sys_cputs(const char *s, size_t len)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	user_mem_assert(curenv, s, len, PTE_U);  // The memory is readable.

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
}

// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
}

// Destroy a given environment (possibly the currently running environment).
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if (e == curenv)
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
	else 
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
	env_destroy(e);
	return 0;
}

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
}

// Allocate a new environment.
// Returns envid of new environment, or < 0 on error.  Errors are:
//	-E_NO_FREE_ENV if no free environment is available.
//	-E_NO_MEM on memory exhaustion.
static envid_t
sys_exofork(void)
{
	// Create the new environment with env_alloc(), from kern/env.c.
	// It should be left as env_alloc created it, except that
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	struct Env* newenv;
	int r = env_alloc(&newenv, curenv->env_id);
	if (r)  // Some error
		return r;
	newenv->env_status = ENV_NOT_RUNNABLE;
	memcpy(&newenv->env_tf, &curenv->env_tf, sizeof(struct Trapframe));
	
	// Tweak trapframe so that it seems that 0 is returned.
	newenv->env_tf.tf_regs.reg_eax = 0;

	return newenv->env_id;
}

// Set envid's env_status to status, which must be ENV_RUNNABLE
// or ENV_NOT_RUNNABLE.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if status is not a valid status for an environment.
static int
sys_env_set_status(envid_t envid, int status)
{
	// Hint: Use the 'envid2env' function from kern/env.c to translate an
	// envid to a struct Env.
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	struct Env* to_env;
	int r = envid2env(envid, &to_env, 1);  // 1 - Check perm
	if (r)  // -E_BAD_ENV
		return r;
	if (status > ENV_NOT_RUNNABLE || status < 0) 
		return -E_INVAL;
	
	to_env->env_status = status;
	return 0;
}

// Set envid's trap frame to 'tf'.
// tf is modified to make sure that user environments always run at code
// protection level 3 (CPL 3), interrupts enabled, and IOPL of 0.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	int r;
	struct Env* env;
	
	// Find environment.
	r = envid2env(envid, &env, 1);
	if (r)	return r;

	// If tf is null, just return.
	if (!tf)	return -E_INVAL;
	// Otherwise write them in env
	// and sanitize some values there.
	env->env_tf = *tf;

	env->env_tf.tf_cs |= 3;  // Code protection level 3.
	env->env_tf.tf_eflags |= FL_IF;  // Interrupt flag.
	env->env_tf.tf_eflags &= ~FL_IOPL_MASK | FL_IOPL_0;  // Set IO level to 0.

	return 0;
}

// Set the page fault upcall for 'envid' by modifying the corresponding struct
// Env's 'env_pgfault_upcall' field.  When 'envid' causes a page fault, the
// kernel will push a fault record onto the exception stack, then branch to
// 'func'.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	struct Env* to_env;
	int r = envid2env(envid, &to_env, 1);  // 1 - Check perm
	if (r)  // -E_BAD_ENV
		return r;
	to_env->env_pgfault_upcall = func;
	return 0;
}

// Allocate a page of memory and map it at 'va' with permission
// 'perm' in the address space of 'envid'.
// The page's contents are set to 0.
// If a page is already mapped at 'va', that page is unmapped as a
// side effect.
//
// perm -- PTE_U | PTE_P must be set, PTE_AVAIL | PTE_W may or may not be set,
//         but no other bits may be set.  See PTE_SYSCALL in inc/mmu.h.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
//	-E_INVAL if perm is inappropriate (see above).
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	// Hint: This function is a wrapper around page_alloc() and
	//   page_insert() from kern/pmap.c.
	//   Most of the new code you write should be to check the
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// get our environment first.
	struct Env* to_env;
	int r = envid2env(envid, &to_env, 1);  // 1 - Check perm
	if (r)  // -E_BAD_ENV
		return r;
	
	// then check parameter
	if ((uintptr_t)va >= UTOP || (uintptr_t)va % PGSIZE)
		return -E_INVAL;

	// Check if we got some prohibited perms.
	if (~PTE_SYSCALL & perm) 
		return -E_INVAL;
	
	// If we don't have perm U or P, just make it up.
	perm |= PTE_U | PTE_P;

	// Do our things finally.
	struct PageInfo* pp = page_alloc(1);
	if (!pp)  // No free memory
		return -E_NO_MEM;
	r = page_insert(to_env->env_pgdir, pp, va, perm);
	if (r) 
		page_free(pp);
	return r;
}

// Map the page of memory at 'srcva' in srcenvid's address space
// at 'dstva' in dstenvid's address space with permission 'perm'.
// Perm has the same restrictions as in sys_page_alloc, except
// that it also must not grant write access to a read-only
// page.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if srcenvid and/or dstenvid doesn't currently exist,
//		or the caller doesn't have permission to change one of them.
//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
//		or dstva >= UTOP or dstva is not page-aligned.
//	-E_INVAL is srcva is not mapped in srcenvid's address space.
//	-E_INVAL if perm is inappropriate (see sys_page_alloc).
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
//		address space.
//	-E_NO_MEM if there's no memory to allocate any necessary page tables.
static int
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
{
	// Hint: This function is a wrapper around page_lookup() and
	//   page_insert() from kern/pmap.c.
	//   Again, most of the new code you write should be to check the
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// get our emvironment first.
	struct Env *from_env, *to_env;
	int r;
	r = envid2env(srcenvid, &from_env, 1);  // 1 - Check perm
	if (r)  return r;
	r = envid2env(dstenvid, &to_env, 1);  // 1 - Check perm
	if (r)  return r;
	
	// Check address and perm
	if (
		((uintptr_t)srcva >= UTOP || (uintptr_t)srcva % PGSIZE) || 
		((uintptr_t)dstva >= UTOP || (uintptr_t)dstva % PGSIZE))
		return -E_INVAL;
	
	// Check if we got some prohibited perms.
	if (~PTE_SYSCALL & perm)
		return -E_INVAL;

	// If we don't have perm U or P, just make it up.
	perm |= PTE_U | PTE_P;

	// Lookup the page first, then 
	// check if perm is stronger than that of src page
	pte_t* src_pgt;
	struct PageInfo* pp = page_lookup(from_env->env_pgdir, srcva, &src_pgt);
	if ((~*src_pgt & PTE_W) && (perm & PTE_W))
		return -E_INVAL;

	// Everything seems good, and we insert that page.
	r = page_insert(to_env->env_pgdir, pp, dstva, perm);
	return r;
}

// Unmap the page of memory at 'va' in the address space of 'envid'.
// If no page is mapped, the function silently succeeds.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
static int
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// get our emvironment first.
	struct Env* to_env;
	int r = envid2env(envid, &to_env, 1);  // 1 - Check perm
	if (r)  // -E_BAD_ENV
		return r;
	
	if ((uintptr_t)va >= UTOP || (uintptr_t)va % PGSIZE)
		return -E_INVAL;

	page_remove(to_env->env_pgdir, va);
	return 0;
}

// Try to send 'value' to the target env 'envid'.
// If srcva < UTOP, then also send page currently mapped at 'srcva',
// so that receiver gets a duplicate mapping of the same page.
//
// The send fails with a return value of -E_IPC_NOT_RECV if the
// target is not blocked, waiting for an IPC.
//
// The send also can fail for the other reasons listed below.
//
// Otherwise, the send succeeds, and the target's ipc fields are
// updated as follows:
//    env_ipc_recving is set to 0 to block future sends;
//    env_ipc_from is set to the sending envid;
//    env_ipc_value is set to the 'value' parameter;
//    env_ipc_perm is set to 'perm' if a page was transferred, 0 otherwise.
// The target environment is marked runnable again, returning 0
// from the paused sys_ipc_recv system call.  (Hint: does the
// sys_ipc_recv function ever actually return?)
//
// If the sender wants to send a page but the receiver isn't asking for one,
// then no page mapping is transferred, but no error occurs.
// The ipc only happens when no errors occur.
//
// Returns 0 on success, < 0 on error.
// Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist.
//		(No need to check permissions.)
//	-E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv,
//		or another environment managed to send first.
//	-E_INVAL if srcva < UTOP but srcva is not page-aligned.
//	-E_INVAL if srcva < UTOP and perm is inappropriate
//		(see sys_page_alloc).
//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's
//		address space.
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in the
//		current environment's address space.
//	-E_NO_MEM if there's not enough memory to map srcva in envid's
//		address space.
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	struct Env* target_env;
	int r;

	r = envid2env(envid, &target_env, 0);  // 0 - don't check perm
	if (r)	return r;

	if (!target_env->env_ipc_recving)  // target is not willing to receive
		return -E_IPC_NOT_RECV;
	
	// Write down our id first.
	target_env->env_ipc_from = curenv->env_id; 
	// also render target not-receiving
	target_env->env_ipc_recving = false;

	// Set value to receive.
	target_env->env_ipc_value = value;

	if ((uintptr_t)srcva < UTOP && // Have a page to map
		(uintptr_t)target_env->env_ipc_dstva < UTOP // and target will receive page
	) {
		// Below is basically a copy of 
		// 'syscall_page_map', 
		// but we cannot call it instead since it checks for permission.

		if ((uintptr_t)srcva % PGSIZE || 	// check addr aligned
			~PTE_SYSCALL & perm 			// check no forbidden perm
		)
			return -E_INVAL;

		// If we don't have perm U or P, just make it up.
		perm |= PTE_U | PTE_P;

		// Lookup the page first, then 
		// check if perm is stronger than that of src page
		pte_t* src_pgt;
		struct PageInfo* pp = page_lookup(curenv->env_pgdir, srcva, &src_pgt);
		if ((~*src_pgt & PTE_W) && (perm & PTE_W))
			return -E_INVAL;

		// Everything seems good, and we insert that page.
		r = page_insert(target_env->env_pgdir, pp, target_env->env_ipc_dstva, perm);
		if (r)	return r;

		target_env->env_ipc_perm = perm;  // tell the permission
	}

	// Finally everything went well.
	// We set awake the target env.
	target_env->env_status = ENV_RUNNABLE;
	return 0;
}

// Block until a value is ready.  Record that you want to receive
// using the env_ipc_recving and env_ipc_dstva fields of struct Env,
// mark yourself not runnable, and then give up the CPU.
//
// If 'dstva' is < UTOP, then you are willing to receive a page of data.
// 'dstva' is the virtual address at which the sent page should be mapped.
//
// This function only returns on error, but the system call will eventually
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
int
sys_ipc_recv(void *dstva)
{
	// Willing to receive information.
	curenv->env_ipc_recving = true; 

	// If willing to receive page but not aligned
	if ((uintptr_t)dstva < UTOP && (uintptr_t)dstva % PGSIZE) 
		return -E_INVAL;
	// No matter we want to get page or not, 
	// this statement is ok.
	curenv->env_ipc_dstva = dstva; 

	// Mark not-runnable. Don't run until we receive something.
	curenv->env_status = ENV_NOT_RUNNABLE;

	// There used to be a yield here, which is wrong.
	// When the env is continued, it will (surely) not be running 
	// from here, since this is kernel code. 
	// sched_yield();

	return 0;
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((const char*)a1, a2);
		return 0;
	case SYS_cgetc:
		return sys_cgetc();
	case SYS_getenvid:
		return sys_getenvid();
	case SYS_env_destroy:
		return sys_env_destroy(a1);
	case SYS_page_alloc:
		return sys_page_alloc(a1, (void*)a2, a3);
	case SYS_page_map:
		return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
	case SYS_page_unmap:
		sys_page_unmap(a1, (void*)a2);
		return 0;
	case SYS_exofork:
		return sys_exofork();
	case SYS_env_set_status:
		return sys_env_set_status(a1, a2);
	case SYS_env_set_trapframe:
		return sys_env_set_trapframe(a1, (void*)a2);
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall(a1, (void*)a2);
	case SYS_yield:
		sys_yield();
		return 0;
	case SYS_ipc_try_send:
		return sys_ipc_try_send(a1, a2, (void*)a3, a4);
	case SYS_ipc_recv:
		return sys_ipc_recv((void*)a1);
	default:
		return -E_INVAL;
	}
}
