extends AnimatedSprite2D

const MOVE_PX = 10

@export var default: String = "idle"
@export var on_beat: String
@export var success: String
@export var fail: String
@export var sfx: AudioStream
@onready var sfx_player = $sfx


func _ready():
	animation_finished.connect(_on_animation_finished)
	if sfx:
		sfx_player.stream = sfx


func beat():
	sfx_player.play()
	if on_beat:
		set_state(on_beat)
	frame = 0


func unbeat():
	if default:
		animation = default


func _on_animation_finished():
	play(default)


func set_expr(expr: String, start_frame = 0):
	var f = frame
	var fp = frame_progress
	if animation.split("_")[0] + "_" + expr in sprite_frames.get_animation_names():
		animation = animation.split("_")[0] + "_" + expr
	else:
		animation = expr
	set_frame_and_progress(f, fp)
	play(animation)



func set_state(state: String, start_frame = 0):
	var f = frame
	var fp = frame_progress
	var anim_names = sprite_frames.get_animation_names()
	if animation.split("_").size() > 1:
		var anim = state + "_" + animation.split("_")[1]
		if anim in anim_names:
			animation = state + "_" + animation.split("_")[1]
	else:
		animation = state
	set_frame_and_progress(f, fp)
	play(animation)
