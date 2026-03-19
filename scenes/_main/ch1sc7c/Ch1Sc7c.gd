extends Scene

@onready var minigame_fishball = $Main/MinigameFishball


func _ready():
	super._ready()
	Story.emitted.connect(_on_story_emitted)
	minigame_fishball.game_finished.connect(_on_minigame_fishball_finished)


func _on_story_emitted(name: String, value):
	match name:
		"start_minigame_fishball":
			minigame_fishball.start()


func _on_minigame_fishball_finished():
	Story.emit("minigame_fishball_finished")
