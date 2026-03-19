extends Node

@onready var ca = get_parent()

var _t := 0.0


func _process(delta):
	_t += delta
	ca.inner_radius = Utils.sin_bounded(_t, 0.2, 0.3, 1.5)
