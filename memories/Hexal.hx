

typedef ParserState = {
	var success     : Bool;
    var kind        : String;
    var expected    : String;
    var index       : Int;
    var remaining   : Int;

}

typedef ParsingFunction = ParserState -> ParserState;


class Parser {
    var code    : String;
    var i       = 0;
    var line    = 1;
	var errors  : Array<String>;

    public function new(code : String) {
        this.code = code;
    }

    public function s(str: String) {
        return function (): ParserState {

            if (this.i == this.code.length ) {
                errors.push ('str: Tried to match "${s}", but got Unexpected end of input.');
                return { success: false, kind: "s", expected: str, index: this.i, remaining: this.code.length - this.i };
            }
    
            if (str == code.substr(this.i, str.length)) {
                this.i += str.length;
                return {success : true, kind: "s", expected: str, index: this.i, remaining: this.code.length - this.i };
            } else {
                return {success : false, kind: "s", expected: str, index: this.i, remaining: this.code.length - this.i };
            }
            
        }
    }

    public function seq(parsers : Array<>)
        
}

class Hexal {
	static public function main() {
        trace ("Starting Parser...");
        var p = new Parser("Hello World");
        var program = p.s("Hello");

        trace (program());
    }
}