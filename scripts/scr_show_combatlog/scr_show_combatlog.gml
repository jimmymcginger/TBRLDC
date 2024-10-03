// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function show_combatlog(_text){
	//wrap the text
	var str = scr_wrap_text(global.play_area_width-10, _text);

	global.combatlog_visible = true;
	array_push(global.combatlog_to_add, str);
	
	with(obj_game){ 
		alarm[0] = log_timer;
	}	
}	