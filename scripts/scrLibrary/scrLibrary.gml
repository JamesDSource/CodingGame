function library() constructor {
	methods = [];
	function add_method(_name, _method_call, _arguments) {
		var _new_method = {
			name: _name,
			method_call: _method_call,
			arguments: _arguments
		}
		methods = array_append(methods, _new_method);
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
	"pow",
	function(_base, _exponent) {
		return power(_base, _exponent);
	},
	[["Base", ARGUMENTTYPE.NUMBER], ["Exponent", ARGUMENTTYPE.NUMBER]]
);
global.standard_library.add_method(
	"sign",
	function(_number) {
		return sign(_number);
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