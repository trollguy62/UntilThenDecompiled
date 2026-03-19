extends Node3D

@export var laser_pos: Array[Vector3]

@onready var sprite = get_parent()
@onready var laser_light = $LaserLight


func _ready():
	sprite.frame_changed.connect(_on_frame_changed)


func _on_frame_changed():
	if visible:
		position = laser_pos[sprite.frame]

	if(sprite.frame == 3):
		laser_light.visible = !laser_light.visible
