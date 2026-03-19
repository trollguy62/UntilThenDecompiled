@tool
extends MeshInstance3D

@export var max_angle = 10.0
@export var speed = 1.0

var _t = 0


func _process(delta):
	_t += delta
	rotation.y = sin(_t * speed) * deg_to_rad(max_angle)
