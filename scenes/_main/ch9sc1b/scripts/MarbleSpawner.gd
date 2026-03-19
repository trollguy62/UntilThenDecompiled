extends Node3D

@export var marble: PackedScene
@onready var petri_dish = $"../PetriDish"

func _enter_tree():
	if not Engine.is_editor_hint():
		Story.add_command_handler(_run_command)


func _exit_tree():
	if not Engine.is_editor_hint():
		Story.remove_command_handler(_run_command)


func _run_command(cmd: Command):
	if cmd.name == "add_marble":
		spawn_marble()
		return null
	return Constants.CMD_RETURN_NONE


func spawn_marble():
	var instance= marble.instantiate()
	add_child(instance)
	var pos = Vector3(randf_range(-0.04,0.04),0, randf_range(-0.04,0.04))
	instance.global_position.x = petri_dish.position.x + pos.x
	instance.global_position.y = position.y
	instance.global_position.z = petri_dish.position.z + pos.z
