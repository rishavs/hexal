# TODO: Write documentation for `Hexal`

# require "./compiler/*"

module Hexal
    VERSION = "0.1.0"

    def self.str2(s : String)
        ->(code : String, i : Int32) {
            if code[i..].starts_with?(s)
                return s
            else
                raise Exception.new("Tried to match #{s} but got #{code[i..]} instead")
            end
        }
    end

    test = str2("hello")

    puts test.call("hello world", 0)

    def self.update_parser_state(state : ParserState, index, result) : ParserState
        new_state = state
        new_state.index = index
        new_state.result = result
        return new_state
    end

    def self.update_parser_result(state : ParserState, result) : ParserState
        new_state = state
        new_state.result = result
        return new_state
    end

    def self.update_parser_error(state : ParserState, errmsg) : ParserState
        new_state = state
        new_state.is_error = true
        new_state.error = errmsg
        return new_state
    end

    struct ParserState
        property code       : String
        property is_error   : Bool
        property error      : String | Nil
        property index      : Int32
        property result     : String | Nil

      def initialize(@code)
        @is_error   = false
        @error      = nil
        @index      = 0
        @result     = nil
      end
    end

    class Parser 

        def initialize(@transformer_func : Proc(ParserState, ParserState))
        end

        def run(target_string)
            initial_parser_state = ParserState.new(target_string)

            return @transformer_func.call (initial_parser_state)
        end

        def map()
        end

        def error_map()
        end
    end

    # def self.str_parser(s : String, ps : ParserState) : ParserState
    #     if ps.is_error
    #         return ps 
    #     end

    #     slicedTarget = ps.code[ps.index..]

    #     if slicedTarget.size  == 0
    #         return update_parser_error(ps, `str: Tried to match "${s}", but got Unexpected end of input.`)
    #     end

    #     if slicedTarget.starts_with?(s)
    #         return update_parser_state(ps, ps.index + s.size, s)
    #     else
    #         return update_parser_error(ps, "str: Tried to match #{s} but got #{slicedTarget} instead")
    #     end
    # end

    def self.str(s : String)
        return Parser.new(->(ps : ParserState) : ParserState {
            if ps.is_error
                return ps 
            end
    
            slicedTarget = ps.code[ps.index..]
    
            if slicedTarget.size  == 0
                return update_parser_error(ps, `str: Tried to match "${s}", but got Unexpected end of input.`)
            end
    
            if slicedTarget.starts_with?(s)
                return update_parser_state(ps, ps.index + s.size, s)
            else
                return update_parser_error(ps, "str: Tried to match #{s} but got #{slicedTarget} instead")
            end
        })
    end

    parser = str("hello")

    puts parser.run("hsello world")

  
end

# def fn1(arg)
#     puts arg * 2
# end

# def pass_fn(s)
#     s.call(10)
# end

# fn1_pointer = ->fn1(Int32)
# pass_fn (fn1_pointer)

# class Node
#     alias NType = Array(Node) | Nil
#     property index : Int32
#     property children : NType
  
#     def initialize(@index)
#     end
#   end