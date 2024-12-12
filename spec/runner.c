#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdint.h>

#include "tests.h"

// Import the tests
#include "basic.test.c"

// Create an array of the tests
Test_Fun all_tests[] = {
    empty_failed_test,
    empty_passed_test,
    simple_var_declaration_as_int,

    // End of tests
    NULL
};


int main() {

    int64_t i = 0;
    int64_t passed_count = 0;

    printf("----------------------------------------------------\n");
    printf("Running Tests ...\n");
    printf("----------------------------------------------------\n");
    while (all_tests[i] != NULL) {
        Test_Result res = all_tests[i]();
        if (res.passed) {
            printf("\033[0;32m%lli: \t[ PASSED ]\t%s\n\033[0m", i, res.desc->data); // Green color for PASS
            passed_count++;
        } else {
            printf("\033[0;31m%lli:\t[ FAILED ]\t%s\n\033[0m", i, res.desc->data);
        }
        i++;
    }
    printf("----------------------------------------------------\n");
    printf("Total: %lli, Passed: %lli, Failed: %lli \n", i, passed_count, i-passed_count);
    return 0;
}
