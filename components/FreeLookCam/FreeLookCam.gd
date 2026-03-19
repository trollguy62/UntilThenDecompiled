extends Camera3D

const MOVE_KEYMAP := {
	KEY_W: Vector3.FORWARD,
	KEY_A: Vector3.LEFT,
	KEY_S: Vector3.BACK,
	KEY_D: Vector3.RIGHT,
	KEY_Q: Vector3.DOWN,
	KEY_E: Vector3.UP
}

const PAN_FACTOR = 0.25

@export var lock_rotation := false
@export var move_speed := 1.0
@export var shift_move_speed_multiplier := 4.0
@export var alt_move_speed_multiplier := 0.25
@export var pan_speed := 0.5
@export var mouse_sensitivity := 0.25
@export_range(0, 1) var zoom_factor: float = 0.9

@onready var menu = $Menu

var move_direction := Vector3.ZERO
var pan_direction := Vector3.ZERO
var pivot_length := 1.0
var pan_mouse_relative := Vector2.ZERO


func _input(ev):
	if not is_enabled():
		return

	if ev is InputEventMouseMotion:
		var mouse_rot = Vector2(
			deg_to_rad(-ev.relative.y * mouse_sensitivity), deg_to_rad(-ev.relative.x * mouse_sensitivity)
		)

		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			_rotate_around_self(mouse_rot)
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) and not Input.is_key_pressed(KEY_SHIFT):
			_rotate_around_pivot(mouse_rot)

		pan_mouse_relative = ev.relative
	else:
		pan_mouse_relative = Vector2.ZERO

	if ev is InputEventMouseButton and ev.pressed:
		if ev.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom(true)
		elif ev.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom(false)


func _process(delta):
	if not is_enabled():
		return

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		_move(delta)
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) and Input.is_key_pressed(KEY_SHIFT):
		_pan(delta)


func is_enabled() -> bool:
	return current and (not Game.paused or menu.visible)


func sync_with(camera: Camera3D):
	var env = camera.environment
	if env == null:
		var world = camera.get_world_3d()

		if world.environment != null:
			env = world.environment
		else:
			env = world.fallback_environment

		if env == null:
			env = Environment.new()

	fov = camera.fov
	transform = camera.transform
	environment = env.duplicate()

	if camera.attributes != null:
		attributes = camera.attributes.duplicate()
	else:
		attributes = CameraAttributesPractical.new()


func _move(delta: float):
	var new_direction = Vector3.ZERO
	for keycode in MOVE_KEYMAP:
		if Input.is_key_pressed(keycode):
			new_direction += MOVE_KEYMAP[keycode]

	var speed = move_speed
	if Input.is_key_pressed(KEY_SHIFT):
		speed *= shift_move_speed_multiplier
	if Input.is_key_pressed(KEY_ALT):
		speed *= alt_move_speed_multiplier

	move_direction = lerp(move_direction, new_direction, 0.2)
	translate(move_direction * speed * delta)


func _pan(delta: float):
	var new_direction = Vector3(-pan_mouse_relative.x, pan_mouse_relative.y, 0)
	pan_direction = lerp(pan_direction, new_direction, 0.3)
	translate(pan_direction * pan_speed * PAN_FACTOR * pivot_length * delta)


func _rotate_around_self(mouse_rot: Vector2):
	if lock_rotation:
		return

	rotation.y += mouse_rot.y
	rotation.x += mouse_rot.x
	rotation.x = clamp(rotation.x, -PI / 2, PI / 2)


func _rotate_around_pivot(mouse_rot: Vector2):
	if lock_rotation:
		return

	var p = transform.translated(Vector3.FORWARD * pivot_length)
	_rotate_around(p.origin, p.basis.y.normalized(), mouse_rot.y)
	_rotate_around(p.origin, p.basis.x.normalized(), mouse_rot.x)
	rotation.z = 0


func _rotate_around(point, axis, angle):
	var rotated_basis = transform.basis.rotated(axis, angle)
	var rotated_origin = point + (transform.origin - point).rotated(axis, angle)
	transform = Transform3D(rotated_basis, rotated_origin)


func _zoom(inward: bool):
	var dl = pivot_length

	if inward:
		pivot_length *= zoom_factor
	else:
		pivot_length /= zoom_factor

	dl -= pivot_length
	translate_object_local(Vector3.FORWARD * dl)
