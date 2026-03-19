extends Node2D

@onready var world_env = $WorldEnvironment


func _ready():
	remove_child(world_env)


func _process(delta):
	var visible_in_tree = is_visible_in_tree()

	if visible_in_tree != world_env.is_inside_tree():
		if visible_in_tree:
			add_child(world_env)
		else:
			remove_child(world_env)
