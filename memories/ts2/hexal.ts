import { compile } from './compiler/compiler'

function run (args: string[]): number {

    // run
    // compile
    // new
    // add

    // console.log(args)
    if (args[0] == "compile" && args[1]) {
        console.log(`Compiling ${args[1]}`)
        compile(args[1])
    }  else {
        console.error("Usage: Hexal [script]")
        console.error(" -- compile <filename>")
        process.exit(64);
    }
    return 0
}

run (process.argv.slice(2))

// const fs = require('fs')
// // const prompt = require("prompt-sync")({ sigint: true });

// class Tylox {

//     compile (args: string[]) {
//         if (args.length > 1) {
//             console.error("Usage: Tylox [script]");
//             process.exit(64);
//         } else if (args.length === 1) {
//             this.runFile(args[0]);
//         } else {
//             this.runPrompt();
//         }
//     }
//     runFile (arg: string) {
//         console.log(`Running File ${arg}`)
//         return fs.readFileSync(arg, "utf8").toString() 
//     }

//     run (code: string) {
//         console.log(`Running compiler on code`)
//     } 
// }

// const compiler = new Tylox()
// compiler.compile(process.argv.slice(2))


// class ConsoleOutputHandler implements OutputHandler {
//     print(message: string): void {
//         console.log(message);
//     }
//     printError(message: string): void {
//         console.error(message);
//     }
// }

// function runFile(path: string): never {
//     const output = new ConsoleOutputHandler();
//     let source;

//     try {
//         source = fs.readFileSync(path, {encoding: "utf8"});
//     } catch (error) {
//         output.printError(`Unable to open file: ${path}`);
//         process.exit(66);
//     }

//     const lox = new Lox(output);
//     const status = lox.run(source);

//     switch (status) {
//         case "SYNTAX_ERROR":
//         case "STATIC_ERROR":
//             return process.exit(65);
//         case "RUNTIME_ERROR":
//             return process.exit(70);
//         case "SUCCESS":
//             return process.exit(0);
//     }
// }

// function startRepl(): void {
//     const lox = new Lox(new ConsoleOutputHandler());

//     process.stdin.setEncoding("utf8");
//     const stdinInterface = readline.createInterface({
//         input: process.stdin,
//         output: process.stdout,
//     });

//     const nextLine = (): void => {
//         stdinInterface.question("> ", line => {
//             lox.run(line, {printLastExpr: true});
//             nextLine();
//         });
//     };

//     nextLine();
// }

// main(process.argv.slice(2));