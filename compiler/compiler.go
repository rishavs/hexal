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

// colorReset := "\033[0m"

// colorRed := "\033[31m"
// colorGreen := "\033[32m"
// colorYellow := "\033[33m"
// colorBlue := "\033[34m"
// colorPurple := "\033[35m"
// colorCyan := "\033[36m"
// colorWhite := "\033[37m"

// fmt.Println(string(colorRed), "test")
// fmt.Println(string(colorGreen), "test")
// fmt.Println(string(colorYellow), "test")
// fmt.Println(string(colorBlue), "test")
// fmt.Println(string(colorPurple), "test")
// fmt.Println(string(colorWhite), "test")
// fmt.Println(string(colorCyan), "test", string(colorReset))
// fmt.Println("next")
