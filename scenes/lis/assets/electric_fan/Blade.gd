@tool
extends Sprite3D

@export var speed = 10.0


func _process(delta):
	rotation.z += speed * delta
