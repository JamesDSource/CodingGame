if(keyboard_check_pressed(vk_f2)) {
    drawing = !drawing;
    oRender.replacement_surface = drawing ? background_surface:-1;
}
if(keyboard_check_pressed(vk_f6)) {
    instance_create_layer(0, 0, "Instances", oIDE);
}
if(keyboard_check_pressed(vk_f7)) {
    window_index--;
}
if(keyboard_check_pressed(vk_f8)) {
    window_index++;
}

// Set visiblility of windows
UI_window_set_visible(navigation_bar_name, drawing);
for(var i = 0; i < array_length(windows); i++) {
    var _win_name = windows[i].UI_window_name;
    UI_window_set_visible(_win_name, drawing && window_index == i ? true : false);
}