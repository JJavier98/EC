###############################################################################
# makefile
###############################################################################

SRC = $(wildcard *.cc)
EXE = suma suma_01_S_cdecl suma_02_S_libC suma_03_SC suma_04_SC suma_05_C \
      suma_06_CS suma_07_Casm suma_08_Casm suma_09_Casm $(basename $(SRC))
ATT = $(EXE:=.att)

###############################################################################

ASFLAGS = --32 -g
LDFLAGS = -L/usr/lib -melf_i386 --no-as-needed
CFLAGS = -fno-omit-frame-pointer -g -lrt -m32 -march=native -O3 -Wall
CXXFLAGS = $(CFLAGS) -std=c++0x

###############################################################################

default: $(EXE)

all: default $(ATT)

clean:
	$(RM) -rfv $(ATT) $(EXE) $(OBJ) core.* perf.* *.o *~

debug: suma.gdb suma
	gdb --batch -q -x "./$<"

###############################################################################

suma: suma.o

###############################################################################

suma_01_S_cdecl: suma_01_S_cdecl.o

###############################################################################

suma_02_S_libC: suma_02_S_libC.o
	$(LD) $(LDFLAGS) -dynamic-linker /lib/ld-linux.so.2 -lc $^ -o $@

###############################################################################

suma_03_SC_c.o: suma_03_SC_c.c
	$(CC) -fno-omit-frame-pointer -g -m32 -O1 -c $^ -o $@

suma_03_SC: suma_03_SC_c.o suma_03_SC_s.o
	$(LD) $(LDFLAGS) -dynamic-linker /lib/ld-linux.so.2 -lc $^ -o $@

###############################################################################

suma_04_SC_c.o: suma_04_SC_c.c
	$(CC) -m32 -O1 -c $^ -o $@

suma_04_SC: suma_04_SC_c.o suma_04_SC_s.o
	$(LD) $(LDFLAGS) -dynamic-linker /lib/ld-linux.so.2 -lc $^ -o $@

###############################################################################

suma_06_CS: suma_06_CS_s.s suma_06_CS_c.c
	$(CC) $(CFLAGS) $^ -o $@

###############################################################################

suma_07_Casm: suma_07_Casm.c
	$(CC) $(CFLAGS) -fno-inline $^ -o $@

###############################################################################

suma_09: suma_09.cc
	$(CXX) $(CXXFLAGS) $^ -o $@

###############################################################################

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

###############################################################################

.PHONY: all clean debug default

###############################################################################

