extends Control

@onready var anim_player = $AnimationPlayer

func fade_in():
	anim_player.play("fade_in")

func fade_out():
	anim_player.play("fade_out")
