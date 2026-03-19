@tool
extends MeshInstance3D

@export var speed := 1.0


func _process(delta):
	rotation.y += speed * delta
