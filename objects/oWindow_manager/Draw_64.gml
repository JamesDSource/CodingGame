// Loop through each window and the them with the higher
// list items being drawn first
for(var i = ds_list_size(windows)-1; i >= 0; i--) {
    var _window = windows[| i];
    with(_window) {
        // drawing the top bar
        draw_rectangle_color(x, y, x + window_width, y + other.window_top_bar_height, c_dkgray, c_dkgray, c_dkgray, c_dkgray, false);
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        draw_set_color(c_white);
        var _name_margin = 5;
        draw_text(x + _name_margin, y + other.window_top_bar_height/2, window_name);
        
        // drawing the window contents
        if(surface_exists(window_surface)) draw_surface(window_surface, x, y + other.window_top_bar_height)
    }
}