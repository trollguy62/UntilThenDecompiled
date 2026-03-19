extends Node
class_name Scene

const Fader = preload("res://components/Fader/Fader.tscn")

@export var pausable := true
@export_range(0.0, 16.0) var fade_in_duration = 1.0
@export_range(0.0, 16.0) var fade_out_duration = 1.0
@export_range(0.0, 16.0) var fade_in_delay = 1.0
@export var auto_fade_in := true
@export var auto_fade_out := true
@export var detached := false

@onready var scene_manager: SceneManager = Service.of("SceneManager")
@onready var key: String = Game.get_scene_param("scene_key", "")

var fader := Fader.instantiate()


func _enter_tree():
	if detached:
		return

	add_child(fader)
	# TODO hacky, if only you can pause specific parts of SceneTree...
	AudioServer.set_bus_mute(Constants.BUS_IDX_SFX, true)


func _ready():
	if detached:
		return

	# "$ next_scene" doesn't work in launching scenes (F6) from the editor
	# so we provide the scene key here in such case
	if Utils.is_internal_debug() and key == "" and scene_manager:
		key = scene_manager.scene_id

	if Utils.is_debug():
		print("Entered scene: ", key)
		StatsMonitor.set_scene_id_label(key)

	AudioServer.set_bus_mute(Constants.BUS_IDX_SFX, false)

	await _cache_visible_shaders()

	if auto_fade_in:
		_fade_in()

	if scene_manager:
		scene_manager.start()


func exit_scene():
	if detached:
		return

	if auto_fade_out:
		await _fade_out()

# Async shader compilation doesn't seem to be out yet, but this will do for now
func _cache_visible_shaders():
	var camera = Camera3D.new()
	add_child(camera)

	camera.global_rotation_degrees = Vector3(-28, 28, 0)
	camera.translate_object_local(Vector3.BACK * 500.0)
	camera.current = true

	await Utils.wait_frames(2)
	camera.queue_free()


func _fade_in():
	await Utils.wait(fade_in_delay)
	Story.emit("_scene_fading_in")
	await fader.fade_in(fade_in_duration)
	Story.emit("_scene_faded_in")


func _fade_out():
	await fader.fade_out(fade_out_duration)


func emit_story_signal(name: String):
	Story.emit(name)


func stop_audio_players():
	AudioUtils.stop_all_players(self)
