extends Node2D

signal mashed


func _unhandled_input(event):
	if event.is_action_pressed("c_interact") or event.is_action_pressed("interact"):
		emit_signal("mashed")
