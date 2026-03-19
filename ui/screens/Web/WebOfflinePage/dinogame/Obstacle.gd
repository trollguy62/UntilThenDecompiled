extends Sprite2D

@export var velocity = Vector2(-130, 0)


func _process(delta):
	translate(velocity * delta)

	if position.y < -20:
		queue_free()
