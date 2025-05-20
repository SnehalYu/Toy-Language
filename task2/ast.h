#ifndef AST_H
#define AST_H

#include <stdbool.h>

// Types of AST nodes
typedef enum {
    NODE_INT,
    NODE_VAR,
    NODE_BINOP,
    NODE_ASSIGN,
    NODE_SEQ,
    NODE_PRINT,
    NODE_SCAN,
    NODE_IF,
    NODE_WHILE
} NodeType;

// AST node structure
typedef struct AST {
    NodeType type;
    char* op;           // operator for binary ops
    char* var_name;     // variable name for var/assign/scan
    int int_value;      // literal integer value
    struct AST* left;
    struct AST* right;
    struct AST* cond;           // for if/while
    struct AST* then_branch;    // for if/while
    struct AST* else_branch;    // for if
    struct AST* next;           // for sequencing statements
} AST;

// Constructors
AST* ast_int(int value);
AST* ast_var(const char* name);
AST* ast_binop(const char* op, AST* left, AST* right);
AST* ast_assign(const char* name, AST* expr);
AST* ast_print(AST* expr);
AST* ast_scan(const char* name);
AST* ast_if(AST* cond, AST* then_b, AST* else_b);
AST* ast_while(AST* cond, AST* body);
AST* ast_seq(AST* first, AST* second);

// Execution & cleanup
void eval_ast(AST* node);
void free_ast(AST* node);

#endif // AST_H
