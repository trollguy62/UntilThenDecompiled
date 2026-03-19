extends "res://scenes/_main/ch3sc1/scripts/MovingNPC.gd"

@export var speed_per_frame: Array[float] = []
@export var base_speed: float

func _process(delta):
	if not moving:
		return
	
	check_progress()
	
	speed = speed_per_frame[sprite.frame] * base_speed
	path_grounder.offset_speed = speed
	path_grounder._target_offset_speed = speed
	
	if speed == 0:
		path_grounder.enabled = false
	else:
		path_grounder.enabled = true
