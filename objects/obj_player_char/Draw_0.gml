/// @description Insert description here
// You can write your code in this editor
if(my_turn){
	draw_set_font(option_font);
	//if not looking at battlelog
	if(!player_displayed_bl){
		var opt_num;
		if(!selecting_target){
			opt_num			= array_length(battle_options[page])-1;
		} else { opt_num	= array_length(obj_game.available_enemies); } 
	
		var i				= 0;
		var text_placement	= 1;
		var opt_text		= "";
		var xx, yy;
	
		repeat(opt_num){
			//show relevant text
			if(!selecting_target){
				opt_text = string(battle_options[page][i][0]);
			} else {
				opt_text = obj_game.available_enemies[i].char_name;	
			}	
			//location
			xx = text_x+text_buffer;
			yy = text_y+(text_placement*text_buffer);

		
			//draw the arrow
			if(!selecting_target){
				if(text_placement-1 == current_option){
					draw_sprite(spr_textarrow, 0, xx-5, yy);	
				}
			} else {
				if(text_placement-1 == current_target){
					draw_sprite(spr_textarrow, 0, xx-5, yy);
				
					//draw the arrow above the sprite also
					with(obj_game.available_enemies[current_target]){
						draw_sprite_ext(spr_textarrow, 0, x, bbox_top-5, 1, 1, 270, c_white, 1);
					}
				}
			}	
			
			//draw the text
			draw_text(xx, yy, opt_text);
			text_placement++;
	
			i++;
		}	
	} else {
		with(obj_game){
			//Draw the battelog
			var current_lines = array_length(global.combatlog);
			
			//placement
			var text_placement = 1;
			var xx = text_x+text_buffer;
			
			var line_to_draw;
			var i					= 0;
			var stored_lines		= [];
			var stored_line_count	= 0;
			repeat(current_lines){
				//get the line(s) to draw
				line_to_draw = global.combatlog[i];
				
				//find how many lines
				var str_len = string_length(line_to_draw);
				var n_count = 0;
				var crt_ltr = 1;
				var n_points = [1];
				repeat(str_len){
					if(string_char_at(line_to_draw, crt_ltr) == "\n"){
						n_count++;	
						array_push(n_points, crt_ltr+1);
					}
					crt_ltr++;
				}	
				array_push(n_points, str_len);
				
				//add the set of lines to an array
				var line_segment;
				var ii = 0;
				repeat(n_count+1){
					//work out the string
					if(n_count != 0){
						var index		= n_points[ii];
						var count		= n_points[ii+1]-n_points[ii];
						line_segment	= string_copy(line_to_draw, index, count);
					} else {
						line_segment = line_to_draw;	
					}	
					
					array_push(stored_lines, line_segment);
					stored_line_count++;
					ii++
				}					
				i++;
			}	
			
			//draw the lines of text to the screen
			
			//work out the number of lines to draw - cap it to max
			var final_lines = [];
			array_copy(final_lines, 0, stored_lines, 0, stored_line_count);
			
			var number_to_remove = 0;
			if(stored_line_count > max_lines){
				number_to_remove = stored_line_count - max_lines;
				var player_pos_to_remove = 0;
				repeat(number_to_remove){ 
					//if the player has scrolled, remove from the bottom first
					if(player_pos_to_remove < other.combatlog_pos){
						array_delete(final_lines, stored_line_count, 1);
						player_pos_to_remove++
					} else {
					//else removed from top
						array_delete(final_lines, 0, 1); 
					}
					stored_line_count--;
				}	
			}	
			
			//draw the text
			var iii = 0;
			repeat(stored_line_count){
				yy = text_y+(text_placement*text_buffer); 
				draw_text_ext(xx, yy, final_lines[iii], text_buffer, 999999);
				text_placement++;
				iii++;
			}
			
			
			//Draw the arrow(s)
			//only bother if we have more than the maximum amount of lines
			var total_lines = array_length(stored_lines);
			if(total_lines > max_lines){
				var xx_shift = 25;
				//you can scroll lower
				if(other.combatlog_pos != 0){
					draw_sprite_ext(spr_down_arrow, 0, xx+global.play_area_width-xx_shift, yy, 0.5, 0.5, 0, c_white, 1);
				}	
				//you can scroll higher
				var num_of_earlier_lines = total_lines - max_lines;
				if(num_of_earlier_lines > other.combatlog_pos){
					draw_sprite_ext(spr_up_arrow, 0, xx+global.play_area_width-xx_shift, text_y+5, 0.5, 0.5, 0, c_white, 1);	
				}	
			}
			//move the cursor
			var dir_pressed = global.up_pressed - global.down_pressed;

			other.combatlog_pos += dir_pressed;
			
			//clamp the cursor
			other.combatlog_pos = clamp(other.combatlog_pos, 0, number_to_remove);
		}	
	}	
}