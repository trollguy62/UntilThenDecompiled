extends Control

@onready var binoculars = get_parent()
@onready var focus = $Focus
@onready var input_blocker = $InputBlocker



func _process(delta):
	input_blocker.visible = not focus.active

	if binoculars.visible != focus.active:
		if binoculars.visible:
			focus.push()
		else:
			focus.pop()

func _unhandled_input(event):
	if (event.is_action_pressed("k_interact") or event.is_action_pressed("c_cancel")) and focus.active:
		Story.emit("exit_binoculars")
