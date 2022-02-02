import std/[parseopt, rdstdin]
import compiler/parser

var opts = initOptParser()
var args : seq[string]

parse(source)

let hexalLogo = ""
# """
#  ▄▄   ▄▄ ▄▄▄▄▄▄▄ ▄▄   ▄▄ ▄▄▄▄▄▄ ▄▄▄     
# █  █ █  █       █  █▄█  █      █   █    
# █  █▄█  █    ▄▄▄█       █  ▄   █   █    
# █       █   █▄▄▄█       █ █▄█  █   █    
# █   ▄   █    ▄▄▄██     ██      █   █▄▄▄ 
# █  █ █  █   █▄▄▄█   ▄   █  ▄   █       █
# █▄▄█ █▄▄█▄▄▄▄▄▄▄█▄▄█ █▄▄█▄█ █▄▄█▄▄▄▄▄▄▄█    V0.1.0
# """

let usageText = """
    Usage: hexal [command] [command-arguments] [command-options]
        Commands:                               Description:
            hexal                         
                ├ repl                          "Run the REPL"
                ├ compile [file] [options]      "Compile a file into an executable"
                └ info                          "See the hexal installation information"
"""

echo hexalLogo
for kind, key, val in opts.getopt():
    case kind
    of cmdArgument:
        echo key
        args.add(key)
    of cmdLongOption, cmdShortOption:
        case key
        of "help", "h": echo "Helping..."
        of "version", "v": echo "Versioning..."
    of cmdEnd: break


if args.len != 0:
    case args[0]
    of "compile":
        echo "Compiling... "
    of "repl":
        echo "Running REPL..."

        var line: string
        while true:
            let ok = readLineFromStdin("hexal>  ", line)
            if not ok: break # ctrl-C or ctrl-D will cause a break
            if line.len > 0: 
                source = line
                
                echo "Interpreting:     "
            echo ""
        echo "exiting"
    else:
        echo "Unknown command: ", args[0]
        echo "Hexal doesn't knows this spell!"
        echo usageText
else:
    echo usageText





# case cmd = ARGV[0]:
# of "compile":
#     echo "Compiling program..."
#     echo "Reading File..."
#     code = File.read(ARGV[1])
#     runner = Runner.new(code)
#     runner.run()
# of "repl":
#     echo "Starting REPL"

#     loop do
#         echo "--------------------------------------------------\n"
#         echo "> "

#         line = gets
#         if line.nil?
#             break
#         end
        
#         echo "\n"
#         runner = Runner.new(line)
#         runner.run()
#     end
# of "init", "install", "run", "update":
#     raise Exception.new("'#{cmd}' Command has not yet been implemented")
# else :
#     raise Exception.new("Unrecognized command '#{cmd}'")
# end