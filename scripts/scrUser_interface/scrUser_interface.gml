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
    visible = true;
}

function UI_window_create(_name) {
    ds_list_add(oUser_interface.UI_windows, new UI_window(_name, 0, 0, 100, 100));
    return _name;
}

function UI_window_destroy(_name) {
    var _list = oUser_interface.UI_windows;
	if(ds_exists(_list, ds_type_list)) {
	    for(var i = 0; i < ds_list_size(_list); i++) {
	        if(_list[| i].name == _name) {
	            ds_list_delete(_list, i);
	            return true;
	        }
	    }
	    return false;
	}
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

function UI_window_set_visible(_name, _visible) {
	var _window = UI_window_find(_name);
	_window.visible = _visible;
}

function UI_window_set_element_positions(_name) {
    var _window = UI_window_find(_name);
    return UI_set_positions(_window.tree, _window.rect, []);
}

function UI_window_hovering(_name, _mouse_x, _mouse_y) {
    var _window = UI_window_find(_name);
    return UI_hovering(_window.tree, _mouse_x, _mouse_y);
}

function UI_window_draw(_name) {
    var _window = UI_window_find(_name);
    UI_draw(_window.tree);
}
#endregion
#region Elements
// The path will look something like "Container1/StartButton", there is no need to put root,
// to get the root element container, just put an empty string
function UI_find_element(_name, _path) {
    var _tokens = get_tokens(_path, []);
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
        
        case "Tab selection":
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
    if(_element.constraint.colliding) array_push(_existing_rects, _return_rect);
    
    // Getting rects for the children of containers
    if(_element.element_name == "Container") {
        var _container_rects = [];
        for(var i = 0; i < array_length(_element.children); i++) {
            _container_rects = UI_set_positions(_element.children[i], _return_rect, _container_rects);
        }
    }
    
    return _existing_rects;
}

// Draws the element based on the rect.
// This function only works if
// UI_set_position has been called on
// the element before
function UI_draw(_element) {
    if(!variable_struct_exists(_element, "rect")) throw "Element does not have position";
    
    var _rect = _element.rect;
    switch(_element.element_name) {
        case "Container":
            for(var i = 0; i < array_length(_element.children); i++) {
                UI_draw(_element.children[i]);
            }
            break;
        
        case "Box":
            var _col = _element.color;
            draw_rectangle_color(_rect.x, _rect.y, _rect.x + _rect.width, _rect.y + _rect.height, _col, _col, _col, _col, false);
            break;
        
        case "Tab selection":
        	var _tab_size = _element.get_tab_size();
        	var _tab_draw_pos = {
        		x: _element.rect.x,
        		y: _element.rect.y + _element.rect.height - sprite_get_height(_element.sprite)
        	}
        	
        	draw_set_halign(fa_left);
        	draw_set_valign(fa_middle);
        	draw_set_color(_element.text_color);
        	draw_set_font(_element.font);
        	for(var i = 0; i < array_length(_element.tabs); i++) {
        		_element.tab_slice.subimage = i == _element.tab_index_selected ? 2 : (i == _element.tab_index_hovering ? 1 : 0);
        		_element.tab_slice.draw(_tab_draw_pos.x, _tab_draw_pos.y, _tab_size);
        		
        		var _text = _element.tabs[i].text;
        		var _shortened = false;
        		while(string_width(_text) > max(0, _tab_size - _element.tab_slice.slice_size*2 - sprite_get_width(_element.x_sprite))) {
        			_text = string_delete(_text, string_length(_text), 1);
        			_shortened = true;
        		}
        		
        		if(_shortened && string_length(_text) >= 3) {
        			_text = string_delete(_text, string_length(_text)-2, 3);
        			_text += "...";
        		}
        		
        		draw_text(_tab_draw_pos.x + _element.tab_slice.slice_size, _tab_draw_pos.y + sprite_get_height(_element.sprite)/2, _text);
        		draw_sprite(_element.x_sprite, _element.tab_index_hovering_x == i ? 1 : 0, _tab_draw_pos.x + _tab_size - _element.tab_slice.slice_size - sprite_get_width(_element.x_sprite), _tab_draw_pos.y + sprite_get_height(_element.sprite)/2 - sprite_get_height(_element.x_sprite)/2);
        		_tab_draw_pos.x += _tab_size;
        		
        	}
        	break;
        
        case "Text box":
            if(!surface_exists(_element.surface)) _element.surface = surface_create(_rect.width, _rect.height);
            if(surface_get_width(_element.surface) != _rect.width || surface_get_height(_element.surface) != _rect.height) surface_resize(_element.surface, _rect.width, _rect.height);
            
            surface_set_target(_element.surface);
            
            draw_clear_alpha(c_white, 0.0);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        	draw_set_font(_element.font);
            
            var _text_draw_x = _element.text_margin, _text_draw_y = _element.text_margin;
            var _offset = 0;
            for(var i = 1; i <= string_length(_element.text) + 1; i++) {
            	draw_set_color(_element.font_color);
            	
            	if(_element.highlighting.text == _element.text && !is_undefined(_element.highlighting.colors[i-1])) {
            		draw_set_color(_element.highlighting.colors[i-1]);
            	}
            	
            	// Draw the cursor
            	if(_element.selected && _element.text_cursor_index == i) {
            		draw_text_color(_text_draw_x - _element.char_seperation/2, _text_draw_y, "|", _element.font_color, _element.font_color, _element.font_color, _element.font_color, draw_get_alpha());
            	}
            	
            	if(i <= string_length(_element.text)) {
	            	
	            	var _char = string_char_at(_element.text, i);
	            	switch(_char) {
	            		case "\n":
	            			_text_draw_y += _element.line_seperation;
	            			_text_draw_x = _element.text_margin;
	            			_offset = 0;
	            			break;
	            		
	            		default:
	            			var _prev_draw_x = _text_draw_x;
	            			
	            			draw_text(_text_draw_x, _text_draw_y, _char == "\t" ? "~":_char);
	            			_offset += _element.get_char_offset(_char, _offset);
	            			_text_draw_x = _element.text_margin + _offset*_element.char_seperation;
	            			
	            			// Highlights the text if needed
	            			if(between(_element.text_highlight_index, _element.text_cursor_index, true, false, i)) {
	            				var _highlight_color = _element.highlight_color;
	            				draw_set_alpha(0.4);
	            				draw_rectangle_color(_prev_draw_x, _text_draw_y, _text_draw_x-1, _text_draw_y + _element.line_seperation-1, _highlight_color, _highlight_color , _highlight_color, _highlight_color, false);
	            				draw_set_alpha(1);
	            			}
	            			break;
	            	}
            	}
            }
            
            surface_reset_target();
            
            draw_surface(_element.surface, _rect.x, _rect.y);
            break;
    }
    
}


// Determins if the element is being 
// hovered over by the mouse.
// This function only works if
// UI_set_position has been called on
// the element before
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


// Takes in the input of an element.
// This function only works if
// UI_set_position has been called on
// the element before
function UI_input(_element, _hovering) {
    if(!variable_struct_exists(_element, "rect")) throw "Element does not have position";
    var _is_hovering = _element == _hovering;
    
    switch(_element.element_name) {
        case "Container":
            for(var i = 0; i < array_length(_element.children); i++) {
                UI_input(_element.children[i], _hovering);
            }
            break;
        
        case "Tab selection":
        	_element.tab_index_hovering = -1;
        	_element.tab_index_hovering_x = -1;
        	if(_is_hovering) {
        		var _mouse_offset_x = device_mouse_x_to_gui(0) - _element.rect.x;
        		var _tab_size = _element.get_tab_size();
        		var _pos = _mouse_offset_x div _tab_size;
        		
        		if(_pos >= 0 && _pos < array_length(_element.tabs)) {
        			_element.tab_index_hovering = _pos;
        			
        			// If the mouse is hovering over the X button
        			if(_mouse_offset_x > (_pos + 1)*_tab_size - _element.tab_slice.slice_size - sprite_get_width(_element.x_sprite)) _element.tab_index_hovering_x = _pos;
        			
        			if(mouse_check_button_pressed(mb_left)) {
        				if(_element.tab_index_hovering_x != -1) _element.remove_tab(_pos);
        				else _element.tab_index_selected = _pos;
        			}
        		}
        	}
        	_element.tab_index_selected = clamp(_element.tab_index_selected, 0, max(0, array_length(_element.tabs)-1));
        	break;
        
        case "Text box":
        	// getting the mouse position relative to the text box
        	var _mouse_offset = {
				x: device_mouse_x_to_gui(0) - (_element.rect.x + _element.text_margin),
				y: device_mouse_y_to_gui(0) - (_element.rect.y + _element.text_margin)
			}
			var _line_offset = _mouse_offset.x div _element.char_seperation;
			var _line = _mouse_offset.y div _element.line_seperation;
			
            if(mouse_check_button_pressed(mb_left)) {
            	// Reset text highlighting
            	_element.text_highlight_index = -1;
            	_element.text_cursor_index = -1;
            	
            	// If the text box is being clicked
            	if(_is_hovering) {
            		// Set the cursor to where the mouse is clicking
            		_element.selected = true;
            		_element.text_cursor_index = _element.add_offset_on_line(_line, _line_offset);
            		_element.text_highlight_index = _element.text_cursor_index;
            	}
                else _element.selected = false;
            }
            else if(mouse_check_button(mb_left) && _element.selected) {
            	_element.text_cursor_index = _element.add_offset_on_line(_line, _line_offset);
            }
            
            if(_element.selected) {
                for(var i = 0; i < array_length(global.valid_characters); i++) {
                    var _keycode = global.valid_characters[i].keycode;
                    var _key_timer = _element.key_timers[i];
                    
                    if(_key_timer.time > 0) _key_timer.time -= _key_timer.subtract;
                    if(keyboard_check_pressed(_keycode) || (keyboard_check(_keycode) && _key_timer.time <= 0)) {
                    	if(keyboard_check(vk_control)) {
                    		switch(_keycode) {
                    			case ord("Z"): // Undo
                    				_element.revert_state();
                    				break;
                    			case ord("Y"): // Redo
                    				_element.restore_state();
                    				break;
                    			case ord("X"): // Cut
                    			case ord("C"): // Copy
                    				var _min = min(_element.text_cursor_index, _element.text_highlight_index);
                    				var _max = max(_element.text_cursor_index, _element.text_highlight_index);
                    				clipboard_set_text(string_copy(_element.text, _min, _max - _min));
                    				
                    				if(_keycode == ord("X")) _element.delete_highlighted();
                    				break;
                    			case ord("V"): // Paste
                    				var _clipboard = clipboard_get_text();
                    				_element.insert_text(_clipboard);
                    				break;
                    		}
                    	}
                    	else {
	                        switch(_keycode) {
	                        	case vk_left:
	                        		_element.move_cursor(-1, 0, keyboard_check(vk_shift));
	                        		break;
	                        	case vk_right:
	                        		_element.move_cursor(1, 0, keyboard_check(vk_shift));
	                        		break;
	                        	case vk_up:
	                        		_element.move_cursor(0, -1, keyboard_check(vk_shift));
	                        		break;
	                        	case vk_down:
	                        		_element.move_cursor(0, 1, keyboard_check(vk_shift));
	                        		break;
	                        	
	                            case vk_backspace:
	                            	if(!_element.delete_highlighted()) {
		                                _element.text = string_delete(_element.text, _element.text_cursor_index-1, 1);
		                                _element.move_cursor(-1, 0, false);
	                            	}
	                                _element.save_state();
	                                break;
	                                
	                            case vk_enter:
	                            	var _add = "\n";
	                            	var _tabs = 0;
	                            	var _pos = _element.get_line_position(string_get_line(_element.text, _element.text_cursor_index));
	                            	var _char = string_char_at(_element.text, _pos);
	                            	while(_char == "\t" && _pos < _element.text_cursor_index) {
	                            		_tabs++;
	                            		_pos++;
	                            		_char = string_char_at(_element.text, _pos);
	                            	}
	                            	repeat(_tabs) _add += "\t";
	                            	
	                            	
	                            	_element.insert_text(_add);
	                            	break;
	                            
	                            default:
	                                var _char_add = keyboard_check(vk_shift) ? global.valid_characters[i].uppercase : global.valid_characters[i].lowercase;
	                                _element.insert_text(_char_add);
	                                break;
	                        }
                    	}
                    	_key_timer.time = _element.key_hold_time;
                        _key_timer.subtract += _element.key_hold_acceleration;
                    }
                    else if(!keyboard_check(_keycode)) _key_timer.subtract = 0;
                }
            	if(_element.treat_as_code && _element.highlighting.text != _element.text) {
            		_element.tokens = get_tokens(_element.text, [global.standard_library]);
            		_element.set_syntax_highlighting(_element.tokens);
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
        array_push(children, _element);
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

function UI_element_tab_selection(_name, _sprite, _x_sprite, _text_color, _font, _sizing_type, _h_sizing, _v_sizing) constructor {
    element_name = "Tab selection";
    name = _name;
    sprite = _sprite;
    x_sprite = _x_sprite;
    text_color = _text_color;
    font = _font;
    
    tab_slice = new three_slice(sprite, 0, SLICEMODE.STREATCH);
    constraint = new UI_constraint();
    
    sizing_type = _sizing_type;
    h_sizing = _h_sizing;
    v_sizing = _v_sizing;
    
    tabs = [];
    tab_index_hovering = -1;
    tab_index_selected = -1;
    tab_index_hovering_x = -1;
    max_tabs = 10;
    
    max_tab_size = 348;
    
    destroy_values_on_remove = true;
    
    function get_selected_tab() {
    	if(array_length(tabs) > 0) {
    		return tabs[tab_index_selected];
    	}
    }
    
    function get_tab_size() {
    	if(variable_struct_exists(self, "rect")) {
    		var _w = rect.width;
    		var _tab_size = _w/array_length(tabs);
    		
    		return min(max_tab_size, _tab_size);
    	}
    	else return max_tab_size;
    }
    
    function add_tab(_text, _value) {
    	if(array_length(tabs) == 0) tab_index_selected = 0;
    	array_push(tabs, {text:_text, value:_value});
    	
    	// Removing all excess tabs from the end of the array
    	// while it has more tabs than allowed
    	while(array_length(tabs) > max_tabs) {
    		array_delete(tabs, array_length(tabs)-1, 1);
    	}
    }
    
    function remove_tab(_index) {
    	if(destroy_values_on_remove) {
    		var _value = tabs[_index].value;
    		if(is_struct(_value)) delete _value;
    		else if(instance_exists(_value)) instance_destroy(_value);
    	}
    	array_delete(tabs, _index, 1);
    }
    
    function remove_tabs_by_value(_value) {
    	var _is_here = true;
    	while(_is_here) {
    		_is_here = false;
    		for(var i = 0; i < array_length(tabs); i++) {
    			if(tabs[i].value == _value) {
    				_is_here = true;
    				array_delete(tabs, i, 1);
    				break;
    			}
    		}
    	}
    }
}

function UI_element_text_box(_name, _sizing_type, _h_sizing, _v_sizing, _text_color, _highlight_color, _writeable, _spill) constructor {
    element_name = "Text box";
    name = _name;
    constraint = new UI_constraint();
    sizing_type = _sizing_type;
    h_sizing = _h_sizing;
    v_sizing = _v_sizing;
    writeable = _writeable;
    spill = _spill;
    can_newline = true;
    selected = false;
    
    surface = -1;
    char_seperation = 24;
    line_seperation = 36;
    text_margin = char_seperation/2;
    
    key_hold_time = 40;
    key_hold_acceleration = 3;
    key_timers = array_create(array_length(global.valid_characters));
    for(var i = 0; i < array_length(global.valid_characters); i++) {
        key_timers[i] = {
            time: 0,
            subtract: 1
        }
    }
    
    font = fCode_gintronic;
    font_color = _text_color;
    highlight_color = _highlight_color;
    
    text = "";
    text_cursor_index = 1;
    text_highlight_index = 1;
    
    // Inserts text to the cursor
    function insert_text(_text) {
    	delete_highlighted();
    	text = string_insert(_text, text, text_cursor_index);
		move_cursor(string_length(_text), 0, false);
		save_state();
    }
    
    // Removes the part of the text that is selected
    function delete_highlighted() {
    	if(abs(text_cursor_index - text_highlight_index) > 0) {
    		var _min = min(text_cursor_index, text_highlight_index);
    		var _max = max(text_cursor_index, text_highlight_index);
    		
    		text = string_delete(text, _min, _max-_min);
    		
    		text_cursor_index = _min;
    		text_highlight_index = _min;
    		
    		return true;
    	}
    	return false;
    }
    
    // This function moves the cursor with a 2D vector
    function move_cursor(_horizontal, _verticle, _drag) {
    	if(_verticle != 0) {
    		var _offset = offset_from_line(text_cursor_index);
    		var _new_line = string_get_line(text, text_cursor_index) + _verticle;
    		
    		text_cursor_index = add_offset_on_line(_new_line, _offset);
		}
    	
    	
    	text_cursor_index += _horizontal;
    	text_cursor_index = clamp(text_cursor_index, 1, string_length(text)+1);
    	if(!_drag) text_highlight_index = text_cursor_index;
    }
    
    // Gets the unit offset from the start of a line
    // an offset is given in the amount of character spaces
    // certain characters like tabs (\t) can be more than one
    // character space
    function offset_from_line(_pos) {
    	var _offset = 0;
    	var _line_pos = get_line_position(string_get_line(text, _pos));
    	while(_line_pos < _pos) {
    		_offset += get_char_offset(string_char_at(text, _line_pos), _offset);
    		_line_pos++;
    	}
    	return _offset;
    }
	
	// Get the offset of a certain character based
	// on the current offset. Most characters will just
	// return 1 offset.
	function get_char_offset(_char, _offset) {
		switch(_char) {
			case "\t":
				var _indent_length = 4;
				var _indent = ceil((_offset + 1)/_indent_length);
				return _indent*_indent_length - _offset;
				break;
			
			default:
				return 1;
				break;
		}
	}
	
    
    // Get's the position of the start of a line
    function get_line_position(_line) {
    	var _newlines = string_pos_all("\n", text);
    	array_insert(_newlines, 0, 0);
    	_line = clamp(_line, 0, array_length(_newlines)-1);
    	return _newlines[_line]+1;
    }
    
    // Returns the character postion of the offset of a certain line
    function add_offset_on_line(_line, _offset) {
    	_pos = get_line_position(_line);
    	while(true) {
    		if(_offset <= offset_from_line(_pos) || string_char_at(text, _pos) == "\n" || _pos > string_length(text)) {
    			break;
    		}
    		_pos++;
    	}
    	return _pos;
    }
    
    // Undo redo states
    timeline = [];
    timeline_pos = -1;
    
    // Saves the current state of the text to the timeline
    function save_state() {
    	if(timeline_pos < array_length(timeline)-1) {
    		array_delete(timeline, timeline_pos+1, array_length(timeline)-timeline_pos);
    	}
    	array_push(timeline, {text: text, cursor_pos: text_cursor_index});
    	timeline_pos++;
    	
    	var _max_states = 300;
    	while(array_length(timeline) > _max_states) {
    		array_delete(timeline, 0, 1);
    		timeline_pos--;
    	}
    }
    
    // If there is a previous state in the timeline, it will revert the state
    // of the text box to it
    function revert_state() {
    	if(array_length(timeline) > 0) {
    		timeline_pos = max(timeline_pos-1, 0);
    		text = timeline[timeline_pos].text;
    		text_cursor_index = timeline[timeline_pos].cursor_pos;
    	}
    }
    
    // If there is a state that was reverted in the timeline, it will restore
    // the state back into the text box
    function restore_state() {
    	if(array_length(timeline) > 0) {
    		timeline_pos = min(timeline_pos+1, array_length(timeline)-1);
    		text = timeline[timeline_pos].text;
    		text_cursor_index = timeline[timeline_pos].cursor_pos;
    	}
    }
    
    save_state();
    
    // Code features
    treat_as_code = false;
    tokens = [];
    
    // Syntax highlighting
    highlighting = {
    	text: "",
    	colors: []
    };
    function set_syntax_highlighting(_tokens) {
    	highlighting.text = text;
    	highlighting.colors = array_create(string_length(text), undefined);
    	for(var i = 0; i < array_length(_tokens); i++) {
    		var _current_token = _tokens[i];
    		var _color = undefined;
    		switch(_current_token.type) {
    			case TOKENTYPE.IF:
    			case TOKENTYPE.ELIF:
    			case TOKENTYPE.ELSE:
    			case TOKENTYPE.LOOP:
    			case TOKENTYPE.FOR:
    			case TOKENTYPE.IN:
    			case TOKENTYPE.FUNC:
    			case TOKENTYPE.METHOD:
    			case TOKENTYPE.RETURN:
    			case TOKENTYPE.BREAK:
    			case TOKENTYPE.OPEN_CURLY:
    			case TOKENTYPE.CLOSE_CURLY:
    				_color = c_orange;
    				break;
    			
    			case TOKENTYPE.STRING:
    				_color = c_lime;
    				break;
    			
    			case TOKENTYPE.NUMBER:
    				_color = c_red;
    				break;
    			
    			case TOKENTYPE.VARIABLE:
    				_color = c_silver;
    				if((i > 0 && _tokens[i-1].type == TOKENTYPE.FUNC) || i < array_length(_tokens)-1 && _tokens[i+1].type == TOKENTYPE.OPEN_PAREN) {
    					_color = c_yellow;
    				}
    				break;
    		}
    		
    		if(!is_undefined(_color)) {
    			for(var j = _current_token.start_pos; j <= _current_token.end_pos; j++) {
    				highlighting.colors[j-1] = _color;
    			}
    		}
    	}
    }
}
#endregion