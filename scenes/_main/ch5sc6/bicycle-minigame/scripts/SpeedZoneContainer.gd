extends Node

var speed_zones = []


func _ready():
	speed_zones = get_children()


func move_range(value):
	for i in speed_zones:
		i.move_range(value)


func check_speed_multiplier(position):
	for i in speed_zones:
		if position >= i.min_range and position <= i.max_range:
			return i
