enum SLICEMODE {
    TILE,
    STREATCH
}

function three_slice(_sprite, _subimage, _slice_mode) constructor {
    sprite = _sprite;
    subimage = _subimage;
    slice_mode = _slice_mode;
    slice_side = sprite_get_width(sprite)/3;
    
    round_down = true;
    
    function draw(_x, _y, _width) {
        var _draw_x = _x;
        
        // Drawing left side
        draw_sprite_part(sprite, subimage, 0, 0, slice_side, sprite_get_height(sprite), _draw_x, _y);
        _draw_x += slice_side;
        
        // Drawing middle
        var _mid_length = max(0, _width - slice_side*2);
        switch(slice_mode) {
            case SLICEMODE.TILE:
                var _repeat = _mid_length/slice_side;
                if(round_down) _repeat = floor(_repeat);
                else _repeat = ceil(_repeat);
                
                repeat(_repeat) {
                    draw_sprite_part(sprite, subimage, slice_side, 0, slice_side, sprite_get_height(sprite), _draw_x, _y);
                    _draw_x += slice_side;
                }
                break;
            case SLICEMODE.STREATCH:
                draw_sprite_part_ext(sprite, subimage, slice_side, 0, slice_side, sprite_get_height(sprite), _draw_x, _y, _mid_length/slice_side, 1, c_white, draw_get_alpha());
                _draw_x += _mid_length;
                break;
        }
        
        // Drawing right side
        draw_sprite_part(sprite, subimage, slice_side*2, 0, slice_side, sprite_get_height(sprite), _draw_x, _y);
    }
}

function nine_slice(_sprite, _slice_mode) constructor {
    sprite = _sprite;
    slice_mode = _slice_mode;
    
    pieces = {
        TL: 0,      // Top Left  
        TR: 0,      // Top Right
        BL: 0,      // Bottom Left
        BR: 0,      // Bottom Right
        L: 0,       // Left
        R: 0,       // Right
        T: 0,       // Top
        B: 0,       // Bottom
        M: 0        // Middle
    }
    
}