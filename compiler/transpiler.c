#include <stdint.h> 

#include "errors.h"
#include "dyn_string.h"
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

    // Initialize the nodes list
    ctx->nodes.len = 0;
    ctx->nodes.capacity = 8;
    ctx->nodes.data = calloc(ctx->nodes.capacity, sizeof(Node_t));
    if (ctx->nodes.data == NULL) memory_allocation_failure(0, 0, NULL, __FILE__, __LINE__);

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

void parser_expected_syntax_error(Transpiler_ctx_t* ctx, Dyn_string_t expected_syntax, int64_t at, Dyn_string_t transpiler_file, int64_t transpiler_line) {
    Token_t token = ctx->tokens.data[at];

    // [RES_EXPECTED]              = "Expected %s, ",
    // [RES_FOUND_X]               = "but found \"%s\". ",
    // [RES_REACHED_EOS]           = "but instead reached end of source.",

    Dyn_string_t found;
    if (at >= ctx->tokens.len) {
        found = dyn_string_do_init("but instead reached end of source.");
    } else {
        found = dyn_string_do_join(3,
            dyn_string_do_init("but instead found \""), 
            token.value,
            dyn_string_do_init("\". ")
        );
    }

    Dyn_string_t msg = dyn_string_do_join(5, 
        dyn_string_do_init("Expected "), 
        expected_syntax,
        dyn_string_do_init(", "), 
        found,
        dyn_string_do_init(". ")
    );
    printf("%s\n", msg.data);
    Transpiler_error_t error = {
        .category = dyn_string_do_init("[ ERROR ] Malformed Syntax!"),
        .msg = msg,
        .pos = token.pos,
        .line = token.line,
        .filepath = ctx->filepath,
        .transpiler_file = transpiler_file,
        .transpiler_line = transpiler_line
    };
    list_of_errors_do_push(&ctx->errors, error);
}

// void parser_expected_syntax_error(Transpiler_context_t* ctx, const char* expected_syntax, const char* transpiler_file, const size_t transpiler_line) {
//     Token_t token = ctx->tokens[ctx->i];
//     char* err_msg;
//     if (ctx->i >= ctx->tokens_count) {
//         err_msg = join_strings(3,
//             build_string(en_us[RES_EXPECTED], expected_syntax), 
//             " ", 
//             en_us[RES_REACHED_EOS]
//         );
//     } else {
//         err_msg = join_strings(3,
//             build_string(en_us[RES_EXPECTED], expected_syntax), 
//             " ", 
//             build_string(en_us[RES_FOUND_X], get_substring(ctx->src, token.pos, token.len)));
//     }
//     add_error_to_context(ctx, 
//         en_us[RES_SYNTAX_ERROR_CAT], 
//         err_msg, 
//         token.pos, token.line, __FILE__, __LINE__
//     );
   
// }


int64_t list_of_nodes_do_push(List_of_nodes_t* list, Node_t node) {
    if (list->len + 1 >= list->capacity) {
        list->capacity *= 2;
        list->data = realloc(list->data, list->capacity * sizeof(Node_t));
        if (list->data == NULL) memory_allocation_failure(0, 0, NULL, __FILE__, __LINE__);
    }

    list->data[list->len] = node;
    list->len++;

    return list->len - 1;
}

int64_t list_of_ints_do_push(List_of_ints_t* list, int64_t item) {
    if (list->len + 1 >= list->capacity) {
        list->capacity *= 2;
        list->data = realloc(list->data, list->capacity * sizeof(int64_t));
        if (list->data == NULL) memory_allocation_failure(0, 0, NULL, __FILE__, __LINE__);
    }

    list->data[list->len] = item;
    list->len++;

    return list->len - 1;
}

// int64_t list_of_ints_do_push(int64_t* list, int64_t item, int64_t count, int64_t capacity) {
//     if (count >= capacity) {
//         capacity *= 2;
//         list = realloc(list, capacity * sizeof(int64_t));
//         if (list == NULL) memory_allocation_failure(0, 0, NULL, __FILE__, __LINE__);
//     }
//     int64_t at = count;
//     list[at] = item;
//     count++;
//     return at;
// }

void transpile_file(Transpiler_ctx_t* ctx){

    // Run the lexer
    lex_file(ctx);


    // print the tokens
    // for (int i = 0; i < ctx->tokens.len; i++) {
    //     Token_t token = ctx->tokens.data[i];
    //     printf("%s:%s\n", token.kind.data, token.value.data);
    // }

    // run the parser
    parse_file(ctx);

    // print the nodes
    for (int i = 0; i < ctx->nodes.len; i++) {
        Node_t node = ctx->nodes.data[i];
        printf("%s\n", node.kind.data);
    }

    // create dummy output
    ctx->c_code = dyn_string_do_init("int main() {\n    return 0;\n}\n");
    ctx->h_file = dyn_string_do_init("#ifndef __TEST_H__\n#define __TEST_H__\n\n#endif\n");
    

    // print the errors
    for (int i = 0; i < ctx->errors.len; i++) {
        Transpiler_error_t error = ctx->errors.data[i];
        printf("%s:%s\n", error.category.data, error.msg.data); 
    }


}