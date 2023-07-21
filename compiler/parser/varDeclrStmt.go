package parser

import "fmt"

func (ctx *ParsingContext) parseVarDeclrStmt() HxNode {
	var res = HxNode{false, "VAR_DCLR_STMT", "", 0, ctx.Tokens[ctx.Pos].Pos, ctx.Tokens[ctx.Pos].Line, nil}
	if ctx.Tokens[ctx.Pos].Kind == "SPACE" {
		ctx.Pos++
	}
	var ident = ctx.parseIdentifier()
	if ctx.Tokens[ctx.Pos].Kind == "SPACE" {
		ctx.Pos++
	}
	if ctx.Tokens[ctx.Pos].Kind == "ASSIGN" {
		fmt.Println("parseVarDeclrStmt: ASSIGN")
		ctx.Pos++
	} else {
		panic("Expected assignment operator for VAR_DCLR_STMT statement.")
	}
	if ctx.Tokens[ctx.Pos].Kind == "SPACE" {
		ctx.Pos++
	}
	fmt.Println("Checking token for vardeclr expr: ", ctx.Tokens[ctx.Pos])
	var expr = ctx.parseExpressions()

	if expr.Resolved && ident.Resolved {
		res.Resolved = true
		res.Children = append(res.Children, ident)
		res.Children = append(res.Children, expr)

	} else {
		panic("Expected expression for VAR_DCLR_STMT statement.")
	}

	return res
}
