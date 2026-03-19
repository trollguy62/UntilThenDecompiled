extends Node3D


func _ready():
	await Story.wait_for("free_set_1")
	queue_free()
