@tool
extends Node3D

@export var giggling = false:
	set(value):
		giggling = value
		if not __ready:
			return

		if not giggling:
			for paper in _get_animated_papers():
				paper.position.y = 0

@export var speed = 50
@export var amplitude = 0.01
@export var step = 0.01

@onready var sfx_giggle = $ClassGiggle

var __ready = false


func _ready():
	__ready = true
	self.giggling = giggling


func _process(delta):
	if giggling:
		_giggle()


func _giggle():
	var papers := _get_animated_papers()

	for i in range(papers.size()):
		var paper = papers[i]
		var y = Utils.sin_bounded(Utils.t + i, 0, amplitude, speed)
		paper.position.y = snapped(y, step)



func _set_papers_playing(playing: bool):
	for paper in _get_animated_papers():
		paper.playing = playing


func _get_animated_papers() -> Array:
	var papers := []

	for child in get_children():
		if child is AnimatedPaper3D:
			papers.append(child)

	return papers


### Command handler ###
var _command_handler = _run_command


func _enter_tree():
	if not Engine.is_editor_hint():
		Story.add_command_handler(_command_handler)


func _exit_tree():
	if not Engine.is_editor_hint():
		Story.remove_command_handler(_command_handler)


func _run_command(cmd: Command):
	var params = cmd.params

	match cmd.name:
		"class_giggle":
			var pause_duration = params[0]
			var giggle_duration = params[1]

			_set_papers_playing(false)
			await Utils.wait(pause_duration)

			_set_papers_playing(true)
			self.giggling = true
			sfx_giggle.play()

			await Utils.wait(giggle_duration)
			self.giggling = false
		_:
			return Constants.CMD_RETURN_NONE

	return null
