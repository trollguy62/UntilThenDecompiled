extends Node2D

@onready var knife = $Knife

### Command handler ###
func _enter_tree():
	Story.add_command_handler(_run_command)


func _exit_tree():
	Story.remove_command_handler(_run_command)


func _run_command(cmd: Command):
	var params = cmd.params

	match cmd.name:
		"minigame_carving.set_enabled":
			knife.enabled = bool(cmd.params[0])
		"minigame_carving.finish":
			knife._on_minigame_finished()
		_:
			return Constants.CMD_RETURN_NONE

	return null
