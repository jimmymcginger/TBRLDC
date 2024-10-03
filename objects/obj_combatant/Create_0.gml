/// @description Insert description here
// You can write your code in this editor
char_name	= "";
stat_hp		= 10;
stat_mp		= 10;
stat_att	= 10;
stat_mag	= 10;
stat_def	= 10;
stat_magdef = 10;
stat_speed	= 10;
stat_acc	= 10;
stat_eva	= 10;
crit_chance = 0.05;
crit_damage = 2; //crit means double damage

//resistances? status effect stuff? 

//current stats
current_hp = stat_hp;
current_mp = stat_mp;

//temp stats
ko				= false;
initiative		= 0;
work_out_init	= 0;
my_turn			= false;
turn_priority   = 0;
take_turn_timer = 1; //TODO: remove this once they get actual turns

death_text_done = false;

//Move types
enum move_types {
	phy_attack,
	mag_attack,
	
}	

//Take turn
function take_turn(_turn_cost = 100){
	initiative -= _turn_cost;
	obj_game.redo_timeline = true;
	my_turn		= false;
}	

function perform_move(_target, _speed, _move_type, _damage_type, _status_effect, _speed_damage){
	var target_name				= _target.char_name;
	var target_y_plus_height	= _target.y - _target.sprite_height;
	
	
	switch (_move_type){
		case move_types.phy_attack:
			
			//did we hit/miss/crit?
			var hit_miss_crit = scr_hitcheck(stat_acc, _target.stat_eva, crit_chance);
			var crit = false;
			var log_text, log_text1, log_text2;
			if(hit_miss_crit == 2){  
				log_text1 = " crit ";
				crit = true;
			} else if(hit_miss_crit == 1){ log_text1 = " attacked ";}
			else { log_text = " missed " + target_name + "!"}
			//TODO SFX Miss noise, plus other noises for each weapon
			
			//work out damage
			if(hit_miss_crit != 0){
				//work out damage
				var dmg = scr_phys_dmg(stat_att, _target.stat_def, crit, crit_damage); //TODO add an attack animation
				//do damage
				_target.current_hp -= dmg; //TODO Add a hurt animation (single frame or a flash or something)
				//work out log message
				log_text2 = string(dmg);
				log_text = log_text1 + target_name + " for " + log_text2 + " damage!";
				//create damage number 
				var inst = instance_create_layer(_target.x, target_y_plus_height, "Messages", obj_dmg_num);
				inst.dmg_str = log_text2;
			}	
		
		break;
		
		
	}	
	
	//add to the combat log
	show_combatlog(char_name + log_text);
	//deal with turn order stuff
	take_turn(_speed);
}	