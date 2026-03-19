extends Node

@onready var minigame = get_parent()
@onready var focus = $Focus
@onready var scene_manager = Service.of("SceneManager") as SceneManager


func _ready():
	minigame.visible = false
	scene_manager.shot_changed.connect(_on_shot_changed)


func _on_shot_changed(shot: String):
	var is_visible = shot == "MinigameJeepney"
	minigame.visible = is_visible

	if is_visible:
		focus.push()
	else:
		focus.pop()
