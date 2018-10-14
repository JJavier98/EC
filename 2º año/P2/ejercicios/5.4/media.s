#EJERCICIO 5.4
#
# Se ha usado el uso de dos macros para poder cambiar la 'lista' de números que se van a sumar según explica el guión
# A la hora de imprimir hemos usado los registros %rsi y %rdx para imprimir los resultados en decimal de la media y resto respectivamente
# y %ecx y %r8d para imprimirlos en hexadecimal
# La media la hemos realizado con 'idiv'. Divide edx:eax entre el parametro pasado. Almacena el cociente en eax y el resto en edx
# Hemos creado dos variables 'media' y 'resto' para hacer mas legible el codigo
# Por lo demás el código es igual al del 5.3

#COMANDO PARA LA EJECUCIÓN:
#for i in $(seq 1 20); do rm media; gcc -x assembler-with-cpp -D TEST=$i -no-pie media.s -o media; printf "__TEST%02d__%35s\n" $i "" | tr " " "-" ; ./media; done

.section .data
#ifndef TEST
#define TEST 20
#endif
.macro linea
#if  TEST==1			//1		8
	.int 1,2,1,2
#elif TEST==2			//-1	-8
	.int -1,-2,-1,-2
#elif TEST==3			//2147483647	0
	.int 0x7fffffff, 0x7fffffff, 0x7fffffff, 0x7fffffff
#elif TEST==4			//-2147483648	0
	.int 0x80000000, 0x80000000, 0x80000000, 0x80000000
#elif TEST==5			//-1	0
	.int 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff
#elif TEST==6			//2000000000	0
	.int 2000000000, 2000000000, 2000000000, 2000000000
#elif TEST==7			//desbordamiento--> -1294967296	0
	.int 3000000000, 3000000000, 3000000000, 3000000000
#elif TEST==8			//-2000000000	0
	.int -2000000000, -2000000000, -2000000000, -2000000000
#elif TEST==9			//desbordamiento--> 1294967296	0
	.int -3000000000, -3000000000, -3000000000, -3000000000
#elif TEST>=10 && TEST<=14
	.int 1, 1, 1, 1
#elif TEST>=15 && TEST<=19
	.int -1, -1, -1, -1
#else			//
	.error "Definir TEST ente 1..19"
#endif			//
	.endm

.macro linea0
#if TEST>=1 && TEST<=9
	linea	
#elif TEST==10			//1	0
	.int 0,2,1,1	
#elif TEST==11			//1	1
	.int 1,2,1,1
#elif TEST==12			//1	8
	.int 8,2,1,1
#elif TEST==13			//1	15
	.int 15,2,1,1
#elif TEST==14			//2	0
	.int 16,2,1,1
#elif TEST==15			//-1	0
	.int 0,-2,-1,-1
#elif TEST==16			//-1	-1
	.int -1,-2,-1,-1
#elif TEST==17			//-1	-8
	.int -8,-2,-1,-1
#elif TEST==18			//-1	-15
	.int -15,-2,-1,-1
#elif TEST==19			//-2	0
	.int -16,-2,-1,-1
#else
	.error "Definir TEST ente 1..19"
#endif
  	.endm
lista: 		linea0
	.irpc i,123
		linea
	.endr

longlista:	.int   (.-lista)/4
resultado:	.quad   0
media: 		.int 	0
resto:		.int 	0
formato: .ascii "media \t = %11d \t resto \t = %11d\n"
		 .asciz "media \t = 0x %08x \t resto \t = 0x %08x\n"

.section .text
main: .global  main

#trabajar
	movq     $lista, %rbx
	movl  longlista, %ecx
	call suma		# == suma(&lista, longlista);
	mov 	%esi, %eax
	mov 	%edi, %edx
	idivl %ecx
	movl  %eax, media
	movl %edx, resto

	# Como 'resultado' es de 64 bits, es almacenado en pila y la arquitectura utilizada almacena los datos en 'little endian'
	# su parte más significativa (%edx) tiene que ser guarda antes que la menos significativa (%eax)
	# por eso almacenamos %edx en resultado+4 y %eax en resultado

#imprim_C
	movq   $formato, %rdi
	movl   media,%esi
	movl   resto,%edx
	movl   media, %ecx
	movl   resto, %r8d
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
