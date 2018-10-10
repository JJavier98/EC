ASM = $(wildcard *.s)
ATT = $(EXE:=.att)
SRC = main.c msum.c
EXE = $(basename  $(ASM)) $(basename  $(SRC))

ASFLAGS = -nostartfiles
CFLAGS = -Os -Wall

all: $(EXE)

att: $(ATT)

clean:
	-rm -fv $(ATT) $(EXE) core.* *~

%.att: %
	objdump -Cd $< > $@

main: mstore.c
msum: sum.c

.PHONY: all att clean
