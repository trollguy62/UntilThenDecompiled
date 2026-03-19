@tool
extends RichTextEffect
class_name RichTextGhost

var bbcode = "ghost"
var time = 0.0


func _init():
	resource_name = "RichTextGhost"


func _process_custom_fx(char_fx):
	if time == 0:
		time = char_fx.elapsed_time

	var speed = char_fx.env.get("freq", 5.0)
	var span = char_fx.env.get("span", 10.0)

	var alpha = sin(char_fx.elapsed_time * speed + (char_fx.absolute_index / span)) * 0.5 + 0.5
	char_fx.color.a = alpha
	return true
