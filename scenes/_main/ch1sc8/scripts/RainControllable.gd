extends Node

@export_range(0.0, 1.0) var intensity: float = 1:
	set = _set_intensity,
	get = _get_intensity


func _set_intensity(value: float):
	assert(false, "Not implemented")


func _get_intensity():
	return intensity
