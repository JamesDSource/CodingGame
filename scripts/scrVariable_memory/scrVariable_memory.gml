global.variable_memory = {};

function variable_set(_name, _value) {
	var _true_name = string(id) + _name;
	variable_struct_set(global.variable_memory, _true_name, _value);
}
function variable_get(_name) {
	var _true_name = string(id) + _name;
	return variable_struct_get(global.variable_memory, _true_name);
}