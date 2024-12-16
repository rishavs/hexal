#ifndef DYN_STRING_H
#define DYN_STRING_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdarg.h>

typedef struct {
    char* data;
    int64_t len;
    int64_t capacity;
} Dyn_string_t;
typedef Dyn_string_t* Ref_to_Dyn_string_t; 

Dyn_string_t dyn_string_do_init(char* string_literal);
Dyn_string_t dyn_string_do_get_substring(Dyn_string_t src, int64_t pos, int64_t len);
// Dyn_string_t dyn_string_do_format (Dyn_string_t base_string, ...);
bool dyn_string_do_compare (Dyn_string_t str1, Dyn_string_t str2);
bool dyn_string_do_starts_with(Dyn_string_t src, int64_t pos, Dyn_string_t frag);
Dyn_string_t dyn_string_do_join(int n, ...);
Dyn_string_t dyn_string_do_copy(Dyn_string_t src);

#endif // DYN_STRING_H