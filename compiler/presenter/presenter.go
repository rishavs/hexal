package presenter

import (
	"os"
	"strconv"

	"github.com/fatih/color"
)

// show, warn, fail
func Fail(errKind string, errMessage string, errLine int, errPos int) {
	color.Red("ERROR at Line " + strconv.Itoa(errLine) + ", Pos " + strconv.Itoa(errPos) + " : [" + errKind + "] " + errMessage + "\n")
	os.Exit(1)
}
