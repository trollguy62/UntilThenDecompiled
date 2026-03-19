extends Sprite2D

const FLASH_DURATION = 0.2

signal fire
signal fade_out
signal fade_in

const Balloon = preload("res://scenes/_main/ch3sc2b/MinigameBalloon/scripts/Balloon.gd")
const Focus = preload("res://components/Focus.gd")

@export var noise_octaves := 4
@export var noise_period := 20.0
@export var noise_persistence := 0.8
@export var noise_magnitude := 0

@onready var tween = Threen.new()
@onready var area = $Area2D

var noise: FastNoiseLite
var balloons_placeholder: Sprite2D
var balloon: Balloon
var is_player_active: bool
var force_shake: bool
var base_pos: Vector2
var fade_duration: float
var is_tugging: bool
var joystick_aim_speed: float
var focus: Focus


func _ready():
	add_child(tween)
	noise = FastNoiseLite.new()
	modulate = Color.TRANSPARENT
	set_process(false)

	area.area_entered.connect(_on_area_entered)
	area.area_exited.connect(_on_area_exited)


func start(is_player, force_shake = false):
	is_player_active = is_player
	self.force_shake = force_shake
	set_process(true)
	_fade_in()


func stop():
	set_process(false)
	_fade_out()


func flash():
	_set_flash(true)
	await Utils.wait(FLASH_DURATION)
	_set_flash(false)


func _set_flash(enabled: bool):
	(material as ShaderMaterial).set_shader_parameter("flash", enabled)


func _process(delta):
	if is_player_active and focus.is_active():
		if _is_joypad_connected():
			base_pos += _get_joystick_direction() * delta * joystick_aim_speed
	else:
		base_pos = position

	var balloons_base_pos = balloons_placeholder.position
	var width = balloons_placeholder.texture.get_width() * 4
	var height = balloons_placeholder.texture.get_height() * 4

	base_pos.x = clamp(base_pos.x, balloons_base_pos.x + 30, width)
	base_pos.y = clamp(base_pos.y, balloons_base_pos.y, height + 70)

	if is_player_active or force_shake:
		var noise_x = _get_noise() * noise_magnitude
		var noise_y = _get_noise() * noise_magnitude
		var shake_pos = Vector2(base_pos.x + noise_x, base_pos.y + noise_y)
		position = shake_pos
	else:
		position = base_pos


func _input(event):
	if not focus.is_active():
		return

	if event is InputEventMouseButton and is_player_active:
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			fire.emit()

	if is_player_active and focus.is_active() and event is InputEventMouseMotion:
		base_pos = get_viewport().get_mouse_position()

	if event.is_action_pressed("interact") and is_player_active:
		fire.emit()


func _get_noise() -> float:
	noise.seed = randi()
	return noise.get_noise_2d(position.x, position.y)


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


func _is_joypad_connected() -> bool:
	return not Input.get_connected_joypads().is_empty()


func _get_joystick_direction() -> Vector2:
	var axis_h = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	var axis_v = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	return Vector2(axis_h, axis_v)


func _on_area_entered(area):
	var area_parent = area.get_parent()
	if area_parent is Balloon:
		balloon = area_parent


func _on_area_exited(area):
	balloon = null
