#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <stdarg.h>
#include <stdint.h>

#include "errors.h"
#include "dyn_string.h"

// Only places where we use char* are in the Dyn_string... definitions
// and in the memory error handlers

// Create a new dynamic string using the given fragment
Dyn_string_t dyn_string_do_init(char* string_literal) {
    Dyn_string_t str;
    
    str.len = strlen(string_literal);
    str.capacity = str.len;
    str.data = calloc(str.capacity, sizeof(char));
    if (str.data == NULL) memory_allocation_failure(0, 0, NULL, __FILE__, __LINE__);

    strncpy(str.data, string_literal, str.len);
    str.data[str.len] = '\0';   // likely not required. just to be safe

    return str;
}

Dyn_string_t dyn_string_do_copy(Dyn_string_t src) {
    Dyn_string_t copy;
    copy.len = src.len;
    copy.capacity = src.len;
    copy.data = calloc(copy.capacity, sizeof(char));
    if (copy.data == NULL) memory_allocation_failure(0, 0, NULL, __FILE__, __LINE__);

    strncpy(copy.data, src.data, copy.len);
    copy.data[copy.len] = '\0';     // likely not required. just to be safe

    return copy;
}

// Get a substring from a string, gievn the position and length
Dyn_string_t dyn_string_do_get_substring(Dyn_string_t src, int64_t pos, int64_t len) {
    if (src.data == NULL) {
        Dyn_string_t empty_string = { .data = NULL, .len = 0, .capacity = 0 };
        return empty_string;
    }

    char* buffer = calloc(len + 1, sizeof(char));
    if (buffer == NULL) memory_allocation_failure(0, 0, NULL, __FILE__, __LINE__);

    strncpy(buffer, src.data + pos, len);
    buffer[len] = '\0';

    Dyn_string_t substring = { .data = buffer, .len = len, .capacity = len + 1 };
    return substring;
}

// Format a string using the given format and arguments
// Dyn_string_t dyn_string_do_format (Dyn_string_t base_string, ...) {
//     va_list args;

//     // get the length of the formatted string
//     va_start(args, base_string);
//     size_t len = vsnprintf(NULL, 0, base_string.data, args) + 1;
//     va_end(args);

//     // allocate memory for the formatted string
//     char* buffer = calloc(len, sizeof(char));
//     if (buffer == NULL) memory_allocation_failure(0, 0, NULL, __FILE__, __LINE__);

//     // format the string
//     va_start(args, base_string);
//     vsnprintf(buffer, len, base_string.data, args);
//     va_end(args);

//     Dyn_string_t formatted_string;
//     formatted_string.len = len - 1;
//     formatted_string.capacity = len;
//     formatted_string.data = buffer;

//     return formatted_string;
// }

// Compare two dynamic strings
bool dyn_string_do_compare (Dyn_string_t str1, Dyn_string_t str2) {
    if (str1.len != str2.len) return false;
    for (int i = 0; i < str1.len; i++) {
        if (str1.data[i] != str2.data[i]) return false;
    }
    return true;
}

// Check if a dynamic string starts with a given fragment
bool dyn_string_do_starts_with(Dyn_string_t src, int64_t pos, Dyn_string_t frag) {
    if (pos + frag.len > src.len) { return false; }
    for (int i = 0; i < frag.len; i++) {
        if (src.data[pos + i] != frag.data[i])  return false; 
    }
    return true;
}

// Join a list of strings
Dyn_string_t dyn_string_do_join(int n, ...) {
    if (n == 0) {
        return (Dyn_string_t){ .data = NULL, .len = 0, .capacity = 0 };
    }

    va_list args;
    va_start(args, n);

    // Calculate the total length of the concatenated string
    size_t total_len = 0;
    for (int i = 0; i < n; i++) {
        Dyn_string_t str = va_arg(args, Dyn_string_t);
        if (str.data != NULL && str.len > 0) {
            total_len += str.len;
        }
    }
    va_end(args);

    // Allocate memory for the result string
    char* buffer = calloc(total_len + 1, sizeof(char)); // +1 for the null-terminator
    if (buffer == NULL) memory_allocation_failure(0, 0, NULL, __FILE__, __LINE__);

    // Copy the strings into the buffer
    va_start(args, n);
    size_t offset = 0;
    for (int i = 0; i < n; i++) {
        Dyn_string_t str = va_arg(args, Dyn_string_t);
        if (str.data != NULL && str.len > 0) {
            memcpy(buffer + offset, str.data, str.len);
            offset += str.len;
        }
    }
    va_end(args);

    // Null-terminate the concatenated string
    buffer[total_len] = '\0';

    // Return the resulting dynamic string
    return (Dyn_string_t){ .data = buffer, .len = total_len, .capacity = total_len + 1 };
}

Dyn_string_t dyn_string_do_char_to_string (char c) {
    Dyn_string_t str;
    str.len = 2;
    str.capacity = 2;
    str.data = calloc(2, sizeof(char));
    if (str.data == NULL) memory_allocation_failure(0, 0, NULL, __FILE__, __LINE__);

    str.data[0] = c;
    str.data[1] = '\0';

    return str;
}

Dyn_string_t dyn_string_do_int_to_string (int64_t num) {
    char buffer[21]; // 1 char for -, 19 for int64 & 1 for null terminator
    snprintf(buffer, 21, "%lld", num);

    return dyn_string_do_init(buffer);
}

