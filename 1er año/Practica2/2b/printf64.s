# printf64.s

.section .data
	resultado: .quad 0x8877665544332211
	formato:   .string "i:%lli / u:%llu / 0x%llx\n"

.section .text
	.extern exit
	.extern printf

_start: .globl _start

	pushl resultado + 4
	pushl resultado
	pushl resultado + 4
	pushl resultado
	pushl resultado + 4
	pushl resultado
	pushl $formato
	call printf
	add $28, %esp

	push $0
	call exit

