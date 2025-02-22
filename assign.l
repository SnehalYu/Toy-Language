%{
# include <stdio.h>
#include <string.h>
int at_count;
int arg;
char print_buffer[1024];
int begin_count = 0;
int in_vardecl = 0;

%}
lowalpha [a-z]
upalpha [A-Z]
digit [0-9]
binary [01]+
decimal 0|[1-9][0-9]*
octal 0|[1-7][0-7]*
value \((0|[1-9][0-9]),10\)|\(([01]+),\s*2\) | \((0|[1-9][0-9]),8\)


charconst \'(\\.|[^\\'])\'
string_const \"([^\"\\]|\\.)*\"
keyword (int|char|if|else|while|for|main|begin|end|print|scan|program|VarDecl|inc|dec)
identifier [a-z][a-z0-9]*(_[a-z0-9])?
datatype (int|char)
asignment_operator [:+\-*/%][=]


%%
"print("  { at_count = 0; 
            arg = 0; 
            strcpy(print_buffer, yytext);
            }
{string_const} { 
    printf("Matched string constant: %s\n", yytext);
    int n = strlen(yytext);
    strcat(print_buffer, yytext);  
    for (int i = 0; i < n; i++) {
        if (yytext[i] == '@') at_count++;
    }
}
"," {strcat(print_buffer, yytext); }            
{identifier} { strcat(print_buffer, yytext); 
               arg += 1;}

{charconst} {strcat(print_buffer, yytext); 
                    arg++;}
");" {
    strcat(print_buffer, yytext);
    if (at_count != arg) {
       printf("Invalid print statement: %s\n", print_buffer);
    } else {
       printf("Valid print: %s\n", print_buffer);
    }
    at_count = 0;
    arg = 0;
}

"begin program:" { 
    begin_count++; 
    printf("Keyword begin\n"); 
    printf("Keyword program\n");
    printf("Separator :\n");
}
"end program" { 
    begin_count--; 
    printf("Keyword end\n"); 
    printf("Keyword program\n"); 
}

"begin VarDecl:" { 
    in_vardecl = 1; 
    begin_count++; 
    printf("Keyword begin\n"); 
    printf("Keyword VarDecl\n"); 
    printf("Separator :\n");
}

"end VarDecl" { 
    in_vardecl = 0; 
    begin_count--; 
    printf("Keyword end\n"); 
    printf("Keyword VarDecl\n"); 
}

\({identifier},[ \t]*{datatype}\) { 
    if (in_vardecl) {
        char *id = strtok(yytext + 1, ",");  
        char *type = strtok(NULL, " )");    

        if (type) { 
            while (*type == ' ' || *type == '\t') type++;  
        } else {
            printf("Error: Missing data type\n");
            return 0;
        }

        if (strcmp(id, "int") == 0 || strcmp(id, "char") == 0 || strcmp(id, "if") == 0 || 
            strcmp(id, "else") == 0 || strcmp(id, "while") == 0 || strcmp(id, "for") == 0 || 
            strcmp(id, "main") == 0 || strcmp(id, "begin") == 0 || strcmp(id, "end") == 0 || 
            strcmp(id, "print") == 0 || strcmp(id, "scan") == 0 || strcmp(id, "program") == 0 || 
            strcmp(id, "VarDecl") == 0 || strcmp(id, "inc") == 0 || strcmp(id, "dec") == 0) {
            printf("%s Error: Keyword is used as an identifier\n", yytext);
        
        } 
        else if (strcmp(type, "int") != 0 && strcmp(type, "char") != 0) {
            printf("Error: Invalid data type '%s'\n", type);
        } 
        else {
            printf("Identifier: %s\n", id);
            printf("Keyword: %s\n", type);
        }
    } else {
        printf("Error: Variable declaration outside VarDecl block\n");
    }
}

%%
int main()
{
    yyin = fopen("sample.txt", "r");
    yylex();
    return 0;
}
int yywrap() {
    return 1;  // Tells Flex there's no more input
}