require "pegmatite"

module Hexal::Parser
    Grammar = Pegmatite::DSL.define do
        # -------------------------------------
        # Comments
        # -------------------------------------
        
        singleline_comment = (str("//") >> (~char('\n') >> any).repeat)
        multiline_comment = (str("/*") >> (~char('\n') >> any).repeat)
        comments = singleline_comment | multiline_comment

        # -------------------------------------
        # Whitespace
        # -------------------------------------
        whitespace = char(' ') | char('\t') | char('\r') | str("\\\n") | str("\\\r\n")
        s = whitespace.repeat
        newline = s >> eol_comment.maybe >> (char('\n') | s.then_eof)
        sn = (whitespace | newline).repeat

        # -------------------------------------
        # Keywords
        # -------------------------------------

        # -------------------------------------
        # Identifiers
        # -------------------------------------
        ident_letter =
            range('a', 'z') | range('A', 'Z') | range('0', '9') | char('_')
        ident = (
            (
                (char('@') >> ident_letter.repeat) |
                (char('^') >> digit19 >> digit.repeat) |
                ident_letter.repeat(1)
            ) >> char('!').maybe
        ).named(:ident)
        # -------------------------------------
        # Literals
        # -------------------------------------

        # -- Null
        null = str("null").named(:null)

        # -- Boolean
        boolean_true = str("true")
        boolean_false = str("false")
        boolean = (
            boolean_true | boolean_false
        ).named(:boolean)

        # -- Number
        # 0
        # 1234
        # -5678
        # 3.14159
        # 1.0
        # -12.34

        # 0xcaffe2

        digit19 = range('1', '9')
        digit = range('0', '9')
        digits = digit.repeat(1)
        integers = digits >> str("_").maybe >> digits
        floats = integers >> str(".") >> integers
        hex = str("0x") >> (digit | range('a', 'f') | range('A', 'F'))
        # 0.0314159e02
        # 0.0314159e+02
        # 314.159e-02
        scientific_notation_numbers =  floats >> (str("e") | str("E")) >> (str("+") | str("-")).maybe >> digits

        number = (
            str("-").maybe >> (integer | float | hex_number | scientific_notation_numbers)
        ).named(:number)


        # ---- Int - Int64

        # ---- Decimals - Float64 + scientific notation

        # ---- Hex

        # ---- Floats - Float64 + scientific notation


        # Define what optional whitespace looks like.
        s = (char(' ') | char('\t')).repeat
        newline = (char('\r').maybe >> char('\n'))
        snl = (s >> newline.maybe >> s).repeat

        # Define what a number looks like.
        digit19 = range('1', '9')
        digit = range('0', '9')
        digits = digit.repeat(1)
        int =
            (char('-') >> digit19 >> digits) 
            | (char('-') >> digit) 
            | (digit19 >> digits) 
            | digit
        number = int.named(:number)

        # Define what a string looks like.

        string_char =
        str("\\\"") | str("\\\\") | str("\\|") |
            str("\\b") | str("\\f") | str("\\n") | str("\\r") | str("\\t") |
            (str("\\u") >> hex >> hex >> hex >> hex) |
            (~char('"') >> ~char('\\') >> range(' ', 0x10FFFF_u32))
        string = char('"') >> string_char.repeat.named(:string) >> char('"')

        identifier = (
        (range('a', 'z') | range('A', 'Z') | char('_')) >>
        (range('a', 'z') | range('A', 'Z') | digits | char('_') | char('-')).repeat
        ).named(:identifier)





      
        VariableStatement = var VariableDeclarationList<withIn> #sc
      
        VariableDeclarationList<guardIn> = NonemptyListOf<VariableDeclaration<guardIn>, ",">
      
        VariableDeclaration<guardIn> = identifier Initialiser<guardIn>?
      
        Initialiser<guardIn> = "=" AssignmentExpression<guardIn>
      
        EmptyStatement = ";" // note: this semicolon eats newlines
      
        ExpressionStatement = ~("{" | function) Expression<withIn> #sc
      
        IfStatement = if "(" Expression<withIn> ")" Statement (else Statement)?
            
            StatementList = Statement*
            Block = "{" StatementList "}"
        
        
        type = enum of classes

        directive = {
            | Block
            | VariableStatement
            | EmptyStatement
            | ExpressionStatement
            | IfStatement
            | IterationStatement
            | ContinueStatement
            | BreakStatement
            | ReturnStatement
            | WithStatement
            | LabelledStatement
            | SwitchStatement
            | ThrowStatement
            | TryStatement
            | DebuggerStatement


        AssignmentExpression = 
            str("let") >> identifier >> (char(':') >> Types ).maybe >> "=" >> Expression<withIn>



        

        block_start = sof | "{"
        block_end = eof | "}"

        term = 
            expression >> term_operator >> 
        
        definition =
            | class_definition
            | function_definition

        expression =
        | value
        | function_instance


        definition = str("def") >> identifier >> (char(':') >> Types ).maybe >> char('=') >> templates
        evaluation = declartion >> char('=') >> expression
        

        
        # equation is made of declartion and expressions. expressions are made of terms (which are expressions)

        # trystr("try") >> block_id

        equation = (
            | definition
            | evaluation
        )

        directive = 
            # | try_directive
            # | catch_directive
            # | for_loop
            # | while_loop
            
        #  can try and catch be expressions instead? always return the last expression in the block?? if no block, return true/false?
        #  everything is an expression. Somethings can just return void.

        # directive is a "do" operation like loops. expression is an "is" operation which assigns value
        statement = (
            # | directive 
            | equation
            # | expression
        ).named(:statement)

        # Define a total document to be a sequence of lines.
        mod = (sof >> statements >> eof).named(:mod)
        
        # A valid parse is a single document followed by the end of the file.
        mod.then_eof
    end
end




# module Savi::Parser
#   Grammar = Pegmatite::DSL.define do
#     # Define what an end-of-line comment/annotation looks like.
#     eol_annotation = str("::") >> char(' ').maybe >> (~char('\n') >> any).repeat.named(:annotation)
#     eol_comment = (str("//") >> (~char('\n') >> any).repeat) | eol_annotation

#     # Define what whitespace looks like.
#     whitespace =
#       char(' ') | char('\t') | char('\r') | str("\\\n") | str("\\\r\n")
#     s = whitespace.repeat
#     newline = s >> eol_comment.maybe >> (char('\n') | s.then_eof)
#     sn = (whitespace | newline).repeat

#     # Define what a number looks like (integer and float).
#     digit19 = range('1', '9')
#     digit = range('0', '9')
#     digithex = digit | range('a', 'f') | range('A', 'F')
#     digitbin = range('0', '1')
#     digits = digit.repeat(1) | char('_')
#     int =
#       (str("0x") >> (digithex | char('_')).repeat(1)) |
#       (str("0b") >> (digitbin | char('_')).repeat(1)) |
#       (char('-') >> digit19 >> digits) |
#       (char('-') >> digit) |
#       (digit19 >> digits) |
#       digit
#     frac = char('.') >> digits
#     exp = (char('e') | char('E')) >> (char('+') | char('-')).maybe >> digits
#     integer = int.named(:integer)
#     float = (int >> ((frac >> exp.maybe) | exp)).named(:float)

#     # Define what an identifier looks like.
#     ident_letter =
#       range('a', 'z') | range('A', 'Z') | range('0', '9') | char('_')
#     ident = (
#       (
#         (char('@') >> ident_letter.repeat) |
#         (char('^') >> digit19 >> digit.repeat) |
#         ident_letter.repeat(1)
#       ) >> char('!').maybe
#     ).named(:ident)

#     # Define what a string looks like.
#     string_char =
#       str("\\\"") | str("\\\\") |
#       str("\\b") | str("\\f") | str("\\n") | str("\\r") | str("\\t") |
#       str("\b")  | str("\f")  | str("\n")  | str("\r")  | str("\t") |
#       (str("\\u") >> digithex >> digithex >> digithex >> digithex) |
#       (str("\\x") >> digithex >> digithex) |
#       str("\\").maybe >> (~char('"') >> ~char('\\') >> range(' ', 0x10FFFF_u32))
#     string = (
#       ident_letter.named(:ident).maybe >>
#       char('"') >>
#       string_char.repeat.named(:string) >>
#       char('"')
#     ).named(:string)

#     # Define what a character string looks like.
#     character_char =
#       str("\\'") | str("\\\\") |
#       str("\\b") | str("\\f") | str("\\n") | str("\\r") | str("\\t") |
#       str("\b")  | str("\f")  | str("\n")  | str("\r")  | str("\t") |
#       (str("\\u") >> digithex >> digithex >> digithex >> digithex) |
#       (str("\\x") >> digithex >> digithex) |
#       (~char('\'') >> ~char('\\') >> range(' ', 0x10FFFF_u32))
#     character = char('\'') >> character_char.repeat.named(:char) >> char('\'')

#     # Define what a heredoc string looks like.
#     heredoc_content = declare()
#     heredoc = str("<<<") >> heredoc_content.named(:heredoc) >> str(">>>")
#     heredoc_no_token = str("<<<") >> heredoc_content >> str(">>>")
#     heredoc_content.define \
#       (heredoc_no_token | (~str(">>>") >> any)).repeat

#     # Define an atom to be a single term with no binary operators.
#     parens = declare()
#     decl = declare()
#     anystring = string | character | heredoc
#     atom = parens | anystring | float | integer | ident

#     # Define a compound to be a closely bound chain of atoms.
#     opcap = char('\'').named(:op)
#     opdot = char('.').named(:op)
#     oparrow = (str("->")).named(:op)
#     compound_without_prefix = (atom >> (
#       (opcap >> ident) | \
#       (s >> oparrow >> s >> atom) | \
#       (sn >> opdot >> sn >> atom) | \
#       parens
#     ).repeat >> (s >> eol_annotation).maybe).named(:compound)

#     # A compound may be optionally preceded by a prefix operator.
#     prefixop = (str("--") | char('!') | char('~')).named(:op)
#     compound_with_prefix = (prefixop >> compound_without_prefix).named(:prefix)
#     compound = compound_with_prefix | compound_without_prefix

#     # Define groups of operators, in order of precedence,
#     # from most tightly binding to most loosely binding.
#     # Operators in the same group have the same level of precedence.
#     opw = (char(' ') | char('\t'))
#     op1 = (str("*!") | char('*') | char('/') | char('%')).named(:op)
#     op2 = (str("+!") | str("-!") | char('+') | char('-')).named(:op)
#     op3 = (str("<|>") | str("<~>") | str("<<~") | str("~>>") |
#             str("<<") | str(">>") | str("<~") | str("~>") |
#             str("<:") | str("!<:") |
#             str(">=") | str("<=") | char('<') | char('>') |
#             str("===") | str("==") | str("!==") | str("!=") |
#             str("=~")).named(:op)
#     op4 = (str("&&") | str("||")).named(:op)
#     ope = (str("+=") | str("-=") | str("<<=") | char('=')).named(:op)
#     ope_colon = char(':').named(:op)

#     # Construct the nested possible relations for each group of operators.
#     tw = compound
#     t1 = ((tw >> (opw >> s >> tw).repeat(1)).named(:group_w) >> s) | tw
#     t2 = (t1 >> (sn >> op1 >> sn >> t1).repeat).named(:relate)
#     t3 = (t2 >> (sn >> op2 >> sn >> t2).repeat).named(:relate)
#     t4 = (t3 >> (sn >> op3 >> sn >> t3).repeat).named(:relate)
#     te = (t4 >> (sn >> op4 >> sn >> t4).repeat).named(:relate)
#     t = (
#       te >> (
#         # Newlines cannot precede the colon form of `ope`,
#         # but any other `ope` can be preceded by a newline.
#         s >> (ope_colon | (sn >> ope)) >> sn >> te
#       ).repeat
#     ).named(:relate_r) >> s

#     # Define what a comma/newline-separated sequence of terms looks like.
#     term = decl | t
#     termsl = term >> s >> (char(',') >> sn >> term >> s).repeat >> (char(',') >> s).maybe
#     terms = (termsl >> sn).repeat

#     # Define groups that are pipe-partitioned sequences of terms.
#     pipesep = char('|').named(:op)
#     ptermsp =
#       pipesep.maybe >> sn >>
#       (terms >> sn >> pipesep >> sn).repeat >>
#       terms >> sn >>
#       pipesep.maybe >> sn
#     parens.define(
#       (str("^(") >> sn >> ptermsp.maybe >> sn >> char(')')).named(:group) |
#       (char('(') >> sn >> ptermsp.maybe >> sn >> char(')')).named(:group) |
#       (char('[') >> sn >> ptermsp.maybe >> sn >> char(']') >> char('!').maybe).named(:group)
#     )

#     # Define what a declaration looks like.
#     decl.define(
#       (char(':') >> ident >> (s >> compound).repeat >> s).named(:decl) >>
#       (char(':') | ~~newline)
#     )

#     # Define a total document to be a sequence of lines.
#     doc = (sn >> terms).named(:doc)

#     # A valid parse is a single document followed by the end of the file.
#     doc.then_eof
#   end
# end