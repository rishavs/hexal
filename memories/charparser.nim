import std/[strutils, strformat, times, options, sequtils]

type 
    ParseObj = object
        kind            : string
        success         : bool
        expected        : string
        actual          : string
        # err             : string
        index           : int
    
    Parser =
        proc(): bool

    ParseError = object
        kind           : string
        message        : string
        index          : int
        startPos       : int
        endPos         : int
        curLineNum     : int
        curLineText    : string
        prevLineNum    : int
        prevLineText   : string
        lastLineNum    : int
        lastLineText   : string

    CompilerMetadata = object
        parseDuration  : Duration
        linesCompiled  : int

# We don't need the parsers to return anything other than a true. only in case of failure do we need to return a full error object
proc parse* (source: string) : void =

    # start timer
    let parseStartTime = getTime()
    var src            = source

    var curLineNum     = 1
    var prevLineNum    = 0
    var lastLineNum    = 0

    var curLineText    = ""
    var prevLineText   = ""
    var lastLineText   = ""

    var i              = 0
    var errors         : seq[ParseError]
    var parsed         : string

    proc handleNewLine() =
        inc curLineNum
        inc prevLineNum
        inc lastLineNum
        lastLineText = prevLineText
        prevLineText = curLineText
        curLineText  = ""

    proc c(c: char ) : Parser =
        return proc () : bool =
            
            if i >= src.len:
                errors.add ParseError(kind: "UnexpectedEndOfInput", message: "Unexpected end of input", index: i, startPos: i, endPos: i, curLineNum: curLineNum, curLineText: curLineText, prevLineNum: prevLineNum, prevLineText: prevLineText, lastLineNum: lastLineNum, lastLineText: lastLineText)
                return false

            if src[i] == c:
                if src[i] == '\n':
                    handleNewLine()
                parsed.add c
                curLineText.add c
                inc i
                return true

            return false

    proc till (c: char) : Parser =
        return proc () : bool =
            while true:
                if i >= src.len:
                    errors.add ParseError(kind: "UnterminatedScope", message: "Unterminated Scope due to Unexpected end of input", index: i, startPos: i, endPos: i, curLineNum: curLineNum, curLineText: curLineText, prevLineNum: prevLineNum, prevLineText: prevLineText, lastLineNum: lastLineNum, lastLineText: lastLineText)
                    return false
                
                if src[i] == c:
                    return true
                else:
                    if src[i] == '\n':
                        handleNewLine()
                    parsed.add src[i]
                    curLineText.add src[i]
                    inc i


    proc `&` (l: Parser, r: Parser) : Parser =
        return proc () : bool =
            if l() and r():
                return true
            return false
    
    proc `|` (l: Parser, r: Parser) : Parser =
        return proc () : bool =
            if l() or r():
                return true
            return false

    proc `*` (p: Parser) : Parser =
        return proc () : bool =
            while true:
                if not p():
                    return true

    proc `+` (p: Parser) : Parser =
        return proc () : bool =
            var atLeastOnce = false
            while true:
                if not p():
                    if atLeastOnce:
                        return true
                    else:
                        return false
                else:
                    atLeastOnce = true

    proc `?` (p: Parser) : Parser =
        return proc () : bool =
            if p():
                return true
            return true

    proc curse (err: ParseError) : Parser =
        return proc () : bool =
            errors.add err
            return false 
    

    src = "d"
    #      01234567
    i = 0
    let var_decl = c('v') & c('a') & c('r')
    let let_decl = c('l') & c('e') & c('t')
    let space = ? c('.')
    let decl = var_decl | let_decl
    let ident = c('x')
    let text = c('{') & till('}') & c('}')
    # let code = decl >> +s(" ") >> s("x") >> *s(" ") >> s("=") >> *s(" ") >> s("1")
    # let code = s("{") >> ! s("}") >> s("}")
    # >> * s(" ") >> s("x") >> s(" ") >> s("=") >> s(" ") >> s("1")
    # let code = decl & space & ident
    let code = c('a') | c('b') | c('c') | curse(ParseError(kind: "NoneOfTheAbove", message: "Its neither a, norb nor c", index: i, startPos: i, endPos: i, curLineNum: curLineNum, curLineText: curLineText, prevLineNum: prevLineNum, prevLineText: prevLineText, lastLineNum: lastLineNum, lastLineText: lastLineText))

    echo code()
    echo errors
    echo parsed
    echo curLineText
    echo "Remaining :", src[i .. ^1]



    # proc eos() : Parser =
    #     return proc () : ParseObj =
    #         var pOut = ParseObj(success : false, expected : "", actual: "")
    #         if (i >= src.len):
    #             pOut.success = true
    #             pOut.actual = "<EOS>"

    #         return pOut

    #         # "1>2<345"
    # proc s(frag : string) : Parser =
    #     return proc () : bool =

    #         # #  start index. We should handle the index overflow earlier as it makes the handling simpler
    #         # if i == 0:
    #         #     discard
    #         # elif i + 1 == src.len:
    #         #     errors.add ParseError(kind : "EOS", message : "Reached End of Source", index : i, startPos : i, endPos : i, curLineNum : curLineNum, curLineText : curLineText, prevLineNum : prevLineNum, prevLineText : prevLineText, lastLineNum : lastLineNum, lastLineText : lastLineText)
    #         #     return false
    #         # else:
    #         #     inc i
    #         # abc
    #         #  check if the fragment is larger than the string left
    #         if i + frag.len > src.len:
    #             errors.add ParseError(kind : "EOS", message : "Unexpected end of source", index : i, startPos : i, endPos : i, curLineNum : curLineNum, curLineText : curLineText, prevLineNum : prevLineNum, prevLineText : prevLineText, lastLineNum : lastLineNum, lastLineText : lastLineText)
    #             return false

    #         if src.continuesWith(frag, i):
    #             curLineText.add frag
    #             i = i + frag.len
    #             parsed.add frag
    #             return true
                
    #         return false

    # proc `>>` (l: Parser, r: Parser) : Parser =
    #     return proc () : ParseObj =
    #         # echo "Index at: ", i, " with value ", src[i]
    #         var pOut = ParseObj(success : false, kind : "Sequence", expected : "", actual: "")
    #         var lOut = l()
    #         if not lOut.success:
    #             pOut.success = false
    #             pOut.expected = lOut.expected
    #             pOut.actual = lOut.actual
    #             pOut.index = lOut.index
    #         else:
    #             # echo "L Success. Cursor now at: ", i, " with value ", src[i]
    #             var rOut = r()
    #             if not rOut.success:
    #                 pOut.success = false
    #                 pOut.expected = rOut.expected
    #                 pOut.actual = rOut.actual
    #                 pOut.index = rOut.index
    #             else:
    #                 # echo "L & R Success. Cursor now at: ", i, " with value ", src[i]
    #                 pOut.success = true
    #                 pOut.expected = lOut.expected & rOut.expected
    #                 pOut.actual = lOut.actual & rOut.actual
    #                 pOut.index = rOut.index

    #         return pOut

    # proc `|` (l: Parser, r: Parser) : Parser =
    #     return proc () : ParseObj =
    #         var lOut = l()
    #         if lOut.success:
    #             return lOut
    #         else:
    #             var rOut = r()
    #             if rOut.success:
    #                 return rOut
    #             else:
    #                 var pOut = ParseObj(success : false)
    #                 pOut.success = false
    #                 pOut.kind = "Choice"
    #                 pOut.expected = lOut.expected & " or " & rOut.expected
    #                 pOut.actual = lOut.actual

    #                 return pOut

    # #    P1 - P2        # matches P1 if P2 does not match
    # proc `-` (l: Parser, r: Parser) : Parser =
    #     return proc () : ParseObj =
    #         var rOut = r()
    #         if rOut.success:
    #             var pOut = ParseObj(success : false)
    #             pOut.kind = "Minus"
    #             pOut.expected = rOut.expected
    #             pOut.actual = rOut.actual

    #             return pOut
    #         else:
    #             var lOut = l()
    #             if lOut.success:
    #                 return lOut
    #             else:
    #                 var pOut = ParseObj(success : false)
    #                 pOut.success = false
    #                 pOut.kind = "Negative"
    #                 pOut.expected = lOut.expected
    #                 pOut.actual = lOut.actual

    #                 return pOut

    # # Zero or Many - always succeeds
    # proc `*` (p: Parser) : Parser =
    #     return proc () : ParseObj =
    #         # var pOut = ParseObj(success : false)
    #         var res = ""
    #         while true:
    #             let pOut = p()
    #             if pOut.success:
    #                 # echo "* received ", pOut.get()
    #                 res.add pOut.actual
    #                 # echo "* has res: ", res
    #             else:
    #                 break
            
    #         return ParseObj(success : true, kind: "Zero or Many", expected : res, actual: res, index: i)

    # # One or Many - succeeds expect when 0 result is found
    # proc `+` (p: Parser) : Parser =
    #     return proc () : ParseObj =
    #         # var pOut = ParseObj(success : false)
    #         var atLeastOneResult = false
    #         var res = ""
    #         while true:
    #             let pOut = p()
    #             if pOut.success:
    #                 # echo "* received ", pOut.get()
    #                 res.add pOut.actual
    #                 atLeastOneResult = true
    #                 # echo "* has res: ", res
    #             else:
    #                 if atLeastOneResult:
    #                     return ParseObj(success : true, kind: "One or Many", expected : res, actual: res, index: i)
    #                 else:
    #                     return ParseObj(success : false, kind: "One or Many", expected : res, actual: res, index: i)

    # #  Zero or One - always succeeds. stops after 1 result
    # proc `?` (p: Parser) : Parser =
    #     return proc () : ParseObj =
    #         var pOut = p()
    #         pOut.kind = "Zero or One"
    #         if not pOut.success:
    #             pOut.success = true
    #             pOut.actual = ""
    #         return pOut

    # #  NOT - succeeds if parser fails
    # proc `!` (p: Parser) : Parser =
    #     return proc () : ParseObj =
    #         var res = ""
    #         while true:
    #             if (i == src.len - 1):
    #                 return ParseObj(success : false, kind: "Not", expected : "", actual: "EOF", index: i)
    #             var pOut = p()
    #             echo pOut.expected
    #             echo pOut.actual
    #             if pOut.success:
    #                 return ParseObj(success : true, kind: "Not", expected : res, actual: res, index: i)
    #             else:
    #                 # need to move cursor
    #                 i = i + pOut.actual.len
    #                 res.add pOut.actual
            # # Raise error as well
            # return ParseObj(success : false, kind: "Not", expected : "NOT " & pOut.expected, actual: res, index: i)
            
    #  TILL - consume till a match succeeds. If end of file reached, parser fails

            

    # src = "abc"
    # #      01234567
    # i = 0
    # # let decl = s("const") | s("var") | s("let")
    # # let code = decl >> +s(" ") >> s("x") >> *s(" ") >> s("=") >> *s(" ") >> s("1")
    # # let code = s("{") >> ! s("}") >> s("}")
    # # >> * s(" ") >> s("x") >> s(" ") >> s("=") >> s(" ") >> s("1")
    # let code = s("abcs")
    # echo code()
    # echo errors
    # echo parsed
    # echo curLineText
    # echo "Remaining :", src[i .. ^1]
    


        
