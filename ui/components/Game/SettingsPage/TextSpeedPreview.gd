extends Label

var text_speed_spk := 0.0
var _t := 0.0


func _ready():
	visible_characters = 0


func _process(delta):
	if text_speed_spk < Constants.EPSILON:
		return

	_t += delta
	var char_count = visible_characters

	while _t >= text_speed_spk:
		_t -= text_speed_spk
		char_count += 1

	char_count %= tr(text).length() + 1
	visible_characters = char_count


func _exit_tree():
	visible_characters = 0
