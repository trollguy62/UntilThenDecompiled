extends Sprite2D

const FLASH_DURATION = 0.1

signal fire
signal fade_in
signal fade_out

const Focus = preload("res://components/Focus.gd")

@onready var tween = Threen.new()

@export var noise_octaves := 4
@export var noise_period := 20.0
@export var noise_persistence := 0.8
@export var noise_magnitude := 0.0

var noisy : float
var noise = FastNoiseLite.new()
var is_player_active: bool
var base_pos: Vector2
var constraint: Sprite2D
var force_shake: bool
var target_lock: bool
var fade_duration: float
var default_pos: Vector2
var joystick_aim_speed: float
var focus: Focus


func _ready():
	add_child(tween)
	set_process(false)
	set_process_input(false)
	modulate = Color.TRANSPARENT
	default_pos = position


func start(is_player):
	is_player_active = is_player
	set_process(true)
	set_process_input(true)
	_fade_in()


func stop():
	set_process(false)
	set_process_input(false)
	is_player_active = false
	_fade_out()


func _process(delta):
	if is_player_active:
		if not target_lock and focus.is_active():
			if _is_joypad_connected():
				base_pos += _get_joystick_direction() * delta * joystick_aim_speed
			_constraint_crosshair()

		var noise_x = _get_noise() * noise_magnitude
		var noise_y = _get_noise() * noise_magnitude
		var shake_pos = Vector2(base_pos.x + noise_x, base_pos.y + noise_y)
		position = shake_pos


func flash():
	_set_flash(true)
	await Utils.wait(FLASH_DURATION)
	_set_flash(false)


func _set_flash(enabled: bool):
	(material as ShaderMaterial).set_shader_parameter("flash", enabled)


func _constraint_crosshair():
	var board_base_pos = constraint.position
	var width = constraint.texture.get_width() * 3.2
	var height = constraint.texture.get_height() * 3.2

	base_pos.x = clamp(base_pos.x, board_base_pos.x + 60, width)
	base_pos.y = clamp(base_pos.y, board_base_pos.y + 60, height)


func _get_noise() -> float:
	noise.seed = randi()
	return noise.get_noise_2d(position.x, position.y)


func _input(event):
	if not focus.is_active():
		return

	if event is InputEventMouseButton and is_player_active:
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			fire.emit()

	if not target_lock and focus.is_active() and is_player_active and event is InputEventMouseMotion:
		base_pos = get_viewport().get_mouse_position()
		_constraint_crosshair()

	if event.is_action_pressed("interact") and is_player_active:
		fire.emit()


func get_random_angle():
	return randf_range(-180, 180)


func get_distance(weight):
	return lerp(80, 0, weight)


func shift_shake_strength(strength, duration):
	tween.interpolate_property(self, "noise_magnitude", float(noise_magnitude), float(strength), duration)
	tween.start()


func _fade_out():
	tween.interpolate_property(
		self,
		"modulate",
		modulate,
		Color.TRANSPARENT,
		fade_duration,
		Threen.TRANS_CUBIC,
		Threen.EASE_IN_OUT
	)
	tween.start()

	await Utils.wait(fade_duration)
	fade_out.emit()


func _fade_in():
	tween.interpolate_property(
		self, "modulate", modulate, Color.WHITE, fade_duration, Threen.TRANS_CUBIC, Threen.EASE_IN_OUT
	)
	tween.start()

	await Utils.wait(fade_duration)
	fade_in.emit()


func to_default_position():
	position = default_pos


func _is_joypad_connected() -> bool:
	return not Input.get_connected_joypads().is_empty()


func _get_joystick_direction() -> Vector2:
	var axis_h = Input.get_joy_axis(0,  JOY_AXIS_LEFT_X)
	var axis_v = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	return Vector2(axis_h, axis_v)
