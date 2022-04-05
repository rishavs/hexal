console.log("Hello")

type NodeKind = "number" | "string" | "identifier" | "operator" | "paren" | "comma" | "semicolon" | "assign" | "plus" | "minus" | "multiply" | "divide" | "modulo" | "eof"

type KindOfNode = "VariableDeclaration" | "Assignment" 


// AST Node
type ASTNode = {
    kind: KindOfNode,
    value: string,
    children : ASTNode[],
    
}



type ParseState = {
    success: boolean,
    remaining: string,
    value: string
}

type Parser = (ps: ParseState) => ParseState

// Parser is a function which takes in a Parseing State and returns a Parsing State

// Parser Combinator function to match a string
function match(str: string): Parser {
    return (ps: ParseState): ParseState => {
        if (ps.remaining.startsWith(str)) {
            return {
                success: true,
                remaining: ps.remaining.substring(str.length),
                value: str
            }
        } else {
            return {
                success: false,
                remaining: ps.remaining,
                value: ""
            }
        }
    }
}

// Parser Combinator function for a sequence of parsers
function seq(...parsers: Parser[]): Parser {
    return (ps: ParseState): ParseState => {
        let remaining = ps.remaining
        let value = ""
        for (let p of parsers) {
            let result = p(remaining)
            if (result.success) {
                remaining = result.remaining
                value += result.value
            } else {
                return {
                    success: false,
                    remaining: remaining,
                    value: ""
                }
            }
        }
        return {
            success: true,
            remaining: remaining,
            value: value
        }
    }
}







let initState = {
    success: true,
    remaining: "Hsello World",
    value: ""
}

let test = match("Hell")
console.log(test(initState))


// # Rod AST node types

// type
//     NodeKind* = enum
//         nkEmpty
//         nkScript, nkBlock
//         nkBool, nkNumber, nkString, nkIdent
//         nkPrefix, nkInfix, nkDot, nkIndex
//         nkVar, nkLet
//         nkIf, nkWhile, nkFor
//         nkBreak, nkContinue
//         nkCall
//         nkGeneric
//         nkObject, nkObjFields, nkObjConstr
//     Node* = ref object
//         ln*, col*: int
//         file*: string
//         case kind*: NodeKind
//         of nkEmpty: discard
//         of nkBool:
//             boolVal*: bool
//         of nkNumber:
//             numberVal*: float
//         of nkString:
//             stringVal*: string
//         of nkIdent:
//             ident*: string
//         else:
//             children*: seq[Node]

// type
//     ParseStack = seq[Node]
