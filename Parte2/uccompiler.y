%{
    #include <stdlib.h>
    #include <stdio.h>
    #include <string.h>
    #include "y.tab.h"

    void yyerror (const char *s);
    int yylex(void);

    /*importa as variaveis do lex*/
    extern int yLine;
    extern int yCol;
    extern char *yytext; 
    extern int yyleng;
    
%}

%union{
<<<<<<< HEAD
		
    char* string;   
	char* chr;
	int num;
	double d;  
=======
        char* string;   
	char chr;
	int num;
	double d;
>>>>>>> 68efac52edd0d14d75fc51b46893efe261ebf53b
}

%token LPAR RPAR LBRACE RBRACE
%token OR AND EQ NE LT GT LE GE ADD SUB MUL DIV MOD NOT MINUS PLUS STORE COMMA BITWISEAND BITWISEXOR BITWISEOR ASSIGN SEMI
%token CHAR ELSE WHILE IF INT SHORT DOUBLE RETURN VOID

%token <string> RESERVED
%token <string> ID
%token <string> INTLIT
%token <string> REALLIT
%token <string> CHRLIT


%left COMMA
%left OR
%left AND
%left EQ NEQ 
%left LT LEQ GT GEQ 
%left PLUS MINUS
%left MUL DIV MOD
%right NOT 
%left LPAR RPAR

%nonassoc IFX
%nonassoc ELSE

%%

//FunctionsAndDeclarations: FunctionDefinition FunctionsAndDeclarations
//		| FunctionDeclaration FunctionsAndDeclarations
//		| Declaration FunctionsAndDeclarations
//		| FunctionDefinition 
//		| FunctionDeclaration 
//		| Declaration 
//        ;
FunctionsAndDeclarations: Expr
		;

/*
FunctionDefinition: TypeSpec FunctionDeclarator FunctionBody	
		;

FunctionBody: LBRACE RBRACE	
		| LBRACE DeclarationsAndStatements RBRACE
		;

DeclarationsAndStatements: Statement DeclarationsAndStatements 
		| Declaration DeclarationsAndStatements 
		| Statement	
		| Declaration	
		;

FunctionDeclaration: TypeSpec FunctionDeclarator SEMI	
		;
		
FunctionDeclarator: ID LPAR ParameterList RPAR	
		;

ParameterList: ParameterDeclaration COMMA ParameterDeclaration ParameterDeclaration	
		;

ParameterDeclaration: TypeSpec ID	
		| TypeSpec 
		;

Declaration: TypeSpec Declarator COMMA Declarator SEMI	
		;

TypeSpec: CHAR	
		| INT	
		| VOID	
		| SHORT	
		| DOUBLE
		;

Declarator: ID ASSIGN Expr
		| ID 
		;

Statement: Expr SEMI
		| SEMI 
		| LBRACE Statement RBRACE 
		| IF LPAR Expr RPAR Statement 
		| IF LPAR Expr RPAR Statement ELSE Statement 
		| WHILE LPAR Expr RPAR Statement 
		| RETURN Expr SEMI 
		| RETURN SEMI 
		;
*/
CommaE: Expr COMMA Expr 
	;

Terminal: ASSIGN
	| MUL
	| DIV
	| MOD
	| OR
	| AND
	| BITWISEAND
	| BITWISEOR
	| BITWISEXOR
	| EQ
	| NE
	| LE
	| GE
	| LT
	| GT
	;

Expr1: Terminal Expr
	| Expr2
	| CommaE
	;

Expr2: PLUS Expr %prec NOT
	| MINUS Expr %prec NOT 
	;

Expr3: LPAR RPAR 
	| LPAR Expr CommaE RPAR
	;

Expr4: Expr RPAR
	;

Expr: Expr Expr1	
	| PLUS Expr %prec NOT
	| MINUS Expr %prec NOT
	| NOT Expr
	| ID
	| ID Expr3	 
	| INTLIT 
	| CHRLIT 
	| REALLIT 
	| LPAR Expr4
	| LPAR Expr3
	;

//--------------------------//

%%

void yyerror (const char *s) {      
        printf ("Line %d, col %d: %s: %s\n", yLine, yCol-(int)yyleng, s, yytext); 
}

