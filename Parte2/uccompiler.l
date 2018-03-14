%X COMMENT LINECOMMENT CHRREAD
%{
	#include "y.tab.h"
	void saveYPos();
    int line=1;
	int col=1;
	int e_line=0;
	int e_col=0;
	int printToken = 0;
	int printTree = 0;
	extern int yLine, yCol;
	int i;
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

"//"					{saveYPos();col+=yyleng;BEGIN LINECOMMENT;}
<LINECOMMENT>"\n"		{saveYPos();line++;col=1;BEGIN 0;}
<LINECOMMENT>"\r"		{saveYPos();line++;col=1;BEGIN 0;}
<LINECOMMENT>"\r\n"		{saveYPos();line++;col=1;BEGIN 0;}
<LINECOMMENT>.			{saveYPos();col+=yyleng;/* Ignorar comentários em linha */}

"/*"					{saveYPos();e_line=line;e_col=col;col+=yyleng;BEGIN COMMENT;}
<COMMENT>"*/"			{saveYPos();col+=yyleng;BEGIN 0;}
<COMMENT>"\n"			{saveYPos();line++;col=1;}
<COMMENT>"\r"			{saveYPos();line++;col=1;}
<COMMENT>"\r\n"			{saveYPos();line++;col=1;}
<COMMENT><<EOF>>		{saveYPos();printf("Line %d, col %d: unterminated comment\n", e_line, e_col);col+=yyleng;BEGIN 0;}
<COMMENT>.				{saveYPos();col+=yyleng;/* Ignorar comentários */}


'						{saveYPos();e_line=line;e_col=col;col+=yyleng;BEGIN CHRREAD;}
<CHRREAD>{ENDLINE}		{saveYPos();printf("Line %d, col %d: unterminated char constant\n", e_line, e_col);col=1;line++;BEGIN 0;}
<CHRREAD>.				{saveYPos();col+=yyleng;}
''						{saveYPos();printf("Line %d, col %d: invalid char constant (%s)\n", line, col, yytext);col+=yyleng;}
{CHRLIT}				{saveYPos();col+=yyleng; if (printToken) {printf("CHRLIT(%s)\n", yytext);}; yylval.chr = strdup(yytext); return CHRLIT;}
'{INVCHR}{INVCHR}*'		{saveYPos();printf("Line %d, col %d: invalid char constant (%s)\n", line, col, yytext);col+=yyleng;BEGIN 0;}

{REALLIT}				{saveYPos();col+=yyleng; if (printToken) {printf("REALLIT(%s)\n", yytext);}; yylval.d = atoi(yytext); return REALLIT;}

[0-9]+					{saveYPos();col+=yyleng; if (printToken) {printf("INTLIT(%s)\n", yytext);}; yylval.num = atoi(yytext); return INTLIT;}

"["|"]"|"++"|"--"|"auto"|"break"|"case"|"const"|"continue"|"default"|"do"|"enum"|"extern"|"float"|"for"|"goto"|"inline"|"long"|"register"|"restrict"|"signed"|"sizeof"|"static"|"struct"|"switch"|"typedef"|"union"|"unsigned"|"volatile"|"_Bool"|"_Complex"|"_Imaginary"	{col+=yyleng;if (printToken) {saveYPos();printf("RESERVED(%s)\n", yytext);}; yylval.string = strdup(yytext); return RESERVED;}

" "|"\t"|"\f"		{saveYPos();col+=yyleng;}
"\n"|"\r"|"\r\n"	{saveYPos();col=1;line++;}
"char"				{saveYPos();col+=yyleng; if (printToken) {printf("CHAR\n");}; return CHAR;}
"else"				{saveYPos();col+=yyleng; if (printToken) {printf("ELSE\n");}; return ELSE;}
"while"				{saveYPos();col+=yyleng; if (printToken) {printf("WHILE\n");}; return WHILE;}
"if"				{saveYPos();col+=yyleng; if (printToken) {printf("IF\n");}; return IF;}
"int"				{saveYPos();col+=yyleng; if (printToken) {printf("INT\n");}; return INT;}
"short"				{saveYPos();col+=yyleng; if (printToken) {printf("SHORT\n");}; return SHORT;}
"double"			{saveYPos();col+=yyleng; if (printToken) {printf("DOUBLE\n");}; return DOUBLE;}
"return"			{saveYPos();col+=yyleng; if (printToken) {printf("RETURN\n");}; return RETURN;}
"void"				{saveYPos();col+=yyleng; if (printToken) {printf("VOID\n");}; return VOID;}

"&"			{saveYPos();col+=yyleng; if (printToken) {printf("BITWISEAND\n");}; return BITWISEAND;}
"|"			{saveYPos();col+=yyleng; if (printToken) {printf("BITWISEOR\n");}; return BITWISEOR;}
"^"			{saveYPos();col+=yyleng; if (printToken) {printf("BITWISEXOR\n");}; return BITWISEXOR;}
"&&"		{saveYPos();col+=yyleng; if (printToken) {printf("AND\n");}; return AND;}
"="			{saveYPos();col+=yyleng; if (printToken) {printf("ASSIGN\n");}; return ASSIGN;}
"*"			{saveYPos();col+=yyleng; if (printToken) {printf("MUL\n");}; return MUL;}
","			{saveYPos();col+=yyleng; if (printToken) {printf("COMMA\n");}; return COMMA;}
"/"			{saveYPos();col+=yyleng; if (printToken) {printf("DIV\n");}; return DIV;}
"=="		{saveYPos();col+=yyleng; if (printToken) {printf("EQ\n");}; return EQ;}
">="		{saveYPos();col+=yyleng; if (printToken) {printf("GE\n");}; return GE;}
">"			{saveYPos();col+=yyleng; if (printToken) {printf("GT\n");}; return GT;}
"{"			{saveYPos();col+=yyleng; if (printToken) {printf("LBRACE\n");}; return LBRACE;}
"<="		{saveYPos();col+=yyleng; if (printToken) {printf("LE\n");}; return LE;}
"("			{saveYPos();col+=yyleng; if (printToken) {printf("LPAR\n");}; return LPAR;}
"<"			{saveYPos();col+=yyleng; if (printToken) {printf("LT\n");}; return LT;}
"-"			{saveYPos();col+=yyleng; if (printToken) {printf("MINUS\n");}; return MINUS;}
"%"			{saveYPos();col+=yyleng; if (printToken) {printf("MOD\n");}; return MOD;}
"!="		{saveYPos();col+=yyleng; if (printToken) {printf("NE\n");}; return NE;}
"!"			{saveYPos();col+=yyleng; if (printToken) {printf("NOT\n");}; return NOT;}
"||"		{saveYPos();col+=yyleng; if (printToken) {printf("OR\n");}; return OR;}
"+"			{saveYPos();col+=yyleng; if (printToken) {printf("PLUS\n");}; return PLUS;}
"}"			{saveYPos();col+=yyleng; if (printToken) {printf("RBRACE\n");}; return RBRACE;}
")"			{saveYPos();col+=yyleng; if (printToken) {printf("RPAR\n");}; return RPAR;}
";"			{saveYPos();col+=yyleng; if (printToken) {printf("SEMI\n");}; return SEMI;}

[a-zA-Z_][a-zA-Z0-9_]*	{saveYPos();col+=yyleng; if (printToken) {printf("ID(%s)\n", yytext);}; yylval.string = strdup(yytext); return ID;}

.			{printf("Line %d, col %d: illegal character (%s)\n", line, col, yytext);saveYPos();col+=yyleng;}

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
				printTree = 1;
			}
		}
	}

	yyparse();
	return 0;
}

void saveYPos()
{
	yLine = line;
	yCol = col;
}

void yyerror(const char *s)
{
	printf("Line %d, col %d: %s: %s\n", yLine, yCol, s, yytext);
}

int yywrap()
{
return 1;
}

