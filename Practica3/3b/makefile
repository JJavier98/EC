###############################################################################
# makefile
###############################################################################

SHELL = /bin/bash

###############################################################################

SRC = $(wildcard *.c *.cc)
EXE = $(basename $(SRC))
ATT = $(EXE:=.att)
DAT = $(EXE:=.dat)
PNG = $(DAT:.dat=.png) $(DAT:.dat=-log.png)
SVG = $(DAT:.dat=.svg) $(DAT:.dat=-log.svg)

PLT =  "set terminal svg enhanced background rgb 'white'; \
		set output '$@'; \
		set key top center horizontal; \
		set grid; \
		set ylabel 'total time (μs)'; \
		set y2label 'cpu cycles'; \
		set xtics rotate; \
		set ytics; \
		set ytics nomirror; \
		set y2tics; \
		set y2tics nomirror; \
		set style fill solid 0.10 border; \
		set boxwidth 0.80; \
		unset logscale y; \
		unset logscale y2; \
		plot '$<' u 5:xtic(1) w boxes axes x1y1 title 'total time', \
		     '$<' u 3:xtic(1) w lp pt 7 axes x1y2 title 'cycles'"

###############################################################################

CFLAGS = -fno-omit-frame-pointer -m32 -march=native -Ofast -std=c11 -Wall # final
#CFLAGS = -fno-omit-frame-pointer -g -m32 -O3 -std=c11 -Wall # desarrollo
CXXFLAGS = $(CFLAGS:c11=c++11)

###############################################################################

default: $(EXE)

all: $(ATT) $(PNG) $(SVG)

clean:
	$(RM) -rfv $(ATT) $(DAT) $(EXE) $(PNG) $(SVG) core.* *~

###############################################################################

popcnt: popcnt.cpp
	g++ -O3 popcnt.cpp -o popcnt -mpopcnt -mssse3 #-fopenmp

###############################################################################

%.att: %
	objdump -C -d $< > $@

%.dat: %
	./$< | tee $@

#%.png: %.svg
#	convert $< $@

%.png: %.dat makefile
	@gnuplot <<< $(subst svg enhanced background rgb 'white',pngcairo enhanced,$(PLT))

%-log.png: %.dat makefile
	@gnuplot <<< $(subst svg enhanced background rgb 'white',pngcairo enhanced,$(PLT:unset=set))

%.svg: %.dat makefile
	@gnuplot <<< $(PLT)

%-log.svg: %.dat makefile
	@gnuplot <<< $(PLT:unset=set)

###############################################################################

.PHONY: all clean default
.PRECIOUS: $(DAT)
.NOEXPORT:

###############################################################################
