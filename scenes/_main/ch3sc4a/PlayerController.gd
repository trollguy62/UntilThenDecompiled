extends Node

const PlayerTarget = preload("res://components/PlayerTarget.gd")

const DEFAULT_MOVE_SPEED = 1.0
const INPUT_THRESHOLD = 0.5

@export var anim_idle := "default_idle"
@export var anim_walk := "walk"

@onready var sprite_controller = $"../SpriteController"
@onready var sprite = $"../Sprite"
@onready var grounder = $"../PathGrounder"
@onready var focus = $Focus
@onready var footsteps = $Footsteps

@onready var player_target = Service.of("PlayerTarget") as PlayerTarget

var speed = DEFAULT_MOVE_SPEED


func _ready():
	player_target.changed.connect(_on_player_target_changed)
	grounder.target_reached.connect(_on_path_grounder_target_reached)


func _process(delta):
	grounder.offset_speed = 0

	var animation = anim_idle
	var play_footsteps = false

	if _is_active() and not grounder.has_target():
		var axis_x = Input.get_axis("move_left", "move_right")

		if abs(axis_x) > INPUT_THRESHOLD:
			grounder.offset_speed = int(sign(axis_x)) * speed

	elif not focus.active:
		animation = sprite_controller.get_animation()

	if abs(grounder.delta_offset) > 0:
		animation = anim_walk
		play_footsteps = true
		sprite.flip_h = grounder.delta_offset < 0

	sprite.animation = animation

	if play_footsteps:
		if not footsteps.playing:
			footsteps.play()
	else:
		footsteps.stop()


func _is_active() -> bool:
	return focus.active and sprite.is_visible_in_tree()


func _on_player_target_changed():
	if sprite.is_visible_in_tree():
		var pos = player_target.global_transform.origin
		grounder.set_target_pos(pos, speed)


func _on_path_grounder_target_reached():
	Story.emit("_player_target_reached")
