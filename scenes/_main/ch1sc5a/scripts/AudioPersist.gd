extends Node

### Command handler ###
var _command_handler = _run_command


func _enter_tree():
	Story.add_command_handler(_command_handler)


func _exit_tree():
	Story.remove_command_handler(_command_handler)


func _run_command(cmd: Command):
	var params = cmd.params

	match cmd.name:
		"play_sound_persist":
			var stream_path = params[0]
			var stream = load(stream_path)
			var volume_db: float = 0
			var bus = "Music"

			if params.size() >= 2:
				volume_db = linear_to_db(clamp(params[1], 0, 1))

			if params.size() >= 3:
				bus = params[2]

			AudioUtils.play_persist(stream, volume_db, bus)
		_:
			return Constants.CMD_RETURN_NONE

	return null
