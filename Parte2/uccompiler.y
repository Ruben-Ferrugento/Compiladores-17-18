%{
    #include <stdlib.h>
    #include <stdio.h>
    #include <string.h>
    #include "y.tab.h"

    void yyerror (const char *s);
    int yylex(void);

    /*importa as variaveis do lex*/
    extern int lineNum;
    extern int columnNum;
    extern char *yytext; 
    extern int yyleng;
    
%}

%union{
        char* string;   
	char chr;
	int num;
	double d;
}

%token LPAR RPAR LBRACE RBRACE
%token OR AND EQ NE LT GT LE GE ADD SUB MUL DIV MOD NOT MINUS PLUS STORE COMMA BITWISEAND BITWISEXOR BITWISEOR ASSIGN
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

FunctionsAndDeclarations: FunctionDefinition FunctionsAndDeclarations2	
		| FunctionDeclaration FunctionsAndDeclarations2	
		| Declaration FunctionsAndDeclarations2	
		| FunctionDefinition 
		| FunctionDeclaration 
		| Declaration 
        ;

FunctionsAndDeclarations2: FunctionDefinition FunctionsAndDeclarations2 
		| FunctionDeclaration FunctionsAndDeclarations2 
		| Declaration FunctionsAndDeclarations2	
		;

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

ECommaE: Expr COMMA Expr 
	;

Expr: Expr ASSIGN Expr	
	| ECommaE	
	| Expr PLUS Expr	
	| Expr MINUS Expr	
	| Expr MUL Expr		
	| Expr DIV Expr		
	| Expr MOD Expr 	
	| Expr OR Expr		
	| Expr AND Expr		
	| Expr BITWISEAND Expr	
	| Expr BITWISEOR Expr	
	| Expr BITWISEXOR Expr	
	| Expr EQ Expr		
	| Expr NE Expr		
	| Expr LE Expr		
	| Expr GE Expr		
	| Expr LT Expr		
	| Expr GT Expr		
	| PLUS Expr		
	| MINUS Expr	
	| NOT Expr		
	| ID LPAR RPAR 
	| ID LPAR ECommaE RPAR 
	| ID 
	| INTLIT 
	| CHRLIT 
	| REALLIT 
	| LPAR Expr RPAR 
	;

//--------------------------//

%%

void yyerror (const char *s) {      
        printf ("Line %d, col %d: %s: %s\n", lineNum, columnNum-(int)yyleng, s, yytext); 
}

