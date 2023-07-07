package main

import (
	"fmt"
	"hexal/compiler"
	"os"
)

func main() {
	hexalLogo := `
                          
   ░░░░░░░░░        █░@░█    
      ░░░░░░░░░░░░   ▀█▀    ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄ 
   ░░░░░░  O    O     █     █░░█▄█░░█░░░░▄▄▄█░░▀█▀░░▄░░▄░░░▄░░░███▀█    
██▌   ░░░██▀▀▀ ▀▀▌   ██▌    █░░░░░░░█░░░█▄▄▄██▄░░░▄██░█▄█░░█░░░█████  
   ░░░░░░████▄▄███░░░ █     █  ▄▄▄  █    ▄▄▄██  ▀  ██      █   █████ 
      ░░░░░░███░░░    █     █  █ █  █   █▄▄▄█   █   █  █   █       █
   ░░░░░░░░░░░░░░░    █     █▄▄█▄█▄▄▄▄▄▄▄▄▄▄▄▄▄███▄▄█▄▄█▄▄▄█▄▄▄▄▄▄▄█    Language v0.1.0
░░░░░░░░░██▌░░░██▌    █     ____________________________________________________________
`

	fmt.Println(os.Args)

	if len(os.Args) < 2 {
		fmt.Println(hexalLogo)
		fmt.Println("Hexal Programming Language")
		fmt.Println("Version 0.0.1")
		fmt.Println("Usage: hexal [command] [options]?")
		fmt.Println("Note: Only Run command is supported for now!")
	} else if len(os.Args) == 3 && os.Args[1] == "run" {
		fmt.Println("Parsing file: ", os.Args[2])
		compiler.CompileFile(os.Args[2])
	} else {
		fmt.Println("ERROR: Incorrect Hexal Command")
		fmt.Println("Note: Only Run command is supported for now!")
	}

}
