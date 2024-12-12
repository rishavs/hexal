#include <stdbool.h>
#include <string.h>

#include "dyn_string.h"
#include "errors.h"
#include "tests.h"
#include "transpiler.h"

// Null input
Test_Result empty_failed_test() {
    Test_Result res = { 
        .desc = dyn_string_do_init("empty failed test"),
        .passed = false 
    };

    return res;
}

Test_Result empty_passed_test() {
    Test_Result res = { 
        .desc = dyn_string_do_init("empty passed test"),
        .passed = false 
    };
    res.passed = true;

    return res;
}

Test_Result simple_var_declaration_as_int() {
    Test_Result res = { 
        .desc = dyn_string_do_init("simple var declaration as int"),
        .passed = false 
    };

    // Create a new transpiler context
    Transpiler_ctx_t* ctx = calloc(1, sizeof(Transpiler_ctx_t));
    if (ctx == NULL) memory_allocation_failure(0, 0, NULL, __FILE__, __LINE__);

    ctx->filepath = dyn_string_do_init("specs/basic.test.c");
    ctx->src = dyn_string_do_init("let x: Int = 10");

    // Transpile the source
    transpile_file(ctx);
    
    res.passed = true;

    return res;
}