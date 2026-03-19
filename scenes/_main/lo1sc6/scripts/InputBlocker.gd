extends Control


func _ready():
	visible = false
	Story.emitted.connect(_on_story_emitted)

func _on_story_emitted(name: String, value):
	match name:
		"enable_input":
			visible = not value
