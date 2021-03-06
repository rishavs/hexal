import std/[strutils, strformat, times, options, sequtils]

var source* : string

type 
    Parser =
        proc(): Option[string]

    ParseObj = object
        isSuccessful    : bool
        parsed          : string
    
    ParseError* = object
        kind*           : string
        expected*       : string
        actual*         : string
        message*        : string
        line*           : int
        pos*            : int
        startPos*       : int
        endPos*         : int
        curLineNum*     : int
        curLineText*    : string
        prevLineNum*    : int
        prevLineText*   : string
        lastLineNum*    : int
        lastLineText*   : string

    CompilerMetadata* = object
        parseDuration*  : Duration
        linesCompiled*  : int

    NodeKind = enum  # the different node types
        nkInt,          # a leaf with an integer value
        nkFloat,        # a leaf with a float value
        nkString,       # a leaf with a string value
        nkAdd,          # an addition
        nkSub,          # a subtraction
        nkIf            # an if statement

    Node = ref object
        case kind: NodeKind  # the `kind` field is the discriminator
        of nkInt: 
            intVal: int
        of nkFloat: 
            floatVal: float
        of nkString: 
            strVal: string
        of nkAdd, nkSub:
            leftOp, rightOp: Node
        of nkIf:
            condition, thenPart, elsePart: Node
    # var n = Node(kind: nkFloat, floatVal: 1.0)
    NodeObj = object 
        kind*: string
        args*: seq[string]
        children*: seq[NodeObj]
 
  

# We don't need the parsers to return anything other than a true. only in case of failure do we need to return a full error object
proc parse* (code: string) : void =

    # start timer
    let parseStartTime = getTime()

    var remaining   = code
    var line        = 1
    var pos         = 0
    var errors      : seq[ParseError]

    proc curse(errmsg : string) : Parser =
        return (
            proc(): Option[string] =
                var err = ParseError(
                    kind: "SyntaxError", 
                    expected: "", 
                    actual: "", 
                    message: errmsg, 
                    line: line, 
                    pos: pos, 
                    startPos: pos, 
                    endPos: pos
                )

                errors.add err

                none(string)
        )
    proc eos() : Parser =
        return (
            proc(): Option[string] =
                if pos == remaining.len - 1: 
                    echo "FOUND EOF"
                    return some("EOF")
                else:
                    echo "Did not find EOF"
                    return none(string)
        )

    proc c(c: char) : Parser  =
        return (
            proc(): Option[string] =
                if pos < remaining.len and remaining[pos] == c:
                    if remaining[pos] == '\n': inc line
                    inc pos
                    return some($c)
                else:
                    return none(string)

                # if remaining[pos] == c:
                #     echo "Matched ", $c, " with ", remaining[pos] , " at pos ", pos
                #     if pos < remaining.len: 
                #         echo "incrementing pos"
                #         inc pos
                #     else:
                #         return none(string)
                #     return some($c)
                # else:
                #     return none(string)
        )
        
    # NOT - Anything but the given parser - always true.
    proc anythingButC(c: char) : Parser  =
        return (
            proc(): Option[string] =
                var res: string
                while true:
                    if remaining[pos] == c:
                        return some(res)
                    else:
                        res.add remaining[pos]
                        inc pos

        )

    
    proc `|` (lp: Parser, rp: Parser) : Parser =
        return (
            proc(): Option[string] =
                let lpOut = lp()
                if lpOut.isSome():
                    return lpOut
                else:
                    let rpOut = rp()
                    if rpOut.isSome():
                        return rpOut
                    else:
                        return none(string)
        )

    proc `&` (lp: Parser, rp: Parser) : Parser =
        return (
            proc(): Option[string] =
                let lpOut = lp()
                if lpOut.isNone():
                    return none(string)
                else:
                    let rpOut = rp()
                    if rpOut.isNone():
                        return none(string)
                    else:
                        return some(lpOut.get() & rpOut.get())
        )

    # P1 - P2        # matches P1 if P2 does not match
    proc `-` (lp: Parser, rp: Parser) : Parser =
        return (
            proc(): Option[string] =
                let rpOut = rp()
                if rpOut.isSome:
                    # echo "Right side was successful. This is wrong."
                    return none(string)
                else:
                    let lpOut = lp()
                    if lpOut.isSome():
                        # echo "left side was successful"
                        return lpOut
                    else:
                        # echo "both sides were unsuccessful"
                        return none(string)

        )

    # Zero or more repetitions of the given parser - always return success
    proc `*` (p: Parser) : Parser =
        return (
            proc(): Option[string] =
                var res: string
                while true:
                    let pOut = p()
                    if pOut.isSome():
                        # echo "* received ", pOut.get()
                        res.add pOut.get()
                        # echo "* has res: ", res
                    else:
                        break
                return some(res)
        )

    # One or more repetitions of the given parser - if zero instances of succes, it returns failure. Esle returns success
    proc `+` (p: Parser) : Parser =
        return (
            proc(): Option[string] =
                var res: string
                var atLeastOne = false

                while true:
                    let pOut = p()
                    if pOut.isSome:
                        atLeastOne = true
                        res.add pOut.get()
                    else:
                        break
                if atLeastOne:
                    return some(res)
                else:
                    return none(string)
        )

    # Zero or One - always true.
    proc `?` (p: Parser) : Parser =
        return (
            proc(): Option[string] =
                let pOut = p()
                if pOut.isSome():
                    return pOut
                else:
                    return none(string)
        )
    
    #  Not-predicate: !P
    # The pattern !P returns a pattern that matches only if the input does not match P. In contrast to most other patterns, this pattern does not consume any input.
    proc `!` (p: Parser) : Parser =
        return (
            proc(): Option[string] =
                let pOut = p()
                if pOut.isNone():
                    return some("")
                else:
                    return none(string)
        )

    let space = c(' ') | c('\t') | c('\r')
    let ws = space | c('\n')

    let lowerChar = c('a') | c('b') | c('c') | c('d') | c('e') | c('f') | c('g') | c('h') | c('i') | c('j') | c('k') | c('l') | c('m') | c('n') | c('o') | c('p') | c('q') | c('r') | c('s') | c('t') | c('u') | c('v') | c('w') | c('x') | c('y') | c('z')

    let upperChar = c('A') | c('B') | c('C') | c('D') | c('E') | c('F') | c('G') | c('H') | c('I') | c('J') | c('K') | c('L') | c('M') | c('N') | c('O') | c('P') | c('Q') | c('R') | c('S') | c('T') | c('U') | c('V') | c('W') | c('X') | c('Y') | c('Z')

    let alphabet = lowerChar | upperChar

    let digit = c('0') | c('1') | c('2') | c('3') | c('4') | c('5') | c('6') | c('7') | c('8') | c('9')
    let nonZeroDigit = c('1') | c('2') | c('3') | c('4') | c('5') | c('6') | c('7') | c('8') | c('9')

    let alphanum = alphabet | digit

    let trueKwd = c('t') & c('r') & c('u') & c('e')
    let falseKwd = c('f') & c('a') & c('l') & c('s') & c('e')

    let boolDef =  trueKwd | falseKwd
    let intDef = ?c('-') & nonZeroDigit & * (digit | c('_'))
    let decDef = ?c('-') & digit & * (digit | c('_')) & c('.') & * (digit | c('_'))

    let literals = intDef | boolDef

    let equalTok = c('=') & *ws
    let colonTok = c(':') & *ws
    let orTok = c('|') & *ws


    let varKwd = c('v') & c('a') & c('r') & +ws
    let constKwd = c('c') & c('o') & c('n') & c('s') & c('t') & +ws
    let intTypeKwd = c('I') & c('n') & c('t')
    let boolTypeKwd = c('B') & c('o') & c('o') & c('l')
    let decTypeKwd = c('D') & c('e') & c('c')
    let voidTypeKwd = c('D') & c('e') & c('c')
    let keywords = varKwd | constKwd | boolDef | intTypeKwd | boolTypeKwd | decTypeKwd

    let identifierRule = alphabet & *(alphanum | c('_'))
    let identifier = (identifierRule - keywords) & *ws
    let primitiveType =  boolTypeKwd | decTypeKwd | intTypeKwd
    let sumType = primitiveType & * (orTok & primitiveType)
    let typedIdentifier = identifier & colonTok & sumType

    let expression = literals | identifier

    let varDeclareAndAssign = varKwd & typedIdentifier & equalTok & expression
    let statement = varDeclareAndAssign #| varDeclaration | assignment

    let program = * statement 

    # var x = 1
    # const y = 2
    # var a, b, c = 1, 2, 3
    # var a : Int, b: Bool, c = 1, true, 3
    # var 
        # a, b, c : Int = 1, 2, 3
    # var 
        # a : Int,
        # b : String

    # var d: Int = 1
    # const e: Int = 1
    # let mutable x : Int = 1
    # let mutable str : String = mutable "Hello"
    # c, f - it is taking all keyward starting letters
    remaining = "vxe"
    pos = 0
    let resProg = identifier()
    if resProg.isSome():
        echo "Success"
        echo resProg.get()
    else:
        echo "Failure"
    echo "Ending string = ",  remaining[pos .. ^1]
    echo "----------------"

    remaining = "xconst"
    pos = 0
    let resIdent = identifier()
    if resIdent.isSome():
        echo "Success"
        echo resIdent.get()
    else:
        echo "Failure"
    echo "Ending string = ",  remaining[pos .. ^1]
    echo "----------------"




    remaining = "const  x = {something}"
    pos = 0
    echo "Starting string = ",  remaining
    let declr = varKwd | constKwd | curse("Expected variable or constant declaration")
    let blockStmts = c('{') & anythingButC('}') & c('}')
    let chk = declr & + c(' ') & c('x') & c(' ') & c('=') & c(' ') & blockStmts

    let res = chk()
    if res.isSome():
        echo "Success"
        echo res.get()
    else:
        echo "Failure"
    echo "Ending string = ",  remaining[pos .. ^1]
    echo "Time taken = ",  getTime() - parseStartTime
    echo "Errors = ",  errors
    echo "----------------"