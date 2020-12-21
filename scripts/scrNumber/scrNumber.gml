function between(_n1,  _n2, _n1_inclusive, _n2_inclusive, _x) {
    var _min = min(_n1, _n2);
    var _max = max(_n1, _n2);
    
    var _cond1 = _n1_inclusive ? _x >= _min: _x > _min;
    var _cond2 = _n2_inclusive ? _x <= _max : _x < _max;
    return _cond1 && _cond2;
}
