if(!surface_exists(surface)) {
	surface = surface_create(window_width, window_height);
}
else {
	// drawing the top margin
	draw_set_color(c_dkgray);
	draw_rectangle(x, y, x + window_width, y + top_margin, false);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	draw_set_color(c_white);
	var _name_margin = 5;
	draw_text(x + _name_margin, y + top_margin/2, window_name);
	surface_set_target(surface);
	// drawing the window
	draw_set_color(c_black);
	draw_rectangle(0, 0, window_width, window_height, false);
	// drawing the left margin
	draw_set_color(c_gray);
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
	
	surface_reset_target();
	draw_surface(surface, x, y + top_margin);
}