extends RefCounted

var timestamp: int = 0
var column: int = 0
var is_pressed: bool = false


func _init(timestamp_: int = 0, column_: int = 0, is_pressed_: bool = false):
	timestamp = timestamp_
	column = column_
	is_pressed = is_pressed_


func update(new_timestamp: int, new_column: int, new_pressed_state: bool):
	timestamp = new_timestamp
	column = new_column
	is_pressed = new_pressed_state
