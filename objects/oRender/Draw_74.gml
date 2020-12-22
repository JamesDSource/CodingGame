if(surface_exists(replacement_surface) || surface_exists(application_surface)) {
    draw_surface_stretched(surface_exists(replacement_surface) ? replacement_surface:application_surface, 0, 0, display_get_gui_width(), display_get_gui_height());
}