extends Node
class_name AudioGlobalParameter

@export var param_name: String
@export var param_value: float:
	set = _set_param_value,
	get = _get_param_value

var _name = ""


func _ready():
	self.param_value = param_value


func _set_param_value(value):
	param_value = value
	if is_inside_tree():
		FMODStudioModule.get_studio_system().set_parameter_by_name(_name, value, false)


func _get_param_value() -> float:
	return FMODStudioModule.get_studio_system().get_parameter_by_name(_name).get("final_value", 0.0)


### Command handler ###
func _enter_tree():
	_name = param_name
	Story.add_command_handler(_run_command)


func _exit_tree():
	Story.remove_command_handler(_run_command)


func _run_command(cmd: Command):
	var params = cmd.params
	var flags = cmd.flags

	if params.size() > 0 and str(params[0]) != _name:
		return Constants.CMD_RETURN_NONE

	match cmd.name:
		"set_global_param":
			self.param_value = float(params[1])
		_:
			return Constants.CMD_RETURN_NONE

	return null
