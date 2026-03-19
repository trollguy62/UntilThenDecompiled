extends Node

const AnchorFollower = preload("res://scenes/lms/ch1sc7/scripts/AnchorFollower.gd")

@export var anim_walk := "walk"

@onready var parent = get_parent()
@onready var sprite = $"../Sprite"
@onready var sprite_controller = $"../SpriteController"
@onready var anchor_follower = $"../AnchorFollower" as AnchorFollower
@onready var sfx_footsteps = $Footsteps

@onready var look_at = get_node(anchor_follower.anchor_path)

var _last_pos := Vector3.ZERO


func _process(delta):
	_process_flip_h()
	_process_state()


func _process_flip_h():
	var dx = look_at.global_transform.origin.x - parent.global_transform.origin.x
	sprite.flip_h = dx > 0


func _process_state():
	var current_pos = sprite.global_transform.origin
	var is_walking = _last_pos.distance_to(current_pos) > Constants.EPSILON

	if is_walking:
		sprite.animation = anim_walk

		if not sfx_footsteps.playing:
			sfx_footsteps.play()
	else:
		sprite.animation = sprite_controller.get_animation()
		sfx_footsteps.stop()

	_last_pos = current_pos
