@tool
extends Node3D

@onready var fields = $Background/Fields
@onready var guardrail_mat = $Highway/GuardrailL.material_override


func _process(_delta):
	var field_coverage = fields.field_coverage
	guardrail_mat.set_shader_parameter("t", field_coverage)
