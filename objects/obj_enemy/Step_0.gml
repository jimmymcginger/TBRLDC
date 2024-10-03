/// @description Insert description here
// You can write your code in this editor

//death
if(current_hp <= 0 && !ko){
	//TODO SFX - Death noise
	if(!death_text_done){
		show_combatlog(string(char_name + " was defeated. "));
		death_text_done = true;
	}	
	
	
	//TODO proper death animation	
	//fade out
	if(alpha <= 0){ 
		ko = true; 
	} else {
		alpha -= fade_spd;	
	}	
}	