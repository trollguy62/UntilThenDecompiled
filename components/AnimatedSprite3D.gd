extends AnimatedSprite3D

@export var alias: String

### Command handler ###
var _command_handler = _run_command


func _enter_tree():
	Story.add_command_handler(_command_handler)


func _exit_tree():
	Story.remove_command_handler(_command_handler)


func _run_command(cmd: Command):
	var params = cmd.params
	if params.size() > 0 and str(params[0]) != alias:
		return Constants.CMD_RETURN_NONE

	match cmd.name:
		"set_anim":
			animation = params[1]
		"play_anim":
			play(params[1])
		_:
			return Constants.CMD_RETURN_NONE

	return null
