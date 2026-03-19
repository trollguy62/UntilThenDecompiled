extends Control

signal skipped

const FADE_DURATION = 0.33

var active: bool = false:
	set(value):
		if active == value:
			return
		active = value

		if not is_inside_tree():
			return

		var tween = create_tween()
		tween.tween_property(
			self,
			"modulate",
			Color.WHITE if active else Color.TRANSPARENT,
			FADE_DURATION
		)


func _ready():
	modulate = Color.TRANSPARENT
	self.active = active


func _unhandled_input(_ev):
	if active and Input.is_action_just_pressed("skip"):
		skipped.emit()
