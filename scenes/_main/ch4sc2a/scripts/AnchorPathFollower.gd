extends Node

@export var enabled := false:
	set = _set_enabled,
	get = _get_enabled

@export var anchor_path: NodePath
@export var min_follow_distance := 1.0
@export var follow_speed := 1.0

@export var keep_x_offset := false
@export var keep_y_offset := false
@export var keep_z_offset := false

@export var path_mode := false:
	set = _set_path_mode,
	get = _get_path_mode

@export var path_path: NodePath
@export var path_loop := false
@export var path_nav_speed := 1.0
@export var target_path_offset := -1.0
@export var target_reached_story_signal := ""

@onready var parent = get_parent()

var _anchor: Node3D
var _anchor_global_offset := Vector3.ZERO

var _path: Path3D
var _path_offset := 0.0
var _path_global_offset := Vector3.ZERO


func _ready():
	self.enabled = enabled
	self.path_mode = path_mode


func _process(delta: float):
	if not _anchor:
		return

	var parent_pos = parent.global_transform.origin
	var anchor_pos = _anchor.global_transform.origin
	var distance = parent_pos.distance_to(anchor_pos)

	if path_mode and parent.is_visible_in_tree():
		if abs(_path_offset - target_path_offset) <= Constants.EPSILON:
			target_path_offset = -1.0

			if target_reached_story_signal != "":
				Story.emit(target_reached_story_signal)

		if target_path_offset >= 0:
			_process_path_target(delta)

	elif distance > min_follow_distance:
		var target_pos = anchor_pos + _anchor_global_offset
		var dpos = target_pos - parent_pos
		var npos = dpos.normalized() * follow_speed * delta
		var damping = Utils.remap(0.1, 0, 1, 0, dpos.length() - min_follow_distance)
		parent.global_transform.origin += npos * damping


func _process_path_target(delta: float):
	var path_len = _path.curve.get_baked_length()
	var offset0 = _path_offset
	var offset_dist = target_path_offset - _path_offset
	var invert = false

	if path_loop:
		var alt_dist = path_len - abs(offset_dist)
		invert = alt_dist < abs(offset_dist)

	var dir = sign(offset_dist) * (-1 if invert else 1)
	var doffset = path_nav_speed * delta * dir
	var offset1 = offset0 + doffset
	var offset_neg = path_len if invert else 0

	if doffset > 0:
		offset1 = min(offset1 - offset_neg, target_path_offset)
	else:
		offset1 = max(offset1, target_path_offset - offset_neg)

	_path_offset = fposmod(offset1, path_len)

	var target_pos = _path.curve.sample_baked(_path_offset, true)
	parent.global_transform.origin = target_pos + _path_global_offset


func set_path_target(global_pos: Vector3):
	target_path_offset = _path.curve.get_closest_offset(global_pos)


func _set_enabled(value):
	enabled = value
	if parent == null:
		return

	if enabled:
		_anchor = get_node(anchor_path) as Node3D
		_path = get_node(path_path) as Path3D

		var dvec = parent.global_transform.origin - _anchor.global_transform.origin
		_anchor_global_offset = Vector3(
			dvec.x if keep_x_offset else 0,
			dvec.y if keep_y_offset else 0,
			dvec.z if keep_z_offset else 0
		)
	else:
		_anchor = null
		_anchor_global_offset = Vector3.ZERO


func _get_enabled():
	return enabled


func _set_path_mode(value):
	path_mode = value
	if parent == null:
		return

	var parent_pos = parent.global_transform.origin
	var path_closest_point = _path.curve.get_closest_point(parent_pos)

	_path_offset = _path.curve.get_closest_offset(parent_pos)
	_path_global_offset = parent_pos - path_closest_point


func _get_path_mode():
	return path_mode
