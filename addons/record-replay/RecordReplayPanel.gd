@tool
extends Control

enum SceneOperation { OPEN, RUN, RECORD_REPLAY }

@onready var scene_list = $HBox/VBox/SceneList
@onready var refresh_btn = $HBox/VBox/HBox/Refresh
@onready var recording_list = $HBox/VBox2/RecordingList
@onready var new_recording_btn = $HBox/VBox2/HBox/NewRecording
@onready var del_recording_btn = $HBox/VBox2/HBox/DeleteRecording

@onready var name_edit = $HBox/VBox3/HBoxContainer2/Name
@onready var name_mkb_btn = $HBox/VBox3/HBoxContainer2/MouseKeyboard
@onready var name_gamepad_btn = $HBox/VBox3/HBoxContainer2/Gamepad
@onready var name_save_btn = $HBox/VBox3/HBoxContainer2/SaveName

@onready var open_scene_btn = $HBox/VBox3/HBoxContainer/OpenScene
@onready var run_scene_btn = $HBox/VBox3/HBoxContainer/RunScene
@onready var record_replay_btn = $HBox/VBox3/HBoxContainer/RecordReplay
@onready var inspect_btn = $HBox/VBox3/HBoxContainer/Inspect

@onready var duration_label = $HBox/VBox3/Duration
@onready var input_events_label = $HBox/VBox3/InputEvents
@onready var manual_count_label = $HBox/VBox3/ManualCount

@onready var blocker = $Blocker

var editor_interface: EditorInterface
var scene_id_to_path := {} # Dictionary<String (scene ID), String ("res://...")>
var selected_scene_id := ""
var selected_recording: Recording

var last_is_playing_scene := false
var request_refresh_on_play_end := false


func _ready():
	assert(editor_interface)
	blocker.visible = false
	_populate()

	refresh_btn.pressed.connect(_populate)
	scene_list.item_selected.connect(_on_scene_list_item_selected)
	recording_list.item_selected.connect(_on_recording_list_item_selected)
	new_recording_btn.pressed.connect(_add_new_recording)
	del_recording_btn.pressed.connect(_delete_selected_recording)

	name_mkb_btn.pressed.connect(func(): name_edit.text = "Mouse and keyboard")
	name_gamepad_btn.pressed.connect(func(): name_edit.text = "Gamepad")
	name_save_btn.pressed.connect(_save_selected_recording)

	open_scene_btn.pressed.connect(_operate_on_selected_scene.bind(SceneOperation.OPEN))
	run_scene_btn.pressed.connect(_operate_on_selected_scene.bind(SceneOperation.RUN))
	record_replay_btn.pressed.connect(_operate_on_selected_scene.bind(SceneOperation.RECORD_REPLAY))

	inspect_btn.pressed.connect(func():
		if selected_recording:
			editor_interface.inspect_object(selected_recording)
	)


func _process(_delta):
	var is_playing_scene = editor_interface.is_playing_scene()
	if last_is_playing_scene == is_playing_scene:
		return

	last_is_playing_scene = is_playing_scene
	blocker.visible = is_playing_scene

	if not is_playing_scene and request_refresh_on_play_end:
		_populate()


func _populate():
	scene_id_to_path.clear()
	selected_scene_id = ""
	selected_recording = null
	_on_recording_list_item_selected(-1)

	scene_list.clear()
	recording_list.clear()

	var f = FileAccess.open("res://assets/databases/scene_directory.json", FileAccess.READ)
	var j = JSON.parse_string(f.get_as_text())

	for scene_id in j.paths.keys():
		scene_id_to_path[scene_id] = j.paths[scene_id]

	for scene_id in scene_id_to_path.keys():
		var idx = scene_list.add_item(scene_id)
		scene_list.set_item_metadata(idx, scene_id)


func _on_scene_list_item_selected(idx: int):
	_on_recording_list_item_selected(-1)
	recording_list.clear()
	selected_scene_id = ""

	var scene_id = scene_list.get_item_metadata(idx)
	selected_scene_id = scene_id

	var i = 0

	for filename in DirAccess.get_files_at(RecordReplay.SAVED_RECORDINGS_DIR):
		if not _is_valid_recording_filename(filename):
			continue

		if _extract_scene_id_from_recording_filename(filename) != scene_id:
			continue

		var recording = load(RecordReplay.SAVED_RECORDINGS_DIR + "/" + filename)
		assert(recording is Recording)

		recording_list.add_item(_get_recording_item_name(recording))
		recording_list.set_item_metadata(i, recording)
		i += 1


func _on_recording_list_item_selected(idx: int):
	selected_recording = null
	name_edit.text = ""
	duration_label.text = ""
	input_events_label.text = ""
	manual_count_label.text = ""

	if idx < 0:
		return

	selected_recording = recording_list.get_item_metadata(idx)
	assert(selected_recording is Recording)

	name_edit.text = selected_recording.name
	record_replay_btn.text = "Record" if _is_recording_draft(selected_recording) else "Replay"
	duration_label.text = _get_recording_duration_text(selected_recording)
	input_events_label.text = "Input events: %d" % selected_recording.input_event_records.size()
	manual_count_label.text = "Manual count: %d" % selected_recording.manual_count


func _add_new_recording():
	var recording = Recording.new()
	recording.name = "New recording"
	recording.resource_path = RecordReplay.SAVED_RECORDINGS_DIR + "/" + \
			_generate_recording_filename(selected_scene_id)
	ResourceSaver.save(recording)

	var idx = recording_list.item_count
	recording_list.add_item(_get_recording_item_name(recording))
	recording_list.set_item_metadata(idx, recording)
	recording_list.select(idx)
	_on_recording_list_item_selected(idx)


func _delete_selected_recording():
	assert(selected_recording is Recording)

	var window = ConfirmationDialog.new()
	window.dialog_text = "Delete recording? For real? 🤯"
	window.confirmed.connect(func():
		DirAccess.remove_absolute(selected_recording.resource_path)
		recording_list.remove_item(_get_selected_recording_idx())
		_on_recording_list_item_selected(-1)
	)

	editor_interface.popup_dialog_centered(window)


func _save_selected_recording():
	assert(selected_recording is Recording)
	selected_recording.name = name_edit.text
	ResourceSaver.save(selected_recording)
	recording_list.set_item_text(_get_selected_recording_idx(), _get_recording_item_name(selected_recording))


func _operate_on_selected_scene(oper: SceneOperation):
	request_refresh_on_play_end = false

	assert(selected_scene_id in scene_id_to_path)
	var selected_scene_path = scene_id_to_path[selected_scene_id]

	if oper == SceneOperation.OPEN:
		editor_interface.open_scene_from_path(selected_scene_path)

	elif oper == SceneOperation.RUN:
		editor_interface.play_custom_scene(selected_scene_path)

	elif oper == SceneOperation.RECORD_REPLAY and selected_recording != null:
		assert(selected_recording)

		var config = RecordReplayConfig.new()
		config.recording_path = selected_recording.resource_path

		if _is_recording_draft(selected_recording):
			config.mode = RecordReplayConfig.Mode.RECORD
			request_refresh_on_play_end = true
		else:
			config.mode = RecordReplayConfig.Mode.REPLAY

		ResourceSaver.save(config, RecordReplay.CONFIG_PATH)
		editor_interface.play_custom_scene(selected_scene_path)


func _get_selected_recording_idx() -> int:
	if selected_recording == null:
		return -1

	for i in range(recording_list.item_count):
		if recording_list.get_item_metadata(i) == selected_recording:
			return i

	return -1


# Filenames: (Scene ID)__(recording ID, 5 digits)__rec.res
# Example: 1.5a__42069__rec.res
func _is_valid_recording_filename(str: String) -> bool:
	var sp = str.split("__")
	return sp.size() == 3 and \
		sp[0] in scene_id_to_path and \
		sp[1].length() == 5 and \
		sp[2] == "rec.res"


func _generate_recording_filename(scene_id: String) -> String:
	return "%s__%s__rec.res" % [scene_id, randi_range(10_000, 99_999)]


func _extract_scene_id_from_recording_filename(str: String) -> String:
	return str.split("__")[0]


func _is_recording_draft(recording: Recording) -> bool:
	return recording == null or recording.input_event_records.is_empty()


func _get_recording_duration_text(recording: Recording) -> String:
	if _is_recording_draft(recording):
		return "(DRAFT)"

	var mins = int(recording.duration_secs) / 60
	var secs = int(recording.duration_secs) - (mins * 60)

	if mins > 0:
		return "Duration: %dm %ds" % [mins, secs]
	else:
		return "Duration: %ds" % secs


func _get_recording_item_name(recording: Recording) -> String:
	if _is_recording_draft(recording):
		return "(DRAFT) " + recording.name
	else:
		return recording.name
