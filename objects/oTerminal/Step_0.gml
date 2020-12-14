if(keyboard_check_pressed(vk_f2)) {
    var _cs = oRender.current_screen;
    oRender.current_screen = _cs == SCREEN.TERMINAL ? SCREEN.MAP : SCREEN.TERMINAL;
}