#include <stdio.h>
#include <stdlib.h>
#include "ast.h"
#include "symtab.h"

extern int yyparse(void);
extern FILE* yyin;
extern AST* root;  // set by Bison in final.tab.c

int main(int argc, char* argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input file>\n", argv[0]);
        return 1;
    }
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("Error opening file");
        return 1;
    }
    symtab_init();
    if (yyparse() != 0) {
        fprintf(stderr, "Parsing failed\n");
        return 1;
    }
    // Execute the program
    eval_ast(root);
    // Print final symbol table
    symtab_print();
    // Cleanup
    free_ast(root);
    symtab_cleanup();
    return 0;
}
