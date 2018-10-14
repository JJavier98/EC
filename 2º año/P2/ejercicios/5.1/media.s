#EJERCICIO 5.1
#
# Se han seguido los pasos tal y como se indican en el guión.
# 'lista' se ha dividido en cuatro lineas para una lectura más cómoda del código
# 'resultado' se ha cambiado por tipo de dato 'quad' para permitir imprimir datos de 64 bits
# 'formato' ha sido modificado para que la impresion mediante 'printf' fuera posible y mostrase adecuadamente los datos (unsigned long y hexadecimal long)
# '_start' fue cambiado por 'main' para poder compilar mediante gcc y las funciones fueron sustituidas por su código directamente
# A muchas instrucciones se les ha añadido un subfijo para ir acostumbrandonos a su uso y significado


.section .data
lista:		.int 0x10000000,0x10000000,0x10000000,0x10000000
			.int 0x10000000,0x10000000,0x10000000,0x10000000
			.int 0x10000000,0x10000000,0x10000000,0x10000000
			.int 0x10000000,0x10000000,0x10000000,0x10000000
longlista:	.int   (.-lista)/4
resultado:	.quad   0
formato: 	.asciz	"suma = %lu = 0x%lx hex\n"

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
	jnc	  	no_inc		# si no hay acarreo no incrementamos %edx y seguimos con las iteraciones del bucle
	inc 	%edx
no_inc:
	inc   	%rsi
	cmpq   	%rsi,%rcx
	jne    	bucle

	ret
