windows = [];

function add_window(_id) {
    windows = array_append(windows, _id);
}

function remove_window(_id) {
    var _index = array_position(window, _id);
    if(!is_undefined(_index)) {
        windows = array_remove(windows, _index);
        instance_destroy(_id);
    }
}

// Surface
global.terminal_surface = -1;