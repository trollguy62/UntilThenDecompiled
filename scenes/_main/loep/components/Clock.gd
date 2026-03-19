extends PanelContainer

@export var speed := 1.0

var _rotation = 0.0


func _process(delta):
	_rotation += speed * delta * 2.0 * PI
	(material as ShaderMaterial).set_shader_parameter("rotation", _rotation)
