seperated_text = string_seperate("\n", text_editing);
t++;
#region Keyboard inputs for the text
for(var i = 0; i < array_length(valid_characters); i++) {
	if(valid_characters[i].key_hold_timer > 0) valid_characters[i].key_hold_timer -= valid_characters[i].key_hold_subtract;
	if(keyboard_check_pressed(valid_characters[i].keycode) || (keyboard_check(valid_characters[i].keycode) && valid_characters[i].key_hold_timer <= 0)) {
		switch(valid_characters[i].keycode) {
			case vk_backspace: 
				text_editing = string_delete(text_editing, cursor_offset -1, 1); 
				move_cursor(-1, 0);
				break;
			case vk_delete: 
				text_editing = string_delete(text_editing, cursor_offset, 1); 
				break;
			case vk_left:
			case vk_right:
			case vk_up:
			case vk_down: 
				move_cursor(keyboard_check(vk_right) - keyboard_check(vk_left), keyboard_check(vk_down) - keyboard_check(vk_up)); 
				break;
			default:
				var _char_add = valid_characters[i].lowercase;
				if(keyboard_check(vk_shift)) _char_add = valid_characters[i].uppercase;
				text_editing = string_insert(_char_add, text_editing, cursor_offset);
				move_cursor(1, 0);
				break;
		}
		valid_characters[i].key_hold_timer = key_hold_time - valid_characters[i].key_hold_subtract;
		valid_characters[i].key_hold_subtract += key_hold_acceleration;
	}
	else if(!keyboard_check(valid_characters[i].keycode)) valid_characters[i].key_hold_subtract = 0;
}
#endregion
#region Mouse inputs for the window and cursor
var _resize_margin = 10;
var _mouse_pressed = mouse_check_button_pressed(mb_left);
var _mouse_cursor = cr_default;
if(point_in_rectangle(mouse_x, mouse_y, x, y, x + window_width, y + top_margin)) {
	_mouse_cursor = cr_drag;
	if(_mouse_pressed) dragging = {x: x - mouse_x, y: y - mouse_y};
}
else if(point_in_rectangle(mouse_x, mouse_y, x + window_width - _resize_margin, y, x + window_width + _resize_margin, y + window_height)) {
	_mouse_cursor = cr_size_we;
	if(_mouse_pressed) horizontal_resize = true;
}
else if(point_in_rectangle(mouse_x, mouse_y, x, y + window_height - _resize_margin, x + window_width, y + window_height + top_margin + _resize_margin)) {
	_mouse_cursor = cr_size_ns;
	if(_mouse_pressed) verticle_resize = true;	
}
else if(point_in_rectangle(mouse_x, mouse_y, x + window_width - _resize_margin, y + window_height + top_margin - _resize_margin, x + window_width + _resize_margin, y + window_height + top_margin + _resize_margin)) {
	_mouse_cursor = cr_size_nwse;
	if(_mouse_pressed) {
		horizontal_resize = true;
		verticle_resize = true;
	}
}
if(!mouse_check_button(mb_left) && _mouse_cursor != window_get_cursor()) window_set_cursor(_mouse_cursor); 

if(mouse_check_button_released(mb_left)) {
	dragging = -1;
	horizontal_resize = false;
	verticle_resize = false;
}

if(dragging != -1) {
	x = mouse_x + dragging.x;
	y = mouse_y + dragging.y;
}

if(horizontal_resize || verticle_resize) {
	if(horizontal_resize) window_width = mouse_x - x;
	if(verticle_resize) window_height = mouse_y - (y + top_margin);
	window_width = clamp(window_width, 150, room_width);
	window_height = clamp(window_height, 150, room_height - top_margin);
	surface_resize(surface, window_width, window_height);
}

x = clamp(x, 0, room_width - window_width);
y = clamp(y, 0, room_height - window_height - top_margin);
#endregion
#region Getting tokens
if(text_editing != text_editing_last) {
	ds_list_clear(tokens);
	// loop through each character in the text
	var _text_len = string_length(text_editing)
	for(var i = 1; i <= _text_len; i++) {
		var _char = string_char_at(text_editing, i);
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
					case "if": ds_list_add(tokens, new token(TOKENTYPE.IF)); break;
					case "elif": ds_list_add(tokens, new token(TOKENTYPE.ELIF)); break;
					case "else": ds_list_add(tokens, new token(TOKENTYPE.ELSE)); break;
					case "loop": ds_list_add(tokens, new token(TOKENTYPE.LOOP)); break;
					case "true": ds_list_add(tokens, new token(TOKENTYPE.BOOL, true)); break;
					case "false": ds_list_add(tokens, new token(TOKENTYPE.BOOL, false)); break;
					default: _found_keyword = false; break;
				}
				if(_found_keyword) break;
				
				// Looking to see if symbol is a function
				var _function_data = -1;
				for(var j = 0; j < ds_list_size(included_functions); j++) {
					for(var k = 0; k < array_length(included_functions[| j].methods); k++) {
						if(included_functions[| j].methods[k].name == _symbol) {
							_function_data = included_functions[| j].methods[k];
							break;
						}
					}
				}
				
				if(_function_data != -1) ds_list_add(tokens, new token(TOKENTYPE.FUNCTION, _function_data));
				else ds_list_add(tokens, new token(TOKENTYPE.VARIABLE, _symbol));
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
				show_debug_message("Unrounded" + _numb);
				show_debug_message("Rounded" + string(real(_numb)));
				ds_list_add(tokens, new token(TOKENTYPE.NUMBER, real(_numb)));
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
				ds_list_add(tokens, new token(TOKENTYPE.STRING, _str));
				i = _peek_index;
				break;
			case ";": // Semi Colon
				ds_list_add(tokens, new token(TOKENTYPE.SEMI_COLON));
			case "=": // Addition and equals
				if(i + 1 <= _text_len && string_char_at(text_editing, i + 1) == "=") {
					ds_list_add(tokens, new token(TOKENTYPE.EQUALS));
					i++;	
				}
				else ds_list_add(tokens, new token(TOKENTYPE.ASSIGN));
				break;
			case ">":
				if(i + 1 <= _text_len && string_char_at(text_editing, i + 1) == "=") {
					ds_list_add(tokens, new token(TOKENTYPE.GREATEREQUAL));
					i++;	
				}
				else ds_list_add(tokens, new token(TOKENTYPE.GREATER));
				break;
			case "<":
				if(i + 1 <= _text_len && string_char_at(text_editing, i + 1) == "=") {
					ds_list_add(tokens, new token(TOKENTYPE.LESSEREQUAL));
					i++;	
				}
				else ds_list_add(tokens, new token(TOKENTYPE.LESSER));
				break;
			case "+": // Addition
				ds_list_add(tokens, new token(TOKENTYPE.ADD));
				break
			case "*": // Multiplication
				ds_list_add(tokens, new token(TOKENTYPE.MULT));
				break;
			case "-": // Subtraction
				ds_list_add(tokens, new token(TOKENTYPE.SUBTRACT));
				break;
			case "/": // Divition
				ds_list_add(tokens, new token(TOKENTYPE.DIVIDE));
				break;
			case "(": // Opening parenthesis
				ds_list_add(tokens, new token(TOKENTYPE.OPEN_PAREN));
				break;
			case ")": // Closing parenthesis
				ds_list_add(tokens, new token(TOKENTYPE.CLOSE_PAREN));
				break;
			case "{": // Opening curly brace
				ds_list_add(tokens, new token(TOKENTYPE.OPEN_CURLY));
				break;
			case "}": // Closing curly brace
				ds_list_add(tokens, new token(TOKENTYPE.CLOSE_CURLY));
				break;			
			case "[": // Opening curly brace
				ds_list_add(tokens, new token(TOKENTYPE.OPEN_BRACKET));
				break;
			case "]": // Closing curly brace
				ds_list_add(tokens, new token(TOKENTYPE.CLOSE_BRACKET));
				break;
			case ",": // Comma
				ds_list_add(tokens, new token(TOKENTYPE.COMMA));
				break;
		}
	}
	text_editing_last = text_editing;
	show_debug_message("------------------------------------------");
	for(var i = 0; i < ds_list_size(tokens); i++) {
		show_debug_message(tokens[| i]);
	}
	

	var _command_tokens = [];
	parsed_commands = [];
	for(var i = 0; i < ds_list_size(tokens); i++) {
		switch(tokens[| i].type) {
			case TOKENTYPE.SEMI_COLON:
				i++;
			case TOKENTYPE.OPEN_CURLY:
				parsed_commands = array_append(parsed_commands, parse(_command_tokens, variables));
				_command_tokens = [];
				break;
			case TOKENTYPE.CLOSE_CURLY:
				parsed_commands = array_append(parsed_commands, parse([tokens[| i]], variables));
				break;
			default: _command_tokens = array_append(_command_tokens, tokens[| i]); break;
		}
	}
}
#endregion

if(keyboard_check_pressed(vk_f4)) run();