# suma.s: Sumar los elementos de una lista
#         llamando a función, pasando argumentos mediante registros
#         retorna: código retorno 0, comprobar suma en %eax mediante gdb/ddd

# SECCIÓN DE DATOS (.data, variables globales inicializadas)
.section .data
lista:
	.int 0x1, 0x5, 24 # ejemplos binario 0b / hex 0x
longlista:
	.int (.-lista)/4 # .= contador posiciones. Aritmética de etiquetas.
resultado:
	.int -1 # 4B a FF para notar cuándo se modifica cada byte
formato:
	.string "suma = %lli / %llu / 0x%llx\n"

# SECCIÓN DE CÓDIGO (.text, instrucciones máquina)
.section .text
	.global _start # PROGRAMA PRINCIPAL - se puede abreviar de esta forma
	.extern exit   # exit no está definido en este fichero
	.extern printf # busca printf fuera de este fichero

_start:

	mov $lista, %ebx    # dirección del array lista
	mov longlista, %ecx # número de elementos a sumar
	call suma           # llamar suma(&lista, longlista);
	mov %eax,resultado  # salvar resultado
	mov %edx, resultado

	push resultado +4      # apila resultado
	push resultado      # apila resultado
	push resultado +4      # apila resultado
	push resultado      # apila resultado
	push resultado +4      # apila resultado
	push resultado      # apila resultado
	push $formato       # apila formato
	call printf         # llamada a función printf(&formato, resultado)
	add $28, %esp       # dejar pila intacta

	# void _exit(int status);
	push $0             # valor de retorno
	call exit           # llamada a función exit

# SUBRUTINA: suma(int* lista, int longlista);
#            entrada: 1) %ebx = dirección inicio array
#                     2) %ecx = número de elementos a sumar
#            salida:     %eax = resultado de la suma

suma:
	# preservar %esi (se usa aquí como índice)
	xor %eax, %eax # poner a 0 acumulador1
	xor %edx, %edx # poner a 0 acumulador2
	xor %esi, %esi # poner a 0 índice
bucle:
	add (%ebx,%esi,4), %eax # acumular i-ésimo elemento
	adc $0, %edx		# acumular el acarreo en %edx
	inc %esi                # incrementar índice
	cmp %esi,%ecx           # comparar con longitud
	jne bucle               # si no iguales, seguir acumulando
	# recuperar %esi antiguo
	ret

