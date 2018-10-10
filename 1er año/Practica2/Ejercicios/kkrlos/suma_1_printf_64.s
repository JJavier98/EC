# suma.s: Sumar los elementos de una lista
#         llamando a función, pasando argumentos mediante registros
#         retorna: código retorno 0, comprobar suma en %eax mediante gdb/ddd

# SECCIÓN DE DATOS (.data, variables globales inicializadas)
.section .data
lista:
	.int 1,2,10, 1,2,0b10, 1,2,0x10, 0xffffffff # ejemplos binario 0b / hex 0x
longlista:
	.int (.-lista)/4 # .= contador posiciones. Aritmética de etiquetas.

resultado: .quad 0x8877665544332211

formato:   .string "i:%lli / u:%llu / 0x%llx\n"

# SECCIÓN DE CÓDIGO (.text, instrucciones máquina)
.section .text
	.global _start # PROGRAMA PRINCIPAL - se puede abreviar de esta forma
	.extern printf # busca printf fuera de este fichero

_start:

	mov $lista, %ebx    # dirección del array lista
	mov longlista, %ecx # número de elementos a sumar
	call suma           # llamar suma(&lista, longlista);
	mov %eax, resultado  		# salvar resultado
	mov %edx, resultado + 4

	pushl resultado + 4	# llama a printf de 64 bits
	pushl resultado
	pushl resultado + 4
	pushl resultado
	pushl resultado + 4
	pushl resultado
	pushl $formato
	call printf
	add $28, %esp       # dejar pila intacta

	# void _exit(int status);
	mov $1, %eax # exit: servicio 1 kernel Linux
	mov $0, %ebx # status: código a retornar (0=OK)
	int $0x80    # llamar _exit(0);

# SUBRUTINA: suma(int* lista, int longlista);
#            entrada: 1) %ebx = dirección inicio array
#                     2) %ecx = número de elementos a sumar
#            salida:     %eax = resultado de la suma

suma:
	push %edi
	xor %eax, %eax # poner a 0 acumulador
	xor %edi, %edi # poner a 0 índice
	xor %edx, %edx # poner a 0 edx (ACARREO)
bucle:
	add (%ebx,%edi,4), %eax # acumular i-ésimo elemento
	adc $0, %edx		# el acarreo lo acumulo en edx
	inc %edi                # incrementar índice
	cmp %edi,%ecx           # comparar con longitud
	jne bucle               # si no iguales, seguir acumulando
	pop %edi                # recuperar %edi antiguo
	ret


