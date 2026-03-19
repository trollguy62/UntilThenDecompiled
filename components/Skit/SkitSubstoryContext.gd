extends "res://data/story/SubstoryContext.gd"

const CommandRunner = preload("res://components/CommandRunner.gd")

var allow_global_access = false

var _cmd_runner: CommandRunner
var _speech_bubble_pivots: Array


func _init(cmd_runner: CommandRunner, speech_bubble_pivots: Array):
	_cmd_runner = cmd_runner
	_speech_bubble_pivots = speech_bubble_pivots

	_cmd_runner.fallback_handler = _delegate_command_to_story


func run_command(cmd: Command):
	return await _cmd_runner.run(cmd)


func get_speech_bubble_pivot(alias: String, require_visible: bool = true) -> Node:
	if allow_global_access:
		return Story.context.get_speech_bubble_pivot(alias, require_visible)

	for pivot in _speech_bubble_pivots:
		if (
			is_instance_valid(pivot)
			and pivot.alias == alias
			and (not require_visible or pivot.is_visible_in_tree())
		):
			return pivot
	return null


func _delegate_command_to_story(cmd: Command):
	if allow_global_access:
		return await Story.run_command(cmd)
	else:
		return await Story.internal_command_handler(cmd)
