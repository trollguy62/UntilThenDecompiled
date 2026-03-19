extends Node

signal shown
signal hidden

@export var alias := ""

@onready var parent = get_parent()
@onready var focus = Focus.new()


func _ready():
	parent.visible = false
	focus.focus_name = alias
	add_child(focus)


func _input(ev):
	if ev.is_action_pressed("k_interact") or ev.is_action_pressed("c_cancel"):
		if focus.active:
			_hide()


func _show():
	parent.visible = true
	focus.push()
	shown.emit()


func _hide():
	parent.visible = false
	await get_tree().process_frame
	focus.pop()
	hidden.emit()


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
	if params.is_empty() or str(params[0]) != alias:
		return Constants.CMD_RETURN_NONE

	match cmd.name:
		"show":
			_show()
			await self.hidden
			var x = 0
		"hide":
			_hide()
		_:
			return Constants.CMD_RETURN_NONE

	return null
