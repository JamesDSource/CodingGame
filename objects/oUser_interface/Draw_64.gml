// Drawing each element
for(var i = 0; i < ds_list_size(UI_windows); i++) {
    if(UI_windows[| i].visible) {
        UI_window_draw(UI_windows[| i].name);
    }
}