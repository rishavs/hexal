#ifndef HEXAL_ERRORS_H
#define HEXAL_ERRORS_H

#include <stdlib.h>
#include <stdio.h>

#include "transpiler.h"

// Fatal failure. Memory allocation failed.
// Still uses char* instead of Dyn_string_t to avoid memory allocation
void memory_allocation_failure(int64_t pos, int64_t line, const char* filepath, char* transpiler_file, int64_t transpiler_line);



#endif // HEXAL_ERRORS_H