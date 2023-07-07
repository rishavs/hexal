import { Context } from './../defs' 
import {handleBlocks} from './handlers/block'

// Move cursor to the next block end
function recoverFromError() {}

function transmorgrify(code) {
    var c: Context = {
        code: code,
        i : 0,
        line : 1,
        errors : [], 
        output : "",
        duration: Date.now()
    }

    handleBlocks(c)

    c.duration = Date.now() - c.duration
    return c
}

console.log(transmorgrify(
`var x = 10`
))




//     parseModule() {
//         parseNewline()
//         parseSpace()
//         parseImports()
//         ParseBlock()
//     }

//     parseBlock () {
//         parseVarDeclr()
//         parseFunc()
//         parseClass()
//     }
     
//     parseVarDeclr() {
//         if (this.code.startsWith("var"))
//     }
//     handleStatements() {}
//     handleReturnStmt(){}

//     expressions = {}


//     allTokens = {
//         'CONST'     : /const/iym,
//         'VAR'       : /var/iym,
//         'NEWLINE'   : /\n/ym,
//         'SPACE'     : /[ \t\r]/ym,

//         'ASSIGN'    : /=/ym,
//         'PLUS'      : /\+/ym,
//         'MINUS'     : /-/ym,
//         'MULT'      : /\*/ym,
//         'DIV'       : /\//ym,

//         'DEC'       : /([\d][\d_]*\.[\d_]*)/ym,
//         'INT'       : /([\d][\d_]*)/ym,

//         'IDENT'     : /([a-zA-Z_#][a-zA-Z\d_]*)/ym,

//     }

//     constructor(code: string) {
//         this.code = code
//     }

//     getNextToken = () : Token => {
//         if (this.i >= this.code.length) {
//             return {
//                 kind: "EOC",
//                 value: "",
//                 i: this.i,
//                 line: this.lines
//             }
//         }
    
//         for (const t in this.allTokens) {
//             this.allTokens[t].lastIndex = this.i
//             const matched = this.allTokens[t].exec(this.code)
//             // console.log(t, this.allTokens[t], matched)
    
//             if (matched) {
//             // console.log("MATCHED:", t, this.allTokens[t], matched)
                
//                 const n : Token = {
//                     kind: t,
//                     value: matched[0],
//                     i: this.i,
//                     line: this.lines
//                 }
//                 this.i += matched[0].length
//                 return n
//             } else {
//             // console.log("NOT MATCHED:", t, this.allTokens[t], matched)

//             }
//         }

//         const ill = {
//             kind: "ILLEGAL",
//             value: "",
//             i: this.i,
//             line: this.lines
//         }
//         // Return Illegal otherwise
//         this.i += 1
//         return ill
//     }

//     advanceTokens () {
//         if (this.i == 0) {
//             console.log("no tokens exist")
//             this.currToken = this.getNextToken()
//             this.nextToken = this.getNextToken()

//         // console.log(ct, nt)

//         } else {
//             this.currToken = this.nextToken
//             this.nextToken = this.getNextToken()
//         }
//     }
//     run() {
//         const startTime = Date.now()
//         do {
//             this.advanceTokens()
//             console.log(this.currToken)
//         } while (this.currToken.kind != 'EOC')

//         console.log(this.nextToken)


//         this.duration = Date.now() - startTime
//         console.log(this.duration, "ms")
//     }
// } 

// var hexal = new Compiler(`var abx__23 = 10 +1
// const c = a
// var d = 10*3.02`)
// hexal.run()

// function parseProgram() {
//     program = newProgramASTNode()
//     advanceTokens()
//     for (currentToken() != EOF_TOKEN) {
//     statement = null
//     if (currentToken() == LET_TOKEN) {
//     statement = parseLetStatement()
//     } else if (currentToken() == RETURN_TOKEN) {
//     statement = parseReturnStatement()
//     } else if (currentToken() == IF_TOKEN) {
//     statement = parseIfStatement()
//     }
//     if (statement != null) {
//     program.Statements.push(statement)
//     }
//     36
//     advanceTokens()
//     }
//     return program
//     }
//     function parseLetStatement() {
//     advanceTokens()
//     identifier = parseIdentifier()
//     advanceTokens()
//     if currentToken() != EQUAL_TOKEN {
//     parseError("no equal sign!")
//     return null
//     }
//     advanceTokens()
//     value = parseExpression()
//     variableStatement = newVariableStatementASTNode()
//     variableStatement.identifier = identifier
//     variableStatement.value = value
//     return variableStatement
//     }
//     function parseIdentifier() {
//     identifier = newIdentifierASTNode()
//     identifier.token = currentToken()
//     return identifier
//     }
//     function parseExpression() {
//     if (currentToken() == INTEGER_TOKEN) {
//     if (nextToken() == PLUS_TOKEN) {
//     return parseOperatorExpression()
//     } else if (nextToken() == SEMICOLON_TOKEN) {
//     return parseIntegerLiteral()
//     }
//     } else if (currentToken() == LEFT_PAREN) {
//     return parseGroupedExpression()
//     }
//     // [...]
//     }
//     function parseOperatorExpression() {
//     operatorExpression = newOperatorExpression()
//     operatorExpression.left = parseIntegerLiteral()
//     operatorExpression.operator = currentToken()
//     operatorExpression.right = parseExpression()
//     return operatorExpression()
//     }
//     // [


