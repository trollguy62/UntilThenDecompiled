extends Node

@onready var minigame = get_parent()
@onready var focus = $Focus
@onready var scene_manager = Service.of("SceneManager") as SceneManager


func _ready():
	minigame.visible = false
	scene_manager.shot_changed.connect(_on_shot_changed)
	minigame.game_finished.connect(_on_game_finished)


func _on_game_finished():
	Story.emit("game_finished")

func _on_shot_changed(shot: String):
	var is_visible = shot == "MinigameWhackAMole"
	minigame.visible = is_visible

	if is_visible:
		minigame.start_game()
		focus.push()
	else:
		focus.pop()
