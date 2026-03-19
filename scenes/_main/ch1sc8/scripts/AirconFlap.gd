@tool
extends MeshInstance3D

var t := 0.0
@export var swing = 35.0
@export var speed = 0.8


func _process(delta):
	t += delta
	rotation_degrees.z = sin(t * speed) * swing
