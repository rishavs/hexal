import std/[strutils, strformat, times, options, sequtils, times]

type
    Parser* = proc(): string
    
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
        

# We don't need the parsers to return anything other than a true. only in case of failure do we need to return a full error object
proc parse* (code: string) : void =

    var remaining   = code
    var line        = 1
    var pos         = 0
    var allLines    : seq[string]
    var errors      : seq[ParseError]

    # should err always return true? that way we may get free backtracking?
    proc curse(str: string) : Parser =
        return (
            proc(): string =
                var err = ParseError(
                    kind: "SyntaxError", 
                    expected: "", 
                    actual: "", 
                    message: str, 
                    line: line, 
                    pos: pos, 
                    startPos: pos, 
                    endPos: pos
                )

                errors.add err
                return ""
        )

    proc c(c: char) : Parser  =
        return (
            proc(): string =
                if c == '\n':
                    inc line
                
                if c == remaining[pos]:
                    inc pos
                    return $c
                else:
                    return ""

        )
    proc `~`(c: char) : Parser  =
        return (
            proc(): string =
                var res : string

                while true:
                    if c == '\n':
                        inc line
                    
                    if c == remaining[pos]:
                        return res
                    else:
                        inc pos
                        res.add c
        )
    
    proc `&` (lp: Parser, rp: Parser): Parser =
        return (
            proc(): string =
                var lpOut = lp()
                if lpOut.len == 0:
                    return ""
                else:
                    var rpOut = rp()
                    if rpOut.len == 0:
                        return ""
                    else:
                        return lpOut & rpOut
        )

    proc `|` (lp: Parser, rp: Parser): Parser =
        return (
            proc(): string =
                var lpOut = lp()
                if lpOut.len > 0:
                    return lpOut
                else:
                    var rpOut = rp()
                    if rpOut.len > 0:
                        return rpOut
                    else:
                        return ""
        )


    # Zero or Many - always true
    proc `*` (p: Parser) : Parser =
        return (
            proc(): string =
                while true:
                    var res : string
                    var pOut = p()
                    if pOut.len == 0:
                        return res
                    else:
                        res.add pOut

        )

    # One or Many - fails when zero
    proc `+` (p: Parser) : Parser =
        return (
            proc(): string =
                var atLeastOne = false
                while true:
                    var res : string
                    var pOut = p()
                    if pOut.len > 0:
                        atLeastOne = true
                        res.add pOut
                    else:
                        if atLeastOne:
                            return res
                        else:
                            return ""
        )

    # Zero or One - always true.
    proc `?` (p: Parser) : Parser =
        return (
            proc(): string =
                var pOut = p()
                if pOut.len > 0:
                    return pOut
                else:
                    return ""
        )


    remaining = """
const  x   = " something.!"
    """
    echo "starting string = ", remaining
    let ws = + c(' ')
    let var_kwd = c('v') & c('a') & c('r') & ws
    let const_kwd = c('c') & c('o') & c('n') & c('s') & c('t') & ws
    let declr = var_kwd | const_kwd | curse ("Missing declaration")
    let str = c('"') & ~('"') & c('"')
    let chk = ws & ? declr & c('x') & ws & c('=') & ws & str
    echo chk()
    echo "ending string = ", remaining[pos.. ^1]
    let test = c('c') & c('o') & c('n') & c('s') & c('t')
    echo test()
    echo errors
    

  