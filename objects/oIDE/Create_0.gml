window_width = 400;
window_height = 400;
window_name = "Code IDE"

t = 0;

text_editing = "";
text_editing_last = text_editing;
seperated_text = [];
parsed_commands = [];

// functions
included_functions = ds_list_create();
ds_list_add(included_functions, global.standard_library);

surface = -1;
left_margin = 30;
top_margin = 30;
line_seperation = 20;
character_seperation = 10;
tab_width = 30;
sidebar_width = 25;

cursor_offset = 1;
cursor_line = 0;
cursor_offset_on_line = 0;

dragging = -1;
horizontal_resize = false;
verticle_resize = false;

#region tokens
tokens = ds_list_create();
enum TOKENTYPE {
	PARSED,
	VARIABLE,
	NUMBER,
	STRING,
	COMMA,
	FUNCTION,
	ASSIGN,
	SEMI_COLON,
	ADD,
	MULT,
	SUBTRACT,
	DIVIDE,
	OPEN_CURLY,
	CLOSE_CURLY,
	OPEN_PAREN,
	CLOSE_PAREN
}
function token(_type, _value) constructor {
	type = _type;
	if(!is_undefined(_value)) value = _value;
	else value = -1;
}
#endregion
#region cursor
function move_cursor(horizontal, verticle) {
	// Horizontal
	cursor_offset += horizontal;
	cursor_offset = clamp(cursor_offset, 0, string_length(text_editing) + 1);
	// Verticle
	var _newlines = [0];
	var _newline_pos = string_pos_all("\n", text_editing);
	array_copy(_newlines, 1, _newline_pos, 0, array_length(_newline_pos));
	var _cursor_newline_pos = 0;
	for(var i = array_length(_newlines) - 1; i >= 0; i--) {
		if(_newlines[i] < cursor_offset) {
			_cursor_newline_pos = i
			cursor_offset_on_line = cursor_offset - _newlines[i];
			break;	
		}
	}
	var _new_pos = _cursor_newline_pos + verticle;
	if(_new_pos >= 0 && _new_pos < array_length(_newlines)) {
		var _new_pos_start = _newlines[_new_pos];
		var _max_addition;
		if(_new_pos + 1 == array_length(_newlines)) _max_addition = string_length(text_editing) + 1 - _new_pos_start;
		else _max_addition = _newlines[_new_pos + 1] - _new_pos_start;
		cursor_offset_on_line = min(cursor_offset_on_line, _max_addition);
		cursor_offset = _new_pos_start + cursor_offset_on_line;
		cursor_line = _new_pos;
	}
	cursor_offset = clamp(cursor_offset, 1, string_length(text_editing) + 1);
	//show_debug_message("Offset: " + string(cursor_offset) + " | Line" + string(cursor_line) + " | Offset on line: " + string(cursor_offset_on_line));
}
move_cursor(0, 0);
#endregion
#region Key characters
key_hold_time = 40;
key_hold_acceleration = 2;
function character(_code, _uppercase, _lowercase) constructor {
	if(_uppercase == "" && _lowercase != "") uppercase = string_upper(_lowercase);
	else uppercase = _uppercase;
	
	if(_lowercase == "" && _uppercase != "") lowercase = _uppercase;
	else lowercase = _lowercase;
	
	if(_code == -1) keycode = ord(uppercase);
	else keycode = _code;
	
	key_hold_timer = 0;
	key_hold_subtract = 0;
}


valid_characters = [
	new character(-1, "", "a"),
	new character(-1, "", "b"),
	new character(-1, "", "c"),
	new character(-1, "", "d"),
	new character(-1, "", "e"),
	new character(-1, "", "f"),
	new character(-1, "", "g"),
	new character(-1, "", "h"),
	new character(-1, "", "i"),
	new character(-1, "", "j"),
	new character(-1, "", "k"),
	new character(-1, "", "l"),
	new character(-1, "", "m"),
	new character(-1, "", "n"),
	new character(-1, "", "o"),
	new character(-1, "", "p"),
	new character(-1, "", "q"),
	new character(-1, "", "r"),
	new character(-1, "", "s"),
	new character(-1, "", "t"),
	new character(-1, "", "u"),
	new character(-1, "", "v"),
	new character(-1, "", "w"),
	new character(-1, "", "x"),
	new character(-1, "", "y"),
	new character(-1, "", "z"),
	new character(ord("1"), "!", "1"),
	new character(ord("2"), "@", "2"),
	new character(ord("3"), "#", "3"),
	new character(ord("4"), "$", "4"),
	new character(ord("5"), "%", "5"),
	new character(ord("6"), "^", "6"),
	new character(ord("7"), "&", "7"),
	new character(ord("8"), "*", "8"),
	new character(ord("9"), "(", "9"),
	new character(ord("0"), ")", "0"),
	new character(vk_space, " ", " "),
	new character(vk_enter, "\n", ""),
	new character(vk_tab, "\t", ""),
	new character(vk_backspace, "", ""),
	new character(vk_delete, "", ""),
	new character(vk_left, "", ""),
	new character(vk_right, "", ""),
	new character(vk_up, "", ""),
	new character(vk_down, "", ""),
	new character(219, "{", "["),
	new character(221, "}", "]"),
	new character(186, ":", ";"),
	new character(222, "\"", "'"),
	new character(187, "+", "="),
	new character(189, "_", "-"),
	new character(188, "<", ","),
	new character(190, ">", "."),
	new character(191, "?", "/")
];

for(var i = 0; i < array_length(valid_characters); i++) {
	if(is_string(valid_characters[i])) {
		valid_characters[i] = ord(valid_characters[i]);
	}
}
#endregion
#region Nodes for the parser
function parse_node_parsed(_value) constructor{
	id = other.id;
	parsed_value = _value;
	
	function get_result() {
		if(is_struct(parsed_value)) return parsed_value.get_result();	
	}
}
function parse_node_value(_value) constructor{
	id = other.id;
	value = _value;
	
	function get_result() {
		return value;	
	}
}

function parse_node_function(_value, _arguments) constructor {
	id = other.id;
	value = _value;
	arguments = _arguments;
	if(!is_array(arguments)) {
		arguments = [arguments];
	}
	
	function get_result() {
		switch(array_length(value.arguments)) {
			case 1: return value.method_call(arguments[0]); break;
			case 2: return value.method_call(arguments[0], arguments[1]); break;
			case 3: return value.method_call(arguments[0], arguments[1], arguments[2]); break;
			case 4: return value.method_call(arguments[0], arguments[1], arguments[2], arguments[3]); break;
			case 5: return value.method_call(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4]); break;
			case 6: return value.method_call(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5]); break;
			case 7: return value.method_call(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6]); break;
			case 8: return value.method_call(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6], arguments[7]); break;
			case 9: return value.method_call(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6], arguments[7], arguments[8]); break;
			case 10: return value.method_call(arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6], arguments[7], arguments[8], arguments[9]); break;
		}
	}
}

function parse_node_list(_list) constructor{
	id = other.id;
	list = [];
	for(var i = 0; i < array_length(_list); i++) {
		if(is_struct(_list[i])) { 
			list = array_append(list, _list[i].get_result());
		}
	}
	
	function get_result() {
		return list;
	}
}

function parse_node_variable(_name) constructor{
	id = other.id;
	variable_name = _name;
	index = -1;
	
	function get_result() {
		var _variable_value = variable_get(variable_name);
		if(index == -1) return _variable_value;
		else return _variable_value[index];
	}
}

function parse_node_binary_operation(_left, _right, _operation) constructor{
	id = other.id;
	left = _left;
	right = _right;
	operation = _operation;
	
	function get_result() {
		var _left_result = 0;
		var _right_result = 0;
		if(is_struct(left))  _left_result = left.get_result();	
		if(is_struct(right)) _right_result = right.get_result();
		
		
		if(is_string(_left_result) || is_string(_right_result)) {
			if(operation == TOKENTYPE.ADD) {
				_right_result = string(_right_result);
				_left_result = string(_left_result);
			}
		}
		
		switch(operation) {
			case TOKENTYPE.ADD: return _left_result + _right_result;
			case TOKENTYPE.SUBTRACT: return _left_result - _right_result;
			case TOKENTYPE.MULT: return _left_result * _right_result;
			case TOKENTYPE.DIVIDE: return _left_result / _right_result;
		}
	}
}

function parse_node_assignment(_left, _right) constructor{
	id = other.id;
	left = _left;
	right = _right;
	
	function get_result() {
		var _right_result = 0;
		if(is_struct(right)) {
			_right_result = right.get_result();
			if(is_undefined(_right_result) && variable_struct_exists(right, "parsed_value")) _right_result = [];	
		}
		
		if(is_struct(left) && variable_struct_exists(left, "variable_name")) {
			var _current_variable = variable_get(left.variable_name);
			if(is_array(_current_variable) && left.index != -1) {
				_current_variable[left.index] = _right_result;
				variable_set(left.variable_name, _current_variable);
			}
			else variable_set(left.variable_name, _right_result);
			return left.variable_name + " = " + string(variable_get(left.variable_name));
		}
	}
}
#endregion
#region Parser
function parse(_tokens) { // Parces an array of token
	// check for parenthesis
	var _paren_error = false;
	while(!_paren_error && array_has_struct(_tokens, "type", TOKENTYPE.OPEN_PAREN)) {
		for(var i = 0; i < array_length(_tokens); i++) {
			if(_tokens[i].type == TOKENTYPE.OPEN_PAREN) {
				var _pair_pos = find_pair_position(_tokens, i, TOKENTYPE.OPEN_PAREN, TOKENTYPE.CLOSE_PAREN);
				if(_pair_pos != -1) {
					var _paren_tokens = [];
					var _len = _pair_pos-i;
					array_copy(_paren_tokens, 0, _tokens, i+1, _len-1);
					repeat(_len) _tokens = array_delete(_tokens, i);
					_paren_tokens = [new token(TOKENTYPE.PARSED, parse(_paren_tokens))];
					array_copy(_tokens, i, _paren_tokens, 0, 1);
				}
				else _paren_error = true;
			}
		}
	}
	var _priority = [
		[TOKENTYPE.COMMA],
		[TOKENTYPE.ASSIGN],
		[TOKENTYPE.ADD, TOKENTYPE.SUBTRACT],
		[TOKENTYPE.MULT, TOKENTYPE.DIVIDE],
		[TOKENTYPE.NUMBER, TOKENTYPE.STRING, TOKENTYPE.VARIABLE, TOKENTYPE.PARSED, TOKENTYPE.FUNCTION]
	]
	for(var i = array_length(_tokens)-1; i >= 0; i--) {	
		for(var j = 0; j < array_length(_priority); j++) {
			// Checks this priority list to see if this token falls inside of it
			if(array_has(_priority[j], _tokens[i].type)) {
				var _tokens_before = [];
				var _tokens_after = [];
				array_copy(_tokens_before, 0, _tokens, 0, i);
				array_copy(_tokens_after, 0, _tokens, i+1, array_length(_tokens)-i+1);
				
				switch(_tokens[i].type) {
					case TOKENTYPE.PARSED:
						var _parse_node = new parse_node_parsed(_tokens[i].value);
						var _result = _parse_node.get_result();
						if(i-1 >= 0) {
							var _next_token = _tokens[i-1];
							switch(_next_token.type) {
								case TOKENTYPE.VARIABLE:
									var _variable_value = variable_get(_next_token.value);
									if(is_array(_variable_value) && is_real(_result)) {
										var _parsed_variable = parse([_next_token]);
										_parsed_variable.index = round(_result);
										return _parsed_variable;
									}
									break;
								case TOKENTYPE.FUNCTION:
									return new parse_node_function(_tokens[i-1].value, _result);
									break;
							}
						}
						return _parse_node;
						break;
					case TOKENTYPE.STRING:
					case TOKENTYPE.NUMBER:
						return new parse_node_value(_tokens[i].value);
						break;
					case TOKENTYPE.VARIABLE:
						return new parse_node_variable(_tokens[i].value);
						break;
					case TOKENTYPE.FUNCTION:
						return new parse_node_function(_tokens[i].value);
						break;
					case TOKENTYPE.ADD:
					case TOKENTYPE.SUBTRACT:
					case TOKENTYPE.MULT:
					case TOKENTYPE.DIVIDE:
						return new parse_node_binary_operation(
							parse(_tokens_before),
							parse(_tokens_after),
							_tokens[i].type
						);
						break;
					case TOKENTYPE.ASSIGN:
						return new parse_node_assignment(
							parse(_tokens_before),
							parse(_tokens_after)
						);
						break;
					case TOKENTYPE.COMMA:
						var _tokens_list = [parse(_tokens_after)];
						var _list_item_tokens = [];
						for(var c = array_length(_tokens_before) - 1; c >= -1; c--) {
							if(c == -1 || _tokens_before[c].type == TOKENTYPE.COMMA) {
								_tokens_list = array_insert(_tokens_list, 0, parse(_list_item_tokens));
								_list_item_tokens = [];
							}
							else {
								_list_item_tokens = array_insert(_list_item_tokens, 0, _tokens_before[c]);
							}
						}
						return new parse_node_list(_tokens_list);
						break;
					
				}
			}
			else {
				// Checks the tokens to see if it has anything that's inside this priority list
				var _break_out = false;
				for(var c = 0; c < array_length(_priority[j]); c++) {
					if(array_has_struct(_tokens, "type", _priority[j][c])) {
						_break_out = true;
						break;
					}
				}
				if(_break_out) break;
			}
		}
	}
}

function find_pair_position(_tokens, _starting_pos, _opening_type, _closing_type) {
	var _value = 0;
	for(var i = _starting_pos; i < array_length(_tokens); i++) {
		if(_tokens[i].type == _opening_type) _value++;
		else if(_tokens[i].type == _closing_type) _value--;
		
		if(_value == 0) return i;
	}
	return -1;
}
#endregion

function run() { // Runs the code
	for(var i = 0; i < array_length(parsed_commands); i++) {
		parsed_commands[i].get_result();
	}
}

function close() { // For closing the window
	
	
}