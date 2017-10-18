/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>



###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

TRAPHANDLER_NOEC(H_DIVIDE , T_DIVIDE)
TRAPHANDLER_NOEC(H_DEBUG  , T_DEBUG)
TRAPHANDLER_NOEC(H_NMI    , T_NMI)
TRAPHANDLER_NOEC(H_BRKPT  , T_BRKPT)
TRAPHANDLER_NOEC(H_OFLOW  , T_OFLOW)
TRAPHANDLER_NOEC(H_BOUND  , T_BOUND)
TRAPHANDLER_NOEC(H_ILLOP  , T_ILLOP)
TRAPHANDLER_NOEC(H_DEVICE , T_DEVICE)
TRAPHANDLER     (H_DBLFLT , T_DBLFLT)	// Error Code const 0
TRAPHANDLER     (H_TSS    , T_TSS)
TRAPHANDLER     (H_SEGNP  , T_SEGNP)
TRAPHANDLER     (H_STACK  , T_STACK)
TRAPHANDLER     (H_GPFLT  , T_GPFLT)
TRAPHANDLER     (H_PGFLT  , T_PGFLT)
TRAPHANDLER_NOEC(H_FPERR  , T_FPERR)
TRAPHANDLER_NOEC(H_ALIGN  , T_ALIGN)
TRAPHANDLER_NOEC(H_MCHK   , T_MCHK)
TRAPHANDLER_NOEC(H_SIMDERR, T_SIMDERR)



_alltraps:
/* Processor has pushed ss, esp, eflags, cs, eip, and [error] */
/* TRAPHANDLER did [error] and trapno */
	pushl  %ds;
	pushl  %es;
	movw   $GD_KD, %ax;
	movw   %ax   , %ds;
	movw   %ax   , %es;
	pushal;
	pushl  %esp;
	call   trap

