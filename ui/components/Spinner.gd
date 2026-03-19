extends TextureRect

@export var rots_per_sec = 1.0
var _t = 0


func _process(delta):
	if visible:
		_t += delta
		pivot_offset = size / 2
		rotation_degrees = rots_per_sec * 360.0 * _t
