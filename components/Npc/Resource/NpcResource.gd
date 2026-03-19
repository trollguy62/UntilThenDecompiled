@tool
extends Resource
class_name NpcResource

@export var generate_path: String = "res://assets/characters/NpcMale/"
@export var skins: Array[Dictionary] =  [] #Array[Dictionary{Array[Texture2D]]}
@export var hairs: Array[Dictionary] = [] #Array[Dictionary{Array[Texture2D]}]
@export var bottoms: Array[Dictionary] = [] #Array[Dictionary{Array[Texture2D]}]
@export var tops: Array[Dictionary] = [] #Array[Dictionary{Array[Texture2D]}]

var _contains_resource = false

#caches the textures into this resource
@export var test_generate: bool = false:
	set(v):
		if not v: #guards against the _init call to this setter
			return
		if Engine.is_editor_hint():
			_generate()

#clears the resource
@export var clear: bool = false:
	set(v):
		if not v: #guards against the _init call to this setter
			return
		if Engine.is_editor_hint():
			_clear()


func _generate():
	#NpcMale -> bottom_01/02 -> idle b/l/walk l -> png
	if _contains_resource:
		_clear()

	var dir: DirAccess = DirAccess.open(generate_path)
	var dirs = dir.get_directories()

	read_textures(dirs, ["skin", "bottom", "top", "hair"])
	_contains_resource = true

func _clear():
	hairs = []
	skins = []
	bottoms = []
	tops = []

func read_textures(dirs, keys: Array[String]):
	for my_dir in dirs:
		for key in keys:
			if my_dir.begins_with(key):
				var variation: Dictionary = {}
				for s_dir in get_dirs(generate_path + my_dir):
					var textures = get_textures(generate_path + my_dir + "/" + s_dir)
					variation[s_dir] = textures

				get(key + "s").append(variation)
#bottoms[0]["idle"]

func get_textures(path):
	var textures = []
	var files: PackedStringArray = get_files(path)
	for file in files:
		if file.ends_with(".import"):
			continue
		textures.append(load(path + "/" + file))
	return textures

func get_files(path):
	var dir = DirAccess.open(path)
	return dir.get_files()

func get_dirs(path):
	var dir = DirAccess.open(path)
	var dirs = dir.get_directories()
	return dirs
