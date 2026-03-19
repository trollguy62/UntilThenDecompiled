extends "res://components/Skit/SkitContainer.gd"

const Fader = preload("res://components/Fader/Fader.gd")

@onready var fader: Fader = Service.of("Fader")


func _ready():
	super._ready()
	Story.emitted.connect(_on_story_emitted)


func _on_story_emitted(name: String, value):
	if not is_running:
		return

	match name:
		"game_balloons":
			_start_game("game_balloons")
		"game_cups":
			_start_game("game_cups")
		"game_coin_toss":
			_start_game("game_coin_toss")


func _start_game(name: String):
	await Utils.wait(0.5)
	await fader.fade_out()

	var dialogue = Story.substory_from_id("3.2a." + name)
	dialogue.start()
	await dialogue.finished

	await Story.start_short("3.2a.after_game")
