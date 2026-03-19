extends Node

const PlayerTarget = preload("res://components/PlayerTarget.gd")

@export var move_speed := 1.0

@onready var path_grounder = $"../PathGrounder"
@onready var sprite = $"../Sprite"
@onready var sprite_controller = $"../SpriteController"
@onready var focus = $Focus
@onready var sfx_footsteps = $Footsteps

@onready var player_target = Service.of("PlayerTarget") as PlayerTarget

var _was_active := false


func _ready():
	player_target.changed.connect(_on_player_target_changed)
	path_grounder.target_reached.connect(_on_path_grounder_target_reached)


func _is_active() -> bool:
	return focus.active and sprite.is_visible_in_tree()


func _process(delta):
	var active = _is_active()

	if not active:
		if _was_active:
			sprite.animation = sprite_controller.get_animation()

		path_grounder.offset_speed = 0
		sfx_footsteps.stop()
	else:
		if not path_grounder.has_target():
			if Input.is_action_pressed("move_left"):
				path_grounder.offset_speed = -move_speed
			elif Input.is_action_pressed("move_right"):
				path_grounder.offset_speed = move_speed
			else:
				path_grounder.offset_speed = 0.0

		var d_offset = path_grounder.delta_offset

		if abs(d_offset) > 0:
			sprite.flip_h = d_offset > 0
			sprite.animation = "walk"
			if not sfx_footsteps.playing:
				sfx_footsteps.play()
		else:
			sprite.animation = "default_idle"
			sfx_footsteps.stop()

	_was_active = active


func _on_player_target_changed():
	var pos = player_target.global_transform.origin
	path_grounder.set_target_pos(pos, move_speed)


func _on_path_grounder_target_reached():
	Story.emit("_player_target_reached")
