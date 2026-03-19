extends Node

const Command = preload("res://data/Command.gd")

@onready var minigame = get_parent()


func _enter_tree():
	if not Engine.is_editor_hint():
		Story.add_command_handler(_run_command)


func _exit_tree():
	if not Engine.is_editor_hint():
		Story.remove_command_handler(_run_command)


func _ready():
	minigame.aim_repositioned.connect(_on_aim_repositioned)
	minigame.shot_finished.connect(_on_shot_finished)
	minigame.thrown.connect(_on_thrown)


func _on_aim_repositioned():
	Story.emit("darts.aim_repositioned")


func _on_shot_finished(points):
	Story.emit("darts.shot_finished", points)


func _on_thrown():
	Story.emit("darts.thrown")


func _run_command(cmd: Command):
	var params = cmd.params

	match cmd.name:
		"darts.add_agent":
			var alias = params[0]
			var is_player = params[1]
			minigame._add_agent(alias, is_player)

		"darts.remove_agent":
			var alias = params[0]
			minigame._remove_agent(alias)

		"darts.start_agent_turn":
			var alias = params[0]
			minigame._set_current_agent(alias)
			minigame._state = minigame.States.AIMING_POSITION

		"darts.aim_position":
			var aim_count = params[0]
			minigame._bullseye_tendency = params[1]
			minigame._aim_position(minigame.aim_count, minigame._bullseye_tendency)

		"darts.start_aim_continuous":
			minigame._aim_position(0, minigame._bullseye_tendency)

		"darts.stop_aim":
			minigame._stop_aim()

		"darts.start_aim_strength":
			minigame._start_aim_strength()

		"darts.throw":
			var accuracy: float = params[0]
			minigame._throw(accuracy)

		"darts.end_agent_turn":
			minigame._remove_current_agent()

		"darts.set_player_crosshair_shake_strength":
			var strength = params[0]
			var duration = params[1] if params.size() >= 2 else minigame.crosshair.noise_magnitude
			minigame.crosshair.shift_shake_strength(strength, duration)

		"darts.set_player_strength_meter_speed_factor":
			var multiplier = params[0]
			minigame.player_strength_meter_speed_factor = multiplier
		_:
			return Constants.CMD_RETURN_NONE

	return null
