#include "symtab.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#define MAX_VARS 1024
static VarEntry table[MAX_VARS];
static int var_count = 0;

void symtab_init() {
    var_count = 0;
}

void symtab_add_var(const char* name) {
    if (symtab_contains(name)) return;
    if (var_count >= MAX_VARS) {
        fprintf(stderr, "Symbol table overflow\n");
        exit(1);
    }
    table[var_count].name = strdup(name);
    table[var_count].initialized = false;
    table[var_count].value = 0;
    var_count++;
}

bool symtab_contains(const char* name) {
    for (int i = 0; i < var_count; i++) {
        if (strcmp(table[i].name, name) == 0)
            return true;
    }
    return false;
}

void symtab_set(const char* name, int value) {
    for (int i = 0; i < var_count; i++) {
        if (strcmp(table[i].name, name) == 0) {
            table[i].value = value;
            table[i].initialized = true;
            return;
        }
    }
    fprintf(stderr, "Semantic error: variable '%s' not declared\n", name);
}

int symtab_get(const char* name, bool* ok) {
    for (int i = 0; i < var_count; i++) {
        if (strcmp(table[i].name, name) == 0) {
            if (!table[i].initialized) {
                fprintf(stderr, "Semantic error: variable '%s' used before initialization\n", name);
            }
            *ok = table[i].initialized;
            return table[i].value;
        }
    }
    fprintf(stderr, "Semantic error: variable '%s' not declared\n", name);
    *ok = false;
    return 0;
}

void symtab_print() {
    printf("\nSymbol Table:\n");
    printf("Name\tValue\tInitialized\n");
    for (int i = 0; i < var_count; i++) {
        printf("%s\t%d\t%s\n",
            table[i].name,
            table[i].value,
            table[i].initialized ? "yes" : "no");
    }
}

void symtab_cleanup() {
    for (int i = 0; i < var_count; i++) {
        free(table[i].name);
    }
    var_count = 0;
}
