@tool
extends MeshInstance3D

@export_range(0.0, 1.0) var flicker_frequency = 0.0
@export_range(0.0, 1.0) var flicker_ratio := 0.5

var _lights := []
var _material: ShaderMaterial
var _initial_emission_energy := 0.0
var _noise := FastNoiseLite.new()
var _lit := false


func _ready():
	Utils.search_descendants(self, func(n): return n is Light3D, _lights)
	_noise.seed = randi()

	_material = material_override.duplicate()
	material_override = _material
	_initial_emission_energy = _material.get_shader_parameter("emission_energy")

	_set_lit(true, true)


func _process(delta):
	if flicker_frequency < Constants.EPSILON:
		_set_lit(true)
		return

	var time_fac = lerp(64.0, 512.0, flicker_frequency)
	var noise_val = _noise.get_noise_1d(Utils.t * time_fac)
	_set_lit(noise_val > lerp(-1.0, 1.0, pow(flicker_ratio, 1.3)))


func _set_lit(lit: bool, force: bool = false):
	if not force and lit == _lit:
		return

	_lit = lit
	_material.set_shader_parameter("emission_energy", _initial_emission_energy if lit else 0.0)

	for light in _lights:
		light.visible = lit
