extends Node

const PlayerTarget = preload("res://components/PlayerTarget.gd")

const DEFAULT_MOVE_SPEED = 1.0
const INPUT_THRESHOLD = 0.5

@export var anim_idle := "default_idle"
@export var anim_walk := "walk"
@export var flip_h := false
@export var use_expression := false
@export var speed := DEFAULT_MOVE_SPEED

@onready var sprite_controller = $"../SpriteController"
@onready var sprite = $"../Sprite"
@onready var grounder = $"../PathGrounder"
@onready var collider = $"../Area/CollisionShape" as CollisionShape3D

@onready var focus = $Focus
@onready var footsteps = $Footsteps

@onready var player_target: PlayerTarget = Service.of("PlayerTarget")


func _ready():
	if player_target != null:
		player_target.changed.connect(_on_player_target_changed)

	grounder.target_reached.connect(_on_path_grounder_target_reached)


func _process(delta):
	grounder.offset_speed = 0
	collider.disabled = not _is_active()

	var animation = _get_anim_idle()
	var play_footsteps = false

	if _is_active() and not grounder.has_target():
		var axis_x = Input.get_axis("move_left", "move_right")

		if abs(axis_x) > INPUT_THRESHOLD:
			grounder.offset_speed = int(sign(axis_x)) * speed

	elif not focus.active:
		animation = sprite_controller.get_animation()

	if abs(grounder.delta_offset) > 0:
		animation = _get_anim_walk()
		play_footsteps = true
		sprite.flip_h = grounder.delta_offset > 0

		if flip_h:
			sprite.flip_h = not sprite.flip_h

	sprite.animation = animation

	if play_footsteps:
		if not footsteps.playing:
			footsteps.play()
	else:
		footsteps.stop()


func _is_active() -> bool:
	return focus.active and sprite.is_visible_in_tree()


func _get_anim_idle() -> String:
	if use_expression:
		return sprite_controller.get_animation()
	else:
		return anim_idle


func _get_anim_walk() -> String:
	if use_expression:
		var supposed_anim: String = sprite_controller.get_animation()
		supposed_anim = supposed_anim.trim_suffix("_idle")
		supposed_anim = supposed_anim.trim_suffix("_talk")

		var anim_walk_candidate = supposed_anim + "_walk"

		if anim_walk_candidate in sprite_controller.standalone_anims:
			return anim_walk_candidate

	return anim_walk


func _on_player_target_changed():
	if sprite.is_visible_in_tree():
		var pos = player_target.global_transform.origin
		grounder.set_target_pos(pos, speed)


func _on_path_grounder_target_reached():
	Story.emit("_player_target_reached")
