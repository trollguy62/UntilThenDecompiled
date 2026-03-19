signal advanced
signal finished

const Character = preload("res://data/Character.gd")
const Command = preload("res://data/Command.gd")
const CommandRunner = preload("res://components/CommandRunner.gd")
const SubstoryContext = preload("res://data/story/SubstoryContext.gd")

var id: String:
	get: return id
var context: SubstoryContext:
	get: return context
var current:
	get: return current
var current_tags := {}:
	get: return current_tags
var choices: Array:
	get: return _runner.get_choices()
var started := false:
	get: return started
var header: Dictionary

var _runner: InkRunner
var _parsers: Array[Callable] = []  # (String) -> Any
var _cmd_runner = CommandRunner.new()

var _character_map: Dictionary
var _character_props: Dictionary

var player: Character:
	get: return player
var player_key: String:
	get: return player_key
var characters: Dictionary = {}:
	get: return characters


func _init(
	id: String,
	runner: InkRunner,
	header: Dictionary = {},
	context: SubstoryContext = null
):
	self.id = id
	_runner = runner

	# This seemingly unnecessary lambda is intentional.
	# Passing `_get_last_cmd_result` directly doesn't work, but this does for some reason.
	_runner.bind_external_function("get_last_cmd_result", func(): return _get_last_cmd_result())

	if header.is_empty():
		self.header = Story.parse_tags(_runner.get_global_tags())
	else:
		self.header = header

	if context == null:
		self.context = Story.context
	else:
		self.context = context
	# Let internal commands process first, then context's
	_cmd_runner.fallback_handler = self.context.run_command

	_add_parser(_substory_parser)

	_character_map = header.get("characters", {})
	_character_props = header.get("character_props", {})

	for key in _character_map.keys():
		var alias = _character_map[key]
		characters[key] = Story.characters[alias]

	player_key = header.player
	player = characters[player_key]


func get_custom_class() -> String:
	return "Substory"


func _get_last_cmd_result():
	var result = _cmd_runner.get_last_result()
	assert(result != null)  # Ink doesn't like null return values
	return result


func _add_parser(fn: Callable):
	_parsers.append(fn)


func _add_command_handler(fn: Callable):
	_cmd_runner.register_handler(fn)


func _parse(raw: String):
	for parser in _parsers:
		var res = parser.call(raw)
		if res != null:
			return res


func run_command(cmd: Command):
	return await _cmd_runner.run(cmd)


func start():
	printerr("Not implemented")


func is_done():
	return not _runner.can_continue() and not has_choices()


func advance():
	started = true

	if _runner.can_continue():
		var raw = _runner.advance().strip_edges()
		current_tags = Story.parse_tags(_runner.get_tags())
		current = _parse(raw)
		advanced.emit()
		if Utils.is_debug():
			print(raw)
	elif has_choices():
		current_tags = {}
		current = self.choices
		advanced.emit()


func finish():
	if not is_done():
		_runner.force_end()
	current = null
	finished.emit()


func has_choices() -> bool:
	return self.choices.size() > 0


func choose_choice_index(i: int):
	_runner.choose_choice_index(i)


func alias_of(char_key: String):
	return _character_map.get(char_key)


func tag_value(char_key: String, tag_key: String, default):
	# Get current-level value
	if tag_key in current_tags:
		return current_tags[tag_key]

	# Get substory-level value
	if char_key in _character_props:
		var char_props = _character_props[char_key]
		if tag_key in char_props:
			return char_props[tag_key]

	# Get character-level value
	var character = characters.get(char_key)
	if character != null:
		return character.get_prop(tag_key, default)

	return default


func _substory_parser(raw: String):
	if raw.begins_with("$"):
		return _parse_command(raw)


func _parse_command(raw: String) -> Command:
	var cmd = Command.new(raw, current_tags, self)
	# Substitute %CharKey params with %CharAlias
	for i in range(cmd.params.size()):
		var param = cmd.params[i]
		if not (param is String and param.begins_with("%")):
			continue

		var char_key = param.trim_prefix("%")
		var char_alias = alias_of(char_key)

		if char_alias is String:
			cmd.params[i] = char_alias

	return cmd
