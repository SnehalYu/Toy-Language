#ifndef SYMTAB_H
#define SYMTAB_H

#include <stdbool.h>

// Entry for a scalar integer variable
typedef struct {
    char* name;
    int value;
    bool initialized;
} VarEntry;

// Initialize symbol table
void symtab_init();
// Add a new variable (if not already present)
void symtab_add_var(const char* name);
// Check if a variable is declared
bool symtab_contains(const char* name);
// Set variable's value (marks initialized)
void symtab_set(const char* name, int value);
// Get variable's value (reports use-before-init)
int symtab_get(const char* name, bool* ok);
// Print the table at end
void symtab_print();
// Free allocated names
void symtab_cleanup();

#endif // SYMTAB_H
