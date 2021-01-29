function library() constructor {
	methods = [];
	function add_method(_name, _method_call, _arguments) {
		var _new_method = {
			name: _name,
			method_call: _method_call,
			arguments: _arguments
		}
		array_push(methods, _new_method);
	}
}

global.standard_library = new library();


enum ARGUMENTTYPE {
	ANY,
	NUMBER,
	STRING,
	ARRAY
}

// Math and numbers
global.standard_library.add_method(
	"abs",
	function(_number) {
		return abs(_number);
	},
	[["Number", ARGUMENTTYPE.NUMBER]]
);
global.standard_library.add_method(
	"sign",
	function(_number) {
		return sign(_number);
	},
	[["Number", ARGUMENTTYPE.NUMBER]]
);
global.standard_library.add_method(
	"floor",
	function(_number) {
		return floor(_number);
	},
	[["Number", ARGUMENTTYPE.NUMBER]]
);
global.standard_library.add_method(
	"ceil",
	function(_number) {
		return ceil(_number);
	},
	[["Number", ARGUMENTTYPE.NUMBER]]
);
global.standard_library.add_method(
	"round",
	function(_number) {
		return round(_number);
	},
	[["Number", ARGUMENTTYPE.NUMBER]]
);

// Print
global.standard_library.add_method(
	"print",
	function(_text) {
		if(is_real(_text)) _text = string_from_real(_text);
		show_debug_message(_text);
	},
	[["Text", ARGUMENTTYPE.ANY]]
);

// Arrays
global.standard_library.add_method(
	"list_size",
	function(_list) {
		return array_length(_list);	
	},
	[["List", ARGUMENTTYPE.ARRAY]]
);
global.standard_library.add_method(
	"list_has",
	function(_list, _value) {
		return array_has(_list, _value);	
	},
	[["List", ARGUMENTTYPE.ARRAY], ["Value", ARGUMENTTYPE.ANY]]
);
global.standard_library.add_method(
	"list_position",
	function(_list, _value) {
		return array_position(_list, _value);
	},
	[["List", ARGUMENTTYPE.ARRAY], ["Value", ARGUMENTTYPE.ANY]]
);

// Random
global.standard_library.add_method(
	"choose",
	function(_items) {
		return _items[irandom_range(0, array_length(_items)-1)];	
	},
	[["items", ARGUMENTTYPE.ARRAY]]
);
global.standard_library.add_method(
	"rand_range",
	function(_lower, _upper) {
		return random_range(_lower, _upper);	
	},
	[["lower", ARGUMENTTYPE.NUMBER], ["upper", ARGUMENTTYPE.NUMBER]]
);
global.standard_library.add_method(
	"randi_range",
	function(_lower, _upper) {
		return irandom_range(floor(_lower), floor(_upper));	
	},
	[["lower", ARGUMENTTYPE.NUMBER], ["upper", ARGUMENTTYPE.NUMBER]]
);

