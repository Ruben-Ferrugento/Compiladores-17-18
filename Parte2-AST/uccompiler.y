%{
    #include <stdlib.h>
    #include <stdio.h>
    #include <string.h>
    #include "y.tab.h"
    #include "estruturas.h"
    #include "ast.h"

    void yyerror (const char *s);
    int yylex(void);

    /*importa as variaveis do lex*/
    extern int line;
    extern int col;
    extern char *yytext; 
    extern int yyleng;

	extern ARVORE raiz;

	/*importa flag de error*/
    extern int error;

	char* type;
	int call = 0;
	int non_cond = 0;

    ARVORE copia;
    
%}

%union{
		
    char* string;   
	struct arvore *arv; /*definimos uma estrutura do tipo arvore*/ 
}

%type <arv> FunctionsAndDeclarations FunctionDefinition FunctionDeclarator FunctionBody DeclarationsAndStatements FunctionDeclaration ParameterList ParameterDeclaration DeclaratorList Declaration TypeSpec Declarator StmList Statement Statement1 Expr ExprList ExprList2

%token LPAR RPAR LBRACE RBRACE
%token OR AND EQ NE LT GT LE GE ADD SUB MUL DIV MOD NOT MINUS PLUS STORE COMMA BITWISEAND BITWISEXOR BITWISEOR ASSIGN SEMI
%token CHAR ELSE WHILE IF INT SHORT DOUBLE RETURN VOID

%token <string> RESERVED
%token <string> ID
%token <string> INTLIT
%token <string> REALLIT
%token <string> CHRLIT

%left COMMA
%right ASSIGN
%left OR
%left AND
%left BITWISEOR
%left BITWISEXOR
%left BITWISEAND
%left EQ NE
%left GE GT LE LT 
%left PLUS MINUS
%left MUL DIV MOD
%right NOT 
%left LPAR RPAR

%nonassoc IFX
%nonassoc ELSE

%%

FunctionsAndDeclarations: FunctionsAndDeclarations FunctionDefinition {$$ = criarIrmao($1, $2);}
		| FunctionsAndDeclarations FunctionDeclaration	{$$ = criarIrmao($1, $2);}
		| FunctionsAndDeclarations Declaration {$$ = criarIrmao($1, $2);}
		| FunctionDefinition {raiz = criarNo("Program", NULL); raiz->filho = $1;}
		| FunctionDeclaration {raiz = criarNo("Program", NULL); raiz->filho = $1;}
		| Declaration {raiz = criarNo("Program", NULL); raiz->filho = $1;}
		;

FunctionDefinition: TypeSpec FunctionDeclarator FunctionBody {$$ = criarNo("FuncDefinition", NULL); $$->filho = criarIrmao(criarIrmao($1, $2), $3);}
		;

//FunctionBody: LBRACE RBRACE is ambiguous to Statement: LBRACE RBRACE?
//LBRACE Statement RBRACE -> LBRACE LBRACE RBRACE RBRACE
FunctionBody: LBRACE DeclarationsAndStatements RBRACE	{$$ = criarNo("FuncBody", NULL); $$->filho = $2;}
		| LBRACE RBRACE	{$$ = criarNo("FuncBody", NULL);}
		;

//Statement DAS ou Statement = StmList{1,...}
DeclarationsAndStatements: DeclarationsAndStatements Declaration	{$$ = $1; $$ = criarIrmao($1, $2);}
		| DeclarationsAndStatements Statement1	{$$ = $1; $$ = criarIrmao($1, $2);}
		| Declaration	{$$ = $1;}
		| Statement1	{$$ = $1;}
		;

FunctionDeclaration: TypeSpec FunctionDeclarator SEMI	{$$ = criarNo("FuncDeclaration", NULL); $$->filho = criarIrmao($1, $2);}
		;

FunctionDeclarator: ID LPAR ParameterList RPAR	{$$ = criarIrmao(criarNo("Id", $1), copia=criarNo("ParamList",NULL)); copia->filho = $3; free($1);}
		;

ParameterList: ParameterDeclaration {$$ = $1;}
		| ParameterList COMMA ParameterDeclaration	{	$$ = criarIrmao($1,$3); }
		;

ParameterDeclaration: TypeSpec ID	{$$ = criarNo("ParamDeclaration", NULL); $$->filho = criarIrmao($1, criarNo("Id", $2)); free($2);}
		| TypeSpec	{$$ = criarNo("ParamDeclaration", NULL); $$->filho = $1;}
		;

//DeclaratorList precisa da cópia do TypeSpec
DeclaratorList: Declarator	{$$ = criarNo("Declaration", NULL); $$->filho = criarIrmao(criarNo(type,NULL),$1);}
		| DeclaratorList COMMA Declarator	{$$ = criarIrmao($1, copia=criarNo("Declaration", NULL)); copia->filho = criarIrmao(criarNo(type,NULL),$3);}
		;

//20 shift reduce problems - Declaration -> error SEMI
//criar nó copia, criar cópia do TypeSpec e enviá-la ao filho
Declaration: TypeSpec DeclaratorList SEMI	{$$ = $2;}
		| error SEMI	{$$ = criarNo("Error", NULL); error = 1;}
		;

TypeSpec: CHAR	{$$ = criarNo("Char", NULL); type="Char";}
		| INT	{$$ = criarNo("Int", NULL); type="Int";}
		| VOID	{$$ = criarNo("Void", NULL); type="Void";}
		| SHORT	{$$ = criarNo("Short", NULL); type="Short";}
		| DOUBLE	{$$ = criarNo("Double", NULL); type="Double";}
		;

Declarator: ID ASSIGN ExprList	{$$ = criarIrmao(criarNo("Id", $1),$3); free($1);}
		| ID {$$ = criarNo("Id", $1); free($1);}
		;

StmList: StmList Statement	{$$ = $1; $$ = criarIrmao($1, $2);}
		| Statement	{$$ = $1;}
		;

Statement: Statement1	{$$ = $1;}
	    | error SEMI	{$$ = criarNo("Error", NULL); error = 1;}
		; 

//20 shift reduce problems - Statement -> error SEMI
//StmList tem que ter só 2 nós
Statement1: ExprList SEMI	{$$ = $1;}
		| SEMI	{$$ = NULL;}
		| LBRACE StmList RBRACE	{if($2 != NULL){
									if($2->irmao != NULL){
                                            $$ = criarNo("StatList", NULL);
                                            $$->filho = $2;
                                    }else{
                                            $$ = $2;
                                    }
								}else{
                                    $$ = $2;
                                }}
		| LBRACE RBRACE	{$$ = NULL;}
		| IF LPAR ExprList RPAR Statement ELSE Statement	{	$$ = criarNo("If", NULL); 
								                                if($5 != NULL){
								                                        if($5->irmao != NULL){
								                                                $$->filho = criarIrmao($3, copia = criarNo("StatList", NULL));
								                                                copia->filho = criarIrmao($5, criarNo("StatList", NULL));
								                                        }else{
								                                                $$->filho = criarIrmao($3, $5);
								                                        }
								                                }else{
								                                        $$->filho = criarIrmao($3,  criarNo("Null", NULL));
								                                }
								                                
								                                if($7 != NULL){
								                                        if($7->irmao != NULL){
								                                                $$->filho = criarIrmao($$->filho, copia = criarNo("StatList", NULL));
								                                                copia->filho = $7;
								                                        }else{
								                                                $$->filho = criarIrmao($$->filho, $7);
								                                        }
								                                }else{
								                                       $$->filho = criarIrmao($$->filho, criarNo("Null", NULL));
								                                }}
		| IF LPAR ExprList RPAR Statement %prec IFX	{	$$ = criarNo("If", NULL); 
                                                                        if($5 != NULL){
                                                                                if($5->irmao != NULL){
                                                                                        $$->filho = criarIrmao($3, copia = criarNo("Null", NULL));
                                                                                        copia->filho = criarIrmao($5, criarNo("Null", NULL));
                                                                                }else{
                                                                                        $$->filho = criarIrmao(criarIrmao($3, $5), criarNo("Null", NULL));
                                                                                }
                                                                        }else{
                                                                                $$->filho = criarIrmao($3, criarIrmao(criarNo("Null", NULL), criarNo("Null", NULL)));
                                                                        }
													}
		| WHILE LPAR ExprList RPAR Statement	{ 	$$ = criarNo("While", NULL); 
                                                    if($5 != NULL){
                                                            if($5->irmao != NULL){
                                                                    $$->filho = criarIrmao($3, copia = criarNo("StatList", NULL));
                                                                    copia->filho = $5;
                                                            }else{
                                                                    $$->filho = criarIrmao($3, $5);
                                                            }
                                                    }else{                                                                                                                          
                                                            $$->filho = criarIrmao($3, criarNo("Null", NULL));
                                                    }	
												}
		| RETURN ExprList SEMI	{$$ = criarNo("Return", NULL); $$->filho = $2;}
		| RETURN SEMI	{$$ = criarNo("Return", NULL);}
		| LBRACE error RBRACE	{$$ = criarNo("Error", NULL); error = 1;}
		;

Expr: Expr ASSIGN Expr	{$$ = criarNo("Store", NULL); $$->filho = criarIrmao($1, $3);}
	| Expr PLUS Expr	{$$ = criarNo("Add", NULL); $$->filho = criarIrmao($1, $3);}
	| Expr MINUS Expr	{$$ = criarNo("Sub", NULL); $$->filho = criarIrmao($1, $3);}
	| Expr MUL Expr		{$$ = criarNo("Mul", NULL); $$->filho = criarIrmao($1, $3);}
	| Expr DIV Expr		{$$ = criarNo("Div", NULL); $$->filho = criarIrmao($1, $3);}
	| Expr MOD Expr 	{$$ = criarNo("Mod", NULL); $$->filho = criarIrmao($1, $3);}
	| Expr OR Expr		{$$ = criarNo("Or", NULL); $$->filho = criarIrmao($1, $3);}
	| Expr AND Expr		{$$ = criarNo("And", NULL); $$->filho = criarIrmao($1, $3);}
	| Expr BITWISEAND Expr	{$$ = criarNo("BitWiseAnd", NULL); $$->filho = criarIrmao($1, $3);}	
	| Expr BITWISEOR Expr	{$$ = criarNo("BitWiseOr", NULL); $$->filho = criarIrmao($1, $3);}
	| Expr BITWISEXOR Expr	{$$ = criarNo("BitWiseXor", NULL); $$->filho = criarIrmao($1, $3);}
	| Expr EQ Expr		{$$ = criarNo("Eq", NULL); $$->filho = criarIrmao($1, $3);}
	| Expr NE Expr		{$$ = criarNo("Ne", NULL); $$->filho = criarIrmao($1, $3);}
	| Expr LE Expr		{$$ = criarNo("Le", NULL); $$->filho = criarIrmao($1, $3);}
	| Expr GE Expr		{$$ = criarNo("Ge", NULL); $$->filho = criarIrmao($1, $3);}
	| Expr LT Expr		{$$ = criarNo("Lt", NULL); $$->filho = criarIrmao($1, $3);}
	| Expr GT Expr		{$$ = criarNo("Gt", NULL); $$->filho = criarIrmao($1, $3);}
	| PLUS Expr %prec NOT	{$$ = criarNo("Plus", NULL); $$->filho = $2;}		
	| MINUS Expr %prec NOT	{$$ = criarNo("Minus", NULL); $$->filho = $2;}
	| NOT Expr	{$$ = criarNo("Not", NULL); $$->filho = $2;}
	| ID LPAR RPAR	{$$ = criarNo("Call", NULL); $$->filho = criarNo("Id", $1); free($1);}
	| ID LPAR ExprList2 RPAR	{$$ = criarNo("Call", NULL); $$->filho = criarIrmao(criarNo("Id", $1), $3); free($1);} 
	| ID {$$ = criarNo("Id", $1); free($1);}
	| INTLIT	{$$ = criarNo("IntLit", $1); free($1);}
	| CHRLIT	{$$ = criarNo("ChrLit", $1); free($1);} 
	| REALLIT 	{$$ = criarNo("RealLit", $1); free($1);}
	| LPAR ExprList RPAR	{$$ = $2;}
	| ID LPAR error RPAR	{$$ = criarNo("Error", NULL); error = 1;}
	| LPAR error RPAR	{$$ = criarNo("Error", NULL); error = 1;}
	;

ExprList: Expr	{$$ = $1;}
	| ExprList COMMA Expr	{$$ = criarNo("Comma", NULL); $$->filho = criarIrmao($1, $3); call=0;}
	;

ExprList2: Expr {$$ = $1;}
	| ExprList2 COMMA Expr {$$ = criarIrmao($1, $3);}
	;


%%

void yyerror (const char *s) {
        printf ("Line %d, col %d: %s: %s\n", line, col-(int)yyleng, s, yytext);
}

