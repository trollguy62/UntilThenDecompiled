extends Node3D

@onready var sprite = $Sprite
@onready var path_grounder = $PathGrounder

@export var speed_base := 1.0
@export var speed_per_frame: Array[float] = []


func _process(delta):
	path_grounder.offset_speed = speed_per_frame[sprite.frame] * speed_base
