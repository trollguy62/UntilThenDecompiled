extends PanelContainer

const MAX_TEXT_WIDTH = 320

@export var text_allowance = 0

@onready var label = $Label


func get_size_of(bbcode_text: String):
	custom_minimum_size = Vector2.ZERO
	size = Vector2.ZERO
	label.text = bbcode_text

	#removes bbcode tags
	var regex = RegEx.new()
	regex.compile("\\[.*?\\]")
	var text = regex.sub(label.text, "", true)

	var font = label.get_theme_font("normal_font")
	var text_width = _text_width_of(text, font)
	
	if Game.config.is_locale_non_latin():
		text_width = min(text_width, MAX_TEXT_WIDTH)
	elif text_width > MAX_TEXT_WIDTH:
		# Finds decent text width by breaking down into lines
		var words: Array = Array(text.split(" ", false))
		var newlined_text = ""
		
		# Prevents orphan words by having at least 2 words for the last line
		if words.size() >= 2:
			words.reverse()
			words[1] += " " + words[0]
			words.remove_at(0)
			words.reverse()

		for word in words:
			var copy = newlined_text
			if not (copy.is_empty() or copy.ends_with("\n")):
				copy += " "
			copy += word

			if _text_width_of(copy, font) > MAX_TEXT_WIDTH:
				newlined_text += "\n" + word
			else:
				newlined_text = copy

		# This probably won't be necessary only if `final_text` is broken into lines too.
		text_width = _text_width_of(newlined_text, font)

	label.custom_minimum_size.x = text_width + text_allowance
	await Utils.wait(0)

	label.size.x = text_width + text_allowance
	size = Vector2.ZERO
	await Utils.wait(0)


func _text_width_of(text: String, font: Font) -> float:
	var lines = text.split("\n")
	var max_width = 0.0

	for line in lines:
		var line_width = font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, \
			-1, label.get_theme_font_size("normal_font_size")).x
		max_width = max(max_width, line_width)

	return max_width
