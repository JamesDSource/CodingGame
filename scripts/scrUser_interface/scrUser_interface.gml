function UI_window(_x, _y, _width, _height) constructor {
    rect = new rectangle(_x, _y, _width, _height);
    tree = new UI_element_container("root");    
}

function UI_window_create(_name) {
    oUser_interface.UI_windows[? _name] = new UI_window(0, 0, 100, 100);
    return _name;
}

function UI_window_destroy(_name) {
    if(is_undefined(oUser_interface.UI_windows[? _name])) return false;
    ds_map_delete(oUser_interface.UI_windows, _name);
    return true;
}

// The path will look something like "Container1/StartButton", there is no need to put root
function UI_find_element(_name, _path) {
    var _tokens = get_tokens(_path);
    var _tree = oUser_interface.UI_windows[? _name];
    
    if(is_undefined(_tree)) throw "Trying to find element from window that does not exist";
    
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
function UI_set_positions(_name_or_element, _area_rect, _existing_rects) { // String or element, rectangle, array of rectangles
    // Temp function that checks if the rectangle is
    // colliding with any of the others
    var _is_colliding = function(_rect) {
        for(var i = 0; i < array_length(_existing_rects); i++) {
            if(_existing_rects[i].colliding_with_rectangle(_rect)) {
                return true;
            }
        }
        return false;
    }
    
    if(is_string(_name_or_element)) {
        var _tree = oUser_interface.UI_windows[? _name_or_element];
        if(is_undefined(_tree)) throw "Trying to find element from window that does not exist";
        var _element = _tree.tree;
    }
    else var _element = _name_or_element;
    
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
    }
    
    // For getting the position of the rectangle
    var _constraint = _element.constraint;
    _return_rect.x = _area_rect.x + (_area_rect.width - _return_rect.width)*_constraint.anchor_points.horizontal + _constraint.margin.horizontal;
    _return_rect.y = _area_rect.y + (_area_rect.height - _return_rect.height)*_constraint.anchor_points.verticle + _constraint.margin.verticle;
    // Moving the rectangle if it is colliding
    if(_element.colliding) {
        
    }
    // Setting the rect
    _element.rect = _return_rect;
    if(_element.colliding) _existing_rects = array_append(_existing_rects, _return_rect);
    return _existing_rects;
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
    
    function set_margin(_horizontal, _verticle) {
        margin.horizontal = _horizontal;
        margin.verticle = _verticle;
    }
    
    function set_anchor_points(_horizontal, _verticle) {
        anchor_points.horizontal = _horizontal;
        anchor_points.verticle = _verticle;
    }
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
    fill = _fill;
}