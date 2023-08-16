package lexer

type HxToken struct {
	Kind  string
	Value string
	Pos   int
	Line  int
}

func isSpace(ch byte) bool {
	return ch == ' ' || ch == '\t' || ch == '\r'
}
func isLetter(ch byte) bool {
	return ch >= 'A' && ch <= 'Z' || ch >= 'a' && ch <= 'z'
}
func isDigit(ch byte) bool {
	return ch >= '0' && ch <= '9'
}
func isAlphaNumeric(ch byte) bool {
	return isLetter(ch) || isDigit(ch)
}
func matches(src *[]byte, i int, match string) bool {
	if len(*src) < i+len(match) {
		return false
	}
	for j := 0; j < len(match); j++ {
		if (*src)[i+j] != match[j] {
			return false
		}
	}
	return true
}

func LexFile(src []byte) []HxToken {
	var i = 0
	var line = 1
	var tokens []HxToken

	// stringOpenAt := -1
	// stringOpenLine := -1

	// var isCommentOpen = false
	// var commentOpenAt = 0
	// var commentOpenLine = 0

	for len(src) > i {

		// ----------------------------------------
		// Handle Spaces
		// ----------------------------------------
		if isSpace(src[i]) || src[i] == '\n' {
			i++
			for len(src) > i {
				if isSpace(src[i]) {
					i++
				} else if src[i] == '\n' {
					i++
					line++
				} else {
					break
				}
			}
			tokens = append(tokens, HxToken{"SPACE", "", i, line})
			// ----------------------------------------
			// Handle Comments
			// ----------------------------------------
		} else if matches(&src, i, "--") {
			tokens = append(tokens, HxToken{"COMMENT_START", "", i, line})
			i += 2
			for len(src) > i {
				if !matches(&src, i, "--") {
					i++
				} else {
					tokens = append(tokens, HxToken{"COMMENT_END", "", i, line})
					i += 2
					break
				}
			}

			// ----------------------------------------
			// Handle all Keywords
			// ----------------------------------------
		} else if matches(&src, i, "exec") {
			tokens = append(tokens, HxToken{"EXEC_KWD", "", i, line})
			i += 4
		} else if matches(&src, i, "var") {
			tokens = append(tokens, HxToken{"VAR_KWD", "", i, line})
			i += 3
		} else if matches(&src, i, "const") {
			tokens = append(tokens, HxToken{"CONST_KWD", "", i, line})
			i += 5
		} else if matches(&src, i, "show") {
			tokens = append(tokens, HxToken{"SHOW_KWD", "", i, line})
			i += 4
		} else if matches(&src, i, "true") {
			tokens = append(tokens, HxToken{"BOOL_LIT", "true", i, line})
			i += 4
		} else if matches(&src, i, "false") {
			tokens = append(tokens, HxToken{"BOOL_LIT", "false", i, line})
			i += 5
			// ----------------------------------------
			// Handle Operators
			// ----------------------------------------
		} else if matches(&src, i, "==") {
			tokens = append(tokens, HxToken{"EQUALS", "", i, line})
			i += 2
		} else if matches(&src, i, "=") {
			tokens = append(tokens, HxToken{"ASSIGN", "", i, line})
			i++
		} else if matches(&src, i, "!=") {
			tokens = append(tokens, HxToken{"NOT_EQUALS", "", i, line})
			i += 2
		} else if matches(&src, i, "!") {
			tokens = append(tokens, HxToken{"NOT_OPR", "", i, line})
			i++
		} else if matches(&src, i, "<=") {
			tokens = append(tokens, HxToken{"LESS_THAN_EQUALS", "", i, line})
			i += 2
		} else if matches(&src, i, "<") {
			tokens = append(tokens, HxToken{"LESS_THAN", "", i, line})
			i++
		} else if matches(&src, i, ">=") {
			tokens = append(tokens, HxToken{"GREATER_THAN_EQUALS", "", i, line})
			i += 2
		} else if matches(&src, i, ">") {
			tokens = append(tokens, HxToken{"GREATER_THAN", "", i, line})
			i++
		} else if matches(&src, i, "+=") {
			tokens = append(tokens, HxToken{"PLUS_EQUALS", "", i, line})
			i += 2
		} else if matches(&src, i, "+") {
			tokens = append(tokens, HxToken{"PLUS_OPR", "", i, line})
			i++
		} else if matches(&src, i, "-=") {
			tokens = append(tokens, HxToken{"MINUS_EQUALS", "", i, line})
			i += 2
		} else if matches(&src, i, "-") {
			tokens = append(tokens, HxToken{"MINUS_OPR", "", i, line})
			i++
		} else if matches(&src, i, "*=") {
			tokens = append(tokens, HxToken{"MULT_EQUALS", "", i, line})
			i += 2
		} else if matches(&src, i, "*") {
			tokens = append(tokens, HxToken{"MULT_OPR", "", i, line})
			i++

			// ----------------------------------------
			// Handle Literals - BYTES
			// ----------------------------------------
		} else if matches(&src, i, "'") {
			isByteTagOpen := true
			tokens = append(tokens, HxToken{"BYTE_START", "", i, line})
			buffer := []byte{}
			i++
			for len(src) > i && isByteTagOpen {
				if !matches(&src, i, "'") {
					buffer = append(buffer, src[i])
					i++
				} else {
					isByteTagOpen = false
					i++
					break
				}
			}
			tokens = append(tokens, HxToken{"BYTE_CONTENT", string(buffer), i, line})
			if !isByteTagOpen {
				tokens = append(tokens, HxToken{"BYTE_END", "", i, line})
			}

			// ----------------------------------------
			// Handle Literals - RAW STRINGS
			// ----------------------------------------
		} else if matches(&src, i, "`") {
			isStringOpen := true
			tokens = append(tokens, HxToken{"RAW_STRING_START", "", i, line})
			buffer := []byte{}
			i++
			for len(src) > i && isStringOpen {
				if !matches(&src, i, "`") {
					buffer = append(buffer, src[i])
					i++
				} else {
					isStringOpen = false
					i++
					break
				}

			}
			tokens = append(tokens, HxToken{"RAW_STRING_CONTENT", string(buffer), i, line})

			if !isStringOpen {
				tokens = append(tokens, HxToken{"RAW_STRING_END", "", i, line})
			}

			// ----------------------------------------
			// Handle Literals - HEXDECIMALS
			// ----------------------------------------
		} else if matches(&src, i, "0x") {
			buffer := []byte{src[i], src[i+1]}
			i += 2
			for len(src) > i {
				if isAlphaNumeric(src[i]) || src[i] == '_' {
					buffer = append(buffer, src[i])
					i++
				} else {
					break
				}
			}
			tokens = append(tokens, HxToken{"HEXLIT", string(buffer), i, line})
			// ----------------------------------------
			// Handle Literals - INTEGERS, FLOATS and EXPONENTIALS
			// ----------------------------------------
		} else if isDigit(src[i]) {
			buffer := []byte{src[i]}
			i++
			var isFloat = false
			var isExp = false

			for len(src) > i {
				if src[i] == '_' {
					i++
				} else if isDigit(src[i]) {
					buffer = append(buffer, src[i])
					i++
				} else if src[i] == '.' && !isFloat {
					isFloat = true
					buffer = append(buffer, src[i])
					i++
				} else if src[i] == 'e' && !isExp {
					isExp = true
					buffer = append(buffer, src[i])
					i++
					for len(src) > i {
						if isDigit(src[i]) {
							buffer = append(buffer, src[i])
							i++
						} else {
							break
						}
					}
				} else {
					break
				}
			}
			if isFloat {
				tokens = append(tokens, HxToken{"FLOAT_LIT", string(buffer), i, line})
			} else if isExp {
				tokens = append(tokens, HxToken{"EXP_LIT", string(buffer), i, line})
			} else {
				tokens = append(tokens, HxToken{"INT_LIT", string(buffer), i, line})
			}
			// ----------------------------------------
			// Handle Identifiers
			// ----------------------------------------
		} else if isLetter(src[i]) || src[i] == '_' {
			buffer := []byte{src[i]}
			i++
			for len(src) > i {
				if isLetter(src[i]) || isDigit(src[i]) || src[i] == '_' {
					buffer = append(buffer, src[i])
					i++
				} else {
					break
				}
			}
			tokens = append(tokens, HxToken{"IDENT", string(buffer), i, line})

			// ----------------------------------------
			// Handle ILLEGALS
			// ----------------------------------------
		} else {
			tokens = append(tokens, HxToken{"ILLEGAL", string(src[i]), i, line})
			i++
		}
	}
	tokens = append(tokens, HxToken{"EOF", "", i, line})
	return tokens
}
