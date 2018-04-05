%X COMMENT LINECOMMENT CHRREAD
%{
	#include "y.tab.h"
	//void saveYPos();
   	#include "estruturas.h"
    #include "ast.h"

    int line=1;
	int col=1;
	int e_line=0;
	int e_col=0;
	int printToken = 0;
	int printTree = 0;
	int yLine, yCol;
	int i;

    ARVORE raiz = NULL;

    /*Flag para verificar se há erro sintatico*/
    int error = 0;
%}

NUMPART		[0-9]+
OCT			[0-7][0-7]?[0-7]?
CHAR		[^\n\r'\\]
ESCAPE		\\(n|t|\\|\'|\"|{OCT})
INVESC		\\(.)
CHRLIT		'({CHAR}|{ESCAPE})'
INVCHR		({CHAR}|{INVESC})
ENDLINE		"\n"|"\r"|"\r\n"|<EOF>
EXP			[Ee][+-]?{NUMPART}
REALLIT		({NUMPART}"."({NUMPART})?({EXP})?)|("."({NUMPART})({EXP})?)|({NUMPART}({EXP}))

%%

"//"					{col+=yyleng;BEGIN LINECOMMENT;}
<LINECOMMENT>"\n"		{line++;col=1;BEGIN 0;}
<LINECOMMENT>"\r"		{line++;col=1;BEGIN 0;}
<LINECOMMENT>"\r\n"		{line++;col=1;BEGIN 0;}
<LINECOMMENT>.			{col+=yyleng;/* Ignorar comentários em linha */}

"/*"					{e_line=line;e_col=col;col+=yyleng;BEGIN COMMENT;}
<COMMENT>"*/"			{col+=yyleng;BEGIN 0;}
<COMMENT>"\n"			{line++;col=1;}
<COMMENT>"\r"			{line++;col=1;}
<COMMENT>"\r\n"			{line++;col=1;}
<COMMENT><<EOF>>		{printf("Line %d, col %d: unterminated comment\n", e_line, e_col);col+=yyleng;BEGIN 0;}
<COMMENT>.				{col+=yyleng;/* Ignorar comentários */}


'						{e_line=line;e_col=col;col+=yyleng;BEGIN CHRREAD;}
<CHRREAD>{ENDLINE}		{printf("Line %d, col %d: unterminated char constant\n", e_line, e_col);col=1;line++;BEGIN 0;}
<CHRREAD>.				{col+=yyleng;}
''						{printf("Line %d, col %d: invalid char constant (%s)\n", line, col, yytext);col+=yyleng;}
{CHRLIT}				{col+=yyleng; if (printToken) {printf("CHRLIT(%s)\n", yytext);}; yylval.string=(char*)strdup(yytext); return CHRLIT;}
'{INVCHR}{INVCHR}*'		{printf("Line %d, col %d: invalid char constant (%s)\n", line, col, yytext);col+=yyleng;BEGIN 0;}

{REALLIT}				{col+=yyleng; if (printToken) {printf("REALLIT(%s)\n", yytext);}; yylval.string=(char*)strdup(yytext); return REALLIT;}

[0-9]+					{col+=yyleng; if (printToken) {printf("INTLIT(%s)\n", yytext);}; yylval.string=(char*)strdup(yytext); return INTLIT;}

"["|"]"|"++"|"--"|"auto"|"break"|"case"|"const"|"continue"|"default"|"do"|"enum"|"extern"|"float"|"for"|"goto"|"inline"|"long"|"register"|"restrict"|"signed"|"sizeof"|"static"|"struct"|"switch"|"typedef"|"union"|"unsigned"|"volatile"|"_Bool"|"_Complex"|"_Imaginary"	{col+=yyleng;if (printToken) {printf("RESERVED(%s)\n", yytext);}; yylval.string=(char*)strdup(yytext); return RESERVED;}

" "|"\t"|"\f"		{col+=yyleng;}
"\n"|"\r"|"\r\n"	{col=1;line++;}
"char"				{col+=yyleng; if (printToken) {printf("CHAR\n");}; return CHAR;}
"else"				{col+=yyleng; if (printToken) {printf("ELSE\n");}; return ELSE;}
"while"				{col+=yyleng; if (printToken) {printf("WHILE\n");}; return WHILE;}
"if"				{col+=yyleng; if (printToken) {printf("IF\n");}; return IF;}
"int"				{col+=yyleng; if (printToken) {printf("INT\n");}; return INT;}
"short"				{col+=yyleng; if (printToken) {printf("SHORT\n");}; return SHORT;}
"double"			{col+=yyleng; if (printToken) {printf("DOUBLE\n");}; return DOUBLE;}
"return"			{col+=yyleng; if (printToken) {printf("RETURN\n");}; return RETURN;}
"void"				{col+=yyleng; if (printToken) {printf("VOID\n");}; return VOID;}

"&"			{col+=yyleng; if (printToken) {printf("BITWISEAND\n");}; return BITWISEAND;}
"|"			{col+=yyleng; if (printToken) {printf("BITWISEOR\n");}; return BITWISEOR;}
"^"			{col+=yyleng; if (printToken) {printf("BITWISEXOR\n");}; return BITWISEXOR;}
"&&"		{col+=yyleng; if (printToken) {printf("AND\n");}; return AND;}
"="			{col+=yyleng; if (printToken) {printf("ASSIGN\n");}; return ASSIGN;}
"*"			{col+=yyleng; if (printToken) {printf("MUL\n");}; return MUL;}
","			{col+=yyleng; if (printToken) {printf("COMMA\n");}; return COMMA;}
"/"			{col+=yyleng; if (printToken) {printf("DIV\n");}; return DIV;}
"=="		{col+=yyleng; if (printToken) {printf("EQ\n");}; return EQ;}
">="		{col+=yyleng; if (printToken) {printf("GE\n");}; return GE;}
">"			{col+=yyleng; if (printToken) {printf("GT\n");}; return GT;}
"{"			{col+=yyleng; if (printToken) {printf("LBRACE\n");}; return LBRACE;}
"<="		{col+=yyleng; if (printToken) {printf("LE\n");}; return LE;}
"("			{col+=yyleng; if (printToken) {printf("LPAR\n");}; return LPAR;}
"<"			{col+=yyleng; if (printToken) {printf("LT\n");}; return LT;}
"-"			{col+=yyleng; if (printToken) {printf("MINUS\n");}; return MINUS;}
"%"			{col+=yyleng; if (printToken) {printf("MOD\n");}; return MOD;}
"!="		{col+=yyleng; if (printToken) {printf("NE\n");}; return NE;}
"!"			{col+=yyleng; if (printToken) {printf("NOT\n");}; return NOT;}
"||"		{col+=yyleng; if (printToken) {printf("OR\n");}; return OR;}
"+"			{col+=yyleng; if (printToken) {printf("PLUS\n");}; return PLUS;}
"}"			{col+=yyleng; if (printToken) {printf("RBRACE\n");}; return RBRACE;}
")"			{col+=yyleng; if (printToken) {printf("RPAR\n");}; return RPAR;}
";"			{col+=yyleng; if (printToken) {printf("SEMI\n");}; return SEMI;}

[a-zA-Z_][a-zA-Z0-9_]*	{col+=yyleng; if (printToken) {printf("ID(%s)\n", yytext);}; yylval.string=(char*)strdup(yytext); return ID;}

.			{printf("Line %d, col %d: illegal character (%s)\n", line, col, yytext);col+=yyleng;}

<<EOF>> {col+=yyleng; return 0;}

%%
int main(int argc, char *argv[])
{
	if (argc > 1)
	{
		for (i = 0; i < argc; i++)
		{
			if (strcmp(argv[i],"-l") == 0)
			{
				printToken = 1;
			}
			if (strcmp(argv[i],"-t") == 0)
			{
				//printTree = 1;
				yyparse();
				imprimirAST(raiz, error, 0, 0);
			}
		}
	}else{
        yyparse();
        /*não tem erros mas não deve imprimir*/
        imprimirAST(raiz, error, 0, 1);
    }

	//yyparse();
	//imprimirAST(raiz, error, 0, 1);
	return 0;
}

int yywrap()
{
return 1;
}
