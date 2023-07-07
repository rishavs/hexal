import { IRBuilder } from "llvm-bindings";
import { Context } from "./defs";
import {advanceTokens} from "./lexer"

export function compileModule(c: Context, ir: IRBuilder) {

    advanceTokens(c)

    // run through all statements
    switch (c.currToken.kind) {
        case 'VAR': 
        case 'CONST':

    } 

}