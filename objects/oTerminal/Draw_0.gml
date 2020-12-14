if(surface_exists(global.terminal_surface)) {
    surface_set_target(global.terminal_surface);
    
    surface_reset_target();
}
else {
    global.terminal_surface = surface_create(window_get_width(), window_get_height());
}