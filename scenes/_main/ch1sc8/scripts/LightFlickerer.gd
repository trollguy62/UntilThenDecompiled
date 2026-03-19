@tool
extends Light3D

@export var flickering = true

@export var noise := FastNoiseLite.new()
@export var min_energy := 0.0
@export var max_energy := 1.0
@export var speed := 1.0
@export var damping := 1.0

@export var mat_emissive: ShaderMaterial
@export var mat_emission_energy_param_name = "emission_energy"
@export var min_emission_energy := 0.0
@export var max_emission_energy := 1.0

var _t := 0.0


func _process(delta):
	var x = 1.0

	if flickering:
		_t += delta
		x = noise.get_noise_1d(_t * speed)
		x = pow((x / 2) + 0.5, damping)

	var energy = lerpf(min_energy, max_energy, x)
	light_energy = energy

	if mat_emissive != null:
		var emission_energy = lerpf(min_emission_energy, max_emission_energy, x)
		mat_emissive.set_shader_parameter(mat_emission_energy_param_name, emission_energy)
