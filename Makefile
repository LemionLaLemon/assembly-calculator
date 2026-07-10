all:
	@mkdir -p obj bin
	nasm -f elf64 src/calculator.asm -o obj/calculator.o
	nasm -f elf64 src/stringutils.asm -o obj/stringutils.o
	ld obj/calculator.o obj/stringutils.o -o bin/calculator
	./bin/calculator

clean:
	rm -rf obj