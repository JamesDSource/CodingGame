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
	
	function get_error() {
		var _error_message = prefix_msg + msg;
		if(pos != -1) _error_message += ", at line " + string(pos);
		return _error_message;
	}
}

function is_error(_struct) {
	if(is_struct(_struct) && variable_struct_exists(_struct, "struct_is_error") && _struct.struct_is_error) return true
	else return false;
}

#endregion
#region Lexer
enum TOKENTYPE {
	PARSED,
	VARIABLE,
	VAR,
	NUMBER,
	STRING,
	BOOL,
	COMMA,
	FUNCTION,
	ASSIGN,
	SEMI_COLON,
	ADD,
	MULT,
	POWER,
	SUBTRACT,
	DIVIDE,
	MOD,
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
	LOOP,
	AND,
	OR,
	NOT,
	NOT_EQUALS
}

global.token_names = [
	"Parsed",
	"Variable",
	"Var",
	"Number",
	"String",
	"Bool",
	"Comma",
	"Function",
	"Assign",
	"Semi Colon",
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
					case "var": _tokens = array_append(_tokens, new token(TOKENTYPE.VAR, _symbol, _symbol_start, _peek_index)); break;
					case "if": _tokens = array_append(_tokens, new token(TOKENTYPE.IF, _symbol, _symbol_start, _peek_index)); break;
					case "elif": _tokens = array_append(_tokens, new token(TOKENTYPE.ELIF, _symbol, _symbol_start, _peek_index)); break;
					case "else": _tokens = array_append(_tokens, new token(TOKENTYPE.ELSE, _symbol, _symbol_start, _peek_index)); break;
					case "loop": _tokens = array_append(_tokens, new token(TOKENTYPE.LOOP, _symbol, _symbol_start, _peek_index)); break;
					case "true": _tokens = array_append(_tokens, new token(TOKENTYPE.BOOL, true, _symbol_start, _peek_index)); break;
					case "false": _tokens = array_append(_tokens, new token(TOKENTYPE.BOOL, false, _symbol_start, _peek_index)); break;
					case "and": _tokens = array_append(_tokens, new token(TOKENTYPE.AND, _symbol, _symbol_start, _peek_index)); break;
					case "or": _tokens = array_append(_tokens, new token(TOKENTYPE.OR, _symbol, _symbol_start, _peek_index)); break;
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
				
				if(_function_data != -1) _tokens = array_append(_tokens, new token(TOKENTYPE.FUNCTION, _function_data, _symbol_start, _peek_index));
				else _tokens = array_append(_tokens, new token(TOKENTYPE.VARIABLE, _symbol, _symbol_start, _peek_index));
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
				_tokens = array_append(_tokens, new token(TOKENTYPE.NUMBER, real(_numb), i, _peek_index));
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
				_tokens = array_append(_tokens, new token(TOKENTYPE.STRING, _str, i, _peek_index));
				i = _peek_index;
				break;
			case ";": // Semi Colon
				_tokens = array_append(_tokens, new token(TOKENTYPE.SEMI_COLON, _char, i, i+1));
			case "=": // Addition and equals
				if(i + 1 <= _text_len && string_char_at(_code, i + 1) == "=") {
					_tokens = array_append(_tokens, new token(TOKENTYPE.EQUALS, "==", i, i+2));
					i++;	
				}
				else _tokens = array_append(_tokens, new token(TOKENTYPE.ASSIGN, _char, i, i+1));
				break;
			case ">":
				if(i + 1 <= _text_len && string_char_at(_code, i + 1) == "=") {
					_tokens = array_append(_tokens, new token(TOKENTYPE.GREATEREQUAL, ">=", i, i+2));
					i++;	
				}
				else _tokens = array_append(_tokens, new token(TOKENTYPE.GREATER, _char, i, i+1));
				break;
			case "<":
				if(i + 1 <= _text_len && string_char_at(_code, i + 1) == "=") {
					_tokens = array_append(_tokens, new token(TOKENTYPE.LESSEREQUAL, "<=", i, i+2));
					i++;	
				}
				else _tokens = array_append(_tokens, new token(TOKENTYPE.LESSER, _char, i, i+1));
				break;
			case "+": // Addition
				_tokens = array_append(_tokens, new token(TOKENTYPE.ADD, _char, i, i+1));
				break
			case "*": // Multiplication
				_tokens = array_append(_tokens, new token(TOKENTYPE.MULT, _char, i, i+1));
				break;
			case "-": // Subtraction
				_tokens = array_append(_tokens, new token(TOKENTYPE.SUBTRACT, _char, i, i+1));
				break;
			case "%": // Mod
				_tokens = array_append(_tokens, new token(TOKENTYPE.MOD, _char, i, i+1));
				break;
			case "^": // Power
				_tokens = array_append(_tokens, new token(TOKENTYPE.POWER, _char, i, i+1));
				break;
			case "/": // Divition
				_tokens = array_append(_tokens, new token(TOKENTYPE.DIVIDE, _char, i, i+1));
				break;
			case "(": // Opening parenthesis
				_tokens = array_append(_tokens, new token(TOKENTYPE.OPEN_PAREN, _char, i, i+1));
				break;
			case ")": // Closing parenthesis
				_tokens = array_append(_tokens, new token(TOKENTYPE.CLOSE_PAREN, _char, i, i+1));
				break;
			case "{": // Opening curly brace
				_tokens = array_append(_tokens, new token(TOKENTYPE.OPEN_CURLY, _char, i, i+1));
				break;
			case "}": // Closing curly brace
				_tokens = array_append(_tokens, new token(TOKENTYPE.CLOSE_CURLY, _char, i, i+1));
				break;			
			case "[": // Opening curly brace
				_tokens = array_append(_tokens, new token(TOKENTYPE.OPEN_BRACKET, _char, i, i+1));
				break;
			case "]": // Closing curly brace
				_tokens = array_append(_tokens, new token(TOKENTYPE.CLOSE_BRACKET, _char, i, i+1));
				break;
			case ",": // Comma
				_tokens = array_append(_tokens, new token(TOKENTYPE.COMMA, _char, i, i+1));
				break;
			case "!": // Not
				if(i + 1 < _text_len && string_char_at(_code, i+1) == "=") {
					_tokens = array_append(_tokens, new token(TOKENTYPE.NOT_EQUALS, "!=", i, i+2));
					i++;
				}
				else _tokens = array_append(_tokens, new token(TOKENTYPE.NOT, _char, i, i+1));
				break;
		}
	}
	return _tokens;
}
#endregion
#region Parser
#region Nodes for the parser
function parse_node_number(_value) constructor {
	node_name = "Number";
	value = _value;
	
	function to_string() {
		return string(value);
	}
}

function parse_node_binary_operation(_left, _right, _operation) constructor {
	node_name = "Binary operation";
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

function parse_node_unary_operation(_operation, _node) constructor {
	node_name = "Unary operation";
	operation = _operation.type;
	node = _node;
	
	function to_string() {
		var _operation_str = operation == TOKENTYPE.ADD ? "+" : "-";
		return "[" + _operation_str + "(" + node.to_string() + ")]";
	}
}

function parse_node_variable(_name) constructor {
	node_name = "Variable";
	variable_name = _name;
	
	function to_string() {
		return variable_name;
	}
}

function parse_node_assignment(_variable_name, _value) constructor {
	node_name = "Assignment";
	variable_name = _variable_name;
	value = _value;
	
	function to_string() {
		return "[ " + varibable_name + " = " + value.to_string() + " ]";
	}
}

function parse_node_function(_value, _arguments) constructor {
	node_name = "function";
	value = _value;
	arguments = _arguments;
	
	function get_result() {
		var _args = arguments.get_result();
		switch(array_length(value.arguments)) {
			case 1: return value.method_call(_args[0]); break;
			case 2: return value.method_call(_args[0], _args[1]); break;
			case 3: return value.method_call(_args[0], _args[1], _args[2]); break;
			case 4: return value.method_call(_args[0], _args[1], _args[2], _args[3]); break;
			case 5: return value.method_call(_args[0], _args[1], _args[2], _args[3], _args[4]); break;
			case 6: return value.method_call(_args[0], _args[1], _args[2], _args[3], _args[4], _args[5]); break;
			case 7: return value.method_call(_args[0], _args[1], _args[2], _args[3], _args[4], _args[5], _args[6]); break;
			case 8: return value.method_call(_args[0], _args[1], _args[2], _args[3], _args[4], _args[5], _args[6], _args[7]); break;
			case 9: return value.method_call(_args[0], _args[1], _args[2], _args[3], _args[4], _args[5], _args[6], _args[7], _args[8]); break;
			case 10: return value.method_call(_args[0], _args[1], _args[2], _args[3], _args[4], _args[5], _args[6], _args[7], _args[8], _args[9]); break;
		}
	}
}

function parse_node_list(_list) constructor {
	node_name = "list";
	list = _list;
	
	function get_result() {
		var _return_list = [];
		for(var i = 0; i < array_length(list); i++) {
			if(is_struct(list[i])) {
				_return_list = array_append(_return_list, list[i].get_result());
			}
		}
		return _return_list;
	}
}

function parse_node_comparison_operation(_left, _right, _operation) constructor {
	node_name = "comparison operation";
	left = _left;
	right = _right;
	operation = _operation;
	
	function get_result() {
		var _left_result = 0;
		var _right_result = 0;
		if(is_struct(left))  _left_result = left.get_result();	
		if(is_struct(right)) _right_result = right.get_result();
		
		switch(operation) {
			case TOKENTYPE.EQUALS: return _left_result == _right_result;
			case TOKENTYPE.GREATER: return _left_result > _right_result;
			case TOKENTYPE.GREATEREQUAL: return _left_result >= _right_result;
			case TOKENTYPE.LESSER: return _left_result < _right_result;
			case TOKENTYPE.LESSEREQUAL: return _left_result <= _right_result;
		}
	}
}

function parse_node_if(_boolean) constructor {
	node_name = "if";
	if_boolean = _boolean;
	function get_result() {
		return if_boolean.get_result() > 0;
	}
}

function parse_node_else() constructor {
	node_name = "else";
	function get_result() {
		return undefined;
	}
}

function parse_node_loop(_count) constructor {
	node_name = "loop";
	count = _count;
	function get_result() {
		var _loop_count = count.get_result();
		if(is_real(_loop_count)) {
			return round(_loop_count);
		}
	}
}

function parse_node_close_curly() constructor {
	node_name = "close curly";
	function get_result() {
		return undefined;
	}
}
#endregion
function parser(_tokens) constructor {
	tokens = _tokens;
	token_index = -1;
	current_token = -1;
	
	function advance() {
		token_index++;
		if(token_index < array_length(tokens)) { 
			current_token = tokens[token_index];
			return true;
		}
		return false;
	}
	
	function binary_operation(_func, _operation_tokens) {
		var _left_factor = _func();
		if(is_error(_left_factor)) return _left_factor;
		while(array_has(_operation_tokens, current_token.type)) {
			var _operation_token = current_token;
			if(advance()) {
				var _right_factor = _func();
				if(is_error(_right_factor)) return _right_factor;
				_left_factor = new parse_node_binary_operation(_left_factor, _right_factor, _operation_token);
			}
			else break;
		}
		return _left_factor;
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
				return new parse_node_number(_return_token.value);
				break;
				
			case TOKENTYPE.VARIABLE:
				advance();
				return new parse_node_variable(_return_token.value);
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
				if(advance()) {
					var _unary_node_wrap = factor()
					if(is_error(_unary_node_wrap)) return _unary_node_wrap;
					return new parse_node_unary_operation(_return_token, _unary_node_wrap);
				}
				else{
					var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
					_error.missing_number_error();
					return _error;
				}
				break;
		}
		
		return pow()
	}
	
	function term() {
		return binary_operation(factor, [TOKENTYPE.MULT, TOKENTYPE.DIVIDE, TOKENTYPE.MOD]);
	}
	
	function expression() {
		if(current_token.type == TOKENTYPE.VAR) {
			advance();
			
			// Check if the next token is not a variable
			if(current_token.type != TOKENTYPE.VARIABLE) {
				var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
				_error.msg = "Expected a variable after \"var\" keyword";
				return _error;
			}
			else {
				var _variable_name = current_token.value;
				advance();
				
				// Check if the next token is not an assignment
				if(current_token.type != TOKENTYPE.ASSIGN) {
					var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
					_error.msg = "Expected '=' after variable";
					return _error;
				}
				
				if(advance()) {
					var _expression = expression();
					if(is_error(_expression)) return _expression;
					else return new parse_node_assignment(_variable_name, _expression);
				}
				else { // Check if there is no expression after the assignment
					var _error = new error(ERRORTYPE.SYNTAX, current_token.start_pos);
					_error.msg = "Expected an expression after '='";
					return _error;
				}
			}
		}
		else return binary_operation(term, [TOKENTYPE.ADD, TOKENTYPE.SUBTRACT]);
	}
	
	function get_AST() {
		if(array_length(tokens) > 0) {
			token_index = -1;
			current_token = -1;
			advance();
			return expression();
		}
	}
	
}
#endregion
#region Interpreter
function interpreter() constructor {
	variables = -1;
	
	function run(_AST) {
		if(is_struct(_AST)) {
			if(is_error(_AST)) show_debug_message(_AST.get_error());
			else {
				variables = ds_map_create();
				var _run_result = get_result(_AST);
				if(is_error(_run_result)) show_debug_message(_run_result.get_error());
				else show_debug_message(_run_result);
				ds_map_destroy(variables);
			};
		}
	}
	
	function get_result(_node) {
		// Checks to see if this is a node
		// If it is not, returns an error
		if(!is_struct(_node) || !variable_struct_exists(_node, "node_name")) {
			var _error = new error(ERRORTYPE.RUN_TIME, -1);
			_error.missing_node_error();
			return _error;
		}
		
		// Find return condition based on the name of the node
		switch(_node.node_name) {
			case "Number": 
				return _node.value; 
				break;
			
			case "Binary operation":
				var _left_result = get_result(_node.left);
				var _right_result = get_result(_node.right);
				if(is_error(_left_result)) return _left_result;
				if(is_error(_right_result)) return _right_result;
				
				switch(_node.operation) {
					case TOKENTYPE.ADD: 		return _left_result + _right_result; break;
					case TOKENTYPE.SUBTRACT:	return _left_result - _right_result; break;
					case TOKENTYPE.MULT:		return _left_result*_right_result; break;
					case TOKENTYPE.POWER:		return power(_left_result, _right_result); break;
					case TOKENTYPE.MOD:
					case TOKENTYPE.DIVIDE:
						if(_right_result == 0) {
							var _error = new error(ERRORTYPE.RUN_TIME, -1);
							_error.msg = "Attempted to divide by 0";
							return _error;
						}
						else {
							if(_node.operation == TOKENTYPE.DIVIDE) return _left_result/_right_result;
							else if(_node.operation == TOKENTYPE.MOD) return _left_result%_right_result;
						}
						break;
				}
				break;
			
			case "Unary operation":
				var _return_result = get_result(_node.node);
				if(!is_error(_return_result) && _node.operation == TOKENTYPE.SUBTRACT) {
					_return_result *= -1;
				}
				return _return_result;
				break;
			
			case "Variable":
				var _return_result = variables[? _node.variable_name];
				if(is_undefined(_return_result)) {
					var _error = new error(ERRORTYPE.RUN_TIME, -1);
					_error.msg = _node.variable_name + " is undefined."
					return _error;
				}
				else return _return_result;
				break;
			
			case "Assignment":
				var _return_result = get_result(_node.value);
				if(!is_error(_return_result)) variables[? _node.variable_name] = _return_result;
				return _return_result;
				break;
			
			default: // If there is no return condition for this node, then return an error
				var _error = new error(ERRORTYPE.RUN_TIME, -1);
				_error.node_not_found_error(_node.node_name);
				return _error;
				break;
		}
	}
}
#endregion