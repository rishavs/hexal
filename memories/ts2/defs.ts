
type VarNode = {
    isVar: string;
    age: number;
};

type Statement = string | number
type Program = Statement[]

export type Err = {
    msg: string,
    kind: string,
    i: number,
    line: number
}

export type Token = {
    kind: string
    value: string
    i: number
    line: number
};


export type Context = {
    code: string
    i: number
    line: number
    tokens: Token[],
    errors: Err[]
    output: string
    duration: number

    currToken: Token
    nextToken: Token
}

export var supportedTokens = {
    'CONST'     : /const/iym,
    'VAR'       : /var/iym,
    'NEWLINE'   : /\n/ym,
    'SPACE'     : /[ \t\r]/ym,

    'ASSIGN'    : /=/ym,
    'PLUS'      : /\+/ym,
    'MINUS'     : /-/ym,
    'MULT'      : /\*/ym,
    'DIV'       : /\//ym,

    'DEC'       : /([\d][\d_]*\.[\d_]*)/ym,
    'INT'       : /([\d][\d_]*)/ym,

    'IDENT'     : /([a-zA-Z_#][a-zA-Z\d_]*)/ym,

}