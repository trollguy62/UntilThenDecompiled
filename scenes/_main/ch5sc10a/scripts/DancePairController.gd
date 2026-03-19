@tool
extends Node3D

signal pending_frame_reached()

@export var alias := ""
@export var group := "":
	set(value):
		group = value
		_switch_group(value)

var _groups: Array[Node3D] = []
var _pending_frame := -1

var _active_group: Node3D
var _reference_sprite: AnimatedPaper3D


func _ready():
	assert(alias != "")

	for child in get_children():
		if child is Node3D:
			_groups.append(child)

	_switch_group(group)


func _process(_delta):
	var cur_frame = _reference_sprite.frame

	for child in _active_group.get_children():
		if child is AnimatedPaper3D and child != _reference_sprite:
			child.frame = cur_frame
			child.playing = false

	if _pending_frame == cur_frame:
		pending_frame_reached.emit()
		_pending_frame = -1


func _switch_group(name: String):
	if not is_node_ready():
		return

	var cur_frame := -1

	if _reference_sprite:
		cur_frame = _reference_sprite.frame
		_reference_sprite.playing = false

	_active_group = null
	_reference_sprite = null

	for group in _groups:
		group.visible = name == group.name

		if group.visible:
			assert(_active_group == null)
			_active_group = group

		for child in group.get_children():
			if child is AnimatedPaper3D:
				child.playing = false

				if _reference_sprite == null and group.visible:
					_reference_sprite = child
					child.playing = true

				if cur_frame >= 0:
					child.frame = cur_frame

	assert(_active_group)
	assert(_reference_sprite)


func _wait_for_frame(frame: int):
	assert(_pending_frame == -1 and frame >= 0)
	_pending_frame = frame
	await pending_frame_reached


### Command handler ###
var _command_handler = _run_command


func _enter_tree():
	Story.add_command_handler(_command_handler)


func _exit_tree():
	Story.remove_command_handler(_command_handler)


func _run_command(cmd: Command):
	var params = cmd.params
	var flags = cmd.flags

	if params.size() >= 1 and str(params[0]) != alias:
		return Constants.CMD_RETURN_NONE

	match cmd.name:
		"dpair.wait_for_frame":
			await _wait_for_frame(int(params[1]))
		"dpair.switch_group":
			var group_name = str(params[1])
			var switch_on_frame = Utils.array_get(params, 2, -1)

			if switch_on_frame >= 0:
				await _wait_for_frame(switch_on_frame)

			_switch_group(group_name)
		_:
			return Constants.CMD_RETURN_NONE

	return null
