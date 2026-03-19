extends Node

const PlayerTarget = preload("res://components/PlayerTarget.gd")

@onready var sprite = $"../Sprite"
@onready var sprite_controller = $"../Sprite/SpriteController"

@onready var focus = $Focus
@onready var footsteps = $Footsteps

@onready var state_container = Utils.get_state_container_of(sprite_controller.state_container_alias) as StateContainer


func _process(delta):
	var is_active = _is_active()
	var is_walking = false
	var input_move_dir = 0

	if _is_active():
		if Input.is_action_pressed("move_left"):
			input_move_dir = -1
		elif Input.is_action_pressed("move_right"):
			input_move_dir = 1

	if input_move_dir != 0:
		is_walking = true
		sprite.flip_h = input_move_dir > 0

	if footsteps:
		if is_walking and sprite.is_visible_in_tree():
			if not footsteps.playing:
				footsteps.play()
		else:
			footsteps.stop()

	if sprite.is_visible_in_tree():
		if is_walking:
			state_container.dict.set_value("with", "walk")
		else:
			state_container.dict.set_value("with", "X")


func _is_active() -> bool:
	return focus.active and sprite.is_visible_in_tree()
