extends Node3D

const PlayerTargetPosition = preload("res://components/PlayerTargetPosition.gd")

@export var alias := ""
@export var path_path: NodePath
@export var path_loop := false

@onready var _path = get_node(path_path) as Path3D


func _ready():
	if alias == "":
		alias = name


### Command handler ###

var _command_handler = _run_command


func _enter_tree():
	Story.add_command_handler(_command_handler)


func _exit_tree():
	Story.remove_command_handler(_command_handler)


func _run_command(cmd: Command):
	var params = cmd.params
	if not (params.size() >= 1 and str(params[0]) == alias and is_visible_in_tree()):
		return Constants.CMD_RETURN_NONE

	match cmd.name:
		"get_closest_target":
			var targets = []

			for i in range(1, params.size()):
				var target_alias = params[i]
				var target = Index.get_with("PlayerTargetPosition", target_alias)

				if target:
					targets.append(target)

			assert(targets.size() >= 2)
			var closest_target = get_closest_target(targets)

			if closest_target is PlayerTargetPosition:
				return closest_target.alias
			else:
				return ""
		_:
			return Constants.CMD_RETURN_NONE

	return null


func get_closest_target(targets: Array):
	var closest_target = null
	var min_distance = 0.0
	var self_offset = _path.curve.get_closest_offset(global_transform.origin)

	for target in targets:
		var offset = _path.curve.get_closest_offset(target.global_transform.origin)
		var dist = abs(self_offset - offset)

		if path_loop:
			var path_len = _path.curve.get_baked_length()
			dist = min(dist, abs(dist - path_len))

		if closest_target == null or dist < min_distance:
			closest_target = target
			min_distance = dist

	return closest_target
