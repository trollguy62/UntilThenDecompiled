extends Marker3D

@export var alias := ""

@onready var player_target = Service.of("PlayerTarget")


func _enter_tree():
	Story.add_command_handler(_run_command)


func _exit_tree():
	Story.remove_command_handler(_run_command)


func _ready():
	if alias == "":
		alias = name


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
