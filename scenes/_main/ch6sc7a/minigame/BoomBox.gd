extends Node2D

@onready var spr = $Sprite


func beat():
	spr.animation = "boom"
	await get_tree().create_timer(0.2).timeout
	spr.animation = "idle"


func unbeat():
	spr.animation = "idle"
