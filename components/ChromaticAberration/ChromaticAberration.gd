@tool
extends TextureRect

@export var strength = 1.0
@export_range(0, 1) var inner_radius: float = 0.3
@export_range(1, 2) var outer_radius: float = 1.2


func _process(delta):
	var mat = material as ShaderMaterial
	mat.set_shader_parameter("strength", strength)
	mat.set_shader_parameter("inner_radius", inner_radius)
	mat.set_shader_parameter("outer_radius", outer_radius)
