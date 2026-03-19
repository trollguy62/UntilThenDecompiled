@tool
extends Node

var _perf_t = 0.0

var t = 0.0


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta):
	t += delta

	if Engine.is_editor_hint():
		return

	_process_time_scale()


func _process_time_scale():
	var time_scale = 1.0

	if Utils.is_debug() and Game.config.enable_time_scale_controls \
			and not is_instance_valid(RecordReplay):
		if Input.is_action_pressed("time_very_slow"):
			time_scale = Game.config.time_scale_very_slow
		elif Input.is_action_pressed("time_slow"):
			time_scale = Game.config.time_scale_slow
		elif Input.is_action_pressed("time_fast"):
			time_scale = Game.config.time_scale_fast
		elif Input.is_action_pressed("time_very_fast"):
			time_scale = Game.config.time_scale_very_fast

	Engine.time_scale = time_scale


func set_process_input_rec(node: Node, enable: bool):
	node.set_process_input(enable)
	for child in node.get_children():
		set_process_input_rec(child, enable)


func read_json_file(path: String) -> Dictionary:
	var json = FileAccess.get_file_as_string(path)
	var json_parser = JSON.new()
	if json_parser.parse(json) == OK:
		return Dictionary(json_parser.data)
	else:
		return {}


func wait(dur: float, pause_mode_process: bool = false):
	await Engine.get_main_loop().create_timer(dur, pause_mode_process).timeout


func wait_frames(frame_count: int = 1):
	if frame_count <= 0:
		await wait(0)
	for _i in range(frame_count):
		await get_tree().process_frame


func count_char(s: String, ch: String) -> int:
	var r = 0
	for c in s:
		if c == ch:
			r += 1
	return r


func equals(a, b) -> bool:
	var type = typeof(a)
	if type != typeof(b):
		return false

	match type:
		TYPE_FLOAT:
			return abs(a - b) < Constants.EPSILON
		TYPE_VECTOR2:
			return equals(a.x, b.x) and equals(a.y, b.y)
		TYPE_VECTOR3:
			return equals(a.x, b.x) and equals(a.y, b.y) and equals(a.z, b.z)
		TYPE_COLOR:
			return equals(a.r, b.r) and equals(a.g, b.g) and equals(a.b, b.b) and equals(a.a, b.a)

	return false


func sin_bounded(x: float, a: float, b: float = 0, t: float = 1) -> float:
	var n = (b - a) / 2
	return (n * sin(t * x)) + n + a


func spring(x: float, start: float, damping: float, frequency: float) -> float:
	damping = clamp(damping, 0.001, 0.999)
	return (start * pow(1 - damping, x)) * cos(frequency * x)


func stylize_bbcode_urls(bbcode_text: String, start: String, end: String):
	bbcode_text = bbcode_text.replace("[url", start + "[url")
	bbcode_text = bbcode_text.replace("[/url]", "[/url]" + end)
	return bbcode_text


func make_empty_panel_container() -> PanelContainer:
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	return panel


func pluralize(count: int, noun: String, irreg_plural: String = "") -> String:
	if not irreg_plural.is_empty():
		return noun if count == 1 else irreg_plural
	else:
		return noun + ("" if count == 1 else "s")


# Source: https://godotengine.org/qa/18559/how-to-add-commas-to-an-integer-or-float-in-gdscript
func commaify_int(n: int) -> String:
	var sn = str(n)
	var mod = sn.length() % 3
	var res = ""

	for i in range(0, sn.length()):
		if i != 0 && i % 3 == mod:
			res += ","
		res += sn[i]

	return res


func cover_aspect_size(i: Vector2, s: Vector2) -> Vector2:
	var ri = i.x / i.y
	var rs = s.x / s.y
	if rs > ri:
		return Vector2(i.x * (s.y / i.y), s.y)
	else:
		return Vector2(s.x, i.y * (s.x / i.x))


func is_left_click(ev: InputEvent) -> bool:
	return ev is InputEventMouseButton and not ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT


# Consider Index (res://Index.gd) instead of this if you simply need to
# lookup by class name and primary key (e.g., name, alias, ID)
func search_node(is_valid: Callable, node: Node = null):
	if node == null:
		node = get_tree().get_root()

	if is_valid.call(node):
		return node

	for child in node.get_children():
		var result = search_node(is_valid, child)
		if result != null:
			return result


func get_child_of_type(parent: Node, type: String):
	for child in parent.get_children():
		if get_custom_class_of(child) == type:
			return child


func traverse_descendants(node: Node, fn: Callable):
	fn.call(node)

	for child in node.get_children():
		traverse_descendants(child, fn)


func search_descendants(node: Node, is_valid: Callable, result: Array):
	if is_valid.call(node):
		result.append(node)
	for child in node.get_children():
		search_descendants(child, is_valid, result)


func get_descendants_of_type(node: Node, type: String, result: Array):
	if get_custom_class_of(node) == type:
		result.append(node)

	for child in node.get_children():
		get_descendants_of_type(child, type, result)


func get_custom_class_of(object: Object):
	if "get_custom_class" in object:
		return object.get_custom_class()
	else:
		return object.get_class()


func get_state_container_of(alias: String):
	return Index.get_with("StateContainer", alias)


func get_root_scene() -> Scene:
	for child in get_tree().root.get_children():
		if child is Scene:
			return child
	return null


func has_root_scene() -> bool:
	return get_root_scene() != null


func array_get(arr: Array, i: int, default = null):
	if i >= 0 and i < arr.size():
		return arr[i]
	else:
		return default

# This is different to the built-in `remap` in two ways:
# 1. Value parameter goes last, not first.
# 2. This clamps. Built-in does not.
func remap(x0: float, x1: float, y0: float, y1: float, t: float) -> float:
	return lerp(y0, y1, clamp(inverse_lerp(x0, x1, t), 0, 1))


func dir_exists(path: String) -> bool:
	return DirAccess.dir_exists_absolute(path)


func file_exists(path: String) -> bool:
	return ResourceLoader.exists(path) or FileAccess.file_exists(path)


func remove_dir_recursive(path: String):
	var dirs = dirs_in_dir(path)
	var files = files_in_dir(path)

	for file in files:
		var file_path = "%s/%s" % [path, file]
		DirAccess.remove_absolute(path)

	for dir in dirs:
		var dir_path = "%s/%s" % [path, dir]
		remove_dir_recursive(dir_path)

	DirAccess.open(path).remove(path)


func _list_dir(path: String, with_files: bool, with_dirs: bool) -> Array:
	var dir := DirAccess.open(path)
	if dir == null:
		return []
	dir.include_hidden = true
	dir.include_navigational = false
	dir.list_dir_begin()
	var res = []

	while true:
		var file: String = dir.get_next()
		if file == "":
			break

		if is_external_build():
			file = file.trim_suffix(".import")

		var file_path = "%s/%s" % [path, file]

		if with_dirs and dir_exists(file_path):
			res.append(file)
		elif with_files and file_exists(file_path):
			res.append(file)

	return res


func files_in_dir(path: String, prefix_filter: String = "", suffix_filter: String = "") -> Array:
	var list = _list_dir(path, true, false)
	var files = []

	for e in list:
		var right_prefix = prefix_filter == "" or e.begins_with(prefix_filter)
		var right_suffix = suffix_filter == "" or e.ends_with(suffix_filter)
		if right_prefix and right_suffix:
			files.append(e)

	return files


func dirs_in_dir(path: String) -> Array:
	return _list_dir(path, false, true)


func is_mouse_on_control(control: Control) -> bool:
	if not control.is_visible_in_tree():
		return false

	var rect = control.get_global_rect()
	var pos = control.get_global_mouse_position()
	return rect.has_point(pos)


func refresh_locale():
	TranslationServer.set_locale.call_deferred(TranslationServer.get_locale())


func get_locale_lang_code(locale: String) -> String:
	if "_" in locale:
		return locale.substr(0, locale.find("_"))
	return locale


func get_best_available_locale_from_os() -> String:
	var os_loc = OS.get_locale()
	var locales = Constants.LOCALES

	if os_loc in locales:
		return os_loc

	var lang_code = get_locale_lang_code(os_loc)
	if lang_code in locales:
		return lang_code

	for locale in locales:
		if lang_code == get_locale_lang_code(locale):
			return locale

	return Constants.DEFAULT_LOCALE


func is_external_build() -> bool:
	return OS.has_feature("template")


func is_internal_debug() -> bool:
	return is_debug() and not is_external_build()


func is_debug() -> bool:
	return OS.is_debug_build()


func has_feature(tag_name: String) -> bool:
	return (
		OS.has_feature(tag_name)
		or (is_internal_debug() and Game.debug_user_config.features.has(tag_name)))


func get_perf_delta() -> float:
	var t0 = _perf_t
	var t1 = Time.get_ticks_msec() / 1000.0
	_perf_t = t1
	return t1 - t0


func randomize():
	if not is_debug():
		randomize()


func parse_file_size(bytes: int, decimal_places: int = 2, separator: String = " ") -> String:
	assert(bytes >= 0)
	assert(decimal_places >= 0)

	var prefixes = ["", "K", "M", "G", "T", "P"]
	var prefix = ""
	var units = 1

	for i in range(prefixes.size()):
		if bytes < pow(1000, i + 1):
			prefix = prefixes[i]
			units = float(bytes) / pow(1000, i)
			break

	return ("%." + str(decimal_places) + "f%s%sB") % [units, separator, prefix]


func replace_edges(text: String, key: String, to: String) -> String:
	var left: int = 0
	var right: int = 1

	while text[left] == key:
		text[left] = to
		left += 1

	while text[-right] == key:
		text[-right] = to
		right += 1

	return text


func shader_has_parameter(shader: Shader, parameter_name: String) -> bool:
	for uniform in shader.get_shader_uniform_list():
		if uniform.name == parameter_name:
			return true
	return false


func is_skip_text_pressed() -> bool:
	return Input.is_action_pressed("skip_text") and Game.ng_plus
