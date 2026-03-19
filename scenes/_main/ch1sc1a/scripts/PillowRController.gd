extends Node3D

@onready var scene_state = Service.of("SceneState") as StateContainer


func _ready():
	scene_state.changed.connect(_on_scene_state_changed)
	_update_visibility()


func _on_scene_state_changed():
	_update_visibility()


func _update_visibility():
	visible = not scene_state.dict.get_value("hide_pillow_r", false)
