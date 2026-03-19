extends "res://components/Grounder.gd"

signal target_reached

@export var offset_speed = 0.0

@export var path_node: NodePath:
	set(value):
		path_node = value

		if path_follow:
			var old_path = path
			path = get_node(path_node)

			if path_follow.get_parent() != null:
				path_follow.reparent(path)

			if old_path != null and path != null:
				var pos = parent.global_transform.origin - path.global_transform.origin
				self.path_offset = path.curve.get_closest_offset(pos)

@export var global_offset = Vector3()

@export var path_offset = 0.0:
	set(value):
		path_offset = value

		if path_follow != null:
			value = normalize_offset(value)
			delta_offset = value - path_follow.progress
			path_follow.progress = value
	get:
		return path_follow.progress if _is_ready else path_offset

@export var path_unit_offset = 0.0:
	set(value):
		value = normalize_unit_offset(value)
		path_unit_offset = value

		if path != null and path_follow != null:
			var path_length = path.curve.get_baked_length()
			delta_offset = (value - path_follow.progress_ratio) * path_length
			path_follow.progress_ratio = value
	get:
		return path_follow.progress_ratio if _is_ready else path_unit_offset

@export var loop := false
@export_range(0.0, 1024.0) var loop_interval_min: float = 0.0
@export_range(0.0, 1024.0) var loop_interval_max: float = 0.0

@onready var path_follow = PathFollow3D.new()
@onready var pivot = Node3D.new()
@onready var loop_timer = Timer.new()

var path: Path3D
var delta_offset := 0.0
var delta_global_position: Vector3:
	get:
		return Vector3.ZERO - test_delta_global_position(-delta_offset)

var _target_offset := -1.0
var _target_offset_speed := 0.0
var _is_ready := false


func _ready():
	super._ready()

	if path == null:
		self.path_node = path_node

	path.add_child(path_follow)
	path_follow.add_child(pivot)

	loop_timer.one_shot = true
	add_child(loop_timer)

	path_follow.rotation_mode = PathFollow3D.ROTATION_NONE
	path_follow.loop = false

	if path_offset > 0:
		self.path_offset = path_offset
	if path_unit_offset > 0:
		self.path_unit_offset = path_unit_offset

	_is_ready = true

	_force_update()


func _pre_physics_process(delta):
	if has_target():
		_pre_physics_process_target(delta)
	elif loop:
		_pre_physics_process_looping(delta)
	else:
		self.path_offset += offset_speed * delta

	var pos = pivot.global_transform.origin + global_offset
	parent.global_transform.origin = pos


func _pre_physics_process_target(delta):
	var path_len = path.curve.get_baked_length()
	var d = _target_offset - self.path_offset
	var dir = sign(d)
	var invert = false

	if abs(d) < Constants.EPSILON:
		target_reached.emit()
		clear_target()
		return

	if loop:
		var alt_d = path_len - abs(d)
		invert = alt_d < abs(d)

	dir *= -1 if invert else 1
	var doffset = _target_offset_speed * delta * dir
	var offset = self.path_offset + doffset
	var offset_neg = path_len if invert else 0.0

	if doffset > 0:
		offset = min(offset - offset_neg, _target_offset)
	else:
		offset = max(offset, _target_offset - offset_neg)

	if loop:
		offset = fposmod(offset, path_len)

	self.path_offset = offset


func _pre_physics_process_looping(delta):
	if loop_timer.time_left > 0:
		return

	var offset0 = path_offset
	self.path_offset += offset_speed * delta
	var offset1 = path_offset

	var did_loop = (
		(offset_speed > 0 and offset1 < offset0)
		or (offset_speed < 0 and offset1 > offset0)
	)

	if did_loop:
		var time_sec = randf_range(loop_interval_min, loop_interval_max)
		loop_timer.start(max(0.0001, time_sec))


func set_target_offset(offset: float, speed: float):
	if speed == 0:
		self.path_offset = offset
	else:
		_target_offset = normalize_offset(offset)
		_target_offset_speed = abs(speed)


func set_target_unit_offset(unit_offset: float, speed: float):
	if path and path.curve:
		var offset = path.curve.get_baked_length() * unit_offset
		set_target_offset(offset, speed)


func set_target_pos(global_pos: Vector3, speed: float):
	var offset = get_closest_offset(global_pos)
	set_target_offset(offset, speed)


func get_closest_offset(global_pos: Vector3) -> float:
	var local_pos = global_pos - path.global_transform.origin
	return path.curve.get_closest_offset(local_pos)


func get_offset_global_position(offset: float) -> Vector3:
	var local_pos = path.curve.sample_baked(offset, true)
	return local_pos + path.global_transform.origin


func clear_target():
	_target_offset = -1.0
	_target_offset_speed = 0.0


func has_target() -> bool:
	return _target_offset >= 0 and _target_offset_speed > 0


func normalize_offset(offset: float):
	if path and path.curve:
		var length = path.curve.get_baked_length()

		if loop:
			return fposmod(offset, length)
		else:
			return clamp(offset, 0, length)

	return max(0, offset)


func normalize_unit_offset(value):
	if loop:
		return fposmod(value, 1.0)
	else:
		return clamp(value, 0, 1)


func _force_update():  # TODO hacky
	path_follow.progress += 0.01
	path_follow.progress -= 0.01


func test_delta_global_position(delta_offset: float) -> Vector3:
	var offset0 = path_offset
	var offset1 = offset0 + delta_offset

	if loop:
		offset0 = fposmod(offset0, path.curve.get_baked_length())

	var p0 = path.curve.sample_baked(offset0, true)
	var p1 = path.curve.sample_baked(offset1, true)
	return p1 - p0
