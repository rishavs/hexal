#ifndef DYN_STRING_H
#define DYN_STRING_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>

typedef struct {
    char* data;
    int64_t len;
    int64_t capacity;
} Dyn_string_t;
typedef Dyn_string_t* Ref_to_Dyn_string_t; 

Dyn_string_t dyn_string_do_init(char* string_literal);

#endif // DYN_STRING_H