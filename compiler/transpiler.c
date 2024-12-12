
#include "transpiler.h"

void transpile_file(Transpiler_ctx_t* ctx){

    // create dummy output
    ctx->c_code = dyn_string_do_init("int main() {\n    return 0;\n}\n");
    ctx->h_file = dyn_string_do_init("#ifndef __TEST_H__\n#define __TEST_H__\n\n#endif\n");
    

    
}