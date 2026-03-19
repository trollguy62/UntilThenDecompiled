extends Node

# This script basically interpolates mutiple values by reusing Animation

const PathGrounder = preload("res://components/PathGrounder.gd")

@export var prog_animation_player_path: NodePath
@export var prog_animation_name = ""
@export_range(0.0, 1.0) var prog_min_unit_offset = 0.0
@export_range(0.0, 1.0) var prog_max_unit_offset = 1.0

@onready var path_grounder = get_parent() as PathGrounder

var _prog_anim: Animation
var _value_tracks := []  # [int (track_idx), Node, String (prop)][]


func _ready():
	assert(path_grounder is PathGrounder)
	assert(prog_min_unit_offset <= prog_max_unit_offset)

	var anim_player = get_node(prog_animation_player_path) as AnimationPlayer
	_prog_anim = anim_player.get_animation(prog_animation_name)
	var _anim_root = anim_player.get_parent()
	assert(_prog_anim.length == 1.0)

	for i in range(_prog_anim.get_track_count()):
		if _prog_anim.track_get_type(i) != Animation.TYPE_VALUE:
			continue

		var abs_path = _prog_anim.track_get_path(i)
		var prop = abs_path.get_concatenated_subnames()
		var node_path = str(abs_path).trim_suffix(":" + prop)
		var node = _anim_root.get_node(node_path)

		_value_tracks.append([i, node, prop])


func _process(delta):
	var t = clamp(
		inverse_lerp(prog_min_unit_offset, prog_max_unit_offset, path_grounder.path_unit_offset),
		0,
		1
	)


	for vt in _value_tracks:
		var value = _prog_anim.value_track_interpolate(vt[0], t)
		vt[1].set_indexed(NodePath(vt[2]), value)
