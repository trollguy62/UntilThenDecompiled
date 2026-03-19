extends Node2D

signal pressed(which)

var is_enabled = false:
	set(v):
		for c in get_children():
			c.disabled = !v

		is_enabled = v


func _ready():
	for btn in get_children():
		if btn is TextureButton:
			btn.pressed.connect(_on_button_pressed.bind(btn.name))


func _on_button_pressed(what: String):
	pressed.emit(what)
