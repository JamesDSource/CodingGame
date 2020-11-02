if(!surface_exists(window_surface)) window_surface = surface_create(window_width, window_height);
surface_set_target(window_surface);

// Resizing
if(surface_get_width(window_surface) != window_width || surface_get_height(window_surface) != window_height) {
    surface_resize(window_surface, window_width, window_height);
}

draw_clear_alpha(c_white, 0);
if(is_method(window_draw_function)) window_draw_function();
surface_reset_target();