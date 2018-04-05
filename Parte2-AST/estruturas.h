#ifndef ESTRUTURAS_FILE
#define ESTRUTURAS_FILE

typedef struct arvore *ARVORE;
typedef struct arvore{
    /*dados*/
    char* valor;
    char* tipoVariavel;
    /*filho*/
    ARVORE filho;
    ARVORE irmao;
}ARV;

#endif
