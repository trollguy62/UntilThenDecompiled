extends Control

signal skipped

@export var enabled := true

@onready var tween = Threen.new()
@onready var label = $Container/HBox/Label

var _is_ready = false
var _show_after_t = 0


func _ready():
	add_child(tween)

	modulate = Color.TRANSPARENT
	_is_ready = true


func _input(ev: InputEvent):
	if not enabled:
		return

	if (ev is InputEventKey or ev is InputEventJoypadButton) and ev.pressed:
		if Input.is_action_just_pressed("ui_cancel"):
			skipped.emit()
		else:
			_try_show()


func _try_show():
	if _show_after_t < 0 or Utils.t < _show_after_t:
		return

	_show_after_t = -1
	tween.interpolate_property(self, "modulate", Color.TRANSPARENT, Color.WHITE, 0.2)
	tween.start()
	await tween.tween_completed

	await Utils.wait(3.0)

	tween.interpolate_property(self, "modulate", Color.WHITE, Color.TRANSPARENT, 0.2)
	tween.start()
	await tween.tween_completed
	_show_after_t = Utils.t + 1.0
