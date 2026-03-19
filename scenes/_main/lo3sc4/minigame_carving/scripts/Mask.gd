extends SubViewport

@export var carving = false

@onready var shader_mat = $MaskRenderer.material as ShaderMaterial


func _process(delta):
	if carving:
		var texture = ImageTexture.create_from_image(self.get_texture().get_image())
		shader_mat.set_shader_parameter("tex_background", texture)
		shader_mat.set_shader_parameter("brush_pos", get_viewport().get_mouse_position() / Vector2(get_viewport().size))
