extends Node

const SHOW_CHANCE = 0.025

@onready var parent = get_parent()


func _ready():
	parent.visible = false


### Command handler ###
var _command_handler = _run_command


func _enter_tree():
	Story.add_command_handler(_command_handler)


func _exit_tree():
	Story.remove_command_handler(_command_handler)


func _run_command(cmd: Command):
	var params = cmd.params

	match cmd.name:
		"try_show_your_fault_decal":
			parent.visible = randf() <= SHOW_CHANCE
		"hide_your_fault_decal":
			parent.visible = false
		_:
			return Constants.CMD_RETURN_NONE

	return null
