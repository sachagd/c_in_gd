	.file	"prime.c"
	.text
	.globl	main
	.type	main, @function
main:
	subl	$144, %esp
	call	__x86.get_pc_thunk.ax
	addl	$_GLOBAL_OFFSET_TABLE_, %eax
	movl	$0, 140(%esp)
	movl	$2, 136(%esp)
	jmp	.L2
.L7:
	movb	$1, 135(%esp)
	movl	$0, 128(%esp)
	jmp	.L3
.L5:
	movl	128(%esp), %eax
	movl	8(%esp,%eax,4), %ecx
	movl	136(%esp), %eax
	cltd
	idivl	%ecx
	movl	%edx, %eax
	testl	%eax, %eax
	jne	.L4
	movb	$0, 135(%esp)
.L4:
	addl	$1, 128(%esp)
.L3:
	movl	128(%esp), %eax
	cmpl	140(%esp), %eax
	jl	.L5
	cmpb	$0, 135(%esp)
	je	.L6
	movl	140(%esp), %eax
	movl	136(%esp), %edx
	movl	%edx, 8(%esp,%eax,4)
	addl	$1, 140(%esp)
.L6:
	addl	$1, 136(%esp)
.L2:
	cmpl	$29, 140(%esp)
	jle	.L7
	movl	$0, %eax
	addl	$144, %esp
	ret
	.size	main, .-main
	.section	.text.__x86.get_pc_thunk.ax,"axG",@progbits,__x86.get_pc_thunk.ax,comdat
	.globl	__x86.get_pc_thunk.ax
	.hidden	__x86.get_pc_thunk.ax
	.type	__x86.get_pc_thunk.ax, @function
__x86.get_pc_thunk.ax:
	movl	(%esp), %eax
	ret
	.ident	"GCC: (Ubuntu 9.4.0-1ubuntu1~20.04.2) 9.4.0"
	.section	.note.GNU-stack,"",@progbits
