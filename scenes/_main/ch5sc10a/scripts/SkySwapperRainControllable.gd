extends "res://scenes/_main/ch1sc8/scripts/RainControllable.gd"

@export var environment: Environment
@export var skyboxes: Array[Sky]


func _ready():
	self.intensity = intensity


func _set_intensity(value):
	intensity = value

	if is_inside_tree():
		var count = skyboxes.size()
		var idx = int(min(floor(count * intensity), count - 1))
		environment.sky = skyboxes[idx]
