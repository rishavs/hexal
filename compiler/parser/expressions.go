package parser

func (ctx *ParsingContext) parseExpressions() HxNode {
	var res HxNode
	res.Resolved = false
	res.Kind = "EXPRESSION"

	var expr HxNode

	switch ctx.Tokens[ctx.Pos].Kind {
	case "SPACE":
		ctx.Pos++
	case "FLOAT_LIT":
		expr = ctx.parseFloatLiteral()
		if expr.Resolved {
			res.Resolved = true
			res.Children = append(res.Children, expr)
		}
	case "INT_LIT":
		res = ctx.parseIntegerLiteral()
		if expr.Resolved {
			res.Resolved = true
			res.Children = append(res.Children, expr)
		}
	case "BOOL_LIT":
		res = ctx.parseBooleanLiteral()
		if expr.Resolved {
			res.Resolved = true
			res.Children = append(res.Children, expr)
		}
	default:
		res.Resolved = false
	}
	return res
}
