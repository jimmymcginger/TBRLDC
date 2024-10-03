// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function scr_hitcheck(_acc, _eva, _crit_chance){
	//Decide whether a move misses, hits or crits
	//if acc is same as eva - aiming for 5% miss rate
	
	//compare the stats - each point difference is 1% more to hit or miss.
	var stat_diff = max((_acc - _eva)/global.perc_per_point_to_hit, global.miss_safety); //minimum of -15;
	
	//1 in 20 twenty chance to miss = 5% if equal stats
	var hit_chance	= irandom(global.hit_percent-1) + stat_diff; //minus 1 due to irand including 0
	var hit			= false;
	show_debug_message(hit_chance)
	//did we hit?
	if(hit_chance > 0){ hit = true; } 
	
	//did we crit?
	var crit = false;
	var compare_crit_chance = global.hit_percent*_crit_chance;
	if(hit){
		if(hit_chance > (global.hit_percent-1)-compare_crit_chance){
			crit = true;	
		}	
	}	
	
	//return
	if(crit){ return 2; }
	else if(hit){ return 1;}
	else { return 0;}
}