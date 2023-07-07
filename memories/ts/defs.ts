
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
    errors: Err[]
    output: string
    duration: number

    // currToken: Token
    // nextToken: Token
}
