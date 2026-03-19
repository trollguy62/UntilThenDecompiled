extends RefCounted

var name: String = ""
var path: String = ""
var chapter_index: int = -1
var scene_index: int = -1
var playthrough: int = -1


func _init(
	name_: String = "",
	path_: String = "",
	chapter_index_: int = -1,
	scene_index_: int = -1,
	playthrough_: int = -1
):
	name = name_
	path = path_
	chapter_index = chapter_index_
	scene_index = scene_index_
	playthrough = playthrough_


func is_hidden() -> bool:
	return name == ""
