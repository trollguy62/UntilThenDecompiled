extends Node2D

signal game_started()
signal game_finished()
signal hi_score_achieved()

@onready var game_time_text = $GameTimer
@onready var game_time_timer = $GameTimer/TimerUpdate
@onready var hi_score_text = $Hiscore
@onready var camera = $Camera2D
@onready var ui = $CanvasLayer
@onready var player_mark = $Mark
@onready var player_cathy = $Cathy
@onready var flash = $CanvasLayer/ColorRect

var game_time = 60
var time  = 0
var seconds = 0
var minutes = 0
var current_hi_score = 0

func _ready():
	game_time_timer.timeout.connect(_on_game_timer_timeout)
	player_mark.mole_hit.connect(camera._on_mole_hit)
	player_mark.mole_hit.connect(ui._on_mole_hit)
	flash.visible = false

func start_game():
	game_started.emit()
	start_timer()
	player_mark.start()
	player_cathy.start()
	flash.visible = true

func end_game():
	game_finished.emit()
	game_time_timer.stop()
	player_mark.stop()
	player_cathy.stop()
	flash.visible = false

func set_high_score():
	if player_cathy.current_score >= player_mark.current_score:
		current_hi_score = player_cathy.current_score
	else:
		current_hi_score = player_mark.current_score
		hi_score_achieved.emit()

	hi_score_text.text = "%03d" % current_hi_score

func start_timer():
	if game_time < 60:
		minutes = 0
		seconds = game_time
	else:
		minutes = game_time / 60
		seconds = game_time - (minutes * 60)

	game_time_text.text = "%02d:%02d" % [minutes,seconds]
	game_time_timer.start(1)

func _on_game_timer_timeout():
	seconds -= 1

	if minutes == 0 and seconds == 0:
		end_game()
		set_high_score()
	else:
		if seconds == -1:
			seconds = 59
			minutes -= 1

	game_time_text.text = "%02d:%02d" % [minutes,seconds]


### Command handler ###
var _command_handler = _run_command


func _enter_tree():
	Story.add_command_handler(_command_handler)


func _exit_tree():
	Story.remove_command_handler(_command_handler)


func _run_command(cmd: Command):
	var params = cmd.params

	match cmd.name:
		"whackamole.get_score_mark":
			return player_mark.current_score
		"whackamole.get_score_cathy":
			return player_cathy.current_score
		_:
			return Constants.CMD_RETURN_NONE

	return null
