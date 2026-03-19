extends Node3D

const PlayerTarget = preload("res://components/PlayerTarget.gd")

@export var alias := ""

@onready var player_target = Service.of("PlayerTarget") as PlayerTarget

var _command_handler = _run_command


func _enter_tree():
	if alias == "":
		alias = name

	Story.add_command_handler(_command_handler)


func _exit_tree():
	Story.remove_command_handler(_command_handler)


func _run_command(cmd: Command):
	var params = cmd.params
	if not (params.size() >= 1 and str(params[0]) == alias):
		return Constants.CMD_RETURN_NONE

	match cmd.name:
		"set_player_target":
			player_target.change(self)
		_:
			return Constants.CMD_RETURN_NONE

	return null


func get_custom_class() -> String:
	return "PlayerTargetPosition"
