function updateParserState(pstate:ParserState, index:Int, result:Array<String>):ParserState {
	pstate.index = index;
	pstate.result = result;

	return pstate;
};

function updateParserResult(pstate:ParserState, result:Array<String>):ParserState {
	pstate.result = result;

	return pstate;
};

function updateParserError(pstate:ParserState, errorMsg:String):ParserState {
	pstate.isError = true;
	pstate.error = [errorMsg];

	return pstate;
};

typedef ParserState = {
	var code:String;
	var isError:Bool;
	var error:Array<String>;
	var index:Int;
	var result:Array<String>;
}

class Parser {
	public var parserStateTransformerFn:ParserState->ParserState;

	public function new(parserStateTransformerFn) {
		this.parserStateTransformerFn = parserStateTransformerFn;
	}

	public function run(targetString) {
		var initialState:ParserState = {
			code: targetString,
			index: 0,
			result: [],
			isError: false,
			error: []
		};

		return this.parserStateTransformerFn(initialState);
	}

	public function map(fn) {
		return new Parser(function(pstate:ParserState):ParserState {
			var nextState:ParserState = this.parserStateTransformerFn(pstate);

			if (nextState.isError) {
				return nextState;
			};

			return updateParserResult(nextState, fn(nextState.result));
		});
	}

	public function errorMap(fn) {
		return new Parser(function(pstate:ParserState):ParserState {
			var nextState = this.parserStateTransformerFn(pstate);
			if (!nextState.isError) {
				return nextState;
			};

			return updateParserError(nextState, fn(nextState.error, nextState.index));
		});
	}
}

function str(s:String) {
    return new Parser(function(pstate:ParserState):ParserState {

        trace (pstate);

        if (pstate.isError) {
            return pstate;
        }

        var slicedTarget = pstate.code.substring(pstate.index);

        if (slicedTarget.length == 0) {
            return updateParserError(pstate, 'str: Tried to match "${s}", but got Unexpected end of input.');
        }

        if (s == slicedTarget.substr(0, s.length)) {
            return updateParserState(pstate, pstate.index + s.length, [s]);
		}

        return updateParserError(pstate, 'str: Tried to match "${s}", but got "${pstate.code.substring(pstate.index, pstate.index + 10)} ....."' );
    });
}

function sequenceOf(parsers:Array<Parser>) {
    return new Parser(function(pstate:ParserState):ParserState {

        if (pstate.isError) {
            return pstate;
        }

        var results = [];
        var nextState = pstate;
  
        for (p in parsers) {
            nextState = p.parserStateTransformerFn(nextState);
            results = results.concat(nextState.result);
        }
    
        return updateParserResult(nextState, results);
    });
}

function choice(parsers:Array<Parser>) {
    return new Parser(function(pstate:ParserState):ParserState {

        if (pstate.isError) {
            return pstate;
        }

        // var nextState = pstate;

        for (p in parsers) {
			trace(p.index);
            var nextState = p.parserStateTransformerFn(pstate);
            trace ("Checking parser: " + nextState);
            if (!nextState.isError) {
                trace ("Matched with " + nextState.result);
                return nextState;
            }
        }
    
        return updateParserError(pstate, 'choice: Unable to match with parsers at index ${pstate.index}');
    });
}

class Main {
	static public function main() {

        var parser = sequenceOf([
            choice([str("hi"), str("xxx"), str("hello")]),
            
            str(" "),
            str("world"),
        ]);
        var output = parser.run("hello world");

        trace (output);

	}
}
