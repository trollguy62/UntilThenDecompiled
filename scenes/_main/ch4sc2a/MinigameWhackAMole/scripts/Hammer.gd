extends Node2D

@export var joystick_aim_speed := 1000
@export var hit_cooldown: float = 1

@onready var hammer: AnimatedSprite2D = $HammerSprite
@onready var hit_timer: Timer = $Timer
@onready var collider = $hit_collider

var is_player_active: bool
var can_hit: bool


func _ready():
	is_player_active = true
	hammer.frame_changed.connect(_on_frame_changed)
	hit_timer.timeout.connect(_on_timer_timeout)
	hit_timer.start(hit_cooldown)


func _process(delta):
	move_hammer(delta)


func move_hammer(delta):
	if _is_joypad_connected():
		position += _get_joystick_direction() * delta * joystick_aim_speed
	else:
		position = get_viewport().get_mouse_position()


func _is_joypad_connected() -> bool:
	return Input.get_joy_name(0) != "" and false


func _input(event):
	if event is InputEventMouseButton and is_player_active:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			whack()

	if Input.is_joy_button_pressed(0, 1) and is_player_active:
		whack()


func _on_timer_timeout():
	can_hit = true


func _on_frame_changed():
	if hammer.animation == "whack":
		if hammer.frame == 3:
			check_hit()


func check_hit():
	var hit_list = collider.get_overlapping_areas()
	for hit in hit_list:
		if hit is Mole:
			hit.take_hit()
			return


func whack():
	if can_hit:
		can_hit = false
		hammer.play("whack")
		await hammer.animation_finished
		hammer.play("idle")
		hit_timer.start(hit_cooldown)


func _get_joystick_direction() -> Vector2:
	var axis_h = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	var axis_v = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	return Vector2(axis_h, axis_v)
