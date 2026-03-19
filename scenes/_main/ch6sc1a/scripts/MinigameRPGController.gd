extends Node

@export var start_btn: Button

@onready var minigame_rpg = get_parent()


func _ready():
	Story.emitted.connect(_on_story_emitted)
	minigame_rpg.game_finished.connect(_on_minigame_rpg_finished)
	start_btn.pressed.connect(minigame_rpg.mash)


func _on_story_emitted(name: String, value):
	match name:
		"start_minigame_rpg":
			#minigame_rpg.start()
			print("start")


func _on_minigame_rpg_finished():
	Story.emit("minigame_rpg_finished")
