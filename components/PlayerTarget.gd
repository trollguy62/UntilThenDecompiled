extends Node3D

signal changed


func change(target: Node3D):
	global_transform = target.global_transform
	changed.emit()
