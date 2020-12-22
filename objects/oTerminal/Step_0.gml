var _tab_selected = nav_bar.get_selected_tab();
if(!is_undefined(_tab_selected)) _tab_selected = _tab_selected.value;

// Temp keys until I get the UI functions for them working
if(keyboard_check_pressed(vk_f2)) {
    drawing = !drawing;
    oRender.replacement_surface = drawing ? background_surface:-1;
}
if(keyboard_check_pressed(vk_f6)) {
    instance_create_layer(0, 0, "Instances", oIDE);
}


// Set visiblility of windows
UI_window_set_visible(navigation_bar_name, drawing);
for(var i = 0; i < array_length(nav_bar.tabs); i++) {
    var _window = nav_bar.tabs[i].value;
    var _win_name = _window.UI_window_name;
    UI_window_set_visible(_win_name, drawing && _window == _tab_selected);
    _window.selected = (drawing && _window == _tab_selected);
}