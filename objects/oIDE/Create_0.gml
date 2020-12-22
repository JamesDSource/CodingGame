event_inherited();

UI_window_create(UI_window_name);
var _root = UI_find_element(UI_window_name, "");

text_box = new UI_element_text_box("Code", ELEMENTSIZINGTYPE.PERCENT, 1, 1, $f0f6f0, $00B200, true, true);
_root.add_child(text_box);

UI_window_set_element_positions(UI_window_name);

oTerminal.add_window(id);