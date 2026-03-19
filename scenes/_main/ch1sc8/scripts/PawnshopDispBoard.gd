@tool
extends Sprite3D

@export var speed := 1.0
@export var amplitude_degrees := 5.0

var _t := 0.0


func _process(delta):
	_t += delta
	rotation_degrees.x = sin(_t * speed) * amplitude_degrees
