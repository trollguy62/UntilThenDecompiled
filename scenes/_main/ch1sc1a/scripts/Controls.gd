extends HBoxContainer

@onready var tween = Threen.new()

var _active = false
var _pressed_move_right = false
var _pressed_interact = false

@onready var move_keys = $MoveKeys
@onready var move_hint = $MoveHint


func _enter_tree():
	visible = false


func _ready():
	add_child(tween)

	ControllerIcons.input_type_changed.connect(_on_input_type_changed)
	_update_move_hint(ControllerIcons._last_input_type == ControllerIcons.InputType.CONTROLLER)


func _process(_delta):
	if _active:
		if Input.is_action_pressed("move_right"):
			_pressed_move_right = true
		if Input.is_action_pressed("interact"):
			_pressed_interact = true


func _start():
	if _active:
		return

	_active = true
	_fade(true)

	while not (_pressed_move_right and _pressed_interact):
		await get_tree().process_frame

	await _fade(false)
	_active = false
	_pressed_move_right = false
	_pressed_interact = false


func _fade(into: bool):
	var c = [Color.TRANSPARENT, Color.WHITE]
	if not into:
		c.reverse()
	else:
		visible = true

	tween.interpolate_property(self, "modulate", c[0], c[1], 0.33)
	tween.start()
	await tween.tween_completed

	if not into:
		visible = false


func _update_move_hint(joy_connected: bool):
	(move_keys if joy_connected else move_hint).hide()
	(move_hint if joy_connected else move_keys).show()


func _on_input_type_changed(input_type: ControllerIcons.InputType):
	_update_move_hint(input_type == ControllerIcons.InputType.CONTROLLER)
