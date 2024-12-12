#ifndef HEXAL_TRANSPILER_H
#define HEXAL_TRANSPILER_H

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>

#include "dyn_string.h"

#define DEFAULT_CFILE_CODE "\
int main() {\n\
    return 0;\n\
}"

typedef struct Transpiler_error_t {
    Dyn_string_t category;
    Dyn_string_t msg;

    int64_t pos;
    int64_t line;
    Dyn_string_t filepath;

    Dyn_string_t transpiler_file;
    int64_t transpiler_line;
} Transpiler_error_t;
typedef struct {
    Transpiler_error_t* data;
    int64_t len;
    int64_t capacity;
} List_of_errors_t;
int64_t list_of_errors_do_push(List_of_errors_t* list, Transpiler_error_t error);

// Token structure
typedef struct Token_t {
    Dyn_string_t kind;
    Dyn_string_t value;
    int64_t pos;
    int64_t len;
    int64_t line;
} Token_t;
typedef struct {
    Token_t* data;
    int64_t len;
    int64_t capacity;
} List_of_tokens_t;
int64_t list_of_tokens_do_push(List_of_tokens_t* list, Token_t token);

typedef struct {
    Dyn_string_t filepath;
    Dyn_string_t src;

    // errors
    List_of_errors_t errors;

    // lexer
    List_of_tokens_t tokens;
    
    
    
    // codegen
    Dyn_string_t c_code;
    Dyn_string_t h_file;
    
    // char* src;
    // char* c_code;
    // char* h_file;
} Transpiler_ctx_t;
Transpiler_ctx_t* transpiler_ctx_do_init(Dyn_string_t filepath, Dyn_string_t src);

void lex_file(Transpiler_ctx_t* ctx);
void transpile_file(Transpiler_ctx_t* ctx);

#endif // HEXAL_TRANSPILER_H