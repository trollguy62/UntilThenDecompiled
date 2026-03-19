extends PanelContainer

signal pressed

func _ready():
	gui_input.connect(_on_gui_input)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)

func _on_gui_input(event):
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed)\
		or (event.is_action_pressed("interact")):
		pressed.emit()

func _on_focus_entered():
	modulate = Color(0.9, 0.9, 0.9, 1.0)

func _on_focus_exited():
	modulate = Color.WHITE
