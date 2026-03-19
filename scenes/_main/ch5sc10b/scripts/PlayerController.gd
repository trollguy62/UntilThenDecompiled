extends Node

const DEFAULT_MOVE_SPEED = 1.0
const INPUT_THRESHOLD = 0.5

@export var move_speed = DEFAULT_MOVE_SPEED
@export var flip_h = false

@export var clamp_global_x := false
@export var min_global_x := 0.0
@export var max_global_x := 0.0

@onready var parent = get_parent()
@onready var sprite = $"../Sprite"
@onready var focus = $Focus
@onready var footsteps = $Footsteps
@onready var state_container = Utils.get_state_container_of(sprite.alias) as StateContainer


func _process(delta):
	var play_footsteps = false

	if sprite.is_visible_in_tree() and focus.active:
		var speed = 0

		var axis_x = Input.get_axis("move_left", "move_right")
		if abs(axis_x) > INPUT_THRESHOLD:
			speed = int(sign(axis_x)) * move_speed

		var moving = abs(speed) > 0

		if moving:
			var old_pos = parent.global_position
			var new_pos = parent.transform.translated_local(Vector3.RIGHT * speed * delta).origin

			if clamp_global_x:
				new_pos.x = clamp(new_pos.x, min_global_x, max_global_x)

			moving = old_pos.distance_to(new_pos) >= Constants.EPSILON
			parent.global_position = new_pos

		play_footsteps = moving

		if moving:
			sprite.flip_h = speed > 0
			state_container.dict.set_value("with", "walk")
		else:
			state_container.dict.set_value("with", "X")

	if play_footsteps:
		if not footsteps.playing:
			footsteps.play()
	else:
		footsteps.stop()
