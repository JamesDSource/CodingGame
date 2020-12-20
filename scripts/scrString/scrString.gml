function string_pos_all(_substr, _str) {
	var _positions = [];
	var _start_pos = 0;
	repeat(string_count(_substr, _str)) {
		var _pos = string_pos_ext(_substr, _str, _start_pos);
		if(_pos != 0) {
			_positions[array_length(_positions)] = _pos;	
			_start_pos = _pos;
		}
	}
	return _positions;
}

function string_seperate(_substr, _str) {
	var _seperated_string = [];
	var _substr_positions = string_pos_all(_substr, _str);
	if(array_length(_substr_positions) == 0) _seperated_string = [_str];
	else {
		var _substr_pos_length = array_length(_substr_positions);
		_seperated_string[0] = string_copy(_str, 1, _substr_positions[0]-1);
		for(var i = 0; i < _substr_pos_length-1; i++) {
			_seperated_string[array_length(_seperated_string)] = string_copy(_str, _substr_positions[i], _substr_positions[i+1] - _substr_positions[i]);
		}
		var _str_length = string_length(_str);
		_seperated_string[array_length(_seperated_string)] = string_copy(_str, _substr_positions[_substr_pos_length-1], _str_length);
	}
	return _seperated_string;
}

function string_stitch(_str_array) {
	var _str = "";
	for(var i = 0; i < array_length(_str_array); i++) {
		_str += _str_array[i];
	}
	return _str;
}

function string_from_real(_real) {
	var _return_string = string(int64(_real));
	
	var _found_decimal = false;
	var _decimal_string = string_format(frac(_real), 0, 5);
	_decimal_string = string_delete(_decimal_string, 1, 1);
	_return_string += _decimal_string;
	
	var _mark = [];
	for(var i = string_length(_return_string); i >= 1; i--) {
		var _done = false;
		var _char = string_char_at(_return_string, i);
		switch(_char) {
			case "0": array_push(_mark, i); break;
			default: _done = true; break;
		}
		if(_done == true) break;
	}
	for(var i = 0; i < array_length(_mark); i++) {
		_return_string = string_delete(_return_string, _mark[i], 1);
	}
	return _return_string;
}
