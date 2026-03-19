extends Node

const DEFAULT_MOVE_SPEED = 1.0
const INPUT_THRESHOLD = 0.5

@onready var sprite_controller = $"../SpriteController"
@onready var sprite = $"../Sprite"
@onready var grounder = $"../PathGrounder"

@onready var focus = $Focus
@onready var footsteps = $Footsteps

var speed = DEFAULT_MOVE_SPEED


func _process(delta):
	grounder.offset_speed = 0

	var animation = "positive_idle"
	var play_footsteps = false

	if focus.active and not grounder.has_target():
		var axis_x = Input.get_axis("move_left", "move_right")

		if abs(axis_x) > INPUT_THRESHOLD:
			grounder.offset_speed = int(sign(axis_x)) * -speed

	elif not focus.active:
		animation = sprite_controller.get_animation()

	if grounder.delta_offset < 0:
		animation = "walk"
		sprite.flip_h = true
		play_footsteps = true
	elif grounder.delta_offset > 0:
		animation = "walk"
		sprite.flip_h = false
		play_footsteps = true

	sprite.animation = animation

	if play_footsteps:
		if not footsteps.playing:
			footsteps.play()
	else:
		footsteps.stop()
