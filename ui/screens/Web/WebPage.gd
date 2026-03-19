extends Control

signal loaded

const WebLink = preload("res://data/web/WebLink.gd")

var link: WebLink
var progress := 0.0:
	get: return progress
var is_loading := false:
	get: return is_loading

@onready var timer = Timer.new()


func _ready():
	timer.one_shot = true
	add_child(timer)


func load(speed_mult: float = 1):
	loaded.emit()


func cancel():
	pass  # Abstract
