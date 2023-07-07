type Tokens =
//Special
| 'EOC' | 'ILLEGAL' | 'IMPORT' | 'EXPORT' | 'WS'
// names
| 'IDENT'
// statement'starters
| 'CONST' | 'VAR' | 'TYPE' | 'SHOW' 
// builtin'types
| 'INT_LIT' | 'DEC_LIT' | 'BOOL_LIT' | 'STR_LIT' | 'CHAR_LIT'
// builtin'values
| 'TRUE' | 'FALSE'  
// Operatrors
| 'ASSIGN' | 'EQUALS' | 'NOT' | 'OR' | 'AND'
| 'PLUS' | 'MINUS' | 'MULT' | 'DIV' 
| 'COMMA' | 'COLON'
| 'SQ_BRACKET_START' | 'SQ_BRACKET_END' | 'CL_BRACKET_START' | 'CL_BRACKET_END' 
| 'SIN_QUOTE' | 'BACKTICK' | 'TRIPTICK' 


export type Token = {
    kind: Tokens
    value: string
    i: number
    line: number
}

export type LexOutput = {
    tokens: Token[],
    lexTime : number
    i: number
    line: number
}

export function lex(code: string): LexOutput {
    const startTime = Date.now()
    
    var output: Token[] = []
    var line = 1
    var i = 0

    while (i < code.length) {
        var n = code.charCodeAt(i)
        var c = code.charAt(i)
        var t : Token = {
            kind: "ILLEGAL",
            value: "",
            i: i,
            line: line
        }

        switch (true) {
        // ------------------------------
        // Handle whitespace
        // ------------------------------
        case code.startsWith("\n", i):
            line += 1
            i += 1
            break
        case code.startsWith(" ", i):
            t.kind = "WS"
            i += 1
            break
        case code.startsWith("\t", i):
            t.kind = "WS"
            i += 1
            break

        // ------------------------------
        // Handle Operators
        // ------------------------------
        case code.startsWith("==", i):
            i += 2
            output.push ({
                kind: "EQUALS",
                value: "==",
                i : i,
                line : line,
            })
            break
        case code.startsWith("=", i):
            i += 1
            output.push ({
                kind: "ASSIGN",
                value: "=",
                i : i,
                line : line,
            })
            break
        case code.startsWith(":", i):
            i += 1
            output.push ({
                kind: "COLON",
                value: ":",
                i : i,
                line : line,
            })
            break

        // ------------------------------
        // Handle keywords
        // ------------------------------
        case code.startsWith("true", i):
            i += 4
            output.push ({
                kind: "TRUE",
                value: "true",
                i : i,
                line : line,
            })
            break
        case code.startsWith("false", i):
            i += 5
            output.push ({
                kind: "FALSE",
                value: "false",
                i : i,
                line : line,
            })
            break
        case code.startsWith("var ", i):
            i += 4
            output.push ({
                kind: "VAR",
                value: "var ",
                i : i,
                line : line,
            })
            break
        case code.startsWith("const ", i):
            i += 5
            output.push ({
                kind: "CONST",
                value: "const ",
                i : i,
                line : line,
            })
            break
        case code.startsWith("type", i):
            i += 4
            output.push ({
                kind: "TYPE",
                value: "type ",
                i : i,
                line : line,
            })
            break

        // ------------------------------
        // Handle builtin types & values
        // ------------------------------            
        case code.startsWith("IntLit", i):
            i += 6
            output.push ({
                kind: "INT_LIT",
                value: "IntLit",
                i : i,
                line : line,
            })
            break
        case code.startsWith("DecLit", i):
            i += 6
            output.push ({
                kind: "DEC_LIT",
                value: "DecLit",
                i : i,
                line : line,
            })
            break
        case code.startsWith("BoolLit", i):
            i += 7
            output.push ({
                kind: "BOOL_LIT",
                value: "BoolLit",
                i : i,
                line : line,
            })
            break
        case code.startsWith("StrLit", i):
            i += 6
            output.push ({
                kind: "STR_LIT",
                value: "StrLit",
                i : i,
                line : line,
            })
            break
        case code.startsWith("CharLit", i):
            i += 7
            output.push ({
                kind: "CHAR_LIT",
                value: "CharLit",
                i : i,
                line : line,
            })
            break

        // ------------------------------
        // Handle numbers greedily 
        // ------------------------------
        case n > 47 && n < 58:
            var val = ""
            var decPointPresent = false
            var t: Token = {
                kind: "INT_LIT",
                value: "CharLit",
                i : i,
                line : line,
            }

            while (true) {
                n = code.charCodeAt(i)
                c = code.charAt(i)

                if (n > 47 && n < 58) {
                    val += c
                    i += 1
                } else if ( c == '_') {
                    i += 1
                } else if (c == '.'){
                    if (decPointPresent){
                        output.push ({
                            kind : decPointPresent ? "DEC_LIT" : "INT_LIT",
                            value : val,
                            i : i,
                            line : line
                        })
                        break
                    } else {
                        val += c
                        i += 1
                        decPointPresent = true
                    }
                } else {
                    output.push ({
                        kind : decPointPresent ? "DEC_LIT" : "INT_LIT",
                        value : val,
                        i : i,
                        line : line
                    })
                    break
                }
            }
            break
            
        // ------------------------------
        // Handle Identifiers greedily
        // Starts with letter. followed by alphanum or '_'
        // ------------------------------
        case  (n > 64 && n < 91) || (n > 96 && n < 123):
            var val = ""
            var t: Token = {
                kind: "IDENT",
                value: "",
                i : i,
                line : line,
            }

            while (true) {
                n = code.charCodeAt(i)
                c = code.charAt(i)

                if ((n > 64 && n < 91) || (n > 96 && n < 123) || ( n > 47 && n < 58) || c == '_') {
                    val += c
                    i += 1
                } else {
                    output.push ({
                        kind : "IDENT",
                        value : val,
                        i : i,
                        line : line
                    })
                    break

                    // TODO check against Keywrods
                }
            }
            break
            
        
        // ------------------------------
        // If nothing matched, return illegal
        // ------------------------------
        default:
            i += 1
            output.push ({
                kind : "ILLEGAL",
                value : c,
                i : i,
                line : line
            })
            break
        }
    }

    output.push ({
        kind: "EOC",
        value: "",
        i : i,
        line : line,
    })

    return {
        tokens: output, 
        lexTime : Date.now() - startTime,
        i: i,
        line: line
    }
}


