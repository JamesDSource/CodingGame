#region Key characters
function character(_code, _uppercase, _lowercase) constructor {
	if(_uppercase == "" && _lowercase != "") uppercase = string_upper(_lowercase);
	else uppercase = _uppercase;
	
	if(_lowercase == "" && _uppercase != "") lowercase = _uppercase;
	else lowercase = _lowercase;
	
	if(_code == -1) keycode = ord(uppercase);
	else keycode = _code;
}


global.valid_characters = [
	new character(-1, "", "a"),
	new character(-1, "", "b"),
	new character(-1, "", "c"),
	new character(-1, "", "d"),
	new character(-1, "", "e"),
	new character(-1, "", "f"),
	new character(-1, "", "g"),
	new character(-1, "", "h"),
	new character(-1, "", "i"),
	new character(-1, "", "j"),
	new character(-1, "", "k"),
	new character(-1, "", "l"),
	new character(-1, "", "m"),
	new character(-1, "", "n"),
	new character(-1, "", "o"),
	new character(-1, "", "p"),
	new character(-1, "", "q"),
	new character(-1, "", "r"),
	new character(-1, "", "s"),
	new character(-1, "", "t"),
	new character(-1, "", "u"),
	new character(-1, "", "v"),
	new character(-1, "", "w"),
	new character(-1, "", "x"),
	new character(-1, "", "y"),
	new character(-1, "", "z"),
	new character(ord("1"), "!", "1"),
	new character(ord("2"), "@", "2"),
	new character(ord("3"), "#", "3"),
	new character(ord("4"), "$", "4"),
	new character(ord("5"), "%", "5"),
	new character(ord("6"), "^", "6"),
	new character(ord("7"), "&", "7"),
	new character(ord("8"), "*", "8"),
	new character(ord("9"), "(", "9"),
	new character(ord("0"), ")", "0"),
	new character(vk_space, " ", " "),
	new character(vk_enter, "\n", ""),
	new character(vk_tab, "\t", ""),
	new character(vk_backspace, "", ""),
	new character(vk_delete, "", ""),
	new character(vk_left, "", ""),
	new character(vk_right, "", ""),
	new character(vk_up, "", ""),
	new character(vk_down, "", ""),
	new character(219, "{", "["),
	new character(221, "}", "]"),
	new character(186, ":", ";"),
	new character(222, "\"", "'"),
	new character(187, "+", "="),
	new character(189, "_", "-"),
	new character(188, "<", ","),
	new character(190, ">", "."),
	new character(191, "?", "/")
];
#endregion
#region Window
function UI_window(_name, _x, _y, _width, _height) constructor {
    name = _name;
    rect = new rectangle(_x, _y, _width, _height);
    tree = new UI_element_container("root");    
}

function UI_window_create(_name) {
    ds_list_add(oUser_interface.UI_windows, new UI_window(_name, 0, 0, 100, 100));
    return _name;
}

function UI_window_destroy(_name) {
    var _list = oUser_interface.UI_windows;
    for(var i = 0; i < ds_list_size(_list); i++) {
        if(_list[| i].name == _name) {
            ds_list_delete(_list, i);
            return true;
        }
    }
    return false;
}

function UI_window_find(_name) {
    var _list = oUser_interface.UI_windows;
    for(var i = 0; i < ds_list_size(_list); i++) {
        if(_list[| i].name == _name) return _list[| i];
    }
    throw "window " + _name + " does not exist";
}

function UI_window_resize(_name, _width, _height) {
    var _window = UI_window_find(_name);
    
    _window.rect.width = _width;
    _window.rect.height = _height;
}

function UI_window_set_position(_name, _x, _y) {
    var _window = UI_window_find(_name);
    _window.rect.x = _x;
    _window.rect.y = _y;
}

function UI_window_set_element_positions(_name) {
    var _window = UI_window_find(_name);
    return UI_set_positions(_window.tree, _window.rect, []);
}

function UI_window_hovering(_name, _mouse_x, _mouse_y) {
    var _window = UI_window_find(_name);;
    return UI_hovering(_window.tree, _mouse_x, _mouse_y);
}

function UI_window_draw(_name) {
    var _window = UI_window_find(_name);;
    UI_draw(_window.tree);
}
#endregion
#region Elements
// The path will look something like "Container1/StartButton", there is no need to put root,
// to get the root element container, just put an empty string
function UI_find_element(_name, _path) {
    var _tokens = get_tokens(_path);
    var _tree = UI_window_find(_name);
    
    if(is_undefined(_tree)) throw "window " + _name + " does not exist";
    
    _tree = _tree.tree;
    
    for(var i = 0; i < array_length(_tokens); i++) {
        switch(_tokens[i].type) {
            case TOKENTYPE.DIVIDE: // Skips
                continue; 
                break;
            
            case TOKENTYPE.VARIABLE: // Goes down the tree
                if(_tree.element_name != "Container") throw "Node does not have children";
                var _found = false;
                
                for(var j = 0; j < array_length(_tree.children); j++) {
                    if(_tree.children[j].name == _tokens[i].value) {
                        _tree = _tree.children[j];
                        _found = true;
                        break;
                    }
                }
                
                if(!_found) throw "Element specified in path does not exist";
                break;
            
            default:
                throw "Incorrect path syntax nerd";
                break;
        }
    }
    return _tree;
}

// This function goes down the tree and sets
// the rect variable to hold a rectangle instance
// for the position of the element, it returns the
// list of the rectangles.
function UI_set_positions(_element, _area_rect, _existing_rects) { // String or element, rectangle, array of rectangles
    // Temp function that checks if the rectangle is
    // colliding with any of the others
    var _is_colliding = function(_rect, _existing_rects) {
        for(var i = 0; i < array_length(_existing_rects); i++) {
            if(_existing_rects[i].colliding_with_rectangle(_rect)) {
                return true;
            }
        }
        return false;
    }
    
    var _return_rect = new rectangle(0, 0, 100, 100);
    // For getting the width and height of the rectangle
    switch(_element.element_name) {
        case "Container":
            var _cw = _area_rect.width * _element.h_fill;
            var _ch = _area_rect.height * _element.v_fill;
            _return_rect.width = _cw;
            _return_rect.height = _ch;
            break;
        
        case "Box":
            var _bw = _area_rect.width * _element.fill;
            var _bh = _area_rect.height * _element.fill;
            _return_rect.width = _bw;
            _return_rect.height = _bh;
            break;        
        
        case "Text box":
            if(_element.sizing_type == ELEMENTSIZINGTYPE.PERCENT) {
                var _bw = _area_rect.width * _element.h_sizing;
                var _bh = _area_rect.height * _element.v_sizing;
            }
            else if(_element.sizing_type == ELEMENTSIZINGTYPE.PIXELS) {
                var _bw = _element.h_sizing;
                var _bh = _element.v_sizing;
            }
            _return_rect.width = _bw;
            _return_rect.height = _bh;
            break;
    }
    
    // For getting the position of the rectangle
    var _constraint = _element.constraint;
    var _x_margin = _constraint.margin.horizontal*(_constraint.anchor_points.horizontal > 0.5 ? -1 : 1);
    var _y_margin = _constraint.margin.verticle*(_constraint.anchor_points.verticle > 0.5 ? -1 : 1);
    _return_rect.x = _area_rect.x + (_area_rect.width - _return_rect.width)*_constraint.anchor_points.horizontal + _x_margin;
    _return_rect.y = _area_rect.y + (_area_rect.height - _return_rect.height)*_constraint.anchor_points.verticle + _y_margin;
    
    
    // Moving the rectangle if it is colliding
    if(_element.constraint.colliding) {
        var _push_direction = {x: 0, y: 0};
        if(_element.constraint.stack_verticle) _push_direction.y = _element.constraint.anchor_points.verticle > 0.5 ? -1 : 1;
        else _push_direction.x = _element.constraint.anchor_points.horizontal > 0.5 ? -1 : 1;
        
        while(_is_colliding(_return_rect, _existing_rects)) {
            _return_rect.x += _push_direction.x;
            _return_rect.y += _push_direction.y;
            
            if(!_is_colliding(_return_rect, _existing_rects)) {
                if(_element.constraint.stack_verticle) _return_rect.y += _y_margin;
                else _return_rect.x += _x_margin;
            }
        }
    }
    
    
    // Setting the rect
    _element.rect = _return_rect;
    if(_element.constraint.colliding) _existing_rects = array_append(_existing_rects, _return_rect);
    
    // Getting rects for the children of containers
    if(_element.element_name == "Container") {
        var _container_rects = [];
        for(var i = 0; i < array_length(_element.children); i++) {
            _container_rects = UI_set_positions(_element.children[i], _return_rect, _container_rects);
        }
    }
    
    return _existing_rects;
}

function UI_draw(_element) {
    if(!variable_struct_exists(_element, "rect")) throw "Element does not have position";
    
    var _rect = _element.rect;
    switch(_element.element_name) {
        case "Container":
            draw_rectangle_color(_rect.x, _rect.y, _rect.x + _rect.width, _rect.y + _rect.height, c_black, c_black, c_black, c_black, true);
            for(var i = 0; i < array_length(_element.children); i++) {
                UI_draw(_element.children[i]);
            }
            break;
        
        case "Box":
            var _col = _element.color;
            draw_rectangle_color(_rect.x, _rect.y, _rect.x + _rect.width, _rect.y + _rect.height, _col, _col, _col, _col, false);
            break;
        
        case "Text box":
            if(!surface_exists(_element.surface)) _element.surface = surface_create(_rect.width, _rect.height);
            if(surface_get_width(_element.surface) != _rect.width || surface_get_height(_element.surface) != _rect.height) surface_resize(_element.surface, _rect.width, _rect.height);
            
            surface_set_target(_element.surface);
            
            draw_clear_alpha(c_white, 0.0);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            
            draw_text(0, 0, _element.text);
            
            surface_reset_target();
            
            draw_surface(_element.surface, _rect.x, _rect.y);
            break;
    }
    
}

function UI_hovering(_element, _mouse_x, _mouse_y) {
    if(!variable_struct_exists(_element, "rect")) throw "Element does not have position";
    if(_element.element_name == "Container") {
        for(var i = 0; i < array_length(_element.children); i++) {
            var _return_element = UI_hovering(_element.children[i], _mouse_x, _mouse_y);
            if(_return_element != -1) return _return_element; 
        }
        return -1;
    }
    else if(_element.constraint.colliding) {
        if(_element.rect.colliding_with_point(_mouse_x, _mouse_y)) return _element;
        else return -1;
    }
    else return -1;
}

function UI_input(_element, _hovering) {
    if(!variable_struct_exists(_element, "rect")) throw "Element does not have position";
    var _is_hovering = _element == _hovering;
    
    switch(_element.element_name) {
        case "Container":
            for(var i = 0; i < array_length(_element.children); i++) {
                UI_input(_element.children[i], _hovering);
            }
            break;
        case "Text box":
            if(mouse_check_button_pressed(mb_left)) {
                _element.text_cursor_index = _is_hovering ? string_length(_element.text)+1 : -1
            }
            
            if(_element.text_cursor_index != -1) {
                for(var i = 0; i < array_length(global.valid_characters); i++) {
                    var _keycode = global.valid_characters[i].keycode;
                    var _key_timer = _element.key_timers[i];
                    
                    if(_key_timer.time > 0) _key_timer.time -= _key_timer.subtract;
                    if(keyboard_check_pressed(_keycode) || (keyboard_check(_keycode) && _key_timer.time <= 0)) {
                        switch(_keycode) { 
                            case vk_backspace:
                                _element.text = string_delete(_element.text, _element.text_cursor_index-1, 1);
                                _element.text_cursor_index--;
                                break;
                            
                            default:
                                var _char_add = keyboard_check(vk_shift) ? global.valid_characters[i].uppercase : global.valid_characters[i].lowercase;
                                _element.text = string_insert(_char_add, _element.text, _element.text_cursor_index);
                                _element.text_cursor_index++;
                                break;
                        }
                        _key_timer.time = _element.key_hold_time;
                        _key_timer.subtract += _element.key_hold_acceleration;
                    }
                    else if(!keyboard_check(_keycode)) _key_timer.subtract = 0;
                }
            }
            break;
    }
}

// This object holds the anchor points, margins, and other positional data
function UI_constraint() constructor {
    colliding = true;
    stack_verticle = false;
    
    anchor_points = {
        horizontal: 0,
        verticle: 0
    }    
    
    margin = {
        horizontal: 0,
        verticle: 0
    }
    
    function set_margins(_horizontal, _verticle) {
        margin.horizontal = _horizontal;
        margin.verticle = _verticle;
    }
    
    function set_anchor_points(_horizontal, _verticle) {
        anchor_points.horizontal = _horizontal;
        anchor_points.verticle = _verticle;
    }
}

enum ELEMENTSIZINGTYPE {
    PERCENT,
    PIXELS
}

// For UI elements, the following is required:
//      An element name variable
//      A name variable
//      A constraint object

function UI_element_container(_name) constructor {
    element_name = "Container";
    name = _name;
    constraint = new UI_constraint();
    
    children = [];
    h_fill = 1;
    v_fill = 1;
    
    function add_child(_element) {
        children = array_append(children, _element);
    }
}

function UI_element_box(_name, _fill) constructor {
    element_name = "Box";
    name = _name;
    constraint = new UI_constraint();
    constraint.colliding = false;
    fill = _fill;
    color = c_white;
}

function UI_element_text_box(_name, _sizing_type, _h_sizing, _v_sizing, _writeable, _spill) constructor {
    element_name = "Text box";
    name = _name
    constraint = new UI_constraint();
    sizing_type = _sizing_type;
    h_sizing = _h_sizing;
    v_sizing = _v_sizing;
    writeable = _writeable;
    spill = _spill;
    can_newline = true;
    
    surface = -1;
    
    key_hold_time = 40;
    key_hold_acceleration = 3;
    key_timers = array_create(array_length(global.valid_characters));
    for(var i = 0; i < array_length(global.valid_characters); i++) {
        key_timers[i] = {
            time: 0,
            subtract: 1
        }
    }
    
    text = "";
    text_cursor_index = -1;
}
#endregion