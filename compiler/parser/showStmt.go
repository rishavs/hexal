package parser

func (ctx *ParsingContext) parseShowStmt() HxNode {
	var res = HxNode{false, "SHOW_STMT", "", 0, ctx.Tokens[ctx.Pos].Pos, ctx.Tokens[ctx.Pos].Line, nil}
	var expr = ctx.parseExpressions()
	if expr.Resolved {
		res.Resolved = true
		res.Children = append(res.Children, expr)
	} else {
		panic("Expected expression for Show statement.")
	}

	return res
}
