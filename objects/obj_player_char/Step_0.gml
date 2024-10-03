/// @description Insert description here
// You can write your code in this editor

if(my_turn){
	
	//If the player presses tab, they see the battlelog
	player_displayed_bl = global.tab_pressed;
	//if we're not looking at the battelog
	if(!player_displayed_bl){
		//Enter takes prescedant over directions, so we check that first
		if(global.enter_pressed){
			if(!selecting_target){
				switch(battle_options[page][current_option][1]){
					case option_type.change_page:
						page			= battle_options[page][current_option][2];
						current_option	= 0; //TODO - memory stuff?
				
						work_out_tl		= true;
					break;
				
					case option_type.do_move:
						selecting_target		= true;
						selected_move			= battle_options[page][current_option][2];
					break;			
				}	
			} else {
				//DO MOVE
				perform_move(obj_game.available_enemies[current_target], selected_move[0], selected_move[1]); //TODO add like attack damage and shit
				reset_turn();
			}	
		} else if(global.back_pressed){
			if(!selecting_target){
				//go back a page of the menu, if possible
				var end_of_array = array_length(battle_options[page])-1;
				if(battle_options[page][end_of_array] != -1){
					page = battle_options[page][end_of_array];
					current_option	= 0; //TODO - memory stuff?
			
					work_out_tl		= true;
				}
			} else { 
				selecting_target	= false; 
				selected_move		= false;
			}
		} else {
			if(!selecting_target){
				//allow the player to change their option
				var dir_pressed = global.down_pressed - global.up_pressed;

				current_option += dir_pressed;
		
				//loop it
				var options_len = array_length(battle_options[page])-1;
				if(current_option > options_len-1){ current_option = 0;}
				else if (current_option < 0){ current_option = options_len-1; }
				//work out timeline is we move 
				if(dir_pressed != 0){
					work_out_tl		= true;
				}
			} else {
				//allow the player to change their option
				var dir_pressed = global.down_pressed - global.up_pressed;

				current_target += dir_pressed;
		
				//loop it
				var options_len = array_length(obj_game.available_enemies);
				if(current_target > options_len-1){ current_target = 0;}
				else if (current_target < 0){ current_target = options_len-1; }
				//work out timeline is we move 
				//if(dir_pressed != 0){
					//work_out_tl		= true; //TODO work this out, but based on slowly the enemy if the attack does that
				//}
			
			}	
		}
	
		//change the timeline to show what our chosen option will do if picked
		if(work_out_tl){
			//are we changing page or doing a move?
			var move_or_page_change = battle_options[page][current_option][1];
		
			if(move_or_page_change == option_type.change_page){
				global.turn_timeline_shown = global.turn_timeline;
			} else {
				var move_speed = battle_options[page][current_option][2][0];
				//work out the timeline
				work_out_turn_timeline(false, move_speed);
			}
			work_out_tl = false;

		}	
	//if we are looking at the battlelog
	} else {
	
	
	
	}	
}	