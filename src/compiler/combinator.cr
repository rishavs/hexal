module Crexal
    class Combinator
        property success = false
        property code = ""
        property parsed = [] of String
        property i = 0
        property line = 1

        def initialize(str)
            @code = str
        end

        def is(pattern)
            return -> {
                matched = /#{pattern}/.match(@code, @i) 
                if matched 
                    @success = true
                    @i = @i + matched[0].size

                    @parsed << matched[0]
                else
                    @success = false
                end
            }
        end
        def s(str)
            return -> {
                matched = /#{str}/.match(@code, @i) 
                if matched 
                    @success = true
                    @i = @i + matched[0].size

                    @parsed << matched[0]
                else
                    @success = false
                end
            }
        end

        def seq(*parsers : ->)
            return ->{
                backupSuccess = @success
                backupParsed = @parsed
                backupI = @i
                backupLine = @line 

                parsers.each{ |parser|
                    parser.call
                    puts @success, @parsed

                    if !@success
                        puts "failed"
                        @success = backupSuccess
                        @parsed = backupParsed
                        @i = backupI
                        @line = backupLine
                        
                        
                        break
                    end
                }
            }
        end

    end

    c = Combinator.new("Hello World")
    program = c.seq(c.is("Hell"), c.is("o"), c.is("World"))

    program.call
    pp! c
end


