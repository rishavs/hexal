#include "resources.h"
#include "errors.h"
#include "dyn_string.h"
#include "transpiler.h"


int64_t parse_integer (Transpiler_ctx_t* ctx, int64_t* i) {
    // Get the current token
    Token_t token = ctx->tokens.data[*i];

    // create the node
    int64_t index = list_of_nodes_do_push(&ctx->nodes, (Node_t) {
        .kind = dyn_string_do_init("integer"),
        .pos = token.pos,
        .line = token.line,
        .scope_depth = 0,
        .root_distance = 0,
        .parent_i= 0,
        .scope_owner_i= 0,

        .Integer_data = { .value = token.value }
    });

    // consume the token
    (*i)++;

    return index;
}

int64_t parse_identifier (Transpiler_ctx_t* ctx, int64_t* i) {
    // Get the current token
    Token_t token = ctx->tokens.data[*i];

    // create the node
    int64_t index = list_of_nodes_do_push(&ctx->nodes, (Node_t) {
        .kind = dyn_string_do_init("identifier"),
        .pos = token.pos,
        .line = token.line,
        .scope_depth = 0,
        .root_distance = 0,
        .parent_i= 0,
        .scope_owner_i= 0,

        .Identifier_data = { .value = token.value }
    });

    // consume the token
    (*i)++;

    return index;
}

int64_t parse_expression (Transpiler_ctx_t* ctx, int64_t* i) {
    // Get the current token
    Token_t token = ctx->tokens.data[*i];

    if (dyn_string_do_compare(token.kind, dyn_string_do_init("integer"))) {
        return parse_integer(ctx, i);
    }

    // if no expression found, raise error
    parser_expected_syntax_error(ctx, dyn_string_do_init("expression"), *i, dyn_string_do_init(__FILE__), __LINE__);
    return -1;
}

int64_t parse_declaration (Transpiler_ctx_t* ctx, int64_t* i) {
    // Get the current token
    Token_t token = ctx->tokens.data[*i];

    // create the node
    int64_t index = list_of_nodes_do_push(&ctx->nodes, (Node_t) {
        .kind = dyn_string_do_init("declaration"),
        .pos = token.pos,
        .line = token.line,
    });
    Node_t* node = &ctx->nodes.data[index];

    // consume the "let" token
    (*i)++;
    token = ctx->tokens.data[*i];
    if (ctx->tokens.len <= *i) {
        parser_expected_syntax_error(ctx, dyn_string_do_init("identifier"), *i, dyn_string_do_init(__FILE__), __LINE__);
        return -1;
    }

    // parse the identifier
    int64_t identifier_index = parse_identifier(ctx, i);
    if (identifier_index == -1) return -1;

    // consume the "=" token
    (*i)++;
    token = ctx->tokens.data[*i];
    if (ctx->tokens.len <= *i) {
        parser_expected_syntax_error(ctx, dyn_string_do_init("="), *i, dyn_string_do_init(__FILE__), __LINE__);
        return -1;
    }

    // parse the expression
    int64_t expression_index = parse_expression(ctx, i);
    if (expression_index == -1) return -1;

    // update the node
    node->Declaration_data.identifier_i = identifier_index;
    node->Declaration_data.expression_i = expression_index;

    // update the children nodes
    Node_t* identifier_node = &ctx->nodes.data[identifier_index];
    identifier_node->parent_i= index;
    identifier_node->scope_depth = node->scope_depth;
    identifier_node->scope_owner_i= node->scope_owner_i;
    identifier_node->root_distance = node->root_distance + 1;

    Node_t* expression_node = &ctx->nodes.data[expression_index];
    expression_node->parent_i= index;
    expression_node->scope_depth = node->scope_depth;
    expression_node->scope_owner_i= node->scope_owner_i;
    expression_node->root_distance = node->root_distance + 1;

    return index;
}

void recover_from_parsing_error(Transpiler_ctx_t* ctx, int64_t* i) {
    // Get the current token
    Token_t token = ctx->tokens.data[*i];

    // skip the current token
    (*i)++;
    token = ctx->tokens.data[*i];
    while (*i < ctx->tokens.len) {
        if (dyn_string_do_compare(token.kind, dyn_string_do_init("end"))) {
            break;
        }
        (*i)++;
        token = ctx->tokens.data[*i];
    }
}

List_of_ints_t parse_statements (Transpiler_ctx_t* ctx, int64_t* i) {
    // Get the current token
    Token_t token = ctx->tokens.data[*i];

    List_of_ints_t statements_list;
    statements_list.len = 0;
    statements_list.capacity = 8;
    statements_list.data = calloc(statements_list.capacity, sizeof(int64_t));
    if (statements_list.data == NULL) memory_allocation_failure(token.pos, token.line, NULL, __FILE__, __LINE__);


    int64_t statement_index;
    while (*i < ctx->tokens.len) {
        
        if (dyn_string_do_compare(token.kind, dyn_string_do_init("let"))) {
            statement_index = parse_declaration(ctx, i);
        } else {
            // if no statement found, raise error
            printf("Yo Yo! Expected statement, but found \"%s\". ", token.kind.data);
            parser_expected_syntax_error(ctx, dyn_string_do_init("statement"), *i, dyn_string_do_init(__FILE__), __LINE__);
            recover_from_parsing_error(ctx, i);
        }

        // handle the statement outcome
        if (statement_index == -1) {
            recover_from_parsing_error(ctx, i);
        } else {
            list_of_ints_do_push(&statements_list, statement_index);
        }
    }

    return statements_list;
}

int64_t parse_program (Transpiler_ctx_t* ctx, int64_t* i) {

    // Create the Program node
    int64_t index = list_of_nodes_do_push(&ctx->nodes, (Node_t) {
        .kind = dyn_string_do_init("program"),
        .pos = 0,
        .line = 0,
        .scope_depth = 0,
        .root_distance = 0,
        .parent_i= 0,
        .scope_owner_i= 0
    });

    Node_t* program_node = &ctx->nodes.data[index];

    // Parse the statements
    program_node->Program_data.statements = parse_statements(ctx, i);

    // update the children nodes
    for (int64_t j = 0; j < program_node->Program_data.statements.len; j++) {
        int64_t statement_index = program_node->Program_data.statements.data[j];
        Node_t* statement_node = &ctx->nodes.data[statement_index];
        statement_node->parent_i= index;
        statement_node->scope_depth = program_node->scope_depth;
        statement_node->scope_owner_i= program_node->scope_owner_i;
        statement_node->root_distance = program_node->root_distance + 1;
    }

    return index;
}

void parse_file(Transpiler_ctx_t* ctx) {
    // create a cursor
    int64_t i = 0;

    int64_t _ = parse_program(ctx, &i);
};