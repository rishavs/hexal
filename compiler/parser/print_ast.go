package parser

import (
	"fmt"
	"strings"
)

func PrintAST(ast HxNode, depth int) {
	fmt.Print(ast.Kind, " Resolved: ", ast.Resolved, " Value :", ast.Value, " Depth: ", ast.Depth, " Pos: ", ast.Pos, " Line: ", ast.Line, "\n")
	for i, _ := range ast.Children {
		fmt.Printf("%s|-- ", strings.Repeat("\t", depth))
		PrintAST(ast.Children[i], depth+1)
	}
}

// false PROGRAM  0 0 1
// 	|-- true EXEC_STMT  0 0 1
// 		|--	true BOOL_LIT false 0 5 1
