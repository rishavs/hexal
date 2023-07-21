package parser

func (ctx *ParsingContext) parseFloatLiteral() HxNode {
	var res = HxNode{false, "FLOAT_LIT", "", 0, ctx.Tokens[ctx.Pos].Pos, ctx.Tokens[ctx.Pos].Line, nil}
	if ctx.Tokens[ctx.Pos].Kind == "FLOAT_LIT" {
		res.Resolved = true
		ctx.Pos++
	}
	return res
}
