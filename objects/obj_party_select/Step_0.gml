/// @description Insert description here
// You can write your code in this editor

//if in character select, move on
if(room == rm_party){ 
	//create the characters
	repeat(4){
		create_character();	
	}	
	
	//pass on the party data
	var inst = instance_create_layer(0, 0, "Instances", obj_game);
	inst.player_party = party;
	
	//go to next room
	room_goto_next(); 
//if in main room, pass the party data on and delete
} else {
	instance_destroy();
}	
