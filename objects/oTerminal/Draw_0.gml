if(!surface_exists(background_surface)) {
    background_surface = surface_create(100, 100);
    surface_set_target(background_surface);
    draw_clear(background_col);
    surface_reset_target();
}
