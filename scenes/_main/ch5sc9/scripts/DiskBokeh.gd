@tool
extends CanvasLayer

@export_range(0.0, 4.0) var strength = 1.0
@export_range(0.0, 2.0) var mul_rand_strength = 0.0
@export var modulate = Color.WHITE

@onready var pass_1 = $Pass1
@onready var tent_filter = $TentFilter
@onready var pass_2 = $TentFilter/Pass2

@onready var mat_pass_1 = pass_1.material as ShaderMaterial
@onready var mat_pass_2 = pass_2.material as ShaderMaterial


func _process(_delta):
	visible = strength > 0
	pass_1.modulate = modulate
	tent_filter.copy_mode = (
		BackBufferCopy.COPY_MODE_VIEWPORT
		if visible
		else BackBufferCopy.COPY_MODE_DISABLED
	)

	if visible:
		mat_pass_1.set_shader_parameter("strength", strength)
		mat_pass_1.set_shader_parameter("mul_rand_strength", mul_rand_strength)
		mat_pass_2.set_shader_parameter("strength", clamp(strength, 0, 1))
