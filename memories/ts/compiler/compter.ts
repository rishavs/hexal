import RE2 from 're2'

type Tokens =
//Special
| 'EOC' | 'ILLEGAL' | 'IMPORT' | 'EXPORT' | 'NEWLINE' | 'SPACE' | 'WS'
// names
| 'IDENT'
// statement'starters
| 'CONST' | 'VAR' | 'TYPE' | 'SHOW' 
// builtin'types
| 'INT_LIT' | 'DEC_LIT' | 'BOOL_LIT' | 'STR_LIT' | 'CHAR_LIT'
// builtin'values
| 'TRUE' | 'FALSE'  
// Operatrors
| 'ASSIGN' | 'EQUALS' | 'NOT' | 'OR' | 'AND'
| 'PLUS' | 'MINUS' | 'MULT' | 'DIV' 
| 'COMMA' | 'COLON'
| 'SQ_BRACKET_START' | 'SQ_BRACKET_END' | 'CL_BRACKET_START' | 'CL_BRACKET_END' 
| 'SIN_QUOTE' | 'BACKTICK' | 'TRIPTICK' 


type Err = {
    msg: string,
    kind: string,
    i : number,
    line : number
}

type Token = {
    kind: Tokens
    value: string
    i: number
    line: number
};

type Context = {
    code : string,
    codeBuff: Buffer,
    i : number,
    lines : number,
    errors : Err[],
    output : string
}

var c : Context = {
    code : "Hellvar x = y",
    codeBuff: Buffer.from(c.code, 'utf8'),
    i : 0,
    lines : 1,
    errors : [],
    output : ""
}
// c.codeBuff =  Buffer.from(c.code, 'utf8')

const is = (rgx: RE2) => {
    return (c: Context) => {
        rgx.lastIndex = c.i

        var matched = rgx.exec(c.code)

        if (matched && matched.length > 0) {
            console.log(matched)
        } else {
            console.log("No match")
        }
    }
}

const seq = () => {}
const oneOf = () => {}

const handleError = () => {}

var varRgx = new RE2("var", "yim")

const program = is(varRgx)
program()