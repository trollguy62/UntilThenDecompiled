var raw_text: String
var steps: Array = []
var last_step: KeystrokeInst:
	get: return steps[-1]
var final_text := ""


func _init(raw_text: String):
	self.raw_text = raw_text
	var text = raw_text.replace("&br;", "\n")

	var i = 0
	var escape = false
	var s = ""

	var pop_stack = []
	var pop = false

	var delay_read = false
	var delay_count = 0

	var fill_read = false
	var fill_count = 0

	var cmd_read = false
	var cmd_raw = ""

	while i < text.length():
		var c = text[i]
		var c1 = text[i + 1] if i < text.length() - 1 else ""
		var delay = 0
		var fill = 0
		var push = false

		if delay_read:
			if c == ".":
				delay_count += 1
			elif c == "]":
				delay = randfn(delay_count, 0.1)
				delay_read = false
				push = true
			i += 1
		elif fill_read:
			if c == "+":
				fill_count += 1
			elif c == "]":
				fill = randfn(fill_count, 0.1)
				fill_read = false
				push = true
			i += 1
		elif cmd_read:
			if c1 == "]" and c != "\\":
				cmd_read = false
				push = true
				i += 1
			cmd_raw += c
			i += 1
		elif pop:
			if s.length() == pop_stack[-1]:
				pop_stack.pop_back()
				pop = false
				i += 1
			else:
				s = s.substr(0, s.length() - 1)
				push = true
		elif not escape and c == "\\":
			escape = true
			i += 1
		elif not escape and c == "[":
			if c1 == ":":
				pop_stack.push_back(s.length())
				i += 2
			elif c1 == ".":
				delay_read = true
				delay_count = 0
			elif c1 == "+":
				fill_read = true
				fill_count = 0
			elif c1 == "$":
				cmd_read = true
				cmd_raw = ""
				i += 1
		elif not escape and c == "]" and pop_stack.size() > 0:
			pop = true
			steps.push_back(ContinuousDelayInst.new(1.0))
		else:
			escape = false
			s += c
			i += 1
			push = true

		if push:
			if delay > 0:
				steps.push_back(DelayInst.new(delay))
			elif fill > 0:
				steps.push_back(FillInst.new(fill))
			elif cmd_raw.length() > 0:
				steps.push_back(Command.new(cmd_raw))
				cmd_raw = ""
			else:
				steps.push_back(TextInst.new(s))

	final_text = s


class KeystrokeInst:
	func _init():
		pass


class TextInst:
	extends KeystrokeInst
	var text: String

	func _init(text: String):
		self.text = text


class DelayInst:
	extends KeystrokeInst
	var delay: float

	func _init(delay: float):
		self.delay = delay


class FillInst:
	extends KeystrokeInst
	var duration: float

	func _init(duration: float):
		self.duration = duration


class ContinuousDelayInst:
	extends KeystrokeInst
	var factor: float
	var delay: float:
		get: return lerp(0.05, 0.35, Game.config.text_speed) * factor

	func _init(factor: float):
		self.factor = factor
