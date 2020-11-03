if(mouse_check_button_pressed(mb_left)) {
    // Selecting specific windows
    var _window_clicked = noone;
    for(var i = 0; i < ds_list_size(windows); i++) {
        var _window = windows[| i];
        if(point_in_rectangle(mouse_x, mouse_y, _window.x, _window.y, _window.x + _window.window_width, _window.y + _window.window_height + window_top_bar_height)) {
            _window_clicked = _window.id;
            break;
        }
    }
    
    if(instance_exists(_window_clicked)) {
        window_remove(_window_clicked);
        window_add(_window_clicked);
    }
    
    if(instance_exists(window_selected)) window_selected.selected = false;
    window_selected = _window_clicked;
     if(instance_exists(window_selected)) window_selected.selected = true;
}