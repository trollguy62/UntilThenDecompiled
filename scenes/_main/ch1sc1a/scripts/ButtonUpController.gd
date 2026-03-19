extends Node

@onready var minigame_button_up = get_parent()
@onready var focus = $Focus
@onready var scene_manager = Service.of("SceneManager") as SceneManager


func _ready():
	minigame_button_up.visible = false
	scene_manager.shot_changed.connect(_on_shot_changed)
	minigame_button_up.finished.connect(_on_minigame_button_up_finished)


func _on_minigame_button_up_finished():
	Story.emit("minigame_button_up_finished")


func _on_shot_changed(shot: String):
	var is_visible = shot == "MinigameButtonUp"
	minigame_button_up.visible = is_visible

	if is_visible:
		focus.push()
		minigame_button_up.start()
	else:
		focus.pop()
