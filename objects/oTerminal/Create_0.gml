drawing = false;
windows = [];

function add_window(_id) {
    array_push(windows, _id);
    
    var _win_name = _id.UI_window_name;
    UI_window_resize(_win_name, display_get_gui_width(), display_get_gui_height());
    UI_window_set_element_positions(_win_name);
}

function remove_window(_id) {
    var _index = array_position(windows, _id);
    if(!is_undefined(_index)) {
        array_delete(windows, _index, 1);
        instance_destroy(_id);
    }
}