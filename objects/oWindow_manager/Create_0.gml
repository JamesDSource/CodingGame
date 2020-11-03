windows = ds_list_create();

function window_add(_window_id) {
    ds_list_insert(windows, 0, _window_id);
}

function window_remove(_window_id) {
    var _index = ds_list_find_index(windows, _window_id);
    if(_index != -1) ds_list_delete(windows, _index);
}

window_selected = noone;