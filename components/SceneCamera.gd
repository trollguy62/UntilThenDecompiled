extends Camera3D

@export var shot := ""
@export_range(0.0, 1.0) var mouse_offset_strength = 0.0

@export var shake_offset := Vector2.ZERO
@export_range(0.0, 16.0) var shake_speed = 0.0

@export var wiggle_offset := Vector2.ZERO
@export_range(0.0, 16.0) var wiggle_speed = 0.0

@export var decorative := false

@onready var manager: SceneManager = Service.of("SceneManager")
@onready var viewport := get_viewport()

@export var c = 0.01
@export var p = 2.28
@export var far_distance_k = 0.015 #1.5%, use far distance to clamp mouse offset val if it exists
@export var far_distance_thres = 0.7 #m

var offset_mult:
	get:
		return _get_mouse_offset_mult()

var _shake_t := 0.0
var _wiggle_t := 0.0

var _mouse_offset := Vector2.ZERO
var _mouse_target_offset := Vector2.ZERO
var _shake_noise = FastNoiseLite.new()

var _skit_container: SkitContainer


func _ready():
	if shot == "":
		shot = name

	if not decorative:
		manager.shot_changed.connect(_on_shot_changed)


func _skit_ready(skit_container: SkitContainer):
	_skit_container = skit_container


func _on_shot_changed(shot: String):
	# When under an inactive skit, do not attempt to change current camera
	if _skit_container != null and is_instance_valid(_skit_container):
		if not _skit_container.is_running:
			return

	if shot == self.shot and not current:
		await get_tree().process_frame  # Make time for shot-dependent nodes to prepare
		current = true


func _process(delta):
	_shake_t += delta * shake_speed
	_wiggle_t += delta * wiggle_speed

	var offset = Vector2.ZERO
	offset += _get_mouse_offset()
	offset += _get_shake_offset()
	offset += _get_wiggle_offset()

	if offset.length() > 0:
		h_offset = offset.x
		v_offset = offset.y


func _get_mouse_offset() -> Vector2:
	var offset0 = _mouse_offset

	var viewport_size = viewport.size
	var offset1 = viewport.get_mouse_position().clamp(Vector2.ZERO, viewport_size)
	offset1 = ((offset1 / Vector2(viewport_size)) - Vector2.ONE / 2.0) * 2.0

	var mouse_offset_mult: float
	#override if it is set, or if it might be a c3d camera
	if mouse_offset_strength > 0.0 or _is_likely_c3d_cam():
		mouse_offset_mult = mouse_offset_strength
	else:
		mouse_offset_mult = _get_mouse_offset_mult()

	offset1 *= Vector2(-1, 1) * mouse_offset_mult

	_mouse_offset = lerp(offset0, offset1, 0.05)
	_mouse_target_offset = offset1
	return _mouse_offset


func _is_likely_c3d_cam():
	return name.to_lower().contains("c3d")


func _get_mouse_offset_mult():
	var mult = c * fov / 70.0 * p
	if attributes != null and attributes.dof_blur_far_enabled:
		var dof_dist = attributes.dof_blur_far_distance
		if dof_dist < far_distance_thres:
			var dof_mult = max(0, clamp(dof_dist, far_distance_k * dof_dist, -far_distance_k * dof_dist))
			mult = min(mult, dof_mult)

	return mult


func _get_shake_offset() -> Vector2:
	var t = _shake_t * 128.0
	var dx = _shake_noise.get_noise_2d(t, 0)
	var dy = _shake_noise.get_noise_2d(0, t)
	return Vector2(dx, dy) * shake_offset


func _get_wiggle_offset() -> Vector2:
	var t = _wiggle_t
	var a = 3.0  # Based on Lissajous curve
	var b = 4.0
	return Vector2(sin(a * t + PI / 2.0), sin(b * t)) * wiggle_offset
