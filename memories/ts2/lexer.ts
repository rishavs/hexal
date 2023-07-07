import { Context, supportedTokens } from "./defs";

function getNextToken (c: Context) : Token {
    if (c.i >= c.code.length) {
        return {
            kind: "EOC",
            value: "",
            i: c.i,
            line: c.line
        }
    }

    for (const t in supportedTokens) {
        supportedTokens[t].lastIndex = c.i
        const matched = supportedTokens[t].exec(c.code)
        // console.log(t, c.supportedTokens[t], matched)

        if (matched) {
        // console.log("MATCHED:", t, c.supportedTokens[t], matched)
            
            const n : Token = {
                kind: t,
                value: matched[0],
                i: c.i,
                line: c.line
            }
            c.i += matched[0].length
            return n
        } else {
        // console.log("NOT MATCHED:", t, c.supportedTokens[t], matched)

        }
    }

    const ill = {
        kind: "ILLEGAL",
        value: "",
        i: c.i,
        line: c.line
    }
    // Return Illegal otherwise
    c.i += 1
    return ill
}

export function advanceTokens (c: Context) {
    if (c.i == 0) {
        console.log("no tokens exist")
        c.currToken = getNextToken(c)
        c.nextToken = getNextToken(c)

    // console.log(ct, nt)

    } else {
        c.currToken = c.nextToken
        c.nextToken = getNextToken(c)
    }
}