# suma.s del Guión 1
# 1.- añadiéndole convención cdecl
# 2.- añadiéndole printf() y cambiando syscall por exit()
#     as --32 -g      suma_02_S_libC.s -o suma_02_S_libC.o
#     ld -m elf_i386  suma_02_S_libC.o -o suma_02_S_libC \
#        -lc   -dynamic-linker /lib/ld-linux.so.2

.section .data
lista:      .int 1,2,10,  1,2,0b10,  1,2,0x10
longlista:  .int (.-lista)/4
resultado:  .int -1
formato:    .string "resultado = %i = 0x%x\n"
            # formato para printf() libC

.section .text
_start: .global _start
                        # versión cdecl del original:
	pushl longlista     # mov    $lista, %ebx
	pushl    $lista     # mov longlista, %ecx
	call suma           # call suma
	add $8, %esp        # quitar args
	mov %eax, resultado # resultado = suma(&lista, longlista)

	push %eax           # versión libC de syscall __NR_write
	push %eax           # ventaja: printf() con formato "%d" / "%x"
	push $formato       # traduce resultado a ASCII decimal/hex
	call printf         # printf(formato, resultado, resultado)
	add $12, %esp
                        # versión libC de syscall __NR_exit
	pushl $0            # mov $1, %eax
	call exit           # mov $0, %ebx
#	add $4, %esp        # (no ret) # int $0x80 == _exit(0)

suma:
	push %ebp           # Ajuste marco pila
	mov  %esp, %ebp     # antes, en el original, conservar todo
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
