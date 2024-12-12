#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include "errors.h"
#include "resources.h"

// Memory allocaltion failed. Fatal failure.
void memory_allocation_failure(int64_t pos, int64_t line, char* filepath, char* transpiler_file, int64_t transpiler_line) {
    fprintf(stderr, "\033[0;31m%s %s ", en_us[RES_MEMORY_FAILURE_CAT], en_us[RES_MEMORY_FAILURE_MSG]);
    if (pos && line && filepath) { // memory failures need not be tied to user code
        fprintf(stderr, en_us[RES_PROBLEM_AT], pos, line, filepath);
    };   
    perror(en_us[RES_INTERNAL_PERROR]);
    fprintf(stderr, en_us[RES_INTERNAL_LOCATION], transpiler_line, transpiler_file);
    fprintf(stderr, "\n\033[0m");
    exit(EXIT_FAILURE);
}
