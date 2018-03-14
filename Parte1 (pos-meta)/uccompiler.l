%X COMMENT LINECOMMENT CHRREAD
%{
	//#include "y.tab.h"
    int line=1;
	int col=1;
	int e_line=0;
	int e_col=0;
	int printToken = 0;
	int i;
%}

NUMPART		[0-9]+
OCT			[0-7][0-7]?[0-7]?
CHAR		[^\n\r'\\]
CHAR2		[^\n\r']
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


'								{e_line=line;e_col=col;col+=yyleng;BEGIN CHRREAD;}
<CHRREAD>{ENDLINE}				{printf("Line %d, col %d: unterminated char constant\n", e_line, e_col);col=1;line++;BEGIN 0;}
<CHRREAD>.						{col+=yyleng;}
''								{printf("Line %d, col %d: invalid char constant (%s)\n", line, col, yytext);col+=yyleng;}
{CHRLIT}						{col+=yyleng; if (printToken) {printf("CHRLIT(%s)\n", yytext);}}
'{INVCHR}{INVCHR}*'				{printf("Line %d, col %d: invalid char constant (%s)\n", line, col, yytext);col+=yyleng;BEGIN 0;}

{REALLIT}				{col+=yyleng; if (printToken) {printf("REALLIT(%s)\n", yytext);}}

[0-9]+					{col+=yyleng; if (printToken) {printf("INTLIT(%s)\n", yytext);}}

"["|"]"|"++"|"--"|"auto"|"break"|"case"|"const"|"continue"|"default"|"do"|"enum"|"extern"|"float"|"for"|"goto"|"inline"|"long"|"register"|"restrict"|"signed"|"sizeof"|"static"|"struct"|"switch"|"typedef"|"union"|"unsigned"|"volatile"|"_Bool"|"_Complex"|"_Imaginary"	{col+=yyleng;if (printToken) {printf("RESERVED(%s)\n", yytext);};}

" "|"\t"|"\f"			{col+=yyleng;}
"\n"|"\r"|"\r\n"		{col=1;line++;}
"char"					{col+=yyleng; if (printToken) {printf("CHAR\n");}}
"else"					{col+=yyleng; if (printToken) {printf("ELSE\n");}}
"while"					{col+=yyleng; if (printToken) {printf("WHILE\n");}}
"if"					{col+=yyleng; if (printToken) {printf("IF\n");}}
"int"					{col+=yyleng; if (printToken) {printf("INT\n");}}
"short"					{col+=yyleng; if (printToken) {printf("SHORT\n");}}
"double"				{col+=yyleng; if (printToken) {printf("DOUBLE\n");}}
"return"				{col+=yyleng; if (printToken) {printf("RETURN\n");}}
"void"					{col+=yyleng; if (printToken) {printf("VOID\n");}}

"&"			{col+=yyleng; if (printToken) {printf("BITWISEAND\n");}}
"|"			{col+=yyleng; if (printToken) {printf("BITWISEOR\n");}}
"^"			{col+=yyleng; if (printToken) {printf("BITWISEXOR\n");}}
"&&"		{col+=yyleng; if (printToken) {printf("AND\n");}}
"="			{col+=yyleng; if (printToken) {printf("ASSIGN\n");}}
"*"			{col+=yyleng; if (printToken) {printf("MUL\n");}}
","			{col+=yyleng; if (printToken) {printf("COMMA\n");}}
"/"			{col+=yyleng; if (printToken) {printf("DIV\n");}}
"=="		{col+=yyleng; if (printToken) {printf("EQ\n");}}
">="		{col+=yyleng; if (printToken) {printf("GE\n");}}
">"			{col+=yyleng; if (printToken) {printf("GT\n");}}
"{"			{col+=yyleng; if (printToken) {printf("LBRACE\n");}}
"<="		{col+=yyleng; if (printToken) {printf("LE\n");}}
"("			{col+=yyleng; if (printToken) {printf("LPAR\n");}}
"<"			{col+=yyleng; if (printToken) {printf("LT\n");}}
"-"			{col+=yyleng; if (printToken) {printf("MINUS\n");}}
"%"			{col+=yyleng; if (printToken) {printf("MOD\n");}}
"!="		{col+=yyleng; if (printToken) {printf("NE\n");}}
"!"			{col+=yyleng; if (printToken) {printf("NOT\n");}}
"||"		{col+=yyleng; if (printToken) {printf("OR\n");}}
"+"			{col+=yyleng; if (printToken) {printf("PLUS\n");}}
"}"			{col+=yyleng; if (printToken) {printf("RBRACE\n");}}
")"			{col+=yyleng; if (printToken) {printf("RPAR\n");}}
";"			{col+=yyleng; if (printToken) {printf("SEMI\n");}}

[a-zA-Z_][a-zA-Z0-9_]*	{col+=yyleng; if (printToken) {printf("ID(%s)\n", yytext);}}

.			{printf("Line %d, col %d: illegal character (%s)\n", line, col, yytext);col+=yyleng;}

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
		}
	}

	yylex();
	return 0;
}

void yyerror(const char *s)
{
	printf("Line %d, col %d: %s: %s\n", line, col, s, yytext);
}

int yywrap()
{
return 1;
}

