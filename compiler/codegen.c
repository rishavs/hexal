#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#include "resources.h"
#include "errors.h"
#include "dyn_string.h"
#include "transpiler.h"

Dyn_string_t indent (Transpiler_ctx_t* ctx, int64_t* i) {
    Node_t* node = &ctx->nodes.data[*i];

    Dyn_string_t spaces = dyn_string_do_init("    ");

    Dyn_string_t indent;
    indent.len = node->scope_depth * 4 + 1; // 4 spaces per scope depth + null terminator
    indent.capacity = indent.len;
    indent.data = calloc(indent.capacity, sizeof(char));
    if (indent.data == NULL) memory_allocation_failure(node->pos, node->line, ctx->filepath.data, __FILE__, __LINE__);

    for (int64_t i = 0; i < node->scope_depth; i++) {
        indent = dyn_string_do_join(2, indent, spaces);
    }

    return indent;

}


Dyn_string_t gen_integer(Transpiler_ctx_t* ctx, int64_t* i) {
    Node_t* node = &ctx->nodes.data[*i];

    ctx->has_integer = true;
    return node->Integer_data.value;
}

Dyn_string_t gen_identifier(Transpiler_ctx_t* ctx, int64_t* i) {
    Node_t* node = &ctx->nodes.data[*i];

    return node->Identifier_data.value;
}

Dyn_string_t gen_expression(Transpiler_ctx_t* ctx, int64_t* i) {
    Node_t* node = &ctx->nodes.data[*i];

    if (dyn_string_do_compare(node->kind, dyn_string_do_init("integer"))) {
        return gen_integer(ctx, i);
    } else if (dyn_string_do_compare(node->kind, dyn_string_do_init("identifier"))) {
        return gen_identifier(ctx, i);
    }
    // Add more expression parsing logic here if needed
    

    unhandled_transpiler_error(ctx, *i, dyn_string_do_init(__FILE__), __LINE__);
    return dyn_string_do_init("");
}

Dyn_string_t gen_declaration(Transpiler_ctx_t* ctx, int64_t* i) {
    printf("Generating declaration\n");
    Node_t* node = &ctx->nodes.data[*i];
    int64_t identifier_index = node->Declaration_data.identifier_i;
    int64_t expression_index = node->Declaration_data.expression_i;

    Dyn_string_t identifier_str = gen_identifier(ctx, &identifier_index);
    Dyn_string_t expression_str = gen_expression(ctx, &expression_index);

    printf("Identifier: %s\n", identifier_str.data);
    printf("Expression: %s\n", expression_str.data);

    Dyn_string_t code = dyn_string_do_join(6,
        indent(ctx, i),
        dyn_string_do_init("int64_t "),
        identifier_str,
        dyn_string_do_init(" = "),
        expression_str,
        dyn_string_do_init(";\n")
    );

    printf("Declaration code: %s\n", code.data);

    return code;
}

Dyn_string_t gen_block(Transpiler_ctx_t* ctx, int64_t* i) {
    printf("Generating block\n");
    Node_t* node = &ctx->nodes.data[*i];
    printf("Block kind: %s\n", node->kind.data);
    List_of_ints_t statements = node->Block_data.statements;

    Dyn_string_t code = dyn_string_do_init("");

    int64_t statement_index;
    for (int64_t j = 0; j < statements.len; j++) {
        printf("Statement %lld\n", j);
        statement_index = statements.data[j];
        printf("Statement index: %lld\n", statement_index);
        if (statement_index >= ctx->nodes.len) {
            printf("Statement index out of bounds: %lld\n", statement_index);
        }

        printf("Statement kind: %s\n", ctx->nodes.data[statement_index].kind.data);

        if (dyn_string_do_compare(ctx->nodes.data[statement_index].kind, dyn_string_do_init("declaration"))) {
            code = dyn_string_do_join(2, code, gen_declaration(ctx, &statement_index));
        } else {
            unhandled_transpiler_error(ctx, statement_index, dyn_string_do_init(__FILE__), __LINE__);
            printf("Unhandled statement kind: %s\n", ctx->nodes.data[statement_index].kind.data);
        }
    }

    return code;
}

Dyn_string_t gen_program(Transpiler_ctx_t* ctx, int64_t* i) {
    Node_t* node = &ctx->nodes.data[*i];
    printf("Program kind: %s\n", node->kind.data);
    int64_t block_i = node->Program_data.block_i;

    printf("Block index: %lld\n", node->Program_data.block_i);

    Dyn_string_t code = gen_block(ctx, &block_i);

    return code;
}


Dyn_string_t gen_h_code(Transpiler_ctx_t* ctx, int64_t* i) {
    return dyn_string_do_init("");
}


Dyn_string_t gen_c_code(Transpiler_ctx_t* ctx, int64_t* i) {
    // Node_t* program = &ctx->nodes[0];

    Dyn_string_t imports = dyn_string_do_init("#include <stdlib.h>\n");
    if (ctx->has_integer) {
        imports = dyn_string_do_join(2, imports, "#include <stdint.h>\n");
    };

    Dyn_string_t code = dyn_string_do_join(4, 
        imports,
        dyn_string_do_init("int main() {\n"),
        gen_program(ctx, i),
        dyn_string_do_init("\n    return 0\n}")
    );

    return code;
}


void gen_code(Transpiler_ctx_t* ctx) {
    // reset cursor. Start from 1, as we don't need the program node
    int64_t i = 0;
    ctx->has_error = false;

    ctx->c_code = gen_c_code(ctx, &i);
    ctx->h_code = gen_h_code(ctx, &i);
}