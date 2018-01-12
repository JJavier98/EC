# gcc -m32 -O1 -g -c suma_06_CS_c.c
# as --32      -g    suma_06_CS_s.s -o suma_06_CS_s.o
#    LDIR = `gcc -print-file-name=`
# ld -m elf_i386     suma_06_CS_c.o    suma_06_CS_s.o -o suma_06_CS \
#    -dynamic-linker /lib/ld-linux.so.2            \
#    /usr/lib32/crt1.o /usr/lib32/crti.o /usr/lib32/crtn.o    \
#    $LDIR/32/crtbegin.o   $LDIR/32/crtend.o        -lc

.section .text
suma:    .global suma
    push %ebp           # Ajuste marco pila
    mov  %esp, %ebp

    push %ebx           # callee-save
    mov  8(%ebp), %ebx  # suma(array,len)
    mov 12(%ebp), %ecx

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

