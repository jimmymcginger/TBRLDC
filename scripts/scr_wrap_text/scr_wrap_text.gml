// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function scr_wrap_text(_width, _text){
	var str_len = string_length(_text);
	var last_space = 1;
	
	var count = 1;
	var substr;
	
	repeat(str_len){
		substr = string_copy(_text, 1, count);
		if(string_char_at(_text, count) == " "){ last_space = count; }
		
		
		if(string_width(substr) > _width){
			_text = string_delete(_text, last_space, 1);	
			_text = string_insert("\n", _text, last_space);
		} 	
		count++;
	}	
		return _text;
}