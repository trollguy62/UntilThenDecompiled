extends "res://scenes/_main/ch6sc1a/RpgMinigame/RpgMasher3D.gd"

@onready var animation_player = $AnimationPlayer

@onready var tween = Threen.new()


func shake(double_time = false):
	if double_time:
		animation_player.play("shake2x")
	else:
		animation_player.play("shake")


func stop_animation():
	animation_player.stop()
