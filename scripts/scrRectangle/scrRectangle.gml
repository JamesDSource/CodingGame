function rectangle(_x, _y, _width, _height) constructor {
    x = _x;
    y = _y;
    width = _width;
    height = _height;
    
    function colliding_with_rectangle(_rect) {
        return rectangle_in_rectangle(x, y, x + width, y + height, _rect.x, _rect.y, _rect.x + _rect.width, _rect.y + _rect.height);
    }
    
    function colliding_with_point(_x, _y) {
        return point_in_rectangle(_x, _y, x, y, x + width, y + height);
    }
    
    function colliding_with_instance(_inst) {
        return rectangle_in_rectangle(x, y, x + width, y + height, _inst.bbox_left, _inst.bbox_top, _inst.bbox_right, _inst.bbox_bottom);
    }
    
    function draw(_col, _outline) {
        draw_rectangle_color(x, y, x + width, y + height, _col, _col, _col, _col, _outline);
    }
}