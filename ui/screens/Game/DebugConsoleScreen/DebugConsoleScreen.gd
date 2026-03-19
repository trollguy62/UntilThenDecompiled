extends CanvasLayer

const CMD_LOG_COLOR = Color("#888")
const FREE_CAM_NAME = "__FreeLookCam__"

const FreeLookCam = preload("res://components/FreeLookCam/FreeLookCam.tscn")
const CONSOLE_HISTORY_PATH = "user://console_history.txt"

@onready var ui = $UI
@onready var cmd_logs = $UI/CommandLogs/Logs
@onready var cmd_lt = $UI/CommandTextEdit

var raw_cmd_buffer := []  # Array<String>
var last_buffer_idx = 0
var buffer_idx = -1
var max_cmd_history = 512


func _ready():
	if not Utils.is_debug():
		queue_free()
		return

	ui.visible = false
	cmd_lt.text_entered.connect(_process_command)
	load_console_history()


func _exit_tree():
	save_console_history()


func _input(ev):
	if not Utils.is_debug():
		return

	if Input.is_action_just_pressed("debug_mode"):
		_toggle_paused()
		cmd_lt.grab_focus()
		cmd_lt.call_deferred("clear")

	if cmd_lt.has_focus() and Input.is_key_pressed(KEY_ALT):
		var pressed_up = Input.is_action_just_pressed("ui_up")
		var pressed_down = Input.is_action_just_pressed("ui_down")
		if pressed_up or pressed_down:
			_cycle_cmd_buffer(pressed_up)


func _cycle_cmd_buffer(up: bool):
	var new_buffer_idx = -1

	if buffer_idx < 0:
		new_buffer_idx = last_buffer_idx - (0 if up else 1)
	elif up and raw_cmd_buffer.size() == 1:
		new_buffer_idx = 0
	else:
		new_buffer_idx = buffer_idx + (1 if up else -1)

	var raw = Utils.array_get(raw_cmd_buffer, new_buffer_idx)
	if raw != null:
		buffer_idx = new_buffer_idx
		cmd_lt.set_command_text(raw.c_unescape())
		await get_tree().process_frame


func _toggle_paused():
	if not Utils.is_debug():
		return

	var root = Utils.get_root_scene()

	var can_show = Game.is_pausable()

	if can_show and root is Scene and root.pausable:
		Game.paused = not Game.paused
		ui.visible = Game.paused

		cmd_lt.grab_focus()
		cmd_lt.call_deferred("clear")

	elif ui.visible:
		ui.visible = false
		Game.paused = not Game.paused


func _print(text: String, color: Color = Color.WHITE):
	cmd_logs.push_color(color)
	cmd_logs.append_text(text + "\n")
	cmd_logs.pop()
	cmd_logs.scroll_to_line(cmd_logs.get_line_count() - 1)


func _process_command(rawArray: PackedStringArray):
	var raw = rawArray[rawArray.size() - 1]
	var raw_tags: PackedStringArray

	if raw.is_empty():
		_toggle_paused()
		return

	var delim: String = "\n"
	_print(delim.join(rawArray), CMD_LOG_COLOR)
	_append_cmd_buffer(delim.c_escape().join(rawArray))

	var is_story_cmd = raw.begins_with("$")
	if not is_story_cmd:
		raw = "$ " + raw

	for line in rawArray:
		if line.begins_with("#") and ":" in line:
			raw_tags.append(line)

	var tags = Story.parse_tags(raw_tags) if not raw_tags.is_empty() else {}
	var cmd = Command.new(raw, tags)
	var success = false

	if is_story_cmd:
		var result = await _process_story_command(cmd)

		success = typeof(result) != TYPE_OBJECT or result != Constants.CMD_RETURN_NONE

		if success:
			_print("Return value: " + str(result))
	else:
		success = _process_debug_command(cmd) != Constants.CMD_RETURN_NONE

	if not success:
		_print("Unknown command", Color.RED)


func _append_cmd_buffer(raw: String):
	var can_append = raw_cmd_buffer.is_empty() or raw != raw_cmd_buffer.front()

	if can_append:
		if raw == Utils.array_get(raw_cmd_buffer, buffer_idx):
			last_buffer_idx = buffer_idx + 1
		else:
			last_buffer_idx = 0

		if raw_cmd_buffer.size() >= max_cmd_history:
			raw_cmd_buffer.pop_back()

		raw_cmd_buffer.push_front(raw)
	else:
		last_buffer_idx = buffer_idx

	buffer_idx = -1


func _reset_cmd_buffer():
	raw_cmd_buffer.clear()
	last_buffer_idx = 0
	buffer_idx = -1


func _process_story_command(cmd: Command):
	# TODO: No way of specifying context/scope at the moment, just global
	return await Story.run_command(cmd)


func _process_debug_command(cmd: Command):
	var p = []
	for i in range(3):
		p.append(Utils.array_get(cmd.params, i))

	match cmd.name:
		"fc":
			if p[0] == "on":
				_turn_on_freecam()
			elif p[0] == "off":
				_turn_off_freecam()
			else:
				_print("Param0 must be 'on' or 'off'", Color.RED)
			return null

		"set", "get":
			if p[0] == "config":
				_setget_config(cmd.name == "set", p[1], p[2])
				return null

		"reset_buffer":
			_reset_cmd_buffer()
			_print("Command buffer reset")
			return null

		"clear":
			cmd_logs.clear()
			return null

		"lock_scene":
			if Game.savegame.lock_scene(p[0]):
				Game.save_savegame()
				_print("Scene locked")
			else:
				_print("Invalid scene key", Color.RED)
			return null

		"unlock_scene":
			if Game.savegame.unlock_scene(p[0]):
				Game.save_savegame()
				_print("Scene unlocked")
			else:
				_print("Invalid scene key", Color.RED)
			return null

		"lock_scenes":
			Game.savegame.lock_all_scenes()
			Game.save_savegame()
			_print("All scenes locked")
			return null

		"unlock_scenes":
			Game.savegame.unlock_all_scenes()
			Game.save_savegame()
			_print("All scenes unlocked")
			return null

	return Constants.CMD_RETURN_NONE


func _turn_on_freecam():
	var free_cam := _get_free_cam()
	var current_cam := CameraManager.current_camera

	if is_instance_valid(current_cam):
		free_cam.sync_with(current_cam)

	CameraManager.override_camera = free_cam
	_print("Free cam turned ON")


func _turn_off_freecam():
	CameraManager.override_camera = null
	_print("Free cam turned OFF")


func _get_free_cam() -> Camera3D:
	# Freecam is lazily added to the root scene instead of being permanently added
	# to the debug console, primarily to avoid having to turn freecam off manually
	# when we switch between scenes
	var root = Utils.get_root_scene()

	if not root.has_node(FREE_CAM_NAME):
		var free_cam = FreeLookCam.instantiate()
		free_cam.name = FREE_CAM_NAME
		root.add_child(free_cam)

	return root.get_node(FREE_CAM_NAME)


func _setget_config(set: bool, prop, value):
	if not prop in Game.config:
		_print("Invalid config property", Color.RED)
	elif not set:
		_print(str(Game.config[prop]))
	else:
		if typeof(value) == typeof(Game.config[prop]):
			Game.config[prop] = value
			Game.save_config()
			_print("config.%s = %s" % [prop, value])
		else:
			_print("Invalid value type", Color.RED)


func save_console_history():
	if Utils.is_debug():
		var file = FileAccess.open(CONSOLE_HISTORY_PATH, FileAccess.WRITE)
		for line in raw_cmd_buffer:
			file.store_line(line)
		file.close()


func load_console_history():
	if Utils.is_debug():
		var file = FileAccess.open(CONSOLE_HISTORY_PATH, FileAccess.WRITE_READ)
		if FileAccess.get_open_error() == OK:
			while not file.eof_reached():
				raw_cmd_buffer.append(file.get_line())
		file.close()
