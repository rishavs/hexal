#include <stdbool.h>
#include <stdint.h>

#include "resources.h"
#include "dyn_string.h"
#include "errors.h"
#include "transpiler.h"

void lex_file(Transpiler_ctx_t* ctx) {
    
    // Initialize the iterator
    char c = ctx->src.data[0];

    // Loop through the source code
    int64_t pos = 0;
    int64_t line = 0;
    while (pos < ctx->src.len && c != '\0') {
        c = ctx->src.data[pos];

        // Skip whitespace
        if (c == ' ' || c == '\t' || c == '\r' || c == '\n') {
            while (pos < ctx->src.len && c != '\0') {
                c = ctx->src.data[pos];
                if (c == ' ' || c == '\t' || c == '\r') {
                    pos++;
                } else if (c == '\n') {
                    pos++;
                    line++;
                } else {
                    break;
                }
            }


        // Handle operators and symbols
        } else if (dyn_string_do_starts_with(ctx->src, pos, dyn_string_do_init("="))) {
            int64_t _ = list_of_tokens_do_push(&ctx->tokens, (Token_t) {
                .kind = dyn_string_do_init("="),
                .value = dyn_string_do_init("="),
                .pos = pos,
                .line = line
            });
            // add_token_to_context(ctx, TOKEN_ASSIGN, pos, 1, line);
            pos++;
        
        // Handle identifiers
        } else if (
            (c >= 'a' && c <= 'z') || 
            (c >= 'A' && c <= 'Z') ||
            (c == '_')
        ) {
            int64_t anchor = pos;

            while (pos < ctx->src.len && c != '\0') {
                c = ctx->src.data[pos];
               if (
                    (c >= 'a' && c <= 'z') || 
                    (c >= 'A' && c <= 'Z') ||
                    (c == '_') ||
                    (c >= '0' && c <= '9')
                ) {
                    pos++; 
                } else {
                    break;
                }
            }

            Dyn_string_t value = dyn_string_do_get_substring(ctx->src, anchor, pos - anchor);

            if (dyn_string_do_compare(value, dyn_string_do_init("let"))) {
                int64_t _ = list_of_tokens_do_push(&ctx->tokens, (Token_t) {
                    .kind = dyn_string_do_init("let"),
                    .value = value,
                    .pos = anchor,
                    .line = line
                });
            } else {
                int64_t _ = list_of_tokens_do_push(&ctx->tokens, (Token_t) {
                    .kind = dyn_string_do_init("identifier"),
                    .value = value,
                    .pos = anchor,
                    .line = line
                });
            }
            // free(buffer);
        // Handle numbers
        } else if (c >= '0' && c <= '9') {
            bool is_decimal = false;
            int64_t anchor = pos;

            while (pos < ctx->src.len && c != '\0') {
                c = ctx->src.data[pos];

                if ((c >= '0' && c <= '9') || c == '.' || c == '_') {
                    if (c == '_') {
                        pos++;
                        continue;
                    }
                    if (c == '.') {
                        if (is_decimal) {
                            break;
                        } else {
                            is_decimal = true;
                        }
                    }
                } else {
                    break;
                }
                pos++;
            }
            int64_t _ = list_of_tokens_do_push(&ctx->tokens, (Token_t) {
                .kind = is_decimal ? dyn_string_do_init("decimal") : dyn_string_do_init("integer"),
                .value = dyn_string_do_get_substring(ctx->src, anchor, pos - anchor),
                .pos = anchor,
                .line = line
            });


        // Handle illegal characters
        } else {
            c = ctx->src.data[pos];
            Dyn_string_t cat = dyn_string_do_init(en_us[RES_SYNTAX_ERROR_CAT]);
            Dyn_string_t msg = dyn_string_do_join(3,
                dyn_string_do_init(en_us[RES_ILLEGAL_CHAR_MSG]), 
                dyn_string_do_get_substring(ctx->src, pos, 1),
                dyn_string_do_init("\". ")
            );
            printf("msg: %s\n", msg.data);
            list_of_errors_do_push(&ctx->errors, (Transpiler_error_t) {
                .category = cat,
                .msg = msg,
                .pos = pos,
                .line = line,
                .filepath = ctx->filepath,
                .transpiler_file = dyn_string_do_init(__FILE__),
                .transpiler_line = __LINE__
            });
            pos++;
        }
    }
    ctx->src.len = pos;
}