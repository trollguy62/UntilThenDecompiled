extends Node3D

@export var move_dir = Vector3()
@export var speed = 1.0


func _process(delta):
	translate(move_dir * speed * delta)
