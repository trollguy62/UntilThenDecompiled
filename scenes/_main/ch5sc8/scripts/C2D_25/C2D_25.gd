extends Node2D

@onready var focus = $Focus
@onready var interactives = $Interactives


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
