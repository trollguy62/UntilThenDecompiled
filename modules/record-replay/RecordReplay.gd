extends ColorRect

const SAVED_RECORDINGS_DIR = "res://tests/record-replay"
const CONFIG_PATH = "res://record_replay_config.tres"

const EXIT_CODE_REPLAY_WHOLE_SCENE_PASS = 88
const EXIT_CODE_REPLAY_NOT_AUTO = 99
const EXIT_CODE_REPLAY_TIMED_OUT_FAIL = 13

const GRACE_PERIOD = 4.0 # seconds to wait after recording duration before timing out and failing

@onready var manual_prompt = $ManualPrompt

var is_recording := false

var recording: Recording
var time := 0.0
var ticks_on_last_process := 0

static var instanced := false


func _enter_tree():
	assert(not instanced) # Make sure there's only one instance of this
	instanced = true

	var config = _get_config()
	if config == null:
		queue_free()
		return

	is_recording = config.mode == RecordReplayConfig.Mode.RECORD
	recording = load(config.recording_path) as Recording

	if config.replay_auto_only and not is_recording and recording.manual_count > 0:
		print("RecordReplay: Recording is not fully automatic. Exiting...")
		get_tree().quit(EXIT_CODE_REPLAY_NOT_AUTO)


func _ready():
	if is_queued_for_deletion():
		return

	manual_prompt.visible = false

	Engine.max_fps = 60
	OS.delta_smoothing = false

	# Avoids accidental overwriting if recording over a non-draft
	if recording.input_event_records.is_empty() != is_recording:
		recording = null
		assert(false)

	Game.will_change_scene.connect(_on_will_change_scene)

	if is_recording:
		print("RecordReplay: Recording!")
		get_window().title += " (RECORDING)"
		get_window().close_requested.connect(_save)

	else:
		print("RecordReplay: Replaying!")
		set_process_input(false)
		get_window().title += " (REPLAYING)"


func _get_config() -> RecordReplayConfig:
	if not Utils.is_internal_debug():
		return null

	if OS.get_name() == "Prospero":
		return null

	if not FileAccess.file_exists(CONFIG_PATH):
		return null

	if FileAccess.get_modified_time(CONFIG_PATH) < Time.get_unix_time_from_system() - 4.0:
		return null

	print("Loading the RecordReplay config!")
	return load(CONFIG_PATH) as RecordReplayConfig


func _input(ev):
	if not is_node_ready() or is_queued_for_deletion():
		return

	#var t = time + ((Time.get_ticks_msec() - ticks_on_last_process) / 1000.0)

	if ev is InputEventMouseMotion:
		var r = MousePositionRecord.new()
		r.time = time
		r.unit_position = _get_mouse_unit_pos()
		recording.mouse_position_records.append(r)
	else:
		var r = InputEventRecord.new()
		r.time = time
		r.event = ev.duplicate()
		recording.input_event_records.append(r)


func _physics_process(delta):
	if not is_node_ready() or is_queued_for_deletion():
		return

	time += delta

	if is_recording:
		var r = MousePositionRecord.new()
		r.time = time
		r.unit_position = _get_mouse_unit_pos()
		recording.mouse_position_records.append(r)
	else:
		if time >= recording.duration_secs + GRACE_PERIOD:
			printerr("RecordReplay: Replay timed out!")
			get_tree().quit(EXIT_CODE_REPLAY_TIMED_OUT_FAIL)
			return

		recording.process_records(time, delta, get_viewport().get_window().size)

	ticks_on_last_process = Time.get_ticks_msec()


func _on_will_change_scene():
	var exit_code := 0

	if not is_recording: # if replaying
		print("RecordReplay: Replay passed!")
		exit_code = EXIT_CODE_REPLAY_WHOLE_SCENE_PASS

	_save()
	get_tree().quit(exit_code)


func _save():
	if is_recording and recording != null:
		set_process_input(false)
		set_physics_process(false)

		recording.duration_secs = time
		ResourceSaver.save(recording)
		recording = null
		print("RecordReplay: Recording saved!")


func _get_mouse_unit_pos() -> Vector2:
	return get_viewport().get_mouse_position() / get_viewport_rect().size


# Do NOT call this directly. `RecordReplay` is immediately freed when not recording/replaying.
# Call `Game.record_replay_pause` instead which performs the right check.
func _pause():
	assert(not manual_prompt.visible)

	if is_recording:
		recording.manual_count += 1

	manual_prompt.visible = true
	process_mode = Node.PROCESS_MODE_DISABLED


# Do NOT call this directly. `RecordReplay` is immediately freed when not recording/replaying.
# Call `Game.record_replay_resume` instead which performs the right check.
func _resume():
	assert(manual_prompt.visible)
	manual_prompt.visible = false
	process_mode = Node.PROCESS_MODE_INHERIT
