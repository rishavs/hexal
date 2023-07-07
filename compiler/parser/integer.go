package parser

func (ctx *ParsingContext) parseIntegerLiteral() HxNode {
	var res = HxNode{false, "INT_LIT", "", 0, ctx.Tokens[ctx.Pos].Pos, ctx.Tokens[ctx.Pos].Line, nil}
	if ctx.Tokens[ctx.Pos].Kind == "INT_LIT" {
		res.Resolved = true
		ctx.Pos++
	}
	return res
}
