extends Node

@export var path: Node

@onready var grounder = $"../PathGrounder"

func _process(delta):
	path.progress = grounder.path_offset

