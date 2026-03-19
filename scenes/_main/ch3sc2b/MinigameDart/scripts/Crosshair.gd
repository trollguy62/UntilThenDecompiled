extends Sprite2D

signal fire
signal fade_in
signal fade_out

const Focus = preload("res://components/Focus.gd")

@export var noise_octaves := 4
@export var noise_period := 20.0
@export var noise_persistence := 0.8
@export var noise_magnitude := 0

@onready var tween = Threen.new()

var board_pos: Vector2
var board_radius: float
var noise: FastNoiseLite
var started: bool
var in_focus: bool
var is_player_active: bool
var target_lock: bool
var fade_duration: float
var joystick_aim_speed: float
var focus: Focus
var base_pos: Vector2


func _ready():
	add_child(tween)
	noise = FastNoiseLite.new()
	set_process(false)
	modulate = Color.TRANSPARENT


func start(is_player):
	is_player_active = is_player
	started = true
	in_focus = true
	target_lock = false
	set_process(true)
	_fade_in()


func stop():
	set_process(false)
	in_focus = false
	_fade_out()


func _process(delta):
	if not in_focus or not focus.is_active():
		return

	if is_player_active:
		if not target_lock:
			if _is_joypad_connected():
				base_pos += _get_joystick_direction() * delta * joystick_aim_speed
			_constraint_crosshair()

		var noise_x = _get_noise() * noise_magnitude
		var noise_y = _get_noise() * noise_magnitude
		var shake_pos = Vector2(base_pos.x + noise_x, base_pos.y + noise_y)
		position = shake_pos


func _get_noise() -> float:
	noise.seed = randi()
	return noise.get_noise_2d(position.x, position.y)


func _constraint_crosshair():
	var distance = base_pos.distance_to(board_pos)

	if distance > board_radius:
		var z = base_pos - board_pos
		z *= board_radius / distance
		base_pos = board_pos + z

	position = base_pos


func _input(event):
	if event is InputEventMouseButton and is_player_active and started:
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			fire.emit()

		if not target_lock:
			base_pos = position

	if not target_lock and focus != null and focus.is_active() \
			and is_player_active and event is InputEventMouseMotion:
		base_pos = get_viewport().get_mouse_position()
		_constraint_crosshair()

	if event.is_action_pressed("interact") and is_player_active:
		fire.emit()

		if not target_lock:
			base_pos = position


func get_random_angle():
	return randf_range(-180, 180)


func get_distance(weight):
	return lerp(200, -5, weight)


func shift_shake_strength(strength, duration):
	tween.interpolate_property(
		self,
		"noise_magnitude",
		float(noise_magnitude),
		float(strength),
		duration,
		Threen.TRANS_LINEAR,
		Threen.EASE_IN_OUT
	)
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


func _is_joypad_connected() -> bool:
	return not Input.get_connected_joypads().is_empty()


func _get_joystick_direction() -> Vector2:
	var axis_h = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	var axis_v = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	return Vector2(axis_h, axis_v)
