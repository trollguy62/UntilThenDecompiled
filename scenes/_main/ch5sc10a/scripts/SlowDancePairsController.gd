extends Node3D

var pairs := []


func _ready():
	for child in get_children():
		if child is AnimatedPaper3D:
			pairs.append(child)
			child.animation = "default"


### Command handler ###
var _command_handler = _run_command


func _enter_tree():
	if not Engine.is_editor_hint():
		Story.add_command_handler(_command_handler)


func _exit_tree():
	if not Engine.is_editor_hint():
		Story.remove_command_handler(_command_handler)


func _run_command(cmd: Command):
	var params = cmd.params

	if cmd.name == "slow_dance_set_worried":
		var anim = "worried" if bool(params[0]) else "default"
		for pair in pairs:
			pair.animation = anim

	return Constants.CMD_RETURN_NONE
