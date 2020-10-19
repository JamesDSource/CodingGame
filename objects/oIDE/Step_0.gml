seperated_text = string_seperate("\n", text_editing);
t++;
for(var i = 0; i < array_length(valid_characters); i++) {
	if(valid_characters[i].key_hold_timer > 0) valid_characters[i].key_hold_timer -= valid_characters[i].key_hold_subtract;
	if(keyboard_check_pressed(valid_characters[i].keycode) || (keyboard_check(valid_characters[i].keycode) && valid_characters[i].key_hold_timer <= 0)) {
		switch(valid_characters[i].keycode) {
			case vk_backspace: 
				text_editing = string_delete(text_editing, cursor_offset -1, 1); 
				move_cursor(-1, 0);
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