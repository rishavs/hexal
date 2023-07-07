package compiler

import (
	"fmt"
	"hexal/compiler/lexer"
	"hexal/compiler/parser"
	"log"
	"os"
)

func CompileFile(filepath string) {
	src, err := os.ReadFile(filepath)
	if err != nil {
		log.Fatalf("unable to read file: %v", err)
	}
	tokens := lexer.LexFile(src)
	fmt.Println("Tokens:\n", tokens)

	ast, errors := parser.ParseFile(tokens)
	fmt.Println("AST:\n", ast)
	parser.PrintAST(ast, 0)

	fmt.Println("Errors:\n:", errors)
}
