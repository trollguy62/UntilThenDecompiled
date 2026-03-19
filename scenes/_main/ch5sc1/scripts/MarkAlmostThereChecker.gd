extends Marker3D

@export var sprite_path: NodePath
@export var state_container_path: NodePath

@onready var sprite = get_node(sprite_path) as AnimatedPaper3D
@onready var state_container = get_node(state_container_path) as StateContainer


func _process(_delta):
	var almost_there = sprite.global_transform.origin.x <= global_transform.origin.x
	state_container.dict.set_value("almost_there", almost_there)
