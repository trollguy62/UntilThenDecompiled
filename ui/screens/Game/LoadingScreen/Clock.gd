@tool
extends PanelContainer

@export_range(-8.0, 8.0) var speed = 1.0

var _t = 0.0


func _ready():
	assert(material is ShaderMaterial)


func _process(delta):
	_t += speed * delta
	material.set_shader_parameter("t", _t)
