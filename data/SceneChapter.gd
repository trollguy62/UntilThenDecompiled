extends RefCounted

var name: String = ""
var scenes: Array = []  #Array of scene keys
var playthrough: int = -1


func _init(ch_name_: String, scenes_: Array, playthrough_: int):
	name = ch_name_
	scenes = scenes_
	playthrough = playthrough_


func get_initial_scene():
	return scenes.front()
