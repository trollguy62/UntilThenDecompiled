extends AnimatedSprite2D

const GROUND_Y = 58

const Obstacle = preload("res://ui/screens/Web/WebOfflinePage/dinogame/Obstacle.gd")

@onready var area = $Area2D

var velocity := Vector2.ZERO


func _ready():
	area.area_entered.connect(_on_collided)


func _process(delta):
	velocity += Vector2.DOWN * 15
	if Input.is_action_just_pressed("interact") and is_on_floor():
		jump()

	translate(velocity * delta)
	position.y = min(position.y, GROUND_Y)

	animation = "run" if is_on_floor() else "idle"
	play(animation)


func is_on_floor():
	return position.y >= GROUND_Y


func _on_collided(area: Area2D):
	get_parent().stop()

func jump():
	velocity = Vector2.UP * 250
