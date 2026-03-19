@tool
extends Node

@export_range(0.0, 1.0) var extent = 0.04
@export_range(0.0, 8.0) var speed = 1.0

@export_range(0.0, 90.0) var rot_x_speed = 0.0

@onready var parent = get_parent() as Node3D

var _dy = 0.0
var _t = 0.0


func _ready():
	_t = randf_range(-4.0, 4.0)


func _process(delta):
	if abs(extent) > 0:
		_t += delta * speed
		var new_dy = sin(_t) * extent
		parent.global_transform.origin.y += new_dy - _dy
		_dy = new_dy

	if abs(rot_x_speed) > 0:
		parent.rotate_object_local(Vector3.RIGHT, deg_to_rad(rot_x_speed) * delta)
