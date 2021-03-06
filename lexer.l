%{
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include "parser.tab.h"	/* header file generated by bison */

extern int yylineno;
extern char id[100];

%}

letter		[a-zA-Z]
digit		[0-9]
num			[0-9]+
floatnum	[+-]?{num}\.{num}
id			{letter}+({letter}|{digit})*
sem			[;]
space		[ ]


%%

"//".+\n						{ yylineno++;}
"/*"(.+\n?)*"*/"				{ 	
									char* t = strtok(yytext,"\n");
									while( t != NULL ) {
						  				yylineno++;
						  				t = strtok(NULL, "\n");
									}
									yylineno --;
								}

"("								{ return LB;}
")"								{ return RB;}
"+" 							{ return ADD;}
"-" 							{ return SUB;}
"*" 							{ return MUL;}
"/" 							{ return DIV;}
"=" 							{ return ASSIGN;}
{sem}							{ return SEM;}
([Pp][Rr][Ii][Nn][Tt])			{ return PRINT;}
([Ww][Hh][Ii][Ll][Ee])			{ return WHILE;}
([Ii][Nn][Tt])					{ return INT;}
([Dd][Oo][Uu][Bb][Ll][Ee])		{ return DOUBLE;}
[\n]							{ yylineno++;}
"\"".+"\""						{strcpy(yylval.str,yytext);return STRING;}
{num}							{yylval.floatval = atof(yytext);return NUMBER;}
{floatnum} 						{yylval.floatval = atof(yytext);return FLOATNUM;}
{id}							{ strcpy(yylval.token,yytext);return ID;}
[ \t]							{;} /* Ignore */
[^ \n\t] 						{;} /* Ignore other charactor sets */
%%

int yywrap()
{
    return 1;
}


