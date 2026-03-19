extends MeshInstance3D


@export var target_viewport: Viewport

func _ready():
	if target_viewport != null:
		material_override.set_shader_parameter("texture_albedo", target_viewport.get_texture())
