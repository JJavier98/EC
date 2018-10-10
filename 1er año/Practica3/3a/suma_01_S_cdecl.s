# suma.s del Guión 1
# 1.- añadiéndole convención cdecl
#     as --32 -g      suma_01_S_cdecl.s -o suma_01_S_cdecl.o
#     ld -m elf_i386  suma_01_S_cdecl.o -o suma_01_S_cdecl

.section .data
lista:      .int 1,2,10,  1,2,0b10,  1,2,0x10
longlista:  .int (.-lista)/4
resultado:  .int -1

.section .text
_start:  .global _start
                        # versión cdecl del original:
	pushl longlista     # mov    $lista, %ebx
	pushl    $lista     # mov longlista, %ecx
	call suma           # call suma
	add $8, %esp        # quitar args
	mov %eax, resultado # resultado = suma(&lista, longlista)

	mov $1, %eax
	mov $0, %ebx
	int $0x80

suma:                   # int suma(int* lista, int longlista)
	push %ebp           # Ajuste marco de pila
	mov  %esp, %ebp
                        # antes, en el original, conservar todo
	push %ebx           # push %edx
	mov  8(%ebp), %ebx  # ahora %ebx es callee-save en cdecl
	mov 12(%ebp), %ecx  # %ecx,%edx no (caller-save)

	mov $0, %eax
	mov $0, %edx
bucle:
	add (%ebx,%edx,4), %eax
	inc       %edx
	cmp  %edx,%ecx
	jne bucle

	pop %ebx            # Recuperar callee-save
	pop %ebp            # Deshacer marco pila
	ret
