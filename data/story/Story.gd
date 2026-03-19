extends Node

enum ForkMode { None, NewState }

signal emitted(name: String, value)

const Set = preload("res://data/Set.gd")
const Character = preload("res://data/Character.gd")
const Command = preload("res://data/Command.gd")
const CommandRunner = preload("res://components/CommandRunner.gd")

const Conversation = preload("res://data/story/Conversation.gd")
const Dialogue = preload("res://data/story/Dialogue.gd")
const Substory = preload("res://data/story/Substory.gd")
const SubstoryContext = preload("res://data/story/SubstoryContext.gd")

var characters: Dictionary

var context: SubstoryContext = GlobalSubstoryContext.new():
	get: return context

var _ink_stories := {} # Dictionary<String, InkStory>

var _cmd_runner := CommandRunner.new()
var _external_functions := StoryExternalFunctions.new()


func _init():
	add_command_handler(internal_command_handler)


func _ready():
	_load_characters()


func _load_characters():
	var db_path = Store.get_localized_db_path("characters", Game.config.locale)
	characters = Utils.read_json_file(db_path)

	for key in characters:
		var character = Character.new(characters[key])
		characters[key] = character


func clear_cache():
	_ink_stories.clear()


func substory_from_id(id: String, context: SubstoryContext = null, fork_mode: ForkMode = ForkMode.None):
	var runner := _create_ink_runner(id, fork_mode)
	var header = parse_tags(runner.get_global_tags())

	match header.type:
		"chat":
			var conversation = Conversation.new(id, runner, header, context)
			return conversation
		"dialogue":
			return Dialogue.new(id, runner, header, context)
		_:
			return Substory.new(id, runner, header, context)


func _create_ink_runner(id: String, fork_mode: ForkMode = ForkMode.None) -> InkRunner:
	var story: InkStory = _ink_stories.get(id)

	if story == null:
		var file = _get_story_inkb_file(id)
		story = InkStory.open(file)
		assert(story != null)
		_ink_stories[id] = story

	var runner := InkRunner.from_ink_story(story, fork_mode == ForkMode.NewState)
	_external_functions.bind(runner)

	return runner


func _get_possible_inkb_rel_paths(id: String) -> Array[String]:
	assert(id.length() > 0)

	var p = id + ".inkb"
	var paths: Array[String] = [p]
	var last_i = p.rfind(".")

	while true:
		var i = p.find(".")
		if i < 0:
			break

		if i == last_i: # last occurrence
			p = p.replace(".", "/_main.")
		else:
			p[i] = "/"

		paths.append(p)

		if i == last_i:
			break

	return paths


func _get_story_inkb_file(id: String) -> FileAccess:
	var rel_paths: Array[String] = _get_possible_inkb_rel_paths(id)
	var locale = Game.config.locale

	var find_file = func(prefix: String = "") -> FileAccess:
		for rel_path in rel_paths:
			var abs_path = Constants.BASE_STORY_DIR_PATH + "/" + prefix + rel_path

			if Utils.is_debug():
				var dyn_path = "user://loc/story/" + prefix + rel_path
				if Utils.file_exists(dyn_path):
					print(dyn_path)
					return FileAccess.open(dyn_path, FileAccess.READ)

			if Utils.file_exists(abs_path):
				print(abs_path)
				return FileAccess.open(abs_path, FileAccess.READ)

		return

	if locale != Constants.DEFAULT_LOCALE:
		var file = find_file.call("locales/" + locale +"/")
		if file != null:
			return file

	var file = find_file.call()
	if file != null:
		return file

	assert(false, ".inkb file of id '%s' not found" % id)
	return


# 1.1.$, Knot "hello" has id of: 1.1.hello
func short_from_id(id: String, context: SubstoryContext = null) -> Substory:
	var delimIdx = id.rfind(".")
	assert(delimIdx > 0)

	var substory_id = id.substr(0, delimIdx) + ".$"
	var knot = id.substr(delimIdx + 1)

	var temp_runner = _create_ink_runner(substory_id, ForkMode.NewState)
	var header = parse_tags(temp_runner.get_global_tags())
	var knot_tags = temp_runner.get_tags_at_path(knot)
	var local_header = parse_tags(knot_tags)

	for key in local_header.keys():
		var value = local_header[key]
		header[key] = value

	var fork = header.get("fork", "")
	var fork_mode = ForkMode.None

	if fork == "new_state":
		fork_mode = ForkMode.NewState

	var runner := _create_ink_runner(substory_id, fork_mode)
	runner.move_to_path(knot)

	match header.type:
		"chat":
			return Conversation.new(id, runner, header, context)
		"dialogue":
			return Dialogue.new(id, runner, header, context)

	assert(false, "Unknown short header type")
	return


func start_short(id: String, context: SubstoryContext = null):
	var short_substory = short_from_id(id, context)
	if short_substory:
		short_substory.start()
		await short_substory.finished


func emit(name: String, value = null):
	await Utils.wait(0)
	emitted.emit(name, value)


func wait_for(name: String, value = null):
	while true:
		var c = await emitted
		if c[0] == name and (value == null or c[1] == value):
			return c[1]


func parse_tags(raw_tags: Array) -> Dictionary:
	var tags = {}
	var json = JSON.new()

	for tag in raw_tags:
		assert(tag is String)

		var result = Constants.REGEX_SUBSTORY_TAG.search(tag)
		var key = result.strings[1]
		var raw_value = result.strings[2]

		var err = json.parse(raw_value)
		assert(err == OK)
		tags[key] = json.data

	return tags


func add_command_handler(handler: Callable):
	_cmd_runner.register_handler(handler)


func remove_command_handler(handler: Callable):
	_cmd_runner.unregister_handler(handler)


func run_command(cmd: Command):
	return await _cmd_runner.run(cmd)


func internal_command_handler(cmd: Command):
	var params = cmd.params
	var flags = cmd.flags

	match cmd.name:
		"pass":
			pass
		"wait":
			var dur = params[0]
			if dur is float or dur is int:
				await Utils.wait(dur)
		"debug", "print":
			print(params[0])
		"emit":
			var value = null
			if params.size() >= 2:
				value = params[1]

			emit(params[0], value)
		"wait_for":
			if params.size() >= 2:
				await wait_for(params[0], params[1])
			else:
				return await wait_for(params[0])
		"change_scene":
			var path = params[0]
			var no_load_screen = flags.has("no-load-screen")

			if Game.scene_directory.scene_exists(path):
				Game.to_scene_key(path, cmd.tags, no_load_screen)
			else:
				Game.change_scene(path, cmd.tags)
		"next_scene":
			var no_load_screen = flags.has("no-load-screen")
			Game.to_next_scene(cmd.tags, no_load_screen)
		"go_to_main_menu":
			Game.go_to_main_menu()
		"quit_game":
			get_tree().quit()
		"set_time":
			Game.time = params[0]
		"unlock_ach":
			Game.dist_platform.unlock_achievement(params[0])
		"record_replay_pause":
			Game.record_replay_pause()
		"record_replay_resume":
			Game.record_replay_resume()
		_:
			return Constants.CMD_RETURN_NONE

	return null


class StoryExternalFunctions:
	const FUNC_PREFIX = "__"

	func bind(runner: InkRunner):
		for method in get_method_list():
			if not method.name.begins_with(FUNC_PREFIX):
				continue

			var func_name = method.name.trim_prefix(FUNC_PREFIX)
			var meta_key_bound = _meta_key_bound_of(func_name)
			var is_bound = runner.has_meta(meta_key_bound) and runner.get_meta(meta_key_bound)

			if not is_bound:
				runner.bind_external_function(func_name, Callable(self, method.name))
				runner.set_meta(meta_key_bound, true)

	func _meta_key_bound_of(func_name: String) -> String:
		return "bound_ext_func_" + func_name

	func __is_fb_post_liked(id: String) -> bool:
		return Store.get_value("fb://posts/%s/liked" % id) == true

	func __is_fb_post_shared(id: String) -> bool:
		return Store.get_value("fb://posts/%s/shared" % id) == true

	func __has_fb_comment(post_id: String, comment_id: String) -> bool:
		return Store.get_value("fb://posts/%s/comments/%s/choice_mode" % [post_id, comment_id]) == 0

	func __is_fb_comment_liked(post_id: String, comment_id: String) -> bool:
		return Store.get_value("fb://posts/%s/comments/%s/liked" % [post_id, comment_id]) == true

	func __has_fb_comment_reply(post_id: String, comment_id: String, reply_id: String) -> bool:
		return (
			Store.get_value(
				"fb://posts/%s/comments/%s/replies/%s/choice_mode" % [post_id, comment_id, reply_id]
			)
			== 0
		)

	func __is_fb_comment_reply_liked(post_id: String, comment_id: String, reply_id: String) -> bool:
		return (
			Store.get_value(
				"fb://posts/%s/comments/%s/replies/%s/liked" % [post_id, comment_id, reply_id]
			)
			== true
		)

	func __get_res_path(key: String) -> String:
		var scene_manager: SceneManager = Service.of("SceneManager")
		return scene_manager.get_stored_resource_path(key)

	func __has_var(path: String) -> bool:
		return Store.get_value(_state_path(path)) != null

	func __set_bool(path: String, value: bool) -> bool:
		Store.set_value(_state_path(path), value)
		return true

	func __get_bool(path: String, default: bool) -> bool:
		var value = Store.get_value(_state_path(path))
		return value if value != null else default

	func __set_int(path: String, value: int) -> bool:
		Store.set_value(_state_path(path), value)
		return true

	func __get_int(path: String, default: int) -> int:
		var value = Store.get_value(_state_path(path))
		return value if value != null else default

	func _state_path(path: String) -> String:
		return "state://%s" % path


class GlobalSubstoryContext:
	extends "SubstoryContext.gd"


	func run_command(cmd: Command):
		return await Story.run_command(cmd)


	func get_speech_bubble_pivot(alias: String, require_visible: bool = true) -> Node:
		var predicate = _is_visible_in_tree if require_visible else null
		return Index.get_with("SpeechBubblePivot", alias, predicate)


	func _is_visible_in_tree(node: Node) -> bool:
		return node.is_visible_in_tree()
