package compiler

import (
	"bufio"
)

type TokenType int

const (
	TOK_EOF TokenType = iota
	TOK_ILLEGAL
	TOK_SPACE
	TOK_VAR_KWD
	TOK_CONST_KWD
	TOK_FUNC_KWD
	TOK_IF_KWD
	TOK_ELSE_KWD
	TOK_TYPE_BOOL_KWD
	TOK_TYPE_INT_KWD
	TOK_TYPE_FLOAT_KWD
	TOK_TYPE_STRING_KWD
	TOK_IDENTIFIER
	TOK_INT_LIT
	TOK_FLOAT_LIT
	TOK_BOOL_LIT
	TOK_ASSIGN_INFIX_OPR
	TOK_EQUALS_INFIX_OPR
)

type Token struct {
	Type  string
	Value string
	Pos   int
	Line  int
}

type Err struct {
	Msg  string
	Pos  int
	Line int
}

type ParsingMetaData struct {
	Errors      []Err
	Duration    float64
	CharsParsed int
}

type Lexer struct {
	Pos  int
	Line int

	CurrentToken Token
	PrevToken    Token
	NextToken    Token

	Reader *bufio.Reader
}

var TokensMap = map[string]string{
	// Special tokens
	"EOF":        "EOF",
	"ILLEGAL":    "ILLEGAL",
	"SPACE":      "SPACE",
	"FAT_ARROW":  "FAT_ARROW",
	"ARROW":      "ARROW",
	"IDENTIFIER": "IDENTIFIER",

	// Keywords
	"VAR_KWD":   "VAR_KWD",
	"CONST_KWD": "CONST_KWD",
	"FUNC_KWD":  "FUNC_KWD",
	"IF_KWD":    "IF_KWD",
	"ELSE_KWD":  "ELSE_KWD",

	// Types
	"TYPE_BOOL_KWD":   "TYPE_BOOL_KWD",
	"TYPE_INT_KWD":    "TYPE_INT_KWD",
	"TYPE_FLOAT_KWD":  "TYPE_FLOAT_KWD",
	"TYPE_STRING_KWD": "TYPE_STRING_KWD",

	// Literals
	"INT_LIT":   "INT_LIT",
	"FLOAT_LIT": "FLOAT_LIT",
	"BOOL_LIT":  "BOOL_LIT",

	// Operators
	"ASSIGN_INFIX_OPR": "ASSIGN_INFIX_OPR",

	"EQUALS_INFIX_OPR":                 "EQUALS_INFIX_OPR",
	"NOT_EQUALS_INFIX_OPR":             "NOT_EQUALS_INFIX_OPR",
	"LESS_THAN_INFIX_OPR":              "LESS_THAN_INFIX_OPR",
	"GREATER_THAN_INFIX_OPR":           "GREATER_THAN_INFIX_OPR",
	"LESS_THAN_OR_EQUALS_INFIX_OPR":    "LESS_THAN_OR_EQUALS_INFIX_OPR",
	"GREATER_THAN_OR_EQUALS_INFIX_OPR": "GREATER_THAN_OR_EQUALS_INFIX_OPR",

	"PLUS_INFIX_OPR":         "PLUS_INFIX_OPR",
	"MINUS_INFIX_OPR":        "MINUS_INFIX_OPR",
	"MULT_INFIX_OPR":         "MULT_INFIX_OPR",
	"DIV_INFIX_OPR":          "DIV_INFIX_OPR",
	"MOD_INFIX_OPR":          "MOD_INFIX_OPR",
	"AND_INFIX_OPR":          "AND_INFIX_OPR",
	"OR_INFIX_OPR":           "OR_INFIX_OPR",
	"PLUS_EQUALS_INFIX_OPR":  "PLUS_EQUALS_INFIX_OPR",
	"MINUS_EQUALS_INFIX_OPR": "MINUS_EQUALS_INFIX_OPR",
	"MULT_EQUALS_INFIX_OPR":  "MULT_EQUALS_INFIX_OPR",
	"DIV_EQUALS_INFIX_OPR":   "DIV_EQUALS_INFIX_OPR",
	"MOD_EQUALS_INFIX_OPR":   "MOD_EQUALS_INFIX_OPR",

	"NOT_PREFIX_OPR": "NOT_PREFIX_OPR",
	"NEG_PREFIX_OPR": "NEG_PREFIX_OPR",

	// Delimiters
	"LPAREN": "LPAREN",
	"RPAREN": "RPAREN",
	"LBRACE": "LBRACE",
	"RBRACE": "RBRACE",
	"LBRACK": "LBRACK",
	"RBRACK": "RBRACK",
	"COMMA":  "COMMA",
	"DOT":    "DOT",
	"COLON":  "COLON",
	"SEMIC":  "SEMIC",
}
