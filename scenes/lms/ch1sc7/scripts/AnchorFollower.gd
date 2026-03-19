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

@onready var parent = get_parent()

var _anchor: Node3D
var _anchor_global_offset := Vector3.ZERO


func _ready():
	self.enabled = enabled


func _process(delta):
	if not _anchor:
		return

	var parent_pos = parent.global_transform.origin
	var anchor_pos = _anchor.global_transform.origin
	var distance = parent_pos.distance_to(anchor_pos)

	if distance > min_follow_distance:
		var target_pos = anchor_pos + _anchor_global_offset
		var dpos = target_pos - parent_pos
		var npos = dpos.normalized() * follow_speed * delta
		var damping = Utils.remap(0.1, 0, 1, 0, dpos.length() - min_follow_distance)
		parent.global_transform.origin += npos * damping


func _set_enabled(value):
	enabled = value
	if parent == null:
		return

	if enabled:
		_anchor = get_node(anchor_path)
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
