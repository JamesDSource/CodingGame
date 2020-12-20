UI_window_create("Test");
root = UI_find_element("Test", "");
UI_window_resize("Test", display_get_gui_width()-10, display_get_gui_height()-10);
UI_window_set_position("Test", 5, 5);

textbox = new UI_element_text_box("Textbox", ELEMENTSIZINGTYPE.PERCENT, 1.0, 1.0, true, true);
root.add_child(textbox);

UI_window_set_element_positions("Test");
