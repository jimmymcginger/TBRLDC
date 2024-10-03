//This script will take a number (0-9) from the seed given, and then takes
//that number based on a number of options, and uses that like a percentage
function scr_seed_chance(_seed_number, _number_of_options){
	//get the number of options from an array, if it is one
	var number_of_options;
	if(is_array(_number_of_options)){
		number_of_options	= array_length(_number_of_options);
	} else { number_of_options = _number_of_options;}
	
	//------Get the seed number
	//make sure the seed number is within the length of the seed
	if(_seed_number < 0){ _seed_number = 0; }
	else if (_seed_number > global.seed_len-1){_seed_number-=global.seed_len;}
	//get the seed number
	var num_from_seed = global.seed[_seed_number];
	
	
	//work out the percentage
	var perc_chance = 10/number_of_options;
	var chosen_num	= floor(num_from_seed/perc_chance);
	
	//increase the seed number
	global.current_seed_num++;
	if(global.current_seed_num > global.seed_len-1){ global.current_seed_num = 0; }

	return chosen_num;
}