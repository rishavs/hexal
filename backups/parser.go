package compiler

import (
	"bufio"
	"fmt"
	"os"
)

// parser takes in filepath and metadata struct as input and returns meta & err as output
func Parse(filepath string, m *ParsingMetaData) (*ParsingMetaData, error) {

	// Open the file for reading
	file, err := os.Open(filepath)
	if err != nil {
		fmt.Println("Error opening file:", err)
		return m, err
	}
	defer file.Close()

	// Create a new buffered reader and read the file character by character
	reader := bufio.NewReader(file)
	pos := 0
	line := 1
	lex := Lexer{pos, line, Token{}, Token{}, Token{}, reader}
	for {
		tok := lex.GetNextToken()
		fmt.Printf("{ type: %s, value: %q, pos: %d, line: %d }\n", tok.Type, tok.Value, tok.Pos, tok.Line)

		if tok.Type == "EOF" {
			break
		}
	}
	return m, nil
}
