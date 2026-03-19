extends Node
class_name SceneManager

signal shot_changed(shot: String)

const FADE_TO_DUR = 0.5

const Substory = preload("res://data/story/Substory.gd")
const Dialogue = preload("res://data/story/Dialogue.gd")
const Conversation = preload("res://data/story/Conversation.gd")
const Command = preload("res://data/Command.gd")
const Set = preload("res://data/Set.gd")
const Fader = preload("res://components/Fader/Fader.gd")

@export var scene_id: String:
	get: return scene_id
@export var shot: String:
	set = change_shot

@export var resource_store := {}  # Dictionary<String, Resource>

@onready var fader: Fader = Service.of("Fader")

var scene: Substory:
	get: return scene

var _flips := Set.new()


func _enter_tree():
	Story.add_command_handler(_run_command)


func _ready():
	Store.load_for_scene(scene_id)


func _exit_tree():
	Store.save_for_scene(scene_id)
	Story.remove_command_handler(_run_command)


func start():
	scene = Story.substory_from_id(scene_id)
	assert(scene != null)

	change_shot(shot)
	_start_substory()


func start_short(knot: String, tags: Dictionary = {}):
	var id = "%s.%s" % [scene_id, knot]
	await Story.start_short(id)


func _start_substory():
	while not scene.is_done():
		scene.advance()
		await _proc_current()


func _proc_current():
	var current = scene.current
	if current is Command:
		await scene.run_command(current)


func change_shot(shot_name):
	shot = shot_name
	shot_changed.emit(shot)


func _go_if(on: bool, name: String):
	var go = on == _flips.has(name)
	if go:
		return await Utils.wait(0)

	while not go:
		await _flips.changed
		go = on == _flips.has(name)


func start_skit(id: String) -> SkitContainer:
	var skit_container = Index.get_with("SkitContainer", id)

	if skit_container is SkitContainer:
		skit_container.start()
		return skit_container
	else:
		return null


func _has_skit_id(node: Node, id: String) -> bool:
	return node is SkitContainer and node.id == id


func get_stored_resource_path(key: String) -> String:
	if not resource_store.has(key):
		return ""

	var res = resource_store[key] as Resource
	return res.resource_path


func _run_command(cmd: Command):
	var params = cmd.params
	var flags = cmd.flags

	match cmd.name:
		"start":
			var id = params[0]
			var substory = Story.substory_from_id(id)
			var start = func(): await substory.start()

			if flags.has("wait"):
				await start.call()
			else:
				start.call()
		"start_short":
			var knot = params[0]
			var tags = cmd.tags
			var start = func(): await start_short(knot, tags)

			if flags.has("no-wait"):
				start.call()
			else:
				await start.call()
		"to":
			var shot = params[0]
			change_shot(shot)
		"fade_in":
			if params.size() >= 1:
				var duration = params[0]
				await fader.fade_in(duration)
			else:
				await fader.fade_in()
		"fade_out":
			if params.size() >= 1:
				var duration = params[0]
				await fader.fade_out(duration)
			else:
				await fader.fade_out()
		"fade_to":
			var shot = params[0]
			await fader.fade_between(func(): change_shot(shot))
		"turn_on":
			_flips.add(params[0])
		"turn_off":
			_flips.remove(params[0])
		"is_on":
			return _flips.has(params[0])
		"go_if_on":
			await _go_if(true, params[0])
		"go_if_off":
			await _go_if(false, params[0])
		"start_skit":
			var skit = start_skit(params[0])
			var wait = flags.has("wait")

			if wait and skit != null:
				await skit.skit_finished
		_:
			return Constants.CMD_RETURN_NONE

	return null
