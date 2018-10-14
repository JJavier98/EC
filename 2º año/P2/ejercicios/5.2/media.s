#EJERCICIO 5.2
#
# Se ha usado el uso de una macro para poder cambiar la 'lista' de números que se van a sumar
# A la hora de imprimir hemos usado los registros %ecx y %r8d para imprimir el numero hexadecimal en dos partes
# En el código 'suma' hemos cambiado la implementación de la suma del acarreo
# en vez de usar un salto condicional utilizamos la instrucción 'adc' que contempla el acarreo
# Por lo demás el código es igual al del 5.1 

#COMANDO PARA LA EJECUCIÓN:
#for i in $(seq 1 9); do rm media; gcc -x assembler-with-cpp -D TEST=$i -no-pie media.s -o media; printf "__TEST%02d__%35s\n" $i "" | tr " " "-" ; ./media; done


.section .data
#ifndef TEST
#define TEST 9
#endif
.macro linea
#if TEST==1					// 16 – ejemplo muy sencillo
	.int 1,1,1,1
#elif TEST==2				// 0x0 ffff fff0, casi acarreo
	.int 0x0fffffff, 0x0fffffff, 0x0fffffff, 0x0fffffff
#elif TEST==3				// 0x10000000, justo 1 acarreo
	.int 0x10000000,0x10000000,0x10000000,0x10000000
#elif TEST==4
	.int 0xffffffff,0xffffffff,0xffffffff,0xffffffff
#elif TEST==5				// no trabaja con numeros negativos
	.int -1,-1,-1,-1		
#elif TEST==6				
	.int 200000000,200000000,200000000,200000000
#elif TEST==7				
	.int 300000000,300000000,300000000,300000000
#elif TEST==8				// 11 280 523 264 << 16x5e9= 80e9
	.int 5000000000,5000000000,5000000000,5000000000
#else
	.error "Definir TEST entre 1..8"
#endif
	.endm

lista: .irpc i,1234
			linea
	.endr

longlista:	.int   (.-lista)/4
resultado:	.quad   0
formato: .ascii "resultado \t = %18lu (uns)\n"
		 .ascii "\t\t = 0x%18lx (hex)\n"
		 .asciz "\t\t = 0x %08x %08x \n"

.section .text
main: .global  main

#trabajar
	movq     $lista, %rbx
	movl  longlista, %ecx
	call suma		# == suma(&lista, longlista);
	movl  %eax, resultado
	movl %edx, resultado+4

	# Como 'resultado' es de 64 bits, es almacenado en pila y la arquitectura utilizada almacena los datos en 'little endian'
	# su parte más significativa (%edx) tiene que ser guarda antes que la menos significativa (%eax)
	# por eso almacenamos %edx en resultado+4 y %eax en resultado

#imprim_C
	movq   $formato, %rdi
	movq   resultado,%rsi
	movq   resultado,%rdx
	movl          $0,%eax	# varargin sin xmm
	movl   resultado+4, %ecx
	movl   resultado, %r8d
	call  printf		# == printf(formato, res, res);

	# Según el manual de 'prinf' formato debe ser especificado en %rdi,
	# el primer resultado a mostrar (unsigned long) en %rsi y el segundo (hexadecimal long) en %rdx

#acabar_C
	mov  resultado, %edi
	call _exit		# ==  exit(resultado)
	ret

suma:
	movq	 $0, %rsi	# iterador de la lista
	movl  	 $0, %eax	# acumulador de la suma. Representa la parte menos significativa
	movl  	 $0, %edx	# acumulador de la suma. Representa la parte más significativa
bucle:
	addl  	(%rbx,%rsi,4), %eax
	adc 	$0, %edx
	inc   	%rsi
	cmpq   	%rsi,%rcx
	jne    	bucle

	ret
