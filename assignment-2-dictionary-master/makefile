COMPILER = nasm
COMPILER_ATTRIBUTES = -f elf64 -o
LINKER = ld
LINKER_ATTRIBUTES = -o

.PHONY: all clean test

all: main

clean:
	rm *.o main

test: test.py main
	python test.py

%.o: %.asm
	$(COMPILER) $(COMPILER_ATTRIBUTES) $@ $<


dict.o: dict.asm lib.inc

main.o: main.asm lib.inc dict.inc words.inc

words.inc: colon.inc

main: main.o dict.o lib.o
	$(LINKER) $(LINKER_ATTRIBUTES) $@ $^
