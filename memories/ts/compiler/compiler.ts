

// scope = {
//     "Root" : {
//         "ident1<Int>": true,
//         "ident1<String>": true,
//         "ident2<": {
//             "block1": {
//                 "ident3": true
//             }
//         }
//     }
// }

import { start } from "repl";

// [Root, ident1<Int>, [ident2<(Int, String) -> String>, [ident<Int>, Ident4:String, Ident5:String] ]  ]

// for a scope, is the statement complete?

enum Tokens {
    // Special
    EOC, ILLEGAL, IMPORT, EXPORT, NEWLINE, SPACE, WS,

    // names
    IDENT,
    // statement starters
    CONST, VAR, TYPE, SHOW,
    
    // builtin types
    INT_LIT, DEC_LIT, BOOL_LIT, STR_LIT, CHAR_LIT, 
    
    // builtin values
    TRUE, FALSE,

    // Operatrors
    ASSIGN, EQUALS, NOT, OR, AND, 
    PLUS, MINUS, MULT, DIV,
    COMMA, COLON, 
    SQ_BRACKET_START, SQ_BRACKET_END, CL_BRACKET_START, CL_BRACKET_END,
    SIN_QUOTE, BACKTICK, TRIPTICK,
}

type Token = {
    kind: Tokens
    value: string
    startPos: number
};

class PrimalObj {

}

// Compiler takes in a Hexal code string, some options and returns the LLVMIR string
function compile(code : string, debug? : boolean, godMode? : boolean): string {
    var i = 0
    var line = 1
    const startTime = Date.now()

    var currentScope: string[] = ["]ROOT["]
    var symbols : string[]
    var prevToken : Token
    var currToken : Token
    var nextToken : Token

    var output = ""

    function getNextToken(): Token {
        var n = code.charCodeAt(i)
        var c = code.charAt(i)
        var t : Token = {
            kind: Tokens.ILLEGAL,
            value: "",
            startPos: i
        }

        switch (true) {

        // ------------------------------
        // Handle end of code
        // ------------------------------
        case i >= code.length:
            t.kind = Tokens.EOC
            return t

        // ------------------------------
        // Handle whitespace
        // ------------------------------
        case code.startsWith("\n", i):
            t.kind = Tokens.WS
            line += 1
            i += 1
            return t
        case code.startsWith(" ", i):
            t.kind = Tokens.WS
            i += 1
            return t
        case code.startsWith("\t", i):
            t.kind = Tokens.WS
            i += 1
            return t

        // ------------------------------
        // Handle Operators
        // ------------------------------
        case code.startsWith("==", i):
            t.kind = Tokens.EQUALS
            t.value = "=="
            i += t.value.length
            return t
        case code.startsWith("=", i):
            t.kind = Tokens.ASSIGN
            t.value = "="
            i += t.value.length
            return t
        case code.startsWith(":", i):
            t.kind = Tokens.COLON
            t.value = ":"
            i += t.value.length
            return t


        // ------------------------------
        // Handle keywords
        // ------------------------------
        case code.startsWith("true", i):
            t.kind = Tokens.TRUE
            t.value = "true"
            i += t.value.length
            return t
        case code.startsWith("false", i):
            t.kind = Tokens.FALSE
            t.value = "false"
            i += t.value.length
            return t
        case code.startsWith("var ", i):
            t.kind = Tokens.VAR
            t.value = "var "
            i += t.value.length
            return t
        case code.startsWith("const ", i):
            t.kind = Tokens.CONST
            t.value = "const "
            i += t.value.length
            return t
        case code.startsWith("type", i):
            t.kind = Tokens.TYPE
            t.value = "type"
            i += t.value.length
            return t

        // ------------------------------
        // Handle builtin types & values
        // ------------------------------            
        case code.startsWith("IntLit", i):
            t.kind = Tokens.INT_LIT
            t.value = "IntLit"
            i += t.value.length
            return t
        case code.startsWith("DecLit", i):
            t.kind = Tokens.DEC_LIT
            t.value = "DecLit"
            i += t.value.length
            return t
        case code.startsWith("BoolLit", i):
            t.kind = Tokens.BOOL_LIT
            t.value = "BoolLit"
            i += t.value.length
            return t
        case code.startsWith("StrLit", i):
            t.kind = Tokens.STR_LIT
            t.value = "StrLit"
            i += t.value.length
            return t
        case code.startsWith("CharLit", i):
            t.kind = Tokens.CHAR_LIT
            t.value = "CharLit"
            i += t.value.length
            return t

        // ------------------------------
        // Handle numbers greedily 
        // ------------------------------
        case n > 47 && n < 58:
            var val = ""
            var decPointPresent = false
            t.kind = Tokens.INT_LIT

            loop: while (true) {
                n = code.charCodeAt(i)
                c = code.charAt(i)

                if ((n > 47 && n < 58) || c == '_') {
                    val += c
                    i += 1
                } else if (c == '.'){
                    if (decPointPresent){
                        t.value = val
                        return t
                    } else {
                        val += c
                        i += 1
                        decPointPresent = true
                        t.kind = Tokens.DEC_LIT
                    }
                } else {
                    t.value = val
                    return t
                }
            }
            
        // ------------------------------
        // Handle Identifiers greedily
        // Starts with letter. followed by alphanum or '_'
        // ------------------------------
        case  (n > 64 && n < 91) || (n > 96 && n < 123):
            var val = ""
            t.kind = Tokens.IDENT

            loop: while (true) {
                n = code.charCodeAt(i)
                c = code.charAt(i)

                if ((n > 64 && n < 91) || (n > 96 && n < 123) || ( n > 47 && n < 58) || c == '_') {
                    val += c
                    i += 1
                } else {
                    t.value = val
                    break loop

                    // TODO check against Keywrods
                }
            }
            return t
            
        
        // ------------------------------
        // If nothing matched, return illegal
        // ------------------------------
        default:
            i += 1
            return t
        }
    }
    function peepNextToken () {}

    function advanceToken() {
        prevToken = currToken
        currToken = nextToken
        nextToken = getNextToken()
    }

    // function addStatement () {
    //     if 
    // }

    // resync on error

    // Parse till scope ends
    function parseDeclarationStatement(isVar: boolean) {}
    function parseFunctionStatement() {}

    function parseExpressions() {}

    // parse till scope ends
    function parseBlock (isRootScope?: boolean) {
        var t = getNextToken()
        outer: while ( t.kind != Tokens.EOC) {
            switch (t.kind) {
                case Tokens.VAR:
                    var isVar = true
                    parseDeclarationStatement(isVar)

                case Tokens.CONST:
                    var isVar = false
                    parseDeclarationStatement(isVar)

                // Not allowed in blocks. how to deliniate export from root block?
                case Tokens.IMPORT, Tokens.EXPORT:
                    if (!isRootScope) {
                        console.log("Import & Export not allowed in Blocks")
                    }

                case Tokens.ILLEGAL:
                    console.log("ITS ILLEAGLE")

                default:
                    console.log("Need token which can start statements. Not puny token")
            } 



            nextToken = getNextToken()
    
    
    
        }
    }

    // parseImports()
    // parseBlock()
    // parseExports()


    // Temp code. lexer
    var n : Token
    do {
        n = getNextToken()
        if (n.kind != Tokens.WS) { console.log(Tokens[n.kind] , " => ", n)}
    } while (n.kind != Tokens.EOC)

    console.log("Time Taken =", Date.now() - startTime, "ms")
    return output

}

compile(`var   x_y21: DecLit 
= 123.456_78`)
