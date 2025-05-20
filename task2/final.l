%{
#include "ast.h"
#include "final.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern FILE *yyin;
%}

%%

"begin"        { return T_BEGIN; }
"end"          { return T_END; }
"program"      { return T_PROGRAM; }
"var"          { return T_VARDEC; }

"if"           { return T_IF; }
"else"         { return T_ELSE; }
"then"         { return T_THEN; }
"endif"        { return T_ENDIF; }

"while"        { return T_WHILE; }
"endwhile"     { return T_ENDWHILE; }

"for"          { return T_FOR; }
"to"           { return T_TO; }
"do"           { return T_DO; }

"print"        { return T_PRINT; }
"scan"         { return T_SCAN; }


"int"|"float"|"char" {
    yylval.sval = strdup(yytext);
    return T_TYPE;
}


":"            { return T_COLON; }
";"            { return T_SM; }
","            { return T_COMMA; }
"["            { return OSB; }
"]"            { return CSB; }
"("            { return T_LPAREN; }
")"            { return T_RPAREN; }


":="           { yylval.sval = strdup(yytext); return T_ASSIGN_OP; }
"=="|"!="|"<="|">=" {
    yylval.sval = strdup(yytext);
    return T_REL_OP;
}
"<"|">"      {
    yylval.sval = strdup(yytext);
    return T_REL_OP;
}
"+"|"-"|"*"|"/"|"%" {
    yylval.sval = strdup(yytext);
    return T_ARITH_OP;
}


[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.sval = strdup(yytext);
    return T_IDENTIFIER;
}
[0-9]+ {
    yylval.ival = atoi(yytext);
    return T_INTEGER;
}


[\t\r\n]+ ;


. {
    fprintf(stderr, "Unexpected char: %s", yytext);
}

%%

int yywrap(void) { return 1; }
