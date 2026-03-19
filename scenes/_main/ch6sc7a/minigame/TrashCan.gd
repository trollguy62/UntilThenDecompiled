extends Node2D

@onready var spr = $Sprite


func _ready():
	spr.animation_finished.connect(_on_animation_finished)


func rattle():
	spr.animation = "rattle"
	spr.play()
	$sfx.play()


func _on_animation_finished():
	spr.frame = 0
	spr.stop()
