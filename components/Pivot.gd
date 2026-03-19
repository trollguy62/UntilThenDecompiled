extends Node3D
class_name Pivot

@export var fixed_x = false
@export var fixed_y = false
@export var fixed_z = false
@export var offset = Vector3()
@export var min_position = Vector3(-9999, -9999, -9999)
@export var max_position = Vector3(9999, 9999, 9999)

@onready var _initial_global_transform = get_parent().global_transform


func _process(_delta):
	var new_global_transform = get_parent().global_transform

	if fixed_x:
		new_global_transform.origin.x = _initial_global_transform.origin.x
	if fixed_y:
		new_global_transform.origin.y = _initial_global_transform.origin.y
	if fixed_z:
		new_global_transform.origin.z = _initial_global_transform.origin.z

	new_global_transform.origin += offset

	new_global_transform.origin.x = clamp(
		new_global_transform.origin.x, min_position.x, max_position.x
	)
	new_global_transform.origin.y = clamp(
		new_global_transform.origin.y, min_position.y, max_position.y
	)
	new_global_transform.origin.z = clamp(
		new_global_transform.origin.z, min_position.z, max_position.z
	)

	global_transform = new_global_transform
