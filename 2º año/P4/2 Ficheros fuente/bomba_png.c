// gcc -O0 bomba_png.c -o bomba_png -no-pie -fno-guess-branch-probability

#include <stdio.h>	// para printf(), fgets(), scanf()
#include <stdlib.h>	// para exit()
#include <sys/time.h>	// para gettimeofday(), struct timeval

#define SIZE 100
#define TLIM 60

int elementosVector(char v[])
{
	int j = 0;

	while(v[j] != '\n')
	{
		++j;
	}

	return j;
}

void funcionX(char v[])
{
	int j = elementosVector(v);

	char aux;
	for(int i=0; i < (j-i); i++)
	{
	    aux = v[i];
	    v[i] = v[j-i-1];
	    v[j-i-1] = aux;
	}
}

void boom(void){
	printf(	"\n"
		"***************\n"
		"*** BOOM!!! ***\n"
		"***************\n"
		"\n");
	exit(-1);
}

void defused(void){
	printf(	"\n"
		"·························\n"
		"··· bomba desactivada ···\n"
		"·························\n"
		"\n");
	exit(0);
}

int main(){
	char p[SIZE];
	char p_read[SIZE];
	int pc;
	int m;
	int c;
	int d;
	int u;
	int correcto = 1;
	int n;

	p[0] = 'p';
	p[8] = '\n';
	p[1] = 'o';
	p[7] = 'l';
	p[2] = 'r';
	p[6] = 'i';
	p[3] = 't';
	p[5] = 't';
	p[4] = 'a';


	struct timeval tv1,tv2;	// gettimeofday() secs-usecs
	gettimeofday(&tv1,NULL);

	do	printf("\nIntroduce la contraseña: ");
	while (	fgets(p_read, SIZE, stdin) == NULL );

	gettimeofday(&tv2,NULL);
	if    ( tv2.tv_sec - tv1.tv_sec > TLIM )
	    boom();

	funcionX(p);
	funcionX(p_read);

	int i = elementosVector(p);
	int j = elementosVector(p_read);
	if(i!=j)
		correcto = 0;

	for(int k=0; k<i && correcto; k++){
		if(p[i] != p_read[i])
	    	correcto = 0;
	}

	if(correcto==0)
	    boom();

	do  {printf("\nIntroduce el pin: ");
	 if ((n=scanf("%i",&pc))==0)
		scanf("%*s")    ==1;         }
	while (	n!=1 );

	gettimeofday(&tv1,NULL);
	if    ( tv1.tv_sec - tv2.tv_sec > TLIM )
	    boom();

	m = pc/1000;
	pc -= m*1000;

	c = pc/100;
	pc -= c*100;

	d = pc/10;
	pc -= d*10;

	u = pc;

	int d1 = 2;
	int d2 = 0;
	int d3 = 1;
	int d4 = 8;

	if(	m != d1 || c != d2 || d != d3 || u != d4 )
	    boom();

	defused();
}
