extends Node

@onready var bus = get_parent()
@onready var scene_manager = Service.of("SceneManager") as SceneManager


func _ready():
	scene_manager.shot_changed.connect(_on_shot_changed)


func _on_shot_changed(shot: String):
	var use_alt_windows = shot == "CamOutside"
	if bus.use_alt_windows != use_alt_windows:
		bus.use_alt_windows = use_alt_windows
