// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function work_out_turn_timeline(_proper_timeline, _current_move_speed = global.normal_speed){
	with(obj_game){
		//----Get the players and enemy data
		var all_fighters		= [];
		var current_timeline	= [];
		//add the player data
		var party_left = array_length(targetable_party);
		var i = 0;
		repeat(party_left){
			array_push(all_fighters, targetable_party[i]);
			i++;
		}
		//add the enemies
		var mon_num = array_length(available_enemies);
		var ii		= 0;
		repeat(mon_num){
			array_push(all_fighters, available_enemies[ii]);
			ii++;
		}	
	
		//make everyone's work out init match starting init
		var chars_to_add = array_length(all_fighters);
		var iii			 = 0;
		repeat(chars_to_add){
			with(all_fighters[iii]){
				work_out_init = initiative;
			}
			iii++;
		}	
	
		//Sort them into highest init order
		var tl			= array_length(current_timeline)
		var first_loop	= true;
		while(tl < timeline_total_length){
			//sort the characters by init - if any are above 100, the top one goes into the list
			array_sort(all_fighters, function(f1, f2){
				return f1.work_out_init == f2.work_out_init ? f1.turn_priority - f2.turn_priority : f2.work_out_init - f1.work_out_init;
			})
		
			//if first char is above 100 init, add to the list
			if(all_fighters[0].work_out_init >= max_init){
				array_push(current_timeline, all_fighters[0]);
			
				//if this is the proper timeline & it's the top of the list, we need to update everyones actual init
				var c_tl_l = array_length(current_timeline);
				if(_proper_timeline && (c_tl_l == 1)){
					var v = 0;
					repeat(chars_to_add){
						with(all_fighters[v]){
							initiative = work_out_init;
						}	
						v++;
					}		
				}
			
				//turn the fighters work out init to new value
				if(first_loop){ //first fighter can have variable speed
					all_fighters[0].work_out_init -= _current_move_speed;
					first_loop = false;
				} else {
					all_fighters[0].work_out_init -= global.normal_speed;
				}	
				
			} else {
				//each turn add the speed stat (even when we're above 100)
				var iv = 0;
				repeat(chars_to_add){
					with(all_fighters[iv]){
						work_out_init += stat_speed;
					}		
					iv++;
				}	
			}
			
			//update timeline length
			tl = array_length(current_timeline)
		}	
	
		//change the appropriate timeline
		if(_proper_timeline){
			global.turn_timeline		= current_timeline;
			global.turn_timeline_shown	= current_timeline;
		} else {
			global.turn_timeline_shown	= current_timeline;
		}	
	}
}	