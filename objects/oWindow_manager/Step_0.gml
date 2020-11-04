var _mouse_cursor = window_get_cursor();
var _mouse_pressed = mouse_check_button_pressed(mb_left);
var _resize_selection_margin = 5;

// For selecting windows
if(_mouse_pressed) {
    var _window_clicked = noone;
    for(var i = 0; i < ds_list_size(windows); i++) {
        var _window = windows[| i];
        if(point_in_rectangle(mouse_x, mouse_y, _window.x, _window.y, _window.x + _window.window_width + _resize_selection_margin, _window.y + _window.window_height + window_top_bar_height + _resize_selection_margin)) {
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

// If there is a selected window, check if it's being dragged or resized
if(instance_exists(window_selected)) {
    var _ws_data = {
        x: window_selected.x, 
        y: window_selected.y,
        w: window_selected.window_width,
        h: window_selected.window_height
    };
    var _gui_borders = {
        x: display_get_gui_width() - _resize_selection_margin,
        y: display_get_gui_height() - _resize_selection_margin - window_top_bar_height
    };

    if(mouse_check_button(mb_left) && !_mouse_pressed) {
        if(is_struct(drag_point)) {
            window_selected.x = clamp(mouse_x + drag_point.x, 0, _gui_borders.x - _ws_data.w );
            window_selected.y = clamp(mouse_y + drag_point.y, 0, _gui_borders.y - _ws_data.h);
        }
        else {
            if(horizontal_resize) window_selected.window_width = clamp(mouse_x - _ws_data.x, 100, _gui_borders.x - _ws_data.x);
            if(verticle_resize) window_selected.window_height = clamp(mouse_y - _ws_data.y - window_top_bar_height, 100, _gui_borders.y - _ws_data.y);
        }
    }
    else {
        // Reset variables
        _mouse_cursor = cr_default;
        drag_point = -1;
        horizontal_resize = false;
        verticle_resize = false;
        
        if(point_in_rectangle(mouse_x, mouse_y, _ws_data.x, _ws_data.y, _ws_data.x + _ws_data.w,  _ws_data.y + window_top_bar_height)) {
            _mouse_cursor = cr_drag;
            if(_mouse_pressed) drag_point = {x: _ws_data.x - mouse_x, y: _ws_data.y - mouse_y}; 
        }
        else {
            if(point_in_rectangle(mouse_x, mouse_y, _ws_data.x + _ws_data.w, _ws_data.y, _ws_data.x + _ws_data.w + _resize_selection_margin,  _ws_data.y + _ws_data.h + window_top_bar_height + _resize_selection_margin)) {
                _mouse_cursor = cr_size_we;
                if(_mouse_pressed) horizontal_resize = true; 
            }
            if(point_in_rectangle(mouse_x, mouse_y, _ws_data.x, _ws_data.y + _ws_data.h + window_top_bar_height, _ws_data.x + _ws_data.w + _resize_selection_margin,  _ws_data.y + _ws_data.h + window_top_bar_height + _resize_selection_margin)) {
                if(_mouse_cursor != cr_size_we)_mouse_cursor = cr_size_ns;
                else _mouse_cursor = cr_size_nwse;
                if(_mouse_pressed) verticle_resize = true; 
            }
        }
        
    }
    
}
else _mouse_cursor = cr_default;

// Set new cursor if it's changed
if(window_get_cursor() != _mouse_cursor) window_set_cursor(_mouse_cursor);