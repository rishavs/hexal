#include <stdint.h> 

#include "errors.h"
#include "transpiler.h"

Transpiler_ctx_t* transpiler_ctx_do_init(Dyn_string_t filepath, Dyn_string_t src) {
    Transpiler_ctx_t* ctx = calloc(1, sizeof(Transpiler_ctx_t));
    if (ctx == NULL) memory_allocation_failure(0, 0, NULL, __FILE__, __LINE__);

    ctx->filepath = filepath;
    ctx->src = src;

    // Initialize the errors list
    ctx->errors.len = 0;
    ctx->errors.capacity = 8;
    ctx->errors.data = calloc(ctx->errors.capacity, sizeof(Transpiler_error_t));
    if (ctx->errors.data == NULL) memory_allocation_failure(0, 0, NULL, __FILE__, __LINE__);

    // Initialize the tokens list
    ctx->tokens.len = 0;
    ctx->tokens.capacity = 8;
    ctx->tokens.data = calloc(ctx->tokens.capacity, sizeof(Token_t));
    if (ctx->tokens.data == NULL) memory_allocation_failure(0, 0, NULL, __FILE__, __LINE__);

    return ctx;
}

int64_t list_of_tokens_do_push(List_of_tokens_t* list, Token_t token) {
    if (list->len + 1 >= list->capacity) {
        list->capacity *= 2;
        list->data = realloc(list->data, list->capacity * sizeof(Token_t));
        if (list->data == NULL) memory_allocation_failure(0, 0, NULL, __FILE__, __LINE__);
    }

    list->data[list->len] = token;
    list->len++;

    return list->len - 1;
}

int64_t list_of_errors_do_push(List_of_errors_t* list, Transpiler_error_t error) {
    if (list->len + 1 >= list->capacity) {
        list->capacity *= 2;
        list->data = realloc(list->data, list->capacity * sizeof(Transpiler_error_t));
        if (list->data == NULL) memory_allocation_failure(0, 0, NULL, __FILE__, __LINE__);
    }

    list->data[list->len] = error;
    list->len++;

    return list->len - 1;
}

void transpile_file(Transpiler_ctx_t* ctx){

    // Run the lexer
    lex_file(ctx);


    // print the tokens
    for (int i = 0; i < ctx->tokens.len; i++) {
        Token_t token = ctx->tokens.data[i];
        printf("%s:%s\n", token.kind.data, dyn_string_do_get_substring(ctx->src, token.pos, token.len).data);
    }

    // print the errors
    for (int i = 0; i < ctx->errors.len; i++) {
        Transpiler_error_t error = ctx->errors.data[i];
        printf("%s:%s\n", error.category.data, error.msg.data); 
    }

    // create dummy output
    ctx->c_code = dyn_string_do_init("int main() {\n    return 0;\n}\n");
    ctx->h_file = dyn_string_do_init("#ifndef __TEST_H__\n#define __TEST_H__\n\n#endif\n");
    


}