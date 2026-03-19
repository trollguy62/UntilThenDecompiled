extends Node3D

@export var state_container_alias := ""
@export var target_path: NodePath
@export var look_at_left := ""
@export var look_at_right := ""

@onready var state_container = Utils.get_state_container_of(state_container_alias) as StateContainer
@onready var target = get_node(target_path) as Node3D
@onready var viewport = get_viewport()


func _process(delta):
	# Explicit `true` check required
	if state_container.dict.get_value("look_at_controller") != true:
		return

	var self_to_target = (target.global_transform.origin - global_transform.origin).normalized()
	var camera_right = viewport.get_camera_3d().global_transform.basis.x
	var to_right = self_to_target.dot(camera_right) > 0
	var look_at = look_at_right if to_right else look_at_left

	state_container.dict.set_value("look_at", look_at)
