extends Node

const AnchorFollower = preload("res://scenes/lms/ch1sc7/scripts/AnchorFollower.gd")

@export var enabled = true

@onready var parent = get_parent()
@onready var sprite = $"../Sprite"
@onready var sprite_controller = $"../Sprite/SpriteController"
@onready var anchor_follower = $"../AnchorFollower" as AnchorFollower
@onready var sfx_footsteps = $Footsteps

@onready var look_at = get_node(anchor_follower.anchor_path)
@onready var state_container = Utils.get_state_container_of(sprite_controller.state_container_alias) as StateContainer

var _last_pos := Vector3.ZERO


func _process(_delta):
	if enabled:
		_process_flip_h()
		_process_state()


func _process_flip_h():
	var dist = parent.global_transform.origin - look_at.global_transform.origin
	sprite.flip_h = look_at.global_transform.basis.x.dot(dist) < 0


func _process_state():
	var current_pos = sprite.global_transform.origin
	var is_walking = _last_pos.distance_to(current_pos) > Constants.EPSILON

	if is_walking:
		if not sfx_footsteps.playing:
			sfx_footsteps.play()
	else:
		sfx_footsteps.stop()

	if sprite.is_visible_in_tree():
		if is_walking:
			state_container.flags.add("$walk")
		else:
			state_container.flags.remove("$walk")

	_last_pos = current_pos
