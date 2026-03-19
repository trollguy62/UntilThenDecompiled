@tool
extends Node3D

const MAX_EMISSION_ENERGY_LIGHT_POS := 2.2
const MAX_EMISSION_ENERGY_LIGHT_FAIRY := 1.7

@export var mat_light_post: ShaderMaterial
@export var mat_light_fairy: ShaderMaterial

@export_range(0.0, 1.0) var light_energy = 0.0 : set = set_light_energy


func _ready():
	for mat in [mat_light_post, mat_light_fairy]:
		var has_paremeter = true if mat.get_shader_parameter("emission_energy") != null else false
		assert(has_paremeter)

	self.light_energy = light_energy


func set_light_energy(value: float):
	light_energy = value
	mat_light_post.set_shader_parameter("emission_energy", value * MAX_EMISSION_ENERGY_LIGHT_POS)
	mat_light_fairy.set_shader_parameter("emission_energy", value * MAX_EMISSION_ENERGY_LIGHT_FAIRY)
