/// @description Insert description here
// You can write your code in this editor

#region //------Gameplay
#region//-----Set the seed
//Seed Variables
global.seed			= [];
global.seed_len		= 10;
//Make a seed
function set_seed(){
	var i = 0;
	repeat(global.seed_len){
		global.seed[i] = irandom(9);
		i++;
	}	
}	
global.current_seed_num = 0;
#endregion
#region//---Rooms & Floor
global.current_floor	= 0;
global.current_level	= 0;
level_per_floor			= 3;

//----ROOMS
global.current_room		= [];

//Room stages (The steps you go through when you travel to a new room
enum room_stages {
	set_up,	
	movable,
	fade,
	change_floors,
	battle,
}		
room_stage				= room_stages.set_up;
directions_available	= [0, 0, 0, 0] //n,e,s,w
next_room				= [0, 0]; //x/y, up or down

//Fade out/in
fade_alpha = 0;
fade_speed = 0.05;
fade_dir   = 0;

fade_x1  = 2
fade_x2  = 720
fade_y1  = 2
fade_y2  = 480;

current_fade = [0, 0, 0, 0];
fade_to = -1;


function set_up_fade(_big_or_no, _where_next){
	var start_x, end_x, start_y, end_y;
	
	if(_big_or_no){ 
		start_x = 0;
		end_x = room_width;
		start_y = 0;
		end_y = room_height;
	} else {
		start_x = fade_x1;
		end_x = fade_x2;
		start_y = fade_y1;
		end_y = fade_y2;
	}	
		
	fade_to			= _where_next;
	current_fade	= [start_x, start_y, end_x, end_y];
	room_stage		= room_stages.fade;
}	

#endregion

#endregion

#region//------Battle

//Hitting and missing
global.hit_percent = 20; // 100/20 = 5 so 5% chance to miss - see scr_hitcheck
global.miss_safety = -15; //this number is the lowest acc - eva can go out of 20. Meaning the lowest chance to hit without status effects is 25%
global.perc_per_point_to_hit = 100/global.hit_percent; //when acc-eva is calaculated, what each point means as a percentage to hit. So 1% in this case

#region  Party
player_party		= [];
party_size			= 4;

targetable_party	= [];
#endregion

#region Enemies

current_enemies		= [];
available_enemies	= [];

enemy_y = 450;

function spawn_enemies(_enemies_to_spawn){
	var en_num	= array_length(_enemies_to_spawn);	
	var enemy_i = 0;
	var inst;
	repeat(en_num){
		inst = instance_create_layer(0, 0, "Enemies", _enemies_to_spawn[enemy_i]);
		inst.turn_priority = instance_number(obj_combatant);
		array_push(current_enemies, inst);
		enemy_i++;
	}
	
	//find enemy positions
	//Divide play area by number of enemies
	var space_per_enemy = global.play_area_width/en_num;
	enemy_i = 0;
	
	var cur_en;
	repeat(en_num){
		cur_en = current_enemies[enemy_i];
		
		cur_en.x = (space_per_enemy*enemy_i+(space_per_enemy/2));
		cur_en.y = enemy_y;
		enemy_i++;	
	}	
}	
#endregion

#region Turn Order

max_init					= 100;
global.turn_timeline		= [];
global.turn_timeline_shown	= [];
timeline_length				= 10;
timeline_total_length		= 20;
timeline_player_pos			= 0;

redo_timeline				= false;
#endregion

#endregion

#region//Floor
//-----Floor Variables
global.floor_size	= 5; //both width and height
global.floor_layout = [];
global.room_amount	= 10;
global.combat_rooms = 4;

//TYPES OF ROOM WITHIN THE GLOBAL FLOOR LAYOUT
enum room_types {
	free,
	rm,
	corridor,
}	

enum filled_room_types {
	start_room,
	boss_room,
	power_up,
	combat,
	//do we want the rest of the rooms to fill randomly?
	//for example, could have standard_room but that could be a battle, could be treasure
	//could be an npc etc...
	//or do we want these as seperate room types? 
}	

#region//----Battle Rooms
floor_1_battles = [
	[obj_goblin],
	[obj_wolf],
	[obj_goblin, obj_wolf],
]
floor_2_battles = [
	[obj_goblin, obj_goblin],
	[obj_wolf, obj_wolf],
	[obj_goblin, obj_wolf],
]

all_battles = [floor_1_battles, floor_2_battles];


#endregion

#region//-----Backgrounds
//--Rooms
current_floor_bgs		= [];
current_floor_bg_grid	= [];

floor1_bgs = [
	spr_bg_room_1, spr_bg_room_2, spr_bg_room_3,
	spr_bg_room_4, spr_bg_room_5, spr_bg_room_6,
	spr_bg_room_7, spr_bg_room_8, spr_bg_room_9,
];	
//TODO Need to be different to floor 1
floor2_bgs = [
	spr_bg_room_1, spr_bg_room_2, spr_bg_room_3,
	spr_bg_room_4, spr_bg_room_5, spr_bg_room_6,
	spr_bg_room_7, spr_bg_room_8, spr_bg_room_9,
];	

all_floor_bgs = [floor1_bgs, floor2_bgs]; //TODO Change this between floors

//--Corridors
current_cor_bgs		= [];

floor1_cor_bgs = [ spr_bg_corridor_1, spr_bg_corridor_2 ];	
floor2_cor_bgs = [ spr_bg_corridor_1, spr_bg_corridor_2 ];	//TODO Need to be different to floor 1

all_cor_bgs = [floor1_cor_bgs, floor2_cor_bgs]; //TODO Change this between floors
#endregion

//-----Make a Floor
function floor_create(){
	
	//Wipe the visuals from the previous floor
	var vis_x = 0;
	var vis_y = 0;
	repeat(global.floor_size*global.floor_size){
		current_floor_bg_grid[vis_x][vis_y][0] = 0;
		current_floor_bg_grid[vis_x][vis_y][1] = 0;
		vis_x++;
		if(vis_x > global.floor_size-1){
			vis_x =0;
			vis_y++;
		}	
	}
	
	//---Floor changes
	//--Backgrounds
	//rooms
	var len = array_length(all_floor_bgs[global.current_floor])
	array_copy(current_floor_bgs, 0, all_floor_bgs[global.current_floor], 0, len);
	//Corridors
	var len = array_length(all_cor_bgs[global.current_floor])
	array_copy(current_cor_bgs, 0, all_cor_bgs[global.current_floor], 0, len);
	
	#region Create the room grid within an array
	//Create Rows
	var i = 0;
	repeat(global.floor_size){
		global.floor_layout[i] = [0];
		i++;
	}
	
	//create columns
	var i = 0;
	var ii = 0;
	repeat(global.floor_size){
		repeat(global.floor_size){
			global.floor_layout[i][ii] = [room_types.free];
			ii++;	
		}	
		i++
		ii = 0;
	}	
	#endregion
	
	#region Fill the grid with rooms
	//place the rooms
	var total_rooms		= global.floor_size*global.floor_size;
	var rooms_to_place	= global.room_amount;
	var xx	= 0;
	var yy	= 0;
	var i	= 0;
	
	//Change the seed for each floor
	var floor_seed = [];
	var sd_len = array_length(global.seed);
	var start_pos = global.current_floor * global.current_level;
	var current_pos = 0;
	var sd_num = 0;
	var seed_i = 0;;
	repeat(sd_len){
		//change the number of the seed that we start on
		current_pos = seed_i+start_pos;
		while(current_pos > sd_len){
			current_pos -= sd_len;	
		}	
		//change the seed number based on the floor + level
		var find_sd_num = (current_pos*(global.current_floor+1))+global.current_level;
		if(find_sd_num  > 9){
			find_sd_num -= 9;
		}	
		
		sd_num = global.seed[find_sd_num];
		
		//add this number to the floor generating seed
		array_push(floor_seed, sd_num);
		seed_i++
	}
	
	//---work out a 50% to spawn a room
	var room_chance = (rooms_to_place/total_rooms)*10;
	repeat(total_rooms){
		//---Place the room
		if(floor_seed[i] < room_chance){ 
			global.floor_layout[xx][yy] = [room_types.rm]; 
			rooms_to_place--;
			
			//Assign a background to the room
			assign_room_sprite(i, xx, yy);
			
		
			//Stop placing rooms if we run out
			if(rooms_to_place <= 0){ break; }
		}	
		
		//move on the horizontal axis
		xx++
		//reset and add to vertical once we go too far
		if(xx>(global.floor_size-1)){
			xx = 0;
			yy++;
		}	
		//increase seed number
		i++;
		if(i > (global.seed_len-1)){
			i = 0;	
		}	
	}	
	
	//if it hasnt placed all the rooms
	if(rooms_to_place > 0){
		//get the empty rooms as possible locations for a room
		i	= 0;
		xx	= 0;
		yy	= 0;
		var empty_rooms = [ ];
		repeat(total_rooms){
			//if the room is empty, add to array
			if(global.floor_layout[xx][yy][0] = room_types.free){
				empty_rooms[i] = [xx, yy];
				i++
			}	
			
			//move on the horizontal axis
			xx++
			//reset and add to vertical once we go too far
			if(xx>(global.floor_size-1)){
				xx = 0;
				yy++;
			}
		}	
		
		//place empty rooms
		i = 0;
		repeat(rooms_to_place){
			//pick the number
			var num_of_rooms = array_length(empty_rooms);
			var num = min(floor_seed[i], num_of_rooms); //which room will be picked
			xx = empty_rooms[num][0];
			yy = empty_rooms[num][1];
			//place the room
			global.floor_layout[xx][yy][0] = room_types.rm;
			//Assign a background to the room
			assign_room_sprite(i, xx, yy);
			//remove that entry from the array
			array_delete(empty_rooms, num, 1);
			
			i++;
		}	
	
	}	
	#endregion
	
	#region//-----Make all the rooms connected

	#region//see how many rooms have been catalouged
	var islands			= [];
	var room_num		= 0;	
	//if all 10 rooms arent in the array, find the next island
	while(room_num < global.room_amount){ 
		//Pick the first room to test from
		xx = 0;
		yy = 0;
		var current_room_x = 0;
		var current_room_y = 0;
		var marked_rooms   = [];

		repeat(total_rooms){
			//check each room and if it's a filled room, that's the first one.
			if(global.floor_layout[xx][yy][0] == room_types.rm){
				var room_is_not_in = true;
				//ensure it's not already in the islands array
				var island_num = array_length(islands);
				var i = 0;
				repeat(island_num){
					//cycle through the rooms of this island, to check the square against
					var island_size = array_length(islands[i]);
					var ii = 0;
					repeat(island_size){
						if(xx == islands[i][ii][0] && yy == islands[i][ii][1]){
							room_is_not_in = false;
							break;	
						}	
						ii++	
					}
					i++
					ii = 0;
				}	
				//Room is starting room, if not in array
				if(room_is_not_in){
					//change current room details
					current_room_x = xx;
					current_room_y = yy;
					//mark the room
					array_push(marked_rooms, [xx, yy]);
					break;
				}
			} 	
	
			//move on the horizontal axis
			xx++
			//reset and add to vertical once we go too far
			if(xx>(global.floor_size-1)){
				xx = 0;
				yy++;
			}
		}	
	
		#region//-check those around the first "island"
		var marked_room_num			= array_length(marked_rooms);
		var	prev_num_marked_rooms	= 0;
		var safety_net				= 0;
		//If rooms have been added, check around them and keep doing so
		while(prev_num_marked_rooms < marked_room_num){
			//find the number of rooms to check around
			var connecting_room_num = (marked_room_num - prev_num_marked_rooms);
			//check
			var current_room		= prev_num_marked_rooms;
			var surrounding_rooms	= [];
			//update the prev marked rooms for the next loop
			prev_num_marked_rooms = marked_room_num;
			//check around the rooms
			repeat(connecting_room_num){
				//cycle to next room
				current_room_x		= marked_rooms[current_room][0];
				current_room_y		= marked_rooms[current_room][1];
			
				//Coords of surrounding rooms
				//check West
				if(current_room_x-1 >= 0){
					surrounding_rooms[0] = [current_room_x-1, current_room_y];
				} else { surrounding_rooms[0] = -1; }
				//check north
				if(current_room_y-1 >= 0){
					surrounding_rooms[1] = [current_room_x, current_room_y-1];
				} else { surrounding_rooms[1] = -1; }
				//check  East
				if(current_room_x+1 < global.floor_size){
					surrounding_rooms[2] = [current_room_x+1, current_room_y];
				} else { surrounding_rooms[2] = -1; }
				//check South
				if(current_room_y+1 < global.floor_size){
					surrounding_rooms[3] = [current_room_x, current_room_y+1];
				} else { surrounding_rooms[3] = -1; }
			
				//check if each direction is occupied
				i = 0;
				repeat(4){
					//check it's in the bounds of the map
					if(surrounding_rooms[i] != -1){
						var xx = surrounding_rooms[i][0];
						var yy = surrounding_rooms[i][1];
						//ensure it's not already in the array
						var array_len			= array_length(marked_rooms);
						var ii					= 0;
						var not_a_repeat		= true;
						var room_to_add			= [xx, yy];
						//go through the marked_rooms and check the current room is not in the array
						repeat(array_len){
							if(array_equals(marked_rooms[ii], room_to_add)){
								not_a_repeat = false;
								break;
							}
							ii++
						}
					
						//add the room to the array if it's not a repeat
						if(global.floor_layout[xx][yy][0] == room_types.rm && not_a_repeat){
							array_push(marked_rooms, room_to_add);	
						}
					}
					i++
					ii = 0;
				}
				//move to next room
				current_room++;
			}
			//ensure the loop doesn't go on forever
			marked_room_num			= array_length(marked_rooms);
			safety_net++;
			if(safety_net > global.room_amount) { break; }
		}
		//add the island to the array
		array_push(islands, marked_rooms);
		
		//see how many islands have been catalouged
		var island_num	= array_length(islands);
		var i			= 0;
		var room_num	= 0;
		repeat(island_num){
			//cycle through and add each room counted to the total
			room_num += array_length(islands[i]);		
			i++
		}
		#endregion
	}	
	#endregion
	
	#region//connect the room with corridors
	//check if we have more than one island
	var island_num = array_length(islands);
	while(island_num > 1){
		//go through island one and find the closest connection point	
		var isle_1_len				= array_length(islands[0]);
		var i						= 0;
		var room_dist				= -1;
		var potential_rooms			= [];
		repeat(isle_1_len){
			//get co-ords for room to check
			var x_to_check = islands[0][i][0];
			var y_to_check = islands[0][i][1];
			
			//compare co-ords to every other island
			var island_to_check_against = 1;
			var room_to_check_against	= 0;
			repeat(global.room_amount - isle_1_len){
				var i2ca_length			= array_length(islands[island_to_check_against]);
				//get co-ords of the room we are checking against
				var x_to_check_against	= islands[island_to_check_against][room_to_check_against][0];
				var y_to_check_against	= islands[island_to_check_against][room_to_check_against][1];
				
				//get the distance between current room and new room
				var x_diff = abs(x_to_check - x_to_check_against);
				var y_diff = abs(y_to_check - y_to_check_against);
				var total_dist = x_diff + y_diff;
				
				//if nothing has been set, or it's the smallest so far, take that value
				if(room_dist == -1){
					room_dist		= total_dist;
					array_push(potential_rooms, [[x_to_check, y_to_check], [x_to_check_against, y_to_check_against, island_to_check_against]]);
				} else {
					//if the distance is equal, add it to the potentials
					if(total_dist == room_dist){
						array_push(potential_rooms, [[x_to_check, y_to_check], [x_to_check_against, y_to_check_against, island_to_check_against]]);
					//if the distance is less, replace the potentials
					} else if (total_dist < room_dist){
						potential_rooms = [];
						array_push(potential_rooms, [[x_to_check, y_to_check], [x_to_check_against, y_to_check_against, island_to_check_against]]);
						room_dist		= total_dist;
					}
				}	
				
				//check next room
				room_to_check_against++;
				//if we check all rooms in an island, move to next island
				if(room_to_check_against >= i2ca_length){
					room_to_check_against	= 0;	
					island_to_check_against++;
				} 
			}	
		
			i++;
		}
		
		#region//Build a corridor to the nearest room
		//pick options based on seed	
		var chosen_path_num = scr_seed_chance(global.seed[global.current_seed_num], potential_rooms);
		var chosen_path		= potential_rooms[chosen_path_num];
		
		var room_from		= chosen_path[0];
		var room_to			= chosen_path[1];
		var connecting_island = chosen_path[1][2];
		
		//---Find and mark a path between the rooms
		//Get the distances between the room co-ords in both directions
		var x_dir			= room_to[0]-room_from[0];
		var y_dir			= room_to[1]-room_from[1];
		
		//find which direction to travel in
		//possible choices
		var possible_directions = [];
		if(abs(x_dir) > 1){ array_push(possible_directions, 0); } //0 = x axis
		if(abs(y_dir) > 1){ array_push(possible_directions, 1); } //0 = x axis
		if(abs(x_dir) > 0 && abs(y_dir) > 0){ possible_directions = [0, 1]; }
		
		//pick a choice
		var possible_dirs			= array_length(possible_directions);
		var chosen_dir_num			= scr_seed_chance(global.current_seed_num, possible_directions);	
		var chosen_dir				= possible_directions[chosen_dir_num];
		
		//move to the next corridor square and make them corridors
		while(possible_dirs > 0){
			//moving on X
			if(chosen_dir == 0){ 
				//if it wasn't a corridor - make 4 data points that contain each direction
				if(global.floor_layout[room_from[0]+(sign(x_dir)), room_from[1]][0] != room_types.corridor){
					global.floor_layout[room_from[0]+(sign(x_dir)), room_from[1]][1] = 0; //north
					global.floor_layout[room_from[0]+(sign(x_dir)), room_from[1]][2] = 0; //east
					global.floor_layout[room_from[0]+(sign(x_dir)), room_from[1]][3] = 0; //South
					global.floor_layout[room_from[0]+(sign(x_dir)), room_from[1]][4] = 0; //west
				}
			
				//mark the square as a corridor
				global.floor_layout[room_from[0]+(sign(x_dir)), room_from[1]][0] = room_types.corridor;
				
				//-----Set the background
				assign_cor_sprite(room_from[0]+(sign(x_dir)), room_from[1]);

				//mark the direction we came from
				var dir_to_add;
				if(sign(x_dir) == 1){ //East
					dir_to_add = 4;
				} else if(sign(x_dir) == -1){ // West
					dir_to_add = 2;
				}	
	
				global.floor_layout[room_from[0]+(sign(x_dir)), room_from[1]][dir_to_add] = 1;
			
				//update where we are looking from
				room_from[0] = room_from[0]+(sign(x_dir));
			//moving on Y	
			} else if(chosen_dir == 1){
				
				//if it wasn't a corridor - make 4 data points that contain each direction
				if(global.floor_layout[room_from[0], room_from[1]+(sign(y_dir))][0] != room_types.corridor){
					global.floor_layout[room_from[0], room_from[1]+(sign(y_dir))][1] = 0; //north
					global.floor_layout[room_from[0], room_from[1]+(sign(y_dir))][2] = 0; //east
					global.floor_layout[room_from[0], room_from[1]+(sign(y_dir))][3] = 0; //South
					global.floor_layout[room_from[0], room_from[1]+(sign(y_dir))][4] = 0; //west
				}
				
				global.floor_layout[room_from[0], room_from[1]+(sign(y_dir))][0] = room_types.corridor;
				
				//-----Set the background
				assign_cor_sprite(room_from[0], room_from[1]+(sign(y_dir)));
				
				//mark the direction we came from
				var dir_to_add;
				if(sign(y_dir) == 1){ //coming from south, so mark north
					dir_to_add = 1;
				} else if(sign(y_dir) == -1){ // North ^
					dir_to_add = 3;
				}	
				global.floor_layout[room_from[0], room_from[1]+(sign(y_dir))][dir_to_add] = 1; 
			
				//update where we are looking from
				room_from[1] = room_from[1]+(sign(y_dir));
			}	
			
			//Get the distances between the room co-ords in both directions
			x_dir			= room_to[0]-room_from[0];
			y_dir			= room_to[1]-room_from[1];
		
			//where are we going to (to finish this square)
			possible_directions = [];
			if(abs(x_dir) >= 1){ array_push(possible_directions, 0); } //0 = x axis
			if(abs(y_dir) >= 1){ array_push(possible_directions, 1); } //0 = x axis
			if(abs(x_dir) > 0 && abs(y_dir) > 0){ possible_directions = [0, 1]; }
		
			//pick a choice
			possible_dirs			= array_length(possible_directions);
			chosen_dir_num			= scr_seed_chance(global.current_seed_num, possible_directions);
			if(possible_dirs > 0){
				chosen_dir				= possible_directions[chosen_dir_num];
			}
			
			//Going to move on X
			if(chosen_dir == 0){ 
				//mark the direction we're going to
				var dir_to_add;
				if(sign(x_dir) == 1){ //East
					dir_to_add = 2;
				} else if(sign(x_dir) == -1){ // West
					dir_to_add = 4;
				}	
	
				global.floor_layout[room_from[0], room_from[1]][dir_to_add] = 1;
			//Going to move on Y	
			} else if(chosen_dir == 1){
				//mark the direction we are going to
				var dir_to_add;
				if(sign(y_dir) == 1){ //South
					dir_to_add = 3;
				} else if(sign(y_dir) == -1){ // North
					dir_to_add = 1;
				}	
				global.floor_layout[room_from[0], room_from[1]][dir_to_add] = 1; 
			}	
			
			//where are we going to (NEXT SQUARE)
			possible_directions = [];
			if(abs(x_dir) > 1){ array_push(possible_directions, 0); } //0 = x axis
			if(abs(y_dir) > 1){ array_push(possible_directions, 1); } //0 = x axis
			if(abs(x_dir) > 0 && abs(y_dir) > 0){ possible_directions = [0, 1]; }
		
			//update the number of choices
			possible_dirs			= array_length(possible_directions);		
		}
		
		//---Fold the connected island into 0
			//add to island 1
			var cur_isl_len = array_length(islands[connecting_island]);
			var iii = 0;
			repeat(cur_isl_len){
				array_push(islands[0], islands[connecting_island][iii]);
				iii++
			}	
			// Delete the old entry & update number of remaining islands
			array_delete(islands, connecting_island, 1);
			island_num = array_length(islands);
		#endregion
	}	
	
	#endregion
	#endregion
	
	#region//Add the visible rooms to the map
	var ar_len = array_length(current_floor_bg_grid);
	var xxx	   = 0;
	var yyy	   = 0;
	repeat(ar_len){
		current_floor_bg_grid[xxx][yyy][1] = 0;
		//move to next room and loop
		xxx++;
		if(xxx > global.floor_size){
			xxx = 0;
			yyy++;
		}	
	}
	#endregion
	
	#region//Populate the floor with different types of room
	
	#region//----Start room
	//Choose which wall it'll be on
	var start_pos = scr_seed_chance(global.current_seed_num, 3);; //choose 0west, 1north, 2east, 3south
	var start_wall;
	if(start_pos == 0 || start_pos == 1){ 
		start_wall = 0;
	} else if(start_pos == 3 || start_pos == 2){
		start_wall = global.floor_size-1;
	}	
	
	//----Find the correct row, go through the rooms and place a start room randomly
	var possible_rooms = [];
	//are we on x or y axis
	if(start_pos mod 2 == 0){ //x
		//east or west
		var i = start_wall;
		var up_or_down;
		if(i == 0){ 
			up_or_down = 1;
		} else {
			up_or_down = -1;	
		}	
		
		//go through the row and pick out rooms
		repeat(global.floor_size){
			//get details for the row we are checking
			var current_row = global.floor_layout[i];
			//go through the rows and take down details for any available rooms
			var ii = 0;
			repeat(global.floor_size){
				if(current_row[ii][0] == 1){ //if it's a room
					array_push(possible_rooms, [i, ii]);
				}	
				ii++
			}	
			i+=up_or_down;
			if(array_length(possible_rooms) > 0){ break; }
		}
	} else { //y
		//north or south
		var ii = start_wall;
		var up_or_down;
		if(ii == 0){ 
			up_or_down = 1;
		} else {
			up_or_down = -1;	
		}	
		
		//go through each column 
		var i = 0;
		repeat(global.floor_size){
			repeat(global.floor_size){
				if(global.floor_layout[i][ii][0] == 1){
					array_push(possible_rooms, [i, ii]);
				}
				i++
			}
			ii+=up_or_down
			i = 0;
			if(array_length(possible_rooms) > 0){ break; }
		}
	}	
	
	//Place the start room
	var chosen_room_n	= scr_seed_chance(global.current_seed_num, possible_rooms);
	var chosen_room		= possible_rooms[chosen_room_n];
	global.floor_layout[chosen_room[0]][chosen_room[1]][1] = filled_room_types.start_room;
	//put the player at the start room
	global.current_room = [chosen_room[0], chosen_room[1]];
	//mark it visible
	current_floor_bg_grid[chosen_room[0]][chosen_room[1]][1] = 1;
	#endregion
	#region//Place the end/boss room
	var end_x = 0; 
	var end_y = 0;
	var dir_to_check_x = 1; 
	var dir_to_check_y = 1;
	//Find the furthest corner from the start point
	if(global.current_room[0] < (global.floor_size/2)){
		end_x = global.floor_size-1;
		dir_to_check_x = -1; 
	}	
	if(global.current_room[1] < (global.floor_size/2)){
		end_y = global.floor_size-1;
		dir_to_check_y = -1; 
	}	
	//checking the furthest corner
	if(global.floor_layout[end_x][end_y][0] == 1){ 
		global.floor_layout[end_x][end_y][1] = filled_room_types.boss_room;
	//check the rest of the squares from the corner	
	} else {
		var potential_endrooms	= [];
		var p_er_num			= array_length(potential_endrooms);
		var current_check		= 1;
		var check_x				= 0;
		var check_y				= 0;
		var check_dir			= 1; 
		var reversing			= false;
		while(p_er_num < 1){
			
			check_x = check_x+((current_check)*(dir_to_check_x));

			repeat(current_check+check_dir){
				//check the room is not a void
				if(global.floor_layout[end_x+check_x][end_y+check_y][0] == 1){
					//and not the start room (by checking the array length isnt long enough)
					var potential_start_room = array_length(global.floor_layout[end_x+check_x][end_y+check_y]);
					if(potential_start_room < 2){
						array_push(potential_endrooms, [end_x+check_x, end_y+check_y]);
					}	
				}	
				//move along in diagonals
				check_x-=dir_to_check_x;
				check_y+=dir_to_check_y;
			}
			//get ready for next loop
			check_x = 0;
			check_y = 0;
			
			// make it so that you check from the otherside, but at max if we go over halfway
			if(current_check >= global.floor_size-1){ 
				reversing = true;
				
				//change the point to check from to be the opposite of whatever it is
				if(end_x == 0){ end_x = global.floor_size-1;}
				else if(end_x == global.floor_size-1){ end_x = 0;}
				if(end_y == 0){ end_y = global.floor_size-1;}
				else if(end_y == global.floor_size-1){ end_y = 0;}
				
				//change the direction we're checking in
				dir_to_check_x *= -1;
				dir_to_check_y *= -1;
			} 
			
			if(reversing){
				current_check--;
			} else {
				current_check++	
			}	
			
			//recheck the array length
			p_er_num = array_length(potential_endrooms);
		}	
		//pick the end/boss room
		var chosen_end_room = scr_seed_chance(global.seed[global.current_seed_num], potential_endrooms);
		var chosen_end_x = potential_endrooms[chosen_end_room][0];
		var chosen_end_y = potential_endrooms[chosen_end_room][1];
		global.floor_layout[chosen_end_x][chosen_end_y][1] = filled_room_types.boss_room;
	}
	#endregion
	
	#region//----Add the battle rooms
	//find the avilable rooms
	var available_rooms = [];
	var ar_x			= 0;
	var ar_y			= 0;
	var room_type_check = 0;
	var add_this_square	= false;
	repeat(global.floor_size*global.floor_size){
		if(global.floor_layout[ar_x][ar_y][0] == room_types.rm){
			//check the room is a vacant room
			room_type_check = array_length(global.floor_layout[ar_x][ar_y]);
			if(room_type_check == 1){ add_this_square = true;}
			else if(global.floor_layout[ar_x][ar_y][1] == -1){
				add_this_square = true;
			}	
			//if it is, add to the list
			if(add_this_square){
				array_push(available_rooms, [ar_x, ar_y]);
			}	
		}	
		//cycle through the rooms
		ar_x++;
		if(ar_x >= global.floor_size){
			ar_y++;
			ar_x = 0;
		}	
		add_this_square = false;
	}	
		
		
	var chosen_battle_room, chosen_room_x, chosen_room_y;
	var battle_selection = all_battles[global.current_floor];
	repeat(global.combat_rooms){
		num_of_rooms_left  = array_length(available_rooms);
		chosen_battle_room = scr_seed_chance(global.seed[global.current_seed_num], num_of_rooms_left);
		chosen_room_x  = available_rooms[chosen_battle_room][0];
		chosen_room_y  = available_rooms[chosen_battle_room][1];
		global.floor_layout[chosen_room_x][chosen_room_y][1] = filled_room_types.combat;
		array_delete(available_rooms, chosen_battle_room, 1);
		
		//add the enemies
		var battle_chosen = scr_seed_chance(global.seed[global.current_seed_num], battle_selection);
		global.floor_layout[chosen_room_x][chosen_room_y][2] = battle_selection[battle_chosen];
	}	
		
	#endregion
	
	#endregion
} 
	
//new floor reset
function floor_reset(){
	current_floor_bgs		= [];
	current_floor_bg_grid	= [];
	room_reset();
}	
	
//new room reset
function room_reset(){
	current_option	= 0;
	options			= [];
	page			= 0;
	
	//carry over the available direction to the option
	var ad_len = array_length(directions_available);
	var i = 0;
	options[pages.directions] = [];
	repeat(ad_len){
		if(directions_available[i] != 0){
			array_push(options[pages.directions], i);
		}
		i++
	}
		
	//set the start options
	if(ad_len > 0 ){
		options[pages.start_page] = [];
		array_push(options[pages.start_page], p_o.show_directions);
	}	
	if(
		global.floor_layout[global.current_room[0]][global.current_room[1]][1] == filled_room_types.boss_room
		&& global.floor_layout[global.current_room[0]][global.current_room[1]][0] == room_types.rm
		)
	{
		array_push(options[pages.start_page], p_o.finish_floor);
	}	
}	

//mark room avilibility
function rm_av_check(_dir_av, x_to_be, y_to_be){
	var player_x = global.current_room[0];
	var player_y = global.current_room[1];
	//rooms
	if(global.floor_layout[x_to_be][y_to_be][0] == 1){
		directions_available[_dir_av]	= global.floor_layout[x_to_be][y_to_be][0];	
		//if the room hasn't been visited, add it to the map as a potential room to go to
		if(current_floor_bg_grid[x_to_be][y_to_be][1] < 1){
			current_floor_bg_grid[x_to_be][y_to_be][1] = 0.5;
		}
	//corridors	
	} else if(global.floor_layout[x_to_be][y_to_be][0] == 2){
		if(y_to_be > player_y){ //if we're checking north
			if(global.floor_layout[x_to_be][y_to_be][1] == 1){ //if the corridor connects north
				directions_available[_dir_av]	= global.floor_layout[x_to_be][y_to_be][0];
				//if the room hasn't been visited, add it to the map as a potential room to go to
				if(current_floor_bg_grid[x_to_be][y_to_be][1] < 1){
					current_floor_bg_grid[x_to_be][y_to_be][1] = 0.5;
				}
			}	
		}  
		if(y_to_be < player_y){ //if we're checking south	
			if(global.floor_layout[x_to_be][y_to_be][3] == 1){ //if the corridor connects south
				directions_available[_dir_av]	= global.floor_layout[x_to_be][y_to_be][0];
				//if the room hasn't been visited, add it to the map as a potential room to go to
				if(current_floor_bg_grid[x_to_be][y_to_be][1] < 1){
					current_floor_bg_grid[x_to_be][y_to_be][1] = 0.5;
				}
			}			
		} 
		if(x_to_be < player_x){ //if we're checking east	
			if(global.floor_layout[x_to_be][y_to_be][2] == 1){ //if the corridor connects east
				directions_available[_dir_av]	= global.floor_layout[x_to_be][y_to_be][0];
				//if the room hasn't been visited, add it to the map as a potential room to go to
				if(current_floor_bg_grid[x_to_be][y_to_be][1] < 1){
					current_floor_bg_grid[x_to_be][y_to_be][1] = 0.5;
				}
			}			
		} 
		if(x_to_be > player_x){ //if we're checking west
			if(global.floor_layout[x_to_be][y_to_be][4] == 1){ //if the corridor connects west
				directions_available[_dir_av]	= global.floor_layout[x_to_be][y_to_be][0];
				//if the room hasn't been visited, add it to the map as a potential room to go to
				if(current_floor_bg_grid[x_to_be][y_to_be][1] < 1){
					current_floor_bg_grid[x_to_be][y_to_be][1] = 0.5;
				}
			}			
		}			
	}
}	

//assign a room sprite
function assign_room_sprite(_seed_num, _xx, _yy){
	//------Pick the sprite
	//make sure we aren't picking outside the list & list isn't empty
	var num_of_sprites	= array_length(current_floor_bgs);
	var num_picked		= global.seed[_seed_num];

	if(num_of_sprites < 1){ 
		var len = array_length(all_floor_bgs[global.current_floor])
		array_copy(current_floor_bgs, 0, all_floor_bgs[global.current_floor], 0, len);
		num_of_sprites	= array_length(current_floor_bgs);
	}
	if(num_picked > num_of_sprites-1){ num_picked = num_of_sprites-1; }
			
	var sprite_to_pick = current_floor_bgs[num_picked];
			
	//Assign the background
	current_floor_bg_grid[_xx][_yy][0] = sprite_to_pick;
	//delete this one from the array
	array_delete(current_floor_bgs, num_picked, 1);
}	
function assign_cor_sprite(_xx, _yy){
			//make sure we aren't picking outside the list & list isn't empty
	var num_of_sprites	= array_length(current_cor_bgs);
	var num_picked		= global.seed[0];

	if(num_of_sprites < 1){ 
		var len = array_length(all_cor_bgs[global.current_floor])
		array_copy(current_cor_bgs, 0, all_cor_bgs[global.current_floor], 0, len);
		num_of_sprites	= array_length(current_cor_bgs);
	}
	if(num_picked > num_of_sprites-1){ num_picked = num_of_sprites-1; }
			
	var sprite_to_pick = current_cor_bgs[num_picked];
			
	//Assign the background
	current_floor_bg_grid[_xx][_yy][0] = sprite_to_pick;
	//delete this one from the array
	array_delete(current_cor_bgs, num_picked, 1);
}	
#endregion

#region//UI
map_size		= room_width/4;
text_x			= 0;
text_y			= 480;
text_buffer		= 25;
options			= [];
page			= [];
option_font		= fnt_optionbox;

global.play_area_width = 722;
play_area_height = 481;

//character boxes
char_box_width			= map_size/2;
char_box_height			= 180;
char_box_start_height	= 350;
name_buffer				= 5;

//Turnorder display
turn_box_start_x		= global.play_area_width + name_buffer;
turn_box_end_x			= (room_width/4)*3 - name_buffer;
turn_box_start_y		= 1;
turn_box_height			= 60;
current_letter			= 0;


//battlelog 
global.combatlog				= [];
global.combatlog_visible		= false;
global.combatlog_to_add			= [];
combatlog_skippable				= false;
log_timer						= 6;
max_lines						= 8;
type_speed						= room_speed/50;
next_letter						= true;

//make an array for each line of the battlelog display
shown_combatlog					= []
var i = 0;
repeat(max_lines){
	shown_combatlog[i] = "";	
	i++;
}	

enum p_o { //possible options
	go_north, //DO NOT MOVE THE DIRECTIONS 
	go_east,  //ADD ANYTHING ELSE BELOW
	go_south,
	go_west,
	show_directions,
	finish_floor,
}	

enum pages {
	start_page,
	directions,
}	

back_pages = [
	-1,
	pages.start_page,

]

#endregion

//As the characters are spawned first, we have to give the info from here
//Give the player character some info from this object
with(obj_player_char){
	text_x			= obj_game.text_x;
	text_y			= obj_game.text_y;
	text_buffer		= obj_game.text_buffer;
	current_option	= 0;
	option_font		= other.option_font
}