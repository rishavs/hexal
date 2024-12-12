#ifndef HEXAL_RESOURCES_H
#define HEXAL_RESOURCES_H

// TODO - add verification step to ensure that the number of resources in the enum matches the number of resources in the string array
typedef enum {
    // special content
    RES_PROBLEM_AT,
    RES_INTERNAL_PERROR,
    RES_INTERNAL_LOCATION,

    RES_IS_FATAL,
    RES_IS_ERROR,
    // RES_IS_WARNING,
    // RES_IS_NOTE,

    // Error Categories
    RES_MEMORY_FAILURE_CAT,
    RES_UNHANDLED_ERROR_CAT,
    RES_SYNTAX_ERROR_CAT,

    // Memory Allocation Failure
    RES_MEMORY_FAILURE_MSG,
    
    // Unhandled Failures
    RES_UNHANDLED_ERROR_MSG,
    RES_UNHANDLED_ERROR_NOTE,
    
    // Error messages
    RES_ILLEGAL_CHAR_MSG,
    RES_UNCLOSED_DELIMITER_MSG,

    RES_STATEMENT,
    RES_EXPRESSION,
    RES_IDENTIFIER,
    RES_EXPECTED,
    RES_FOUND_X,
    RES_REACHED_EOS,
    
    RES_RESOURCE_COUNT // This helps to keep track of the number of error resources
} Error_resource;

// Generate the string array using the macro
static const char* en_us[RES_RESOURCE_COUNT] = {
    [RES_PROBLEM_AT]            = "Problem at %zu:%zu in the file \"%s\"",
    [RES_INTERNAL_PERROR]       = "Internal Note",
    [RES_INTERNAL_LOCATION]     = "Internal Note: Failed in the compiler code at line %zu in the file \"%s\"",
    
    [RES_IS_FATAL]              = "[ FATAL ]",
    [RES_IS_ERROR]              = "[ ERROR ]",

    [RES_MEMORY_FAILURE_CAT]    = "Memory Failure!",
    [RES_UNHANDLED_ERROR_CAT]   = "Unhandled Failure!",
    [RES_SYNTAX_ERROR_CAT]      = "Malformed Syntax!",

    [RES_MEMORY_FAILURE_MSG]    = "Failed to allocate dmemory during compilation",
    [RES_UNHANDLED_ERROR_MSG]   = "This is likely not a bug in your code, but in the compiler! Please report with minimal reproducible code.",
    
    [RES_ILLEGAL_CHAR_MSG]      = "Found illegal character \"%c\", ",
    [RES_UNCLOSED_DELIMITER_MSG] = "Expected the delimiter \"%s\" to get closed, but instead reached end of source.",

    [RES_STATEMENT]             = "statement",
    [RES_EXPRESSION]            = "expression",
    [RES_IDENTIFIER]            = "identifier",

    [RES_EXPECTED]              = "Expected %s, ",
    [RES_FOUND_X]               = "but found \"%s\". ",
    [RES_REACHED_EOS]           = "but instead reached end of source.",

};

#endif // HEXAL_RESOURCES_H