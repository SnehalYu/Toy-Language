# 🧸 Toy Language - Syntax Analysis and AST Generation

This repository contains the second part of the **CS F363 Compiler Construction** course project at BITS Pilani, Hyderabad Campus. It focuses on:

- ✅ Checking syntactic correctness of a toy programming language using **Bison** and **Flex**
- ✅ Printing the **Abstract Syntax Tree (AST)** in generalized list format

---

## 📁 Project Structure

```
Toy-Language/
├── syntax_analysis/
│   ├── Makefile
│   ├── toy.y      # Bison grammar file
│   ├── toy.l      # Flex lexer file
│   └── ...
│
├── ast_generation/
│   ├── Makefile
│   ├── toy.y      # Extended Bison file with AST generation
│   ├── toy.l
│   └── ...
│
├── test_cases/
│   ├── input1.txt
│   └── ...
│
├── group_info.pdf # Contains BITS ID, name, and email ID of group members
└── README.md
```

---

## 📥 Input Format

The input program is provided as a `.txt` file via command-line argument.

Sample `main()` to read input:

```c
int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input file>\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("Error opening file");
        return 1;
    }

    yyparse();
    fclose(yyin);
    return 0;
}
```

Run the program with:

```bash
./a.out input1.txt
```

---

## ✅ Output Format

- If syntactically correct:
```bash
Successfully parsed !!!
```

- If there's a syntax error:
```bash
Syntax error !!!
```

- If AST mode is enabled and input is valid:
  AST is printed in a generalized list format.

---

## 🧪 Sample Test Cases

### ✅ Valid Input

```toy
begin program:
begin VarDecl:
(a, int);
(b, int);
end VarDecl
a := (5, 10);
b := (7, 8);
end program
```

**Output:**
```
Successfully parsed !!!
```

---

### ❌ Invalid Input (Missing Semicolon)

```toy
begin program:
begin VarDecl:
(x, int)
end VarDecl
x := (10, 10);
end program
```

**Output:**
```
Syntax error !!!
```

---

### 🌳 AST Example

**Input:**

```toy
begin program:
begin VarDecl:
(i, int);
end VarDecl
i := (5, 10);
if (i > (10, 10))
begin
i := i + (0, 10);
end
else
begin
i := (20, 10);
end;
end program
```

**Output (AST):**

```lisp
(
(i int)
(
(:= i (5 10))
(
(if
(> i (10 10))
(
(:= i (+ i (0 10)))
)
(
(:= i (20 10))
)
)
)
)
)
```
