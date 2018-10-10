file suma_03_SC
disas _start
printf "longlista[0x%x] = %i\n", &longlista, longlista
printf "lista[0x%x] = %i\n", &lista, lista
break suma
run
x/3wx $esp
run
quit
