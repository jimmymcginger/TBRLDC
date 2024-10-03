/// @description Insert description here
// You can write your code in this editor

party = [];

function create_character(){

	var inst = instance_create_layer(0, 0, "Instances", obj_player_char);

	array_push(party, inst);

	//ADD THE STATS OF CHOSEN CLASS
	var al = array_length(party);
	
	inst.char_name = string("Character " + string(al));
	
	//give them a turn priority
	inst.turn_priority = instance_number(obj_player_char);
}