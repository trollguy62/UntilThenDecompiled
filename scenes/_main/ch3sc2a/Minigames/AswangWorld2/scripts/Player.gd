extends CharacterBody2D

@export var speed := 160

@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite
@onready var timer_chase = $TimerChase
@onready var footsteps = $Footsteps

var can_move = false

var _idle_frame := 0
var _is_chasing = false


func _ready():
	timer_chase.timeout.connect(_on_timer_chase_timeout)

func _process(delta):
	velocity = Vector2.ZERO
	var play_footsteps = false

	if can_move:
		_move()

		if velocity.length() > 0:
			velocity = velocity * speed
			move_and_slide()
			play_footsteps = true

	if play_footsteps:
		if not footsteps.playing:
			footsteps.play()
			pass
	else:
		footsteps.stop()
		pass


func _move():
	if Input.is_action_pressed("move_down"):
		velocity = Vector2.DOWN
		if not _is_chasing:
			anim.play("f_idle_walk")
		else:
			anim.play("f_chase_walk")
		_idle_frame = 0
	elif Input.is_action_pressed("move_up"):
		velocity = Vector2.UP
		if not _is_chasing:
			anim.play("b_idle_walk")
		else:
			anim.play("b_chase_walk")
		_idle_frame = 4
	elif Input.is_action_pressed("move_right"):
		velocity = Vector2.RIGHT
		if not _is_chasing:
			anim.play("r_idle_walk")
		else:
			anim.play("r_chase_walk")
		_idle_frame = 8
	elif Input.is_action_pressed("move_left"):
		velocity = Vector2.LEFT
		if not _is_chasing:
			anim.play("l_idle_walk")
		else:
			anim.play("l_chase_walk")
		_idle_frame = 8
	else:
		sprite.frame = _idle_frame
		anim.stop()


func chase():
	_is_chasing = true
	timer_chase.start()


func _on_timer_chase_timeout():
	_is_chasing = false
