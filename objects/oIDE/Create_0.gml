event_inherited();
text_editing = "";
text_editing_last = text_editing;

UI_window_create(UI_window_name);
var _root = UI_find_element(UI_window_name, "");

var _text_box = new UI_element_text_box("Code", ELEMENTSIZINGTYPE.PERCENT, 1, 1, true, true);
_root.add_child(_text_box);

UI_window_set_element_positions(UI_window_name);

oTerminal.add_window(id);