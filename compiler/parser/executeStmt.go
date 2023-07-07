package parser

import "fmt"

func (ctx *ParsingContext) parseExecuteStmt() HxNode {
	var res = HxNode{false, "EXEC_STMT", "", 0, ctx.Tokens[ctx.Pos].Pos, ctx.Tokens[ctx.Pos].Line, nil}
	var expr = ctx.parseExpressions()
	fmt.Println("parseExecuteStmt: expr = ", expr)
	if expr.Resolved {
		res.Resolved = true
		res.Children = append(res.Children, expr)
	} else {
		panic("Expected expression for Exec statement.")
	}

	return res
}
