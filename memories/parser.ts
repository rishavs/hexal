type nkLiteral = {
    litType: "Int" | "Float" | "Bool",
    value: string
}

type ParseState = {
    success: boolean,
    remaining: string,
    value: string[],
    seqCaptured: string[],
}

type ParseMetadata = {
    startingTime: Date,
    endingTime: Date,
    linesParsed: number,
}

// type Parser = (ps: ParseState) => ParseState

// Parser is a function which takes in a Parseing State and returns a Parsing State



// Parser Combinator function to match a string
function match(str: string): Parser {
    return (ps: ParseState): ParseState => {
        if (ps.remaining.length <= 0) { throw new Error (`Expected ${str} but reached EoF`)}

        if (ps.remaining.startsWith(str)) {
            ps.success = true
            ps.remaining = ps.remaining.substring(str.length)
            ps.value.push (str)
        } else {
            ps.success = false
        }
        return ps
    }
}

function eof(): Parser {
    return (ps: ParseState): ParseState => {
        if (ps.remaining.length != 0) {
            ps.success = false
        }
        return ps
    }
}
function eol(): Parser {
    return (ps: ParseState): ParseState => {
        if (ps.remaining.charCodeAt(0) == 10) {
            console.log("New Line detected!")
            ps.success = true
            ps.value.push ( ps.remaining[0] )
            ps.remaining = ps.remaining.substring(1)
        } else {
            ps.success = false
        }
        return ps
    }
}

// This one matches whitespace
function ws() {
    // SPACE (codepoint 32, U+0020)
    // TAB (codepoint 9, U+0009)
    // LINE FEED (codepoint 10, U+000A)
    // LINE TABULATION (codepoint 11, U+000B)
    // FORM FEED (codepoint 12, U+000C)
    // CARRIAGE RETURN (codepoint 13, U+000D)
    return (ps: ParseState): ParseState => {
        let char = ps.remaining[0]
        let charCode = ps.remaining.charCodeAt(0)
        if (charCode == 10) {
            console.log("New Line detected!")
            ps.success = true
            ps.remaining = ps.remaining.substring(1)
            ps.value.push (char)
        } else if (charCode == 9 || charCode == 11 || charCode == 12 || charCode == 13 || charCode == 32) {
            ps.success = true
            ps.remaining = ps.remaining.substring(1)
            ps.value.push (char)
        } else {
            ps.success = false
        }
        return ps
    } 
}

// function isLower

// function isUpper

// function isDigit

// function isAlphanum

// function isSpace



// function matchRange(start, end): Parser {
//     return  (ps: ParseState): ParseState => {
//         return {
//             success: false,
//             remaining: ps.remaining,
//             value: [""]
//         }
//     }
// }

// Function which mates a range of utf codes
// function matchRange (begin: number, end: number): Parser {
//     return (ps: ParseState): ParseState => {
//         if (ps.remaining.length > 0) {
//             let code = ps.remaining.charCodeAt(0)
//             if (code >= begin && code <= end) {
//                 return {
//                     success: true,
//                     remaining: ps.remaining.substring(1),
//                     value: [ps.remaining.substring(0, 1)]
//                 }
//             }
//         }
//         return {
//             success: false,
//             remaining: ps.remaining,
//             value: [""]
//         }
//     }
// }

function choice(...parsers: Parser[]): Parser {
    return (ps: ParseState): ParseState => {
        for (let p of parsers) {
            let parseResult = p(ps)
            if (parseResult.success) {
                break
            }
            ps = parseResult
        }
        return ps    
    }
}

// let ps.value.lentgth be stored
// later just slice from this position and add to the seqCaptured
// Parser Combinator function for a sequence of parsers
// function seq( capture?: boolean, ...parsers: Parser[]): Parser {
function seq( ...parsers: Parser[]): Parser {
    return (ps: ParseState): ParseState => {
        let initialParserState = ps
        // if (capture) { console.log ("Capture Set to True") }
        for (let p of parsers) {
            let parseResult = p(ps)
            if (parseResult.success) {
                ps = parseResult
            } else {
                return initialParserState
            }
        }
        return ps
    }
}

function zeroOrMany(p: Parser): Parser {
    return (ps: ParseState): ParseState => {
        while (true) {
            let parseResult = p(ps)
            if (parseResult.success) {
                ps = parseResult
            } else {
                break
            }
        }
        ps.success = true
        return ps
    }
}

function oneOrMany(p: Parser): Parser {
    return (ps: ParseState): ParseState => {
        var atleastOneSucceeds = false
        while (true) {
            let parseResult = p(ps)
            if (parseResult.success) {
                atleastOneSucceeds = true
                ps = parseResult
            } else {
                break
            }
        }
        ps.success = atleastOneSucceeds
        return ps
    }
}

// function discardAllUntil() -- use for multiline comments
// function captureUntilMatch()   -- use for string & multiline comments
// function captureUntilEoL()   -- use for string & multiline comments

function zeroOrOne(p: Parser): Parser {
    return (ps: ParseState): ParseState => {
        var parseResult = p(ps)
        parseResult.success = true
        return parseResult
    }
}


let initState = {
    success: false,
    remaining: `Hello 
World`,
    value: [],
    seqCaptured: []
}

// let test = match("Hell")
let test = seq( choice(match("Hi"), match("Hello")), eol(), match("World"), eof())
console.log("Input Text: ", initState.remaining)
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
