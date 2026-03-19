extends CharacterBody2D

signal dead(is_cliff)

const cliff_y := 900

@export var run_speed : int = 100
@export var jump_speed : int = -400
@export var gravity : int = 1200

@onready var sprite = $Sprite
@onready var anim = $AnimationPlayer
@onready var sfx_jump = $Jump
@onready var sfx_dead = $Dead

var _is_facing_left: bool
var allow_control = true
var is_dead: bool


func _physics_process(delta):
	velocity.x = 0
	_control_player(delta)

	move_and_slide()


func _control_player(delta):
	velocity.y += gravity * delta

	if not allow_control:
		return

	var jump = Input.is_action_just_pressed("ui_select")

	if jump and is_on_floor():
		velocity.y = jump_speed
		anim.play("jump")
		sfx_jump.play()

	if Input.is_action_pressed("move_right"):
		_move("right")

	if Input.is_action_pressed("move_left"):
		_move("left")

	if Input.is_action_just_released("ui_right") or Input.is_action_just_released("ui_left"):
		anim.stop()
		sprite.frame = 46

	if position.y > cliff_y:
		dead.emit(true)
		set_physics_process(false)


func _move(direction: String):
	var is_left = direction == "left"

	velocity.x = (velocity.x - run_speed) if is_left else (velocity.x + run_speed)
	sprite.flip_h = is_left
	_is_facing_left = is_left

	if is_on_floor():
		anim.play("walk")
	else:
		if anim.current_animation == "walk":
			anim.play("jump")


func damage():
	allow_control = false
	is_dead = true

	anim.play("dead")
	velocity.y = -400
	$CollisionShape2D.set_deferred("disabled", true)

	sfx_dead.play()
	dead.emit(false)
