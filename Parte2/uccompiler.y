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
=======

>>>>>>> 92a8b1e733ef1fe414dda851cb8802b2fda79ef7
		
    	char* string;   
	char* chr;
	int num;
	double d;  
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
%right ASSIGN
%left OR
%left AND
%left EQ NE
%left GE GT LE LT 
%left PLUS MINUS
%left MUL DIV MOD
%left BITWISEAND BITWISEOR BITWISEXOR
%right NOT 
%left LPAR RPAR

%nonassoc IFX
%nonassoc ELSE

%%

FunctionsAndDeclarations: FunctionsAndDeclarations FunctionDefinition 
		| FunctionsAndDeclarations FunctionDeclaration
		| FunctionsAndDeclarations Declaration
		| FunctionDefinition 
		| FunctionDeclaration 
		| Declaration
		;

FunctionDefinition: TypeSpec FunctionDeclarator FunctionBody
		;

FunctionBody: LBRACE DeclarationsAndStatements RBRACE
		| LBRACE RBRACE
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

ParameterList: ParameterDeclaration 
		| ParameterList COMMA ParameterDeclaration
		;

ParameterDeclaration: TypeSpec ID
		| TypeSpec
		;

DeclList: Declarator
		| DeclList COMMA Declarator
		;

//20 shift reduce problems - Declaration -> error SEMI
Declaration: TypeSpec DeclList SEMI
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

StmList: StmList Statement
		| error SEMI
		;

//20 shift reduce problems - Statement -> error SEMI
Statement: Expr SEMI
		| SEMI
		| LBRACE StmList RBRACE
		| IF LPAR Expr RPAR Statement ELSE Statement
		| IF LPAR Expr RPAR Statement %prec IFX
		| WHILE LPAR Expr RPAR Statement
		| RETURN Expr SEMI
		| RETURN SEMI
		| error SEMI
		;

Expr: Expr ASSIGN Expr
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
	| PLUS Expr %prec NOT		
	| MINUS Expr %prec NOT	
	| NOT Expr		
	| ID LPAR RPAR
	| ID LPAR ExprList RPAR 
	| ID 
	| INTLIT 
	| CHRLIT 
	| REALLIT 
	| LPAR Expr RPAR
	| ID LPAR error RPAR
	| LPAR error RPAR
	;

ExprList: Expr
	| ExprList COMMA Expr
	;

%%

void yyerror (const char *s) {      
        printf ("Line %d, col %d: %s: %s\n", yLine, yCol-(int)yyleng, s, yytext); 
}

