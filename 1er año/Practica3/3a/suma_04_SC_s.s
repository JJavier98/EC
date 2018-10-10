# suma.s del Guión 1
# 1.- añadiéndole convención cdecl
# 2.- añadiéndole printf() y cambiando syscall por exit()
#    as --32 -g      suma_02_S_libC.s -o suma_02_S_libC.o
#    ld -m elf_i386  suma_02_S_libC.o -o suma_02_S_libC \
#        -lc   -dynamic-linker /lib/ld-linux.so.2
# 3.- extrayendo suma a módulo C para linkar
#    gcc -m32 -O1 -g -c suma_03_SC_c.c
#    as --32      -g    suma_03_SC_s.s -o suma_03_SC_s.o
#    ld -m elf_i386     suma_03_SC_c.o    suma_03_SC_s.o -o suma_03_SC \
#        -lc   -dynamic-linker /lib/ld-linux.so.2
# 4.- dejando sólo los datos, que el resto lo haga suma() en módulo C

.section .data
lista:        .int 1,2,10,  1,2,0b10,  1,2,0x10
longlista:    .int (.-lista)/4
resultado:    .int -1
formato:      .string    "resultado = %i = 0x%x\n\0"

.global lista, longlista, resultado, formato

.section .text
_start: .global _start

	jmp suma

