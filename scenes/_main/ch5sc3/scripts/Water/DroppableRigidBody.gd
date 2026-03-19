extends Node

@onready var parent = get_parent() as RigidBody3D

var _command_handler = _run_command


func _enter_tree():
	Story.add_command_handler(_command_handler)


func _exit_tree():
	Story.remove_command_handler(_command_handler)


func _ready():
	assert(parent is RigidBody3D)
	parent.visible = false
	parent.freeze = true


func drop():
	parent.visible = true
	parent.freeze = false


func _run_command(cmd: Command):
	if cmd.name == "drop" and cmd.params[0] == parent.name:
		drop()
		return null

	return Constants.CMD_RETURN_NONE
