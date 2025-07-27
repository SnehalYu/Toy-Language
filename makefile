# --- User-adjustable settings ---
CC      := gcc
CFLAGS  := -Wall -Wextra -g
LEX     := flex
YACC    := bison
YFLAGS  := -d

TARGET  := parser

# Source files:
SRCS    := \
    ast.c \
    symtab.c \
    main.c \
    final.tab.c \
    lex.yy.c

OBJS    := $(SRCS:.c=.o)

# --- Build rules ---
.PHONY: all clean

all: $(TARGET)

# Step 1: generate parser from Bison
final.tab.c final.tab.h: final.y
	$(YACC) $(YFLAGS) final.y

# Step 2: generate lexer from Flex
lex.yy.c: final.l final.tab.h
	$(LEX) final.l

# Step 3: compile all .c → .o
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Step 4: link everything into the final executable
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS) -lfl

# Clean up generated files
clean:
	rm -f $(TARGET) $(OBJS) final.tab.c final.tab.h lex.yy.c


