@tool
extends Sprite3D

@export var spin_dir: Vector3 = Vector3.BACK
@export var speed: float = 1.0


func _process(delta):
	rotation += spin_dir * speed * delta
