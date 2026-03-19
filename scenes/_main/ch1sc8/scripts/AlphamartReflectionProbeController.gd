extends Node

@onready var parent = get_parent()
@onready var scene_state = Service.of("SceneState") as StateContainer


func _ready():
	scene_state.changed.connect(_on_scene_state_changed)
	_update_visilibity()


func _on_scene_state_changed():
	_update_visilibity()


func _update_visilibity():
	parent.visible = bool(scene_state.dict.get_value("alphamart_reflection_probe", false))
