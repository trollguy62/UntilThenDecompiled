extends MeshInstance3D

const SCREEN_MATERIAL_IDX = 1

@export var tv_viewport: Viewport

@onready var tv_material = get_surface_override_material(SCREEN_MATERIAL_IDX)

func _ready():
	tv_material.set_shader_parameter("tex_background", tv_viewport.get_texture())
