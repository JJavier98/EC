###############################################################################
# makefile
###############################################################################

SRC = $(wildcard *.c *.cc)
ASM = $(wildcard *.s)
EXE = $(basename $(ASM) $(SRC))
ATT = $(EXE:=.att)
DAT = $(EXE:=.dat)
PERF = $(EXE:=.perf)

###############################################################################

ASFLAGS = -fno-omit-frame-pointer -g -m32 -nostartfiles
CFLAGS = $(ASFLAGS:-nostartfiles=) -Os -Wall
CXXFLAGS = $(CFLAGS) -std=c++11

###############################################################################

default: $(EXE)

all: default $(ATT)

clean:
	$(RM) -rfv $(ATT) $(DAT) $(EXE) core.* *.dat.old *~

###############################################################################

%.att: %
	objdump -C -d -z $< > $@

%.dat: %
	perf record --call-graph dwarf -o $@ ./$<

%.perf: %.dat
	perf report -g -i $< -s symbol

###############################################################################

.PRECIOUS: $(DAT)
.PHONY: all clean default

###############################################################################

