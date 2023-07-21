package parser

func (ctx *ParsingContext) parseStatements() HxNode {
	var res HxNode
	var stmt HxNode

	// loopOverStatements:
	for ctx.Tokens[ctx.Pos].Kind != "EOF" {
		switch ctx.Tokens[ctx.Pos].Kind {
		case "SPACE":
			ctx.Pos++
		case "EXEC_KWD":
			ctx.Pos++
			stmt = ctx.parseExecuteStmt()
			if stmt.Resolved {
				res.Resolved = true
				res.Children = append(res.Children, stmt)
			}
		case "SHOW_KWD":
			ctx.Pos++
			stmt = ctx.parseShowStmt()
			if stmt.Resolved {
				res.Resolved = true
				res.Children = append(res.Children, stmt)
			}
		case "VAR_KWD":
			ctx.Pos++
			stmt = ctx.parseVarDeclrStmt()
			if stmt.Resolved {
				res.Resolved = true
				res.Children = append(res.Children, stmt)
			}
		default:
			panic("Unexpected token. Expected Statement.")
		}

		// Add check here. All statements should end with space or EOF
	}
	return res
}