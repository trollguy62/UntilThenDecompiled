extends Control

signal pressed
signal hovered
signal unhovered
signal mouse_down
signal mouse_up

@export var clickable := true:
	set(value):
		clickable = value
		mouse_filter = Control.MOUSE_FILTER_STOP if value else Control.MOUSE_FILTER_IGNORE
	get:
		return clickable

@export var disable_focus_on_controller = false

var _hovered = false


func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	focus_mode = FOCUS_CLICK if disable_focus_on_controller else FOCUS_ALL
	self.clickable = clickable


func _gui_input(ev):
	if ev.is_action("interact") or (ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT and _hovered):# and has_focus():
		if ev.pressed:
			mouse_down.emit()
		else:
			mouse_up.emit()
			pressed.emit()


func _on_mouse_entered():
	_hovered = true
	hovered.emit()


func _on_mouse_exited():
	_hovered = false
	unhovered.emit()
