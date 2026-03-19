extends Area2D

signal pressed
signal released

var is_mouse_entered := false
var is_mouse_pressed := false


func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _input(ev):
	if ev is InputEventMouseButton:
		if ev.button_index == MOUSE_BUTTON_LEFT:
			if ev.pressed and is_mouse_entered:
				is_mouse_pressed = true
				pressed.emit()
				get_viewport().set_input_as_handled()
			elif is_mouse_pressed:
				is_mouse_pressed = false
				released.emit()


func _on_mouse_entered():
	is_mouse_entered = true


func _on_mouse_exited():
	is_mouse_entered = false
