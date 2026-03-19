extends Node

### Command handler ###
var _command_handler = _run_command


func _enter_tree():
	Story.add_command_handler(_command_handler)


func _exit_tree():
	Story.remove_command_handler(_command_handler)


func _run_command(cmd: Command):
	var params = cmd.params
	var flags = cmd.flags

	match cmd.name:
		"to_tv_screen":
			var screen_name = params[0]
			for child in get_children():
				child.visible = child.name == screen_name
		_:
			return Constants.CMD_RETURN_NONE

	return null
