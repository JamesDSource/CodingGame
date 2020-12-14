switch(current_screen) {
    case SCREEN.MAP:
        if(surface_exists(application_surface)) draw_surface(application_surface, 0, 0);
        break;
    
    case SCREEN.TERMINAL:
        if(surface_exists(global.terminal_surface)) draw_surface(global.terminal_surface, 0, 0);
        break;
}