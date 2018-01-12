# saludo.s: Imprimir por pantalla
#           Hola a todos!
#           Hello, World!
#           retorna: código retorno 0, programado en la penúltima línea
#           comprobar desde línea de comandos bash con echo $?

# SECCIÓN DE DATOS (.data, variables globales inicializadas)
# datos hex, octal, binario, decimal, char, string: 0x, 0, 0b, díg<>0, ‘, “”
# ejemplos: 0x41, 0101, 65, 0b01000001, ‘A, “AAA”
# directivas comienzan por . (en este caso empezamos una sección)
# no son instrucciones máquina, son indicaciones al ensamblador
# etiquetas recuerdan el valor del contador de posiciones (bytes)

.section .data 
saludo:
	.string "Hola a todos!\nHello, World!\n" # \n representa salto de línea
longsaludo:
	.int .-saludo # .= contador posiciones. Aritmética de etiquetas.

# SECCIÓN DE CÓDIGO (.text, instrucciones máquina)

.section .text # cambiamos de sección, ahora emitimos en .text
.global _start # muestra punto de entrada a ld (como main en C)

_start: # punto de entrada ASM (como main en C)

	# Llamada al sistema WRITE, consultar “man 2 write”
	# ssize_t write(int fd, const void *buf, size_t count);
	mov $4, %eax          # write: servicio 4 kernel Linux
	mov $1, %ebx          # fd: descriptor de fichero para stdout
	mov $saludo, %ecx     # buf: dirección del texto a escribir
	mov longsaludo, %edx  # count: número de bytes a escribir
	int $0x80             # llamar write(stdout, &saludo, longsaludo);

	# Llamada al sistema EXIT, consultar “man 2 exit”
	# void _exit(int status);
	mov $1, %eax  # exit: servicio 1 kernel Linux
	mov $0, %ebx  # status: código a retornar (0=OK)
	int $0x80     # llamar exit(0);

