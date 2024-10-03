/// @description Insert description here
// You can write your code in this editor

//don't run in party room
if(room == obj_party_select){ exit; }

//Restart the game - TODO REMOVE
if(keyboard_check_pressed(ord("R"))){
	game_restart();	
}

//-----WHAT HAPPENS IN EACH ROOM
switch (room_stage) {
	//set the room up when you first enter•
	case room_stages.set_up:
	#region
		//work out what exits we have
		directions_available = [0,0,0,0];
		var player_x = global.current_room[0];
		var player_y = global.current_room[1];
		
		//Light the room up on the map
		current_floor_bg_grid[player_x][player_y][1] = 1;
		
		//if we're in a room
		if(global.floor_layout[player_x][player_y][0] == 1){
			//check each direction - first making sure it's inbounds
			if(player_y-1 >= 0 && player_y-1 <= global.floor_size-1){ //make sure it's in bounds
				rm_av_check(0, player_x, player_y-1);
			}
			if(player_y+1 >= 0 && player_y+1 <= global.floor_size-1){ //make sure it's in bounds
				rm_av_check(2, player_x, player_y+1);
			}
			if(player_x+1 >= 0 && player_x+1 <= global.floor_size-1){ //make sure it's in bounds
				rm_av_check(1, player_x+1, player_y);
			}
			if(player_x-1 >= 0 && player_x-1 <= global.floor_size-1){ //make sure it's in bounds		
				rm_av_check(3, player_x-1, player_y);
			}	
		//If we're in a corridor	
		} else if(global.floor_layout[player_x][player_y][0] == 2){
			var this_room = global.floor_layout[player_x][player_y];
			if(this_room[1] == 1){ //if the corridor connects north
				directions_available[0]	= 1;
				//if the room hasn't been visited, add it to the map as a potential room to go to
				if(current_floor_bg_grid[player_x][player_y-1][1] < 1){
					current_floor_bg_grid[player_x][player_x-1][1] = 0.5;
				}
			}	
			if(this_room[2] == 1){ //if the corridor connects east
				directions_available[1]	= 1;
				//if the room hasn't been visited, add it to the map as a potential room to go to
				if(current_floor_bg_grid[player_x+1][player_y][1] < 1){
					current_floor_bg_grid[player_x+1][player_y][1] = 0.5;
				}
			}
			if(this_room[3] == 1){ //if the corridor connects south
				directions_available[2]	= 1;
				//if the room hasn't been visited, add it to the map as a potential room to go to
				if(current_floor_bg_grid[player_x][player_y+1][1] < 1){
					current_floor_bg_grid[player_x][player_y+1][1] = 0.5;
				}
			}	
			if(this_room[4] == 1){ //if the corridor connects west
				directions_available[3]	= 1;
				//if the room hasn't been visited, add it to the map as a potential room to go to
				if(current_floor_bg_grid[player_x-1][player_y][1] < 1){
					current_floor_bg_grid[player_x-1][player_y][1] = 0.5;
				}
			}	
		}	
		
		//change room stage
		room_reset();
		if(global.floor_layout[player_x][player_y][1] == filled_room_types.combat){
			spawn_enemies(global.floor_layout[player_x][player_y][2]);
			redo_timeline = true;
			room_stage		= room_stages.battle;
		} else {	
			room_stage		= room_stages.movable;
		}
		
		
	#endregion
	break;
	
	case room_stages.movable:
	#region
		//Enter takes prescedant over directions, so we check that first
		if(global.enter_pressed){
			switch(options[page][current_option]){
				case p_o.go_north:
					next_room = [1, -1];
					set_up_fade(false, room_stages.set_up);
				break;
				
				case p_o.go_east:
					next_room = [0, 1];
					set_up_fade(false, room_stages.set_up);
				break;
				
				case p_o.go_south:
					next_room = [1, 1];
					set_up_fade(false, room_stages.set_up);
				break;
				
				case p_o.go_west:
					next_room = [0, -1];;
					set_up_fade(false, room_stages.set_up);
				break;
				
				case p_o.show_directions:
					page = pages.directions;
				break;
				
				case p_o.finish_floor:
					//set up fade and change floors in next stage
					set_up_fade(true, room_stages.change_floors);
				break;				
			}	
		} else if(global.back_pressed){
			//go back a page of the menu, if possible
			current_option = 0;
			var page_to_switch_to = back_pages[page];
			if(page_to_switch_to != -1){
				page = back_pages[page];
			}
		} else {
			//allow the player to change their option
			var dir_pressed = global.down_pressed - global.up_pressed;
			if(page != pages.directions){ //if not directions, do the usual
				current_option += dir_pressed;
		
				//loop it
				var options_len = array_length(options[page]);
				if(current_option > options_len-1){ current_option = 0;}
				else if (current_option < 0){ current_option = options_len-1; }
			} else {
				var option_selected = -1;
				if(global.down_pressed){ option_selected = p_o.go_south;}
				else if(global.up_pressed){ option_selected = p_o.go_north; }
				else if(global.right_pressed){ option_selected = p_o.go_east; }
				else if(global.left_pressed){ option_selected = p_o.go_west; }
				else if(global.down_pressed){ option_selected = p_o.go_south; }

				var len = array_length(options[page]);
				var i = 0;
				repeat(len){
					if(options[page][i] == option_selected){
						current_option = i;	
					}	
					i++;
				}	
			}	
		}	
	#endregion	
	break;
	
	case room_stages.fade:
	#region
		if(fade_dir == 0){ //if fading out
			fade_alpha += fade_speed;
			if(fade_alpha >= 1){
				fade_dir = 1; 
				//change once faded
				if(fade_to == room_stages.set_up){
					global.current_room[next_room[0]] += next_room[1];
				} else if(fade_to == room_stages.change_floors){	
					if(global.current_level/level_per_floor == 1){
						global.current_level = 0;
						global.current_floor++;
					} else {
						global.current_level++;
					}	
					floor_reset();
					floor_create();
				}
			}	
		} else {
			fade_alpha -= fade_speed; //if fading in
			if(fade_alpha <= 0){
				//reset
				fade_alpha = 0;
				fade_dir = 0;
				//change room stage
				room_stage = room_stages.set_up;
			}	
		}	
	#endregion
	break;
	
	case room_stages.battle:
		//Next turn - work out timeline & make it next persons go
		if(redo_timeline && !global.combatlog_visible){ //nothing happens until combatlog has finished
			//work out which players and enemies are still fighting
			//add the player data
			var i = 0;
			targetable_party = [];
			repeat(party_size){
				if(player_party[i].current_hp > 0){ //do not add Ko'd party members
					array_push(targetable_party, player_party[i]);
				}
				i++;
			}
			//add the enemies
			var mon_num			= array_length(current_enemies);
			var ii				= 0;
			available_enemies	= [];
			repeat(mon_num){
				if(current_enemies[ii].current_hp > 0){ //do not add Ko'd monsters
					array_push(available_enemies, current_enemies[ii]);
				}
				ii++;
			}	
			
			//If everyone is KO'd - game over
			var party_left	= array_length(targetable_party);
			var en_left		= array_length(available_enemies);
			if(party_left <= 0){
				//GAME OVER TODO
				//delete the player objects as they are persistent
			} else if(en_left <= 0){
				//--End the battle - you won!
				//TODO victory message, any loot - allow any last fadeout
				
				//remove the enemies
				with(obj_enemy){ instance_destroy(); }
				current_enemies = [];
				
				//wipe the timeline
				global.turn_timeline			= [];
				global.turn_timeline_shown		= [];
				
				//wipe the battle log
				global.combatlog				= [];
				

				//make the player able to move
				room_stage = room_stages.movable;
				
				//change the room to not be combat
				global.floor_layout[global.current_room[0]][global.current_room[1]][1] = -1;
			} else {	
				//work out timeline and set turn
				work_out_turn_timeline(true); 
				global.turn_timeline[0].alarm[0] = global.turn_timeline[0].take_turn_timer; //TODO change once they have actual turns
				redo_timeline = false;
			}
		}
		
		//allow the player to skip the combat log
		//TODO once it is typewriter the player should skip the typewriter THEN the log itself
		if(global.combatlog_visible){
			if(global.enter_pressed && combatlog_skippable){
				//If word is typing, skip to end, otherwise skip
				//if there is a word to add
				var to_add_len = array_length(global.combatlog_to_add);
				if(to_add_len > 0){
					//if it's still typing
					var str_len = string_length(global.combatlog_to_add[0]);
					if(current_letter < str_len){
						current_letter	= str_len;
						next_letter		= false;
						alarm[1]		= false;
					}
				} else {
					global.combatlog_visible	= false;	
					combatlog_skippable			= false;
				}
			}	
		}	
		
		//allow the player to scroll the turnorder
		var scroll_dir = global.l2_pressed - global.l1_pressed;
		timeline_player_pos = clamp(timeline_player_pos + scroll_dir, 0, timeline_total_length-timeline_length);
	
	break;
}