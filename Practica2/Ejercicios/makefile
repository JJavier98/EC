###############################################################################
# makefile
###############################################################################

SRC = $(wildcard *.cc)
ASM = $(wildcard *.s)
EXE = $(basename $(ASM) $(SRC)) p
ATT = $(EXE:=.att)
DAT = $(EXE:=.dat)
PERF = $(EXE:=.perf)

###############################################################################

ASFLAGS = --32 -g
LDFLAGS = -melf_i386
CFLAGS = -fno-omit-frame-pointer -ggdb -m32 -Os -Wall
CXXFLAGS = $(CFLAGS)

###############################################################################

default: $(EXE)

all: $(ATT)

call: $(EXE)
	for i in $^; do \
		valgrind --tool=callgrind --cache-sim=yes --collect-jumps=yes --branch-sim=yes --dump-instr=yes ./$$i; \
	done

clean:
	$(RM) -rfv $(ATT) $(DAT) $(EXE) callgrind.out.* *.old *~

###############################################################################

$(basename $(ASM)): CFLAGS+=-nostartfiles

p:	p1.c p2.c
	$(CC) $(CFLAGS) $^ -o $@

%: %.s
	$(CC) $(CFLAGS) $< -o $@

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

%: %.o
	$(LD) $(LDFLAGS) $< -o $@

%: %.c
	$(CC) $(CFLAGS) $< -o $@

%: %.cc
	$(CXX) $(CXXFLAGS) $< -o $@

%.att: %
	objdump -C -d $< > $@

%.dat: %
	perf record --call-graph dwarf -g -o ./$@ ./$<

%.perf: %.dat
	perf report -g -i ./$< # --no-children

###############################################################################

.PRECIOUS: $(DAT)
.PHONY: all call clean default

###############################################################################

