extends Node

@export var wrong_connection_short_knot := ""

@onready var scene_manager = Service.of("SceneManager") as SceneManager
@onready var minigame = get_parent()


func _ready():
	scene_manager.shot_changed.connect(_on_scene_manager_shot_changed)
	minigame.wrong_connection.connect(_on_minigame_wrong_connection)
	minigame.finished.connect(_on_minigame_finished)


func _on_scene_manager_shot_changed(shot: String):
	if shot == minigame.name:
		minigame.start()


func _on_minigame_wrong_connection():
	if wrong_connection_short_knot != "":
		var id = "%s.%s" % [scene_manager.scene_id, wrong_connection_short_knot]
		Story.start_short(id)


func _on_minigame_finished():
	Story.emit("MinigameButtonUp.finished")
