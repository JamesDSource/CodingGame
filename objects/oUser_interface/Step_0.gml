// Getting the element that the mouse is hovering over
var _element_hovering = -1;
for(var i = ds_list_size(UI_windows)-1; i >= 0; i--) {
    if(UI_windows[| i].visible) {
        _element_hovering = UI_window_hovering(UI_windows[| i].name, device_mouse_x_to_gui(0), device_mouse_y_to_gui(0));
        if(_element_hovering != -1) break;
    }
}

// Getting the inputs for each element
for(var i = 0; i < ds_list_size(UI_windows); i++) {
    if(UI_windows[| i].visible) {
        UI_input(UI_windows[| i].tree, _element_hovering);
    }
}