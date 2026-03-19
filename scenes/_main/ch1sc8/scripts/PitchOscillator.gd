@tool
extends Node

@export var min_pitch := 0.9
@export var max_pitch := 1.1
@export var frequency := 1.0

@onready var player = get_parent()

var _t := 0.0


func _process(delta):
	_t += delta
	player.pitch_scale = Utils.sin_bounded(_t, min_pitch, max_pitch, frequency)
