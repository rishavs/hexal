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
    str.capacity = str.len + 1;
    str.data = calloc(str.capacity, sizeof(char));
    if (str.data == NULL) memory_allocation_failure(0, 0, NULL, __FILE__, __LINE__);

    strncpy(str.data, string_literal, str.len);
    str.data[str.len] = '\0';

    return str;
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
Dyn_string_t dyn_string_do_format (Dyn_string_t base_string, ...) {
    va_list args;

    // get the length of the formatted string
    va_start(args, base_string);
    size_t len = vsnprintf(NULL, 0, base_string.data, args) + 1;
    va_end(args);

    // allocate memory for the formatted string
    char* buffer = calloc(len, sizeof(char));
    if (buffer == NULL) memory_allocation_failure(0, 0, NULL, __FILE__, __LINE__);

    // format the string
    va_start(args, base_string);
    vsnprintf(buffer, len, base_string.data, args);
    va_end(args);

    Dyn_string_t formatted_string;
    formatted_string.len = len - 1;
    formatted_string.capacity = len;
    formatted_string.data = buffer;

    return formatted_string;
}

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
        Dyn_string_t empty_string = { .data = NULL, .len = 0, .capacity = 0 };
        return empty_string;
    }

    va_list args;
    va_start(args, n);

    size_t total_len = 0;
    for (int i = 0; i < n; i++) {
        Dyn_string_t str = va_arg(args, Dyn_string_t);
        if (str.data != NULL) {
            total_len += str.len;
        }
    }
    va_end(args);

    char* buffer = calloc(total_len + 1, sizeof(char));
    if (buffer == NULL) memory_allocation_failure(0, 0, NULL, __FILE__, __LINE__);

    va_start(args, n);
    for (int i = 0; i < n; i++) {
        Dyn_string_t str = va_arg(args, Dyn_string_t);
        if (str.data != NULL) {
            strncat(buffer, str.data, str.len);
        }
    }
    va_end(args);

    Dyn_string_t result = { .data = buffer, .len = total_len, .capacity = total_len + 1 };
    return result;
}

//     va_list args;

//     // get the length of the formatted string
//     va_start(args, base_string);
//     size_t len = vsnprintf(NULL, 0, base_string->data, args) + 1;
//     va_end(args);

//     // allocate memory for the formatted string
//     char* buffer = calloc(len, sizeof(char));
//     if (buffer == NULL) memory_allocation_failure(0, 0, NULL, __FILE__, __LINE__);

//     // format the string
//     va_start(args, base_string);
//     vsnprintf(buffer, len, base_string->data, args);
//     va_end(args);

//     Dyn_string_t* formatted_string = calloc(1, sizeof(Dyn_string_t));
//     if (formatted_string == NULL) memory_allocation_failure(0, 0, NULL, __FILE__, __LINE__);

//     formatted_string->len = len - 1;
//     formatted_string->capacity = len;
//     formatted_string->data = buffer;

//     return formatted_string;
// }
    

// Dyn_string_t* dyn_string_do_push(Dyn_string_t* str, char* frag) {
//     size_t frag_len = strlen(frag);
//     if (str->len + frag_len >= str->capacity) {
//         str->capacity *= 2;
//         str->data = realloc(str->data, str->capacity * sizeof(char));
//         if (str->data == NULL) {
//             perror("Failed to reallocate memory for string");
//             exit(EXIT_FAILURE);
//         }
//     }

//     strncpy(str->data + str->len, frag, frag_len);
//     str->len += frag_len;
//     str->data[str->len] = '\0';

//     return str->data;
// }

// bool string_starts_with(char *src, size_t src_len, size_t i,  char* frag) {
//     size_t frag_len = strlen(frag);
//     if (i + frag_len > src_len) { return false; }
//     for (size_t j = 0; j < frag_len; j++) {
//         if (src[i + j] != frag[j]) { return false; }
//     }
//     return true;
// }

// char* get_substring(char* src, size_t pos, size_t len) {
//     if (src == NULL) return NULL;

//     char* buffer = calloc(len + 1, sizeof(char));
//     if (buffer == NULL) return NULL;
    
//     strncpy(buffer, src + pos, len);
//     buffer[len] = '\0';
//     return buffer;
// }

// char* join_strings(int n, ...) {
//     if (n == 0) return NULL;

//     va_list args;
//     va_start(args, n);

//     size_t total_len = 0;
//     for (int i = 0; i < n; i++) {
//         char* str = va_arg(args, char*);
//         if (str != NULL) {
//             total_len += strlen(str);
//         }
//     }
//     va_end(args);

//     char* buffer = calloc(total_len + 1, sizeof(char));
//     if (buffer == NULL) {
//         perror("Failed to allocate memory");
//         return NULL;
//     }

//     va_start(args, n);
//     for (int i = 0; i < n; i++) {
//         char* str = va_arg(args, char*);
//         if (str != NULL) {
//             strcat(buffer, str);
//         }
//     }
//     va_end(args);

//     return buffer;
// }
// // char* result = join_strings(3, "Hello, ", "World", "!");
// // if (result != NULL) {
// //     printf("%s\n", result);
// //     free(result);
// // }

// char* get_duration(clock_t start, clock_t end) {
//     double duration = ((double)(end - start))/CLOCKS_PER_SEC; // in seconds

//     int minutes = (int)duration / 60;
//     int seconds = (int)duration % 60;
//     int milliseconds = ((int)(duration * 1000)) % 1000;
//     int microseconds = ((int)(duration * 1000000)) % 1000;

//     char *formatted_duration = malloc(100 * sizeof(char));
//     if (formatted_duration == NULL) {
//         perror("Failed to allocate memory for formatted_duration");
//         exit(EXIT_FAILURE);
//     }

//     snprintf(formatted_duration, 100, "%dm %ds %dms %dus", 
//              minutes, seconds, milliseconds, microseconds);

//     return formatted_duration;
// }

// // wrap sprintf to return the string
// char* build_string (const char* format, ...) {
//     va_list args;
//     va_start(args, format);

//     // get the length of the formatted string
//     size_t len = vsnprintf(NULL, 0, format, args) + 1;
//     va_end(args);

//     // allocate memory for the formatted string
//     char* buffer = calloc(len, sizeof(char));
//     if (buffer == NULL) {
//         perror("Failed to allocate memory for buffer");
//         exit(EXIT_FAILURE);
//     }

//     // format the string
//     va_start(args, format);
//     vsnprintf(buffer, len, format, args);
//     va_end(args);

//     return buffer;
// }
