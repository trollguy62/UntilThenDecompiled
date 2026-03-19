extends Resource
class_name DebugUserConfig

@export var main_scene: PackedScene
@export var ignore_main_scene := false
@export var continue_immediately := false

@export var features: Array[String]


func get_main_scene():
	if not ignore_main_scene:
		return main_scene
