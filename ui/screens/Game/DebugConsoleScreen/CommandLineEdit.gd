extends TextEdit

signal text_entered(stringArray)

var input_text_array: PackedStringArray
var max_lines = 4
var line_height = 20


func _ready():
	text_changed.connect(_on_text_changed)


func _input(event):
	if (
		has_focus()
		and event is InputEventKey
		and event.pressed
		and event.keycode == KEY_ENTER
		and not Input.is_key_pressed(KEY_CTRL)
	):
		enter_text_command()
		clear_all.call_deferred()


func _on_text_changed():
	if get_line_count() <= max_lines:
		size.y = line_height * get_line_count()


func enter_text_command():
	var line_count = get_line_count()
	for i in line_count:
		var line = get_line(i)
		line.strip_edges()

		if not line.is_empty():
			input_text_array.append(line)

	if input_text_array.size() > 0:
		text_entered.emit(input_text_array)

func clear_all():
	text = ""
	input_text_array.clear()
	size.y = line_height


func set_command_text(text: String):
	self.text = text
	_on_text_changed()
	set_cursor_position()


func set_cursor_position():
	await get_tree().process_frame
	var line_count = get_line_count()
	var last_line = get_line(line_count - 1)
	set_caret_line(line_count)
	set_caret_column(last_line.length())
