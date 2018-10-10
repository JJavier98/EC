# suma.s: Sumar los elementos de una lista
#         llamando a función, pasando argumentos mediante registros
#         retorna: código retorno 0, comprobar suma en %eax mediante gdb/ddd

# SECCIÓN DE DATOS (.data, variables globales inicializadas)
.section .data
lista:
	.int 0x80000000,0x80000000,-1,-2,-10, 1,2,0b10, 1,2,0x10, 0xffffffff, 0xffabcd34 # números
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
	push %esi 
	push %ebp 
	xor %eax, %eax # poner a 0 acumulador parte baja
	xor %edx, %edx # poner a 0 acumulador parte alta
	xor %edi, %edi # poner a 0 índice
bucle:
	mov (%ebx,%edi,4), %esi # mover i-ésimo elemento
	mov %esi, %ebp		# extiendo el signo
	sar $31, %ebp		# de %esi en %ebp
	add %esi, %eax	        # sumo la parte baja
	adc %ebp, %edx		# sumo la parte alta teniendo en cuenta el acarreo de la baja
	inc %edi                # incrementar índice
	cmp %edi,%ecx           # comparar con longitud
	jne bucle               # si no iguales, seguir acumulando
	pop %ebp                # recuperar %ebp antiguo (%eax y %edx no porque devuelven el resultado)
	pop %esi
	pop %edi
	ret

