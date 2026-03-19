const Command = preload("res://data/Command.gd")

var text: String:
	get: return text
var duration: float:
	get: return duration
var final_text: String:
	get: return final_text
var steps: Array:
	get: return steps


# text: property of RichTextLabel where bbcode_text is stripped of BBcodes
func _init(text: String, duration: float = 0):
	self.text = text
	self.duration = duration

	_parse_text()

	if is_timed():
		_fix_duration()


func is_timed() -> bool:
	return duration > 0


func _parse_text():
	steps = []
	final_text = ""

	var escape = false
	var read_cmd = false
	var text_cmd = ""
	var text_speed_mult = 1.0
	var visible_characters = 0

	var text_len = text.length()

	for i in range(text_len):
		var c = text[i]
		var last_char = i == text_len - 1

		if c == "\\" and not escape:
			escape = true
		elif read_cmd:
			if c == "]" and not escape:
				read_cmd = false

				if text_cmd[0] == ">":
					# TODO: Not yet actually used
					text_speed_mult = max(float(text_cmd.trim_prefix(">")), 0.01)
				else:
					var cmd = _parse_misc(text_cmd)
					if cmd != null:
						steps.append(cmd)
					else:
						final_text += "[" + text_cmd + "]"
			else:
				text_cmd += c
				escape = false
		elif c == "[" and not escape:
			read_cmd = true
			text_cmd = ""
		else:
			escape = false
			final_text += c
			visible_characters += 1
			steps.append(visible_characters)

			if not last_char:
				steps.append(TextDelayInst.new())


func _parse_misc(text_cmd: String):
	var first_char = text_cmd[0]

	if first_char == ".":
		var dot_count = Utils.count_char(text_cmd, ".")
		return DotDelayInst.new(dot_count)
	elif first_char == "$":
		return Command.new(text_cmd)
	else:
		return null


func _fix_duration():
	var total_dur := 0.0

	for i in range(steps.size()):
		var step = steps[i]

		if step is DelayInst:
			var step_dur = step.duration
			total_dur += step_dur
			steps[i] = FixedDelayInst.new(step_dur)

	if total_dur > duration:
		for step in steps:
			if step is FixedDelayInst:
				step.fixed_duration *= duration / total_dur
	else:
		var excess = duration - total_dur
		steps.append(FixedDelayInst.new(excess))


class DelayInst:
	var duration: float:
		get = _get_duration

	func _get_duration() -> float:
		return 0.0


class TextDelayInst:
	extends DelayInst

	func _get_duration() -> float:
		return Game.config.text_speed_spk


class DotDelayInst:
	extends DelayInst
	var count: int

	func _init(count: int):
		self.count = count

	func _get_duration() -> float:
		var delay_mult = Game.config.text_speed_delay_mult
		var base_delay = 0.5 * count * delay_mult
		var delay = randfn(base_delay, 0.1)
		return delay


class FixedDelayInst:
	extends DelayInst
	var fixed_duration: float

	func _init(fixed_duration: float):
		self.fixed_duration = fixed_duration

	func _get_duration() -> float:
		return fixed_duration
