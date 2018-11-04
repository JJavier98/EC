//COMANDO PARA LA EJECUCIÓN:
//for i in $(seq 1 4);do rm popcount; gcc -D TEST=$i popcount.c -o popcount; ./popcount ; done

// COMANDO PARA LA DEPURACION DE UN TEST EN CONCRETO
// gcc popcount.c -o popcount -Og -g -D TEST=1

/*
=== TESTS === ____________________________________
for i in 0 g 1 2; do
printf "__OPTIM%1c__%48s\n" $i "" | tr " " "="
for j in $(seq 1 4); do
printf "__TEST%02d__%48s\n" $j "" | tr " " "-"
rm popcount
gcc popcount.c -o popcount -O$i -D TEST=$j -g
./popcount
done
done
=== CRONOS === ____________________________________
for i in 0 g 1 2; do
printf "__OPTIM%1c__%48s\n" $i "" | tr " " "="
rm popcount
gcc popcount.c -o popcount -O$i -D TEST=0
for j in $(seq 0 10); do
echo $j; ./popcount
done | pr -11 -l 22 -w 80
done
___________________________________________________
*/

#include <stdio.h>		// para printf()
#include <stdlib.h>		// para exit()
#include <stdint.h>		// para uint32_t y uint64_t
#include <sys/time.h>	// para gettimeofday(), struct timeval

unsigned resultado=0;	// varable donde se almacenará los resultados de los popcounts

#define LONG_SIZE 8*sizeof(long)	// longitud de una variable de tipo LONG en nuestra arquitectura
#define INT_SIZE 8*sizeof(int)		// longitud de una variable de tipo INT en nuestra arquitectura

//	Máscaras para aplicar en algunos funciones popcount
const uint32_t m1 	= 0x55555555; 			//binary: 01010101010101010101010101010101
const uint32_t m2 	= 0x33333333; 			//binary: 00110011001100110011001100110011
const uint32_t m4 	= 0x0f0f0f0f; 			//binary: 00001111000011110000111100001111
const uint32_t m8 	= 0x00ff00ff; 			//binary: 00000000111111110000000011111111
const uint32_t m16 	= 0x0000ffff; 			//binary: 00000000000000001111111111111111

const uint64_t m1_64 	= 0x5555555555555555; 	//binary: 0101010101010101010101010101010101010101010101010101010101010101
const uint64_t m2_64 	= 0x3333333333333333; 	//binary: 0011001100110011001100110011001100110011001100110011001100110011
const uint64_t m4_64 	= 0x0f0f0f0f0f0f0f0f; 	//binary: 0000111100001111000011110000111100001111000011110000111100001111
const uint64_t m8_64 	= 0x00ff00ff00ff00ff; 	//binary: 0000000011111111000000001111111100000000111111110000000011111111
const uint64_t m16_64 	= 0x0000ffff0000ffff; 	//binary: 0000000000000000111111111111111100000000000000001111111111111111
const uint64_t m32_64 	= 0x00000000ffffffff; 	//binary: 0000000000000000000000000000000011111111111111111111111111111111

/* DEFINICIÓN DE LOS TEST
 * DEPENDIENDO DEL TEST ELEGIDO LAS FUNCIONES
 * POPCOUNT TRABAJARÁN CON UNA LISTA DE VALORES U OTRA
 */
#ifndef TEST
#define TEST 20
#endif

#if TEST==1
	#define SIZE 4
	unsigned lista[SIZE]={0x80000000, 0x00400000, 0x00000200, 0x00000001};
#elif TEST==2
	#define SIZE 8
	unsigned lista[SIZE]={0x7fffffff, 0xffbfffff, 0xfffffdff, 0xfffffffe, 0x01000023, 0x00456700, 0x8900ab00, 0x00cd00ef};
#elif TEST==3
	#define SIZE 8
	unsigned lista[SIZE]={0x0, 0x01020408, 0x35906a0c, 0x70b0d0e0, 0xffffffff, 0x12345678, 0x9abcdef0, 0xdeadbeef};
#elif TEST==4 || TEST==0
	#define NBITS 20
	#define SIZE (1<<NBITS)
	unsigned lista[SIZE];
	#define RESULT ( NBITS * ( 1 << NBITS-1 ) )	
#endif

///////	  CRONO   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// FUNCIÓN CRONO PROPORCIONADA EN EL GUIÓN
void crono(int (*func)(), char* msg){
	struct timeval tv1,tv2; // gettimeofday() secs-usecs
	long tv_usecs;			// y sus cuentas

	gettimeofday(&tv1,NULL);
	resultado = func(lista, SIZE);
	gettimeofday(&tv2,NULL);

	tv_usecs = (tv2.tv_sec - tv1.tv_sec ) * 1E6 + (tv2.tv_usec - tv1.tv_usec);
#if TEST==0
	printf(	"%ld" "\n",	tv_usecs);
#else
	printf("resultado = %d\t", resultado);
	printf("%s:%9ld us\n", msg, tv_usecs);
#endif
}

///////   POPCOUNTs   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/* POPCOUNT1:
 * RECORRE TODOS LOS BITS DE CADA DATO DEL VECTOR
 * APLICÁNDOLE LA MÁSCARA 0X1, ES DECIR, QUEDÁNDONOS
 * CADA VEZ CON EL ÚLTIMO BIT DEL DATO.
 * PARA CADA NÚMERO SE APLICA LA MÁSCARA EL MISMO NÚMERO
 * DE VECES (INT_SIZE)
 */
int popcount1(unsigned *v, size_t len)
{
	size_t i;
	size_t j;
	unsigned x;
	for (i = 0; i < len; ++i)
	{
		x = v[i];

		for(j = 0; j < INT_SIZE; ++j)
		{
		    resultado += x & 0x1;
			x >>= 1;
		}
	}
	return resultado;
}

/* POPCOUNT2:
 * RECORRE LOS BITS DE CADA DATO DEL VECTOR HASTA
 * QUE TODOS SUS BITS SEAN 0, ES DECIR, V[I] == 0
 * LA MÁSCARA QUE SE LE APLICA ES IGUAL A LA DE POPCOUNT1
 */
int popcount2(unsigned *v, size_t len)
{
	size_t i;
	unsigned x;
	for (i = 0; i < len; ++i)
	{
		x = v[i];
		while(x)
		{
		    resultado += x & 0x1;
			x >>= 1;
		}
	}
	return resultado;
}

/* POPCOUNT3:
 * EN ESTA VERSIÓN HACEMOS USO DEL ENSAMBLADOR
 * EN LÍNEA. CON LA INSTRUCCIÓN SHR DESPLAZAMOS,
 * EN CADA ITERACIÓN, UNA POSICIÓN A LA DERECHA.
 * EL BIT DESBORDADO SE ALMACENA EN EL FLAG CF Y
 * NOS APROVECHAMOS DE ESTO PARA ACUMULARLOS EN
 * 'resultado' CON LA INSTRUCCIÓN ADC.
 * EL BUCLE INTERNO, AL IGUAL QUE EN LA VERSIÓN
 *  ANTERIOR, FINALIZA CUANDO CUANDO V[I] == 0
 */
int popcount3(unsigned *v, size_t len)
{
	size_t i;
	unsigned x;
	for (i = 0; i < len; ++i)
	{
		x = v[i];
		asm("\n"
		"ini3:				\n\t"
			"shr %[x]		\n\t"
			"adc $0, %[r]	\n\t"
			"test %[x], %[x]	\n\t"
			"jne ini3		\n\t"
			:[r]"+r"(resultado)
			:[x]"r"(x)
			);
	}
	return resultado;
}

/* POPCOUNT4:
 * EN ESTA VERSIÓN HACEMOS USO DEL ENSAMBLADOR
 * EN LÍNEA. ES IGUAL QUE LA VERSIÓN ANTERIOR
 * PERO AQUÍ EVITAMOS EL USO DE TEST YA QUE
 * LA INSTRUCCIÓN SHR ALTERA TAMBIÉN EL FLAG ZF
 * EL USO DE LA ETIQUETA 'fin4' NO LO HE VISTO
 * NECESARIO 
 */
int popcount4(unsigned *v, size_t len)
{
	size_t i;
	unsigned x;

	for (i = 0; i < len; ++i)
	{
		x = v[i];
		asm("clc 			\n\t"	//	LIMPIAMOS EL CONTENIDO DE LOS FLAGS
		"ini4:				\n\t"
			"adc $0, %[r]	\n\t"
			"shr %[x]		\n\t"
			"jne ini4		\n\t"	// SI %[x] ES DISTINTO DE 0 REPITE EL BUCLE
			"adc $0, %[r]	\n\t"
			:[r]"+r"(resultado)
			:[x]"r"(x)
			:"cc"
			);
	}
	return resultado;
}

/* POPCOUNT5:
 * EN ESTA VERSIÓN REALIZAMOS LA SUMA DE BITS
 * ACTIVOS BYTE A BYTE GRACIAS A LA MÁSCARA 0x01010101
 * CON ESTA MÁSCARA OBTENEMOS EL PRIMER BIT DE CADA BYTE
 * DE UN DATO DEL VECTOR. POR ESTO DEBEMOS REALIZAR
 * 8 DESPLAZAMIENTOS. TRAS REALIZAR TODOS LOS DESPLAZAMIENTOS
 * SUMAREMOS LOS BYTES EN FORMA DE ARBOL DE LA VARIABLE
 * 'resultado' Y APLICAREMOS UNA MÁSCARA PARA QUEDARNOS
 * SOLO CON LOS VALORES DEL ÚLTIMO BYTE (EL VALOR CORRECTO
 * DE LA SUMA - EL PESO HAMMING)
 */
int popcount5(unsigned *v, size_t len)
{
	unsigned val = 0, x;
	size_t i,j;
	for(j = 0; j < len ; ++j)
	{
		x = v[j];
		val = 0;
		for (i = 0; i < 8; ++i)
		{

			val += x & 0x01010101;
			x >>= 1;
		}
		val += (val >> 16);
		val += (val >> 8);

		resultado += (val & 0xFF);
	}

	return resultado;
}

/* POPCOUNT6:
 * ESTA VERSIÓN PODRÍA CONSIDERARSE UN DESENROLLAMIENTO
 * DE LA VERSIÓN ANTERIOR. EN VEZ DE REALIZAR UNA SUMA
 * TRATANDOLA COMO SI FUERA UN ÁRBOL, APLICAMOS VARIAS MÁSCARAS
 * PARA IR SUMANDO CADA 2 BITS, 4 BITS, 8 BITS, 16 BITS Y POR
 * ÚLTIMO CADA 32
 */
int popcount6(unsigned *v, size_t len)
{
	size_t i;
	unsigned x;
	for(i=0; i<len; ++i)
	{
		x = v[i];
		x = (x & m1 ) + ((x >> 1) & m1 ); //put count of each 2 bits into those 2 bits
		x = (x & m2 ) + ((x >> 2) & m2 ); //put count of each 4 bits into those 4 bits
		x = (x & m4 ) + ((x >> 4) & m4 ); //put count of each 8 bits into those 8 bits
		x = (x & m8 ) + ((x >> 8) & m8 ); //put count of each 16 bits into those 16 bits
		x = (x & m16) + ((x >> 16) & m16); //put count of each 32 bits into those 32 bits

		resultado+=x;
	}
	return resultado;
}

/* POPCOUNT7:
 * ESTA VERSIÓN ESTÁ AÚN MÁS DESENROLLADA SI CABE.
 * LAS MÁSCARAS APLICADAS EN LA VERSIÓN ANTERIOR
 * LAS TRANSFORMAMOS EN MÁSCARAS DE 64BITS YA QUE
 * VAMOS A ASIGNAR DOS COMPONENTES DEL VECTOR DE ENTEROS
 * A UNA MISMA VARIABLE (HABRÁ DOS DATOS EN UNA MISMA VARIABLE
 * X = V[i]V[i+1] ). SI ESTO LO REALIZAMOS DOS VECES,
 * ES DECIR, TENEMOS DOS VARIABLES LONG Y EN CADA UNA DE
 * ELLAS 2 VARIABLES DEL VECTOR ESTAREMOS TOMANDO 128 BITS
 * EN UNA SOLA ITERACIÓN.
 */
int popcount7(unsigned *v, size_t len)
{
	size_t i;
	unsigned long x,y;

	if (len & 0x3)
		printf("leyendo 128b pero len no múltiplo de 4\n");

	for(i=0; i<len; i+=4)
	{
		x = *(unsigned long*) &v[i];
		y = *(unsigned long*) &v[i+2];

		x = (x & m1_64 ) + ((x >> 1) & m1_64 ); //put count of each 2 bits into
		x = (x & m2_64 ) + ((x >> 2) & m2_64 ); //put count of each 4 bits into
		x = (x & m4_64 ) + ((x >> 4) & m4_64 ); //put count of each 8 bits into
		x = (x & m8_64 ) + ((x >> 8) & m8_64 ); //put count of each 16 bits into
		x = (x & m16_64) + ((x >> 16) & m16_64); //put count of each 32 bits into
		x = (x & m32_64) + ((x >> 32) & m32_64); //put count of each 64 bits into

		y = (y & m1_64 ) + ((y >> 1) & m1_64 ); //put count of each 2 bits into
		y = (y & m2_64 ) + ((y >> 2) & m2_64 ); //put count of each 4 bits into
		y = (y & m4_64 ) + ((y >> 4) & m4_64 ); //put count of each 8 bits into
		y = (y & m8_64 ) + ((y >> 8) & m8_64 ); //put count of each 16 bits into
		y = (y & m16_64) + ((y >> 16) & m16_64); //put count of each 32 bits into
		y = (y & m32_64) + ((y >> 32) & m32_64); //put count of each 64 bits into

		resultado += x+y;
	}
	return resultado;
}

/* POPCOUNT8:
 * EN ESTA VERSIÓN HACEMOS USO DE INSTRUCCIONES
 * MULTIMEDIA SSSE3 Y EN PARTICULAR, LA INTERANTE ES
 * PSHUFB, UNA INSTRUCCIÓN SIMD (SINGLE INSTRUCTION MULTIPLE DATA)
 * QUE NOS PERMITE BARAJAR EL SEGUNDO PARÁMETRO PASADO
 * SEGUN LAS RESTRICCIONES IMPUESTAS CON EL PRIMERO.
 * ASM CARGA 4 ENTEROS EN UN REGISTRO XMM Y SACA COPIA EN OTRO XMM.
 * CARGA UNA MÁSCARA PARA QUEDARSE CON NIBBLES INFERIORES. DESPLAZA
 * 4B UNA DE LAS COPIAS, DE MANERA QUE AL APLICAR LA MÁSCARA A AMBAS
 * COPIAS, RESULTEN SEPARADOS LOS NIBBLES INFERIORES Y SUPERIORES EN
 * SU CORRESPONDIENTE REGISTRO XMM. SE CARGAN ENTONCES DOS COPIAS DE
 * LA LUT Y SE BARAJAN USANDO COMO ÍNDICES LOS NIBBLES, OBTENIENDO
 * LOS POPCOUNT RESPECTIVOS
 */
int popcount8(unsigned* v, size_t len){
	size_t i;
	int val;
	int SSE_mask[] = {0x0f0f0f0f, 0x0f0f0f0f, 0x0f0f0f0f, 0x0f0f0f0f};
	int SSE_LUTb[] = {0x02010100, 0x03020201, 0x03020201, 0x04030302};
					//	3 2 1 0		7 6 5 4	    11109 8	    15141312

	if (len & 0x3) printf("leyendo 128b pero len no múltiplo de 4\n");
	for (i=0; i<len; i+=4)
	{
		asm("movdqu	%[x], %%xmm0	\n\t"
			"movdqa %%xmm0, %%xmm1 	\n\t" //; x: two copies xmm0-1
			"movdqu	%[m], %%xmm6 	\n\t" //: mask: xmm6
			"psrlw	$4 , %%xmm1 	\n\t"
			"pand	%%xmm6, %%xmm0 	\n\t" //; xmm0 – lower nibbles
			"pand	%%xmm6, %%xmm1 	\n\t" //; xmm1 – higher nibbles

			"movdqu %[l], %%xmm2 	\n\t" //; since instruction pshufb modifies LUT
			"movdqa %%xmm2, %%xmm3 	\n\t" //; we need 2 copies
			"pshufb %%xmm0, %%xmm2 	\n\t" //; xmm2 = vector of popcount lower nibbles
			"pshufb %%xmm1, %%xmm3 	\n\t" //; xmm3 = vector of popcount upper nibbles	
		
			"paddb %%xmm2, %%xmm3 	\n\t" //; xmm3 – vector of popcount for bytes
			"pxor %%xmm0, %%xmm0 	\n\t" //; xmm0 = 0,0,0,0
			"psadbw %%xmm0, %%xmm3 	\n\t" //; xmm3 = [pcnt bytes0..7|pcnt bytes8..15]
			"movhlps %%xmm3, %%xmm0 \n\t" //; xmm0 = [		0		|pcnt bytes0..7 ]
			"paddd %%xmm3, %%xmm0 	\n\t" //; xmm0 = [ 	not needed 	|pcnt bytes0..15]
			"movd %%xmm0, %[val]		"
			: [val]"=r" (val)
			: [x] "m" (v[i]),
			[m] "m" (SSE_mask[0]),
			[l] "m" (SSE_LUTb[0])
		);

		resultado += val;
	}
	return resultado;
}

/* POPCOUNT9:
 * EN ESTA VERSIÓN HACEMOS USO DE UNA INSTRUCCIÓN SSE4
 * 'popcnt' QUE CALCULA EL PESO HAMMING DEL PRIMER PARÁMETRO
 * Y LO ALMACENA EN EL SEGUNDO.
 */
int popcount9(unsigned* v, size_t len){
	size_t i;
	int val;

	for (i=0; i<len; ++i)
	{
		asm("popcnt	%[x], %[val]"
			: [val]"=r" (val)
			: [x] "m" (v[i])
		);

		resultado += val;
	}
	return resultado;
}

/* POPCOUNT9:
 * ESTA VERSIÓN ES IGUAL QUE LA ANTERIOR PERO APLICANDO LA FILOSOFÍA
 * DE LA VERSIÓN 7, DESENROLLAR EL BUCLE TRABAJANDO CON 128 BITS
 * EN UNA SOLA ITERACIÓN.
 */
int popcount10(unsigned* v, size_t len){
	size_t i;
	unsigned long x, y;
	long val;

	if (len & 0x3) printf("leyendo 128b pero len no múltiplo de 4\n");

	for (i=0; i<len; i+=4)
	{
		x = *(unsigned long*) &v[i];
		y = *(unsigned long*) &v[i+2];
		asm("popcnt	%[y], %[val]	\n\t"
			"popcnt	%[x], %[y]		\n\t"
			"add 	%[y], %[val]	\n\t"
			: 	[val]"+r" (val),
				[y]"+r" (y)
			: 	[x] "m" (x)
		);

		resultado += val;
	}
	return resultado;
}

///////   MAIN   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

int main()
{
// SI ESTAMOS EJECUTANDO TEST0 O TEST4 INICIALIZAMOS LA LISTA
// DE SIZE ENTEROS DE MANERA QUE lista[0] == 0 y lista[SIZE] == SIZE-1
#if TEST==0 || TEST==4
	unsigned i;
	for (i=0; i<SIZE; i++)
		lista[i]=i;
#endif

	// EJECUTAMOS TODAS LAS VERSIONES DE popcount DENTRO DE crono PARA
	// CALCULAR SU TIEMPO DE EJECUCIÓN. AL FINAL DE CADA crono IGUALAMOS
	// resultado A 0 YA QUE LA VARIABLE ES GLOBAL.
	crono(popcount1 ,"popcount1 (lenguaje C -	for)"); resultado = 0;
	crono(popcount2 ,"popcount2 (lenguaje C -	while)"); resultado = 0;
	crono(popcount3 ,"popcount3 (leng.ASM-body while 4i)"); resultado = 0;
	crono(popcount4 ,"popcount4 (leng.ASM-body while 3i)"); resultado = 0;
	crono(popcount5 ,"popcount5 (CS:APP2e 3.49-group 8b)"); resultado = 0;
	crono(popcount6 ,"popcount6 (Wikipedia- naive - 32b)"); resultado = 0;
	crono(popcount7 ,"popcount7 (Wikipedia- naive -128b)"); resultado = 0;
	crono(popcount8 ,"popcount8 (asm SSE3 - pshufb 128b)"); resultado = 0;
	crono(popcount9 ,"popcount9 (asm SSE4- popcount 32b)"); resultado = 0;
	crono(popcount10,"popcount10(asm SSE4- popcount128b)");

	printf("\n");

#if TEST != 0
	printf("calculado = %d\n", resultado);
#endif
	exit(0);
}