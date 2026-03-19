extends Node

const Command = preload("res://data/Command.gd")

@onready var minigame = get_parent()

var _command_handler = _run_command


func _ready():
	minigame.aim_reposition.connect(_on_aim_reposition)
	minigame.shot_finished.connect(_on_shot_finished)


func _enter_tree():
	if not Engine.is_editor_hint():
		Story.add_command_handler(_command_handler)


func _exit_tree():
	if not Engine.is_editor_hint():
		Story.remove_command_handler(_command_handler)


func _on_aim_reposition():
	Story.emit("bpop.aim_reposition")


func _on_shot_finished(pts):
	Story.emit("bpop.shot_finished", pts)


func _run_command(cmd: Command):
	var params = cmd.params

	match cmd.name:
		"bpop.add_agent":
			var alias = params[0]
			var is_player = params[1]
			minigame._add_agent(alias, is_player)

		"bpop.remove_agent":
			var alias = params[0]
			minigame._remove_agent(alias)

		"bpop.set_current_agent":
			var alias = params[0]
			minigame._set_current_agent(alias)

		"bpop.remove_current_agent":
			minigame._remove_current_agent()

		"bpop.aim_and_fire":
			var aim_count = params[0]
			minigame._shoot_probability = params[1]
			minigame._aim_and_fire(aim_count)

		"bpop.start_aim_continuous":
			minigame._aim_and_fire(0)

		"bpop.stop_aim":
			minigame._stop_aim()

		"bpop.set_player_crosshair_tug_enabled":
			var is_enabled = params[0]
			minigame._tugged_enabled = is_enabled

		"bpop.set_player_crosshair_shake_strength":
			var strength = params[0]
			var duration = params[1] if params.size() >= 2 else minigame.crosshair.noise_magnitude
			minigame.crosshair.shift_shake_strength(strength, duration)
			
		_:
			return Constants.CMD_RETURN_NONE

	return null
