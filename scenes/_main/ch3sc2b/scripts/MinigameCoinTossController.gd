extends Node

const Command = preload("res://data/Command.gd")

@onready var minigame = get_parent()

var _command_handler = _run_command


func _ready():
	minigame.aim_repositioned.connect(_on_aim_repositioned)
	minigame.tossed.connect(_on_tossed)

func _enter_tree():
	if not Engine.is_editor_hint():
		Story.add_command_handler(_command_handler)


func _exit_tree():
	if not Engine.is_editor_hint():
		Story.remove_command_handler(_command_handler)


func _on_aim_repositioned():
	var signal_name = "aim_repositioned"
	Story.emit("cointoss.%s" % signal_name)


func _on_tossed(points):
	Story.emit("cointoss.tossed", points)


func _run_command(cmd: Command):
	var params = cmd.params

	match cmd.name:
		"cointoss.add_agent":
			var alias = params[0]
			var is_player = params[1]
			minigame._add_agent(alias, is_player)

		"cointoss.remove_agent":
			var alias = params[0]
			minigame._remove_agent(alias)

		"cointoss.start_agent_turn":
			var alias = params[0]
			minigame._set_current_agent(alias)
			minigame._state = minigame.States.AIMING_POSITION

		"cointoss.end_agent_turn":
			minigame._remove_current_agent()

		"cointoss.aim_position":
			var aim_count = params[0]
			minigame._accuracy = params[1]
			await minigame._aim_position(aim_count, minigame._accuracy)

		"cointoss.stop_aim":
			minigame._stop_aim()

		"cointoss.start_aim_strength":
			minigame._start_aim_strength()

		"cointoss.toss":
			var accuracy: float = params[0]
			minigame._toss(accuracy)

		"cointoss.set_player_crosshair_shake_strength":
			var strength = params[0]
			var duration = params[1] if params.size() >= 2 else minigame.crosshair.noise_magnitude
			minigame.crosshair.shift_shake_strength(strength, duration)

		"cointoss.set_player_strength_meter_speed_factor":
			var multiplier = params[0]
			minigame.player_strength_meter_speed_factor = multiplier

		"cointoss.player_has_highest_score":
			return minigame._player_has_highest_score()

		_:
			return Constants.CMD_RETURN_NONE

	return null
