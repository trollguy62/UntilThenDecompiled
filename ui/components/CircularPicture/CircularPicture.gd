extends TextureRect

const CircularMask = preload("CircularMask.gdshader")

var _texture: Texture


func _ready():
	material = ShaderMaterial.new()
	material.shader = CircularMask
	material.set_shader_parameter("tex", texture)


func _process(_delta):
	if _texture != texture:
		_texture = texture
		material.set_shader_parameter("tex", texture)
