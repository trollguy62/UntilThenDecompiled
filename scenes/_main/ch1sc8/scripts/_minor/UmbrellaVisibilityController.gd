extends Node

@onready var parent = get_parent() as Node3D
@onready var scene_state = Service.of("SceneState") as StateContainer


func _ready():
	scene_state.changed.connect(_on_scene_state_changed)
	_update_visibility()


func _on_scene_state_changed():
	_update_visibility()


func _update_visibility():
	parent.visible = not scene_state.dict.get_value("umbrella_taken", false)
