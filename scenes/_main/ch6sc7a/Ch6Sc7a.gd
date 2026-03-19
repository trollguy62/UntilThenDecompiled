extends Scene

@onready var minigame_jeepney = $Main/MinigameJeepney


func _ready():
	super._ready()
	Story.emitted.connect(_on_story_emitted)
	minigame_jeepney.game_finished.connect(_on_minigame_jeepney_finished)


func _on_story_emitted(name: String, value):
	match name:
		"start_minigame_jeepney":
			minigame_jeepney.start()


func _on_minigame_jeepney_finished():
	Story.emit("minigame_jeepney_finished")
