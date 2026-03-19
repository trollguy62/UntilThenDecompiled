extends Node

const C2D_24 = preload("C2D_24.gd")

@onready var c2d = get_parent() as C2D_24


func _ready():
	c2d.selected.connect(_on_c2d_selected)


func _on_c2d_selected(i: int):
	Story.emit("C2D_24.selected", i)


### Command handler ###
func _enter_tree():
	if not Engine.is_editor_hint():
		Story.add_command_handler(_run_command)


func _exit_tree():
	if not Engine.is_editor_hint():
		Story.remove_command_handler(_run_command)


func _run_command(cmd: Command):
	var params = cmd.params
	var flags = cmd.flags

	match cmd.name:
		"C2D_24.set_selection_enabled":
			c2d.selection_enabled = bool(params[0])
			c2d.set_area_enabled(bool(params[0]))
		_:
			return Constants.CMD_RETURN_NONE

	return null
