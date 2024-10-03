/// @description Insert description here
// You can write your code in this editor

//don't run in party room
if(room == obj_party_select){ exit; }

//-------------UI
#region//---Play area
draw_rectangle(1, 1, global.play_area_width, play_area_height, true);

var cur_spr = current_floor_bg_grid[global.current_room[0]][global.current_room[1]][0];
draw_sprite(cur_spr, 0, 2, 2);

#endregion

#region//---OPTIONS
if(room_stage == room_stages.movable){
	draw_set_font(option_font);
	var opt_num			= array_length(options[page]);
	var i				= 0;
	var text_placement	= 1;
	var opt_text		= "";
	var dir_text		= false;
	var xx, yy;
	repeat(opt_num){
		//show relevant text
		switch options[page][i]{
			case p_o.go_north:
				opt_text = "Tread North";
				dir_text = true;
				
				xx = global.play_area_width/2;
				yy = text_y+text_buffer;
			break;
				
			case p_o.go_east:
				opt_text = "Tread East";
				dir_text = true;
				
				xx = global.play_area_width - text_buffer;
				yy = text_y+(text_buffer*4);
			break;
				
			case p_o.go_south:
				opt_text = "Tread South";
				dir_text = true;
				
				xx = global.play_area_width/2
				yy = room_height-(text_buffer*2);
			break;
				
			case p_o.go_west:
				opt_text = "Tread West"
				dir_text = true;
				
				xx = text_x+text_buffer;
				yy = text_y+(text_buffer*4);
			break;
				
			case p_o.show_directions:
				opt_text = "Travel"
			break;
				
			case p_o.finish_floor:
			if(global.current_level/level_per_floor == 1){
				opt_text = "Descend to the next floor";
			} else { opt_text = "Travel deeper into the ruins"; } //TODO are they always ruins?
			break;
		}
		//location - different for directions
		if(!dir_text){
			xx = text_x+text_buffer;
			yy = text_y+(text_placement*text_buffer);
		} 
		
		//draw the arrow
		if(text_placement-1 == current_option){
			draw_sprite(spr_textarrow, 0, xx-5, yy);	
		}	
			
		//draw the text
		draw_text(xx, yy, opt_text);
		text_placement++;
	
		i++;
	}
}	

#endregion

#region//---MAP
//----Draw the Floor Plan
var room_w		= map_size/global.floor_size; //gets the pixel width of a room within the floor plan
var m2c			= (room_width/4)*3; //move to corner

//move map so player is in the middle at all times
player_adjx = global.current_room[0]-(ceil(global.floor_size/2)-1);
player_adjy = global.current_room[1]-(ceil(global.floor_size/2)-1);


//Draw vertical lines
var i = 0;
//repeat(global.floor_size){
	draw_line(room_w*i+m2c, 0, room_w*i+m2c, 0+(room_w*global.floor_size));
//	i++
//}	
var i = global.floor_size; //this adds the final line, delete if we uncomment the above
draw_line(room_w*i+m2c-1, 0, room_w*i+m2c-1, 0+(room_w*global.floor_size));

//Draw horizontal lines
var i = 0;
//repeat(global.floor_size+1){
	draw_line(0+m2c, room_w*i, room_width, room_w*i);
//	i++
//}	
var i = global.floor_size; //this adds the final line, delete if we uncomment the above
draw_line(0+m2c, room_w*i, room_width, room_w*i);

//Draw the type of room (room/blank space/corridor)
var xx = 0;
var yy = 0;
repeat(global.floor_size*global.floor_size){
	
	//only draw the room if it's within the map bounds
	if(
		xx-player_adjx >=0 && xx-player_adjx <= (global.floor_size-1) &&
		yy-player_adjy >=0 && yy-player_adjy <= (global.floor_size-1)
	){
		//set the alpha to only show visible rooms
		//check it's a room first
		draw_set_alpha(current_floor_bg_grid[xx][yy][1]);

		//room
		if(global.floor_layout[xx][yy][0] = room_types.rm){
			//if it's the start room, make it blue
		
			//TODO DELETE THIS - the rooms don't start with types currently, when they do, this won't be needed later
			if(array_length(global.floor_layout[xx][yy]) < 2){
				global.floor_layout[xx][yy][1] = -1;
			}	
		
			//make it coloured for the room
			if(global.floor_layout[xx][yy][1] == filled_room_types.start_room){
				draw_set_color(c_blue);
			} else if(global.floor_layout[xx][yy][1] == filled_room_types.boss_room){
				draw_set_color(c_aqua);
			} else if(global.floor_layout[xx][yy][1] == filled_room_types.combat){
				draw_set_color(c_maroon);
			}		
		
			//draw the room
			draw_rectangle(
				((xx-player_adjx)*room_w)+m2c, (yy-player_adjy)*room_w, 
				(xx+1-player_adjx)*room_w+m2c, (yy+1-player_adjy)*room_w,
				false
			);
		
			draw_set_color(c_white);
		//corridor	
		} else if(global.floor_layout[xx][yy][0] = room_types.corridor){
			draw_set_color(c_red);
			//Initialise vars for corridor drawing
			var start_x, start_y, finish_x, finish_y;
			//West
			if(global.floor_layout[xx][yy][4] == 1){
				start_x		= (xx-player_adjx)*room_w+m2c;
				start_y		= (yy-player_adjy)*room_w+(room_w/4);
				finish_x	= (xx-player_adjx)*room_w+(room_w/2)+m2c;
				finish_y	= (yy-player_adjy)*room_w+((room_w/4)*3);
				draw_rectangle( start_x, start_y, finish_x, finish_y, false);
			//East	
			} 
			if(global.floor_layout[xx][yy][2] == 1){
				start_x		= (xx+1-player_adjx)*room_w+m2c;
				start_y		= (yy-player_adjy)*room_w+(room_w/4);
				finish_x	= (xx+1-player_adjx)*room_w-(room_w/2)+m2c;
				finish_y	= (yy-player_adjy)*room_w+((room_w/4)*3);
				draw_rectangle( start_x, start_y, finish_x, finish_y, false);			
			//North	
			} 
			if(global.floor_layout[xx][yy][1] == 1){
				start_x		= (xx-player_adjx)*room_w+(room_w/4)+m2c;
				start_y		= (yy-player_adjy)*room_w;
				finish_x	= (xx-player_adjx)*room_w+((room_w/4)*3)+m2c;
				finish_y	= (yy-player_adjy)*room_w+(room_w/2);
				draw_rectangle( start_x, start_y, finish_x, finish_y, false);
			//south	
			} 
			if(global.floor_layout[xx][yy][3] == 1){
				start_x		= (xx-player_adjx)*room_w+(room_w/4)+m2c;
				start_y		= (yy+1-player_adjy)*room_w;
				finish_x	= (xx-player_adjx)*room_w+((room_w/4)*3)+m2c;
				finish_y	= (yy+1-player_adjy)*room_w-(room_w/2);
				draw_rectangle( start_x, start_y, finish_x, finish_y, false);
			
			}	

			draw_set_color(c_white);
		}
	
	}
	draw_set_alpha(1);
	
	xx++
	//reset and add to vertical once we go too far
	if(xx>(global.floor_size-1)){
		xx = 0;
		yy++;
	}	
}	

//draw the players position
draw_set_color(c_green);
xx = global.current_room[0];
yy = global.current_room[1];
draw_circle(			
	((xx-player_adjx)*room_w+m2c)+(room_w/2), (yy-player_adjy)*room_w+(room_w/2), 
	room_w/10, false
)
draw_set_color(c_white);
#endregion

#region//--CHARACTERS
//draw the character boxes

var cb_i = 0;
var box_sx, box_sy, box_ex, box_ey;
repeat(4){
	//work out X
	if(cb_i mod 2 == 0){ 
		box_sx = room_width-1-(char_box_width*2);
		box_ex = room_width-1-(char_box_width);
	} else {
		box_sx = room_width-1-char_box_width;
		box_ex = room_width-1;
	}	
	//work out Y
	if(cb_i < 2){ 
		box_sy = char_box_start_height;
		box_ey = char_box_start_height+char_box_height;
	} else {
		box_sy = char_box_start_height+char_box_height;
		box_ey = char_box_start_height+(char_box_height*2);
	}	
	//draw the boxes
	draw_rectangle(box_sx, box_sy, box_ex, box_ey, true);
	
	//write the name
	draw_set_halign(fa_center);
	var char_nam		= player_party[cb_i].char_name;
	var string_x			= box_sx+(char_box_width/2)
	draw_text(string_x, box_sy+name_buffer, char_nam);
	
	var string_h = string_height("M");
	
	//draw hp
	var	cur_hp	= player_party[cb_i].current_hp;
	var	max_hp	= player_party[cb_i].stat_hp;
	var hp_str  = "HP: " + string(cur_hp) + "/" + string(max_hp);
	draw_text(string_x, box_sy+(name_buffer*2)+string_h, hp_str);
	//draw mp
	var	cur_mp	= player_party[cb_i].current_hp;
	var	max_mp	= player_party[cb_i].stat_hp;
	var mp_str  = "MP: " + string(cur_mp) + "/" + string(max_mp);
	draw_text(string_x, box_sy+(name_buffer*3)+(string_h*2), mp_str);
	
	cb_i++;
}
draw_set_halign(fa_left);	

#endregion

#region//--BATTLE UI

if(room_stage == room_stages.battle){
	var tts_ex = array_length(global.turn_timeline_shown);
	if(tts_ex > 0){
		var t_i = 0
		repeat(timeline_length){ //check that the timeline is populated
			//draw the turn order box
			draw_rectangle(
				turn_box_start_x, turn_box_start_y+((turn_box_height+name_buffer)*t_i), 
				turn_box_end_x, turn_box_start_y+((turn_box_height+name_buffer)*t_i)+turn_box_height, true
			);
		
			//fill it with a name
			draw_text(
				turn_box_start_x+name_buffer, 
				turn_box_start_y+((turn_box_height+name_buffer)*t_i)+name_buffer,
				string(global.turn_timeline_shown[t_i+timeline_player_pos].char_name)
			);
		
			t_i++;	
		}	
		
		//draw the arrows
		var xx_shift = 25;
		var yy_shift = 25;
		//you can scroll lower
		if(timeline_player_pos != 0){
			draw_sprite_ext(spr_up_arrow, 0, turn_box_end_x-xx_shift, (yy_shift/2), 0.5, 0.5, 0, c_white, 1);	
		}	
		//you can scroll higher
		if(timeline_player_pos < (timeline_total_length-timeline_length)){
			var yy = turn_box_start_y+((turn_box_height+name_buffer)*timeline_length)-yy_shift;
			draw_sprite_ext(spr_down_arrow, 0, turn_box_end_x-xx_shift, yy, 0.5, 0.5, 0, c_white, 1);
			
		}	
	}
	
	//-------Combat log
	if(global.combatlog_visible){
		//location of text
		text_placement = 1;
		xx = text_x+text_buffer;
		
		//Work out the number of lines
		var log_len				= array_length(global.combatlog);
		var num_lines_to_add	= array_length(global.combatlog_to_add);
		
		//Work out the text for the added line and
		//work out how many lines are to be used for the currently being added line
		var lines_to_be_added = [];
		if(num_lines_to_add > 0){
			//is it time for the next letter?
			if(next_letter){
				current_letter++;
				next_letter = false;
				alarm[1] = type_speed;
			}
			
			var str		= string_copy(global.combatlog_to_add[0], 1, current_letter); 
			var str_len = string_length(str);
			var new_str = "";

			var cur_let = 0;
			
			var str_i	= 1;
			repeat(str_len){
				cur_let = string_char_at(str, str_i);
				if(cur_let != "\n"){
					new_str = string(new_str+cur_let);	
						
				} else {
					array_push(lines_to_be_added, new_str);
					new_str = "";
				}	
					
				str_i++;	
			}	
			//add the final line
			array_push(lines_to_be_added, new_str);
		}	
		
		//work out the rest of the lines
		//Do we have more lines than space?
		var num_placed_lines	= min(log_len, max_lines);
		var placed_lines		= [];
		var npl_i				= max(0, log_len-max_lines);
		repeat(num_placed_lines){
			var str		= global.combatlog[npl_i]; 
			var str_len = string_length(str);
			var new_str = "";

			var cur_let = 0;
			
			var str_i	= 1;
			repeat(str_len){
				cur_let = string_char_at(str, str_i);
				if(cur_let != "\n"){
					new_str = string(new_str+cur_let);	
						
				} else {
					array_push(placed_lines, new_str);
					new_str = "";
				}	
					
				str_i++;	
			}	
			//add the final line
			array_push(placed_lines, new_str);
			
			npl_i++;
		}	
			
		//work out the number of lines to swap over to be shown to the screen
		var num_of_new_lines		= array_length(lines_to_be_added);
		var num_of_old_lines		= array_length(placed_lines);
		var placed_lines_to_keep	= min(num_of_old_lines, max_lines-num_of_new_lines);
		var old_lines_to_yeet		= max(0, num_of_old_lines-placed_lines_to_keep);
		var pl2k_i					= 0;
		repeat(placed_lines_to_keep){
			shown_combatlog[pl2k_i] = placed_lines[old_lines_to_yeet+pl2k_i];
			pl2k_i++;
		}	
		//add the new lines
		var l2ba = 0;
		repeat(num_of_new_lines){
			shown_combatlog[pl2k_i] = lines_to_be_added[l2ba];
			pl2k_i++;
			l2ba++
		}	
		
		//Draw the text
		var lines_to_draw = placed_lines_to_keep+num_of_new_lines;
		var li		= 0;
		repeat(lines_to_draw){
			yy = text_y+(text_placement*text_buffer); 
			draw_text_ext(xx, yy, shown_combatlog[li], text_buffer, 999999);
			text_placement++;
			
			li++;
		}
	
			
		//reset new word when full word is typed
		if(num_lines_to_add > 0){
			var str_len = string_length(global.combatlog_to_add[0]);
			if(current_letter >= str_len){
				//add to this historic log
				var new_line_str	= global.combatlog_to_add[0];
				var new_line_len	= string_length(new_line_str);
				var string_to_add   = "";
				var nli				= 0;
				var cl				= "";
				var str_ii			= 1;
				repeat(new_line_len){
					
					cl = string_char_at(new_line_str, str_ii);
					
					if(cl != "\n"){
						string_to_add = string(string_to_add+cl);	
					} else {
						string_to_add  = "";
					}	
					str_ii++;
					nli++	
				}	
				
				//add the new line to the combat log
				array_push(global.combatlog, global.combatlog_to_add[0]);
				array_delete(global.combatlog_to_add, 0, 1);
				next_letter		= true;
				alarm[1]		= -1;
				current_letter	= 0;
			}
		}
	}
}	

#endregion

#region//--FADE
//fade out square
draw_set_colour(c_black);
draw_set_alpha(fade_alpha);
draw_rectangle(current_fade[0], current_fade[1], current_fade[2], current_fade[3], false);
draw_set_colour(c_white);
draw_set_alpha(1);

#endregion