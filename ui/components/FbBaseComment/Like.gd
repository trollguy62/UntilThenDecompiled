extends Button


func _ready():
	gui_input.connect(_on_gui_input)


func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		release_focus()
