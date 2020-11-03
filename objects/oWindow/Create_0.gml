oWindow_manager.window_add(id);
x = display_get_gui_width()/2 - window_width/2 + irandom_range(-100, 100);
y = display_get_gui_height()/2 - window_height/2  + irandom_range(-100, 100);

window_surface = -1;
window_draw_function = -1; // Replace this in child

selected = false;