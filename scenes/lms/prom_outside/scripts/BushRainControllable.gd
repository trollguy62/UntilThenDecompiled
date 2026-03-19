@tool
extends "res://scenes/_main/ch1sc8/scripts/RainControllable.gd"

@onready var _mat = get("material_override") as ShaderMaterial


func _set_intensity(t):
	if _mat:
		_mat.set_shader_parameter("wind_speed", lerp(0.3, 1.6, t))
		_mat.set_shader_parameter("turbulence_speed", lerp(1, 2, t))
		_mat.set_shader_parameter("turbulence_strength", lerp(0.01, 0.03, t))
