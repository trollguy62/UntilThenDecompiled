extends Node2D

signal finished

@export var enabled = false:
	set(v):
		if not is_inside_tree():
			await ready
		enabled = v
		for clickable in clickable_objects:
			clickable.enabled = v

func _ready():
	visibility_changed.connect(_on_visibility_changed)

func _process(delta):
	if not visible:
		return

	for interactive in interactives.get_children():
		if "enabled" in interactive:
			interactive.enabled = focus.active


func _on_visibility_changed():
	if visible != focus.active:
		if visible:
			focus.push()
		else:
			focus.pop()
