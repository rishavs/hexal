import std/[strutils, strformat, times, options, sequtils, times]

type
    Parser* = proc(): bool
    
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
            proc(): bool =
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

                errors.add(err)
                return true
        )

    proc eof() : Parser  =
        return (
            proc(): bool =
                if pos > remaining.len :
                    return true
                else:
                    return false

        )
    proc c(c: char) : Parser  =
        return (
            proc(): bool =
                if c == '\n':
                    inc line
                
                if c == remaining[pos]:
                    inc pos
                    return true
                else:
                    return false

        )
    proc `~`(c: char) : Parser  =
        return (
            proc(): bool =
                while true:
                    if c == '\n':
                        inc line
                    
                    if c == remaining[pos]:
                        return true
                    else:
                        inc pos
        )
    
    proc `&` (lp: Parser, rp: Parser): Parser =
        return (
            proc(): bool =
                if lp() and rp():
                    return true
                else:
                    return false
        )

    proc `|` (lp: Parser, rp: Parser): Parser =
        return (
            proc(): bool =
                if lp() or rp():
                    return true
                else:
                    return false
        )


    # Zero or Many - always true
    proc `*` (p: Parser) : Parser =
        return (
            proc(): bool =
                while true:
                    if not p():
                        return true
        )

    # One or Many - fails when zero
    proc `+` (p: Parser) : Parser =
        return (
            proc(): bool =
                var atLeastOne = false
                while true:
                    if p():
                        atLeastOne = true
                    else:
                        if atLeastOne:
                            return true
                        else:
                            return false
        )

    # Zero or One - always true.
    proc `?` (p: Parser) : Parser =
        return (
            proc(): bool =
                if p():
                    return true
                else:
                    return true
        )


    remaining = """
    conQst  x   = " something.!"
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
    echo errors
    

  