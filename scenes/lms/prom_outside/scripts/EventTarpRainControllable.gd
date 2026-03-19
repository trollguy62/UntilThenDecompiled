@tool
extends "res://scenes/_main/ch1sc8/scripts/RainControllable.gd"

@onready var _mat = get("material_override") as ShaderMaterial


func _set_intensity(t: float):
	if _mat:
		_mat.set_shader_parameter("strength", lerpf(0.8, 1.5, t))
		_mat.set_shader_parameter("speed", lerpf(1.0, 3.2, t))
