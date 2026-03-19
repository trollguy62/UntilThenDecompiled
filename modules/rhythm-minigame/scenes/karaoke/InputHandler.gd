extends Node

signal input_triggered(column, state)

const RhythmGameConstants = preload("../../utils/RhythmGameConstants.gd")

@onready var arrows: Array = get_children()


func _unhandled_input(event):
	if event is InputEventKey && !event.is_echo():
		if event.is_action("rhythm_left"):
			_trigger(RhythmGameConstants.COLUMN.LEFT, event.is_pressed())

		if event.is_action("rhythm_down"):
			_trigger(RhythmGameConstants.COLUMN.DOWN, event.is_pressed())

		if event.is_action("rhythm_up"):
			_trigger(RhythmGameConstants.COLUMN.UP, event.is_pressed())

		if event.is_action("rhythm_right"):
			_trigger(RhythmGameConstants.COLUMN.RIGHT, event.is_pressed())


func _trigger(column: int, pressed: bool):
	input_triggered.emit(column, pressed)
