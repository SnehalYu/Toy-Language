#include "ast.h"
#include "symtab.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

// Node constructors
AST* ast_int(int value) {
    AST* n = malloc(sizeof(AST));
    n->type = NODE_INT;
    n->int_value = value;
    n->op = n->var_name = NULL;
    n->left = n->right = n->cond = n->then_branch = n->else_branch = n->next = NULL;
    return n;
}
AST* ast_var(const char* name) {
    AST* n = malloc(sizeof(AST));
    n->type = NODE_VAR;
    n->var_name = strdup(name);
    n->op = NULL;
    n->left = n->right = n->cond = n->then_branch = n->else_branch = n->next = NULL;
    // ensure declared
    symtab_add_var(name);
    return n;
}
AST* ast_binop(const char* op, AST* l, AST* r) {
    AST* n = malloc(sizeof(AST));
    n->type = NODE_BINOP;
    n->op = strdup(op);
    n->left = l;
    n->right = r;
    n->var_name = NULL;
    n->cond = n->then_branch = n->else_branch = n->next = NULL;
    return n;
}
AST* ast_assign(const char* name, AST* expr) {
    AST* n = malloc(sizeof(AST));
    n->type = NODE_ASSIGN;
    n->var_name = strdup(name);
    n->left = expr;
    n->right = n->cond = n->then_branch = n->else_branch = n->next = NULL;
    symtab_add_var(name);
    return n;
}
AST* ast_print(AST* expr) {
    AST* n = malloc(sizeof(AST));
    n->type = NODE_PRINT;
    n->left = expr;
    n->op = n->var_name = NULL;
    n->right = n->cond = n->then_branch = n->else_branch = n->next = NULL;
    return n;
}
AST* ast_scan(const char* name) {
    AST* n = malloc(sizeof(AST));
    n->type = NODE_SCAN;
    n->var_name = strdup(name);
    n->left = n->right = n->cond = n->then_branch = n->else_branch = n->next = NULL;
    symtab_add_var(name);
    return n;
}
AST* ast_if(AST* cond, AST* tb, AST* eb) {
    AST* n = malloc(sizeof(AST));
    n->type = NODE_IF;
    n->cond = cond;
    n->then_branch = tb;
    n->else_branch = eb;
    n->op = n->var_name = NULL;
    n->left = n->right = n->next = NULL;
    return n;
}
AST* ast_while(AST* cond, AST* body) {
    AST* n = malloc(sizeof(AST));
    n->type = NODE_WHILE;
    n->cond = cond;
    n->then_branch = body;
    n->else_branch = NULL;
    n->op = n->var_name = NULL;
    n->left = n->right = n->next = NULL;
    return n;
}
AST* ast_seq(AST* a, AST* b) {
    if (!a) return b;
    AST* n = malloc(sizeof(AST));
    n->type = NODE_SEQ;
    n->left = a;
    n->right = b;
    n->op = n->var_name = NULL;
    n->cond = n->then_branch = n->else_branch = n->next = NULL;
    return n;
}

// Evaluate integer expressions
static int eval_expr(AST* node) {
    bool ok;
    switch (node->type) {
        case NODE_INT: return node->int_value;
        case NODE_VAR: {
            int v = symtab_get(node->var_name, &ok);
            if (!ok) exit(1);
            return v;
        }
        case NODE_BINOP: {
            int l = eval_expr(node->left);
            int r = eval_expr(node->right);
            if (strcmp(node->op, "+") == 0) return l + r;
            if (strcmp(node->op, "-") == 0) return l - r;
            if (strcmp(node->op, "*") == 0) return l * r;
            if (strcmp(node->op, "/") == 0) { if (r == 0) { fprintf(stderr, "Division by zero\n"); exit(1); } return l / r; }
            if (strcmp(node->op, "%") == 0) { if (r == 0) { fprintf(stderr, "Modulo by zero\n"); exit(1); } return l % r; }
            if (strcmp(node->op, "==") == 0) return l == r;
            if (strcmp(node->op, "!=") == 0) return l != r;
            if (strcmp(node->op, "<") == 0) return l < r;
            if (strcmp(node->op, "<=") == 0) return l <= r;
            if (strcmp(node->op, ">") == 0) return l > r;
            if (strcmp(node->op, ">=") == 0) return l >= r;
            fprintf(stderr, "Unknown operator '%s'\n", node->op);
            exit(1);
        }
        default:
            fprintf(stderr, "Invalid expression node\n");
            exit(1);
    }
}

// Execute statements
void eval_ast(AST* node) {
    if (!node) return;
    switch (node->type) {
        case NODE_SEQ:
            eval_ast(node->left);
            eval_ast(node->right);
            break;
        case NODE_ASSIGN: {
            int v = eval_expr(node->left);
            symtab_set(node->var_name, v);
            break;
        }
        case NODE_PRINT: {
            int v = eval_expr(node->left);
            printf("%d\n", v);
            break;
        }
        case NODE_SCAN: {
            int v;
            if (scanf("%d", &v) != 1) { fprintf(stderr, "Scan error\n"); exit(1); }
            symtab_set(node->var_name, v);
            break;
        }
        case NODE_IF: {
            if (eval_expr(node->cond)) eval_ast(node->then_branch);
            else if (node->else_branch) eval_ast(node->else_branch);
            break;
        }
        case NODE_WHILE:
            while (eval_expr(node->cond)) {
                eval_ast(node->then_branch);
            }
            break;
        default:
            fprintf(stderr, "Invalid statement node type %d\n", node->type);
            exit(1);
    }
}

// Free the AST
void free_ast(AST* node) {
    if (!node) return;
    free_ast(node->left);
    free_ast(node->right);
    free_ast(node->cond);
    free_ast(node->then_branch);
    free_ast(node->else_branch);
    free_ast(node->next);
    free(node->op);
    free(node->var_name);
    free(node);
}
