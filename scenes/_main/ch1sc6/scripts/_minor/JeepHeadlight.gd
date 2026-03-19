@tool
extends SpotLight3D

@export var hue_change_speed = 1.0


func _process(delta):
	light_color.h += delta * hue_change_speed
