
var _text_box = UI_find_element("Test", "Textbox");
var _debug_string = string(_text_box.text_cursor_index) + "   " + "Line: " + string(_text_box.get_line(_text_box.text_cursor_index)) + "   " + "Col: " + string(_text_box.offset_from_line(_text_box.text_cursor_index));

draw_set_halign(fa_right);
draw_set_valign(fa_bottom);
draw_text(display_get_gui_width(), display_get_gui_height(), _debug_string);