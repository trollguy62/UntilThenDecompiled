extends "Substory.gd"

signal push_timed_choices_requested(time_limit: float, fallback_idx: int)

const THOUGHT_CHAR_KEY = ":"

var focus_name: String


func _init(
	id: String,
	runner: InkRunner,
	header: Dictionary = {},
	context: SubstoryContext = null
):
	super(id, runner, header, context)
	assert(header.type == "dialogue")

	var push_focus = header.get("push_focus", true)
	focus_name = id if push_focus else Constants.UNIVERSAL_FOCUS

	_add_parser(_dialogue_parser)
	_add_command_handler(_dialogue_command_handler)


func get_custom_class() -> String:
	return "Dialogue"


func start():
	var handler = Service.of("DialogueHandler")
	handler.start(self)
	await finished


func _dialogue_parser(raw: String):
	var result := Constants.REGEX_DIALOGUE.search(raw)
	if result == null:
		return null

	var char_key = result.strings[result.names["char_key"]]
	var text = result.strings[result.names["text"]]
	var duration = 0.0

	if "duration" in result.names:
		var raw_duration: String = result.strings[result.names["duration"]]
		duration = float(raw_duration)

	return Line.new(char_key, text, duration)


func _dialogue_command_handler(cmd: Command):
	var params = cmd.params

	match cmd.name:
		"push_timed_choices":
			var time_limit = params[0]
			var fallback_idx = params[1]
			push_timed_choices_requested.emit(time_limit, fallback_idx)
		_:
			return Constants.CMD_RETURN_NONE

	return null


class Line:
	var char_key: String
	var text: String
	var duration: float

	func _init(char_key: String, text: String, duration: float):
		self.char_key = char_key
		self.text = text
		self.duration = duration

	func is_thought() -> bool:
		return char_key == THOUGHT_CHAR_KEY

	func is_timed() -> bool:
		return duration > 0
