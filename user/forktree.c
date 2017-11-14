// Fork a binary tree of processes and display their structure.

#include <inc/lib.h>

#define DEPTH 1

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
	char nxt[DEPTH+1];

	int r;
	//cprintf("nxt = %p, r = %p\n", nxt, &r);
	if (strlen(cur) >= DEPTH)
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
	cprintf("env = %x, nxt = %s, &nxt = %p\n", sys_getenvid(), nxt, nxt);
	r = fork();
	// cprintf("nxt = %s, &nxt = %p\n", nxt, nxt);
	if (r == 0) {
		forktree(nxt);
		exit();
	}
}

void
forktree(const char *cur)
{
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);

	cprintf("env = %x, cur = %s, &cur = %p\n", sys_getenvid(), cur, cur);
	forkchild(cur, '0');
	// forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
	forktree("");
}

