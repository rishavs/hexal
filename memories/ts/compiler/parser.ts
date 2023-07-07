import * as Lexer from './lexer'
import from './../defs'

function parse(lexOp : Lexer.LexOutput): string {
    const tokens = lexOp.tokens
    var i = 0
    var output = ""

    // parseFile < parseBlock + parse


    // function parseBlock

    while (i < tokens.length) {
        console.log(tokens[i])

        // switch (tokens[i]) {
        //     case 
        // }

        i += 1
    } 

    return output

}

var lexOp = Lexer.lex(
`var xy_12
    =   10.12_45
a = xy_12
<>
`
)
console.log(lexOp)
console.log(parse(lexOp))

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