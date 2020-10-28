function array_append(_array, _value) {
	_array[array_length(_array)] = _value;	
	return _array;
}

function array_insert(_array, _index, _value) {
	var _new_array = [];
	for(var i = 0; i <= array_length(_array); i++) {
		if(i < _index) _new_array[i] = _array[i];
		else if(i == _index) _new_array[i] = _value;
		else _new_array[i] = _array[i - 1];
	}
	return _new_array;
}

function array_delete(_array, _index) {
	var _new_array = [];
	for(var i = 0; i < array_length(_array)-1; i++) {
		if(i < _index) _new_array[i] = _array[i];
		else _new_array[i] = _array[i + 1];
	}
	return _new_array;
}

function array_has(_array, _value) {
	for(var i = 0; i < array_length(_array); i++) {
		if(_array[i] == _value) return true;
	}
	return false;
}

function array_position(_array, _value) {
	var _positions = [];
	for(var i = 0; i < array_length(_array); i++) {
		if(_array[i] == _value) _positions = array_append(_positions, i);
	}
	switch(array_length(_positions)) {
		case 0: return undefined; break;
		case 1: return _positions[0]; break;
		default: return _positions; break;
	}
	return false;
}

function array_has_struct(_array, _variable, _value) {
	for(var i = 0; i < array_length(_array); i++) {
		if(variable_struct_exists(_array[i], _variable) && variable_struct_get(_array[i], _variable) == _value) return true;
	}
	return false;
}