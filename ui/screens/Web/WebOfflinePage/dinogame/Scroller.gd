extends Sprite2D

@onready var scroll_mat: ShaderMaterial = material

@export var speed := 1.0


func _ready():
	set_process(true)


func _process(delta):
	scroll_mat.set_shader_parameter("t", Utils.t * speed)
	scroll_mat.set_shader_parameter("albedo", self_modulate)
