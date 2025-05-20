%{
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

int s_comment = 0;    // Single line comment counter
int m_comment = 0;    // Multi line comment counter
int at_count = 0;     // Count of @ symbols in print/scan
int arg_count = 0;    // Count of arguments in print/scan
int comma_count = 0;
char buffer[1024];    // Buffer for storing statements
int in_vardecl = 0;   // Track if in variable declaration
int underscore_count=0;
int invalid_char=0;
int var_count=0;
char words[100][50];
int prev_state= 0;
int valid_arr = 0;

// Print token in the required format
void print_token(const char* lexeme, const char* type) {
    printf("%s\t%s\n", lexeme, type);
}

int isDuplicate(char words[][50], int w_count, char *leaf){
	for(int i=0;i<w_count;i++){
		if(strcmp(words[i],leaf)==0) return 1;
	} return 0;
}

// Check if a given string is a keyword
int isKeyword(const char* str) {
    const char* keywords[] = {
        "int", "char", "if", "else", "while", "for", "main", 
        "begin", "end", "print", "scan", "program", "VarDecl", 
        "inc", "dec", "to", "do", "then"
    };
    
    int num_keywords = sizeof(keywords) / sizeof(keywords[0]);
    
    for(int i = 0; i < num_keywords; i++) {
        if(strcmp(str, keywords[i]) == 0) {
            return 1;
        }
    }
    return 0;
}

%}

%x COMMENT SLCOMMENT VARDECL PRINT PRINT1 SCAN SCAN1 FOR WHILE IF STRING VARDECL1 VARDEC2COMMA VARDEC3 VARDECEND 

/* Regular definitions */
DIGIT       [0-9]
BINARY      [01]+
DECIMAL     [0-9]*
OCTAL       [0-7]+
ID          [a-z][a-z0-9]*(_[a-z0-9]+)?
Variable    [a-zA-Z][a-zA-Z0-9_]*
KEYWORD     int|char|if|else|while|for|main|begin|end|print|scan|program|VarDecl|inc|dec|to|do|then
type  	    int|char
CHARCONST   \'[^\']*\'
STRING      \"[^\"]*\"
SLINE	    //(.*)$
Number      [1-9][0-9]*

%%


<*>"//"(.)*\n {s_comment++; }
<*>"/*" { prev_state=YY_START; BEGIN(COMMENT); } /* Enter COMMENT state */
<COMMENT>. { }
<COMMENT>"*/" { m_comment++; BEGIN(prev_state); } /* Exit COMMENT state */
<COMMENT>\n { /* Handle new lines inside comments */ }

"begin program:" {
    print_token("begin", "Keyword");
    print_token("program", "Keyword");
    print_token(":", "Separator");
}

    /* Variable Declaration block */
"begin VarDecl:" {
    BEGIN(VARDECL);
    in_vardecl = 1;
    print_token("begin", "Keyword");
    print_token("VarDecl", "Keyword");
    print_token(":", "Separator");
}

<VARDECL>"end VarDecl" {
    in_vardecl = 0;
    BEGIN(INITIAL);
    print_token("end", "Keyword");
    print_token("VarDecl", "Keyword");
}

<VARDECL>\( {
    BEGIN(VARDECL1);
	print_token(yytext,"Seperator");
}

<VARDECL1>{Variable} {
    BEGIN(VARDEC2COMMA);
	
	var_count++;

    for (int i = 0; i < strlen(yytext); i++) {
        if (yytext[i] == '_') {
            underscore_count++;
        } else if (!isalnum(yytext[i]) && yytext[i] != '_' && yytext[i] != '[' && yytext[i] != ']') {
            invalid_char = 1;
        } else if (isupper(yytext[i])) {
            invalid_char = 1;
        }
    }

    if (isKeyword(yytext)) {
        print_token(yytext, "Error: keyword used as an identifier");
    } else if (!islower(yytext[0])) {
        print_token(yytext,"Error: invalid identifier");
    } else if (underscore_count > 1) {
        print_token(yytext,"Error: invalid identifier");
    } else if (invalid_char) {
        print_token(yytext,"Error: invalid identifier");
    } else if(isDuplicate(words,var_count,yytext)){
	    print_token(yytext,"Error: identifier already declared");
    }else {
	    strcpy(words[var_count],yytext);
        print_token(yytext,"Identifier");
    }
    underscore_count = 0;
    invalid_char = 0;
}
<VARDECL1>{Variable}\[[0-9]+\] {  
    BEGIN(VARDEC2COMMA);
    
    char array_name[100];
    int array_size;
    
    sscanf(yytext, "%[a-zA-Z0-9_][%d]", array_name, &array_size); // Extract array name and size

    int underscore_count = 0, invalid_char = 0;
    for (int i = 0; array_name[i] != '\0'; i++) {
        if (array_name[i] == '_') {
            underscore_count++;
        } else if (!isalnum(array_name[i]) && array_name[i] != '_') {
            invalid_char = 1;
        }
    }

    // Check if the array name is already declared
    if (isKeyword(array_name)) {
        print_token(array_name, "Error: keyword used as an identifier");
    } else if (underscore_count > 1) {
        print_token(array_name, "Error: invalid identifier");
    } else if (invalid_char) {
        print_token(array_name, "Error: invalid identifier");
    } else if (isDuplicate(words, var_count, array_name)) {
        print_token(array_name, "Error: identifier already declared");
    } else {
        strcpy(words[var_count], array_name);
        var_count++;
        char output[1000];
        sprintf(output, "%s[%d]", array_name, array_size);
        char type_output[100];
        sprintf(type_output, "Array Identifier with size %d", array_size);
        print_token(output, type_output);
    }
}


<VARDEC2COMMA>, {
	BEGIN(VARDEC3);
	print_token(",","Seperator");
}

<VARDEC3>{type} { 
    BEGIN(VARDECEND);
    print_token(yytext,"Keyword");
}

<VARDECEND>");" {
    BEGIN(VARDECL);
    print_token(")","Seperator");
    print_token(";","Seperator");
}


    /* Print statement handling */
"print("         { 
    BEGIN(PRINT); 
    at_count = 0;
    arg_count = 0;
    strcpy(buffer, yytext);
    //print_token(yytext, "Keyword");
}

<PRINT>\"[^\"]*\" {
    BEGIN(PRINT1);
    strcat(buffer, yytext);
    // Count @ symbols
    for(int i = 0; yytext[i]; i++)
        if(yytext[i] == '@') at_count++;
    //print_token(yytext, "String constant");
}

<PRINT1>,[[:space:]]*{ID} {
    arg_count++;
    strcat(buffer, yytext);
    // Check if the identifier part is a keyword
    char identifier[100];
    sscanf(yytext, ", %s", identifier);
    if (isKeyword(identifier)) {
        print_token(identifier, "Error: keyword used as an identifier");
    }
    //print_token(yytext, "Identifier");
}

<PRINT1>");" {
    strcat(buffer, yytext);
    if(at_count != arg_count) {
        print_token(buffer,"Error: invalid print statement");
    }
    else{
        print_token(buffer,"Valid output statement");
    }
    //print_token(")", "Separator");
    //print_token(";", "Separator");
    memset(buffer,0,sizeof(buffer));
    BEGIN(INITIAL);
}

    /* Scan statement handling */
"scan("          {
    BEGIN(SCAN);
    at_count = 0;
    arg_count = 0;
    comma_count = 0;
    strcpy(buffer, yytext);
    //print_token(yytext, "Keyword");
}

<SCAN>\"[@, ]*\" {
    BEGIN(SCAN1);
    strcat(buffer, yytext);
    // Count @ symbols
    for(int i = 0; yytext[i]; i++){
        if(yytext[i] == '@') at_count++;
	    if(yytext[i] == ',') comma_count++;
    }
    //print_token(yytext, "String constant");
}

<SCAN1>,[[:space:]]*{ID} {
    arg_count++;
    strcat(buffer, yytext);
    // Check if the identifier part is a keyword
    char identifier[100];
    sscanf(yytext, ", %s", identifier);
    if (isKeyword(identifier)) {
        print_token(identifier, "Error: keyword used as an identifier");
    }
    //print_token(yytext, "Identifier");
}

<SCAN1>");" {
    strcat(buffer, yytext);
    if(at_count != arg_count) {
	//printf("at_count: %d",at_count);
	//printf("arg_count: %d",arg_count);
        print_token(buffer,"Error: invalid input statement");
    } else if(at_count != (comma_count+1)){
		//printf("at_count: %d",at_count);
		//printf("comma_count: %d",comma_count);
		//printf("arg_count: %d",arg_count);
	    print_token(buffer,"Error: invalid input statement");
    }
    else{
        print_token(buffer,"Valid input statement");
    }
    //print_token(");", "Separator");
    BEGIN(INITIAL);
}

\([0-9]+,[ ]*[0-9]+\) {
    char num[100], base[10];
    sscanf(yytext, "(%[^,],%[^)])", num, base);
    int baseVal = atoi(base);
    
    if(baseVal != 2 && baseVal != 8 && baseVal != 10) {
        printf("%s\tError: invalid integer constant\n", yytext);
    } else {
        // Validate digits according to base
        int valid = 1;
        for(int i = 0; num[i]; i++) {
            if(baseVal == 2 && (num[i] != '0' && num[i] != '1'))
                valid = 0;
            else if(baseVal == 8 && (num[i] < '0' || num[i] > '7'))
                valid = 0;
        }
        if(!valid)
            printf("%s\tError: invalid integer constant for base %d\n", yytext, baseVal);
        else
            print_token(yytext, "Integer constant");
    }
}

{KEYWORD}       { print_token(yytext, "Keyword"); }
{ID}            { 
    // Check if identifier is a keyword before accepting it
    if (isKeyword(yytext)) {
        print_token(yytext, "Error: keyword used as an identifier");
    } else {
        print_token(yytext, "Identifier"); 
    }
}
{CHARCONST}     { print_token(yytext, "Character constant"); }

[:+\-*/%][=]    { print_token(yytext, "Assignment operator"); }
[+\-*/%]        { print_token(yytext, "Arithmetic operator"); }
[<>=]=?         { print_token(yytext, "Relational operator"); }
[(){},;:]       { print_token(yytext, "Separator"); }

[ \t\n]+        ; 

%%

int main() {
    yyin = fopen("sample.txt", "r");
    if (!yyin) {
        printf("Could not open file\n");
        return 1;
    }
    yylex();
    fclose(yyin);
    return 0;
}

int yywrap() {
    return 1;
}
