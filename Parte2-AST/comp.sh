#!/bin/sh

lex uccompiler.l
yacc -v -d uccompiler.y
clang-3.8 ast.c -o ucc -g y.tab.c lex.yy.c
valgrind --leak-check=full ./ucc -t < CasosTestes/BinToOctal.c
cp uccompiler.l uccompiler
cp uccompiler.y uccompiler
cp ast.c uccompiler
cp ast.h uccompiler
cp estruturas.h uccompiler
rm uccompiler.zip
zip -rq uccompiler.zip uccompiler
