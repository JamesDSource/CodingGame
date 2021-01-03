if(keyboard_check_pressed(vk_f4) && selected) {
	var _AST = new parser(text_box.tokens).get_AST();
	var _interpreter = new interpreter();
	var _result = _interpreter.run(_AST);
	if(is_error(_result)) show_debug_message(_result.get_error(text_box.text));
	else show_debug_message(_result);
}