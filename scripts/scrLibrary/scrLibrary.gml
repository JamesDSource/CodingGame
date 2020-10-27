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

// Print
global.standard_library.add_method(
	"print",
	function print(_text) {
		show_debug_message(_text);
	},
	["Text"]
);