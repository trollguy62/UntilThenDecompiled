extends RefCounted

var time_start: float = 0.0
var text: String = ""
var time_end: float = 0.0


func _init(time_start_: float, text_: String, time_end_: float):
	time_start = time_start_
	text = text_
	time_end = time_end_
