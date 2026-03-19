extends Node3D
class_name SkitContainer

signal skit_started
signal skit_finished
signal emitted(name, value)

const Command = preload("res://data/Command.gd")
const CommandRunner = preload("res://components/CommandRunner.gd")
const Substory = preload("res://data/story/Substory.gd")
const SkitSubstoryContext = preload("res://components/Skit/SkitSubstoryContext.gd")

@export var id = ""
@export var entrypoint = ""

@export var sync_visibility := true
@export var allow_global_access := false:
	set(value):
		_context.allow_global_access = value
	get:
		return _context.allow_global_access

@export var free_on_finish := false
@export var sync_process_mode := true

@onready var _scene_manager = Service.of("SceneManager")
@onready var _scene_state = Service.of("SceneState")
@onready var _thought_bubble = Service.of("ThoughtBubble")
@onready var _screen_navigator = Service.of("ScreenNavigator")
@onready var _dialogue_handler = Service.of("DialogueHandler")
@onready var _chat_handler = Service.of("ChatHandler")
@onready var _presenter = Service.of("Presenter")
@onready var _rhythm_service = Service.of("RhythmService")
@onready var _rain_controller = Service.of("RainController")
@onready var _scene_globals = [
	FocusManager,
	_scene_manager,
	_scene_state,
	_thought_bubble,
	_screen_navigator,
	_dialogue_handler,
	_chat_handler,
	_presenter,
	_rhythm_service,
	_rain_controller
]

@onready var _root_2d: CanvasItem = get_node_or_null("Root2D")

var _substory: Substory
var _cmd_runner := CommandRunner.new()
var _speech_bubble_pivots := []
var _context := SkitSubstoryContext.new(_cmd_runner, _speech_bubble_pivots)

var is_running: bool:
	get: return is_running
	set(value):
		is_running = value

		if sync_process_mode:
			process_mode = Node.PROCESS_MODE_INHERIT if is_running else Node.PROCESS_MODE_DISABLED

		_sync_visibility()


func _ready():
	assert(not is_running)
	assert(_scene_manager)

	Utils.traverse_descendants(self, _register_node)
	child_entered_tree.connect(_register_node)

	if _root_2d:
		assert(_root_2d is CanvasItem)

	self.is_running = false


func get_custom_class() -> String:
	return "SkitContainer"


func start():
	if is_running:
		print("Tried to start skit '%s' but is already running" % id)
		return

	self.is_running = true
	skit_started.emit()
	print("Skit '%s' started" % id)

	_init_register_nodes()
	await _init_substory()
	print("Skit '%s' finished" % id)

	skit_finished.emit()
	self.is_running = false

	if free_on_finish:
		queue_free()


func _sync_visibility():
	if not sync_visibility:
		return

	if visible and not is_running:
		# Before hiding, delay next frame, same time as the next skit
		# This avoids seeing a single frame of "nothing" in between skits
		await get_tree().process_frame

	visible = is_running
	if _root_2d:
		_root_2d.visible = is_running


func _init_substory():
	_substory = Story.substory_from_id(entrypoint, _context, Story.ForkMode.NewState)
	assert(_substory.get_custom_class() == "Substory")

	await get_tree().process_frame

	while not _substory.is_done():
		_substory.advance()

		var current = _substory.current
		var proc = null
		# Order of command handling:
		# 1. Substory internal command runner
		# 2. Skit command runner (in here)
		# 3. Story-level command runner, if global access allowed, otherwise just
		#    its local handler (Story._story_command_handler)
		if current is Command:
			proc = await _substory.run_command(current)


func _init_register_nodes():
	Utils.traverse_descendants(self, _register_node)

	for node in _scene_globals:
		if node != null:
			_register_node(node)


func _register_node(node: Node):
	var n = node

	if node is SkitExternalRef:
		n = node.get_ref()

	if is_running:
		_try_register_command_handler(n)
		_try_add_speech_bubble_pivot(n)

		if not node is SkitExternalRef:
			_try_call_skit_start(n)
	else:
		if not node is SkitExternalRef:
			_try_call_skit_ready(n)

	if node is SkitExternalRef:
		for r in node.get_extra_refs():
			_register_node(r)


func _try_register_command_handler(node: Node):
	if node.has_method("_run_command"):
		_cmd_runner.register_handler(node._run_command)


func _try_add_speech_bubble_pivot(node: Node):
	if Utils.get_custom_class_of(node) == "SpeechBubblePivot":
		_speech_bubble_pivots.append(node)


func _try_call_skit_start(node: Node):
	if node.has_method("_skit_start"):
		node._skit_start(self)


func _try_call_skit_ready(node: Node):
	if node.has_method("_skit_ready"):
		node._skit_ready(self)


func _run_command(cmd: Command):
	var params = cmd.params
	var flags = cmd.flags
	var tags = cmd.tags

	match cmd.name:
		"start":
			var id = params[0]
			var wait = flags.has("wait")
			var global = flags.has("global")
			var use_cache = tags.get("use_cache", true)

			var context = Story.context if global else _context
			var fork_mode = Story.ForkMode.None if use_cache else Story.ForkMode.NewState
			var start = func(): await Story.substory_from_id(id, context, fork_mode).start()

			if wait:
				await start.call()
			else:
				start.call()
		"start_short":
			var start = func(): await start_short(params[0])
			if not flags.has("no-wait"):
				await start.call()
			else:
				start.call()
		"emit_local":
			var value = null
			if params.size() >= 2:
				value = params[1]

			emit_local(params[0], value)
		"wait_for_local":
			if params.size() >= 2:
				await wait_for_local(params[0], params[1])
			else:
				return await wait_for_local(params[0])
		_:
			return Constants.CMD_RETURN_NONE


func emit_local(name: String, value = null):
	emitted.emit(name, value)


func wait_for_local(name: String, value = null):
	while true:
		var c = await emitted
		if c[0] == name and (value == null or c[1] == value):
			return c[1]


func start_short(knot: String):
	var id = "%s.%s" % [_scene_manager.scene_id, knot]
	await Story.start_short(id, _context)
