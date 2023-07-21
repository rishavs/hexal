package parser

func (ctx *ParsingContext) parseIdentifier() HxNode {
	var res = HxNode{false, "IDENTIFIER", "", 0, ctx.Tokens[ctx.Pos].Pos, ctx.Tokens[ctx.Pos].Line, nil}

	if ctx.Tokens[ctx.Pos].Kind == "IDENT" {
		res.Resolved = true
		ctx.Pos++
	}
	return res
}
