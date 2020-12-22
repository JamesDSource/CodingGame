background_col = $222323;

drawing = false;
background_surface = -1;

bar_height = display_get_gui_height()*window_top_bar_percent;
navigation_bar_name = "Terminal nav bar";
UI_window_create(navigation_bar_name);
UI_window_resize(navigation_bar_name, display_get_gui_width(), bar_height);
var _root = UI_find_element(navigation_bar_name, "");

nav_bar = new UI_element_tab_selection("Navigation", sTerminal_tab, sTerminal_tab_X, $f0f6f0, fCode_gintronic, ELEMENTSIZINGTYPE.PERCENT, 1, 1);
_root.add_child(nav_bar);

UI_window_set_element_positions(navigation_bar_name);

function add_window(_id) {
    
    var _win_name = _id.UI_window_name;
    UI_window_resize(_win_name, display_get_gui_width(), display_get_gui_height() - bar_height);
    UI_window_set_position(_win_name, 0, bar_height);
    UI_window_set_element_positions(_win_name);
    
    nav_bar.add_tab(_id.window_name, _id);
}

function remove_window(_id) {
    var _index = array_position(windows, _id);
    if(!is_undefined(_index)) {
        if(is_array(_index)) {
            for(var i = 0; i < array_length(_index); i++) {
                array_delete(windows, _index[i], 1);
            }
        }
        else array_delete(windows, _index, 1);
        instance_destroy(_id);
    }
}
