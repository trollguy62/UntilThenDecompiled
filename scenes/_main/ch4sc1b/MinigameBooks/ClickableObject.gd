extends "res://components/ClickableArea2D.gd"

signal requested_start_short(short_knot)

@export var short_knot := ""
@export var enabled := true:
	set = _set_enabled,
	get = _get_enabled


func _ready():
	super._ready()
	pressed.connect(_on_pressed)


func _process(delta):
	if is_mouse_entered and enabled:
		_update_cursor_shape()


func _on_mouse_entered():
	super._on_mouse_entered()
	_update_cursor_shape()


func _on_mouse_exited():
	super._on_mouse_exited()
	_update_cursor_shape()


func _on_pressed():
	if enabled and short_knot != "":
		requested_start_short.emit(short_knot)


func _update_cursor_shape():
	var shape = Input.CURSOR_POINTING_HAND if is_mouse_entered and enabled else Input.CURSOR_ARROW
	Input.set_default_cursor_shape(shape)


func _set_enabled(value: bool):
	enabled = value
	_update_cursor_shape()


func _get_enabled() -> bool:
	return enabled
