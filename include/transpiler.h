#ifndef HEXAL_TRANSPILER_H
#define HEXAL_TRANSPILER_H

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdbool.h>

#include "dyn_string.h"

#define DEFAULT_CFILE_CODE "\
int main() {\n\
    return 0;\n\
}"


// Token structure
typedef struct Token_t {
    Dyn_string_t* kind;
    int64_t pos;
    int64_t len;
    int64_t line;
} Token_t;


typedef struct {
    Dyn_string_t* filepath;
    Dyn_string_t* src;

    // lexer
    Token_t* tokens;
    int64_t tokens_len;
    int64_t tokens_capacity;
    
    
    
    // codegen
    Dyn_string_t* c_code;
    Dyn_string_t* h_file;
    
    // char* src;
    // char* c_code;
    // char* h_file;
} Transpiler_ctx_t;
void transpile_file(Transpiler_ctx_t* ctx);

#endif // HEXAL_TRANSPILER_H