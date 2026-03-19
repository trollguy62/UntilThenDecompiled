extends Node

const ground_types: Dictionary = {
	"Soil": 0, "Concrete": 1, "Grass": 2, "WoodBridge": 3, "CreakyWood": 4, "Default": 0
}  #these are set in fmod

@export var triggerable_areas: Array = []  # Array of NodePaths #maybe just using string and then disambiguating by node name is better
@export var mark_footsteps_nodepath: NodePath

@onready var footsteps = get_node_or_null(mark_footsteps_nodepath)

var sfx_stack = ["Default"]  #Array of strings


func _ready():
	assert(footsteps)


func _skit_start(skit_container: SkitContainer):
	for node_path in triggerable_areas:
		var area = get_node_or_null(node_path)
		assert(area is Area3D)
		if area is Area3D:
			area.area_entered.connect(_on_area_entered.bind(area.ground_type))
			area.area_exited.connect(_on_area_exited.bind(area.ground_type))


func _on_area_entered(area: Area3D, which: String):
	footsteps.set_parameter("GroundType", ground_types[which])
	if not sfx_stack.has(which):
		sfx_stack.push_back(which)


func _on_area_exited(area: Area3D, which: String):
	print("Exited ", which)

	if sfx_stack.has(which):
		sfx_stack.erase(which)

	footsteps.set_parameter("GroundType", ground_types[sfx_stack.back()])
