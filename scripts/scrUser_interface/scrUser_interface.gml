function UI_window(_x, _y) constructor {
    x = _x;
    y = _y;
    tree = new UI_element_container("root");    
}

function UI_window_create(_name) {
    oUser_interface.UI_windows[? _name] = new UI_window(0, 0);
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
                if(_tree.name != "Container") throw "Node does not have children";
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

// This object holds the anchor points, margins, and other positional data
function UI_constraint() constructor {
    anchor_points = {
        horizontal: 0,
        verticle: 0
    }    
    margin = {
        horizontal: 0,
        verticle: 0
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
 
    function add_child(_element) {
        children = array_append(children, _element);
    }
}

function UI_element_box(_name) constructor {
    element_name = "Box";
    name = _name;
    constraint = new UI_constraint();
}