extends Node3D

@onready var manager = Service.of("SceneManager")


func _process(_delta):
	visible = manager.shot == "CloseUp"
