#ifndef HEXAL_TESTS_H
#define HEXAL_TESTS_H

#include <stdbool.h>

#include "dyn_string.h"

typedef struct Test_Result {
    Dyn_string_t* desc;
    bool passed;
} Test_Result;

// Define the function pointer type
typedef Test_Result (*Test_Fun)();

#endif // HEXAL_TESTS_H
