extends Node
class_name DialogueHandler

const Command = preload("res://data/Command.gd")
const SpeechBubble = preload("res://components/SpeechBubble/SpeechBubble.gd")
const SpeechBubbleView = preload("res://components/SpeechBubble/SpeechBubble.tscn")
const DialogueText = preload("res://data/DialogueText.gd")

var _speech_bubbles = {}


func start(dialogue):
	await Utils.wait(0)

	var processor = Processor.new(dialogue, self)
	add_child(processor)


# TODO: This function could be Processor's, so as to no longer need a reference
#       to its DialogueHandler
func get_speech_bubble(alias: String):
	if _speech_bubbles.has(alias):
		return _speech_bubbles[alias]
	# TODO: Do we really need this below?
	var sb = SpeechBubbleView.instantiate()
	sb.alias = alias

	_speech_bubbles[alias] = sb
	add_child(sb)

	return sb


### Command handler ###
func _enter_tree():
	Story.add_command_handler(_run_command)


func _exit_tree():
	Story.remove_command_handler(_run_command)


func _run_command(cmd: Command):
	var params = cmd.params

	match cmd.name:
		"say":  # Warning: Overrides existing dialogue
			var alias = params[0]
			var text = params[1]
			var sb = get_speech_bubble(alias)

			_apply_speech_bubble_theme_from_command(sb, alias, cmd)

			sb.context = null
			sb.choices = [DialogueText.new(text)]
			await sb.chosen
		"say_timed":
			var alias = params[0]
			var duration = params[1]
			var text = params[2]
			var sb = get_speech_bubble(alias)

			_apply_speech_bubble_theme_from_command(sb, alias, cmd)

			sb.context = null
			sb.choices = [DialogueText.new(text, duration)]
			await sb.chosen
		_:
			return Constants.CMD_RETURN_NONE

	return null


func _apply_speech_bubble_theme_from_command(sb: SpeechBubble, key: String, cmd: Command):
	var color = sb.color
	var text_color = sb.text_color
	# TODO [IMPORTANT] A unified system for resolution of tags!
	if cmd.substory:  # Get tag value from substory, if any
		var ss = cmd.substory
		color = Color(ss.tag_value(key, "bub_color", color))
		text_color = Color(ss.tag_value(key, "bub_text_color", text_color))
	else:  # Otherwise, derive from character-level props
		var character = Story.characters.get(key)
		if character:
			color = Color(character.get_prop("bub_color", color))
			text_color = Color(character.get_prop("bub_text_color", text_color))

	sb.color = color
	sb.text_color = text_color


class Processor:
	extends Node
	const Dialogue = preload("res://data/story/Dialogue.gd")

	var dialogue: Dialogue:
		get: return dialogue
	var handler: WeakRef  # WeakRef<DialogueHandler>

	var next_choice_time_limit := 0.0
	var next_choice_fallback_idx := 0


	func is_running():
		return dialogue != null and not dialogue.is_done()

	func _init(dialogue: Dialogue = null, handler = null):
		self.handler = weakref(handler)
		self.dialogue = dialogue

		dialogue.push_timed_choices_requested.connect(_push_timed_choices)
		start()

	func start():
		await Utils.wait(0)

		var focus = Focus.new()
		add_child(focus)
		focus.focus_name = dialogue.focus_name
		focus.push()

		while not dialogue.is_done():
			dialogue.advance()
			var proc = await _proc_current()

		# Prevent potential collision of controls with InteractiveArea
		await Utils.wait(0)

		focus.pop()
		dialogue.finish()
		self.dialogue = null

	func _proc_current():
		var current = dialogue.current

		if current is Dialogue.Line:
			if current.is_thought():
				await _proc_thought(current.text, current.duration)
			else:
				await _proc_dialogue_line(current)
		elif current is Array:
			await _proc_choices(current)
		elif current is Command:
			await dialogue.run_command(current)


	func _proc_thought(text: String, duration: float):
		var thought_bubble = Service.of("ThoughtBubble")
		if thought_bubble != null:
			await thought_bubble.show(text, duration, dialogue.context)

	func _proc_dialogue_line(line: Dialogue.Line):
		var key = line.char_key
		var tags = dialogue.current_tags

		var alias = dialogue.alias_of(key)
		if alias == null:
			alias = key

		var sb = handler.get_ref().get_speech_bubble(alias)

		var flags = []
		if "F" in tags:
			flags = tags["F"].split(" ")
		flags.append("$talk")

		_apply_speech_bubble_theme_from_tags(sb, key)
		_change_temp_flags(alias, true, flags)

		var dlg_text = DialogueText.new(line.text, line.duration)

		sb.context = dialogue.context
		sb.choices = [dlg_text]

		await sb.chosen
		_change_temp_flags(alias, false, flags)

	func _proc_choices(ink_choices: Array):
		var key = dialogue.player_key
		var alias = dialogue.alias_of(key)
		var sb = handler.get_ref().get_speech_bubble(alias)
		var choices = []

		for ink_choice in ink_choices:
			var dlg_text = DialogueText.new(ink_choice)
			choices.append(dlg_text)

		_apply_speech_bubble_theme_from_tags(sb, key)
		_change_temp_flags(alias, true, ["$choice"])

		sb.context = dialogue.context
		sb.choices = choices

		if next_choice_time_limit > 0:
			sb.push_time_limit(next_choice_time_limit, next_choice_fallback_idx)
			next_choice_time_limit = 0.0
			next_choice_fallback_idx = 0

		var choice_idx = await sb.chosen

		_change_temp_flags(alias, false, ["$choice"])
		dialogue.choose_choice_index(choice_idx)

	func _push_timed_choices(time_limit: float, fallback_idx: int):
		next_choice_time_limit = time_limit
		next_choice_fallback_idx = fallback_idx

	# TODO to be refactored (how do we actually change emotes consistently?)
	func _change_temp_flags(alias: String, add: bool, flags: Array):
		if flags.is_empty():
			return

		if not add:
			for i in range(flags.size()):
				flags[i] = "-" + flags[i]

		var raw = "$ Fs %s %s" % [alias, " ".join(PackedStringArray(flags))]
		var cmd = Command.new(raw, {}, dialogue)
		dialogue.context.run_command(cmd)

	func _apply_speech_bubble_theme_from_tags(sb, key: String):
		sb.color = Color(dialogue.tag_value(key, "bub_color", SpeechBubble.DEF_COLOR))
		sb.text_color = Color(
			dialogue.tag_value(key, "bub_text_color", SpeechBubble.DEF_TEXT_COLOR)
		)
