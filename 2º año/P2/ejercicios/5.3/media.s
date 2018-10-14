#EJERCICIO 5.3
#
# Se ha usado el uso de una macro para poder cambiar la 'lista' de números que se van a sumar
# A la hora de imprimir hemos usado los registros %ecx y %r8d para imprimir el numero hexadecimal en dos partes
# En la suma hemos tenido en cuenta el signo a la hora de hacer operaciones.
# Gracias a la operación 'cdq' extendemos el signo de eax a edx.
# Utilizamos los registros esi y edi como acumuladores.
# Por lo demás el código es igual al del 5.2

#COMANDO PARA LA EJECUCIÓN:
#for i in $(seq 1 20); do rm media; gcc -x assembler-with-cpp -D TEST=$i -no-pie media.s -o media; printf "__TEST%02d__%35s\n" $i "" | tr " " "-" ; ./media; done

.section .data
#ifndef TEST
#define TEST 20
#endif
.macro linea
#if TEST==1					// 16 – ejemplo muy sencillo
	.int -1,-1,-1,-1
#elif TEST==2				// 1073741824
	.int 0x04000000, 0x04000000, 0x04000000, 0x04000000
#elif TEST==3				// 2147483648
	.int 0x08000000,0x08000000,0x08000000,0x08000000
#elif TEST==4				// 4294967296
	.int 0x10000000,0x10000000,0x10000000,0x10000000
#elif TEST==5				// 34359738352
	.int 0x7FFFFFFF,0x7FFFFFFF,0x7FFFFFFF,0x7FFFFFFF		
#elif TEST==6				// -34359738368
	.int 0x80000000,0x80000000,0x80000000,0x80000000
#elif TEST==7				// -4294967296
	.int 0xF0000000,0xF0000000,0xF0000000,0xF0000000
#elif TEST==8				// -2147483648
	.int 0xF8000000,0xF8000000,0xF8000000,0xF8000000
#elif TEST==9				// -2147483664
	.int 0xF7FFFFFF,0xF7FFFFFF,0xF7FFFFFF,0xF7FFFFFF
#elif TEST==10				// 1600000000
	.int 100000000,100000000,100000000,100000000
#elif TEST==11				// 3200000000
	.int 200000000,200000000,200000000,200000000
#elif TEST==12				// 4800000000
	.int 300000000,300000000,300000000,300000000
#elif TEST==13				// 32000000000
	.int 2000000000,2000000000,2000000000,2000000000
#elif TEST==14				// -20719476736 no representable sgn32b(>=2Gi)
	.int 3000000000,3000000000,3000000000,3000000000
#elif TEST==15				// -1600000000
	.int -100000000,-100000000,-100000000,-100000000
#elif TEST==16				// -3200000000
	.int -200000000,-200000000,-200000000,-200000000
#elif TEST==17				// -4800000000
	.int -300000000,-300000000,-300000000,-300000000
#elif TEST==18				// -32000000000
	.int -2000000000,-2000000000,-2000000000,-2000000000
#elif TEST==19				// 20719476736 no representable sgn32b(<-2Gi)
	.int -3000000000,-3000000000,-3000000000,-3000000000
#else
	.error "Definir TEST entre 1..20"
#endif
	.endm

lista: .irpc i,1234
			linea
	.endr

longlista:	.int   (.-lista)/4
resultado:	.quad   0
formato: .ascii "resultado \t = %18ld (sgn)\n"
		 .ascii "\t\t = 0x%18lx (hex)\n"
		 .asciz "\t\t = 0x %08x %08x \n"

.section .text
main: .global  main

#trabajar
	movq     $lista, %rbx
	movl  longlista, %ecx
	call suma		# == suma(&lista, longlista);
	mov 	%esi, %eax
	mov 	%edi, %edx
	movl  %eax, resultado
	movl %edx, resultado+4

	# Como 'resultado' es de 64 bits, es almacenado en pila y la arquitectura utilizada almacena los datos en 'little endian'
	# su parte más significativa (%edx) tiene que ser guarda antes que la menos significativa (%eax)
	# por eso almacenamos %edx en resultado+4 y %eax en resultado

#imprim_C
	movq   $formato, %rdi
	movq   resultado,%rsi
	movq   resultado,%rdx
	movl   resultado+4, %ecx
	movl   resultado, %r8d
	movl          $0,%eax	# varargin sin xmm
	call  printf		# == printf(formato, res, res);

	# Según el manual de 'prinf' formato debe ser especificado en %rdi,
	# el primer resultado a mostrar (unsigned long) en %rsi y el segundo (hexadecimal long) en %rdx

#acabar_C
	mov  resultado, %edi
	call _exit		# ==  exit(resultado)
	ret

suma:
	movq	 $0, %r8	# iterador de la lista
	movl  	 $0, %eax	# En un principio se usará para extender el signo a %edx. Representa la parte menos significativa
	movl  	 $0, %esi	# Acumulador de la suma. Representa la parte menos significativa
	movl 	 $0, %edi 	# Acumulador de la suma. Representa la parte más significativa
bucle:
	movl  	(%rbx,%r8,4), %eax
	cdq
	add 	%eax, %esi
	adc 	%edx, %edi
	inc   	%r8
	cmpq   	%r8,%rcx
	jne    	bucle

	ret
