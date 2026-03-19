extends Node

@export var ssfx_glitch_mat: ShaderMaterial
@export var diffraction_mat: ShaderMaterial

var _scene_state: StateContainer

func _ready():
	_scene_state = Service.of("SceneState") as StateContainer
	_scene_state.changed.connect(_on_scene_state_changed)
	_on_scene_state_changed()


func _on_scene_state_changed():
	_set_glitch_fac(float(_scene_state.dict.get_value("glitch", 0.0)))


func _set_glitch_fac(glitch_fac: float):
	if ssfx_glitch_mat != null:
		ssfx_glitch_mat.set_shader_parameter("strength", glitch_fac)

	if diffraction_mat != null:
		diffraction_mat.set_shader_parameter("fluctuate_strength", lerpf(0.04, 1.0, glitch_fac))
