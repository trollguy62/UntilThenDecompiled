extends Node

const AnimatedPaper3D = preload("res://components/AnimatedPaper3D/AnimatedPaper3D.gd")
const PathGrounder = preload("res://components/PathGrounder.gd")
const PlayerTargetPosition = preload("res://components/PlayerTargetPosition.gd")

@export var alias := ""

@onready var parent := get_parent() as Node3D
@onready var path_grounder := $"../PathGrounder" as PathGrounder
@onready var forward_vec := Vector3.RIGHT
@onready var footsteps = get_node_or_null("./Footsteps")


func _ready():
	if alias == "":
		alias = parent.name

	_init_path_grounder()


func _process(delta):
	var moving = abs(path_grounder.delta_offset) > Constants.EPSILON

	if footsteps:
		if moving and not footsteps.playing:
			footsteps.play()
		else:
			footsteps.stop()


func _init_path_grounder():
	path_grounder.enabled = false
	await get_tree().process_frame

	var global_pos = parent.global_transform.origin
	var offset = path_grounder.get_closest_offset(global_pos)
	var offset_pos = path_grounder.get_offset_global_position(offset)

	path_grounder.path_offset = offset
	path_grounder.global_offset = global_pos - offset_pos
	path_grounder.enabled = true


func _get_player_target_pos(alias: String) -> PlayerTargetPosition:
	# Compiler doesn't like if I return Index.get_with(..) directly (return type mismatch)
	var target = Index.get_with("PlayerTargetPosition", alias)
	return target


func _emit_next_target_reached():
	await path_grounder.target_reached
	Story.emit("_npc_target_reached_" + alias)


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

	if not parent.is_visible_in_tree() or params.is_empty() or str(params[0]) != alias:
		return Constants.CMD_RETURN_NONE

	match cmd.name:
		"set_npc_target", "set_npc_position":
			var target_alias = params[1] as String
			var target_pos = _get_player_target_pos(target_alias)

			if target_pos == null:
				return null

			var speed: float = 1.0

			if cmd.name == "set_npc_position":
				speed = 0.0
			elif params.size() >= 3:
				speed = float(params[2])

			var global_pos = target_pos.global_transform.origin
			path_grounder.set_target_pos(global_pos, speed)

			if speed != 0.0:
				_emit_next_target_reached()
		_:
			return Constants.CMD_RETURN_NONE

	return null
