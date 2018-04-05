#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "estruturas.h"
#include "ast.h"


/* Cada nó tem que ser criado, introduzindo o valor da variavel (p.e. 5) e o tipo da variavel (p.e. INT)
*  No final o nó deve ser devolvido outra vez
*/
ARVORE criarNo (char *tipoVariavel, char *valor){
    ARVORE no;
    no = (ARVORE)malloc(sizeof(ARV));

    if(no != NULL){
        /*NECESSÁRIO ALOCAR MEMORIA PARA O COPY DA STRING*/
        if(valor == NULL){
            no->valor = valor;
        }else{
            no->valor = strdup (valor); 
        }

        if(tipoVariavel == NULL){
            no->tipoVariavel = tipoVariavel;
        }else{
            no->tipoVariavel = strdup(tipoVariavel);
        }
        
        //no->valor = (char*)malloc(strlen(valor) + 1);
        //strcpy(no->valor, valor);
        
        no->filho = NULL;
        no->irmao = NULL;        
        //printf("<<<<<< >>>>>>><<<<<<<<<>>>>>>> %s\n", no->tipoVariavel);
    }
    return no;
}

/* Os nós IRMAOS sao criados aqui. 
* A ideia é percorrer todos os nós irmaos de um no filho até ao ultimo 
* e só depois usar a função acima para criar o no: criarNo
* Deve retornar o nó que é criado quando noActual não é NULL
*/
ARVORE criarIrmao(ARVORE noActual, ARVORE novoNo){
    ARVORE aux;
    if(noActual == NULL){
        return novoNo;
    }
    
    aux = noActual;
    while(aux->irmao != NULL){
        aux = aux->irmao;
    }
    
    aux->irmao = novoNo;
    return noActual;
}


void imprimirAST(ARVORE noActual, int error, int numFilhos, int flagImprimir){
	int i;
    if(noActual != NULL){
        if(error ==  0 && flagImprimir == 0){
            if(noActual->valor != NULL){
                for(i=0; i < numFilhos; i++){
                    printf("..");
                }
                printf("%s(%s)\n", noActual->tipoVariavel, noActual->valor);
            }else{
                for(i=0; i < numFilhos; i++){
                    printf("..");
                }
                printf("%s\n", noActual->tipoVariavel);
            }
        }
            
        if(noActual->filho != NULL){
            numFilhos += 1;
            imprimirAST(noActual->filho, error, numFilhos, flagImprimir);
            numFilhos -= 1;
        }

        if(noActual->irmao != NULL ){
            imprimirAST(noActual->irmao, error, numFilhos, flagImprimir);
        }    
        
        if(noActual->tipoVariavel != NULL){
            free(noActual->tipoVariavel);
        }
        if(noActual->valor != NULL){
            free(noActual->valor);
        }
        free(noActual);
        
    }  
}
