extends Node
class_name CommandAudioTrigger

@export var alias := ""

@onready var event = get_parent()


func _enter_tree():
	Story.add_command_handler(_run_command)


func _ready():
	if alias == "":
		alias = event.name

	assert(event is StudioEventEmitter2D or event is StudioEventEmitter3D)


func _exit_tree():
	Story.remove_command_handler(_run_command)


func _run_command(cmd: Command):
	var params = cmd.params
	var flags = cmd.flags

	if params.size() > 0 and str(params[0]) != alias:
		return Constants.CMD_RETURN_NONE

	match cmd.name:
		"play_sound":
			event.play()
		"stop_sound":
			event.stop()
		"set_event_param":
			var param_name = params[1]
			var param_value = params[2]
			event.set_parameter(param_name, float(param_value))
		_:
			return Constants.CMD_RETURN_NONE

	return null
