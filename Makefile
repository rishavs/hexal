# Variables
COMPILER = gcc
HEADERS_FOLDER = include
OUTPUT_EXECUTABLE = bin/hexal
TEST_EXECUTABLE = bin/test
MAIN_FILE = hexal.c
TEST_FILE = spec/runner.c
COMPILER_FLAGS = \
	# -fno-omit-frame-pointer \
	# -fsanitize=address \
	# -fsanitize=leak \
	# -fsanitize=bounds-strict 

COMPILER_WARNINGS = -Wall -Wextra -Wno-unused-variable -Wno-unused-parameter
INCLUDES = -I$(HEADERS_FOLDER)

SOURCE_FILES = \
	compiler/errors.c \
	compiler/types/dyn_string.c \
	compiler/lexer.c \
	compiler/parser.c \
	compiler/codegen.c \
	compiler/transpiler.c
# 	src/transpiler/helpers.c \
# 	src/transpiler/context.c \
# 	src/transpiler/lexer.c	\
# 	src/transpiler/parser.c	\
# 	src/transpiler/codegen.c	\
# 	src/transpiler/transpiler.c \
# 	src/transpiler/presenter.c 

# Default target
all: build

# Build target
build:
	$(COMPILER) $(COMPILER_WARNINGS) $(COMPILER_FLAGS) $(INCLUDES) $(MAIN_FILE) $(SOURCE_FILES) -o $(OUTPUT_EXECUTABLE)

# Run target
run: build
	./bin/pixel run tests/inputs/third.pix

# Test target
test: 
	@cmd /c cls
	@$(COMPILER) $(COMPILER_WARNINGS) $(COMPILER_FLAGS) $(INCLUDES) $(TEST_FILE) $(SOURCE_FILES) -o ./bin/test.exe
	@./bin/test.exe

# Clean target
clean:
	rm -f $(OUTPUT_EXECUTABLE) test