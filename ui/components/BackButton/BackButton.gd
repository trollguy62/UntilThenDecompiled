extends "res://ui/components/Game/FocusableControl.gd"

@export var pop_nav_on_press = true

func _ready():
	pressed.connect(_on_pressed)


func press():
	_on_pressed()


func _on_pressed():
	if disabled:
		return

	if pop_nav_on_press:
		var navigator = Service.of(Service.NAVIGATOR)
		if navigator:
			navigator.pop()

func _unhandled_input(event):
	if event.is_action_pressed("d_left") and not disabled and is_visible_in_tree():
		if get_viewport().gui_get_focus_owner() == null:
			grab_focus()
