@tool
extends Sprite2D

@export var color: Color = Color.WHITE
@export var speed: float = 1.0
@export_range(0.0, 1.0) var density = 0.6

@onready var mat = material as ShaderMaterial


func _ready():
	texture = preload("res://assets/misc/icon.png")


func _process(_delta):
	mat.set_shader_parameter("color", color)
	mat.set_shader_parameter("speed", speed)
	mat.set_shader_parameter("density", density)
	mat.set_shader_parameter("px_size", global_scale * texture.get_size())
