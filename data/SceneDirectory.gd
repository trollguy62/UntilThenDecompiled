extends RefCounted

signal directory_changed

const SceneChapter = preload("res://data/SceneChapter.gd")
const SceneInfo = preload("res://data/SceneInfo.gd")

#consider normalizing the og json so we can simplify implementation
var _scene_db: Dictionary = {}  # "key": SceneInfo
var chapters: Array = []  # Array of Scenechapters


func _init(dict: Dictionary = {}):
	_read_from_dict(dict)


func _read_from_dict(dict: Dictionary):
	if dict.is_empty():
		return

	for key in dict["paths"]:
		_scene_db[key] = SceneInfo.new()
		_scene_db[key].path = dict["paths"][key]

	for i in dict["chapters"].size():
		var chapter = dict["chapters"][i]
		var scenes = []
		var playthrough = int(chapter.get("playthrough", 1))

		for j in chapter["scenes"].size():
			var s = chapter["scenes"][j]  # "1.1a":"SCENEDIR_CH1_SC1A"
			scenes.append(s.key)

			if s.key in _scene_db:
				var scene_info = _scene_db[s.key]
				scene_info.chapter_index = i
				scene_info.scene_index = j
				scene_info.name = s.get("name", "")
				scene_info.playthrough = playthrough

		var sc = SceneChapter.new(chapter.name, scenes, playthrough)
		chapters.append(sc)

	directory_changed.emit()


func get_scene_keys() -> Array:
	return _scene_db.keys()


func get_scene_path(key: String):
	if key in _scene_db:
		return _scene_db[key].path

	printerr("Key %s not found in scene directory!" % key)
	return ""


func get_scene_info(key: String) -> SceneInfo:
	return _scene_db[key]


func is_from_different_chapters(key1: String, key2: String) -> bool:
	return (
		scene_exists(key1)
		and scene_exists(key2)
		and get_scene_info(key1).chapter_index != get_scene_info(key2).chapter_index
	)


func get_next_scene_key_of(key: String):
	if !(key in _scene_db):
		printerr("Key %s does not exist in scene directory!" % key)
		return ""

	if _scene_db[key].chapter_index < 0:
		printerr("Key %s is an orphan, there is no next scene", key)
		return ""

	#key exists and is in a chapter somewhere
	var scene_info: SceneInfo = _scene_db[key]
	var ch_idx: int = scene_info.chapter_index
	var sc_idx: int = scene_info.scene_index

	var scene_list: Array = chapters[ch_idx].scenes

	if scene_list[sc_idx]:
		sc_idx += 1
		if sc_idx < scene_list.size() && sc_idx >= 0:
			return chapters[ch_idx].scenes[sc_idx]

		else:
			ch_idx += 1
			if ch_idx >= chapters.size():
				print("Reached end of chapter list")
				return ""
			else:
				return chapters[ch_idx].get_initial_scene()

	#it's in the db but not in the chapter list and somehow not an orphan
	printerr("Could not retrieve scene from chapter list")
	return ""


func get_chapter_name(chapter_index: int) -> String:
	if chapter_index >= 0 && chapter_index < chapters.size():
		return chapters[chapter_index].name

	printerr("Chapter index out of range: ", chapter_index)
	return ""


func scene_exists(key: String):
	return key in _scene_db
