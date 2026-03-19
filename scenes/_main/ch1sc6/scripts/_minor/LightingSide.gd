extends Node3D

@onready var parent: AnimatedPaper3D = get_parent()


func _process(delta):
	visible = parent.animation == "side"
