extends CharacterBody2D

@onready var anim = $AnimationPlayer
@onready var timer = $TimerChangeDirection
@onready var areaStomp = $AreaStomp
@onready var areaBody = $AreaBody
@onready var sfx_stomp = $Stomp


var last_pos := Vector2.ZERO
var _speed = 40
var _is_dead: bool


func _ready():
	timer.timeout.connect(_on_timer_timeout)
	areaStomp.body_entered.connect(_on_body_stomp_entered)
	areaBody.body_entered.connect(_on_body_entered)


func enable():
	timer.start()
	_move_left()


func _physics_process(delta):
	move_and_slide()


func _move_left():
	velocity.x = -_speed
	anim.play("walk_left")


func _move_right():
	velocity.x = _speed
	anim.play("walk_right")


func _on_timer_timeout():
	_move_right() if velocity.x < 0 else _move_left()


func _on_body_entered(player: CharacterBody2D):
	if not _is_dead:
		player.damage()


func _on_body_stomp_entered(player: CharacterBody2D):
	if not _is_dead and not player.is_dead:
		_is_dead = true
		sfx_stomp.play()
		player.velocity.y = -200

		$CollisionShape2D.set_deferred("disabled", true)
		areaStomp.get_node("CollisionShape2D").set_deferred("disabled", true)
		set_physics_process(false)
		scale = Vector2(1, 0.3)

		anim.stop()
		timer.stop()

		await Utils.wait(1)
		queue_free()
