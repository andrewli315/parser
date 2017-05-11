
all: parser

parser.tab.h: parser.y
	bison -d parser.y

lex.yy.c: lexer.l parser.tab.h parser.tab.c
	flex lexer.l

parser: lex.yy.c parser.tab.c parser.tab.h
	gcc -o parser parser.tab.c lex.yy.c 
clean: 
	rm parser parser.tab.h lex.yy.c
	



