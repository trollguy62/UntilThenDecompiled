extends Node

signal focus_changed

const Command = preload("res://data/Command.gd")

var _stack := [Constants.UNIVERSAL_FOCUS]


func is_focused(name: String) -> bool:
	return _stack.front() == name


func is_focus_universal() -> bool:
	return is_focused(Constants.UNIVERSAL_FOCUS)


func push_focus(name: String) -> bool:
	if name == Constants.UNIVERSAL_FOCUS or name in _stack:
		return false
	else:
		_stack.push_front(name)
		focus_changed.emit()
		return true


func pop_focus(name: String) -> bool:
	if name == Constants.UNIVERSAL_FOCUS or not name in _stack:
		return false

	if _stack.front() == name:
		_stack.pop_front()
	else:
		_stack.erase(name)

	focus_changed.emit()
	return true


func clear():
	while _stack.size() > 1:
		_stack.pop_front()
	focus_changed.emit()


func _enter_tree():
	Story.add_command_handler(_run_command)


func _exit_tree():
	Story.remove_command_handler(_run_command)


func _run_command(cmd: Command):
	var params = cmd.params

	match cmd.name:
		"push_focus":
			push_focus(params[0])
		"pop_focus":
			pop_focus(params[0])
		_:
			return Constants.CMD_RETURN_NONE

	return null
