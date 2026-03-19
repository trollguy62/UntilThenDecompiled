extends Node

@export var look_at_path: NodePath
@export var state_container_path: NodePath

@onready var parent = get_parent()
@onready var sprite = $"../Sprite"
@onready var sfx_footsteps = $Footsteps

@onready var look_at = get_node(look_at_path) as Node3D
@onready var state = get_node(state_container_path) as StateContainer

var _last_pos := Vector3.ZERO


func _process(delta):
	_process_flip_h()
	_process_state()


func _process_flip_h():
	var dx = look_at.global_transform.origin.x - parent.global_transform.origin.x
	sprite.flip_h = dx > 0


func _process_state():
	var current_pos = sprite.global_transform.origin

	if _last_pos.distance_to(current_pos) > Constants.EPSILON:
		state.flags.add("walk")
		if not sfx_footsteps.playing:
			sfx_footsteps.play()
	else:
		state.flags.remove("walk")
		sfx_footsteps.stop()

	_last_pos = current_pos
