// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function draw_text_outlined(_x, _y, _outline_colour, _string_color, _string){ 
	var xx,yy;  
	xx = argument[0];  
	yy = argument[1];  
  
	//Outline  
	draw_set_color(argument[2]);  
	draw_text(xx+1, yy+1, argument[4]);  
	draw_text(xx-1, yy-1, argument[4]);  
	draw_text(xx,   yy+1, argument[4]);  
	draw_text(xx+1,   yy, argument[4]);  
	draw_text(xx,   yy-1, argument[4]);  
	draw_text(xx-1,   yy, argument[4]);  
	draw_text(xx-1, yy+1, argument[4]);  
	draw_text(xx+1, yy-1, argument[4]);  
  
	//Text  
	draw_set_color(argument[3]);  
	draw_text(xx, yy, argument[4]); 
}