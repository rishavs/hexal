package parser

func (ctx *ParsingContext) parseBooleanLiteral() HxNode {
	var res = HxNode{false, "BOOL_LIT", "", 0, ctx.Tokens[ctx.Pos].Pos, ctx.Tokens[ctx.Pos].Line, nil}
	if ctx.Tokens[ctx.Pos].Kind == "BOOL_LIT" {
		res.Resolved = true
		res.Value = ctx.Tokens[ctx.Pos].Value
		ctx.Pos++
	}
	return res
}
