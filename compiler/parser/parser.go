package parser

import (
	"fmt"
	"hexal/compiler/lexer"
)

type ParsingContext struct {
	Tokens []lexer.HxToken
	Errors []HxError

	Pos  int
	Line int
}

type HxNode struct {
	Resolved bool
	Kind     string
	Value    string
	Depth    int
	Pos      int
	Line     int
	Children []HxNode
}
type HxError struct {
	Kind string
	Msg  string
	Pos  int
	Line int
}

func ParseFile(tokens []lexer.HxToken) (HxNode, []HxError) {

	// var ast = HxNode{false, "MODULE", "", 0, 0, 1, nil}
	var errors []HxError
	// var i int

	ctx := ParsingContext{tokens, errors, 0, 1}

	ast := ctx.parseStatements()
	ast.Kind = "MODULE"
	fmt.Println("ParseFile: ast = ", ast)
	if !ast.Resolved {

		panic("Error in Compiler. This is the catchall error")
	}

	return ast, errors
}
