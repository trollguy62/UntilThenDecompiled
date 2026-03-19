extends Node3D

@export var sync_position_x: Array[float]
@onready var manager: SceneManager = Service.of("SceneManager")

@onready var sprite = get_parent()

var enabled = false


func _ready():
	sprite.frame_changed.connect(_on_frame_changed)
	manager.shot_changed.connect(_on_shot_changed)


func _on_frame_changed():
	if enabled:
		position.x = sync_position_x[sprite.frame]


func _on_shot_changed(shot: String):
	if shot == "CamSS_Laser":
		enabled = false
	else:
		enabled = true
		
