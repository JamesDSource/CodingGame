seperated_text = string_seperate("\n", text_editing);
t++;
if(keyboard_check_pressed(vk_f4)) {
	var _tokens = get_tokens(text_editing);
	for(var i = 0; i < array_length(_tokens); i++) {
		show_debug_message(_tokens[i].token_string());
	}
	show_debug_message("-------------------");
	var _AST = new parser(_tokens).get_AST();
	var _interpreter = new interpreter()
	_interpreter.run(_AST);
	show_debug_message("!-----------------!");
	text_editing_last = text_editing;	
}