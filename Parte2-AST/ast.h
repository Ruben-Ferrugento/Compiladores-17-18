#ifndef AST_FILE
#define AST_FILE

#include "estruturas.h"

ARVORE criarNo (char *tipoVariavel, char *valor);
ARVORE criarIrmao(ARVORE noActual, ARVORE novoNo);
void imprimirAST(ARVORE noActual, int error, int numFilhos, int flagImprimir);
void freeArvore(ARVORE noActual);

#endif