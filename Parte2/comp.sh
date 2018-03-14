#!/bin/sh

lex uccompiler.l
yacc -v -d uccompiler.y
clang-3.8 -o uccompiler y.tab.c lex.yy.c

