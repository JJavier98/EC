# suma2.s

.section .data

	lista:     .int 0x1, 0x100, 0x10000, 0x1000000, 0x8fffffff
	longlista: .int (. - lista) / 4
	resultado: .int 0
	formato:   .string "%i / 0x%x\n"

.section .text
	.extern exit
	.extern printf

_start: .globl _start

	pushl longlista
	pushl $lista
	call suma
	addl $8, %esp
	movl %eax, resultado

	pushl resultado
	pushl resultado
	pushl $formato
	call printf
	add $12, %esp

	push $0
	call exit

suma:                   # versión cdecl: suma(int *lista, int longlista)
	pushl %ebp          # guardar marco de pila
	movl %esp, %ebp     # nuevo marco de pila
	movl 12(%ebp), %ecx # longlista --> ecx
	pushl %esi          # guardar esi
	movl 8(%ebp), %esi  # lista --> esi
	xorl %edx, %edx     # edx = 0
	cld
.siguiente:
	lodsl               # lista[esi++] --> eax
	addl %eax, %edx     # eax + edx --> edx
	loop .siguiente     # repetir mientras ecx != 0
	movl %edx, %eax     # resultado en eax
	popl %esi           # restaurar esi
	popl %ebp           # recuperar marco de pila
	retl

