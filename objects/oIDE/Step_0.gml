if(keyboard_check_pressed(vk_f4) && selected) {
	var _tokens = get_tokens(text_box.text);
	for(var i = 0; i < array_length(_tokens); i++) {
		show_debug_message(_tokens[i].token_string());
	}
	show_debug_message("-------------------");
	var _AST = new parser(_tokens).get_AST();
	var _interpreter = new interpreter();
	_interpreter.run(_AST);
	show_debug_message("!-----------------!");
}