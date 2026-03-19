@tool
extends Node3D

@export var enabled := true:
	set(value):
		if enabled == value:
			return

		enabled = value

		if enabled:
			_y = position.y
		else:
			position.y = _y

@export var frame_offsets: Array[int] = [0, 0, 0, 0, 0, 0]
@export var offset_multiplier: float = 0.01
@export var sprite: AnimatedPaper3D

var _y := 0.0


func _ready():
	if enabled:
		_y = position.y

	sprite.frame_changed.connect(_on_sprite_frame_changed)


func _on_sprite_frame_changed():
	if not enabled:
		return

	var frame := sprite.frame
	var offset := 0.0

	if frame >= len(frame_offsets):
		offset = frame_offsets[-1]
	else:
		offset = frame_offsets[frame]

	position.y = _y + offset * offset_multiplier


func _notification(what: int):
	if not Engine.is_editor_hint():
		return

	if enabled and what == NOTIFICATION_EDITOR_PRE_SAVE:
		position.y = _y
