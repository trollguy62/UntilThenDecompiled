@tool
extends RichTextEffect
class_name RichTextPulse

var bbcode = "pulse"


func _init():
	resource_name = "RichTextPulse"


func _process_custom_fx(char_fx):
	var color = char_fx.env.get("color", char_fx.color)
	var color_alt = char_fx.env.get("color_alt", char_fx.color)
	var freq = char_fx.env.get("freq", 2.0)
	var offset = char_fx.env.get("offset", 0.0)

	var sined_time = (sin(char_fx.elapsed_time * freq + offset) + 1.0) / 2.0
	char_fx.color = color_alt.linear_interpolate(color, sined_time)
	color.a = 1.0
	return true
