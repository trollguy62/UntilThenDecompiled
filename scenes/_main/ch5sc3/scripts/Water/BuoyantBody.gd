extends RigidBody3D

@onready var probes = get_node("Probes")
@onready var collision_mesh = get_node("CollisionMesh")

@export var buoyancy = 5.0 : set= set_buoyancy, get =get_buoyancy
@export var created_waves_amplitude = 0.1
@export var water_node_path: NodePath
@export var water_height_offset = 0.0


func set_buoyancy(p_buoyancy):
	if is_inside_tree():
		for i in range(probes.get_child_count()):
			probes.get_child(i).buoyancy = p_buoyancy
	buoyancy = p_buoyancy


func get_buoyancy():
	return buoyancy


func _ready():
	collision_mesh.material_override = collision_mesh.material_override.duplicate()
	for i in range(probes.get_child_count()):
		probes.get_child(i).water_node = get_node(water_node_path)
		probes.get_child(i).buoyancy = buoyancy


func _physics_process(delta):
	collision_mesh.material_override.set_shader_parameter(
		"speed", created_waves_amplitude * linear_velocity.length()
	)

	for i in range(probes.get_child_count()):
		probes.get_child(i).water_height_offset = water_height_offset

		if probes.get_child(i).force > 0.0:
			apply_force(
				Vector3(0.0, probes.get_child(i).force, 0.0) / probes.get_child_count(),
				probes.get_child(i).global_transform.origin - global_transform.origin
			)
