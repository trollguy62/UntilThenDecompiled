extends Node

var _databases := {}
var _original_databases := {}

var _last_loaded_scene_id := ""

@onready var _json_utils = JsonUtils.new()


func _ready():
	Game.config.locale_changed.connect(reload)
	_load_all(Game.config.locale)


func _load_all(lang: String = "en"):
	_read_db("state", "state", lang)
	_read_db("fb", "fb", lang)
	_read_db("https", "web", lang)
	_read_db("email", "email", lang)
	_read_db("tlt", "the_liamson_times", lang)
	_read_db("ma", "minds_alike", lang)
	_read_db("geddit", "geddit", lang)
	_read_db("text", "text", lang)


func reload(lang: String = "en"):
	_original_databases.clear()
	_load_all(lang)


func _read_db(key: String, name: String, lang: String = "en"):
	if not key in _original_databases:
		var path = get_localized_db_path(name, lang)
		_original_databases[key] = Utils.read_json_file(path)

	var db = _original_databases[key]
	_databases[key] = db.duplicate(true)


func get_localized_db_path(name: String, lang: String = "en") -> String:
	var fallback_path = "res://assets/databases/%s.json" % name

	if Utils.is_debug():
		var dyn_path = "user://loc/databases/%s_%s.json" % [name, lang]
		if FileAccess.file_exists(dyn_path):
			return dyn_path

	if lang != "en":
		var localized_path = "res://assets/databases/%s_%s.json" % [name, lang]
		if FileAccess.file_exists(localized_path):
			return localized_path

	return fallback_path


func _get_dirs(path: String) -> Array:
	var res = Constants.REGEX_STORE_PATH.search(path)
	if res == null:
		return []

	var dirs = res.strings[2].split("/")
	dirs.insert(0, res.strings[1])
	return dirs


func get_value(path: String):
	var dirs = _get_dirs(path)
	var obj = _databases

	for dir in dirs:
		if obj is Dictionary and obj.has(dir):
			obj = obj.get(dir)
		else:
			return

	return obj


func get_serialized(path: String, schema):
	var json = get(path)
	if json == null:
		return null

	return schema.new("", json)


func set_value(path: String, value):
	var dirs = _get_dirs(path)
	# You can't set the value of an entire database like set("https://", true)
	if dirs.size() < 2:
		return

	var db_key = dirs[0]
	var obj = _databases[db_key]

	if obj == null:
		return

	for i in range(1, dirs.size()):
		var dir = dirs[i]
		var is_last_dir = i == dirs.size() - 1

		if is_last_dir:
			obj[dir] = value
			break

		var next_obj = obj.get(dir)

		if not (next_obj is Dictionary):
			next_obj = {}
			obj[dir] = next_obj

		obj = next_obj


func get_config(db_key: String, key: String, default = null):
	var db = _databases[db_key]
	return db.get("$" + key, default)


func set_config(db_key: String, key: String, value):
	var db = _databases[db_key]
	db["$" + key] = value


func save_for_scene(scene_id: String):
	if Game.record_replay_is_active():
		return # Eliminate some indeterminism. Keep databases untouched.

	assert(scene_id != "")

	var diffs := {}

	for db_key in _databases.keys():
		var diff = _get_db_diff(db_key)
		if diff:
			diffs[db_key] = diff

	if diffs.is_empty():
		return

	var dir_path = "user://store/%s" % scene_id
	var dir = DirAccess.make_dir_recursive_absolute(dir_path)

	for db_key in diffs.keys():
		var file_path = "%s/%s.json" % [dir_path, db_key]
		var file = FileAccess.open(file_path, FileAccess.WRITE)
		var diff_json = JSON.stringify(diffs[db_key])

		file.store_string(diff_json)
		file.close()

	_last_loaded_scene_id = scene_id


func _get_db_diff(db_key):
	var diff = _json_utils.diff(_original_databases[db_key], _databases[db_key])

	var p = diff["p"] as Array
	return null if p.is_empty() else diff


func load_for_scene(scene_id: String):
	if Game.record_replay_is_active():
		return # Eliminate some indeterminism. Keep databases untouched.

	var saved_scene_ids: Array = Utils.dirs_in_dir("user://store")
	var load_scene_id = ""
	saved_scene_ids.sort()

	for id in saved_scene_ids:
		if id < scene_id:
			#printerr("id: ", id, "--", "scene_id: ", scene_id)
			load_scene_id = id
		else:
			break

	for id in saved_scene_ids:
		if id > load_scene_id or load_scene_id == "":
			Utils.remove_dir_recursive("user://store/%s" % id)

	if load_scene_id == _last_loaded_scene_id:
		return
	_last_loaded_scene_id = load_scene_id

	if load_scene_id == "":
		_load_all(Game.config.locale)
		return

	var diff_path = "user://store/%s" % load_scene_id

	while not _read_diffs(diff_path):
		var idx = saved_scene_ids.bsearch(load_scene_id)
		var prev_idx = idx - 1

		if prev_idx < 0:
			print("No store diffs loaded. Loading defaults...")
			_load_all(Game.config.locale)
			return

		load_scene_id = saved_scene_ids[prev_idx]
		diff_path = "user://store/%s" % load_scene_id
	
	print("Loaded store diffs from " + load_scene_id)


func _read_diffs(path):
	var diff_files = Utils.files_in_dir(path, "", ".json")

	for diff_file in diff_files:
		var db_key = diff_file.trim_suffix(".json")
		var diff_file_path = "%s/%s" % [path, diff_file]
		if Utils.read_json_file(diff_file_path) == {}:
			#something went wrong
			printerr("ERROR: Store diff file (%s) read failed." % diff_file_path)
			return false
		#printerr("loading ", diff_file_path)
		_patch_db(db_key, diff_file_path)

	return true


func _patch_db(db_key, diff_file_path):
	var diff = Utils.read_json_file(diff_file_path)
	var orig_db = _original_databases[db_key]
	_databases[db_key] = _json_utils.patch(orig_db, diff)
