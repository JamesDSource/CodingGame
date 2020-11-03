// Loop through each window and the them with the higher
// list items being drawn first
for(var i = ds_list_size(windows)-1; i >= 0; i--) {
    var _window = windows[| i];
    if(instance_exists(_window)) {
        var _wx = _window.x;
        var _wy = _window.y;
        // Drawing the top bar
        var _banner_col = c_gray;
        if(_window != window_selected) _banner_col = c_dkgray;
        draw_rectangle_color(_wx, _wy, _wx + _window.window_width, _wy + window_top_bar_height, _banner_col, _banner_col, _banner_col, _banner_col, false);
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        draw_set_color(c_white);
        var _name_margin = 5;
        draw_text(_wx + _name_margin, _wy + window_top_bar_height/2, _window.window_name);
        
        // Drawing the window contents
        if(surface_exists(_window.window_surface)) draw_surface(_window.window_surface, _wx, _wy + window_top_bar_height);
        
    }
}