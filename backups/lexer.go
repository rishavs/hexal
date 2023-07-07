package compiler

import (
	"io"
	"unicode"
)

func (l *Lexer) GetNextToken() Token {
	code, _, err := l.Reader.ReadRune()
	if err != nil {
		if err == io.EOF {
			return Token{TokensMap["EOF"], "", l.Pos, l.Line}
		} else {
			panic(err)
		}
	}
	l.Pos++
	if code == '\n' {
		l.Line++
	}

	switch {

	// Handle spaces. Roll up all spaces into one token
	case unicode.IsSpace(code):
		for { // Skip all spaces
			code, _, err = l.Reader.ReadRune()
			if err != nil {
				if err == io.EOF {
					return Token{TokensMap["EOF"], "", l.Pos, l.Line}
				} else {
					panic(err)
				}
			}
			if unicode.IsSpace(code) {
				l.Pos++
				if code == '\n' {
					l.Line++
				}
			} else {
				l.Reader.UnreadRune()
				break
			}
		}
		return Token{TokensMap["SPACE"], "", l.Pos, l.Line}

	// Handle keywords and identifiers
	case unicode.IsLetter(code):
		buffer := string(code)

		for {
			code, _, err = l.Reader.ReadRune()
			if err != nil {
				if err == io.EOF {
					return Token{TokensMap["EOF"], "", l.Pos, l.Line}
				} else {
					panic(err)
				}
			}
			if unicode.IsLetter(code) || unicode.IsDigit(code) || code == '_' {
				l.Pos++
				buffer += string(code)
			} else {
				l.Reader.UnreadRune()
				break
			}
		}

		switch buffer {
		case "var":
			return Token{TokensMap["VAR_KWD"], buffer, l.Pos, l.Line}
		case "const":
			return Token{TokensMap["CONST_KWD"], buffer, l.Pos, l.Line}
		case "true", "false":
			return Token{TokensMap["BOOL_LIT"], buffer, l.Pos, l.Line}
		case "if":
			return Token{TokensMap["IF_KWD"], buffer, l.Pos, l.Line}
		case "else":
			return Token{TokensMap["ELSE_KWD"], buffer, l.Pos, l.Line}
		case "Int":
			return Token{TokensMap["TYPE_INT_KWD"], buffer, l.Pos, l.Line}
		case "Float":
			return Token{TokensMap["TYPE_FLOAT_KWD"], buffer, l.Pos, l.Line}
		case "Bool":
			return Token{TokensMap["TYPE_BOOL_KWD"], buffer, l.Pos, l.Line}
		case "String":
			return Token{TokensMap["TYPE_STRING_KWD"], buffer, l.Pos, l.Line}
		default:
			return Token{TokensMap["IDENTIFIER"], buffer, l.Pos, l.Line}
		}

	// Handle numbers
	case unicode.IsDigit(code):
		isFloat := false
		buffer := string(code)

		for {
			code, _, err = l.Reader.ReadRune()
			if err != nil {
				if err == io.EOF {
					return Token{TokensMap["EOF"], "", l.Pos, l.Line}
				} else {
					panic(err)
				}
			}
			if unicode.IsDigit(code) || code == '_' || code == '.' {
				l.Pos++
				buffer += string(code)
				if code == '.' && !isFloat {
					isFloat = true
				} else if code == '.' && isFloat {
					break
				}
			} else {
				l.Reader.UnreadRune()
				break
			}
		}
		if isFloat {
			return Token{TokensMap["FLOAT_LIT"], buffer, l.Pos, l.Line}
		} else {
			return Token{TokensMap["INT_LIT"], buffer, l.Pos, l.Line}
		}

	// Handle infix operators with upto 2 char width
	case code == '+' || code == '-' || code == '*' || code == '/' || code == '%' || code == '<' || code == '>' || code == '!' || code == '=':
		buffer := string(code)

		for {
			code, _, err = l.Reader.ReadRune()
			if err != nil {
				if err == io.EOF {
					return Token{TokensMap["EOF"], "", l.Pos, l.Line}
				} else {
					panic(err)
				}
			}
			switch {
			case buffer == "=" && code == '=': // "=="
				l.Pos++
				buffer += string(code)
				return Token{TokensMap["EQUALS_INFIX_OPR"], buffer, l.Pos, l.Line}
			case buffer == "=" && code == '>': // "=>"
				l.Pos++
				buffer += string(code)
				return Token{TokensMap["FAT_ARROW"], buffer, l.Pos, l.Line}
			case buffer == "=" && code != '=': // "="
				l.Reader.UnreadRune()
				return Token{TokensMap["ASSIGN_INFIX_OPR"], buffer, l.Pos, l.Line}

			case buffer == "+" && code == '=': // "+="
				l.Pos++
				buffer += string(code)
				return Token{TokensMap["PLUS_EQUALS_INFIX_OPR"], buffer, l.Pos, l.Line}
			case buffer == "+" && code != '=': // "+"
				l.Reader.UnreadRune()
				return Token{TokensMap["PLUS_INFIX_OPR"], buffer, l.Pos, l.Line}

			case buffer == "-" && code == '=': // "-="
				l.Pos++
				buffer += string(code)
				return Token{TokensMap["MINUS_EQUALS_INFIX_OPR"], buffer, l.Pos, l.Line}
			case buffer == "-" && code == '>': // "->"
				l.Pos++
				buffer += string(code)
				return Token{TokensMap["ARROW"], buffer, l.Pos, l.Line}
			case buffer == "-" && code != '=': // "-"
				l.Reader.UnreadRune()
				return Token{TokensMap["MINUS_INFIX_OPR"], buffer, l.Pos, l.Line}

			case buffer == "*" && code == '=': // "*="
				l.Pos++
				buffer += string(code)
				return Token{TokensMap["MULTIPLY_EQUALS_INFIX_OPR"], buffer, l.Pos, l.Line}
			case buffer == "*" && code != '=': // "*"
				l.Reader.UnreadRune()
				return Token{TokensMap["MULTIPLY_INFIX_OPR"], buffer, l.Pos, l.Line}

			case buffer == "/" && code == '=': // "/="
				l.Pos++
				buffer += string(code)
				return Token{TokensMap["DIVIDE_EQUALS_INFIX_OPR"], buffer, l.Pos, l.Line}
			case buffer == "/" && code != '=': // "/"
				l.Reader.UnreadRune()
				return Token{TokensMap["DIVIDE_INFIX_OPR"], buffer, l.Pos, l.Line}

			case buffer == "%" && code == '=': // "%="
				l.Pos++
				buffer += string(code)
				return Token{TokensMap["MODULO_EQUALS_INFIX_OPR"], buffer, l.Pos, l.Line}

			case buffer == "%" && code != '=': // "%"
				l.Reader.UnreadRune()
				return Token{TokensMap["MODULO_INFIX_OPR"], buffer, l.Pos, l.Line}
			case buffer == "<" && code == '=': // "<="
				l.Pos++
				buffer += string(code)
				return Token{TokensMap["LESS_THAN_OR_EQUALS_INFIX_OPR"], buffer, l.Pos, l.Line}
			case buffer == "<" && code != '=': // "<"
				l.Reader.UnreadRune()
				return Token{TokensMap["LESS_THAN_INFIX_OPR"], buffer, l.Pos, l.Line}

			case buffer == ">" && code == '=': // ">="
				l.Pos++
				buffer += string(code)
				return Token{TokensMap["GREATER_THAN_OR_EQUALS_INFIX_OPR"], buffer, l.Pos, l.Line}
			case buffer == ">" && code != '=': // ">"
				l.Reader.UnreadRune()
				return Token{TokensMap["GREATER_THAN_INFIX_OPR"], buffer, l.Pos, l.Line}

			case buffer == "!" && code == '=': // "!="
				l.Pos++
				buffer += string(code)
				return Token{TokensMap["NOT_EQUALS_INFIX_OPR"], buffer, l.Pos, l.Line}
			case buffer == "!" && code != '=': // "!"
				l.Reader.UnreadRune()
				return Token{TokensMap["ILLEGAL"], buffer, l.Pos, l.Line}

			}
		}

	default:
		return Token{TokensMap["ILLEGAL"], string(code), l.Pos, l.Line}
	}
}
