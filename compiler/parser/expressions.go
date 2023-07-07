package parser

func (ctx *ParsingContext) parseExpressions() HxNode {
	var res HxNode

loopOverExpressions:
	for ctx.Pos < len(ctx.Tokens) {
		switch ctx.Tokens[ctx.Pos].Kind {
		case "SPACE":
			ctx.Pos++
		case "INT_LIT":
			res = ctx.parseIntegerLiteral()
			if res.Resolved {
				return res
			}
		case "BOOL_LIT":
			res = ctx.parseBooleanLiteral()
			if res.Resolved {
				return res
			}
		default:
			res.Resolved = false
			break loopOverExpressions
		}
	}
	return res
}
