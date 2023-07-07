
import { Context } from '../../defs' 

var rgx = /[var][const]/iym

export function handleSymDeclarations(c: Context): string {
    rgx.lastIndex = c.i
    const matched = rgx.exec(c.code)

    if (!matched) {
        return
    }

    // get identifier

    // get typeExpr

    // if this is only a declr, then return early

    // get the RHS of the equation

    // pub var x:  = 2




 
}
