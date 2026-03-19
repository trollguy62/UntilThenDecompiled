extends Node

@onready var minigame_platformer = get_parent()


func _ready():
	Story.emitted.connect(_on_story_emitted)
	minigame_platformer.game_finished.connect(_on_minigame_platformer_finished)


func _on_story_emitted(name: String, value):
	match name:
		"start_minigame_platformer":
			minigame_platformer.play(true)
		"end_minigame_platformer":
			minigame_platformer.play(false)


func _on_minigame_platformer_finished():
	Story.emit("minigame_platformer_finished")
