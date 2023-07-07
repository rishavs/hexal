// import {readFileSync} from 'fs';

var fs = require("fs");
import llvm from 'llvm-bindings';

import { advanceTokens } from './lexer';
import { Context } from './defs' 


export function compile(inputFile : string) : string {
    const context = new llvm.LLVMContext();
    const module = new llvm.Module('main', context);
    const builder = new llvm.IRBuilder(context);

    var c: Context = {
        code: fs.readFileSync("samples/test.hex", "utf8").toString(),
        i : 0,
        line : 1,
        tokens: [],
        errors : [], 
        output : "",
        duration: Date.now(),
        currToken: {
            kind: "EOC",
            value: "",
            i: 0,
            line: 1
        },
        nextToken: {
            kind: "EOC",
            value: "",
            i: 0,
            line: 1
        }
    }

    console.log(c)

    const startTime = Date.now()
    do {
        this.advanceTokens()
        console.log(this.currToken)
    } while (this.currToken.kind != 'EOC')

    console.log(this.nextToken)


    // this.duration = Date.now() - startTime
    // console.log(this.duration, "ms")



    return ""

}