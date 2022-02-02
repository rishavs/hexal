import std/[strutils, strformat, times, options, sequtils]

var source* : string

type 
    Parser =
        proc(code:string): seq[string]

    IParser =
        proc(): Option[seq[string]]

    NodeKind = enum  # the different node types
        nkInt,          # a leaf with an integer value
        nkFloat,        # a leaf with a float value
        nkString,       # a leaf with a string value
        nkAdd,          # an addition
        nkSub,          # a subtraction
        nkIf            # an if statement

    Node = ref object
        case kind: NodeKind  # the `kind` field is the discriminator
        of nkInt: intVal: int
        of nkFloat: floatVal: float
        of nkString: strVal: string
        of nkAdd, nkSub:
            leftOp, rightOp: Node
        of nkIf:
            condition, thenPart, elsePart: Node
    # var n = Node(kind: nkFloat, floatVal: 1.0)
    NodeObj = object 
        kind*: string
        args*: seq[string]
        children*: seq[NodeObj]
 
    ParseObject = object
        success     : bool
        lines       : int
        pos         : int
        errors      : seq[string]
        remaining   : string
        output      : seq[string]

    ParseError* = object
        kind*       : string
        message*    : string
        hint*       : string
        value*      : string
        line*       : int
        filePos*    : int
        linePos*    : int
        uLineStartPos*    : int
        uLineEndPos*    : int
        line1Txt*   : string
        line2Txt*   : string
        line3Txt*   : string
        line4Txt*   : string
        line5Txt*   : string

    ParseErrors = seq[ParseError]

    CompilerMetadata* = object
        parseDuration*  : Duration
        linesCompiled*  : int

proc s(c: char) : Parser  =
    return (
        proc(code:string): seq[string] =
            var remaining = code
            var res = ""
            if remaining.startsWith c:
                remaining.removePrefix c
                res = $c

            return @[remaining, res]
    )

proc s(frag: string) : Parser  =
    return (
        proc(code:string): seq[string] =
            var remaining = code
            var res = ""
            if remaining.startsWith frag:
                remaining.removePrefix frag
                res = frag

            return @[remaining, res]
    )

proc `|` (l: Parser, r: Parser) : Parser =
    return (
        proc(code:string): seq[string] =
            var lOut = l(code)
            if lOut[0].len > 0:
                return lOut
            else:
                var rOut = r(code)
                if rOut[0].len > 0:
                    return rOut

            return @[code, ""]
    )

proc `&` (l: Parser, r: Parser) : Parser =
    return (
        proc(code:string): seq[string] =
            var lOut = l(code)
            if lOut[1].len == 0:
                echo "NOT Matched L"
                return @[code, ""]
            else:
                echo "Matched L"
                var rOut = r(lOut[0])
                if rOut[1].len == 0:
                    echo "Not Matched R"
                    return @[code, ""]
                else:
                    echo "Matched L & R"
                    return @[rOut[0], lOut[1], rOut[1]]
    )

proc yellError (nodeName: string) : Parser  =
    return (
        proc(code:string): seq[string] =
            return @[nodeName, "Error on node type XXX"]    )

proc parse* (code: string) : void =

    # start timer
    let parseStartTime = getTime()

    var remaining   = code
    var lines       = 0
    var pos         = 0
    var errors      : seq[ParseError]
    var output      : seq[string]

    proc s(c: char) : IParser  =
        return (
            proc(): Option[seq[string]] =
                if remaining.startsWith c:
                    echo fmt"Matched {c}"
                    remaining.delete(0..0)
                    inc pos
                    return some(@[$c])
                else:
                    return none(seq[string]) 
        )

    proc no(c: char) : IParser  =
        return (
            proc(): Option[seq[string]] =
                echo "NOT - Checking ", remaining[0]
                if remaining.startsWith c:
                    return none(seq[string]) 
                else:
                    echo $remaining[0], " is Not matched by ", $c
                    var res = $remaining[0]
                    remaining.delete(0..0)
                    inc pos
                    return some(@[res])
        )

    proc `|` (lSide: IParser, rSide: IParser) : IParser =
        return (
            proc(): Option[seq[string]] =
                var lOut: Option[seq[string]] = lSide()
                if lOut.isSome:
                    return lOut
                else:
                    var rOut: Option[seq[string]] = rSide()
                    if rOut.isSome:
                        return rOut

                return none(seq[string])
        )

    proc `&` (lSide: IParser, rSide: IParser) : IParser =
        return (
            proc(): Option[seq[string]] =
                var lOut = lSide()
                if lOut.isNone:
                    return none(seq[string])
                else:
                    var rOut = rSide()
                    if rOut.isNone:
                        return none(seq[string])
                    else:
                        return some (lOut.get & rOut.get)
        )
        
    # ZerOrMany
    proc `*` (p: IParser) : IParser =
        return (
            proc(): Option[seq[string]] =
                var vals: seq[string] = @[]
                while true:
                    result = p()
                    if result.isNone:
                        return some(vals)
                    else:
                        vals.add(result.get)           
        )

    # OneOrMany
    proc `+` (p: IParser) : IParser =
        return (
            proc(): Option[seq[string]] =
                var vals: seq[string] = @[]
                while true:
                    result = p()
                    if result.isNone:
                        if vals.len == 0:
                            return none(seq[string])
                        else:
                            return some(vals)
                    else:
                        vals.add(result.get)           
        )

    # ZeroOrOne
    # proc `?` (p: IParser) : IParser =
    #     return (
    #         proc(): Option[seq[string]] =
    #             var vals: seq[string] = @[]
    #             while true:
    #                 result = p()
    #                 if result.isNone:
    #                     if vals.len > 0:
    #                         return none(seq[string])
    #                     else:
    #                         return some(vals)
    #                 else:
    #                     vals.add(result.get)       
    #     )

    #  NOT Parser -  TODO? do this or stick with NOT char?
    # proc `!` (p: IParser) : IParser =
    #     return (
    #         proc(): Option[seq[string]] =
    #             var vals: seq[string] 
    #             while true:
    #                 result = p()
    #                 if result.isNone:
    #                     vals.add(result.get)     
    #                 else:
    #                     return some(vals)      
    #     )

    echo "about to parse"
    remaining = "constx = 1"
    let ws = *s(' ')
    let var_kwd = s('v') & s('a') & s('r') & ws
    let const_kwd = s('c') & s('o') & s('n') & s('s') & s('t') & ws 
    let comb = var_kwd | const_kwd
    echo comb().get
    echo pos, remaining

    remaining = "{ something goes in here } "
    let txt = s('{') & *(no('}')) & s('}')
    echo txt().get
    echo pos, remaining

    # remaining = "bar"
    # let chk0or1 = ?((s('f') & s('o') & s('o')) & s('b')) & s('a') & s('r')
    # echo chk0or1().get
    # echo pos, remaining

# let psa = s("xhe") | s("he")
# let psb = (s("xhe") | s("he")) & s("ll")
# var txt = "var x = 1"
# let VAR_DECL = s("var") & s(' ') & s('x') & s(' ') & s('=') & s(' ') & s('1')
# let CONST_DECL = s("const") & s(' ') & s('x') & s(' ') & s('=') & s(' ') & s('1')

# let parser = VAR_DECL | CONST_DECL

# echo psa(txt)
# echo VAR_DECL(txt)
# echo CONST_DECL(txt)
# echo parser(txt)
