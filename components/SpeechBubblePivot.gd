extends Node

const SpeechBubble = preload("res://components/SpeechBubble/SpeechBubble.gd")

@export var alias := ""
@export var orientation := SpeechBubble.Orientation.TOP

@export var force_show := false
@export_range(0.0, 512.0) var force_show_margin = 32.0
@export var adaptive: bool = false


func get_custom_class() -> String:
	return "SpeechBubblePivot"
