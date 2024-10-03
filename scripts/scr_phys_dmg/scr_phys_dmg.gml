// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function scr_phys_dmg(_att, _def, _crit, _crit_dmg){
	//work out base damage
	var dmg		= _att - (_def/10);
	var bonus	= irandom(round(dmg/10));
	dmg += bonus;
	
	//work out crit dmg
	if(_crit){
		dmg *= _crit_dmg	
	}	
		
	return dmg;
}