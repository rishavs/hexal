import std/[strutils, strformat, times, options, sequtils, times]

var source* : string

type 
    ParseObject = object
        kind       : string
        isSuccessful: bool
        expected    : string
        actual      : string
        atPosition  : int
        atLine      : int

    Parser =
        proc(): ParseObject

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

# We don't need the parsers to return anything other than a true. only in case of failure do we need to return a full error object
proc parse* (code: string) : void =

    # start timer
    let parseStartTime = getTime()

    var remaining   = code
    var lines       = 0
    var pos         = 0
    var errors      : seq[ParseError]
    var output      : seq[string]

    proc eof() : Parser  =
        return (
            proc(): ParseObject =
                var pOut = ParseObject(
                    kind : "eof",
                    isSuccessful: false,
                    expected: "",
                )
                if remaining.len == pos:
                    pOut.isSuccessful = true
                    pOut.actual = "EOF"
                else:
                    pOut.actual = remaining[pos..^1]

                return pOut
        )

    proc s(c: char) : Parser  =
        return (
            proc(): ParseObject =
                # echo "starting = ", remaining[pos..^1]

                var newPos : int
                var pOut = ParseObject(
                    kind : "s-char",
                    isSuccessful: false,
                    expected: $c,
                    actual : "EOF",
                    atPosition: pos
                )
                if c == '\n':
                    inc lines

                if remaining.len > pos:

                    if remaining[pos] == c:
                        # echo fmt"Matched {c}"
                        inc pos

                        pOut.isSuccessful = true
                        pOut.actual = $c
                    else:
                        pOut.isSuccessful = false
                        pOut.actual = $remaining[pos]
                    # echo pOut
                    # echo "remaining = ", remaining[pos..^1]
                    # echo "----------------------"
                pOut.atPosition = pos
                pOut.atLine = lines
                return pOut
        )
    # proc s(frag: string) : Parser  =
    #     return (
    #         proc(): ParseObject =
    #             echo "starting = ", remaining[pos..^1]

    #             var newPos : int
    #             var pOut = ParseObject(
    #                 kind : "s-str",
    #                 isSuccessful: false,
    #                 expected: frag,
    #                 actual : "EOF"
    #             )
    #             if remaining.len > pos:
    #                 newPos = pos + frag.len
    #                 if remaining.continuesWith(frag, pos):
    #                     echo fmt"Matched {frag}"
    #                     pos = newPos

    #                     pOut.isSuccessful = true
    #                     pOut.actual = frag
    #                 else:
    #                     pOut.isSuccessful = false
    #                     pOut.actual = remaining[pos..newPos - 1]
    #                 echo pOut
    #                 echo "remaining = ", remaining[pos..^1]
    #                 echo "----------------------"
    #             return pOut
    #     )

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

    proc `|` (lSide: Parser, rSide: Parser) : Parser =
        return (
            proc(): ParseObject =
                var pOut = ParseObject(
                    kind : "|",
                    isSuccessful: false,
                )
                var lOut: ParseObject = lSide()
                if lOut.isSuccessful:
                    pOut.expected = lOut.expected
                    pOut.isSuccessful = true
                    pOut.actual.add lOut.actual
                else:
                    var rOut: ParseObject = rSide()
                    if rOut.isSuccessful:
                        pOut.expected = rOut.expected
                        pOut.isSuccessful = true
                        pOut.actual.add rOut.actual
                    else:
                        pOut.expected = lOut.expected & " | " & rOut.expected
                        pOut.isSuccessful = false
                        pOut.actual.add lOut.actual
                        pOut.atLine = lOut.atLine
                        pOut.atPosition = lOut.atPosition

                return pOut
        )

    proc `&` (lSide: Parser, rSide: Parser) : Parser =
        return (
            proc(): ParseObject =
                var pOut = ParseObject(
                    kind : "&",
                    isSuccessful: false,
                )
                var lOut: ParseObject = lSide()
                if not lOut.isSuccessful:
                    pOut.expected = lOut.expected
                    pOut.isSuccessful = false
                    pOut.actual.add lOut.actual
                    pOut.atLine = lOut.atLine
                    pOut.atPosition = lOut.atPosition

                else:
                    var rOut: ParseObject = rSide()
                    if not rOut.isSuccessful:
                        pOut.expected = rOut.expected
                        pOut.isSuccessful = false
                        pOut.actual.add rOut.actual
                        pOut.atLine = rOut.atLine
                        pOut.atPosition = rOut.atPosition
                    else:
                        pOut.isSuccessful = true
                        pOut.expected = lOut.expected & rOut.expected
                        pOut.actual.add lOut.actual & rOut.actual
                        
                return pOut

        )
    # proc `&` (lSide: IParser, rSide: IParser) : IParser =
    #     return (
    #         proc(): Option[seq[string]] =
    #             var lOut = lSide()
    #             if lOut.isNone:
    #                 return none(seq[string])
    #             else:
    #                 var rOut = rSide()
    #                 if rOut.isNone:
    #                     return none(seq[string])
    #                 else:
    #                     return some (lOut.get & rOut.get)
    #     )
        
    # ZerOrMany
    proc `*` (p: Parser) : Parser =
        return (
            proc(): ParseObject =
                var pOut = ParseObject(
                    kind : "*",
                    isSuccessful: false,
                )

                while true:
                    result = p()
                    if not result.isSuccessful:
                        pOut.isSuccessful = true
                        pOut.expected = " ZeroOrMany(" & $result.expected & ")"
                        return pOut
                    else:
                        pOut.actual.add(result.actual)      
        )
    # proc `*` (p: IParser) : IParser =
    #     return (
    #         proc(): Option[seq[string]] =
    #             var vals: seq[string] = @[]
    #             while true:
    #                 result = p()
    #                 if result.isNone:
    #                     return some(vals)
    #                 else:
    #                     vals.add(result.get)           
    #     )

    # OneOrMany
    proc `+` (p: Parser) : Parser =
        return (
            proc(): ParseObject =
                var pOut = ParseObject(
                    kind : "+",
                    isSuccessful: false,
                )
                var successCount = 0

                while true:
                    result = p()
                    pOut.expected = " OneOrMany(" & $result.expected & ")"
                    pOut.actual = $result.actual
                    if not result.isSuccessful:
                        if successCount == 0:
                            pOut.isSuccessful = false
                            return pOut
                        else:
                            pOut.isSuccessful = true
                            return pOut
                    else:
                        inc successCount
                        pOut.actual.add(result.actual)     
        )
    # proc `+` (p: IParser) : IParser =
    #     return (
    #         proc(): Option[seq[string]] =
    #             var vals: seq[string] = @[]
    #             while true:
    #                 result = p()
    #                 if result.isNone:
    #                     if vals.len == 0:
    #                         return none(seq[string])
    #                     else:
    #                         return some(vals)
    #                 else:
    #                     vals.add(result.get)           
    #     )

    # ZeroOrOne
    proc `?` (p: Parser) : Parser =
        return (
            proc(): ParseObject =
                var pOut = ParseObject(
                    kind: "?",
                    isSuccessful: false,
                )
                result = p()
                pOut.expected = " ZeroOrOne(" & $result.expected & ")"

                if result.isSuccessful:
                    pOut.isSuccessful = true
                else:
                    pOut.isSuccessful = true

                return pOut   
        )
    # proc `?` (p: IParser) : IParser =
    #     return (
    #         proc(): Option[seq[string]] =
    #             var vals: seq[string] = @[]
    #             result = p()
    #             if result.isNone:
    #                 if vals.len > 0:
    #                     return none(seq[string])
    #                 else:
    #                     return some(vals)
    #             else:
    #                 vals.add(result.get)       
    #     )

    #  NOT Parser -  TODO? do this or stick with NOT char?
    # every parse fail is success for NOT
    # the first parse success is a failure for NOT
    proc `!` (p: Parser) : Parser =
        return (
            proc(): ParseObject =
                var pOut = ParseObject(
                    kind: "!",
                    isSuccessful: false,
                )

                while true:
                    result = p()
                    if result.isSuccessful:
                        pOut.isSuccessful = true
                        pOut.expected = " NOT(" & $result.expected & ")"
                        return pOut
                    else:
                        pOut.actual.add(result.actual)      
                        pos = pos + result.expected.len
        )

    remaining = "hello world"
    var str = s('h') & s('e') & s('l') & s('l') & s('o') & (s('w') | s(' ')) & s('w') & s('o') & s('r') & s('l') & s('d')
    echo "remaining = ",  remaining[pos .. ^1]
    echo str()

    # remaining = "hello world"
    # pos = 0
    # # var chckOr = s("hello") & s(' ') & s("world")
    # var chckOr = (s("hi") | (s("hel") & (s("lox") | s("lo")))) & s(' ') & s("world")
    # # echo "remaining = ",  remaining[pos .. ^1]
    # var sTime = getTime()
    # echo chckOr()
    # echo "Duration = ", getTime() - sTime

    # remaining = "helloooxx world"
    # pos = 0
    # # var chckOr = s("hello") & s(' ') & s("world")
    # var chckZOrM = s("hell") & *s('o') & *s('x') & *s('y') & *s(' ') & s("world")
    # # echo "remaining = ",  remaining[pos .. ^1]
    # var sTime2 = getTime()
    # var result = chckZOrM()
    # echo "Duration = ", getTime() - sTime2
    # echo result

    # remaining = "xxxx"
    # pos = 0

    # var chkEOF = s("xxxx") & eof()
    # var sTime3 = getTime()
    # var result = chkEOF()
    # echo "Duration = ", getTime() - sTime3
    # echo result

    # remaining = "{ xxxx}"
    # pos = 0
    # var chckOOrM =  s('{') & ! (s('}') | s('@')) & s('}')
    # # echo "remaining = ",  remaining[pos .. ^1]
    # var sTime4 = getTime()
    # var result4 = chckOOrM()
    # echo "Duration = ", getTime() - sTime4
    # echo result4

    # remaining = "hello world"
    # pos = 0
    # # var chckOr = s("hello") & s(' ') & s("world")
    # # var chckOOrM =  s("hello") & s(' ') & s("world")
    # # echo "remaining = ",  remaining[pos .. ^1]
    # var sTime3 = getTime()
    # var result = chckOOrM()
    # echo "Duration = ", getTime() - sTime3
    # echo result


    # echo "about to parse"
    # remaining = "constx = 1"
    # let ws = *s(' ')
    # let var_kwd = s('v') & s('a') & s('r') & ws
    # let const_kwd = s('c') & s('o') & s('n') & s('s') & s('t') & ws 
    # let comb = var_kwd | const_kwd
    # echo comb().get
    # echo pos, remaining

    # remaining = "{ something goes in here } "
    # let txt = s('{') & *(no('}')) & s('}')
    # echo txt().get
    # echo pos, remaining

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

# import std/[strutils, unicode]

# var str = """
# 012
# 345
# 678
# 9ab
# """

# echo str[0], str[14]
# echo str.len

# var pos = str.len - 4
# var line = 4

# var errLineType = "cur"
# var curLineText: string
# var prevLineText: string
# var lastLineText: string

# var chkPos = pos
# var chkChar : char

# while chkPos >= 0 :
#   chkChar = str[chkPos]
  
#   case errLineType:
#     of "cur":
#       if chkChar == '\n':
#         errLineType = "prev"
#       else:   
#         curLineText.add chkChar
#     of "prev":
#       if chkChar == '\n':
#         errLineType = "last"
#       else:  
#         prevLineText.add chkChar
#     of "last":
#       if chkChar == '\n':
#         break
#       else:  
#         lastLineText.add chkChar
  
#   dec chkPos
  
# echo "|", line - 2, ": ",reversed lastLineText
# echo "|", line - 1, ": ", reversed prevLineText
# echo "|", line, ": ", reversed curLineText