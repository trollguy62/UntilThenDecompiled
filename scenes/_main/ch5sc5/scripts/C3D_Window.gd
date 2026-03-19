@tool
extends Node2D

@export_range(0.0, 4.0) var blur_amount = 0.0:
	set = set_blur_amount

@onready var _pass_1_mat = $Pass2/Viewport/Pass1.material as ShaderMaterial  # tent filter (4 samples)
@onready var _pass_2_mat = $Pass2.material as ShaderMaterial  # unfocus (22 samples)


func _ready():
	self.blur_amount = blur_amount


func set_blur_amount(value):
	blur_amount = value
	if not is_inside_tree():
		return

	var p1_s = min(blur_amount / 3, 1) * 3.2
	var p2_s = blur_amount

	_pass_1_mat.set_shader_parameter("strength", p1_s)
	_pass_2_mat.set_shader_parameter("strength", p2_s)
