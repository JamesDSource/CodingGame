#region Error
enum ERRORTYPE {
	SYNTAX,
	RUN_TIME
}
function error(_type, _pos) constructor {
	struct_is_error = true;
	prefix_msg = "";
	msg = "";
	switch(_type) {
		case ERRORTYPE.SYNTAX: prefix_msg = "SYNTAX ERROR: "; break;
		case ERRORTYPE.RUN_TIME: prefix_msg = "RUNTIME ERROR: "; break;
	}
	pos = _pos;
	
	function missing_char_error(_char) {
		msg = "Missing character expected, '" + _char + "'";
	}	
	function missing_number_error() {
		msg = "Missing number expected";
	}	
	function invalid_type_error(_type_expected) {
		msg = "Invalid type, \"" + _type_expected + "\" was expected.";
	}
	function node_not_found_error(_node_name) {
		msg = "Invalid node type, \"" + _node_name + "\"";
	}
	function missing_node_error() {
		msg = "Missing node expected";
	}
	function array_out_of_range_error() {
		msg = "Index out of range in array";
	}
	
	function get_error(text) {
		var _error_message = prefix_msg + msg;
		if(pos != -1) _error_message += ", at line " + string(string_get_line(text, pos) + 1);
		return _error_message;
	}
}

function is_error(_struct) {
	if(is_struct(_struct) && variable_struct_exists(_struct, "struct_is_error") && _struct.struct_is_error) return true;
	else return false;
}

#endregion
#region Lexer
enum TOKENTYPE {
	NONE,
	VARIABLE,
	NUMBER,
	STRING,
	COMMA,
	METHOD,
	FUNC,
	RETURN,
	ASSIGN,
	NEW_LINE,
	ADD,
	MULT,
	POWER,
	SUBTRACT,
	DIVIDE,
	MOD,
	EQUALS,
	GREATER,
	GREATER_EQUAL,
	LESSER,
	LESSER_EQUAL,
	OPEN_CURLY,
	CLOSE_CURLY,
	OPEN_PAREN,
	CLOSE_PAREN,
	OPEN_BRACKET,
	CLOSE_BRACKET,
	IF,
	ELIF,
	ELSE,
	LOOP,
	FOR,
	BREAK,
	IN,
	AND,
	OR,
	NOT,
	NOT_EQUALS
}

global.token_names = [
	"None",
	"Variable",
	"Number",
	"String",
	"Comma",
	"Method",
	"Function",
	"Return",
	"Assign",
	"New line",
	"Add",
	"Mult",
	"Power",
	"Subtract",
	"Divide",
	"Mod",
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
	"Loop",
	"For",
	"Break",
	"In",
	"And",
	"Or",
	"Not",
	"Not equals"
];

function token(_type, _value, _start_pos, _end_pos) constructor {
	type = _type;
	value = _value;
	start_pos = _start_pos;
	end_pos = _end_pos;
	
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
						var _peek_char = string_char_at(_code, _peek_index);
						if(string_pos(_peek_char, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_") == 0) _found_symbol = true;
					}
				}
				_peek_index--;
				var _symbol = string_copy(_code, i, _peek_index-i + 1);
				var _symbol_start = i;
				i = _peek_index;
				
				var _found_keyword = true;
				switch(_symbol) {
					case "if": array_push(_tokens, new token(TOKENTYPE.IF, _symbol, _symbol_start, _peek_index)); break;
					case "elif": array_push(_tokens, new token(TOKENTYPE.ELIF, _symbol, _symbol_start, _peek_index)); break;
					case "else": array_push(_tokens, new token(TOKENTYPE.ELSE, _symbol, _symbol_start, _peek_index)); break;
					case "loop": array_push(_tokens, new token(TOKENTYPE.LOOP, _symbol, _symbol_start, _peek_index)); break;
					case "for": array_push(_tokens, new token(TOKENTYPE.FOR, _symbol, _symbol_start, _peek_index)); break;
					case "break": array_push(_tokens, new token(TOKENTYPE.BREAK, _symbol, _symbol_start, _peek_index)); break;
					case "in": array_push(_tokens, new token(TOKENTYPE.IN, _symbol, _symbol_start, _peek_index)); break;
					case "func": array_push(_tokens, new token(TOKENTYPE.FUNC, _symbol, _symbol_start, _peek_index)); break;
					case "return": array_push(_tokens, new token(TOKENTYPE.RETURN, _symbol, _symbol_start, _peek_index)); break;
					case "true": array_push(_tokens, new token(TOKENTYPE.NUMBER, true, _symbol_start, _peek_index)); break;
					case "false": array_push(_tokens, new token(TOKENTYPE.NUMBER, false, _symbol_start, _peek_index)); break;
					case "and": array_push(_tokens, new token(TOKENTYPE.AND, _symbol, _symbol_start, _peek_index)); break;
					case "or": array_push(_tokens, new token(TOKENTYPE.OR, _symbol, _symbol_start, _peek_index)); break;
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
				
				if(_function_data != -1) array_push(_tokens, new token(TOKENTYPE.FUNCTION, _function_data, _symbol_start, _peek_index));
				else array_push(_tokens, new token(TOKENTYPE.VARIABLE, _symbol, _symbol_start, _peek_index));
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
						var _peek_char = string_char_at(_code, _peek_index);
						if(_peek_char == ".") {
							if(_has_dot) _found_number = true;
							else _has_dot = true;	
						}
						else if(string_pos(_peek_char, "0123456789") == 0) _found_number = true;
					}
				}
				_peek_index--;
				var _numb = string_copy(_code, i, _peek_index-i + 1);
				array_push(_tokens, new token(TOKENTYPE.NUMBER, real(_numb), i, _peek_index));
				i = _peek_index;
				break;
			case "\"":
				var _peek_index = i;
				var _found_string = false;
				while(!_found_string) {
					_peek_index++;
					if(_peek_index == _text_len + 1) _found_string = true;
					else {
						var _peek_char = string_char_at(_code, _peek_index);	
						if(_peek_char == "\"") _found_string = true;
					}
				}
				var _str = string_copy(_code, i+1, _peek_index-i-1);
				array_push(_tokens, new token(TOKENTYPE.STRING, _str, i, _peek_index));
				i = _peek_index;
				break;
			case "\n": 
			case ";": // New line
				array_push(_tokens, new token(TOKENTYPE.NEW_LINE, _char, i, i+1));
				break;
			case "=": // Addition and equals
				if(i + 1 <= _text_len && string_char_at(_code, i + 1) == "=") {
					array_push(_tokens, new token(TOKENTYPE.EQUALS, "==", i, i+2));
					i++;	
				}
				else array_push(_tokens, new token(TOKENTYPE.ASSIGN, _char, i, i+1));
				break;
			case ">":
				if(i + 1 <= _text_len && string_char_at(_code, i + 1) == "=") {
					array_push(_tokens, new token(TOKENTYPE.GREATER_EQUAL, ">=", i, i+2));
					i++;	
				}
				else array_push(_tokens, new token(TOKENTYPE.GREATER, _char, i, i+1));
				break;
			case "<":
				if(i + 1 <= _text_len && string_char_at(_code, i + 1) == "=") {
					array_push(_tokens, new token(TOKENTYPE.LESSER_EQUAL, "<=", i, i+2));
					i++;	
				}
				else array_push(_tokens, new token(TOKENTYPE.LESSER, _char, i, i+1));
				break;
			case "+": // Addition
				array_push(_tokens, new token(TOKENTYPE.ADD, _char, i, i+1));
				break;
			case "*": // Multiplication
				array_push(_tokens, new token(TOKENTYPE.MULT, _char, i, i+1));
				break;
			case "-": // Subtraction
				array_push(_tokens, new token(TOKENTYPE.SUBTRACT, _char, i, i+1));
				break;
			case "%": // Mod
				array_push(_tokens, new token(TOKENTYPE.MOD, _char, i, i+1));
				break;
			case "^": // Power
				array_push(_tokens, new token(TOKENTYPE.POWER, _char, i, i+1));
				break;
			case "/": // Divition
				if(i + 1 <= _text_len && string_char_at(_code, i + 1) == "/") {
					for(var j = i; j <= _text_len; j++) {
						if(string_char_at(_code, j) == "\n") break;
						i = j;
					}
				}
				else array_push(_tokens, new token(TOKENTYPE.DIVIDE, _char, i, i+1));
				break;
			case "(": // Opening parenthesis
				array_push(_tokens, new token(TOKENTYPE.OPEN_PAREN, _char, i, i+1));
				break;
			case ")": // Closing parenthesis
				array_push(_tokens, new token(TOKENTYPE.CLOSE_PAREN, _char, i, i+1));
				break;
			case "{": // Opening curly brace
				array_push(_tokens, new token(TOKENTYPE.OPEN_CURLY, _char, i, i+1));
				break;
			case "}": // Closing curly brace
				array_push(_tokens, new token(TOKENTYPE.CLOSE_CURLY, _char, i, i+1));
				break;			
			case "[": // Opening curly brace
				array_push(_tokens, new token(TOKENTYPE.OPEN_BRACKET, _char, i, i+1));
				break;
			case "]": // Closing curly brace
				array_push(_tokens, new token(TOKENTYPE.CLOSE_BRACKET, _char, i, i+1));
				break;
			case ",": // Comma
				array_push(_tokens, new token(TOKENTYPE.COMMA, _char, i, i+1));
				break;
			case "!": // Not
				if(i + 1 <= _text_len && string_char_at(_code, i+1) == "=") {
					array_push(_tokens, new token(TOKENTYPE.NOT_EQUALS, "!=", i, i+2));
					i++;
				}
				else array_push(_tokens, new token(TOKENTYPE.NOT, _char, i, i+1));
				break;
		}
	}
	return _tokens;
}
#endregion
#region Parser
#region Nodes for the parser
function parse_node_number(_value, _pos) constructor {
	node_name = "Number";
	position = _pos;
	value = _value;
	
	
	function to_string() {
		return string(value);
	}
}

function parse_node_string(_value, _pos) constructor {
	node_name = "String";
	position = _pos;
	value = _value;
	
	function to_string() {
		return value;
	}
}

function parse_node_binary_operation(_left, _right, _operation, _pos) constructor {
	node_name = "Binary operation";
	position = _pos;
	left = _left;
	right = _right;
	operation = _operation.type;
	
	function to_string() {
		var _operation_string = "";
		switch(operation) {
			case TOKENTYPE.ADD: _operation_string = "+"; break;
			case TOKENTYPE.SUBTRACT: _operation_string = "-"; break;
			case TOKENTYPE.MULT: _operation_string = "*"; break;
			case TOKENTYPE.DIVIDE: _operation_string = "/"; break;
			case TOKENTYPE.POWER: _operation_string = "**"; break;
			case TOKENTYPE.MOD: _operation_string = "%"; break;
		}
		return "[" + left.to_string() + " " + _operation_string + " " + right.to_string() + "]";
	}
}

function parse_node_unary_operation(_operation, _node, _pos) constructor {
	node_name = "Unary operation";
	position = _pos;
	operation = _operation.type;
	node = _node;
	
	function to_string() {
		var _operation_str = operation == TOKENTYPE.ADD ? "+" : "-";
		return "[" + _operation_str + "(" + node.to_string() + ")]";
	}
}

function parse_node_variable(_name, _index, _pos) constructor {
	node_name = "Variable";
	position = _pos;
	variable_name = _name;
	index = _index;
	
	function to_string() {
		return variable_name;
	}
}

function parse_node_assignment(_variable_name, _value, _index, _pos) constructor {
	node_name = "Assignment";
	position = _pos;
	variable_name = _variable_name;
	value = _value;
	index = _index;
	
	function to_string() {
		return "[ " + varibable_name + " = " + value.to_string() + " ]";
	}
}

function parse_node_if(_cases, _else_case, _pos) constructor {
	node_name = "If";
	position = _pos;
	cases = _cases;
	else_case = _else_case;
}

function parse_node_loop(_count_expression, _body, _pos) constructor {
	node_name = "Loop";
	position = _pos;
	count_expression = _count_expression;
	body = _body;
	
	break_out = false;
}

function parse_node_for(_variable_name, _list_expression, _body, _pos) constructor {
	node_name = "For";
	position = _pos;
	variable_name = _variable_name;
	list_expression = _list_expression;
	body = _body;
	
	break_out = false;
}

function parse_node_list(_expression_list, _pos) constructor {
	node_name = "List";
	position = _pos;
	expression_list = _expression_list;
	list_stop = false;
}

function parse_node_func(_variable_name, _arguments, _body, _pos) constructor {
	node_name = "Func";
	position = _pos;
	variable_name = _variable_name;
	arguments = _arguments;
	body = _body;
}

function parse_node_call(_identifier, _arguments, _pos) constructor {
	node_name = "Call";
	position = _pos;
	identifier = _identifier;
	arguments = _arguments;
	return_value = undefined;
}

function parse_node_return(_expression, _pos) constructor {
	node_name = "Return";
	position = _pos;
	expression = _expression;
}

function parse_node_break(_pos) constructor {
	node_name = "Break";
	position = _pos;
}

#endregion
function parser(_tokens) constructor {
	tokens = _tokens;
	token_index = -1;
	current_token = -1;
	peek_token = -1;
	
	function advance() {
		token_index++;
		if(token_index < array_length(tokens)) { 
			current_token = tokens[token_index];
			return true;
		}
		return false;
	}
	
	function peek(_amount) {
		var _peek_index = token_index + _amount;
		if(_peek_index < array_length(tokens)) {
			peek_token = tokens[_peek_index];
			return true;
		}
		peek_token = new token(TOKENTYPE.NONE, -1, -1, -1);
		return false;
	}
	
	function remove_newlines() {
		while(current_token.type == TOKENTYPE.NEW_LINE) {
			if(!advance()) break;
		}
	}
	
	function binary_operation(_func, _operation_tokens) {
		var _left_factor = _func();
		if(is_error(_left_factor)) return _left_factor;
		while(array_has(_operation_tokens, current_token.type)) {
			var _operation_token = current_token;
			if(advance()) {
				var _right_factor = _func();
				if(is_error(_right_factor)) return _right_factor;
				_left_factor = new parse_node_binary_operation(_left_factor, _right_factor, _operation_token, _operation_token.start_pos);
			}
			else break;
		}
		return _left_factor;
	}
	
	function if_statement(_pos) {
		var _cases = [];
		var _else_expression = undefined;
		function check_for_condition_expression(_cond) {
			if(advance()) {
				if(_cond) {
					var _condition = expression();
					if(is_error(_condition)) return _condition;
				}
				
				remove_newlines();
				
				// Check if there is not a open curly brace
				if(current_token.type != TOKENTYPE.OPEN_CURLY) {
					var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
					_error.missing_char_error("{");
					return _error;
				}
				
				var _eq_value = 1;
				var _statement_tokens = [];
				while(_eq_value != 0) {
					if(!advance()) {
						var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
						_error.missing_char_error("}");
						return _error;
					}
					if(current_token.type == TOKENTYPE.OPEN_CURLY) _eq_value++;
					else if(current_token.type == TOKENTYPE.CLOSE_CURLY) _eq_value--;
					if(_eq_value != 0) {
						array_push(_statement_tokens, current_token);
					}
				}
				
				var _statement_parser = new parser(_statement_tokens);
				var _if_ast = _statement_parser.get_AST();
				if(is_error(_if_ast)) return _if_ast;
				if(_cond) var _return =  {condition: _condition, statements: _if_ast};
				else var _return = _if_ast;
				delete _statement_parser;
				
				// delete newlines
				advance();
				while(peek(1) && peek_token.type == TOKENTYPE.NEW_LINE) {
					if(!advance()) break;
				}
				
				return _return;
			}
			else {
				var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
				_error.msg = "Expected expression";
				return _error;
			}
		}
		
		var _if_condition_statements = check_for_condition_expression(true);
		if(is_error(_if_condition_statements)) return _if_condition_statements;
		array_push(_cases, _if_condition_statements);
		
		while(peek(1) && peek_token.type == TOKENTYPE.ELIF) {
			advance();
			var _elif_condition_statements = check_for_condition_expression(true);
			if(is_error(_elif_condition_statements)) return _elif_condition_statements;
			array_push(_cases, _elif_condition_statements);
		}		
		
		if(peek(1) && peek_token.type == TOKENTYPE.ELSE) {
			advance();
			var _else_condition_statements = check_for_condition_expression(false);
			if(is_error(_else_condition_statements)) return _else_condition_statements;
			_else_expression =  _else_condition_statements;
		}
		return new parse_node_if(_cases, _else_expression, _pos);
	}
	
	function loop_statement(_pos) {
		if(advance()) {
			var _condition = expression();
			if(is_error(_condition)) return _condition;
			
			remove_newlines();
			
			// Check if there is not open curly
			if(current_token.type != TOKENTYPE.OPEN_CURLY) {
				var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
				_error.missing_char_error("{");
				return _error;
			}
			
			var _body_tokens = [];
			var _eq_value = 1;
			while(_eq_value != 0) {
				if(!advance()) {
					var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
					_error.missing_char_error("}");
					return _error;
				}
				if(current_token.type == TOKENTYPE.OPEN_CURLY) _eq_value++;
				else if(current_token.type == TOKENTYPE.CLOSE_CURLY) _eq_value--;
				if(_eq_value != 0) {
					array_push(_body_tokens, current_token);
				}
			}
			
			var _loop_parser = new parser(_body_tokens);
			var _body = _loop_parser.get_AST();
			if(is_error(_body)) return _body;
			delete _loop_parser;
			advance();
			return new parse_node_loop(_condition, _body, _pos);
		}
		else {
			var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
			_error.msg = "Expected condition";
			return _error;
		}
	}
	
	function for_statement(_pos) {
		advance();
		
		// Check if the token is not a variable
		if(current_token.type != TOKENTYPE.VARIABLE) {
			var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
			_error.msg = "Expected variable name";
			return _error;
		}
		// Get variable name
		var _variable_name = current_token.value;
		
		advance();
		
		// Check if the token is not an "In" token
		if(current_token.type != TOKENTYPE.IN) {
			var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
			_error.msg = "Expected keyword \"in\"";
			return _error;
		}
		
		if(!advance()) {
			var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
			_error.msg = "Expected expression";
			return _error;
		}
		
		// Get expression
		var _expression = expression();
		if(is_error(_expression)) return _expression;
	
		remove_newlines();
		
		// Check if there is not a open curly
		if(current_token.type != TOKENTYPE.OPEN_CURLY) {
			var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
			_error.missing_char_error("{");
			return _error;
		}
		
		var _body_tokens = [];
		var _eq_value = 1;
		while(_eq_value != 0) {
			if(!advance()) {
				var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
				_error.missing_char_error("}");
				return _error;
			}
			if(current_token.type == TOKENTYPE.OPEN_CURLY) _eq_value++;
			else if(current_token.type == TOKENTYPE.CLOSE_CURLY) _eq_value--;
			if(_eq_value != 0) {
				_bodyarray_push(_body_tokens, current_token);
			}
		}
		
		var _body_parser = new parser(_body_tokens);
		var _body = _body_parser.get_AST();
		delete _body_parser;
		if(is_error(_body)) return _body;
		advance();
		return new parse_node_for(_variable_name, _expression, _body, _pos);
	}
	
	function list_statement(_pos) {
		if(advance()) {
			var _list = [];
			if(current_token.type != TOKENTYPE.CLOSE_BRACKET) {
				remove_newlines();
				var _first_item = expression();
				if(is_error(_first_item)) return _first_item;
				_list = [_first_item];
				while(current_token.type == TOKENTYPE.COMMA) {
					if(!advance()) break;
					remove_newlines();
					
					if(current_token.type == TOKENTYPE.CLOSE_BRACKET) break;
					
					var _list_item = expression();
					if(is_error(_list_item)) return _list_item;
					array_push(_list, _list_item);
				}
				remove_newlines();
				if(current_token.type != TOKENTYPE.CLOSE_BRACKET) {
					var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
					_error.missing_char_error("]");
					return _error;
				}
				advance();
				return new parse_node_list(_list, _pos);
			}
			else {
				advance();
				return new parse_node_list([], _pos);
			}
		}
		else {
			var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
			_error.missing_char_error("]");
			return _error;
		}
	}
	
	function func_statement(_pos) {
		var _parameters = [];
		var _variable_name = "";
		
		advance();
	
		// Check if the current token is not a variable
		if(current_token.type != TOKENTYPE.VARIABLE) {
			var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
			_error.msg = "Expected variable";
			return _error;
		}
		_variable_name = current_token.value;
		advance();
		remove_newlines();
		
		// Check if the current token if not an open paren
		if(current_token.type != TOKENTYPE.OPEN_PAREN) {
			var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
			_error.missing_char_error("(");
			return _error;
		}
		
		advance();
		remove_newlines();
		
		// Check for parameters
		if(current_token.type == TOKENTYPE.VARIABLE) {
			_parameters = [current_token.value];
			advance();
			remove_newlines();
			while(current_token.type == TOKENTYPE.COMMA) {
				if(!advance()) break;
				remove_newlines();
				
				// Check if not a variable
				if(current_token.type != TOKENTYPE.VARIABLE) {
					var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
					_error.msg = "Expected variable";
					return _error;
				}
				array_push(_parameters, current_token.value);
				advance();
				remove_newlines();
			}
		}
		
		// Check if the current token is not a close paren
		if(current_token.type != TOKENTYPE.CLOSE_PAREN) {
			var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
			_error.missing_char_error(")");
			return _error;
		}
		
		advance();
		remove_newlines();
		
		// Check if there is not an open curly
		if(current_token.type != TOKENTYPE.OPEN_CURLY) {
			var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
			_error.missing_char_error("{");
			return _error;
		}
		
		// Get the body of the function
		var _body_tokens = [];
		var _eq_value = 1;
		while(_eq_value) {
			if(!advance()) break;
			
			if(current_token.type == TOKENTYPE.OPEN_CURLY) _eq_value++;
			else if(current_token.type == TOKENTYPE.CLOSE_CURLY) _eq_value--;
			
			if(_eq_value != 0) {
				array_push(_body_tokens, current_token);
			}
		}
		
		// Parsing the body of the function
		var _body_parser = new parser(_body_tokens);
		var _body = _body_parser.get_AST();
		delete _body_parser;
		
		advance();
		return new parse_node_func(_variable_name, _parameters, _body, _pos);
	}
	
	function atom() {
		var _return_token = current_token;
		switch(current_token.type) {
			case TOKENTYPE.OPEN_PAREN:
				if(advance()) {
					var _paren_expression = expression();
					if(is_error(_paren_expression)) return _paren_expression;
					if(current_token.type == TOKENTYPE.CLOSE_PAREN) {
						advance();
						return _paren_expression;
					}
				}
				else {
					var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
					_error.missing_char_error(")");
					return _error;
				}
				break;
			
			case TOKENTYPE.NUMBER:
				advance();
				return new parse_node_number(_return_token.value, _return_token.start_pos);
				break;
			
			case TOKENTYPE.STRING:
				advance();
				return new parse_node_string(_return_token.value, _return_token.start_pos);
				break;
				
			case TOKENTYPE.METHOD:
			case TOKENTYPE.VARIABLE:
				advance();
				if(current_token.type == TOKENTYPE.OPEN_PAREN) { // Checking for a function/method call
					var _parameters = [];
					var _identifier = _return_token.value;
					
					// Checking if the statement ends here
					if(!advance()) {
						var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
						_error.missing_char_error(")");
						return _error;
					}
					remove_newlines();
					
					// Checking if there are no arguments
					if(current_token.type != TOKENTYPE.CLOSE_PAREN) {
						var _expression = expression();
						if(is_error(_expression)) return _expression;
						_parameters = [_expression];
						remove_newlines();
						while(current_token.type == TOKENTYPE.COMMA) {
							if(!advance()) break;
							remove_newlines();
							
							var _expression = expression();
							if(is_error(_expression)) return _expression;
							array_push(_parameters, _expression);
							
							remove_newlines();
						}
						
						// Check if the current token is not a close paren
						if(current_token.type != TOKENTYPE.CLOSE_PAREN) {
							var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
							_error.missing_char_error(")");
							return _error;
						}
						advance();
					}
					return new parse_node_call(_identifier, _parameters, _return_token.start_pos);
				}
				else if(_return_token.type == TOKENTYPE.VARIABLE) { // Checking for a variable refrence
					// Checking for the index if this is a variable array
					var _index = -1;
					if(current_token.type == TOKENTYPE.OPEN_BRACKET) {
						if(advance()) {
							var _index_expression = expression();
							if(is_error(_index_expression)) return _index_expression;
							_index = _index_expression;
							
							if(current_token.type != TOKENTYPE.CLOSE_BRACKET) {
								var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
								_error.missing_char_error("]");
								return _error;
							}
							advance();
						}
						else {
							var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
							_error.missing_char_error("]");
							return _error;
						}
					}
					return new parse_node_variable(_return_token.value, _index, _return_token.start_pos);
				}
				else {
					var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
					_error.missing_char_error("(");
					return _error;
				}
				break;
			
			case TOKENTYPE.IF:
				return if_statement(_return_token.start_pos);
				break;
			
			case TOKENTYPE.LOOP:
				return loop_statement(_return_token.start_pos);
				break;			
			
			case TOKENTYPE.FOR:
				return for_statement(_return_token.start_pos);
				break;
			
			case TOKENTYPE.OPEN_BRACKET:
				return list_statement(_return_token.start_pos);
				break;
			
			case TOKENTYPE.FUNC:
				return func_statement(_return_token.start_pos);
				break;
	
			default:
				var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
				_error.msg = "Expected float, int, variable, '+', '-', or '('";
				return _error;
		}
	}
	
	
	function pow() {
		return binary_operation(atom, [TOKENTYPE.POWER]);
	}
	
	function factor() {
		var _return_token = current_token;
		switch(current_token.type) {
			case TOKENTYPE.ADD:
			case TOKENTYPE.SUBTRACT:
			case TOKENTYPE.NOT:
				if(advance()) {
					var _unary_node_wrap = factor();
					if(is_error(_unary_node_wrap)) return _unary_node_wrap;
					return new parse_node_unary_operation(_return_token, _unary_node_wrap, _return_token.start_pos);
				}
				else{
					var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
					_error.missing_number_error();
					return _error;
				}
				break;
		}
		
		return pow();
	}
	
	function term() {
		return binary_operation(factor, [TOKENTYPE.MULT, TOKENTYPE.DIVIDE, TOKENTYPE.MOD]);
	}
	
	function arithmatic() {
		return binary_operation(term, [TOKENTYPE.ADD, TOKENTYPE.SUBTRACT]);
	}
	
	function comparison() {
		return binary_operation(arithmatic, [TOKENTYPE.EQUALS, TOKENTYPE.GREATER, TOKENTYPE.LESSER, TOKENTYPE.GREATER_EQUAL, TOKENTYPE.LESSER_EQUAL, TOKENTYPE.NOT_EQUALS]);
	}
	
	function expression() {
		peek(1);
		if(current_token.type == TOKENTYPE.RETURN) {
			if(!advance()) {
				var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
				_error.msg = "Expression expected";
				return _error;
			}
				
			var _expression = expression();
			if(is_error(_expression)) return _expression;
				
			return new parse_node_return(_expression, current_token.start_pos);
		}		
		else if(current_token.type == TOKENTYPE.BREAK) {
			return new parse_node_break(current_token.start_pos);
		}
		else if(current_token.type == TOKENTYPE.VARIABLE && (peek_token.type == TOKENTYPE.ASSIGN || peek_token.type == TOKENTYPE.OPEN_BRACKET)) {
			var _variable_name = current_token.value;
			var _index = -1;
			var _assignment_statement = true;
			
			// Checks to see if this really is an assignment statement if the peek token was 
			/// an open bracket
			if(peek_token.type == TOKENTYPE.OPEN_BRACKET) {
				var _peek_amount = 1;
				while(true) {
					if(peek(_peek_amount)) {
						if(peek_token.type == TOKENTYPE.CLOSE_BRACKET) break;
						_peek_amount++;
					}
					else {
						var _error = new error(ERRORTYPE.SYNTAX, peek_token.start_pos);
						_error.missing_char_error("]");
						return _error;
					}
				}
				if(peek(_peek_amount+1) && peek_token.type == TOKENTYPE.ASSIGN) {
					// If it is an assignment, get the index of the variable we want to change
					advance();
					advance();
					var _index_expression = expression();
					if(is_error(_index_expression)) return _index_expression;
					_index = _index_expression;
				} 
				else _assignment_statement = false;
			}
			
			if(_assignment_statement) {
				advance();
				var _pos = current_token.start_pos;
				if(advance()) {
					// Checking for an index of an array
					var _expression = expression();
					if(is_error(_expression)) return _expression;
					else return new parse_node_assignment(_variable_name, _expression, _index, _pos);
				}
				else { // Check if there is no expression after the assignment
					var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
					_error.msg = "Expected an expression after '='";
					return _error;
				}
			}
		}
		return binary_operation(comparison, [TOKENTYPE.AND, TOKENTYPE.OR]);
	}
	
	function statements() {
		var _statements = [];
		
		remove_newlines();
		
		var _pos = current_token.start_pos;
		
		var _first_statement = expression();
		if(is_error(_first_statement)) return _first_statement;
		
		_statements = [_first_statement];
		
		var _are_statements = true;
		while(true) {
			var new_line_count = 0;
			while(current_token.type == TOKENTYPE.NEW_LINE) {
				if(!advance()) {
					_are_statements = false;
					break;
				}
				new_line_count++;
			}
			if(new_line_count == 0) _are_statements = false;
			if(!_are_statements) break;
			else {
				var _statement = expression(); 
				if(is_error(_statement)) return _statement;
				array_push(_statements, _statement);
			}
		}
		
		return new parse_node_list(_statements, _pos);
	}
	
	function get_AST() {
		var _can_parse = false;
		for(var i = 0; i < array_length(tokens); i++) {
			if(tokens[i].type != TOKENTYPE.NEW_LINE) {
				_can_parse = true;
				break;
			}	
		}
		if(_can_parse) {
			token_index = -1;
			current_token = -1;
			peek_token = -1;
			advance();
			return statements();
		}
		return undefined;
	}
	
}
#endregion
#region Scope
function scope(_parent) constructor {
	parent = _parent;
	data = {};
	function get_value(_var_name) {
		if(variable_struct_exists(data, _var_name)) return data[$ _var_name];
		else if(is_struct(parent)) return parent.get_value(_var_name);
		else return undefined;
	}
	function set_value(_var_name, _value, _look_for_parent) {
		if(_look_for_parent && !variable_struct_exists(data, _var_name) && is_struct(parent)) {
			var _tree = parent;
			var _var_search = true;
			while(_var_search) {
				if(variable_struct_exists(_tree.data, _var_name)) {
					_tree.data[$ _var_name] = _value;
					return undefined;
				}
				else if(is_struct(_tree.parent)) _tree = _tree.parent;
				else _var_search = false;
			}
		}
		data[$ _var_name] = _value;
	}
}
#endregion
#region Interpreter
function interpreter() constructor {
	function add_scope_layer() {
		var _old_scope = current_scope;
		current_scope = new scope(-1);
		if(is_struct(_old_scope)) {
			current_scope.parent = _old_scope;
		}
	}	
	function remove_scope_layer() {
		if(is_struct(current_scope)) {
			var _old_scope = current_scope;
			if(is_struct(_old_scope.parent)) current_scope = _old_scope.parent;
			else current_scope = -1;
			delete _old_scope;
		}
	}
	
	current_scope = -1;
	
	function run(_AST) {
		if(is_struct(_AST)) {
			if(is_error(_AST)) return _AST;
			else {
				add_scope_layer();
				var _run_result = get_result(_AST, -1);
				return _run_result;
				while(is_struct(current_scope)) remove_scope_layer();
			};
		}
	}
	
	function get_result(_node, _parent) {
		// Checks to see if this is a node
		// If it is not, returns an error
		if(!is_struct(_node) || !variable_struct_exists(_node, "node_name")) {
			return undefined;
		}
		
		_node.parent_node = _parent;
		
		// Find return condition based on the name of the node
		switch(_node.node_name) {
			case "Number": 
				return _node.value; 
				break;	
				
			case "String": 
				return _node.value; 
				break;
			
			case "Binary operation":
				var _left_result = get_result(_node.left, _node);
				var _right_result = get_result(_node.right, _node);
				if(is_error(_left_result)) return _left_result;
				if(is_error(_right_result)) return _right_result;
				
				switch(_node.operation) {
					case TOKENTYPE.ADD: 			
						if(is_string(_left_result)) {
							_right_result = string(_right_result);
						}
						else if(is_string(_right_result)) {
							_left_result = string(_left_result);
						}
						else if(!is_real(_left_result) || !is_real(_right_result)) {
							var _error = new error(ERRORTYPE.RUN_TIME, _node.position);
							_error.msg = "Invalid type";
							return _error;
							
						}
						return _left_result + _right_result; break;
					case TOKENTYPE.SUBTRACT:
						if(!is_real(_right_result) || !is_real(_left_result)) {
							var _error = new error(ERRORTYPE.RUN_TIME, _node.position);
							_error.msg = "Invalid type";
							return _error;
						}
						return _left_result - _right_result; break;
					case TOKENTYPE.MULT:			
						if(!is_real(_right_result) || !is_real(_left_result)) {
							var _error = new error(ERRORTYPE.RUN_TIME, _node.position);
							_error.msg = "Invalid type";
							return _error;
						}
						return _left_result*_right_result; 
						break;
					case TOKENTYPE.POWER:			
						if(!is_real(_right_result) || !is_real(_left_result)) {
							var _error = new error(ERRORTYPE.RUN_TIME, _node.position);
							_error.msg = "Invalid type";
							return _error;
						}
						return power(_left_result, _right_result); 
						break;
					case TOKENTYPE.MOD:
					case TOKENTYPE.DIVIDE:
						if(!is_real(_right_result) || !is_real(_left_result)) {
							var _error = new error(ERRORTYPE.RUN_TIME, _node.position);
							_error.msg = "Invalid type";
							return _error;
						}
					
						if(_right_result == 0) {
							var _error = new error(ERRORTYPE.RUN_TIME, _node.position);
							_error.msg = "Attempted to divide by 0";
							return _error;
						}
						else {
							if(_node.operation == TOKENTYPE.DIVIDE) return _left_result/_right_result;
							else if(_node.operation == TOKENTYPE.MOD) return _left_result%_right_result;
						}
						break;
					case TOKENTYPE.EQUALS:			return _left_result == _right_result; break;
					case TOKENTYPE.GREATER:			return _left_result > _right_result; break;
					case TOKENTYPE.LESSER:			return _left_result < _right_result; break;
					case TOKENTYPE.GREATER_EQUAL:	return _left_result >= _right_result; break;
					case TOKENTYPE.LESSER_EQUAL:	return _left_result <= _right_result; break;
					case TOKENTYPE.NOT_EQUALS:		return _left_result != _right_result; break;
					case TOKENTYPE.AND:				return _left_result && _right_result; break;
					case TOKENTYPE.OR:				return _left_result || _right_result; break;
				}
				break;
			
			case "Unary operation":
				var _return_result = get_result(_node.node, _node);
				if(!is_error(_return_result)) {
					if(!is_real(_return_result)) {
						var _error = new error(ERRORTYPE.RUN_TIME, _node.position);
						_error.msg = "Invalid type";
						return _error;
					}
					
					switch(_node.operation) {
						case TOKENTYPE.SUBTRACT:
							_return_result *= -1;
							break;
						
						case TOKENTYPE.NOT:
							_return_result = !_return_result;
							break;
					}
				}
				return _return_result;
				break;
			
			case "Variable":
				var _return_result = current_scope.get_value(_node.variable_name);
				if(is_undefined(_return_result)) {
					var _error = new error(ERRORTYPE.RUN_TIME, _node.position);
					_error.msg = _node.variable_name + " is undefined in the current scope";
					return _error;
				}
				
				if(_node.index != -1) {
					var _index_value = get_result(_node.index, _node);
					if(is_error(_index_value)) return _index_value;
					
					if(is_real(_index_value)) _index_value = floor(_index_value);
					else {
						var _error = new error(ERRORTYPE.RUN_TIME, _node.position);
						_error.invalid_type_error("int");
						return _error;
					}
					
					if(is_array(_return_result)) {
						if(_index_value < 0 || _index_value >= array_length(_return_result)) {
							var _error = new error(ERRORTYPE.RUN_TIME, _node.position);
							_error.array_out_of_range_error();
							return _error;
						}
						
						return _return_result[_index_value];
					}
					
				}
				
				return _return_result;
				break;
			
			case "Assignment":
				var _return_result = get_result(_node.value, _node);
				if(is_error(_return_result)) return _return_result;
				
				if(_node.index != -1) {
					var _variable = current_scope.get_value(_node.variable_name);
					if(is_array(_variable)) {
						var _index = get_result(_node.index, _node);
						if(is_error(_index)) return _index;
						
						if(is_real(_index)) _index = floor(_index);
						else {
							var _error = new error(ERRORTYPE.RUN_TIME, _node.index.position);
							_error.invalid_type_error("int");
							return _error;
						}
						
						if(_index < 0) {
							var _error = new error(ERRORTYPE.RUN_TIME, _node.index.position);
							_error.array_out_of_range_error();
							return _error;
						}
						
						_variable[_index] = _return_result;
						current_scope.set_value(_node.variable_name, _variable, true);
						return _variable;
					}
				}
				else current_scope.set_value(_node.variable_name, _return_result, true);
				return _return_result;
				break;
			
			case "If":
				add_scope_layer();
				for(var i = 0; i < array_length(_node.cases); i++) {
					var _case = _node.cases[i];
					
					var _cond_result = get_result(_case.condition, _node);
					if(is_error(_cond_result)) return _cond_result;
					
					if(_cond_result) {
						var _result = get_result(_case.statements, _node);
						remove_scope_layer();
						return _result;
					}
				}
				if(!is_undefined(_node.else_case)) {
					var _result = get_result(_node.else_case, _node);
					remove_scope_layer();
					return _result;
				}
				remove_scope_layer();
				break;
			
			case "Loop":
				add_scope_layer();
				var _count = get_result(_node.count_expression, _node);
				if(is_error(_count)) return _count;
				
				// Check if count is a number
				if(is_real(_count)) _count = floor(_count);
				else {
					var _error = new error(ERRORTYPE.RUN_TIME, _node.position);
					_error.missing_number_error();
					return _error;
				}
				
				for(var i = 0; i < _count; i++) {
					var _body = get_result(_node.body, _node);
					if(is_error(_body) || i == _count-1 || _node.break_out) {
						remove_scope_layer();
						_node.break_out = false;
						return _body;
					}
				}
			
			case "For":
				add_scope_layer();
				var _list_expression_result = get_result(_node.list_expression, _node);
				if(is_error(_list_expression_result)) return _list_expression_result;
				
				if(!is_array(_list_expression_result)) {
					var _error = new error(ERRORTYPE.RUN_TIME, _node.position);
					_error.msg = "Array expected after keyword \"in\"";
					return _error;
				}
				
				for(var i = 0; i < array_length(_list_expression_result); i++) {
					current_scope.set_value(_node.variable_name, _list_expression_result[i], false);
					var _body_result = get_result(_node.body, _node);
					if(is_error(_body_result) || i == array_length(_list_expression_result)-1 || _node.break_out) {
						remove_scope_layer();
						_node.break_out = false;
						return _body_result;
					}
				}
				break;
			
			case "List":
				var _return_list = [];
				for(var i = 0; i < array_length(_node.expression_list); i++) {
					var _list_item_result = get_result(_node.expression_list[i], _node);
					if(is_error(_list_item_result)) return _list_item_result;
					array_push(_return_list, _list_item_result);
					if(_node.list_stop) {
						_node.list_stop = false;
						break;
					}
				}
				return _return_list;
			
			case "Func":
				current_scope.set_value(
					_node.variable_name,
					{
						node: _node,
						func: function(_arguments, _parameters, _body, _scope, _get_result, _call) {
							// Check if there are enough arguments
							if(array_length(_arguments) < array_length(_parameters)) {
								var _error = new error(ERRORTYPE.RUN_TIME, _node.position);
								_error.msg = "More arguments expected";
								return _error;
							}
							
							// Setting all the arguments in the scope
							for(var i = 0 ; i < array_length(_parameters); i++) {
								_scope.set_value(_parameters[i], _arguments[i], false);
							}
							
							// Calling the body of the function
							return _get_result(_body, _call);
						}
					},
					true
				);
				break;
			
			case "Call":
				var _call_method_function = current_scope.get_value(_node.identifier);
				
				// Check if it is defined
				if(is_undefined(_call_method_function)) {
					var _error = new error(ERRORTYPE.RUN_TIME, _node.position);
					_error.msg = _node.identifier + " is undefined in the current scope";
					return _error;
				}				
				
				// Check if it is a method or function
				if(!is_struct(_call_method_function)) {
					var _error = new error(ERRORTYPE.RUN_TIME, _node.position);
					_error.msg = _node.identifier + " is not a method or function";
					return _error;
				}
				
				// Get the arguments
				var _arguments = [];
				for(var i = 0; i < array_length(_node.arguments); i++) {
					var _arg = get_result(_node.arguments[i], _node);
					if(is_error(_arg)) return _arg;
					array_push(_arguments, _arg);
				}
				
				add_scope_layer();
				_call_method_function.func(_arguments, _call_method_function.node.arguments, _call_method_function.node.body, current_scope, get_result, _node);
				remove_scope_layer();
				
				var _return = _node.return_value;
				_node.return_value = undefined;
				return _return;
				break;
			
			case "Return":
				// Climb up the parent tree and stop any lists
				// Look for a function call
				var _call_found = false;
				var _tree = _parent;
				while(is_struct(_tree)) {
					if(_tree.node_name == "List") {
						_tree.list_stop = true;
					}
					else if(_tree.node_name == "Call") {
						var _result = get_result(_node.expression);
						if(is_error(_result)) return _result;
						
						_tree.return_value = _result;
						_call_found = true;
						break;
					}
					_tree = _tree.parent_node;
				}
				if(!_call_found) {
					var _error = new error(ERRORTYPE.RUN_TIME, _node.position);
					_error.msg = "Could not find a function to return";
					return _error;
				}
				break;	
			
			case "Break":
				// Climb up the parent tree and stop any lists
				// Look for a loop
				var _loop_found = false;
				var _tree = _parent;
				while(is_struct(_tree)) {
					if(_tree.node_name == "List") {
						_tree.list_stop = true;
					}
					else if(_tree.node_name == "Loop" || _tree.node_name == "For") {
						_tree.break_out = true;
						_loop_found = true;
						break;
					}
					_tree = _tree.parent_node;
				}
				if(!_loop_found) {
					var _error = new error(ERRORTYPE.RUN_TIME, _node.position);
					_error.msg = "Could not find anything to break out of";
					return _error;
				}
				break;
			
			default: // If there is no return condition for this node, then return an error
				var _error = new error(ERRORTYPE.RUN_TIME, _node.position);
				_error.node_not_found_error(_node.node_name);
				return _error;
				break;
		}
	}
}
#endregion