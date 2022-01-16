# TODO: Write documentation for `Hexal`

require "./compiler/*"


module Hexal
    VERSION = "0.1.0"

    puts "Number of command line arguments: #{ARGV.size}"

    begin
        pp content = File.read(ARGV[0])
    rescue ex1 : IndexError
        puts "Rescued MyException: #{ex1.message}"
    rescue ex2 : File::NotFoundError
        puts "Rescued MyException: #{ex2.message}"
    # rescue
    # # any other kind of exception
    # else
    # # execute this if an exception isn't raised
    end

end
