class_name Mole
extends Area2D

signal mole_hit(score)

enum State {
	IDLE,
	READY,
	APPEAR,
	HIDE
}

@export var mole_type : Array[Resource]= []

@onready var timer = $Timer
@onready var mole_sprite = $MoleSprite
@onready var animation_player = $AnimationPlayer

@onready var pop_sfx = $Pop
@onready var whack_sfx = $Whack
@onready var boing_sfx = $Boing

var state = State.IDLE
var hittable = false
var min_time_to_appear
var max_time_to_appear
var time_exposed
var score

func _ready():
	timer.timeout.connect(on_timer_timeout)
	hide_mole()

func on_timer_timeout():
	match state:
		State.READY:
			appear()
		State.APPEAR:
			hide_mole()

func prepare_to_appear():
	if not state == State.IDLE:
		return

	state = State.READY
	set_mole_type()
	var time_to_appear = randf_range(min_time_to_appear,max_time_to_appear)
	timer.start(time_to_appear)

func appear():
	visible = true
	state = State.APPEAR
	mole_sprite.play("show")
	timer.start(time_exposed)
	pop_sfx.play()

	await mole_sprite.animation_finished
	hittable = true

func hide_mole():
	state = State.HIDE
	mole_sprite.play("hide")
	timer.stop()
	hittable = false

	await mole_sprite.animation_finished
	idle()

func idle():
	state = State.IDLE
	visible = false

func set_mole_type():
	var mole_data = get_random_mole_type()
	min_time_to_appear = mole_data.min_time_to_appear
	max_time_to_appear = mole_data.max_time_to_appear
	time_exposed = mole_data.time_exposed
	score = mole_data.score
	mole_sprite.frames = mole_data.sprite_frames

func take_hit():
	if not hittable:
		return
	animation_player.play("hit")
	whack_sfx.play()

	if randf() < 0.1:
		boing_sfx.play()

	hide_mole()
	mole_hit.emit(score)

func is_appear():
	return state == State.APPEAR

func get_random_mole_type():
	var weights_sum = 0
	for mole in mole_type:
		weights_sum += mole.appear_chance

	var remaining_distance = randf() * weights_sum
	for i in mole_type.size():
		remaining_distance -= mole_type[i].appear_chance
		if(remaining_distance<0):
			return mole_type[i]

	return mole_type[0]
