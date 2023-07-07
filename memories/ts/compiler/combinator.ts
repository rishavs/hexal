type Parser = () => void

function parse (code : string) {
    var line = 1
    var i = 0
    
    var lastSuccess = false
    var lastParsed : string[]
    // var allParsed = []

    var startTime = Date.now()
    // ----------------------------
    // Parsers
    // ----------------------------
    function is(frag: string): Parser {
        return function () {
            lastParsed = []

            if (code.startsWith(frag, i)) {
                lastSuccess = true
                lastParsed = [frag]

                i += frag.length
                // allParsed.push(frag)
            } else {
                lastSuccess = false
            }
        }
    }

    function eoc() : Parser {
        return function () {
            lastParsed = []

            if (i < code.length) {
                lastSuccess = false
            } else {
                lastSuccess = true
                lastParsed = ["<:EOC:>"]
                // allParsed.push("<:EOC:>")
            }
        }
    }

    function nl() {
        return function() {
            lastParsed = []

            if (code.charCodeAt(i) == 10) {
                lastSuccess = true
                line += 1
                i += 1
                lastParsed = ["<:NL:>"]
                // allParsed.push("<:NL:>")
            } else {
                lastSuccess = false
            }
        }

    }

    function ws() {
        return function() {
            lastParsed = []

            switch (code.charCodeAt(i)) {
                case 32:
                case 9:
                    lastSuccess = true
                    i += 1
                    // allParsed.push("<:WS:>")
                    lastParsed = ["<:WS:>"]

                    break;
                case 10:
                    lastSuccess = true
                    line += 1
                    i += 1
                    // allParsed.push("<:NL:>")
                    lastParsed = ["<:WS:>"]
                    
                    break;
                default: 
                    lastSuccess = false
                }
              
        }
    }

    function isLetter() {
        return function () {
            lastParsed = []

            const n = code.charCodeAt(i)
            if ( (n > 64 && n < 91) || (n > 96 && n < 123)) {
                lastSuccess = true
                lastParsed = [code.charAt(i)]
                i += 1

            } else {
                lastSuccess = false
            }
        }
    }
    function isDigit() {
        return function () {
            lastParsed = []

            const n = code.charCodeAt(i)
            console.log(n, code.charAt(i))
            if (n > 47 && n < 58){
                lastSuccess = true
                lastParsed = [code.charAt(i)]
                i += 1

            } else {
                lastSuccess = false
            }
        }
    }
    function isUppercaseLetter() {}
    function islowercaseLetter() {}

    // function checkCase(ch) {
    //     if (!isNaN(ch * 1)){
    //        return 'ch is numeric';
    //     }
    //      else {
    //        if (ch == ch.toUpperCase()) {
    //           return 'upper case';
    //        }
    //        if (ch == ch.toLowerCase()){
    //           return 'lower case';
    //        }
    //     }
    //  }
    // ----------------------------
    // Combinators
    // ----------------------------
    function seq(...parsers: Parser[]): Parser {
        return function () {
            var seqParsed = []
            lastParsed = []

            const backup: [number, number, boolean] = [line, i, lastSuccess]
            
            for (var parser of parsers) {
                parser()
                if (lastSuccess) {
                    seqParsed.push(...lastParsed)
                } else {
                    [line, i, lastSuccess] = backup
                    lastParsed = []
                    break
                }
            }
            // const seqParsed = allParsed.slice(allParsedIndex)
            lastParsed = seqParsed
        }
    }
    function choice(...parsers: Parser[]) {
        return function () {
            lastParsed = []

            for (var parser of parsers) {
                parser()
                if (lastSuccess) {
                    break
                } else {
                    lastParsed = []
                }
            }
        }
    }

    function zeroOrMany (parser: Parser) {
        return function () {
            var seqParsed = []
            lastParsed = []

            while (lastSuccess) {
                parser()
                if (lastSuccess) {
                    seqParsed.push(...lastParsed)
                }
            }
            lastParsed = seqParsed
            lastSuccess = true
        }

    }

    function oneOrMany (parser: Parser) {
        return function () {
            var seqParsed = []
            lastParsed = []

            var atLeastOne = false
            while (lastSuccess) {
                parser()

                if (lastSuccess) {
                    atLeastOne = true
                    seqParsed.push(...lastParsed)
                } else {
                    lastParsed = []
                }
            }
            lastParsed = seqParsed
            lastSuccess = atLeastOne
        }
    }

    // ----------------------------
    // Parsing Rules
    // ----------------------------
    const space = oneOrMany(ws())

    const assignExpr = 1
    const declareAndAssignExpr = 2


    // const integer = isDigit()
    const integer = seq(
        oneOrMany(isDigit()),
        // zeroOrMany(is("_"))
        // isDigit(),
        // // zeroOrMany(isDigit())
        // choice(zeroOrMany(isDigit()), zeroOrMany(is("_")))
    )

    integer()
    
    const parsingDuration = `${Date.now() - startTime} ms`
    return {lastSuccess, parsingDuration,  i, line, lastParsed}

}

const input = `1_0`
console.log(parse(input))