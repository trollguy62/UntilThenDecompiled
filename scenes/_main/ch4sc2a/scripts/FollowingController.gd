extends Node

const AnchorPathFollower = preload("res://scenes/_main/ch4sc2a/scripts/AnchorPathFollower.gd")
const PlayerTargetPosition = preload("res://components/PlayerTargetPosition.gd")

@onready var parent = get_parent()
@onready var sprite = $"../Sprite"
@onready var sprite_controller = $"../SpriteController"
@onready var follower = $"../AnchorPathFollower" as AnchorPathFollower
@onready var sfx_footsteps = $Footsteps

@onready var state_container = Utils.get_state_container_of(sprite_controller.state_container_alias) as StateContainer

@onready var look_at = get_node(follower.anchor_path)

var _last_pos := Vector3.ZERO


func _ready():
	state_container.dict.changed.connect(_state_dict_changed)


func _process(delta):
	if not sprite.is_visible_in_tree():
		sfx_footsteps.stop()
		return

	var path_mode = follower.path_mode

	if not path_mode:
		var dx = look_at.global_transform.origin.x - parent.global_transform.origin.x
		sprite.flip_h = dx > 0

	var current_pos = sprite.global_transform.origin
	var is_walking = _last_pos.distance_to(current_pos) > Constants.EPSILON

	if is_walking:
		state_container.flags.add("$walk")

		if not sfx_footsteps.playing:
			sfx_footsteps.play()

		if path_mode:
			var dx = current_pos.x - _last_pos.x
			sprite.flip_h = dx > 0
	else:
		state_container.flags.remove("$walk")
		sfx_footsteps.stop()

	_last_pos = current_pos


func _state_dict_changed(key: String, old_value, value):
	match key:
		"path_mode":
			follower.path_mode = value
		"path_target":
			var target = Index.get_with("PlayerTargetPosition", value)
			if target is PlayerTargetPosition:
				follower.set_path_target(target.global_transform.origin)
