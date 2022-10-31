# TODO: Write documentation for `Hexal`

# require "./compiler/*"
#
module Hexal
    VERSION = "0.1.0"

    struct ParserState
        property success        : Bool
        property expected       : String
        property actual         : String

        def initialize(@success, @expected, @actual)
        end
    end

    alias ParsingFunc = ParserState -> ParserState

    class Parser
        # alias ParsingFunction = ->() : (Bool, String)
        @code : String
        @i : Int32

        def initialize(@code)
            @i = 0
        end

        def s(frag : String)
            ps = ParserState.new(success = false, expected = frag, actual = "")
            return -> {
                   if @code[@i..].lchop? frag
                    @i += frag.size
                    ParserState.new(true, frag, frag)
                else
                    ParserState.new(false, frag, @code[@i].to_s)
                end
            }
        end
        # def seq(parsers : Array( Proc(, ParserState))
        # end
    #     def c(c : Char)
    #         if @code[@i..].lchop? c
    #             @i += 1
    #             return true, c.to_s
    #         else
    #             return false, ""
    #         end
    #     end

    #     def seq(parsers : Array(Tuple(Bool, String)))
    #         res = ""
    #         parsers.each { |p|
    #             if p[0]
    #                 res += p[1]
    #             else
    #                 return false, ""
    #             end
    #         }
    #         return true, res
    #     end

    #     def choice(parsers : Array(Tuple(Bool, String)))
    #         parsers.each { |p|
    #             puts "choice: ", p
    #             if p[0]
    #                 puts "Found",  p
    #                 return p
    #             end
    #         }
    #         return false, ""
    #     end

    #     def zero_or_many(p : Tuple(Bool, String))
    #         res = ""
    #         loop do
    #             puts "Checking Zero or many: at ", @code[@i]
    #             if p[0]
    #                 puts "Zero or many: p matched", p
    #                 return true, res
    #             else
    #                 puts "Zero or many: p did not match", p
    #                 res += p[1]
    #             end

    #         end
    #         return true, res
    #     end

    end

    p = Parser.new("Hello World")

    grammar = p.s("Hello")

    puts grammar.call()
#     puts p.seq([
#         p.choice([p.s("Hi"), p.s("Hello")]), 
#         # p.s("Hello"),
#         p.zero_or_many(p.s(" ")), 
#         p.s("World")])
end
# class Myclass
#     property val : String

#     def initialize(@val : String)
#     end

#     def + (x : Myclass)
#       return @val + x.val
#     end

#     def + (x : String)
#         puts x
#       return @val + x
#     end

#   end

#   a = Myclass.new("a")
#   b = Myclass.new("b")
#   c = Myclass.new("c")

#   # pp a.num
#   pp a. + b. + c

# def self.update_parser_state(state : ParserState, index, result) : ParserState
#     new_state = state
#     new_state.index = index
#     new_state.result = result
#     return new_state
# end

# def self.update_parser_result(state : ParserState, result) : ParserState
#     new_state = state
#     new_state.result = result
#     return new_state
# end

# def self.update_parser_error(state : ParserState, errmsg) : ParserState
#     new_state = state
#     new_state.is_error = true
#     new_state.error = errmsg
#     return new_state
# end

# struct ParserState
#     property code       : String
#     property is_error   : Bool
#     property error      : Array(String)
#     property index      : Int32
#     property result     : Array(String)

#   def initialize(@code)
#     @is_error   = false
#     @error      = [] of String
#     @index      = 0
#     @result     = [] of String
#   end
# end

# class Parser
#     property transformer_func : Proc(ParserState, ParserState)

#     def initialize(@transformer_func )
#     end

#     def run(target_string)
#         initial_parser_state = ParserState.new(target_string)

#         return @transformer_func.call (initial_parser_state)
#     end

#     def parser_map(func)
#         return Parser.new(
#             ->(ps : ParserState) : ParserState {

#                 nextState = @transformer_func.call(ps)

#                 if nextState.is_error
#                     return nextState
#                 end

#                 return update_parser_result(nextState, func.call(nextState.result))
#             }
#         )
#     end

#     def error_map()
#     end
# end
# # map(fn) {
# #     return new Parser(parserState => {
# #       const nextState = this.parserStateTransformerFn(parserState);

# #       if (nextState.isError) return nextState;

# #       return updateParserResult(nextState, fn(nextState.result));
# #     });
# #   }

# def self.str(s : String)
#     return Parser.new(
#         ->(ps : ParserState) : ParserState {
#             if ps.is_error
#                 return ps
#             end

#             slicedTarget = ps.code[ps.index..]

#             if slicedTarget.size  == 0
#                 return update_parser_error(ps, ["str: Tried to match ${s}, but got Unexpected end of input."])
#             end

#             if slicedTarget.starts_with?(s)
#                 return update_parser_state(ps, ps.index + s.size, [s])
#             end

#             return update_parser_error(ps, ["str: Tried to match #{s} but got #{slicedTarget} instead"])
#         }
#     )
# end

# def self.sequence_of(parsers : Array(Parser))
#     return Parser.new(
#         ->(ps : ParserState) : ParserState {
#             if ps.is_error
#                 return ps
#             end

#             results = [] of String

#             nextState = ps
#             parsers.each { |p|
#                 nextState = p.transformer_func.call(nextState)
#                 results.concat nextState.result
#             }

#             return update_parser_result(nextState, results)
#         }
#     )
# end

# tstart = Time.monotonic
# parser = sequence_of([
#     str("hello"),
#     str(" "),
#     str("world"),
# ]).parser_map(->(r : Array(String)) {
#     return r.reverse
# })
# # parser = str("hello").map (->(s : String) { s.upcase })

# # })
# puts output = parser.run("hello world")

# pp tend  = Time.monotonic - tstart
# pp tend.seconds.to_s + " s, " + tend.milliseconds.to_s + " us, " + tend.microseconds.to_s + " ms, " + tend.nanoseconds.to_s + " ns"

# end

# class Node
#     alias NType = Array(Node) | Nil
#     property index : Int32
#     property children : NType

#     def initialize(@index)
#     end
#   end
