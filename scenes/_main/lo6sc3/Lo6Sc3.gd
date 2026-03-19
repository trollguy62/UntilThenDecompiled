extends Scene

@onready var minigame_focus = $Main/MinigameFocus3D

func _ready():
	super._ready()
	Story.emitted.connect(_on_story_emit)
	minigame_focus.target_clarity_reached.connect(_on_focus_cleared)

func _on_story_emit(emit: String, value):
	match emit:
		"minigame_focus_start":
			minigame_focus.start(value)

func _on_focus_cleared():
	Story.emit("minigame_focus_cleared")
