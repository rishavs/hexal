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
    int64_t line;
} Token_t;
typedef struct {
    Token_t* data;
    int64_t len;
    int64_t capacity;
} List_of_tokens_t;
int64_t list_of_tokens_do_push(List_of_tokens_t* list, Token_t token);

// Indices structure
typedef struct {
    int64_t* data;
    int64_t len;
    int64_t capacity;
} List_of_ints_t; 
int64_t list_of_ints_do_push(List_of_ints_t* list, int64_t item);

// Node structure
typedef struct Node_t {
    Dyn_string_t   kind;
        
    int64_t      pos;                // starting position in the source code
    int64_t      line;               // line number in the source code

    int64_t      scope_depth;        // distance from root in terms of scopes
    int64_t      root_distance;      // distance from root in terms of nodes - parent linkages

    int64_t      parent_i;             // index of the parent node
    int64_t      scope_owner_i;        // index of the scope owner node
    
    union {
        struct { Dyn_string_t value; } Integer_data;
        struct { Dyn_string_t value; } Decimal_data;
        struct { Dyn_string_t value; } Identifier_data;
        // struct { char* operator; int64_t right_index; } Node_Unary;
        // struct { char* operator; int64_t expressions[] } Node_Binary; // can a qualified chain just be binary?
        // struct { int64_t identifier_index; int64_t expression_index; } Reassignment_data;
        struct { int64_t identifier_i; int64_t expression_i; } Declaration_data;
        // struct { struct Node *expr; } Node_Return;
        struct { List_of_ints_t statements;} Program_data;
    };
} Node_t;
typedef struct {
    struct Node_t* data;
    int64_t len;
    int64_t capacity;
} List_of_nodes_t;
int64_t list_of_nodes_do_push(List_of_nodes_t* list, Node_t node);


// Transpiler context
typedef struct {
    Dyn_string_t filepath;
    Dyn_string_t src;

    // errors
    List_of_errors_t errors;

    // lexer
    List_of_tokens_t tokens;

    // parser
    List_of_nodes_t nodes;  
        
    // codegen
    Dyn_string_t c_code;
    Dyn_string_t h_code;
    
    // Header flags
    bool has_integer;
    bool has_string;
    bool has_list;
    bool has_dict;

    // Other flags
    bool has_error;

} Transpiler_ctx_t;
Transpiler_ctx_t* transpiler_ctx_do_init(Dyn_string_t filepath, Dyn_string_t src);

void parser_expected_syntax_error(Transpiler_ctx_t* ctx, Dyn_string_t expected_syntax, int64_t at, Dyn_string_t transpiler_file, int64_t transpiler_line);
void unhandled_transpiler_error(Transpiler_ctx_t* ctx, int64_t at, Dyn_string_t transpiler_file, int64_t transpiler_line);

void lex_file(Transpiler_ctx_t* ctx);
void parse_file(Transpiler_ctx_t* ctx);
void transpile_file(Transpiler_ctx_t* ctx);
void gen_code(Transpiler_ctx_t* ctx);


#endif // HEXAL_TRANSPILER_H