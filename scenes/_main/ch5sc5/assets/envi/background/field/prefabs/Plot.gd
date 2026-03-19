@tool
extends Node3D

const INSTANCE_DATA_SIZE = 16
const PLOT_SIZE = 5.0

@export var plot_material: ShaderMaterial
@export var plot_seed = 0.17
@export_range(0.0, 1.0) var field_coverage = 1.0

@export var grid_size = 32
@export var delta_uv = Vector2(0, 0)

@export var initial_displacement = Vector3(0, 0, 0)
@export var initial_scale = Vector3(1, 1, 1)

@export var random_displacement = Vector3(0.01, 0.02, 0.01)
@export var random_rotation = 30.0

@onready var plot = $Plot
@onready var crops = $Crops

var _plot_material: ShaderMaterial
var _particles_material: ShaderMaterial


func _ready():
	_plot_material = plot_material.duplicate()
	plot.material_override = _plot_material

	_particles_material = crops.process_material.duplicate()
	crops.process_material = _particles_material

	_particles_material.set_shader_parameter("plot_size", PLOT_SIZE)

	if Engine.is_editor_hint():
		update()


func update():
	crops.lifetime = 600.0
	crops.one_shot = true
	crops.amount = grid_size * grid_size

	_plot_material.set_shader_parameter("plot_seed", plot_seed)
	_plot_material.set_shader_parameter("delta_uv", delta_uv)
	_plot_material.set_shader_parameter("field_coverage", field_coverage)

	_particles_material.set_shader_parameter("plot_seed", plot_seed)
	_particles_material.set_shader_parameter("delta_uv", delta_uv)
	_particles_material.set_shader_parameter("field_coverage", field_coverage)

	_particles_material.set_shader_parameter("grid_size", grid_size)
	_particles_material.set_shader_parameter("initial_displacement", initial_displacement)
	_particles_material.set_shader_parameter("initial_scale", initial_scale)
	_particles_material.set_shader_parameter("random_displacement", random_displacement)
	_particles_material.set_shader_parameter("random_rotation", deg_to_rad(random_rotation))
