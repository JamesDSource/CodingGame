// Lexer
enum TOKENTYPE {
	PARSED,
	VARIABLE,
	NUMBER,
	STRING,
	BOOL,
	COMMA,
	FUNCTION,
	ASSIGN,
	SEMI_COLON,
	ADD,
	MULT,
	SUBTRACT,
	DIVIDE,
	EQUALS,
	GREATER,
	GREATEREQUAL,
	LESSER,
	LESSEREQUAL,
	OPEN_CURLY,
	CLOSE_CURLY,
	OPEN_PAREN,
	CLOSE_PAREN,
	OPEN_BRACKET,
	CLOSE_BRACKET,
	IF,
	ELIF,
	ELSE,
	LOOP
}

global.token_names = [
	"Parsed",
	"Variable",
	"Number",
	"String",
	"Bool",
	"Comma",
	"Function",
	"Assign",
	"Semi Colon",
	"Add",
	"Mult",
	"Subtract",
	"Divide",
	"Equals",
	"Greater",
	"Greater Equal",
	"Lesser",
	"Lesser Equal",
	"Open Curly",
	"Close Curly",
	"Open Paren",
	"Close Paren",
	"Open Bracket",
	"Close Bracket",
	"If",
	"Elif",
	"Else",
	"Loop"
];

function token(_type, _value) constructor {
	type = _type;
	value = _value;
	
	function token_string() {
		return global.token_names[type] + " token: " + string(value);
	}
}

function get_tokens(_code) {
	var _tokens = [];
	var _text_len = string_length(_code);
	
	for(var i = 1; i <= _text_len; i++) {
		var _char = string_char_at(_code, i);
		switch(_char) {
			case "_":
			case "a":
			case "b":
			case "c":
			case "d":
			case "e":
			case "f":
			case "g":
			case "h":
			case "i":
			case "j":
			case "k":
			case "l":
			case "m":
			case "n":
			case "o":
			case "p":
			case "q":
			case "r":
			case "s":
			case "t":
			case "u":
			case "v":
			case "w":
			case "x":
			case "y":
			case "z":
			case "A":
			case "B":
			case "C":
			case "D":
			case "E":
			case "F":
			case "G":
			case "H":
			case "I":
			case "J":
			case "K":
			case "L":
			case "M":
			case "N":
			case "O":
			case "P":
			case "Q":
			case "R":
			case "S":
			case "T":
			case "U":
			case "V":
			case "W":
			case "X":
			case "Y":
			case "Z":
				var _peek_index = i;
				var _found_symbol = false;
				while(!_found_symbol) {
					_peek_index++;
					if(_peek_index == _text_len + 1) _found_symbol = true;
					else {
						var _peek_char = string_char_at(text_editing, _peek_index);
						if(string_pos(_peek_char, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_") == 0) _found_symbol = true;
					}
				}
				_peek_index--;
				var _symbol = string_copy(text_editing, i, _peek_index-i + 1);
				i = _peek_index;
				
				var _found_keyword = true;
				switch(_symbol) {
					case "if": _tokens = array_append(_tokens, new token(TOKENTYPE.IF, _symbol)); break;
					case "elif": _tokens = array_append(_tokens, new token(TOKENTYPE.ELIF, _symbol)); break;
					case "else": _tokens = array_append(_tokens, new token(TOKENTYPE.ELSE, _symbol)); break;
					case "loop": _tokens = array_append(_tokens, new token(TOKENTYPE.LOOP, _symbol)); break;
					case "true": _tokens = array_append(_tokens, new token(TOKENTYPE.BOOL, true)); break;
					case "false": _tokens = array_append(_tokens, new token(TOKENTYPE.BOOL, false)); break;
					default: _found_keyword = false; break;
				}
				if(_found_keyword) break;
				
				// Looking to see if symbol is a function
				var _function_data = -1;
				//for(var j = 0; j < ds_list_size(included_functions); j++) {
				//	for(var k = 0; k < array_length(included_functions[| j].methods); k++) {
				//		if(included_functions[| j].methods[k].name == _symbol) {
				//			_function_data = included_functions[| j].methods[k];
				//			break;
				//		}
				//	}
				//}
				
				if(_function_data != -1) _tokens = array_append(_tokens, new token(TOKENTYPE.FUNCTION, _function_data));
				else _tokens = array_append(_tokens, new token(TOKENTYPE.VARIABLE, _symbol));
				break;
			case "0": // Numbers
			case "1":
			case "2":
			case "3":
			case "4":
			case "5":
			case "6":
			case "7":
			case "8":
			case "9":
				var _peek_index = i;
				var _found_number = false;
				var _has_dot = false;
				while(!_found_number) {
					_peek_index++;
					if(_peek_index == _text_len + 1) _found_number = true;
					else {
						var _peek_char = string_char_at(text_editing, _peek_index);
						if(_peek_char == ".") {
							if(_has_dot) _found_number = true;
							else _has_dot = true;	
						}
						else if(string_pos(_peek_char, "0123456789") == 0) _found_number = true;
					}
				}
				_peek_index--;
				var _numb = string_copy(text_editing, i, _peek_index-i + 1);
				i = _peek_index;
				_tokens = array_append(_tokens, new token(TOKENTYPE.NUMBER, real(_numb)));
				break;
			case "\"":
				var _peek_index = i;
				var _found_string = false;
				while(!_found_string) {
					_peek_index++;
					if(_peek_index == _text_len + 1) _found_string = true;
					else {
						var _peek_char = string_char_at(text_editing, _peek_index);	
						if(_peek_char == "\"") _found_string = true;
					}
				}
				var _str = string_copy(text_editing, i+1, _peek_index-i-1);
				_tokens = array_append(_tokens, new token(TOKENTYPE.STRING, _str));
				i = _peek_index;
				break;
			case ";": // Semi Colon
				_tokens = array_append(_tokens, new token(TOKENTYPE.SEMI_COLON, _char));
			case "=": // Addition and equals
				if(i + 1 <= _text_len && string_char_at(text_editing, i + 1) == "=") {
					_tokens = array_append(_tokens, new token(TOKENTYPE.EQUALS, "=="));
					i++;	
				}
				else _tokens = array_append(_tokens, new token(TOKENTYPE.ASSIGN, _char));
				break;
			case ">":
				if(i + 1 <= _text_len && string_char_at(text_editing, i + 1) == "=") {
					_tokens = array_append(_tokens, new token(TOKENTYPE.GREATEREQUAL, ">="));
					i++;	
				}
				else _tokens = array_append(_tokens, new token(TOKENTYPE.GREATER, _char));
				break;
			case "<":
				if(i + 1 <= _text_len && string_char_at(text_editing, i + 1) == "=") {
					_tokens = array_append(_tokens, new token(TOKENTYPE.LESSEREQUAL, "<="));
					i++;	
				}
				else _tokens = array_append(_tokens, new token(TOKENTYPE.LESSER, _char));
				break;
			case "+": // Addition
				_tokens = array_append(_tokens, new token(TOKENTYPE.ADD, _char));
				break
			case "*": // Multiplication
				_tokens = array_append(_tokens, new token(TOKENTYPE.MULT, _char));
				break;
			case "-": // Subtraction
				_tokens = array_append(_tokens, new token(TOKENTYPE.SUBTRACT, _char));
				break;
			case "/": // Divition
				_tokens = array_append(_tokens, new token(TOKENTYPE.DIVIDE, _char));
				break;
			case "(": // Opening parenthesis
				_tokens = array_append(_tokens, new token(TOKENTYPE.OPEN_PAREN, _char));
				break;
			case ")": // Closing parenthesis
				_tokens = array_append(_tokens, new token(TOKENTYPE.CLOSE_PAREN, _char));
				break;
			case "{": // Opening curly brace
				_tokens = array_append(_tokens, new token(TOKENTYPE.OPEN_CURLY, _char));
				break;
			case "}": // Closing curly brace
				_tokens = array_append(_tokens, new token(TOKENTYPE.CLOSE_CURLY, _char));
				break;			
			case "[": // Opening curly brace
				_tokens = array_append(_tokens, new token(TOKENTYPE.OPEN_BRACKET, _char));
				break;
			case "]": // Closing curly brace
				_tokens = array_append(_tokens, new token(TOKENTYPE.CLOSE_BRACKET, _char));
				break;
			case ",": // Comma
				_tokens = array_append(_tokens, new token(TOKENTYPE.COMMA, _char));
				break;
		}
	}
	return _tokens;
}