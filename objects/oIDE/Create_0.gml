text_editing = "";
seperated_text = [];

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
	show_debug_message("Offset: " + string(cursor_offset) + " | Line" + string(cursor_line) + " | Offset on line: " + string(cursor_offset_on_line));
}
move_cursor(0, 0);
t = 0;

key_hold_time = 30;
key_hold_acceleration = 2;
function character(_code, _uppercase, _lowercase) constructor {
	if(_uppercase == "" && _lowercase != "") uppercase = string_upper(_lowercase);
	else uppercase = _uppercase;
	
	if(_lowercase == "" && _uppercase != "") lowercase = _uppercase;
	else lowercase = _lowercase;
	
	if(_code == -1) keycode = ord(uppercase);
	else keycode = _code;
	show_debug_message(keycode);
	
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
