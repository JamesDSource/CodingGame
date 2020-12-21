if(keyboard_check_pressed(vk_f2)) {
    drawing = !drawing;
    oRender.draw_game = !drawing;
}

// Set visiblility of windows
for(var i = 0; i < array_length(windows); i++) {
    var _win_name = windows[i].UI_window_name;
    UI_window_set_visible(_win_name, drawing ? true : false);
}
