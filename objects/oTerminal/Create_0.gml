windows = [];

function add_window(_id) {
    array_push(windows, _id);
}

function remove_window(_id) {
    var _index = array_position(windows, _id);
    if(!is_undefined(_index)) {
        array_delete(windows, _index, 1);
        instance_destroy(_id);
    }
}

// Surface
global.terminal_surface = -1;