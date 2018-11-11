# Practica 4, Actividad 4.1: explicacion de la bomba

# CONTRASEÑA: portatil
# 	 PIN: 2018

# MODIFICADA: hola,adios.
#	 PIN: 1234

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
#   layout asm
#   layout regs
### arrancar programa, notar automatizacion para teclear hola y 123
    br *main+99
    run < <(echo -e hola\\n1234\\n)
### vemos que hay una consecución de movb muy seguida y que,
### además, se almacenan en una variable 'p' que parece ser
### un vector. Vemos que se ejecutan 9 movb (desde p hasta p+8).
#	0x400834 <main+36>      movb   $0x70,0x201865(%rip)        # 0x6020a0 <p>
#   0x40083b <main+43>      movb   $0x72,0x201860(%rip)        # 0x6020a2 <p+2>
#   0x400842 <main+50>      movb   $0x69,0x20185d(%rip)        # 0x6020a6 <p+6>
#   0x400849 <main+57>      movb   $0xa,0x201858(%rip)         # 0x6020a8 <p+8>
#   0x400850 <main+64>      movb   $0x6f,0x20184a(%rip)        # 0x6020a1 <p+1> 
#   0x400857 <main+71>      movb   $0x74,0x201845(%rip)        # 0x6020a3 <p+3> 
#   0x40085e <main+78>      movb   $0x74,0x201840(%rip)        # 0x6020a5 <p+5> 
#   0x400865 <main+85>      movb   $0x61,0x201838(%rip)        # 0x6020a4 <p+4> 
#   0x40086c <main+92>      movb   $0x6c,0x201834(%rip)        # 0x6020a7 <p+7> 
### Imprimimos 9 chars (es lo más lógico pensar que son chars puesto
### que están copiando bytes). Parece ser la contraseña.
### Anotamos que está en 0x6020a0.
    p(char[0x9])p
#   p(char*)0x6020a0
### Avanzamos hasta la activación de la bomba más cercana.
### En este caso es una activación por tiempo.
### De camino hasta esta posición el programa nos gabrá pedido la
### contraseña pero se habrá introducido automáticamente.
### lo que debemos hacer es igualar $rax a 0 para que no explote.
	br *main+199
	cont
	set $rax=0
### Vemos la funcion elementosVector que si la estudiamos averiguamos
### que cuenta el número de elementos que tiene un vector
### (algo lógico por el nombre). La primera vez que se le llama se le
### pasa como parámetro la contraseña real. Vamos a cambiar el resultado devuelto
### a 0 para, posteriormente, saltarnos el bucle de comprobación. 
	br *main+246
	cont
	set $eax=0
### También engañamos diciendo que nuestra contraseña tiene la longitud de la original
### $eax(la supuesta longitud de la original) lo haremos igual a la longitud de nuestra
### contraseña, en este caso 4
	br *main+276
	cont
	set $eax=4
### Avanzamos hasta la activación de la bomba más cercana.
### En este caso es una activación por tiempo.
### De camino hasta esta posición el programa nos gabrá pedido el
### pin pero se habrá introducido automáticamente.
### lo que debemos hacer es igualar $rax a 0 para que no explote.
	br *main+519
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

	br *main+729
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
    set {char[13]}p="hola,adios.\n"
    set {int}d1=1
    set {int}d2=2
    set {int}d3=3
    set {int}d4=4
### comprobar las instrucciones cambiadas
    p (char[0xd])p
    p (int      )d1
    p (int      )d2
    p (int      )d3
    p (int      )d4
### salir para desbloquear el ejecutable
    quit

########################################################



















