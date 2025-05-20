/* final.y */

%{
#include "ast.h"
#include "symtab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


AST* root = NULL;
void yyerror(const char* s) { fprintf(stderr, "Parse error: %s\n", s); }
int yylex(void);
extern FILE* yyin;
%}

%union {
    int     ival;
    char*   sval;
    AST*    ast;
}

/* keyword tokens */
%token T_BEGIN T_END T_PROGRAM T_VARDEC T_COLON
%token T_IF T_ELSE T_THEN T_ENDIF
%token T_WHILE T_DO T_ENDWHILE
%token T_FOR T_TO
%token T_PRINT T_SCAN

/* your single ‘type’ token */
%token <sval> T_TYPE

/* punctuation */
%token T_LPAREN T_RPAREN
%token T_COMMA T_SM OSB CSB

/* operators and identifiers */
%token <sval> T_ASSIGN_OP T_REL_OP T_ARITH_OP T_IDENTIFIER
%token <ival> T_INTEGER

/* the only nonterminals that carry an AST pointer */
%type <ast>
    program
    variable_declaration variable_list variable_definition
    statements statement assignment
    if_statement loop_statement io_statement
    print_statement scan_statement
    expression condition factor

%%

program:
    T_BEGIN T_PROGRAM T_COLON variable_declaration statements T_END T_PROGRAM
    { root = $5; }
  ;

variable_declaration:
    T_BEGIN T_VARDEC T_COLON variable_list T_END T_VARDEC
    { /* no AST node for declarations */ $$ = NULL; }
;

variable_list:
      variable_definition
    | variable_definition variable_list
  ;

variable_definition:
    T_IDENTIFIER T_COLON T_TYPE T_SM
    {
      symtab_add_var($1);
      free($1);
      free($3);
    }
  ;

statements:
      statement                   { $$ = $1; }
    | statement statements        { $$ = ast_seq($1, $2); }
  ;

statement:
      assignment
    | if_statement
    | loop_statement
    | io_statement
  ;

assignment:
    T_IDENTIFIER T_ASSIGN_OP expression T_SM
    {
      $$ = ast_assign($1, $3);
      free($1);
    }
  ;

if_statement:
    T_IF condition T_THEN statements T_ENDIF
      { $$ = ast_if($2, $4, NULL); }
  | T_IF condition T_THEN statements T_ELSE statements T_ENDIF
      { $$ = ast_if($2, $4, $6); }
  ;

loop_statement:
    T_WHILE condition T_DO statements T_ENDWHILE
      { $$ = ast_while($2, $4); }
  ;

/* optional: you could add a FOR loop here similarly */

io_statement:
      print_statement
    | scan_statement
  ;

print_statement:
    T_PRINT T_LPAREN expression T_RPAREN T_SM
      { $$ = ast_print($3); }
  ;

scan_statement:
    T_SCAN T_LPAREN T_IDENTIFIER T_RPAREN T_SM
    {
      $$ = ast_scan($3);
      free($3);
    }
  ;

expression:
      expression T_ARITH_OP condition
      { $$ = ast_binop($2, $1, $3); free($2); }
    | condition
      { $$ = $1; }
  ;

condition:
      condition T_REL_OP factor
      { $$ = ast_binop($2, $1, $3); free($2); }
    | factor
      { $$ = $1; }
  ;

factor:
      T_INTEGER              { $$ = ast_int($1); }
    | T_IDENTIFIER           { $$ = ast_var($1); free($1); }
    | T_LPAREN expression T_RPAREN { $$ = $2; }
  ;

%%


