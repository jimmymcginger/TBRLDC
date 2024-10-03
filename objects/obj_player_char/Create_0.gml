/// @description Insert description here
// You can write your code in this editor
event_inherited();
char_name	= "Character 1";

//Battle Menu

enum option_type {
	change_page,
	do_move,
}	

page			= 0;
current_option  = 0;
battle_options	= [
	//Main Page
	[						//Options + page they go to, page to go back
		["Attack", option_type.do_move, [global.normal_speed, move_types.phy_attack]],
		["Skills", option_type.change_page, 1], 
		-1
	], 
	//Skills
	[
		["Fast Attack", option_type.do_move, [global.fast_speed, move_types.phy_attack]], //TODO change this so that
		["Normal Attack", option_type.do_move, [global.normal_speed, move_types.phy_attack]], //moves can be added or taken away
		["Slow Attack", option_type.do_move, [global.slow_speed, move_types.phy_attack]],
		["Do nothing", option_type.do_move, [global.normal_speed, move_types.phy_attack]],
		0
	]
];

work_out_tl			= false;

selected_move		= [];

selecting_target	= false;
current_target		= 0;

player_displayed_bl	= -1;
combatlog_pos		= 0;

function reset_turn() { 
	selected_move			= [];
	selecting_target		= false;
	current_target			= 0;
	page					= 0;
	current_option			= 0;
}	