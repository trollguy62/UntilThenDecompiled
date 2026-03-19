extends Node2D

const SpeechBubble = preload("res://components/SpeechBubble/SpeechBubble.gd")
const ACTIONS := ["choice_1", "choice_2"]

signal correct_key_pressed
signal wrong_key_pressed

@export var short_path: String

@onready var click = $Click
@onready var slow_mo = $SlowMo

var _time_scale := 1.0
var _is_running: bool


func _ready():
	Story.emitted.connect(_on_story_emitted)


func _on_story_emitted(name: String, value):
	match name:
		"dodge":
			_finish_run()
			correct_key_pressed.emit()
		"miss":
			_finish_run()
			wrong_key_pressed.emit()


func run(npc: Node3D, time_scale: float = 0.5):
	_is_running = true
	_time_scale = time_scale

	var short_id = short_path + npc.short_action_choice
	Story.start_short(short_id)

	click.play()
	slow_mo.play()


func _process(delta):
	if _is_running:
		Engine.time_scale = _time_scale


func _finish_run():
	_is_running = false
	_time_scale = 1.0
