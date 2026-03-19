extends Node2D

enum State { IDLE, MOVE, HIT }

@export var hit_cooldown: float = 1

@onready var hammer: AnimatedSprite2D = $HammerSprite
@onready var hit_timer: Timer = $Timer
@onready var collider = $hit_collider
@onready var mole_manager = $"../MoleManager"
@onready var tween = Threen.new()

var state = State.IDLE
var min_travel_speed = 0.2
var max_travel_speed = 0.5
var min_search_speed = 0.3
var max_search_speed = 0.5
var float_speed = 3
var angle = 0
var avoid_chance = 0.8


func _ready():
	add_child(tween)
	hammer.frame_changed.connect(_on_frame_changed)
	hit_timer.timeout.connect(_on_timer_timeout)
	hit_timer.start(hit_cooldown)


func _process(delta):
	if state != State.IDLE:
		return

	angle += (float_speed * delta)
	position.x = sin(angle) + position.x


func _on_timer_timeout():
	if state != State.IDLE:
		return

	move_to_target()


func move_to_target():
	var target_mole = mole_manager.get_random_active_mole()
	if target_mole == null:
		return

	if should_avoid(target_mole):
		return

	state = State.MOVE
	var speed = randf_range(min_travel_speed, max_travel_speed)
	tween.interpolate_property(
		self,
		"position",
		global_position,
		target_mole.global_position,
		speed,
		Threen.TRANS_LINEAR,
		Threen.EASE_IN_OUT
	)
	tween.start()

	await tween.tween_completed
	whack()


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


func should_avoid(mole):
	if mole.score < 0:
		if randf() < avoid_chance:
			return true


func whack():
	state = State.HIT
	hammer.play("whack")

	await hammer.animation_finished
	idle()


func idle():
	hammer.play("idle")
	var speed = randf_range(min_search_speed, max_search_speed)
	hit_timer.start(speed)
	state = State.IDLE
