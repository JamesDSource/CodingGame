event_inherited();
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

#region tokens
tokens = ds_list_create();
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
function parse_node_parsed(_value) constructor {
	node_name = "parsed";
	variables = other.variables;
	parsed_value = _value;
	
	function get_result() {
		if(is_struct(parsed_value)) return parsed_value.get_result();	
	}
}
function parse_node_value(_value) constructor {
	node_name = "value";
	variables = other.variables;
	value = _value;
	
	function get_result() {
		return value;	
	}
}

function parse_node_function(_value, _arguments) constructor {
	node_name = "function";
	variables = other.variables;
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
	variables = other.variables;
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

function parse_node_variable(_name) constructor {
	node_name = "variable";
	variables = other.variables;
	variable_name = _name;
	index = -1;
	
	function get_result() {
		var _index = -1;
		if(index != -1) _index = index.get_result();
		
		var _variable_value = variables[? variable_name];
		if(_index == -1 || !is_array(_variable_value)) return _variable_value;
		else if(is_array(_index)) return _variable_value[_index[0]];
		else return _variable_value[_index];
	}
}

function parse_node_binary_operation(_left, _right, _operation) constructor {
	node_name = "binary operation";
	variables = other.variables;
	left = _left;
	right = _right;
	operation = _operation;
	
	function get_result() {
		var _left_result = 0;
		var _right_result = 0;
		if(is_struct(left))  _left_result = left.get_result();	
		if(is_struct(right)) _right_result = right.get_result();
		
		if(!is_string(_left_result) && !is_real(_left_result)) _left_result = 0;
		if(!is_string(_right_result) && !is_real(_right_result)) _right_result = 0;
		
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

function parse_node_comparison_operation(_left, _right, _operation) constructor {
	node_name = "comparison operation";
	variables = other.variables;
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

function parse_node_assignment(_left, _right) constructor {
	node_name = "assignment";
	variables = other.variables;
	left = _left;
	right = _right;
	
	function get_result() {
		var _right_result = undefined;
		if(is_struct(right)) _right_result = right.get_result();
		
		if(is_struct(left) && left.node_name == "variable") {
			var _current_variable = variables[? left.variable_name];
			if(is_array(_current_variable) && left.index != -1) {
				_current_variable[left.index] = _right_result;
				variables[? left.variable_name] = _current_variable;
			}
			else variables[? left.variable_name] = _right_result;
			return left.variable_name + " = " + string(variables[? left.variable_name]);
		}
	}
}

function parse_node_if(_boolean) constructor {
	node_name = "if";
	variables = other.variables;
	if_boolean = _boolean;
	function get_result() {
		return if_boolean.get_result() > 0;
	}
}

function parse_node_else() constructor {
	node_name = "else";
	variables = other.variables;
	function get_result() {
		return undefined;
	}
}

function parse_node_loop(_count) constructor {
	node_name = "loop";
	variables = other.variables;
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
	variables = other.variables;
	function get_result() {
		return undefined;
	}
}
#endregion
#region Parser
// Variables
variables = ds_map_create();

function parse(_tokens, _variables) { // Parces an array of token
	// check for parenthesis
	var _paren_error = false;
	while(!_paren_error && (array_has_struct(_tokens, "type", TOKENTYPE.OPEN_PAREN) || array_has_struct(_tokens, "type", TOKENTYPE.OPEN_BRACKET))) {
		for(var i = 0; i < array_length(_tokens); i++) {
			if(_tokens[i].type == TOKENTYPE.OPEN_PAREN || _tokens[i].type == TOKENTYPE.OPEN_BRACKET) {
				var _pair_pos = -1;
				if(_tokens[i].type == TOKENTYPE.OPEN_PAREN) _pair_pos = find_pair_position(_tokens, i, TOKENTYPE.OPEN_PAREN, TOKENTYPE.CLOSE_PAREN);
				else _pair_pos = find_pair_position(_tokens, i, TOKENTYPE.OPEN_BRACKET, TOKENTYPE.CLOSE_BRACKET);
				
				if(_pair_pos != -1) {
					var _paren_tokens = [];
					var _len = _pair_pos-i;
					if(_tokens[i].type == TOKENTYPE.OPEN_PAREN) {
						array_copy(_paren_tokens, 0, _tokens, i+1, _len-1);
						repeat(_len) _tokens = array_delete(_tokens, i);
						_paren_tokens = [new token(TOKENTYPE.PARSED, parse(_paren_tokens, _variables))];
					}
					else {
						var _bracket_list = [];
						for(var j = i+1; j <= _pair_pos; j++) {
							if(_tokens[j].type == TOKENTYPE.OPEN_BRACKET) {
								var _pair = find_pair_position(_tokens, j, TOKENTYPE.OPEN_BRACKET, TOKENTYPE.CLOSE_BRACKET);
								if(_pair != -1 || _pair < _pair_pos) {
									for(var k = j; k <= _pair; k++) _paren_tokens = array_append(_paren_tokens, _tokens[k]);
									j = _pair;
								}
							}
							else if((_tokens[j].type == TOKENTYPE.COMMA || j == _pair_pos) && array_length(_paren_tokens) > 0) {
								_paren_tokens = parse(_paren_tokens, _variables);
								_bracket_list = array_append(_bracket_list, _paren_tokens);
								_paren_tokens = [];
							}
							else _paren_tokens = array_append(_paren_tokens, _tokens[j]);
						}
						repeat(_len) _tokens = array_delete(_tokens, i);
						_paren_tokens = [new token(TOKENTYPE.PARSED, new parse_node_list(_bracket_list))];
					}
					array_copy(_tokens, i, _paren_tokens, 0, 1);
				}
				else _paren_error = true;
			}
		}
	}
	var _priority = [
		[TOKENTYPE.CLOSE_CURLY],
		[TOKENTYPE.ASSIGN, TOKENTYPE.IF, TOKENTYPE.ELIF, TOKENTYPE.ELSE, TOKENTYPE.LOOP],
		[TOKENTYPE.EQUALS, TOKENTYPE.GREATER, TOKENTYPE.LESSER, TOKENTYPE.GREATEREQUAL, TOKENTYPE.LESSEREQUAL],
		[TOKENTYPE.ADD, TOKENTYPE.SUBTRACT],
		[TOKENTYPE.MULT, TOKENTYPE.DIVIDE],
		[TOKENTYPE.NUMBER, TOKENTYPE.STRING, TOKENTYPE.BOOL, TOKENTYPE.VARIABLE, TOKENTYPE.PARSED, TOKENTYPE.FUNCTION]
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
						if(i-1 >= 0) {
							var _next_token = _tokens[i-1];
							switch(_next_token.type) {
								case TOKENTYPE.VARIABLE:
									var _variable_value = _variables[? _next_token.value];
									var _parsed_variable = parse([_next_token], _variables);
									_parsed_variable.index = _parse_node;
									return _parsed_variable;
									break;
								case TOKENTYPE.FUNCTION:
									return new parse_node_function(_tokens[i-1].value, _parse_node);
									break;
							}
						}
						return _parse_node;
						break;
					case TOKENTYPE.BOOL:
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
					case TOKENTYPE.EQUALS:
					case TOKENTYPE.LESSER:
					case TOKENTYPE.LESSEREQUAL:
					case TOKENTYPE.GREATER:
					case TOKENTYPE.GREATEREQUAL:
						return new parse_node_comparison_operation (
							parse(_tokens_before, _variables),
							parse(_tokens_after, _variables),
							_tokens[i].type
						);
						break;
					case TOKENTYPE.ADD:
					case TOKENTYPE.SUBTRACT:
					case TOKENTYPE.MULT:
					case TOKENTYPE.DIVIDE:
						return new parse_node_binary_operation(
							parse(_tokens_before, _variables),
							parse(_tokens_after, _variables),
							_tokens[i].type
						);
						break;
					case TOKENTYPE.ASSIGN:
						return new parse_node_assignment(
							parse(_tokens_before, _variables),
							parse(_tokens_after, _variables)
						);
						break;
					case TOKENTYPE.ELIF:
					case TOKENTYPE.IF:
						if(i < array_length(_tokens)-1 && _tokens[i+1].type == TOKENTYPE.PARSED) {
							var _new_node = new parse_node_if(parse([_tokens[i+1]]));
							if(_tokens[i].type == TOKENTYPE.ELIF) _new_node.node_name = "elif";
							return _new_node;
						}
						break;
					case TOKENTYPE.ELSE:
						return new parse_node_else();
						break;
					case TOKENTYPE.LOOP:
						if(i < array_length(_tokens)-1 && _tokens[i+1].type == TOKENTYPE.PARSED) {
							return new parse_node_loop(parse([_tokens[i+1]]));
						}
						break;
					case TOKENTYPE.CLOSE_CURLY:
						return new parse_node_close_curly();
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
	var _loop_points = ds_list_create();

	function check_for_pair(_start_pos) {
		var _value = 0;
		for(var i = _start_pos; i < array_length(parsed_commands); i++) {
			switch(parsed_commands[i].node_name) {
				case "if":
				case "elif":
				case "else":
				case "loop":
					_value++;
					break;
				case "close curly":
					_value--;
			}
			
			if(_value == 0) return i;
		}
		// TODO: put an error here for not finding a pair
		return -1;
	}

	// loops through each command
	var _parse_len = array_length(parsed_commands);
	for(var i = 0; i < _parse_len; i++) {
		var _current_command = parsed_commands[i];
		var _current_command_result = _current_command.get_result();
		
		switch(_current_command.node_name) {
			case "if":
				if(!_current_command_result) {
					i = check_for_pair(i);
					// finding a drop off point
					var _found_drop_off = false;
					while(!_found_drop_off) {
						if(i + 1 >= _parse_len) _found_drop_off = true;
						else {
							switch(parsed_commands[i+1].node_name) {
								case "elif":
									if(parsed_commands[i+1].get_result()) {
										i++;
										_found_drop_off = true;
									}
									else i = check_for_pair(i+1);
									break;
								case "else":
									i++;
								default:
									_found_drop_off = true;
									break;
							}
						}
					}
				}
				break;
			case "elif":
			case "else":
				i = check_for_pair(i);
				break;
			case "loop":
				var _end_loop_point = check_for_pair(i);
				var _loop_point = {start_point: i, end_point: _end_loop_point, iterations_remaining: _current_command_result}; 
				ds_list_add(_loop_points, _loop_point);
				show_debug_message(_loop_point);
				break;
			case "close curly":
				// Checking for loops
				for(var j = 0; j < ds_list_size(_loop_points); j++) {
					if(_loop_points[| j].end_point == i) {
						_loop_points[| j].iterations_remaining--;
						if(_loop_points[| j].iterations_remaining > 0) {
							i = _loop_points[| j].start_point;	
						}
						break;
					}
				}
				break;
		}
	
		
	}
	// clears variables
	ds_map_clear(variables);
	ds_list_destroy(_loop_points);
}

window_draw_function = function window_draw_ide() {
	// drawing the window
	draw_set_color(c_black);
	draw_rectangle(0, 0, window_width, window_height, false);
	// drawing the left margin
	draw_set_color(c_ltgray);
	draw_rectangle(0, 0, sidebar_width, window_height, false);
	draw_set_color(c_white);
	draw_set_halign(fa_right);
	draw_set_valign(fa_top);
	for(var i = 0; i <= string_count("\n", text_editing); i++) {
		draw_text(sidebar_width, i*line_seperation, i + 1);	
	}
	// drawing the text
	draw_set_valign(fa_top);
	draw_set_halign(fa_left);
	draw_set_color(c_white);
	var _draw_y = 0;
	var _draw_x = left_margin;
	for(var i = 0; i <= string_length(text_editing); i++) {
		var _char = string_char_at(text_editing, i);
		if(i == cursor_offset || (i == 0 && string_length(text_editing) == 0)) draw_text(_draw_x - character_seperation/2, _draw_y, "|");
		else if(i == string_length(text_editing) && cursor_offset == i + 1) {
			if(_char == "\n") draw_text(left_margin, _draw_y + line_seperation, "|");
			else if(_char == "\t") draw_text(_draw_x + tab_width, _draw_y, "|");
			else draw_text(_draw_x + character_seperation, _draw_y, "|");
		}
		if(i != 0) {
			switch(_char) {
				case "\n":
					_draw_y += line_seperation;
					_draw_x = left_margin;
					break;
				case "\t":
					draw_text(_draw_x, _draw_y, "~");
					_draw_x += tab_width;
					break;
				default:
					draw_set_color(c_white);
					draw_text(_draw_x, _draw_y, _char);
					_draw_x += character_seperation;
					break;
			}
		}
	}

	
}