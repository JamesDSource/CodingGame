UI_window_create("Test");
root = UI_find_element("Test", "");

box_test = new UI_element_box("Box1", 0.9);
box_test.constraint.set_anchor_points(0.5, 0.5);
root.add_child(box_test);

UI_window_set_positions("Test");
var _box = UI_find_element("Test", "Box1");
show_debug_message(_box.rect);