extends Control

signal new_result(result)

const HitResult = preload("../../classes/judgment/HitResult.gd")
const HitInput = preload("../../classes/input/HitInput.gd")
const RhythmGameConstants = preload("../../utils/RhythmGameConstants.gd")

const action_dict = {
	RhythmGameConstants.COLUMN.DOWN : ["rhythm_down", "ui_down"],
	RhythmGameConstants.COLUMN.LEFT : ["rhythm_left", "ui_left"],
	RhythmGameConstants.COLUMN.RIGHT : ["rhythm_right", "ui_right"],
	RhythmGameConstants.COLUMN.UP : ["rhythm_up", "ui_up"]
}

@export var column: RhythmGameConstants.COLUMN = RhythmGameConstants.COLUMN.DOWN

var index = 0
var timestamp_msec: int = 0

var input_window_frame = 0
var last_input_frame = 0
var last_input: RhythmGameConstants.COLUMN

func _unhandled_input(event):
	if !event.is_echo():
		for action in action_dict[column]:
			if event.is_action(action):
				if last_input_frame == input_window_frame and column == last_input:
					return

				trigger(column, event.is_pressed())
				last_input = column
				last_input_frame = input_window_frame

func _process(delta):
	input_window_frame += 1
	for n in get_children():
		n.timestamp_msec = timestamp_msec

func clear():
	for n in get_children():
		n.queue_free()
	index = 0

func spawn(kht):
	add_child(kht)
	kht.new_result.connect(_on_new_result)

func _on_new_result(result: HitResult):
	new_result.emit(result)
	index += 1

func trigger(column: int, pressed: bool):
	var hi = HitInput.new(timestamp_msec, column, pressed)
	if get_child_count() > 0 && index < get_child_count():
		get_child(index).check_result(hi)
