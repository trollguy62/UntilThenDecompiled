extends Node2D

@onready var focus = $Focus

func _process(delta):
	if not visible:
		return

	for interactive in get_children():
		if "enabled" in interactive:
			interactive.enabled = focus.active


func _on_visibility_changed():
	if visible != focus.active:
		if visible:
			focus.push()
		else:
			focus.pop()
