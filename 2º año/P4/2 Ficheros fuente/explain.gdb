# Practica 4, Actividad 4.1: explicacion de la bomba

# CONTRASEÑA: portatil
# 	 PIN: 2018

# MODIFICADA: hola,adios
#	 PIN: 123

# Describe el proceso logico seguido
# primero: para descubrir las claves, y
# despues: para cambiarlas

# Pensado para ejecutar mediante "source explain.gdb"
# o desde linea de comandos con gdb -q -x explain.gdb
# Renombrar temporalmente el fichero "bomba-gdb.gdb"
# para que no se cargue automat. al hacer "file bomba"

# funciona sobre la bomba original, para recompilarla
# usar la orden gcc en la primera linea de bomba.c
# gcc -Og bomba.c -o bomba -no-pie -fno-guess-branch-probability

########################################################

### cargar el programa
	file bomba_png
### util para la sesion interactiva, no para source/gdb -q -x
#	layout asm
#	layout regs
### arrancar programa, notar automatizacion para teclear hola y 123
	br *main+136
	run < <(echo -e hola,adios\\n1234\\n)
### Avanzamos hasta la activación de la bomba más cercana.
### En este caso es una activación por tiempo.
### De camino hasta esta posición el programa nos gabrá pedido la
### contraseña pero se habrá introducido automáticamente.
### lo que debemos hacer es igualar $rax a 0 para que no explote.
	set $rax=0
### Hay una funcionX un tanto peculiar de la cual desconocemos su funcionamiento,
### pero vemos que se le pasa como parámetro una variable global p que está en
### 0x602060 vamos a imprimir para ver la contraseña
	br *main+154
	cont
	p(char*)0x602060
### Vemos la funcion elementosVector que si la estudiamos averiguamos
### que cuenta el número de elementos que tiene un vector
### (algo lógico por el nombre). La primera vez que se le llama se le
### pasa como parámetro la contraseña real. Vamos a cambiar el resultado devuelto
### a 0 para, posteriormente, saltarnos el bucle de comprobación. 
	### Podemos ver la contraseña de la siguiente manera:
		p(char*)0x602060
	#vemos que la contraseña ha cambiado

	br *main+183
	cont
	set $eax=0
### También, en la siguiente llamada a elementosVector, engañamos diciendo
### que nuestra contraseña tiene la longitud de la original 
### $eax(la supuesta longitud de la original) lo haremos igual
### a la longitud de nuestra contraseña, en este caso 10
	br *main+213
	cont
	set $eax=10
### Avanzamos hasta la activación de la bomba más cercana.
### En este caso es una activación por tiempo.
### De camino hasta esta posición el programa nos gabrá pedido el
### pin pero se habrá introducido automáticamente.
### lo que debemos hacer es igualar $rax a 0 para que no explote.
	br *main+456
	cont
	set $rax=0
### La siguiente activacion de la bomba está casi al final del programa
### despues de una secuencia muy seguida de cmp y jne. Además aparecen comentarios
### de otras variables globales (d1,d2,d3,d4). Podemos suponer que se trata del pin.
### Como las comparaciones se hacen respecto a los datos que nostros hemos introducido
### debemos poner en el registro $eax de cada cmp los números de nuestro pin

### Para saber cual es la contraseña real
	p(int) d1
	p(int) d2
	p(int) d3
	p(int) d4
### Debemos guardar donde están guardados(0x60206c, 0x60208c, 0x602070, 0x602074)

	br *main+666
	cont
	set $eax=1
	ni
	ni
	ni
	set $eax=2
	ni
	ni
	ni
	set $eax=3
	ni
	ni
	ni
	set $eax=4
	cont

########################################################

### permitir escribir en el ejecutable
	set write on
### reabrir ejecutable con permisos r/w
	file bomba_png
### realizar los cambios
	set {char[13]}0x602060="hola,adios.\n"
	set {int     }0x60206c=1
	set {int     }6299789=2
	set {int     }0x602070=3
	set {int     }0x602074=4
### comprobar las instrucciones cambiadas
	p (char[0xd])p
	p (int)d1
	p (int)d2
	p (int)d3
	p (int)d4
### salir para desbloquear el ejecutable
	quit

########################################################













