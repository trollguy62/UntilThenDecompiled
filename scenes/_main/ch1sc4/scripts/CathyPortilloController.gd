@tool
extends Node3D

@export var default_classmate_anim := "default"
@export var equate_classmate_anims: Array[String] = []

@onready var sprite = $Sprite


func _process(delta):
	var animation = sprite.animation
	if animation in equate_classmate_anims:
		_set_classmates_anim(animation)
	else:
		_set_classmates_anim(default_classmate_anim)


func _set_classmates_anim(anim: String):
	for child in get_children():
		if child is AnimatedPaper3D and child != sprite and child.animation != anim:
			child.animation = anim
			child.frame = randi()
