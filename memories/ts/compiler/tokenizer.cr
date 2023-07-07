module Hexal

    alias Token = Tuple(Symbol, String)

    class Tokenizer
        @keywords = {
            # Keywords
            "const "    => :CONST_DEF,
            "var "      => :VAR_DEF,
            "type "     => :TYPE_DEF,
    
            # Builtins
            "Int"       => :INT_LIT,
            "Bool"      => :BOOL_LIT,
            "Str"       => :STR_LIT,
            "Char"      => :CHAR_LIT,
        }
        
        # Operators
        @operators = {
            "="         => :ASSIGN,
            "=="        => :EQUALS,
            "!="        => :NOTEQUALS,
            "!"         => :NOT,
            "|"         => :OR,
            "&"         => :AND,
            "+"         => :PLUS,
            "-"         => :MINUS,
            "*"         => :MULT,
            "/"         => :DIV,
            "("         => :BRACKETSTART,
            ")"         => :BRACKETEND,
            "```"       => :TRIPTICK,
            "`"         => :BACKTICK,
            "'"         => :SINQUOTE
        }

        @i = 0
        @line = 1

        @output : Array(Token) = [{:SOC, ""}]

        def initialize (@code : String)
        end

        def matches_keywords 
            @keywords.each_key do |kwd|
                # if  i + kwd.size - 1 < @code.size
                if @code[@i, kwd.size]? == @keywords[kwd]
                    return { @keywords[kwd], kwd}
                else
                    return false
                end
            end
        end

        def run

            while @i < @code.size 
                case @code[@i]

                # Handling Whitespace
                when '\n' 
                    @line += 1

                when .whitespace?

                when .number?
                    peepAt = @i 
                    while peepAt < @code.size
                        if @code[peepAt].number? || @code[peepAt]? == '_'
                            peepAt += 1
                        else
                            break
                        end
                    end
                    @output << {:Int_lit, @code[@i .. peepAt - 1]}
                    @i = peepAt 
                else
                    kwd_matched = self.matches_keywords
                    if typeof(kwd_matched) == Tuple(Symbol, String)
                        @output << kwd_matched
                        @i = @i + kwd_matched[1].size
                    else

                        puts "Eating Identifier"
                    end
                end
            
            end

        end


    end

    def self.tokenize (code : String): Array(Token)
        start_time = Time.monotonic


        output : Array(Token) = [{:SOC, ""}]

        i = 0
        line = 1

        while i < code.size 
            case code[i]

            # Handling Whitespace
            when '\n' 
                line += 1
            when .whitespace? 

            # Handling Operators
            when '='
                output << {:Assign, "="}

            when .number?
                peepAt = i 
                while peepAt < code.size
                    if code[peepAt].number? || code[peepAt]? == '_'
                        peepAt += 1
                    else
                        break
                    end
                end
                output << {:Int_lit, code[i .. peepAt - 1]}
                i = peepAt 
            when .letter?
                # Handling Keywords
                if code[i,4]? == "var "
                    output << {:Var_kwd, "var"}
                    i = i + 3
                elsif code[i, 6] == "const "
                    output << {:Const_kwd, "const"}
                    i = i + 5

                # Handling identifiers
                elsif
                    peepAt = i 
                    while peepAt < code.size
                        if code[peepAt].letter? || code[peepAt].number? || code[peepAt] == '_'
                            peepAt += 1
                        else
                            break
                        end
                    end
                    output << {:Ident, code[i .. peepAt - 1]}
                    i = peepAt 

                end
            else
                output << {:Illegal, code[i].to_s}
            end

            if i >= code.size
                output << {:Eoc, ""}
            else 
                i += 1
            end
        end

        end_time = Time.monotonic
        lexing_time = end_time - start_time

        puts "Lines Lexed: #{line}"
        puts "Chars eaten: #{i}"
        puts "Time Taken: #{lexing_time.total_milliseconds } ms"
        return output
    end

    # res = tokenize ("var my_Num = 1_000
# const qq = my_Num")
    # pp res
    t = Tokenizer.new ("var my_Num = 1_000
# const qq = my_Num")

    t.run
    puts t.output

end
